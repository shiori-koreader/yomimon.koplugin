--[[--
Gerador de falas da Yomimon, por fase.

Cada fala = abertura + núcleo + fecho (cada parte pode ser vazia). O vocabulário de
cada fase muda o grau de inocência: a ninfa é curiosa e assustada; a jovem, ansiosa e
começando a ironizar; a adulta, culta e cínica; a anciã, amarga, sábia e ranzinza.

Brechas nos núcleos (preenchidas com o que ela comeu):
  {livro}       título do livro atual
  {personagem}  um personagem frequente do livro atual
  {tema}        a obsessão do momento (ex.: "o mar")
  {palavra}     a última palavra difícil que ela comeu
Núcleos com brechas sem dado disponível são pulados.
]]

local Lingua = require("yomimon_language")
local Voz = require("yomimon_voice")

local F = {}

for fase, bancos in pairs(Lingua.content("speech")) do F[fase] = bancos end




-- Sonhos: o que ela resmunga dormindo (de noite e na tela de descanso), por temperamento.

-- ninfa usa F.ninfa, jovem F.jovem, adulta F.adulta, anciã F.ancia
local POR_FASE = { ninfa = F.ninfa, jovem = F.jovem, adulta = F.adulta, ancia = F.ancia }

local function brechas(texto)
    local lista = {}
    for b in texto:gmatch("{(%a+)}") do lista[#lista + 1] = b end
    return lista
end

--- Quantas falas diferentes uma fase consegue gerar (com todas as brechas disponíveis).
function F.contar(fase)
    local g = POR_FASE[fase]
    if not g then return 0 end
    local function unicos(t) local u = {} for _, v in ipairs(t) do u[v] = true end local n = 0 for _ in pairs(u) do n = n + 1 end return n end
    return unicos(g.abertura) * unicos(g.nucleo) * unicos(g.fecho)
end

--- Monta uma fala a partir de um banco { abertura, nucleo, fecho }.
-- Devolve a fala e o núcleo usado (antes de preencher), que serve para evitar repetição.
local function gerarDe(g, dados, sorteio)
    local possiveis = {}
    for _, n in ipairs(g.nucleo) do
        local ok = true
        for _, b in ipairs(brechas(n)) do if not dados[b] then ok = false break end end
        if ok then possiveis[#possiveis + 1] = n end
    end
    if #possiveis == 0 then return nil end
    -- dados.voz troca as marcas de traço e as palavras de domínio pelo que vale (yomimon_voice.lua); sem ela,
    -- vale o texto padrão de cada marca
    local voz = dados.voz or function(t) return Voz.resolver(t, nil) end
    -- dados.escolher: sorteio em que a fala que combina com ela pesa mais (yomimon_voice.lua)
    local escolher = dados.escolher or function(lista) return lista[sorteio(#lista)] end
    -- o vocabulário de domínio entra uma vez só por fala: a parte que vem depois não usa (menos tempero)
    local nucleo = escolher(possiveis)
    local modelo = nucleo
    local _, ja_dominio
    nucleo, _, ja_dominio = voz(nucleo)
    local partes = {}
    local a, _, dom_a = voz(escolher(g.abertura, ja_dominio), ja_dominio)
    ja_dominio = ja_dominio or dom_a
    if a ~= "" then partes[#partes + 1] = a end
    -- depois de "Sabia que…"/"mas"/":" a frase continua em minúscula (nunca um nome próprio,
    -- nem o "I" do inglês)
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
    -- "Zzz…" + "…sonhando" vira "Zzz… sonhando" (sem reticências dobradas)
    for i = 2, #partes do
        if partes[i - 1]:sub(-3) == "…" and partes[i]:sub(1, 3) == "…" then partes[i] = partes[i]:sub(4) end
    end
    return table.concat(partes, " "), modelo
end

--- Gera uma fala. dados = { livro=, personagem=, tema=, palavra=, voz=, escolher= } (campos podem faltar).
function F.gerar(fase, dados, sorteio)
    local g = POR_FASE[fase]
    if not g then return nil end
    return gerarDe(g, dados or {}, sorteio or math.random)
end

--- Um sonho (fala dormindo). temperamento: "jovem" ou "velha".
function F.sonhar(temperamento, dados, sorteio)
    local g = F.sonho[temperamento]
    if not g then return nil end
    return gerarDe(g, dados or {}, sorteio or math.random)
end

return F
