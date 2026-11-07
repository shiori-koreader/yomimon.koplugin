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

C.DEFAULT_MIN = 5             -- same default as KOReader's statistics
C.PACE_FRACTION = 0.35        -- minimum time = 35% of the reader's pace for that amount of text
C.ABSOLUTE_MIN = 8           -- never less than this to shape Yomimon
C.DEFAULT_PACE = 0.03        -- seconds per letter before knowing the reader (~33 letters/s, a fast reader)
C.PACE_SAMPLES = 30        -- how many recent pages make up the pace
C.MAX_OPEN = 600           -- a page open longer than this (fell asleep?) does not enter the pace
C.MIN_PAGE_LETTERS = 150       -- less than this is a title, dedication, epigraph
C.REMEMBERED_BOOKS = 30      -- how many books it keeps the already counted pages of

--- Minimum time per page of KOReader's statistics (the reader's setting), or the default.
function C.minimumSeconds(statistics)
    local v = type(statistics) == "table" and tonumber(statistics.min_sec)
    return v and v >= 0 and v or C.DEFAULT_MIN
end

-- Pages already counted of a book, in compact ranges: "11-27,30,35-40".
local function readRanges(txt)
    local out = {}
    for a, b in (txt or ""):gmatch("(%d+)%-?(%d*)") do out[#out + 1] = { tonumber(a), tonumber(b ~= "" and b or a) } end
    return out
end
local function writeRanges(ranges)
    local parts = {}
    for _, f in ipairs(ranges) do parts[#parts + 1] = f[1] == f[2] and tostring(f[1]) or (f[1] .. "-" .. f[2]) end
    return table.concat(parts, ",")
end
local function contains(ranges, p)
    for _, f in ipairs(ranges) do if p >= f[1] and p <= f[2] then return true end end
    return false
end
local function include(ranges, p)
    ranges[#ranges + 1] = { p, p }
    table.sort(ranges, function(a, b) return a[1] < b[1] end)
    local out = {}
    for _, f in ipairs(ranges) do
        local u = out[#out]
        if u and f[1] <= u[2] + 1 then u[2] = math.max(u[2], f[2]) else out[#out + 1] = { f[1], f[2] } end
    end
    return out
end

--- true if it is the first time this page of the book counts (and already records it). total: pages of the book now.
function C.firstTime(s, book, page, total, now)
    s.seenList = s.seenList or {}
    local v = s.seenList[book]
    if not v or (total and v.total ~= total) then
        v = { total = total, ranges = "" }
        s.seenList[book] = v
    end
    v.t = now or v.t
    local ranges = readRanges(v.ranges)
    if contains(ranges, page) then return false end
    v.ranges = writeRanges(include(ranges, page))
    -- only the most recent books
    local n, oldest, when = 0, nil, math.huge
    for nameText, x in pairs(s.seenList) do
        n = n + 1
        if (x.t or 0) < when then oldest, when = nameText, x.t or 0 end
    end
    if n > C.REMEMBERED_BOOKS and oldest then s.seenList[oldest] = nil end
    return true
end

-- Front and back matter: by the chapter name in the table of contents or by marks in the page text.
local CHAPTERS = {}
for t in ([[contents|table of contents|copyright|title page|cover|dedication|acknowledgments|acknowledgements|
    about the author|about the publisher|also by|other books by|books by|praise for|index|bibliography|notes|
    endnotes|footnotes|glossary|colophon|imprint|license|licence|project gutenberg|preface|foreword|introduction|
    translator's note|editor's note|a note on the text|further reading|chronology|epigraph|frontispiece|
    sumário|índice|conteúdo|direitos autorais|ficha catalográfica|ficha técnica|créditos|capa|folha de rosto|
    dedicatória|agradecimentos|sobre o autor|sobre a autora|do mesmo autor|da mesma autora|outras obras|
    prefácio|apresentação|introdução|nota do editor|nota da edição|nota do tradutor|nota da tradução|notas|
    posfácio|bibliografia|glossário|colofão|cronologia|epígrafe]]):gmatch("[^|]+") do
    CHAPTERS[#CHAPTERS + 1] = t:gsub("^%s+", ""):gsub("%s+$", "")
end
-- chapters that always continue ("Also by John Steinbeck", "Outras obras de Clarice Lispector")
local PREFIXES = { "also by ", "books by ", "other books by ", "praise for ", "about the author", "outras obras ",
    "do mesmo autor", "da mesma autora", "sobre o autor", "sobre a autora" }
-- only marks that practically only appear in a catalogue card or licence (never "printed in", which fits in a novel)
local MARKS = { "isbn", "©", "all rights reserved", "todos os direitos reservados",
    "dados internacionais de catalogação", "catalogação na publicação", "library of congress", "project gutenberg" }

--- true if the page is front or back matter (does not shape Yomimon).
function C.matter(chapter, textValue)
    if type(chapter) == "string" then
        local c = chapter:lower():gsub("^[%s%d%p]+", ""):gsub("[%s%p]+$", "")
        -- exact name or with a colon ("Introduction: …"); "Notes from Underground" is not "Notes"
        for _, t in ipairs(CHAPTERS) do
            if c == t or c:sub(1, #t + 1) == t .. ":" then return true end
        end
        for _, t in ipairs(PREFIXES) do if c:sub(1, #t) == t then return true end end
    end
    if type(textValue) == "string" and #textValue < 4000 then
        local l = textValue:lower()
        for _, m in ipairs(MARKS) do if l:find(m, 1, true) then return true end end
    end
    return false
end

--- true if this page already shaped Yomimon (was digested). Counting and digestion are separate: a
-- page flipped through counts on the first pass, but can still be digested when you come back and read.
function C.alreadyRead(s, book, page)
    local v = s.seenList and s.seenList[book]
    return v ~= nil and contains(readRanges(v.readPages), page)
end
function C.markRead(s, book, page)
    local v = s.seenList and s.seenList[book]
    if v then v.readPages = writeRanges(include(readRanges(v.readPages), page)) end
end

--- The reader's pace (seconds per letter): median of the most recent pages really read.
function C.pace(s)
    local r = s.pace
    if type(r) ~= "table" or #r < 5 then return C.DEFAULT_PACE end
    local o = {}
    for i, v in ipairs(r) do o[i] = v end
    table.sort(o)
    return o[math.floor((#o + 1) / 2)]
end

--- true if the page was really read (shapes Yomimon); if so, it enters the reader's pace.
function C.reallyRead(s, time, letters, chapter, textValue)
    if not textValue or letters < C.MIN_PAGE_LETTERS or C.matter(chapter, textValue) then return false end
    local minimum = math.max(C.ABSOLUTE_MIN, C.PACE_FRACTION * C.pace(s) * letters)
    if time < minimum then return false end
    if time <= C.MAX_OPEN then
        s.pace = type(s.pace) == "table" and s.pace or {}
        s.pace[#s.pace + 1] = time / letters
        while #s.pace > C.PACE_SAMPLES do table.remove(s.pace, 1) end
    end
    return true
end

return C
