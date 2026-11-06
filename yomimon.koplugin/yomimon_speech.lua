--[[--
Yomimon's phrase generator, by stage.

Each phrase = opening + core + closing (each part may be empty). The vocabulary of
each stage changes the degree of innocence: the ninfa is curious and scared; the jovem, anxious and
starting to be ironic; the adulta, cultured and cynical; the anciã, bitter, wise and grumpy.

Gaps in the cores (filled with what it ate):
  {livro}       title of the current book
  {personagem}  a frequent character of the current book
  {tema}        the obsession of the moment (e.g. "o mar")
  {palavra}     the last difficult word it ate
Cores with gaps that have no data available are skipped.
]]

local Language = require("yomimon_language")
local Voice = require("yomimon_voice")

local F = {}

for stage, banks in pairs(Language.content("speech")) do F[stage] = banks end




-- Dreams: what it mutters while sleeping (at night and on the sleep screen), by temperament.

-- ninfa uses F.ninfa, jovem F.jovem, adulta F.adulta, anciã F.ancia
local PER_STAGE = { nymph = F.nymph, young = F.young, adult = F.adult, elder = F.elder }

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

--- Builds a phrase from a bank { abertura, nucleo, fecho }.
-- Returns the phrase and the core used (before filling), which serves to avoid repetition.
local function generateFrom(g, data, draw)
    local possible = {}
    for _, n in ipairs(g.core) do
        local ok = true
        for _, b in ipairs(gaps(n)) do if not data[b] then ok = false break end end
        if ok then possible[#possible + 1] = n end
    end
    if #possible == 0 then return nil end
    -- dados.voz swaps the trait marks and domain words for what applies (yomimon_voice.lua); without it,
    -- the default text of each mark applies
    local voice = data.voice or function(t) return Voice.resolver(t, nil) end
    -- dados.escolher: a draw in which the phrase that matches it weighs more (yomimon_voice.lua)
    local pick = data.pick or function(list) return list[draw(#list)] end
    -- the domain vocabulary enters once per phrase: the part that comes after does not use it (less seasoning)
    local core = pick(possible)
    local template = core
    local _, already_domain
    core, _, already_domain = voice(core)
    local parts = {}
    local a, _, dom_a = voice(pick(g.opening, already_domain), already_domain)
    already_domain = already_domain or dom_a
    if a ~= "" then parts[#parts + 1] = a end
    -- after "Sabia que…"/"mas"/":" the phrase continues in lowercase (never a proper name,
    -- nor the English "I")
    if a ~= "" and not core:match("^{") and not core:match("^I[%s']")
            and (a:sub(-1) == ":" or a:sub(-3) == "mas" or a:sub(-3) == "but" or a:sub(-1) == ","
            or a == "Sabia que…" or a == "Acho que…" or a == "Pensei bastante e" or a == "I think…"
            or a == "I've thought about it and") then
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

--- Generates a phrase. dados = { livro=, personagem=, tema=, palavra=, voz=, escolher= } (fields may be missing).
function F.generate(stage, data, draw)
    local g = PER_STAGE[stage]
    if not g then return nil end
    return generateFrom(g, data or {}, draw or math.random)
end

--- A dream (a phrase while sleeping). temperamento: "jovem" or "velha".
function F.dream(temperament, data, draw)
    local g = F.dreamPhrase[temperament]
    if not g then return nil end
    return generateFrom(g, data or {}, draw or math.random)
end

return F
