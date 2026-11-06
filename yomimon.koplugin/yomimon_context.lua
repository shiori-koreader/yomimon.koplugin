--[[--
Phrases with data from your reading: time, pages today, record, streak of days,
non-stop session, days away and what part of the book you are in.

Each trigger looks at the state (filled by Estado.comer) and, if it applies, offers phrases
with gaps: {hora} ("2h13" / "2:13 a.m."), {n} (pages or days), {livro}, {pct}.
"Strong" triggers (small hours, record, marathon, vanishing) usually beat the other phrases.

Pure logic (no KOReader), testable outside it.
]]

local Lingua = require("yomimon_language")
local Voz = require("yomimon_voice")

local Contexto = {}

local LENDO_AGORA = 30 * 60   -- read in the last 30 min: it is reading now

-- Phrases by trigger and temperament ("jovem" = ninfa and jovem; "velha" = adulta and anciã).
local FALAS = Lingua.content("context")

Lingua.append(FALAS, Lingua.extra("contexto"))  -- new batches of phrases

--- Hour for the phrases, formatted by the language ("2h13", "2:13 a.m.").
function Contexto.hora(agora)
    return Lingua.format().clock(os.date("*t", agora))
end

--- Triggers that apply now, each { nome, n, forte }, the strong ones first.
function Contexto.gatilhos(s, agora)
    local lista = {}
    local function add(nome, n, forte) lista[#lista + 1] = { nome = nome, n = n, forte = forte or false } end
    local hora = tonumber(os.date("%H", agora))
    local hoje_dia = os.date("%Y-%m-%d", agora)
    local hoje = s.hoje == hoje_dia and (s.paginas_hoje or 0) or 0
    local desde = s.ultima_refeicao and (agora - s.ultima_refeicao)
    local lendo = desde and desde < LENDO_AGORA

    if lendo and hora < 5 then add("madrugada", nil, true) end
    if s.recorde_em == hoje_dia and hoje >= 10 and hoje >= (s.recorde_dia or 0) then add("recorde", hoje, true)
    elseif hoje >= 40 then add("maratona", hoje, true) end
    if desde and desde >= 2 * 86400 then add("sumiu", math.floor(desde / 86400), true) end

    if lendo and hora >= 22 then add("tarde") end
    if lendo and hora >= 5 and hora < 9 then add("cedo") end
    if lendo and (s.sessao_paginas or 0) >= 25 then add("sessao", s.sessao_paginas) end
    if (s.sequencia or 0) >= 3 and s.hoje == hoje_dia then add("sequencia", s.sequencia) end
    if hoje >= 15 and hoje < 40 then add("bom_dia", hoje) end
    if hoje == 0 and hora >= 19 and desde and desde >= 6 * 3600 and desde < 2 * 86400 then add("nada_hoje") end
    local pct = s.ultimo_progresso
    if pct and s.ultimo_livro and desde and desde < 86400 then
        if pct >= 0.9 and pct < 1 then add("reta_final", math.floor(pct * 100))
        elseif pct >= 0.45 and pct <= 0.55 then add("metade")
        elseif pct < 0.05 then add("comeco") end
    end
    local dia_semana = tonumber(os.date("%w", agora))
    if (dia_semana == 0 or dia_semana == 6) and hoje >= 5 then add("fim_de_semana") end
    return lista
end

--- A phrase with reading data, or nil. Also returns whether the trigger is strong.
-- temperamento: "jovem" or "velha". sorteio(n) returns an integer from 1 to n.
function Contexto.fala(s, agora, temperamento, sorteio)
    sorteio = sorteio or math.random
    local lista = Contexto.gatilhos(s, agora)
    if #lista == 0 then return nil end
    local g = lista[1].forte and lista[1] or lista[sorteio(#lista)]
    local banco = FALAS[g.nome] and FALAS[g.nome][temperamento]
    if not banco then return nil end
    local valores = {
        hora = Contexto.hora(agora), n = g.n and tostring(g.n),
        livro = s.ultimo_livro, pct = g.n and (g.n .. "%"),
    }
    -- domain words ({gosto}, {cheiro}…) are left to the voice resolver (yomimon_voice.lua)
    local texto = Voz.escolher(banco, s, sorteio):gsub("{(%a+)}", function(b)
        if valores[b] then return valores[b] end
        if Voz.SLOTS[b] then return nil end
        return b
    end)
    texto = texto:gsub("([ap]%.m%.)%.", "%1")  -- "It's 2:13 a.m.." → "It's 2:13 a.m."
    return texto, g.forte
end

return Contexto
