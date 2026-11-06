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

local Lingua = require("yomimon_language")
local Voz = require("yomimon_voice")

local F = {}

for fase, bancos in pairs(Lingua.content("speech")) do F[fase] = bancos end




-- Dreams: what it mutters while sleeping (at night and on the sleep screen), by temperament.

-- ninfa uses F.ninfa, jovem F.jovem, adulta F.adulta, anciã F.ancia
local POR_FASE = { ninfa = F.ninfa, jovem = F.jovem, adulta = F.adulta, ancia = F.ancia }

local function brechas(texto)
    local lista = {}
    for b in texto:gmatch("{(%a+)}") do lista[#lista + 1] = b end
    return lista
end

--- How many different phrases a stage can generate (with all the gaps available).
function F.contar(fase)
    local g = POR_FASE[fase]
    if not g then return 0 end
    local function unicos(t) local u = {} for _, v in ipairs(t) do u[v] = true end local n = 0 for _ in pairs(u) do n = n + 1 end return n end
    return unicos(g.abertura) * unicos(g.nucleo) * unicos(g.fecho)
end

--- Builds a phrase from a bank { abertura, nucleo, fecho }.
-- Returns the phrase and the core used (before filling), which serves to avoid repetition.
local function gerarDe(g, dados, sorteio)
    local possiveis = {}
    for _, n in ipairs(g.nucleo) do
        local ok = true
        for _, b in ipairs(brechas(n)) do if not dados[b] then ok = false break end end
        if ok then possiveis[#possiveis + 1] = n end
    end
    if #possiveis == 0 then return nil end
    -- dados.voz swaps the trait marks and domain words for what applies (yomimon_voice.lua); without it,
    -- the default text of each mark applies
    local voz = dados.voz or function(t) return Voz.resolver(t, nil) end
    -- dados.escolher: a draw in which the phrase that matches it weighs more (yomimon_voice.lua)
    local escolher = dados.escolher or function(lista) return lista[sorteio(#lista)] end
    -- the domain vocabulary enters once per phrase: the part that comes after does not use it (less seasoning)
    local nucleo = escolher(possiveis)
    local modelo = nucleo
    local _, ja_dominio
    nucleo, _, ja_dominio = voz(nucleo)
    local partes = {}
    local a, _, dom_a = voz(escolher(g.abertura, ja_dominio), ja_dominio)
    ja_dominio = ja_dominio or dom_a
    if a ~= "" then partes[#partes + 1] = a end
    -- after "Sabia que…"/"mas"/":" the phrase continues in lowercase (never a proper name,
    -- nor the English "I")
    if a ~= "" and not nucleo:match("^{") and not nucleo:match("^I[%s']")
            and (a:sub(-1) == ":" or a:sub(-3) == "mas" or a:sub(-3) == "but" or a:sub(-1) == ","
            or a == "Sabia que…" or a == "Acho que…" or a == "Pensei bastante e" or a == "I think…"
            or a == "I've thought about it and") then
        nucleo = nucleo:gsub("^(%u)", string.lower)
    end
    nucleo = nucleo:gsub("{(%a+)}", function(b) return dados[b] end)
    partes[#partes + 1] = nucleo
    local f = (voz(escolher(g.fecho, ja_dominio), ja_dominio))
    if f ~= "" then partes[#partes + 1] = f end
    -- "Zzz…" + "…sonhando" becomes "Zzz… sonhando" (no doubled ellipses)
    for i = 2, #partes do
        if partes[i - 1]:sub(-3) == "…" and partes[i]:sub(1, 3) == "…" then partes[i] = partes[i]:sub(4) end
    end
    return table.concat(partes, " "), modelo
end

--- Generates a phrase. dados = { livro=, personagem=, tema=, palavra=, voz=, escolher= } (fields may be missing).
function F.gerar(fase, dados, sorteio)
    local g = POR_FASE[fase]
    if not g then return nil end
    return gerarDe(g, dados or {}, sorteio or math.random)
end

--- A dream (a phrase while sleeping). temperamento: "jovem" or "velha".
function F.sonhar(temperamento, dados, sorteio)
    local g = F.sonho[temperamento]
    if not g then return nil end
    return gerarDe(g, dados or {}, sorteio or math.random)
end

return F
