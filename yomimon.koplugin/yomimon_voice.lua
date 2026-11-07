--[[--
Yomimon's voice: the only place that understands the variant marks inside phrases.

Step 1, trait inside the phrase (as in Wildermyth):

    "Achei um ponto final e <bitter:fiquei aliviada|hopeful:já quero o próximo|fiquei com medo de acabar>."

- The mark starts with an option with a label. Each label is a trait pole: bitter, hopeful, fearful,
  brave, cynical, romantic, popular, erudite, diurnal or nocturnal. The option of the strongest striking pole
  (Traits.STRIKING) among those listed wins; a tie keeps the first.
- Optional threshold: "fearful.60:" only applies with the trait at 60 or more.
- The option without a label is the usual phrase: it applies when no listed pole is striking. It may be empty.
- Gaps {book}, {character}… may go inside the options, the same in all. %s and %d never: string.format
  counts all the options.

Step 2, vocabulary of what it ate (the domains of Caves of Qud):

    "Lambi a capa. Só tinha {taste|poeira}."         → "Só tinha sal." (whoever has been reading about the sea)
    "Ainda mastigando “%s”.<domain: Tem gosto de {taste}.|>"

- Each theme has a vocabulary (yomimon_locales/<code>/data/domains.lua) with six kinds of word:
  taste, smell, comparison, exclamation, place and thing.
- The domain of a phrase is the current book's or life's, its obsession (s.dominant_theme); when both
  exist and differ, the book's wins 6 times in 10. The book's, after a few pages, is the
  theme it has most ABOVE the average page (yomimon_base_topics.lua): family and time are in almost every
  old novel, so Dracula becomes fear, not time, and Macbeth becomes politics, not family.
- {taste|default}: the domain's word, or the default when there is no domain. {taste} without a default only in the
  generator cores, which skips the core when there is no domain.
- The "domain:" option of a mark applies when there is a domain and no listed pole won.
- It prefers words not yet used: it only repeats after going through all of the kind.

Pure logic (no KOReader), testable outside it.
]]

local Language = require("yomimon_language")
local Traits = require("yomimon_traits")

local Voice = {}

-- pole → axis and direction ("fearful" → courage, -1)
local POLES = {}
for _, tr in ipairs(Traits.LIST) do
    POLES[tr.neg] = { axis = tr.id, signal = -1 }
    POLES[tr.pos] = { axis = tr.id, signal = 1 }
end
Voice.POLES = POLES

-- Kinds of domain word.
Voice.SLOTS = { taste = true, smell = true, comparison = true, exclamation = true, place = true, thing = true }

Voice.BOOK_MIN_PAGES = 10  -- the book only becomes a domain after 10 pages…
Voice.BOOK_MIN_POINTS = 5    -- …with the theme at 5 points or more (count × theme weight, as in L.themes)
Voice.BOOK_CHANCE = 6        -- in 10: the book's domain beats life's

-- How much of each theme an average page has, by language.
local okBase, BASE_THEMES = pcall(require, "yomimon_base_topics")
Voice.BASE_THEMES = okBase and type(BASE_THEMES) == "table" and BASE_THEMES or nil

local banks = {}
--- Domain vocabulary in the current language (or nil).
function Voice.bank()
    local c = Language.code()
    if banks[c] == nil then
        local ok, b = pcall(Language.data, "domains")
        banks[c] = ok and type(b) == "table" and b or false
    end
    return banks[c] or nil
end

--- The theme the current book has most above the average page, or nil if it is still early.
function Voice.bookDomain(s)
    local L = s and s.last_book and s.books and s.books[s.last_book]
    local pages = L and L.pages or 0
    if pages < Voice.BOOK_MIN_PAGES then return nil end
    local lg = (L.pages_pt or 0) * 2 > pages and "pt" or "en"
    local media = Voice.BASE_THEMES and Voice.BASE_THEMES[lg] or {}
    local best, grade = nil, 0
    for t, c in pairs(L.themes or {}) do
        local above = c / pages - (media[t] or 0)
        if c >= Voice.BOOK_MIN_POINTS and (above > grade or (above == grade and best and t < best)) then
            best, grade = t, above
        end
    end
    return best
end

--- Its obsession (the life theme), or nil.
function Voice.lifeDomain(s)
    return s and s.dominant_theme
end

--- Is there any domain with vocabulary?
function Voice.domainAvailable(s)
    local B = Voice.bank()
    if not B then return false end
    local l, v = Voice.bookDomain(s), Voice.lifeDomain(s)
    return (l and B[l] ~= nil) or (v and B[v] ~= nil) or false
end

--- The domain of a phrase: the book's or life's (draw(n) returns from 1 to n).
function Voice.domain(s, draw)
    local B = Voice.bank()
    if not B then return nil end
    local book, life = Voice.bookDomain(s), Voice.lifeDomain(s)
    if book and not B[book] then book = nil end
    if life and not B[life] then life = nil end
    if book and life and book ~= life then
        return (draw or math.random)(10) <= Voice.BOOK_CHANCE and book or life
    end
    return book or life
end

-- Words used a moment ago, by theme and kind: it goes through all of them before repeating.
local used_ones = {}
function Voice.forgetWords() used_ones = {} end  -- (for tests)
function Voice.word(theme, slot, draw)
    local B = Voice.bank()
    local list = B and B[theme] and B[theme][slot]
    if not list or #list == 0 then return nil end
    local lookupKey = theme .. "/" .. slot
    local seenList = used_ones[lookupKey] or {}
    local free = {}
    for _, p in ipairs(list) do if not seenList[p] then free[#free + 1] = p end end
    if #free == 0 then seenList, free = {}, list end
    local p = free[(draw or math.random)(#free)]
    seenList[p] = true
    used_ones[lookupKey] = seenList
    return p
end

--- The options of a mark, separated by "|" (the "|" inside {taste|default} does not separate).
function Voice.parts(body)
    local out, ini, level = {}, 1, 0
    for i = 1, #body do
        local c = body:sub(i, i)
        if c == "{" then level = level + 1
        elseif c == "}" then level = math.max(0, level - 1)
        elseif c == "|" and level == 0 then out[#out + 1] = body:sub(ini, i - 1); ini = i + 1 end
    end
    out[#out + 1] = body:sub(ini)
    return out
end

--- Options of a group (the text between < and >): { {pole=, threshold=, textValue=} | {domain=true, textValue=} | {textValue=} }.
-- Returns nil if no option has a label (it is not a variant mark).
function Voice.options(body)
    local list, some = {}, false
    for _, part in ipairs(Voice.parts(body)) do
        local label, threshold, remainder = part:match("^(%l+)%.?(%d*):(.*)$")
        if label and POLES[label] then
            list[#list + 1] = { pole = label, threshold = tonumber(threshold) or Traits.STRIKING, textValue = remainder }
            some = true
        elseif label == "domain" then
            list[#list + 1] = { domain = true, textValue = remainder }
            some = true
        else
            list[#list + 1] = { textValue = part }
        end
    end
    return some and list or nil
end

local function pick(list, traits, hasDomain)
    local best, val, default, dominant
    for _, o in ipairs(list) do
        if o.pole then
            local p = POLES[o.pole]
            local v = (traits[p.axis] or 0) * p.signal
            if v >= o.threshold and (not best or v > val) then best, val = o, v end
        elseif o.domain then
            dominant = dominant or o
        elseif not default then
            default = o
        end
    end
    if best then return best.textValue, best.pole end
    if dominant and hasDomain() then return dominant.textValue end
    return default and default.textValue or ""
end

--- Swaps the trait marks and domain words for what applies to s.
-- no_domain (optional): does not use a domain (the generator already used it in another part of the same phrase).
-- Returns the text, the poles that chose some option and the theme of the domain used (or nil).
function Voice.resolver(textValue, s, draw, no_domain)
    if type(textValue) ~= "string" or not (textValue:find("<", 1, true) or textValue:find("{", 1, true)) then
        return textValue, {}, nil
    end
    local traits = s and s.traits or {}
    local poles, used = {}, nil
    local dominant  -- the phrase's domain, decided once only (false: none)
    local function domain()
        if no_domain then return nil end
        if dominant == nil then dominant = Voice.domain(s, draw) or false end
        return dominant or nil
    end
    -- 1) domain words, inside and outside the marks; each one stays between \1 and \2 until the end, to
    --    know whether it survived the choice of the mark
    local out = textValue:gsub("{(%l+)(|?)([^{}]*)}", function(nameText, bar, default)
        if not Voice.SLOTS[nameText] then return nil end
        local d = domain()
        local p = d and Voice.word(d, nameText, draw)
        if p then return "\1" .. p .. "\2" end
        if bar == "|" then return default end
        return nil
    end)
    -- 2) trait and domain marks
    out = out:gsub("<([^<>]*)>", function(body)
        local list = Voice.options(body)
        if not list then return nil end  -- not a mark: stays as it is
        local picked_one, pole = pick(list, traits, domain)
        if pole then poles[#poles + 1] = pole end
        return picked_one
    end)
    if out:find("\1", 1, true) then used = dominant or nil end
    out = out:gsub("[\1\2]", "")
    -- an empty option leaves extra space
    out = out:gsub("  +", " "):gsub("^ ", ""):gsub(" $", ""):gsub(" ([%.,!%?])", "%1")
    return out, poles, used
end

-- Step 4, the phrase that matches it wins (Valve, Hades, Emily Short) ----------------------------
-- When drawing from a list, the phrase that has a variant of one of its striking traits, or a domain word
-- when it has a domain, weighs more. Still a draw; without trait or domain, all weigh 1.
Voice.TRAIT_WEIGHT = 8     -- how much more a phrase with a variant of a striking pole weighs
Voice.DOMAIN_WEIGHT = 4   -- how much more a phrase with a domain word weighs, if it has a domain
-- (calibrated by the voice ruler on 27/10/2026: with 3 and 2, half of the profiles with a trait were below 50%
-- of phrases with a clue; with 8 and 4, all pass, without losing variety)

local clues_cache = {}  -- by bank text (the banks are fixed, so the cache does not grow forever)
--- What a phrase can show: { polos = {pole = true}, domain = bool } (stored by text).
function Voice.clues(textValue)
    if type(textValue) ~= "string" then return { poles = {}, domain = false } end
    local p = clues_cache[textValue]
    if p then return p end
    p = { poles = {}, domain = false }
    for body in textValue:gmatch("<([^<>]*)>") do
        for _, o in ipairs(Voice.options(body) or {}) do
            if o.pole then p.poles[o.pole] = true end
            if o.domain then p.domain = true end
        end
    end
    for nameText in textValue:gmatch("{(%l+)") do if Voice.SLOTS[nameText] then p.domain = true end end
    clues_cache[textValue] = p
    return p
end

--- Weight of a phrase for s: 1, plus TRAIT_WEIGHT if it lists a striking pole, plus DOMAIN_WEIGHT if it uses a
-- domain and it has a domain. domainAvailable (optional) avoids recomputing over a whole list.
function Voice.weight(textValue, s, domainAvailable)
    local p = Voice.clues(textValue)
    local w = 1
    local traits = s and s.traits or {}
    for pole in pairs(p.poles) do
        local q = POLES[pole]
        if (traits[q.axis] or 0) * q.signal >= Traits.STRIKING then w = w + Voice.TRAIT_WEIGHT; break end
    end
    if p.domain then
        if domainAvailable == nil then domainAvailable = Voice.domainAvailable(s) end
        if domainAvailable then w = w + Voice.DOMAIN_WEIGHT end
    end
    return w
end

--- Draws an item from the list, with the weight of each phrase (draw(n) returns from 1 to n).
-- no_domain (optional): the domain gives no weight (already used in another part of the phrase).
function Voice.pick(list, s, draw, no_domain)
    draw = draw or math.random
    if not list or #list == 0 then return nil end
    local dominant = not no_domain and Voice.domainAvailable(s)
    local weights, total = {}, 0
    for i, t in ipairs(list) do
        weights[i] = Voice.weight(t, s, dominant)
        total = total + weights[i]
    end
    if total == #list then return list[draw(#list)] end  -- nobody stands out: the usual draw
    local r = draw(total)
    for i, w in ipairs(weights) do
        r = r - w
        if r <= 0 then return list[i] end
    end
    return list[#list]
end

--- Cause invented afterwards (Caves of Qud): the bad mood gets a real reason from the current book, the
-- event that stood out most in a recent chapter. temperament: "young" or "old".
-- Returns the phrase or nil.
function Voice.cause(s, temperament, draw)
    local B = Voice.bank()
    local C = B and B._cause
    local L = s and s.last_book and s.books and s.books[s.last_book]
    if not (C and L and L.caps) then return nil end
    local ok, Memory = pcall(require, "yomimon_memory")
    if not ok then return nil end
    local caps = {}
    for _, cap in pairs(L.caps) do caps[#caps + 1] = cap end
    table.sort(caps, function(a, b) return (a.order or 0) > (b.order or 0) end)
    for i = 1, math.min(5, #caps) do
        local ev = Memory.chapterEvent(L, caps[i])
        local sentences = C[temperament == "young" and "young" or "old"]
        if ev and C.events[ev] and sentences then
            local t = sentences[(draw or math.random)(#sentences)]
            return (t:gsub("{event}", C.events[ev]):gsub("{book}", function() return s.last_book end))
        end
    end
end

return Voice
