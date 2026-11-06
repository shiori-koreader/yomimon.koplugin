--[[--
Yomimon's voice: the only place that understands the variant marks inside phrases (PLANO-VOZ.md).

Step 1, trait inside the phrase (as in Wildermyth):

    "Achei um ponto final e <amarga:fiquei aliviada|otimista:já quero o próximo|fiquei com medo de acabar>."

- The mark starts with an option with a label. Each label is a trait pole: amarga, otimista, medrosa,
  corajosa, cinica, romantica, popular, erudita, diurna or noturna. The option of the strongest striking pole
  (Tracos.MARCANTE) among those listed wins; a tie keeps the first.
- Optional threshold: "medrosa.60:" only applies with the trait at 60 or more.
- The option without a label is the usual phrase: it applies when no listed pole is striking. It may be empty.
- Gaps {livro}, {personagem}… may go inside the options, the same in all. %s and %d never: string.format
  counts all the options.

Step 2, vocabulary of what it ate (the domains of Caves of Qud):

    "Lambi a capa. Só tinha {gosto|poeira}."         → "Só tinha sal." (whoever has been reading about the sea)
    "Ainda mastigando “%s”.<dominio: Tem gosto de {gosto}.|>"

- Each theme has a vocabulary (yomimon_locales/<code>/data/domains.lua) with six kinds of word:
  gosto, cheiro, comparacao, exclamacao, lugar and coisa.
- The domain of a phrase is the current book's or life's, its obsession (s.tema_dominante); when both
  exist and differ, the book's wins 6 times in 10. The book's, after a few pages, is the
  theme it has most ABOVE the average page (yomimon_base_topics.lua): family and time are in almost every
  old novel, so Dracula becomes fear, not time, and Macbeth becomes politics, not family.
- {gosto|padrão}: the domain's word, or the default when there is no domain. {gosto} without a default only in the
  generator cores, which skips the core when there is no domain.
- The "dominio:" option of a mark applies when there is a domain and no listed pole won.
- It prefers words not yet used: it only repeats after going through all of the kind.

Pure logic (no KOReader), testable outside it.
]]

local Lingua = require("yomimon_language")
local Tracos = require("yomimon_traits")

local Voz = {}

-- pole → axis and direction ("medrosa" → coragem, -1)
local POLOS = {}
for _, tr in ipairs(Tracos.LISTA) do
    POLOS[tr.neg] = { eixo = tr.id, sinal = -1 }
    POLOS[tr.pos] = { eixo = tr.id, sinal = 1 }
end
Voz.POLOS = POLOS

-- Kinds of domain word.
Voz.SLOTS = { gosto = true, cheiro = true, comparacao = true, exclamacao = true, lugar = true, coisa = true }

Voz.LIVRO_MIN_PAGINAS = 10  -- the book only becomes a domain after 10 pages…
Voz.LIVRO_MIN_PONTOS = 5    -- …with the theme at 5 points or more (count × theme weight, as in L.temas)
Voz.CHANCE_LIVRO = 6        -- in 10: the book's domain beats life's

-- How much of each theme an average page has, by language (ferramentas/validacao/calcular_base_temas.lua).
local okB, BASE_TEMAS = pcall(require, "yomimon_base_topics")
Voz.BASE_TEMAS = okB and type(BASE_TEMAS) == "table" and BASE_TEMAS or nil

local bancos = {}
--- Domain vocabulary in the current language (or nil).
function Voz.banco()
    local c = Lingua.code()
    if bancos[c] == nil then
        local ok, b = pcall(Lingua.data, "domains")
        bancos[c] = ok and type(b) == "table" and b or false
    end
    return bancos[c] or nil
end

--- The theme the current book has most above the average page, or nil if it is still early.
function Voz.dominioDoLivro(s)
    local L = s and s.ultimo_livro and s.livros and s.livros[s.ultimo_livro]
    local paginas = L and L.paginas or 0
    if paginas < Voz.LIVRO_MIN_PAGINAS then return nil end
    local lg = (L.paginas_pt or 0) * 2 > paginas and "pt" or "en"
    local media = Voz.BASE_TEMAS and Voz.BASE_TEMAS[lg] or {}
    local melhor, nota = nil, 0
    for t, c in pairs(L.temas or {}) do
        local acima = c / paginas - (media[t] or 0)
        if c >= Voz.LIVRO_MIN_PONTOS and (acima > nota or (acima == nota and melhor and t < melhor)) then
            melhor, nota = t, acima
        end
    end
    return melhor
end

--- Its obsession (the life theme), or nil.
function Voz.dominioDaVida(s)
    return s and s.tema_dominante
end

--- Is there any domain with vocabulary?
function Voz.temDominio(s)
    local B = Voz.banco()
    if not B then return false end
    local l, v = Voz.dominioDoLivro(s), Voz.dominioDaVida(s)
    return (l and B[l] ~= nil) or (v and B[v] ~= nil) or false
end

--- The domain of a phrase: the book's or life's (sorteio(n) returns from 1 to n).
function Voz.dominio(s, sorteio)
    local B = Voz.banco()
    if not B then return nil end
    local livro, vida = Voz.dominioDoLivro(s), Voz.dominioDaVida(s)
    if livro and not B[livro] then livro = nil end
    if vida and not B[vida] then vida = nil end
    if livro and vida and livro ~= vida then
        return (sorteio or math.random)(10) <= Voz.CHANCE_LIVRO and livro or vida
    end
    return livro or vida
end

-- Words used a moment ago, by theme and kind: it goes through all of them before repeating.
local usadas = {}
function Voz.esquecerPalavras() usadas = {} end  -- (for tests)
function Voz.palavra(tema, slot, sorteio)
    local B = Voz.banco()
    local lista = B and B[tema] and B[tema][slot]
    if not lista or #lista == 0 then return nil end
    local chave = tema .. "/" .. slot
    local vistas = usadas[chave] or {}
    local livres = {}
    for _, p in ipairs(lista) do if not vistas[p] then livres[#livres + 1] = p end end
    if #livres == 0 then vistas, livres = {}, lista end
    local p = livres[(sorteio or math.random)(#livres)]
    vistas[p] = true
    usadas[chave] = vistas
    return p
end

--- The options of a mark, separated by "|" (the "|" inside {gosto|padrão} does not separate).
function Voz.partes(corpo)
    local out, ini, nivel = {}, 1, 0
    for i = 1, #corpo do
        local c = corpo:sub(i, i)
        if c == "{" then nivel = nivel + 1
        elseif c == "}" then nivel = math.max(0, nivel - 1)
        elseif c == "|" and nivel == 0 then out[#out + 1] = corpo:sub(ini, i - 1); ini = i + 1 end
    end
    out[#out + 1] = corpo:sub(ini)
    return out
end

--- Options of a group (the text between < and >): { {polo=, limiar=, texto=} | {dominio=true, texto=} | {texto=} }.
-- Returns nil if no option has a label (it is not a variant mark).
function Voz.opcoes(corpo)
    local lista, algum = {}, false
    for _, parte in ipairs(Voz.partes(corpo)) do
        local rotulo, limiar, resto = parte:match("^(%l+)%.?(%d*):(.*)$")
        if rotulo and POLOS[rotulo] then
            lista[#lista + 1] = { polo = rotulo, limiar = tonumber(limiar) or Tracos.MARCANTE, texto = resto }
            algum = true
        elseif rotulo == "dominio" then
            lista[#lista + 1] = { dominio = true, texto = resto }
            algum = true
        else
            lista[#lista + 1] = { texto = parte }
        end
    end
    return algum and lista or nil
end

local function escolher(lista, tracos, haDominio)
    local melhor, valor, padrao, dom
    for _, o in ipairs(lista) do
        if o.polo then
            local p = POLOS[o.polo]
            local v = (tracos[p.eixo] or 0) * p.sinal
            if v >= o.limiar and (not melhor or v > valor) then melhor, valor = o, v end
        elseif o.dominio then
            dom = dom or o
        elseif not padrao then
            padrao = o
        end
    end
    if melhor then return melhor.texto, melhor.polo end
    if dom and haDominio() then return dom.texto end
    return padrao and padrao.texto or ""
end

--- Swaps the trait marks and domain words for what applies to s.
-- sem_dominio (optional): does not use a domain (the generator already used it in another part of the same phrase).
-- Returns the text, the poles that chose some option and the theme of the domain used (or nil).
function Voz.resolver(texto, s, sorteio, sem_dominio)
    if type(texto) ~= "string" or not (texto:find("<", 1, true) or texto:find("{", 1, true)) then
        return texto, {}, nil
    end
    local tracos = s and s.tracos or {}
    local polos, usado = {}, nil
    local dom  -- the phrase's domain, decided once only (false: none)
    local function dominio()
        if sem_dominio then return nil end
        if dom == nil then dom = Voz.dominio(s, sorteio) or false end
        return dom or nil
    end
    -- 1) domain words, inside and outside the marks; each one stays between \1 and \2 until the end, to
    --    know whether it survived the choice of the mark
    local out = texto:gsub("{(%l+)(|?)([^{}]*)}", function(nome, barra, padrao)
        if not Voz.SLOTS[nome] then return nil end
        local d = dominio()
        local p = d and Voz.palavra(d, nome, sorteio)
        if p then return "\1" .. p .. "\2" end
        if barra == "|" then return padrao end
        return nil
    end)
    -- 2) trait and domain marks
    out = out:gsub("<([^<>]*)>", function(corpo)
        local lista = Voz.opcoes(corpo)
        if not lista then return nil end  -- not a mark: stays as it is
        local escolhido, polo = escolher(lista, tracos, dominio)
        if polo then polos[#polos + 1] = polo end
        return escolhido
    end)
    if out:find("\1", 1, true) then usado = dom or nil end
    out = out:gsub("[\1\2]", "")
    -- an empty option leaves extra space
    out = out:gsub("  +", " "):gsub("^ ", ""):gsub(" $", ""):gsub(" ([%.,!%?])", "%1")
    return out, polos, usado
end

-- Step 4, the phrase that matches it wins (Valve, Hades, Emily Short) ----------------------------
-- When drawing from a list, the phrase that has a variant of one of its striking traits, or a domain word
-- when it has a domain, weighs more. Still a draw; without trait or domain, all weigh 1.
Voz.PESO_TRACO = 8     -- how much more a phrase with a variant of a striking pole weighs
Voz.PESO_DOMINIO = 4   -- how much more a phrase with a domain word weighs, if it has a domain
-- (calibrated by the voice ruler on 27/10/2026: with 3 and 2, half of the profiles with a trait were below 50%
-- of phrases with a clue; with 8 and 4, all pass, without losing variety)

local pistas_cache = {}  -- by bank text (the banks are fixed, so the cache does not grow forever)
--- What a phrase can show: { polos = {polo = true}, dominio = bool } (stored by text).
function Voz.pistas(texto)
    if type(texto) ~= "string" then return { polos = {}, dominio = false } end
    local p = pistas_cache[texto]
    if p then return p end
    p = { polos = {}, dominio = false }
    for corpo in texto:gmatch("<([^<>]*)>") do
        for _, o in ipairs(Voz.opcoes(corpo) or {}) do
            if o.polo then p.polos[o.polo] = true end
            if o.dominio then p.dominio = true end
        end
    end
    for nome in texto:gmatch("{(%l+)") do if Voz.SLOTS[nome] then p.dominio = true end end
    pistas_cache[texto] = p
    return p
end

--- Weight of a phrase for s: 1, plus PESO_TRACO if it lists a striking pole, plus PESO_DOMINIO if it uses a
-- domain and it has a domain. temDominio (optional) avoids recomputing over a whole list.
function Voz.peso(texto, s, temDominio)
    local p = Voz.pistas(texto)
    local w = 1
    local tracos = s and s.tracos or {}
    for polo in pairs(p.polos) do
        local q = POLOS[polo]
        if (tracos[q.eixo] or 0) * q.sinal >= Tracos.MARCANTE then w = w + Voz.PESO_TRACO; break end
    end
    if p.dominio then
        if temDominio == nil then temDominio = Voz.temDominio(s) end
        if temDominio then w = w + Voz.PESO_DOMINIO end
    end
    return w
end

--- Draws an item from the list, with the weight of each phrase (sorteio(n) returns from 1 to n).
-- sem_dominio (optional): the domain gives no weight (already used in another part of the phrase).
function Voz.escolher(lista, s, sorteio, sem_dominio)
    sorteio = sorteio or math.random
    if not lista or #lista == 0 then return nil end
    local dom = not sem_dominio and Voz.temDominio(s)
    local pesos, total = {}, 0
    for i, t in ipairs(lista) do
        pesos[i] = Voz.peso(t, s, dom)
        total = total + pesos[i]
    end
    if total == #lista then return lista[sorteio(#lista)] end  -- nobody stands out: the usual draw
    local r = sorteio(total)
    for i, w in ipairs(pesos) do
        r = r - w
        if r <= 0 then return lista[i] end
    end
    return lista[#lista]
end

--- Cause invented afterwards (Caves of Qud): the bad mood gets a real reason from the current book, the
-- event that stood out most in a recent chapter. temperamento: "jovem" or "velha".
-- Returns the phrase or nil.
function Voz.causa(s, temperamento, sorteio)
    local B = Voz.banco()
    local C = B and B._causa
    local L = s and s.ultimo_livro and s.livros and s.livros[s.ultimo_livro]
    if not (C and L and L.caps) then return nil end
    local ok, Memoria = pcall(require, "yomimon_memory")
    if not ok then return nil end
    local caps = {}
    for _, cap in pairs(L.caps) do caps[#caps + 1] = cap end
    table.sort(caps, function(a, b) return (a.ordem or 0) > (b.ordem or 0) end)
    for i = 1, math.min(5, #caps) do
        local ev = Memoria.eventoDoCapitulo(L, caps[i])
        local frases = C[temperamento == "jovem" and "jovem" or "velha"]
        if ev and C.eventos[ev] and frases then
            local t = frases[(sorteio or math.random)(#frases)]
            return (t:gsub("{evento}", C.eventos[ev]):gsub("{livro}", function() return s.ultimo_livro end))
        end
    end
end

return Voz
