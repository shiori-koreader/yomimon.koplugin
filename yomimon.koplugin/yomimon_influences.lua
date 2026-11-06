--[[--
Influências literárias (desde 28/10/2026): as leituras mudam, devagar, o jeito de a Yomimon pensar e falar.

Três níveis, todos de 0 a 100 por influência (yomimon_data/influences.lua):
  contexto   o livro atual, pelo vetor dele (yomimon_vector.lua); refeito a cada 5 páginas lidas
  recente    o que você anda lendo: a cada página lida de verdade, anda 1/300 do caminho até o contexto
  acumulada  o que ficou: anda 1/2000 do caminho. Um livro de 300 páginas que é 70 numa influência deixa
             a recente perto de 44 e a acumulada perto de 10. Nenhum livro sozinho vira a cabeça dela.
Só página lida de verdade e nunca lida antes conta (a mesma porta dos traços: M.digerir com texto). Antes de
20 páginas o livro não tem vetor, e nada muda.

Na fala (Estado.fala → Influencias.fala), a mistura pesa 45% o contexto, 30% a recente e 25% a acumulada. A
influência mais forte escolhe a frase; a segunda, se for forte o bastante, entra na mesma fala por uma
"lente" (um nome com artigo, numa lacuna {lente}) ou por um "fecho" (uma frase curta inteira no fim). Sem
influência forte, sai a personalidade-base, às vezes temperada pela mais forte que houver. A fase dela
(ninfa, jovem, adulta, anciã) escolhe entre as frases marcadas com `fase`; a da fase atual pesa mais.
Estado guardado: s.influencias = { acumulada, recente, livro, contexto, contexto_em, tema, paginas }.
Lógica pura (sem KOReader), testável fora dele. Sem rede, sem IA.
]]

local Lingua = require("yomimon_language")

local Infl = {}

Infl.RECENTE = 300       -- páginas: quanto a recente demora para seguir o livro
Infl.ACUMULADA = 2000    -- páginas: quanto a acumulada demora
Infl.RECALCULAR = 5      -- páginas lidas entre um cálculo e outro do contexto
Infl.PESOS = { contexto = 0.45, recente = 0.30, acumulada = 0.25 }
Infl.MINIMO = 15         -- mistura a partir da qual uma influência escolhe a fala
Infl.SEGUNDA = 0.6       -- a segunda entra se tiver pelo menos 60% da primeira (e o mínimo)
Infl.POR_PONTOS = 4      -- chance da fala de influência: 1 em 20 a cada 4 pontos da mais forte, até 4 em 20
Infl.MAX_CHANCE = 4      -- (era 6 em 10; com 70 frases por influência e as etiquetas do EPUB, um gênero forte tomava 4 falas em 10)
Infl.BASE = 3            -- chance da personalidade-base, quando a influência não falou: 3 em 20 (era 3 em 10)
Infl.MAX_FALA = 150      -- com o fecho, a fala não passa disso
Infl.FECHO_ATE = 110     -- o fecho só entra em fala curta (até 110 letras e 2 frases): uma tirada por fala
Infl.CURTA_ATE = 52      -- na Home, frase sem versão curta só entra se já tiver até isso de letras
Infl.ETIQUETA = 40       -- no perfil do livro, o gênero que a etiqueta do EPUB indica vale pelo menos isso

local okL, LISTA = pcall(require, "yomimon_data.influences")
Infl.LISTA = okL and type(LISTA) == "table" and LISTA or {}
Infl.POR_ID = {}
for _, I in ipairs(Infl.LISTA) do Infl.POR_ID[I.id] = I end

local bancos = {}
--- Frases no idioma atual (yomimon_locales/<code>/data/influences.lua), ou nil.
function Infl.banco()
    local c = Lingua.code()
    if bancos[c] == nil then
        local ok, b = pcall(Lingua.data, "influences")
        bancos[c] = ok and type(b) == "table" and b.base and b.influencias and b or false
    end
    return bancos[c] or nil
end
function Infl.usarBanco(b) bancos[Lingua.code()] = b end  -- (para testes)

local function sat(x, k)
    if not x or x <= 0 then return 0 end
    return 1 - math.exp(-x / k)
end

--- Intensidade de cada influência num livro, de 0 a 100, a partir do vetor dele (Vetor.de) e dos
-- acontecimentos por página. Devolve o perfil e o tema mais forte do livro (ou nil).
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

--- As influências que as etiquetas de gênero do livro indicam (yomimon_data/genres.lua): { id = true }.
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

--- Perfil do livro (como Infl.perfilDe) ou nil se ainda é cedo. O gênero que as etiquetas do EPUB indicam
-- vale pelo menos Infl.ETIQUETA: a etiqueta é só mapa (diz de que gênero o livro é); quem move a Yomimon
-- continua sendo cada página lida, em Infl.digerir.
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

--- Uma página lida de verdade do livro L (yomimon_memory.lua, junto com os traços).
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

--- A mistura que vale na fala: { id = valor }. O contexto só conta se for do livro atual.
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

--- As influências que mandam agora: até duas, { {id, valor}, ... }, a mais forte primeiro.
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

-- Fala ------------------------------------------------------------------------------------------

--- Tipo de uma frase do banco: "modelo" (tem lacunas) ou "fixa".
function Infl.tipo(frase)
    local t = type(frase) == "table" and frase[1] or frase
    return (type(t) == "string" and t:find("{", 1, true)) and "modelo" or "fixa"
end

-- o acontecimento de destaque dos 3 capítulos mais recentes do livro atual, ou nil
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

-- valores das lacunas que existem agora; lacuna sem dado deixa a frase de fora
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
    -- o último livro terminado que não é o atual (as resenhas do diário)
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

-- a frase marcada com uma fase (ou lista de fases) só vale nela
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

-- na Home (2 linhas, ~50 letras) só servem a versão curta ou a frase que já é curta e sem lacunas
local function cabeNaHome(f)
    return f.curta ~= nil or (#f[1] <= Infl.CURTA_ATE and not f[1]:find("{", 1, true))
end

local function escolher(lista, situ, valores, lente, sorteio, dita)
    local cands, total = {}, 0
    local home = situ and situ.tela == "home"
    for _, f in ipairs(lista or {}) do
        if serve(f, situ, valores, lente) and not (dita and dita("infl:" .. f[1])) and (not home or cabeNaHome(f)) then
            -- a frase feita para a situação ou para a fase de agora ganha
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

--- Preenche um modelo: lacunas, lente e a primeira letra maiúscula.
function Infl.preencher(texto, valores, lente)
    local out = texto:gsub("{([%w_]+)}", function(nome)
        if nome == "lente" then return lente end
        return valores[nome]
    end)
    return (out:gsub("^%l", string.upper))
end

--- Junta um fecho no fim de uma fala (os dois são frases inteiras), ou nil se não couber. Fala longa ou
-- de 3+ frases já tem a sua tirada e fica como está.
function Infl.juntar(texto, fecho)
    if not (fecho and texto:find("[%.!%?…]$")) then return nil end
    local _, frases = texto:gsub("[%.!%?…]+%s", "")
    if #texto > Infl.FECHO_ATE or frases >= 2 then return nil end
    local junto = texto .. " " .. fecho
    if #junto > Infl.MAX_FALA then return nil end
    return junto
end

--- Uma fala de influência ou da personalidade-base, ou nil (aí o resto do Estado.fala decide).
-- dados: os de Estado (personagem, palavra…); situ: { triste, feliz, fome, cheia, noite, muda = true/false,
-- fase = "ninfa" | "jovem" | "adulta" | "ancia", tela = "home" | "traca" | nil };
-- dita(chave): true se a frase foi dita há pouco (fica de fora). Devolve o texto e a chave da regra de não
-- repetir (a frase do banco, antes de preencher; a versão curta usa a mesma chave). Na Home sai a versão
-- curta (`curta`), sem fecho.
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
        -- a mais forte escolhe; a segunda empresta a lente ou o fecho
        lista = B.influencias[d1[1]] and B.influencias[d1[1]].frases
        lente_de, fecho_de, chance_fecho = d2 and d2[1] or d1[1], d2 and d2[1], 2
    elseif r > 20 - Infl.BASE then
        -- personalidade-base, temperada pela influência mais forte, se houver
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
