--[[--
O vetor do livro (PLANO-VOZ.md, Etapa 3): cada livro descrito como uma mistura, não como um gênero.

Dimensões, todas tiradas de somas que a memória já guarda por página (yomimon_memory.lua):
  temas      o que o livro tem ACIMA da página média (yomimon_base_topics.lua)
  tom        sentimento médio por página (dicionários de clima), comparado com o livro médio
  dialogo    marcas de diálogo por página («, “, aspas, travessão)
  eventos    acontecimentos por página (morte, viagem, briga…)
  frase      palavras por frase
  teatro     falas com rótulo de personagem por página (as peças têm ~8; os romances, menos de 3)
  primeira   narrado por um "eu" (3,5% ou mais das palavras; nunca em teatro)
tom, dialogo, eventos e frase viram "quantos desvios acima ou abaixo do livro médio"
(yomimon_base_books.lua, gerado por ferramentas/validacao/calcular_base_livros.lua).

O nome composto junta o tema mais forte com até duas outras coisas que se destacam:
  "uma história de mar, sombria, com cheiro de bichos" · "a family drama, bright and talkative"
Ele entra na resenha do diário quando ela termina o livro.

Lógica pura (sem KOReader), testável fora dele.
]]

local Lingua = require("yomimon_language")

local Vetor = {}

Vetor.MIN_PAGINAS = 20          -- antes disso o livro ainda não tem nome
Vetor.TEATRO_FALAS = 4          -- falas com rótulo por página a partir das quais é peça
Vetor.PRIMEIRA_PESSOA = 0.035   -- "eu" por palavra a partir do qual é narrado em primeira pessoa
Vetor.LIMITE = { tom = 1.0, dialogo = 1.0, eventos = 1.2, frase = 1.2 }  -- desvios para virar adjetivo
Vetor.SEGUNDO_TEMA = 0.5        -- o 2º tema entra se tiver pelo menos metade do destaque do 1º
Vetor.MAX_EXTRAS = 2            -- além do tema, no máximo duas coisas no nome

local okB, BASE = pcall(require, "yomimon_base_books")
Vetor.BASE = okB and type(BASE) == "table" and BASE or nil
local okT, BASE_TEMAS = pcall(require, "yomimon_base_topics")
Vetor.BASE_TEMAS = okT and type(BASE_TEMAS) == "table" and BASE_TEMAS or nil

--- Contas brutas do livro (por página), ou nil sem páginas com texto.
function Vetor.brutos(L)
    local P = L and L.paginas_texto or 0
    if P < 1 then return nil end
    local ev, falou = 0, 0
    for _, c in pairs(L.eventos or {}) do ev = ev + c end
    for _, c in pairs(L.falou or {}) do falou = falou + c end
    local N = L.narrador or {}
    return {
        lingua = (L.paginas_pt or 0) * 2 > P and "pt" or "en",
        paginas = P,
        clima = (L.clima or 0) / P,
        dialogo = (L.dialogo or 0) / P,
        eventos = ev / P,
        frase = (L.palavras or 0) / math.max(1, L.frases or 0),
        teatro = falou / P >= Vetor.TEATRO_FALAS,
        eu = (N.palavras or 0) > 0 and (N.eu or 0) / N.palavras or 0,
    }
end

local function desvios(valor, base)
    if not base or (base.desvio or 0) <= 0 then return 0 end
    return (valor - base.media) / base.desvio
end

--- O vetor do livro, ou nil se ainda é cedo (menos de Vetor.MIN_PAGINAS páginas com texto).
function Vetor.de(L)
    local b = Vetor.brutos(L)
    if not b or b.paginas < Vetor.MIN_PAGINAS then return nil end
    local B = Vetor.BASE or {}
    local v = {
        lingua = b.lingua, paginas = b.paginas, teatro = b.teatro,
        primeira = not b.teatro and b.eu >= Vetor.PRIMEIRA_PESSOA,
        tom = desvios(b.clima, B.clima and B.clima[b.lingua]),
        dialogo = desvios(b.dialogo, B.dialogo),
        eventos = desvios(b.eventos, B.eventos),
        frase = desvios(b.frase, B.frase),
        temas = {},
    }
    local media = Vetor.BASE_TEMAS and Vetor.BASE_TEMAS[b.lingua] or {}
    for t, c in pairs(L.temas or {}) do
        local acima = c / b.paginas - (media[t] or 0)
        if acima > 0 then v.temas[#v.temas + 1] = { t, acima } end
    end
    table.sort(v.temas, function(x, y) return x[2] > y[2] or (x[2] == y[2] and x[1] < y[1]) end)
    return v
end

--- Distância entre dois livros (0 = iguais, 2 = opostos): cosseno sobre os temas acima da média e,
-- com peso menor, tom, diálogo e ritmo.
function Vetor.distancia(a, b)
    local function plano(v)
        local x = {}
        for _, p in ipairs(v.temas or {}) do x[p[1]] = p[2] end
        x._tom, x._dialogo, x._eventos = (v.tom or 0) * 0.1, (v.dialogo or 0) * 0.1, (v.eventos or 0) * 0.1
        return x
    end
    local xa, xb = plano(a), plano(b)
    local dot, na, nb = 0, 0, 0
    for k, va in pairs(xa) do na = na + va * va; dot = dot + va * (xb[k] or 0) end
    for _, vb in pairs(xb) do nb = nb + vb * vb end
    if na == 0 or nb == 0 then return 1 end
    return 1 - dot / math.sqrt(na * nb)
end

local bancos = {}
local function banco()
    local c = Lingua.code()
    if bancos[c] == nil then
        local ok, b = pcall(Lingua.data, "vector")
        bancos[c] = ok and type(b) == "table" and b or false
    end
    return bancos[c] or nil
end

--- O nome composto do livro no idioma atual, ou nil.
function Vetor.nome(v)
    local B = banco()
    if not (B and v and v.temas[1]) then return nil end
    local t1 = v.temas[1][1]
    local cabeca, genero
    if v.teatro then
        cabeca, genero = string.format(B.peca[1], B.tema_curto[t1] or t1), B.peca[2]
    else
        local n = B.nomes[t1]
        if not n then return nil end
        cabeca, genero = n[1], n[2]
    end
    -- candidatos, com a força de cada um (desvios do livro médio)
    local cand = {}
    local function adjetivo(dim, pos, neg)
        local z, lim = v[dim] or 0, Vetor.LIMITE[dim]
        if z >= lim then cand[#cand + 1] = { tipo = "adj", chave = pos, forca = z }
        elseif z <= -lim then cand[#cand + 1] = { tipo = "adj", chave = neg, forca = -z } end
    end
    if not v.teatro then  -- nas peças, sem aspas e em verso, o tom dos dicionários e o diálogo não valem
        adjetivo("tom", "luminoso", "sombrio")
        adjetivo("dialogo", "falante", "calado")
        if math.abs(v.frase or 0) >= Vetor.LIMITE.frase then
            cand[#cand + 1] = { tipo = "frase", chave = v.frase > 0 and "longas" or "curtas", forca = math.abs(v.frase) }
        end
        if v.primeira then cand[#cand + 1] = { tipo = "primeira", forca = 1.5 } end
    end
    adjetivo("eventos", "agitado", "parado")
    local t2 = v.temas[2]
    if t2 and t2[2] >= v.temas[1][2] * Vetor.SEGUNDO_TEMA and B.tema_curto[t2[1]] then
        cand[#cand + 1] = { tipo = "tema", chave = t2[1], forca = 2 * t2[2] / v.temas[1][2] }
    end
    table.sort(cand, function(a, b) return a.forca > b.forca end)
    local adjs, resto = {}, {}
    for i = 1, math.min(Vetor.MAX_EXTRAS, #cand) do
        local c = cand[i]
        if c.tipo == "adj" then adjs[#adjs + 1] = B.adjetivos[c.chave][genero] or B.adjetivos[c.chave].m
        elseif c.tipo == "tema" then resto[#resto + 1] = { 1, string.format(B.cheiro, B.tema_curto[c.chave]) }
        elseif c.tipo == "frase" then resto[#resto + 1] = { 2, B.frases[c.chave] }
        elseif c.tipo == "primeira" then resto[#resto + 1] = { 3, B.primeira[genero] or B.primeira.m } end
    end
    table.sort(resto, function(a, b) return a[1] < b[1] end)
    local partes = { cabeca }
    if #adjs == 1 then partes[#partes + 1] = adjs[1]
    elseif #adjs == 2 then partes[#partes + 1] = adjs[1] .. B.e .. adjs[2] end
    for _, r in ipairs(resto) do partes[#partes + 1] = r[2] end
    return table.concat(partes, ", ")
end

return Vetor
