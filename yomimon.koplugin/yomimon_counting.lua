--[[--
Contagem de páginas: duas perguntas separadas.

1. A página conta? Igual às estatísticas do KOReader, para os números baterem com o que o leitor vê:
   cada página conta UMA vez por livro (também depois de reiniciar o KOReader), se ficou aberta pelo
   menos o tempo mínimo das estatísticas (statistics.min_sec, 5 s por padrão). Se o total de páginas do
   livro muda (fonte, margens), a lista recomeça, porque os números das páginas mudam.

2. A página molda o Yomimon? Só leitura de verdade (o princípio: ela vira quem é pelo que você leu):
   - não é matéria inicial ou final (sumário, ficha catalográfica, prefácio, notas, sobre o autor…);
   - tem texto de verdade (página de título e dedicatória não);
   - ficou aberta um tempo plausível para o tanto de texto, pelo ritmo do próprio leitor: pelo menos
     35% do tempo que ele costuma levar por letra (mínimo de 8 s). Folhear não molda.

Lógica pura (sem KOReader), testável fora dele.
]]

local C = {}

C.MIN_PADRAO = 5             -- mesmo padrão das estatísticas do KOReader
C.FRACAO_RITMO = 0.35        -- tempo mínimo = 35% do ritmo do leitor para aquele tanto de texto
C.MIN_ABSOLUTO = 8           -- nunca menos que isso para moldar a traça
C.RITMO_PADRAO = 0.03        -- segundos por letra antes de conhecer o leitor (~33 letras/s, leitor rápido)
C.RITMO_AMOSTRAS = 30        -- quantas páginas recentes formam o ritmo
C.MAX_ABERTA = 600           -- página aberta mais que isso (dormiu?) não entra no ritmo
C.LETRAS_MINIMAS = 150       -- menos que isso é título, dedicatória, epígrafe
C.LIVROS_LEMBRADOS = 30      -- de quantos livros guarda as páginas já contadas

--- Tempo mínimo por página das estatísticas do KOReader (configuração do leitor), ou o padrão.
function C.minimoSegundos(estatisticas)
    local v = type(estatisticas) == "table" and tonumber(estatisticas.min_sec)
    return v and v >= 0 and v or C.MIN_PADRAO
end

-- Páginas já contadas de um livro, em faixas compactas: "11-27,30,35-40".
local function lerFaixas(txt)
    local out = {}
    for a, b in (txt or ""):gmatch("(%d+)%-?(%d*)") do out[#out + 1] = { tonumber(a), tonumber(b ~= "" and b or a) } end
    return out
end
local function escreverFaixas(faixas)
    local partes = {}
    for _, f in ipairs(faixas) do partes[#partes + 1] = f[1] == f[2] and tostring(f[1]) or (f[1] .. "-" .. f[2]) end
    return table.concat(partes, ",")
end
local function contem(faixas, p)
    for _, f in ipairs(faixas) do if p >= f[1] and p <= f[2] then return true end end
    return false
end
local function incluir(faixas, p)
    faixas[#faixas + 1] = { p, p }
    table.sort(faixas, function(a, b) return a[1] < b[1] end)
    local out = {}
    for _, f in ipairs(faixas) do
        local u = out[#out]
        if u and f[1] <= u[2] + 1 then u[2] = math.max(u[2], f[2]) else out[#out + 1] = { f[1], f[2] } end
    end
    return out
end

--- true se é a primeira vez que esta página do livro conta (e já registra). total: páginas do livro agora.
function C.primeiraVez(s, livro, pagina, total, agora)
    s.vistas = s.vistas or {}
    local v = s.vistas[livro]
    if not v or (total and v.total ~= total) then
        v = { total = total, faixas = "" }
        s.vistas[livro] = v
    end
    v.t = agora or v.t
    local faixas = lerFaixas(v.faixas)
    if contem(faixas, pagina) then return false end
    v.faixas = escreverFaixas(incluir(faixas, pagina))
    -- só os livros mais recentes
    local n, mais_velho, quando = 0, nil, math.huge
    for nome, x in pairs(s.vistas) do
        n = n + 1
        if (x.t or 0) < quando then mais_velho, quando = nome, x.t or 0 end
    end
    if n > C.LIVROS_LEMBRADOS and mais_velho then s.vistas[mais_velho] = nil end
    return true
end

-- Matéria inicial e final: pelo nome do capítulo no sumário ou por marcas no texto da página.
local CAPITULOS = {}
for t in ([[contents|table of contents|copyright|title page|cover|dedication|acknowledgments|acknowledgements|
    about the author|about the publisher|also by|other books by|books by|praise for|index|bibliography|notes|
    endnotes|footnotes|glossary|colophon|imprint|license|licence|project gutenberg|preface|foreword|introduction|
    translator's note|editor's note|a note on the text|further reading|chronology|epigraph|frontispiece|
    sumário|índice|conteúdo|direitos autorais|ficha catalográfica|ficha técnica|créditos|capa|folha de rosto|
    dedicatória|agradecimentos|sobre o autor|sobre a autora|do mesmo autor|da mesma autora|outras obras|
    prefácio|apresentação|introdução|nota do editor|nota da edição|nota do tradutor|nota da tradução|notas|
    posfácio|bibliografia|glossário|colofão|cronologia|epígrafe]]):gmatch("[^|]+") do
    CAPITULOS[#CAPITULOS + 1] = t:gsub("^%s+", ""):gsub("%s+$", "")
end
-- capítulos que sempre continuam ("Also by John Steinbeck", "Outras obras de Clarice Lispector")
local PREFIXOS = { "also by ", "books by ", "other books by ", "praise for ", "about the author", "outras obras ",
    "do mesmo autor", "da mesma autora", "sobre o autor", "sobre a autora" }
-- só marcas que praticamente só aparecem em ficha ou licença (nunca "printed in", que cabe num romance)
local MARCAS = { "isbn", "©", "all rights reserved", "todos os direitos reservados",
    "dados internacionais de catalogação", "catalogação na publicação", "library of congress", "project gutenberg" }

--- true se a página é matéria inicial ou final (não molda o Yomimon).
function C.materia(capitulo, texto)
    if type(capitulo) == "string" then
        local c = capitulo:lower():gsub("^[%s%d%p]+", ""):gsub("[%s%p]+$", "")
        -- nome exato ou com dois-pontos ("Introduction: …"); "Notes from Underground" não é "Notes"
        for _, t in ipairs(CAPITULOS) do
            if c == t or c:sub(1, #t + 1) == t .. ":" then return true end
        end
        for _, t in ipairs(PREFIXOS) do if c:sub(1, #t) == t then return true end end
    end
    if type(texto) == "string" and #texto < 4000 then
        local l = texto:lower()
        for _, m in ipairs(MARCAS) do if l:find(m, 1, true) then return true end end
    end
    return false
end

--- true se esta página já moldou o Yomimon (foi digerida). A contagem e a digestão são separadas: uma
-- página folheada conta na primeira passagem, mas ainda pode ser digerida quando você volta e lê.
function C.jaLida(s, livro, pagina)
    local v = s.vistas and s.vistas[livro]
    return v ~= nil and contem(lerFaixas(v.lidas), pagina)
end
function C.marcarLida(s, livro, pagina)
    local v = s.vistas and s.vistas[livro]
    if v then v.lidas = escreverFaixas(incluir(lerFaixas(v.lidas), pagina)) end
end

--- Ritmo do leitor (segundos por letra): mediana das páginas lidas de verdade mais recentes.
function C.ritmo(s)
    local r = s.ritmo
    if type(r) ~= "table" or #r < 5 then return C.RITMO_PADRAO end
    local o = {}
    for i, v in ipairs(r) do o[i] = v end
    table.sort(o)
    return o[math.floor((#o + 1) / 2)]
end

--- true se a página foi lida de verdade (molda o Yomimon); se foi, entra no ritmo do leitor.
function C.lidaDeVerdade(s, tempo, letras, capitulo, texto)
    if not texto or letras < C.LETRAS_MINIMAS or C.materia(capitulo, texto) then return false end
    local minimo = math.max(C.MIN_ABSOLUTO, C.FRACAO_RITMO * C.ritmo(s) * letras)
    if tempo < minimo then return false end
    if tempo <= C.MAX_ABERTA then
        s.ritmo = type(s.ritmo) == "table" and s.ritmo or {}
        s.ritmo[#s.ritmo + 1] = tempo / letras
        while #s.ritmo > C.RITMO_AMOSTRAS do table.remove(s.ritmo, 1) end
    end
    return true
end

return C
