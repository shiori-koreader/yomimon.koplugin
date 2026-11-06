--[[--
Page counting: two separate questions.

1. Does the page count? Like KOReader's statistics, so the numbers match what the reader sees:
   each page counts ONCE per book (also after restarting KOReader), if it stayed open for at
   least the statistics' minimum time (statistics.min_sec, 5 s by default). If the book's total
   of pages changes (font, margins), the list starts again, because the page numbers change.

2. Does the page shape Yomimon? Only real reading (the principle: it becomes who it is by what you read):
   - it is not front or back matter (contents, catalogue card, preface, notes, about the author…);
   - it has real text (title page and dedication do not);
   - it stayed open a plausible time for the amount of text, by the reader's own pace: at least
     35% of the time they usually take per letter (minimum 8 s). Flipping through does not shape it.

Pure logic (no KOReader), testable outside it.
]]

local C = {}

C.MIN_PADRAO = 5             -- same default as KOReader's statistics
C.FRACAO_RITMO = 0.35        -- minimum time = 35% of the reader's pace for that amount of text
C.MIN_ABSOLUTO = 8           -- never less than this to shape Yomimon
C.RITMO_PADRAO = 0.03        -- seconds per letter before knowing the reader (~33 letters/s, a fast reader)
C.RITMO_AMOSTRAS = 30        -- how many recent pages make up the pace
C.MAX_ABERTA = 600           -- a page open longer than this (fell asleep?) does not enter the pace
C.LETRAS_MINIMAS = 150       -- less than this is a title, dedication, epigraph
C.LIVROS_LEMBRADOS = 30      -- how many books it keeps the already counted pages of

--- Minimum time per page of KOReader's statistics (the reader's setting), or the default.
function C.minimoSegundos(estatisticas)
    local v = type(estatisticas) == "table" and tonumber(estatisticas.min_sec)
    return v and v >= 0 and v or C.MIN_PADRAO
end

-- Pages already counted of a book, in compact ranges: "11-27,30,35-40".
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

--- true if it is the first time this page of the book counts (and already records it). total: pages of the book now.
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
    -- only the most recent books
    local n, mais_velho, quando = 0, nil, math.huge
    for nome, x in pairs(s.vistas) do
        n = n + 1
        if (x.t or 0) < quando then mais_velho, quando = nome, x.t or 0 end
    end
    if n > C.LIVROS_LEMBRADOS and mais_velho then s.vistas[mais_velho] = nil end
    return true
end

-- Front and back matter: by the chapter name in the table of contents or by marks in the page text.
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
-- chapters that always continue ("Also by John Steinbeck", "Outras obras de Clarice Lispector")
local PREFIXOS = { "also by ", "books by ", "other books by ", "praise for ", "about the author", "outras obras ",
    "do mesmo autor", "da mesma autora", "sobre o autor", "sobre a autora" }
-- only marks that practically only appear in a catalogue card or licence (never "printed in", which fits in a novel)
local MARCAS = { "isbn", "©", "all rights reserved", "todos os direitos reservados",
    "dados internacionais de catalogação", "catalogação na publicação", "library of congress", "project gutenberg" }

--- true if the page is front or back matter (does not shape Yomimon).
function C.materia(capitulo, texto)
    if type(capitulo) == "string" then
        local c = capitulo:lower():gsub("^[%s%d%p]+", ""):gsub("[%s%p]+$", "")
        -- exact name or with a colon ("Introduction: …"); "Notes from Underground" is not "Notes"
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

--- true if this page already shaped Yomimon (was digested). Counting and digestion are separate: a
-- page flipped through counts on the first pass, but can still be digested when you come back and read.
function C.jaLida(s, livro, pagina)
    local v = s.vistas and s.vistas[livro]
    return v ~= nil and contem(lerFaixas(v.lidas), pagina)
end
function C.marcarLida(s, livro, pagina)
    local v = s.vistas and s.vistas[livro]
    if v then v.lidas = escreverFaixas(incluir(lerFaixas(v.lidas), pagina)) end
end

--- The reader's pace (seconds per letter): median of the most recent pages really read.
function C.ritmo(s)
    local r = s.ritmo
    if type(r) ~= "table" or #r < 5 then return C.RITMO_PADRAO end
    local o = {}
    for i, v in ipairs(r) do o[i] = v end
    table.sort(o)
    return o[math.floor((#o + 1) / 2)]
end

--- true if the page was really read (shapes Yomimon); if so, it enters the reader's pace.
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
