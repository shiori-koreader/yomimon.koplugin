--[[--
Literary influences (since 28/10/2026): readings slowly change the way Yomimon thinks and speaks.

Three levels, all from 0 to 100 per influence (yomimon_data/influences.lua):
  contexto   the current book, by its vector (yomimon_vector.lua); redone every 5 pages read
  recente    what you have been reading: on each page really read, it moves 1/300 of the way to the context
  acumulada  what stayed: it moves 1/2000 of the way. A 300-page book that is 70 in an influence leaves
             the recent near 44 and the accumulated near 10. No single book turns its head.
Only a page really read and never read before counts (the same door as the traits: M.digerir with text). Before
20 pages the book has no vector, and nothing changes.

In speech (Estado.fala → Influencias.fala), the mix weighs 45% the context, 30% the recent and 25% the accumulated. The
strongest influence picks the phrase; the second, if strong enough, enters the same phrase through a
"lens" (a name with an article, in a {lente} gap) or through a "fecho" (a whole short phrase at the end). Without a
strong influence, the base personality comes out, sometimes seasoned by the strongest there is. Its stage
(ninfa, jovem, adulta, anciã) chooses among the phrases marked with `fase`; the current stage's weighs more.
Stored state: s.influencias = { acumulada, recente, livro, contexto, contexto_em, tema, paginas }.
Pure logic (no KOReader), testable outside it. No network, no AI.
]]

local Lingua = require("yomimon_language")

local Infl = {}

Infl.RECENTE = 300       -- pages: how long the recent takes to follow the book
Infl.ACUMULADA = 2000    -- pages: how long the accumulated takes
Infl.RECALCULAR = 5      -- pages read between one context computation and the next
Infl.PESOS = { contexto = 0.45, recente = 0.30, acumulada = 0.25 }
Infl.MINIMO = 15         -- mix from which an influence picks the phrase
Infl.SEGUNDA = 0.6       -- the second enters if it has at least 60% of the first (and the minimum)
Infl.POR_PONTOS = 4      -- chance of an influence phrase: 1 in 20 for each 4 points of the strongest, up to 4 in 20
Infl.MAX_CHANCE = 4      -- (it was 6 in 10; with 70 phrases per influence and the EPUB tags, a strong genre took 4 phrases in 10)
Infl.BASE = 3            -- chance of the base personality, when the influence did not speak: 3 in 20 (it was 3 in 10)
Infl.MAX_FALA = 150      -- with the fecho, the phrase does not go past this
Infl.FECHO_ATE = 110     -- the fecho only enters a short phrase (up to 110 letters and 2 sentences): one quip per phrase
Infl.CURTA_ATE = 52      -- on the Home, a phrase without a short version only enters if it has up to this many letters
Infl.ETIQUETA = 40       -- in the book profile, the genre the EPUB tag indicates is worth at least this

local okL, LISTA = pcall(require, "yomimon_data.influences")
Infl.LISTA = okL and type(LISTA) == "table" and LISTA or {}
Infl.POR_ID = {}
for _, I in ipairs(Infl.LISTA) do Infl.POR_ID[I.id] = I end

local bancos = {}
--- Phrases in the current language (yomimon_locales/<code>/data/influences.lua), or nil.
function Infl.banco()
    local c = Lingua.code()
    if bancos[c] == nil then
        local ok, b = pcall(Lingua.data, "influences")
        bancos[c] = ok and type(b) == "table" and b.base and b.influencias and b or false
    end
    return bancos[c] or nil
end
function Infl.usarBanco(b) bancos[Lingua.code()] = b end  -- (for tests)

local function sat(x, k)
    if not x or x <= 0 then return 0 end
    return 1 - math.exp(-x / k)
end

--- Intensity of each influence in a book, from 0 to 100, from its vector (Vetor.de) and the
-- happenings per page. Returns the profile and the book's strongest theme (or nil).
function Infl.perfilDe(v, eventos_por_pagina)
    local f = {}
    for _, p in ipairs(v.temas or {}) do f[p[1]] = sat(p[2], 0.4) end
    for ev, taxa in pairs(eventos_por_pagina or {}) do f["ev_" .. ev] = sat(taxa, 0.2) end
    f._sombrio, f._leve = sat(-(v.tom or 0), 2), sat(v.tom or 0, 2)
    f._frase_longa, f._frase_curta = sat(v.frase or 0, 2), sat(-(v.frase or 0), 2)
    f._teatro = v.teatro and 1 or 0
    f._primeira = v.primeira and 1 or 0
    local perfil = {}
    for _, I in ipairs(Infl.LISTA) do
        local soma = 0
        for chave, peso in pairs(I.receita) do soma = soma + peso * (f[chave] or 0) end
        perfil[I.id] = math.floor(math.min(100, 100 * soma) + 0.5)
    end
    local tema = v.temas and v.temas[1] and v.temas[1][1] or nil
    return perfil, tema
end

local okG, GENEROS = pcall(require, "yomimon_data.genres")
GENEROS = okG and type(GENEROS) == "table" and GENEROS or {}
local DOBRA = { ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["é"] = "e", ["ê"] = "e", ["í"] = "i",
    ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ü"] = "u", ["ç"] = "c", ["Á"] = "a", ["À"] = "a",
    ["Â"] = "a", ["Ã"] = "a", ["É"] = "e", ["Ê"] = "e", ["Í"] = "i", ["Ó"] = "o", ["Ô"] = "o", ["Õ"] = "o",
    ["Ú"] = "u", ["Ç"] = "c" }

--- The influences the book's genre tags indicate (yomimon_data/genres.lua): { id = true }.
function Infl.doGenero(etiquetas)
    local ids = {}
    for _, e in ipairs(type(etiquetas) == "table" and etiquetas or {}) do
        local t = tostring(e):gsub("\195[\128-\191]", DOBRA):lower()
        for _, g in ipairs(GENEROS) do
            if t:find(g[1], 1, true) then
                for i = 2, #g do ids[g[i]] = true end
            end
        end
    end
    return ids
end

--- Book profile (like Infl.perfilDe) or nil if it is still early. The genre the EPUB tags indicate
-- is worth at least Infl.ETIQUETA: the tag is only a map (it says which genre the book is); what moves Yomimon
-- is still each page read, in Infl.digerir.
function Infl.perfil(L)
    local okV, Vetor = pcall(require, "yomimon_vector")
    local v = okV and L and Vetor.de(L)
    if not v then return nil end
    local ev = {}
    for k, c in pairs(L.eventos or {}) do ev[k] = c / v.paginas end
    local perfil, tema = Infl.perfilDe(v, ev)
    for id in pairs(Infl.doGenero(L.etiquetas)) do
        if perfil[id] then perfil[id] = math.max(perfil[id], Infl.ETIQUETA) end
    end
    return perfil, tema
end

local function arred(x) return math.floor(x * 1000 + 0.5) / 1000 end

--- A page really read of book L (yomimon_memory.lua, together with the traits).
function Infl.digerir(s, livro, L)
    if not (livro and L) then return end
    local I = type(s.influencias) == "table" and s.influencias or {}
    s.influencias = I
    if type(I.acumulada) ~= "table" then I.acumulada = {} end
    if type(I.recente) ~= "table" then I.recente = {} end
    local P = L.paginas_texto or 0
    local em = tonumber(I.contexto_em) or 0
    if I.livro ~= livro or type(I.contexto) ~= "table" or P - em >= Infl.RECALCULAR or P < em then
        local perfil, tema = Infl.perfil(L)
        I.livro, I.contexto, I.contexto_em, I.tema = livro, perfil, P, tema
    end
    if type(I.contexto) ~= "table" then return end
    for id, alvo in pairs(I.contexto) do
        local r, a = tonumber(I.recente[id]) or 0, tonumber(I.acumulada[id]) or 0
        I.recente[id] = arred(r + (alvo - r) / Infl.RECENTE)
        I.acumulada[id] = arred(a + (alvo - a) / Infl.ACUMULADA)
    end
    I.paginas = (tonumber(I.paginas) or 0) + 1
end

--- The mix that applies in speech: { id = value }. The context only counts if it is of the current book.
function Infl.mistura(s)
    local I = type(s.influencias) == "table" and s.influencias or {}
    local ctx = (I.livro == s.ultimo_livro and type(I.contexto) == "table") and I.contexto or {}
    local rec = type(I.recente) == "table" and I.recente or {}
    local acu = type(I.acumulada) == "table" and I.acumulada or {}
    local P = Infl.PESOS
    local m = {}
    for _, inf in ipairs(Infl.LISTA) do
        local id = inf.id
        m[id] = P.contexto * (tonumber(ctx[id]) or 0) + P.recente * (tonumber(rec[id]) or 0)
            + P.acumulada * (tonumber(acu[id]) or 0)
    end
    return m
end

--- The influences that rule now: up to two, { {id, value}, ... }, the strongest first.
function Infl.dominantes(s)
    local m = Infl.mistura(s)
    local lista = {}
    for _, inf in ipairs(Infl.LISTA) do
        if m[inf.id] >= Infl.MINIMO then lista[#lista + 1] = { inf.id, m[inf.id] } end
    end
    table.sort(lista, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    local out = { lista[1] }
    if lista[2] and lista[2][2] >= Infl.SEGUNDA * lista[1][2] then out[2] = lista[2] end
    return out
end

-- Speech ------------------------------------------------------------------------------------------

--- Kind of a bank phrase: "modelo" (has gaps) or "fixa".
function Infl.tipo(frase)
    local t = type(frase) == "table" and frase[1] or frase
    return (type(t) == "string" and t:find("{", 1, true)) and "modelo" or "fixa"
end

-- the standout happening of the 3 most recent chapters of the current book, or nil
local function eventoRecente(s, Memoria)
    local L = s.ultimo_livro and s.livros and s.livros[s.ultimo_livro]
    if not (L and L.caps and Memoria) then return nil end
    local caps = {}
    for _, C in pairs(L.caps) do caps[#caps + 1] = C end
    table.sort(caps, function(a, b) return (a.ordem or 0) > (b.ordem or 0) end)
    for i = 1, math.min(3, #caps) do
        local ev = Memoria.eventoDoCapitulo(L, caps[i])
        if ev then return ev end
    end
    return nil
end

-- values of the gaps that exist now; a gap without data leaves the phrase out
local function lacunas(s, dados, B)
    local okM, Memoria = pcall(require, "yomimon_memory")
    local I = type(s.influencias) == "table" and s.influencias or {}
    local v = { livro = s.ultimo_livro, personagem = dados and dados.personagem, palavra = dados and dados.palavra }
    local tema = I.livro == s.ultimo_livro and I.tema or nil
    if tema and okM then v.tema, v.de_tema = Memoria.tema(tema), Memoria.tema(tema, "de") end
    local ev = eventoRecente(s, okM and Memoria)
    if ev and B.eventos then v.evento = B.eventos[ev] end
    local L = s.ultimo_livro and s.livros and s.livros[s.ultimo_livro]
    if L and type(L.autor) == "string" and L.autor:find("%S") then v.autor = L.autor end
    -- the last finished book that is not the current one (the diary reviews)
    local resenhas = type(s.resenhas) == "table" and s.resenhas or {}
    for i = #resenhas, 1, -1 do
        local r = resenhas[i]
        if type(r) == "table" and type(r.livro) == "string" and r.livro ~= s.ultimo_livro then
            v.anterior = r.livro
            break
        end
    end
    return v
end

-- a phrase marked with a stage (or list of stages) only applies in it
local function daFase(f, fase)
    if not f.fase then return true end
    if type(f.fase) == "string" then return f.fase == fase end
    for _, x in ipairs(f.fase) do if x == fase then return true end end
    return false
end

local function serve(f, situ, valores, lente)
    if f.quando and not (situ and situ[f.quando]) then return false end
    if not daFase(f, situ and situ.fase) then return false end
    for nome in f[1]:gmatch("{([%w_]+)}") do
        if nome == "lente" then
            if not lente then return false end
        elseif not valores[nome] then
            return false
        end
    end
    return true
end

-- on the Home (2 lines, ~50 letters) only the short version or a phrase that is already short and without gaps serve
local function cabeNaHome(f)
    return f.curta ~= nil or (#f[1] <= Infl.CURTA_ATE and not f[1]:find("{", 1, true))
end

local function escolher(lista, situ, valores, lente, sorteio, dita)
    local cands, total = {}, 0
    local home = situ and situ.tela == "home"
    for _, f in ipairs(lista or {}) do
        if serve(f, situ, valores, lente) and not (dita and dita("infl:" .. f[1])) and (not home or cabeNaHome(f)) then
            -- the phrase made for the situation or for the current stage wins
            local w = 1 + (f.quando and 2 or 0) + (f.fase and 2 or 0)
            cands[#cands + 1] = { f, w }
            total = total + w
        end
    end
    if total == 0 then return nil end
    local r = sorteio(total)
    for _, c in ipairs(cands) do
        r = r - c[2]
        if r <= 0 then return c[1] end
    end
    return cands[#cands][1]
end

--- Fills a template: gaps, lens and the capital first letter.
function Infl.preencher(texto, valores, lente)
    local out = texto:gsub("{([%w_]+)}", function(nome)
        if nome == "lente" then return lente end
        return valores[nome]
    end)
    return (out:gsub("^%l", string.upper))
end

--- Joins a fecho at the end of a phrase (both are whole phrases), or nil if it does not fit. A long phrase or
-- one of 3+ sentences already has its quip and stays as it is.
function Infl.juntar(texto, fecho)
    if not (fecho and texto:find("[%.!%?…]$")) then return nil end
    local _, frases = texto:gsub("[%.!%?…]+%s", "")
    if #texto > Infl.FECHO_ATE or frases >= 2 then return nil end
    local junto = texto .. " " .. fecho
    if #junto > Infl.MAX_FALA then return nil end
    return junto
end

--- A phrase from an influence or from the base personality, or nil (then the rest of Estado.fala decides).
-- dados: those of Estado (personagem, palavra…); situ: { triste, feliz, fome, cheia, noite, muda = true/false,
-- fase = "ninfa" | "jovem" | "adulta" | "ancia", tela = "home" | "traca" | nil };
-- dita(chave): true if the phrase was said a moment ago (it stays out). Returns the text and the key of the no-repeat
-- rule (the bank phrase, before filling; the short version uses the same key). On the Home the short
-- version comes out (`curta`), without a fecho.
function Infl.fala(s, dados, sorteio, situ, dita)
    local B = Infl.banco()
    if not B then return nil end
    sorteio = sorteio or math.random
    local dom = Infl.dominantes(s)
    local d1, d2 = dom[1], dom[2]
    local k = d1 and math.min(Infl.MAX_CHANCE, math.floor(d1[2] / Infl.POR_PONTOS)) or 0
    local r = sorteio(20)
    local lista, lente_de, fecho_de, chance_fecho
    if d1 and r <= k then
        -- the strongest picks; the second lends the lens or the fecho
        lista = B.influencias[d1[1]] and B.influencias[d1[1]].frases
        lente_de, fecho_de, chance_fecho = d2 and d2[1] or d1[1], d2 and d2[1], 2
    elseif r > 20 - Infl.BASE then
        -- base personality, seasoned by the strongest influence, if any
        lista = B.base
        lente_de, fecho_de, chance_fecho = d1 and d1[1], d1 and d1[1], 3
    else
        return nil
    end
    local valores = lacunas(s, dados, B)
    local lentes = lente_de and B.influencias[lente_de] and B.influencias[lente_de].lentes
    local lente = lentes and #lentes > 0 and lentes[sorteio(#lentes)] or nil
    local f = escolher(lista, situ, valores, lente, sorteio, dita)
    if not f then return nil end
    if situ and situ.tela == "home" then
        return Infl.preencher(f.curta or f[1], valores, lente), "infl:" .. f[1]
    end
    local texto = Infl.preencher(f[1], valores, lente)
    local fechos = fecho_de and B.influencias[fecho_de] and B.influencias[fecho_de].fechos
    if fechos and #fechos > 0 and not f[1]:find("{lente}", 1, true) and sorteio(chance_fecho) == 1 then
        texto = Infl.juntar(texto, fechos[sorteio(#fechos)]) or texto
    end
    return texto, "infl:" .. f[1]
end

return Infl
