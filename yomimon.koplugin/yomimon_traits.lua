--[[--
Yomimon's personality traits: they move slowly with what YOU read.

Five axes, from -100 to 100:
  humor    amarga  ↔ otimista   (tragedies, deaths ↔ love, parties, weddings)
  coragem  medrosa ↔ corajosa   (horror, crimes ↔ sea, travel, adventures)
  coracao  cínica  ↔ romântica  (money, politics, revenge ↔ love, weddings, letters)
  gosto    popular ↔ erudita    (crimes, parties ↔ philosophy, art, science, faith)
  relogio  diurna  ↔ noturna    (the time you read)

Only pages really eaten move the traits (never what it knows of the book ahead).
Each page pushes by the DIFFERENCE from an average page (yomimon_base_traits.lua): family and love in an old
novel, or knowledge and faith in a classic, are in almost every book and do not push; only what your
book has above (or below) normal shapes it. What you do NOT read only undoes excess: a page with
nothing for a trait pulls towards neutral, never towards the opposite pole (not reading romance does not make it cynical).
Each page pushes a little and everything slowly returns to the middle: what you read last
weighs more. When a trait becomes striking, it writes in the diary and gets its own phrases
(in yomimon_locales/<code>/data/traits.lua).

Pure logic (no KOReader), testable outside it.
]]

local Lingua = require("yomimon_language")
local T = Lingua.t

local Tracos = {}

Tracos.LISTA = {
    { id = "humor",   neg = "amarga",  pos = "otimista" },
    { id = "coragem", neg = "medrosa", pos = "corajosa" },
    { id = "coracao", neg = "cinica",  pos = "romantica" },
    { id = "gosto",   neg = "popular", pos = "erudita" },
    { id = "relogio", neg = "diurna",  pos = "noturna" },
}
Tracos.PASSO = 0.5          -- how much a page can move a trait
Tracos.DECAIMENTO = 0.998   -- on each page, everything returns a little to the middle
Tracos.MARCANTE = 25        -- from here up the trait shows in the phrases and in the diary
Tracos.FORTE = 60
Tracos.FOLGA = 5            -- to drop a level it must fall 5 below the limit (no flicker)

local ROTULO = {
    amarga = "BITTER", otimista = "HOPEFUL", medrosa = "JUMPY", corajosa = "BOLD",
    cinica = "CYNICAL", romantica = "ROMANTIC", popular = "LOWBROW", erudita = "HIGHBROW",
    diurna = "EARLY BIRD", noturna = "NIGHT OWL",
}

-- What each page signal pushes (positive = the axis' "pos" pole).
local PESOS = {
    humor = {
        temas = { morte = -1, guerra = -1, solidao = -1, vinganca = -1, medo = -0.5, loucura = -1, dinheiro = -0.5,
                  amor = 1, natureza = 0.5, comida = 1, infancia = 0.5, arte = 0.5, viagem = 0.5 },
        eventos = { morte = -2, doenca = -1, crime = -1, briga = -0.5, festa = 1.5, casamento = 1.5 },
        -- (27/10/2026, PLANO-VOZ.md step 6: madness -0.5 → -1 and money -0.5, so tragedy leaves it bitter
        -- and not just fearful like horror; Crime and Punishment, Hamlet and Macbeth are madness, guilt and money)
        -- (without weather: the old list pulled horror towards optimistic; the dictionary orders short passages well,
        -- but leaves Shakespeare and Victorian prose "light" — Hamlet and Romeo were less bitter with it.
        -- Out since 25/10/2026; see ferramentas/validacao/MEMORIA-VINCULO.md)
    },
    coragem = {
        temas = { medo = -1.5, loucura = -0.5, noite = -0.3, viagem = 1, mar = 1, liberdade = 1, guerra = 0.5 },
        eventos = { fuga = -0.5, tempestade = 0.5, viagem = 1 },
        -- (crime left on 27/10/2026: crime and investigation, from Sherlock to Crime and Punishment, are not stories of
        -- fear; crime still leaves it bitter and a little cynical)
    },
    coracao = {
        temas = { amor = 1.5, arte = 0.5, familia = 0.5, dinheiro = -1, politica = -1, vinganca = -1 },
        eventos = { casamento = 1.5, carta = 0.5, briga = -0.5, crime = -0.5 },
    },
    gosto = {
        temas = { saber = 1, arte = 1, fe = 0.5, ciencia = 0.5 },
        eventos = { crime = -0.5, festa = -0.3 },
    },
}

Tracos.PESOS = PESOS  -- exposed for the validation tools

local function limitar(v, a) return math.max(-a, math.min(a, v)) end

-- Average push of a page, by language: what every book has does not shape it.
Tracos.CENTRADOS = { "humor", "coragem", "coracao", "gosto" }
local okB, BASE = pcall(require, "yomimon_base_traits")
Tracos.BASE = okB and type(BASE) == "table" and BASE or nil

local banco
--- Phrases and diary notes of the traits, in the current language.
function Tracos.banco()
    banco = banco or Lingua.data("traits")
    return banco
end

--- -2, -1, 0, 1 or 2 for a value (without considering the previous level).
function Tracos.nivel(v)
    if v >= Tracos.FORTE then return 2 elseif v >= Tracos.MARCANTE then return 1
    elseif v <= -Tracos.FORTE then return -2 elseif v <= -Tracos.MARCANTE then return -1 end
    return 0
end

-- Level with slack: to weaken, the value must fall FOLGA below the current level's limit.
local function nivelComFolga(v, atual)
    local alvo = Tracos.nivel(v)
    if atual ~= 0 and (alvo == 0 or (alvo > 0) == (atual > 0)) and math.abs(alvo) < math.abs(atual) then
        local limite = math.abs(atual) == 2 and Tracos.FORTE or Tracos.MARCANTE
        if math.abs(v) > limite - Tracos.FOLGA and (v > 0) == (atual > 0) then return atual end
    end
    return alvo
end

--- How much a page pushes each axis (from -1 to 1). hora: the local time of reading.
-- bruto: without discounting the average page (to compute the average and for diagnosis).
function Tracos.empurrao(sinal, hora, bruto)
    local out = {}
    for id, P in pairs(PESOS) do
        local v = 0
        for t, c in pairs(sinal.temas or {}) do v = v + (P.temas[t] or 0) * math.min(c, 3) end
        for ev in pairs(sinal.eventos or {}) do v = v + (P.eventos[ev] or 0) end
        if P.clima then v = v + P.clima * (sinal.clima or 0) end
        out[id] = v
    end
    -- (the average word size pushed taste; out since 25/10/2026: it decided 70–83% of the trait and
    -- called almost all prose "popular", Henry James and Dostoevsky included)
    local base = not bruto and Tracos.BASE and Tracos.BASE[sinal.pt and "pt" or "en"]
    local ausente = {}
    if base then
        for _, id in ipairs(Tracos.CENTRADOS) do
            if out[id] == 0 then ausente[id] = true end
            out[id] = out[id] - (base[id] or 0)
        end
    end
    out.relogio = 0
    if hora then
        if hora >= 22 or hora < 5 then out.relogio = 1 elseif hora < 12 then out.relogio = -1 end
    end
    for id, v in pairs(out) do out[id] = limitar(v, 1) end
    return out, ausente
end

--- Average push of a page, by language, over a corpus (lines of livros30.txt; `fora`: books to
-- ignore). Used by ferramentas/validacao/calcular_base_tracos.lua and by the personality ruler.
function Tracos.mediaDasPaginas(M, linhas, fora)
    local soma, n, livro = { en = {}, pt = {} }, { en = 0, pt = 0 }, nil
    for linha in linhas do
        local t = linha:match("^#LIVRO\t(.*)")
        if t then livro = t
        elseif not linha:match("^#") and livro and not (fora and fora[livro]) then
            local sn = M.sinais(linha, livro)
            local lg = sn.pt and "pt" or "en"
            local e = Tracos.empurrao(sn, nil, true)
            n[lg] = n[lg] + 1
            for _, id in ipairs(Tracos.CENTRADOS) do soma[lg][id] = (soma[lg][id] or 0) + e[id] end
        end
    end
    local base = { en = {}, pt = {} }
    for lg, sm in pairs(soma) do
        for _, id in ipairs(Tracos.CENTRADOS) do base[lg][id] = (sm[id] or 0) / math.max(1, n[lg]) end
    end
    return base, n
end

local function notaDiario(tr, antes, depois, livro)
    local polo, chave
    if depois == 0 then
        polo, chave = antes > 0 and tr.pos or tr.neg, "volta"
    elseif math.abs(depois) > math.abs(antes) or (depois > 0) ~= (antes > 0) then
        polo, chave = depois > 0 and tr.pos or tr.neg, math.abs(depois)
    else
        return nil  -- weakened from 2 to 1: not worth noting
    end
    local lista = Tracos.banco().diario[polo]
    lista = lista and lista[chave]
    if not lista or #lista == 0 then return nil end
    local texto = lista[math.random(#lista)]
    return (texto:gsub("{livro}", livro or T"this book"))
end

--- Digests a page: moves the traits and returns the diary notes of whoever changed level.
function Tracos.digerir(s, sinal, agora, livro)
    s.tracos = s.tracos or {}
    s.tracos_nivel = s.tracos_nivel or {}
    local hora = agora and tonumber(os.date("%H", agora))
    local emp, ausente = Tracos.empurrao(sinal, hora)
    local notas = {}
    for _, tr in ipairs(Tracos.LISTA) do
        local atual = (s.tracos[tr.id] or 0) * Tracos.DECAIMENTO
        local v = limitar(atual + (emp[tr.id] or 0) * Tracos.PASSO, 100)
        -- page with nothing for this axis: the average discount only undoes excess (pulls towards neutral),
        -- never leads to the opposite pole
        if ausente and ausente[tr.id] then
            if atual == 0 or (v > 0) ~= (atual > 0) then v = 0
            elseif math.abs(v) > math.abs(atual) then v = atual end
        end
        -- a single book does not fix a strong trait: it only goes past STRONG if the trait was already striking, in the same
        -- direction, when this book started
        if math.abs(v) >= Tracos.FORTE then
            local L = livro and s.livros and s.livros[livro]
            local ini = L and L.tracos_inicio and L.tracos_inicio[tr.id] or 0
            if math.abs(ini) < Tracos.MARCANTE or (ini > 0) ~= (v > 0) then
                v = (v > 0 and 1 or -1) * (Tracos.FORTE - 0.1)
            end
        end
        s.tracos[tr.id] = v
        local antes = s.tracos_nivel[tr.id] or 0
        local depois = nivelComFolga(v, antes)
        if depois ~= antes then
            s.tracos_nivel[tr.id] = depois
            local nota = notaDiario(tr, antes, depois, livro)
            if nota then notas[#notas + 1] = nota end
        end
    end
    return notas
end

--- Striking poles, from strongest to weakest: { {polo, valor}, ... }.
function Tracos.marcantes(tracos)
    local lista = {}
    for _, tr in ipairs(Tracos.LISTA) do
        local v = (tracos or {})[tr.id] or 0
        if math.abs(v) >= Tracos.MARCANTE then lista[#lista + 1] = { v > 0 and tr.pos or tr.neg, math.abs(v) } end
    end
    table.sort(lista, function(a, b) return a[2] > b[2] end)
    return lista
end

--- Translated label of a pole ("BITTER", "NIGHT OWL"…).
function Tracos.rotulo(polo)
    return T(ROTULO[polo] or polo)
end

--- Up to `max` labels of the striking traits ("BITTER", "NIGHT OWL"…), already translated.
function Tracos.rotulos(tracos, max)
    local out = {}
    for i, m in ipairs(Tracos.marcantes(tracos)) do
        if i > (max or 2) then break end
        out[#out + 1] = Tracos.rotulo(m[1])
    end
    return out
end

--- A phrase in the way it ended up, or nil. The stronger the trait, the more it shows
-- (at most 4 in every 10 phrases). temperamento: "jovem" or "velha".
function Tracos.fala(s, temperamento, sorteio)
    sorteio = sorteio or math.random
    local fortes = Tracos.marcantes(s.tracos)
    if #fortes == 0 then return nil end
    if sorteio(100) > math.min(40, fortes[1][2] * 0.6) then return nil end
    local soma = 0
    for _, f in ipairs(fortes) do soma = soma + f[2] end
    local alvo, acc, polo = sorteio(math.max(1, math.floor(soma))), 0, fortes[1][1]
    for _, f in ipairs(fortes) do
        acc = acc + f[2]
        if alvo <= acc then polo = f[1]; break end
    end
    local porPolo = Tracos.banco().falas[polo]
    local lista = porPolo and porPolo[temperamento == "jovem" and "jovem" or "velha"]
    if not lista or #lista == 0 then return nil end
    return lista[sorteio(#lista)]
end

return Tracos
