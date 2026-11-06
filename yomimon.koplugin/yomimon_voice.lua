--[[--
A voz da Yomimon: o único lugar que entende as marcas de variante dentro das frases (PLANO-VOZ.md).

Etapa 1, traço dentro da frase (como no Wildermyth):

    "Achei um ponto final e <amarga:fiquei aliviada|otimista:já quero o próximo|fiquei com medo de acabar>."

- A marca começa por uma opção com rótulo. Cada rótulo é um polo de traço: amarga, otimista, medrosa,
  corajosa, cinica, romantica, popular, erudita, diurna ou noturna. Vence a opção do polo marcante
  (Tracos.MARCANTE) mais forte entre os listados; empate fica com a primeira.
- Limiar opcional: "medrosa.60:" só vale com o traço em 60 ou mais.
- A opção sem rótulo é a fala de sempre: vale quando nenhum polo listado está marcante. Pode ser vazia.
- Brechas {livro}, {personagem}… podem ir dentro das opções, as mesmas em todas. %s e %d nunca: o
  string.format conta todas as opções.

Etapa 2, vocabulário do que ela comeu (os domínios de Caves of Qud):

    "Lambi a capa. Só tinha {gosto|poeira}."         → "Só tinha sal." (quem anda lendo sobre o mar)
    "Ainda mastigando “%s”.<dominio: Tem gosto de {gosto}.|>"

- Cada tema tem um vocabulário (locales/<code>/data/domains.lua) com seis tipos de palavra:
  gosto, cheiro, comparacao, exclamacao, lugar e coisa.
- O domínio de uma fala é o do livro atual ou o da vida, a obsessão dela (s.tema_dominante); quando os dois
  existem e são diferentes, o do livro vale 6 em cada 10 vezes. O do livro, depois de algumas páginas, é o
  tema que ele tem mais ACIMA da página média (yomimon_base_topics.lua): família e tempo estão em quase todo
  romance antigo, então Drácula vira medo, não tempo, e Macbeth vira política, não família.
- {gosto|padrão}: a palavra do domínio, ou o padrão quando não há domínio. {gosto} sem padrão só nos
  núcleos do gerador, que pula o núcleo quando não há domínio.
- A opção "dominio:" de uma marca vale quando há domínio e nenhum polo listado ganhou.
- Ela prefere as palavras ainda não usadas: só repete depois de passar por todas do tipo.

Lógica pura (sem KOReader), testável fora dele.
]]

local Lingua = require("yomimon_language")
local Tracos = require("yomimon_traits")

local Voz = {}

-- polo → eixo e sentido ("medrosa" → coragem, -1)
local POLOS = {}
for _, tr in ipairs(Tracos.LISTA) do
    POLOS[tr.neg] = { eixo = tr.id, sinal = -1 }
    POLOS[tr.pos] = { eixo = tr.id, sinal = 1 }
end
Voz.POLOS = POLOS

-- Tipos de palavra dos domínios.
Voz.SLOTS = { gosto = true, cheiro = true, comparacao = true, exclamacao = true, lugar = true, coisa = true }

Voz.LIVRO_MIN_PAGINAS = 10  -- o livro só vira domínio depois de 10 páginas…
Voz.LIVRO_MIN_PONTOS = 5    -- …com o tema em 5 pontos ou mais (contagem × peso do tema, como em L.temas)
Voz.CHANCE_LIVRO = 6        -- em 10: o domínio do livro ganha do da vida

-- Quanto de cada tema tem uma página média, por língua (ferramentas/validacao/calcular_base_temas.lua).
local okB, BASE_TEMAS = pcall(require, "yomimon_base_topics")
Voz.BASE_TEMAS = okB and type(BASE_TEMAS) == "table" and BASE_TEMAS or nil

local bancos = {}
--- Vocabulário dos domínios no idioma atual (ou nil).
function Voz.banco()
    local c = Lingua.code()
    if bancos[c] == nil then
        local ok, b = pcall(Lingua.data, "domains")
        bancos[c] = ok and type(b) == "table" and b or false
    end
    return bancos[c] or nil
end

--- O tema que o livro atual tem mais acima da página média, ou nil se ainda é cedo.
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

--- A obsessão dela (o tema da vida), ou nil.
function Voz.dominioDaVida(s)
    return s and s.tema_dominante
end

--- Algum domínio com vocabulário?
function Voz.temDominio(s)
    local B = Voz.banco()
    if not B then return false end
    local l, v = Voz.dominioDoLivro(s), Voz.dominioDaVida(s)
    return (l and B[l] ~= nil) or (v and B[v] ~= nil) or false
end

--- O domínio de uma fala: o do livro ou o da vida (sorteio(n) devolve de 1 a n).
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

-- Palavras usadas há pouco, por tema e tipo: ela passa por todas antes de repetir.
local usadas = {}
function Voz.esquecerPalavras() usadas = {} end  -- (para testes)
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

--- As opções de uma marca, separadas por "|" (o "|" dentro de {gosto|padrão} não separa).
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

--- Opções de um grupo (o texto entre < e >): { {polo=, limiar=, texto=} | {dominio=true, texto=} | {texto=} }.
-- Devolve nil se nenhuma opção tem rótulo (não é uma marca de variante).
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

--- Troca as marcas de traço e as palavras de domínio pelo que vale para s.
-- sem_dominio (opcional): não usa domínio (o gerador já usou em outra parte da mesma fala).
-- Devolve o texto, os polos que escolheram alguma opção e o tema do domínio usado (ou nil).
function Voz.resolver(texto, s, sorteio, sem_dominio)
    if type(texto) ~= "string" or not (texto:find("<", 1, true) or texto:find("{", 1, true)) then
        return texto, {}, nil
    end
    local tracos = s and s.tracos or {}
    local polos, usado = {}, nil
    local dom  -- o domínio da fala, decidido uma vez só (false: nenhum)
    local function dominio()
        if sem_dominio then return nil end
        if dom == nil then dom = Voz.dominio(s, sorteio) or false end
        return dom or nil
    end
    -- 1) palavras de domínio, dentro e fora das marcas; cada uma fica entre \1 e \2 até o fim, para
    --    saber se sobreviveu à escolha da marca
    local out = texto:gsub("{(%l+)(|?)([^{}]*)}", function(nome, barra, padrao)
        if not Voz.SLOTS[nome] then return nil end
        local d = dominio()
        local p = d and Voz.palavra(d, nome, sorteio)
        if p then return "\1" .. p .. "\2" end
        if barra == "|" then return padrao end
        return nil
    end)
    -- 2) marcas de traço e de domínio
    out = out:gsub("<([^<>]*)>", function(corpo)
        local lista = Voz.opcoes(corpo)
        if not lista then return nil end  -- não é marca: fica como está
        local escolhido, polo = escolher(lista, tracos, dominio)
        if polo then polos[#polos + 1] = polo end
        return escolhido
    end)
    if out:find("\1", 1, true) then usado = dom or nil end
    out = out:gsub("[\1\2]", "")
    -- opção vazia deixa espaço sobrando
    out = out:gsub("  +", " "):gsub("^ ", ""):gsub(" $", ""):gsub(" ([%.,!%?])", "%1")
    return out, polos, usado
end

-- Etapa 4, a fala que combina com ela ganha (Valve, Hades, Emily Short) ----------------------------
-- Ao sortear de uma lista, a fala que tem variante de um traço marcante dela, ou palavra de domínio
-- quando ela tem domínio, pesa mais. Continua sorteio; sem traço nem domínio, todas pesam 1.
Voz.PESO_TRACO = 8     -- quanto a mais pesa uma fala com variante de um polo marcante
Voz.PESO_DOMINIO = 4   -- quanto a mais pesa uma fala com palavra de domínio, se ela tem domínio
-- (calibrados pela régua de voz em 27/10/2026: com 3 e 2, metade dos perfis com traço ficava abaixo de 50%
-- de falas com pista; com 8 e 4, todos passam, sem perder variedade)

local pistas_cache = {}  -- por texto de banco (os bancos são fixos, então o cache não cresce sem fim)
--- O que uma fala pode mostrar: { polos = {polo = true}, dominio = bool } (guardado por texto).
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

--- Peso de uma fala para s: 1, mais PESO_TRACO se lista um polo marcante, mais PESO_DOMINIO se usa
-- domínio e ela tem domínio. temDominio (opcional) evita recalcular numa lista inteira.
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

--- Sorteia um item da lista, com o peso de cada fala (sorteio(n) devolve de 1 a n).
-- sem_dominio (opcional): o domínio não dá peso (já foi usado em outra parte da fala).
function Voz.escolher(lista, s, sorteio, sem_dominio)
    sorteio = sorteio or math.random
    if not lista or #lista == 0 then return nil end
    local dom = not sem_dominio and Voz.temDominio(s)
    local pesos, total = {}, 0
    for i, t in ipairs(lista) do
        pesos[i] = Voz.peso(t, s, dom)
        total = total + pesos[i]
    end
    if total == #lista then return lista[sorteio(#lista)] end  -- ninguém se destaca: o sorteio de sempre
    local r = sorteio(total)
    for i, w in ipairs(pesos) do
        r = r - w
        if r <= 0 then return lista[i] end
    end
    return lista[#lista]
end

--- Causa inventada depois (Caves of Qud): o mau humor ganha um motivo real do livro atual, o
-- acontecimento que mais se destacou num capítulo recente. temperamento: "jovem" ou "velha".
-- Devolve a fala ou nil.
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
