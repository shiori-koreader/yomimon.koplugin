--[[--
Literary influences (since 28/10/2026): readings slowly change the way Yomimon thinks and speaks.

Three levels, all from 0 to 100 per influence (yomimon_data/influences.lua):
  contexto   the current book, by its vector (yomimon_vector.lua); redone every 5 pages read
  recente    what you have been reading: on each page really read, it moves 1/300 of the way to the context
  acumulada  what stayed: it moves 1/2000 of the way. A 300-page book that is 70 in an influence leaves
             the recent near 44 and the accumulated near 10. No single book turns its head.
Only a page really read and never read before counts (the same door as the traits: M.digerir with text). Before
20 pages the book has no vector, and nothing changes.

In speech (State.fala → Influences.fala), the mix weighs 45% the context, 30% the recent and 25% the accumulated. The
strongest influence picks the phrase; the second, if strong enough, enters the same phrase through a
"lens" (a name with an article, in a {lente} gap) or through a "fecho" (a whole short phrase at the end). Without a
strong influence, the base personality comes out, sometimes seasoned by the strongest there is. Its stage
(ninfa, jovem, adulta, anciã) chooses among the phrases marked with `stage`; the current stage's weighs more.
Stored state: s.influencias = { acumulada, recente, livro, contexto, context_at, tema, paginas }.
Pure logic (no KOReader), testable outside it. No network, no AI.
]]

local Language = require("yomimon_language")

local Infl = {}

Infl.RECENT = 300       -- pages: how long the recent takes to follow the book
Infl.ACCUMULATED = 2000    -- pages: how long the accumulated takes
Infl.RECOMPUTE = 5      -- pages read between one context computation and the next
Infl.WEIGHTS = { context = 0.45, recent = 0.30, accumulated = 0.25 }
Infl.MINIMUM = 15         -- mix from which an influence picks the phrase
Infl.SECOND = 0.6       -- the second enters if it has at least 60% of the first (and the minimum)
Infl.PER_POINTS = 4      -- chance of an influence phrase: 1 in 20 for each 4 points of the strongest, up to 4 in 20
Infl.MAX_CHANCE = 4      -- (it was 6 in 10; with 70 phrases per influence and the EPUB tags, a strong genre took 4 phrases in 10)
Infl.BASE = 3            -- chance of the base personality, when the influence did not speak: 3 in 20 (it was 3 in 10)
Infl.MAX_SPEECH = 150      -- with the fecho, the phrase does not go past this
Infl.CLOSING_UNTIL = 110     -- the fecho only enters a short phrase (up to 110 letters and 2 sentences): one quip per phrase
Infl.SHORT_UNTIL = 52      -- on the Home, a phrase without a short version only enters if it has up to this many letters
Infl.TAG = 40       -- in the book profile, the genre the EPUB tag indicates is worth at least this

local okL, LIST = pcall(require, "yomimon_data.influences")
Infl.LIST = okL and type(LIST) == "table" and LIST or {}
Infl.BY_ID = {}
for _, I in ipairs(Infl.LIST) do Infl.BY_ID[I.id] = I end

local banks = {}
--- Phrases in the current language (yomimon_locales/<code>/data/influences.lua), or nil.
function Infl.bank()
    local c = Language.code()
    if banks[c] == nil then
        local ok, b = pcall(Language.data, "influences")
        banks[c] = ok and type(b) == "table" and b.base and b.influences and b or false
    end
    return banks[c] or nil
end
function Infl.useBank(b) banks[Language.code()] = b end  -- (for tests)

local function sat(x, k)
    if not x or x <= 0 then return 0 end
    return 1 - math.exp(-x / k)
end

--- Intensity of each influence in a book, from 0 to 100, from its vector (Vector.de) and the
-- happenings per page. Returns the profile and the book's strongest theme (or nil).
function Infl.profileOf(v, events_per_page)
    local f = {}
    for _, p in ipairs(v.themes or {}) do f[p[1]] = sat(p[2], 0.4) end
    for ev, rate in pairs(events_per_page or {}) do f["ev_" .. ev] = sat(rate, 0.2) end
    f._gloomy, f._light = sat(-(v.tone or 0), 2), sat(v.tone or 0, 2)
    f._long_sentence, f._short_sentence = sat(v.sentence or 0, 2), sat(-(v.sentence or 0), 2)
    f._theatre = v.theatre and 1 or 0
    f._first_person = v.first and 1 or 0
    local profile = {}
    for _, I in ipairs(Infl.LIST) do
        local sum = 0
        for lookupKey, weight in pairs(I.recipe) do sum = sum + weight * (f[lookupKey] or 0) end
        profile[I.id] = math.floor(math.min(100, 100 * sum) + 0.5)
    end
    local theme = v.themes and v.themes[1] and v.themes[1][1] or nil
    return profile, theme
end

local okG, GENRES = pcall(require, "yomimon_data.genres")
GENRES = okG and type(GENRES) == "table" and GENRES or {}
local FOLD = { ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["é"] = "e", ["ê"] = "e", ["í"] = "i",
    ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ü"] = "u", ["ç"] = "c", ["Á"] = "a", ["À"] = "a",
    ["Â"] = "a", ["Ã"] = "a", ["É"] = "e", ["Ê"] = "e", ["Í"] = "i", ["Ó"] = "o", ["Ô"] = "o", ["Õ"] = "o",
    ["Ú"] = "u", ["Ç"] = "c" }

--- The influences the book's genre tags indicate (yomimon_data/genres.lua): { id = true }.
function Infl.ofGenre(tags)
    local ids = {}
    for _, e in ipairs(type(tags) == "table" and tags or {}) do
        local t = tostring(e):gsub("\195[\128-\191]", FOLD):lower()
        for _, g in ipairs(GENRES) do
            if t:find(g[1], 1, true) then
                for i = 2, #g do ids[g[i]] = true end
            end
        end
    end
    return ids
end

--- Book profile (like Infl.profileOf) or nil if it is still early. The genre the EPUB tags indicate
-- is worth at least Infl.TAG: the tag is only a map (it says which genre the book is); what moves Yomimon
-- is still each page read, in Infl.digerir.
function Infl.profile(L)
    local okV, Vector = pcall(require, "yomimon_vector")
    local v = okV and L and Vector.de(L)
    if not v then return nil end
    local ev = {}
    for k, c in pairs(L.events or {}) do ev[k] = c / v.pages end
    local profile, theme = Infl.profileOf(v, ev)
    for id in pairs(Infl.ofGenre(L.tags)) do
        if profile[id] then profile[id] = math.max(profile[id], Infl.TAG) end
    end
    return profile, theme
end

local function rounded(x) return math.floor(x * 1000 + 0.5) / 1000 end

--- A page really read of book L (yomimon_memory.lua, together with the traits).
function Infl.digest(s, book, L)
    if not (book and L) then return end
    local I = type(s.influences) == "table" and s.influences or {}
    s.influences = I
    if type(I.accumulated) ~= "table" then I.accumulated = {} end
    if type(I.recent) ~= "table" then I.recent = {} end
    local P = L.text_pages or 0
    local em = tonumber(I.context_at) or 0
    if I.book ~= book or type(I.context) ~= "table" or P - em >= Infl.RECOMPUTE or P < em then
        local profile, theme = Infl.profile(L)
        I.book, I.context, I.context_at, I.theme = book, profile, P, theme
    end
    if type(I.context) ~= "table" then return end
    for id, target in pairs(I.context) do
        local r, a = tonumber(I.recent[id]) or 0, tonumber(I.accumulated[id]) or 0
        I.recent[id] = rounded(r + (target - r) / Infl.RECENT)
        I.accumulated[id] = rounded(a + (target - a) / Infl.ACCUMULATED)
    end
    I.pages = (tonumber(I.pages) or 0) + 1
end

--- The mix that applies in speech: { id = value }. The context only counts if it is of the current book.
function Infl.mixture(s)
    local I = type(s.influences) == "table" and s.influences or {}
    local ctx = (I.book == s.last_book and type(I.context) == "table") and I.context or {}
    local rec = type(I.recent) == "table" and I.recent or {}
    local acu = type(I.accumulated) == "table" and I.accumulated or {}
    local P = Infl.WEIGHTS
    local m = {}
    for _, inf in ipairs(Infl.LIST) do
        local id = inf.id
        m[id] = P.context * (tonumber(ctx[id]) or 0) + P.recent * (tonumber(rec[id]) or 0)
            + P.accumulated * (tonumber(acu[id]) or 0)
    end
    return m
end

--- The influences that rule now: up to two, { {id, value}, ... }, the strongest first.
function Infl.dominants(s)
    local m = Infl.mixture(s)
    local list = {}
    for _, inf in ipairs(Infl.LIST) do
        if m[inf.id] >= Infl.MINIMUM then list[#list + 1] = { inf.id, m[inf.id] } end
    end
    table.sort(list, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    local out = { list[1] }
    if list[2] and list[2][2] >= Infl.SECOND * list[1][2] then out[2] = list[2] end
    return out
end

-- Speech ------------------------------------------------------------------------------------------

--- Kind of a bank phrase: "modelo" (has gaps) or "fixa".
function Infl.kind(sentence)
    local t = type(sentence) == "table" and sentence[1] or sentence
    return (type(t) == "string" and t:find("{", 1, true)) and "template" or "fixa"
end

-- the standout happening of the 3 most recent chapters of the current book, or nil
local function recentEvent(s, Memory)
    local L = s.last_book and s.books and s.books[s.last_book]
    if not (L and L.caps and Memory) then return nil end
    local caps = {}
    for _, C in pairs(L.caps) do caps[#caps + 1] = C end
    table.sort(caps, function(a, b) return (a.order or 0) > (b.order or 0) end)
    for i = 1, math.min(3, #caps) do
        local ev = Memory.chapterEvent(L, caps[i])
        if ev then return ev end
    end
    return nil
end

-- values of the gaps that exist now; a gap without data leaves the phrase out
local function blanks(s, data, B)
    local okM, Memory = pcall(require, "yomimon_memory")
    local I = type(s.influences) == "table" and s.influences or {}
    local v = { book = s.last_book, character = data and data.character, word = data and data.word }
    local theme = I.book == s.last_book and I.theme or nil
    if theme and okM then v.theme, v.of_theme = Memory.theme(theme), Memory.theme(theme, "de") end
    local ev = recentEvent(s, okM and Memory)
    if ev and B.events then v.event = B.events[ev] end
    local L = s.last_book and s.books and s.books[s.last_book]
    if L and type(L.author) == "string" and L.author:find("%S") then v.author = L.author end
    -- the last finished book that is not the current one (the diary reviews)
    local reviews = type(s.reviews) == "table" and s.reviews or {}
    for i = #reviews, 1, -1 do
        local r = reviews[i]
        if type(r) == "table" and type(r.book) == "string" and r.book ~= s.last_book then
            v.previous = r.book
            break
        end
    end
    return v
end

-- a phrase marked with a stage (or list of stages) only applies in it
local function ofStage(f, stage)
    if not f.stage then return true end
    if type(f.stage) == "string" then return f.stage == stage end
    for _, x in ipairs(f.stage) do if x == stage then return true end end
    return false
end

local function serve(f, sit, values, lens)
    if f.when and not (sit and sit[f.when]) then return false end
    if not ofStage(f, sit and sit.stage) then return false end
    for nameText in f[1]:gmatch("{([%w_]+)}") do
        if nameText == "lens" then
            if not lens then return false end
        elseif not values[nameText] then
            return false
        end
    end
    return true
end

-- on the Home (2 lines, ~50 letters) only the short version or a phrase that is already short and without gaps serve
local function fitsOnHome(f)
    return f.short ~= nil or (#f[1] <= Infl.SHORT_UNTIL and not f[1]:find("{", 1, true))
end

local function pick(list, sit, values, lens, draw, said_f)
    local cands, total = {}, 0
    local home = sit and sit.screen == "home"
    for _, f in ipairs(list or {}) do
        if serve(f, sit, values, lens) and not (said_f and said_f("infl:" .. f[1])) and (not home or fitsOnHome(f)) then
            -- the phrase made for the situation or for the current stage wins
            local w = 1 + (f.when and 2 or 0) + (f.stage and 2 or 0)
            cands[#cands + 1] = { f, w }
            total = total + w
        end
    end
    if total == 0 then return nil end
    local r = draw(total)
    for _, c in ipairs(cands) do
        r = r - c[2]
        if r <= 0 then return c[1] end
    end
    return cands[#cands][1]
end

--- Fills a template: gaps, lens and the capital first letter.
function Infl.fill(textValue, values, lens)
    local out = textValue:gsub("{([%w_]+)}", function(nameText)
        if nameText == "lens" then return lens end
        return values[nameText]
    end)
    return (out:gsub("^%l", string.upper))
end

--- Joins a fecho at the end of a phrase (both are whole phrases), or nil if it does not fit. A long phrase or
-- one of 3+ sentences already has its quip and stays as it is.
function Infl.join(textValue, closing)
    if not (closing and textValue:find("[%.!%?…]$")) then return nil end
    local _, sentences = textValue:gsub("[%.!%?…]+%s", "")
    if #textValue > Infl.CLOSING_UNTIL or sentences >= 2 then return nil end
    local alongside = textValue .. " " .. closing
    if #alongside > Infl.MAX_SPEECH then return nil end
    return alongside
end

--- A phrase from an influence or from the base personality, or nil (then the rest of State.fala decides).
-- dados: those of Estado (personagem, palavra…); situ: { triste, feliz, fome, cheia, noite, muda = true/false,
-- fase = "ninfa" | "jovem" | "adulta" | "ancia", tela = "home" | "traca" | nil };
-- dita(chave): true if the phrase was said a moment ago (it stays out). Returns the text and the key of the no-repeat
-- rule (the bank phrase, before filling; the short version uses the same key). On the Home the short
-- version comes out (`short`), without a fecho.
function Infl.speech(s, data, draw, sit, said_f)
    local B = Infl.bank()
    if not B then return nil end
    draw = draw or math.random
    local dom = Infl.dominants(s)
    local d1, d2 = dom[1], dom[2]
    local k = d1 and math.min(Infl.MAX_CHANCE, math.floor(d1[2] / Infl.PER_POINTS)) or 0
    local r = draw(20)
    local list, lens_of, closing_of, closing_chance
    if d1 and r <= k then
        -- the strongest picks; the second lends the lens or the fecho
        list = B.influences[d1[1]] and B.influences[d1[1]].sentences
        lens_of, closing_of, closing_chance = d2 and d2[1] or d1[1], d2 and d2[1], 2
    elseif r > 20 - Infl.BASE then
        -- base personality, seasoned by the strongest influence, if any
        list = B.base
        lens_of, closing_of, closing_chance = d1 and d1[1], d1 and d1[1], 3
    else
        return nil
    end
    local values = blanks(s, data, B)
    local lenses = lens_of and B.influences[lens_of] and B.influences[lens_of].lenses
    local lens = lenses and #lenses > 0 and lenses[draw(#lenses)] or nil
    local f = pick(list, sit, values, lens, draw, said_f)
    if not f then return nil end
    if sit and sit.screen == "home" then
        return Infl.fill(f.short or f[1], values, lens), "infl:" .. f[1]
    end
    local textValue = Infl.fill(f[1], values, lens)
    local closings = closing_of and B.influences[closing_of] and B.influences[closing_of].closings
    if closings and #closings > 0 and not f[1]:find("{lens}", 1, true) and draw(closing_chance) == 1 then
        textValue = Infl.join(textValue, closings[draw(#closings)]) or textValue
    end
    return textValue, "infl:" .. f[1]
end

return Infl
