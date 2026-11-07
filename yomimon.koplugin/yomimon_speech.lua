--[[--
Yomimon's phrase generator, by stage.

Each phrase = opening + core + closing (each part may be empty). The vocabulary of
each stage changes the degree of innocence: the nymph is curious and scared; the young, anxious and
starting to be ironic; the adult, cultured and cynical; the elder, bitter, wise and grumpy.

Gaps in the cores (filled with what it ate):
  {book}       title of the current book
  {character}  a frequent character of the current book
  {theme}        the obsession of the moment (e.g. "o mar")
  {word}     the last difficult word it ate
Cores with gaps that have no data available are skipped.
]]

local Language = require("yomimon_language")
local Voice = require("yomimon_voice")

local F = {}

for stage, banks in pairs(Language.content("speech")) do F[stage] = banks end




-- Dreams: what it mutters while sleeping (at night and on the sleep screen), by temperament.

-- nymph uses F.nymph, young F.young, adult F.adult, elder F.elder
local PER_STAGE = { nymph = F.nymph, young = F.young, adult = F.adult, elder = F.elder }

local function continuesLowercase(opening)
    local rule = Language.format().lowercase_after or {}
    for _, ending in ipairs(rule.endings or {}) do
        if opening:sub(-#ending) == ending then return true end
    end
    for _, whole in ipairs(rule.openings or {}) do
        if opening == whole then return true end
    end
    return false
end

local function gaps(textValue)
    local list = {}
    for b in textValue:gmatch("{(%a+)}") do list[#list + 1] = b end
    return list
end

--- How many different phrases a stage can generate (with all the gaps available).
function F.count(stage)
    local g = PER_STAGE[stage]
    if not g then return 0 end
    local function uniques(t) local u = {} for _, v in ipairs(t) do u[v] = true end local n = 0 for _ in pairs(u) do n = n + 1 end return n end
    return uniques(g.opening) * uniques(g.core) * uniques(g.closing)
end

--- Builds a phrase from a bank { opening, core, closing }.
-- Returns the phrase and the core used (before filling), which serves to avoid repetition.
local function generateFrom(g, data, draw)
    local possible = {}
    for _, n in ipairs(g.core) do
        local ok = true
        for _, b in ipairs(gaps(n)) do if not data[b] then ok = false break end end
        if ok then possible[#possible + 1] = n end
    end
    if #possible == 0 then return nil end
    -- data.voice swaps the trait marks and domain words for what applies (yomimon_voice.lua); without it,
    -- the default text of each mark applies
    local voice = data.voice or function(t) return Voice.resolver(t, nil) end
    -- data.pick: a draw in which the phrase that matches it weighs more (yomimon_voice.lua)
    local pick = data.pick or function(list) return list[draw(#list)] end
    -- the domain vocabulary enters once per phrase: the part that comes after does not use it (less seasoning)
    local core = pick(possible)
    local template = core
    local _, already_domain
    core, _, already_domain = voice(core)
    local parts = {}
    local a, _, new_domain = voice(pick(g.opening, already_domain), already_domain)
    already_domain = already_domain or new_domain
    if a ~= "" then parts[#parts + 1] = a end
    -- the core continues in lowercase after a connective opening (never a proper name, nor the English "I")
    if a ~= "" and not core:match("^{") and not core:match("^I[%s']") and continuesLowercase(a) then
        core = core:gsub("^(%u)", string.lower)
    end
    core = core:gsub("{(%a+)}", function(b) return data[b] end)
    parts[#parts + 1] = core
    local f = (voice(pick(g.closing, already_domain), already_domain))
    if f ~= "" then parts[#parts + 1] = f end
    -- "Zzz…" + "…sonhando" becomes "Zzz… sonhando" (no doubled ellipses)
    for i = 2, #parts do
        if parts[i - 1]:sub(-3) == "…" and parts[i]:sub(1, 3) == "…" then parts[i] = parts[i]:sub(4) end
    end
    return table.concat(parts, " "), template
end

--- Generates a phrase. data = { book=, character=, theme=, word=, voice=, pick= } (fields may be missing).
function F.generate(stage, data, draw)
    local g = PER_STAGE[stage]
    if not g then return nil end
    return generateFrom(g, data or {}, draw or math.random)
end

--- A dream (a phrase while sleeping). temperament: "young" or "old".
function F.dream(temperament, data, draw)
    local g = F.dreamPhrase[temperament]
    if not g then return nil end
    return generateFrom(g, data or {}, draw or math.random)
end

return F
