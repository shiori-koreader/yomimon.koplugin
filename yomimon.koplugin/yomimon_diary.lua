--[[--
Yomimon's diary: what it writes about your reading, with concrete things.

- One entry per reading day, built from that day's data: how many pages, of which
  book, at what time, who it met, a character's line, the event and the subject of the day.
- When starting a book: a varied opening (author, same author as before, abandoned book, re-read).
- When finishing a book: a short review (protagonist, comparison with other books, series of
  themes, the trait the book moved, grade) — and the full review goes to s.resenhas.

The phrases live in yomimon_locales/<code>/data/diary.lua. Pure logic, testable outside KOReader.
]]

local Language = require("yomimon_language")

local Diary = {}

local REVIEWS_MAX = 120
local BOOK_END = 0.98     -- book without a helpful table of contents: progress from which it counts as finished
local STORY_MIN = 0.5      -- appendices that would start before the middle of the file: the table of contents is not reliable
local ENTRY_MAX = 200       -- bigger entries lose optional parts

-- Appendix titles (what comes after the story), as whole words: notes, chronology, afterword,
-- about the author, credits, publisher ads…
local APPENDICES = {}
for p in ([[nota notas posfácio posfacio cronologia créditos creditos colofon colofão autor autora autores
    bibliografia referências glossário índice apêndice apêndices anexo anexos agradecimentos copyright
    note notes endnotes footnotes afterword author credits colophon acknowledgments acknowledgements
    appendix appendices glossary index bibliography references license gutenberg transcriber]]):gmatch("%S+") do
    APPENDICES[" " .. p .. " "] = true
end
for _, p in ipairs({ "saiba mais", "outras leituras", "leia também", "leia mais", "outros títulos",
    "further reading", "also by", "reading group", "praise for" }) do
    APPENDICES[" " .. p .. " "] = true
end

local function isAppendix(titleText)
    -- lowercase (also À…Þ), without numbers or punctuation: "XLV. Notas" → " xlv notas "
    local t = " " .. tostring(titleText or ""):lower():gsub("\195([\128-\158])", function(c) return "\195" .. string.char(c:byte() + 32) end)
        :gsub("[^%a\128-\255]+", " ") .. " "
    for lookupKey in pairs(APPENDICES) do
        if t:find(lookupKey, 1, true) then return true end
    end
    return false
end

--- Last page of the story, by the table of contents. Going backwards, it skips the appendix titles; the story ends
-- right before the first of them. Backwards because a chapter of the story may be called "Notas"
-- (Brás Cubas, XLV). Only the top level of the table of contents counts: the notes may have subtitles ("Capítulo 1"…).
-- toc: { { titulo =, pagina =, nivel = }, … } in the book's order; total: pages of the file.
-- Returns nil when the table of contents does not help (empty, only appendices, or appendices before the middle of the file).
function Diary.storyEnd(toc, total)
    if type(toc) ~= "table" or not total or total < 1 then return nil end
    local level
    for _, it in ipairs(toc) do level = math.min(level or math.huge, it.level or 1) end
    local top = {}
    for _, it in ipairs(toc) do
        if (it.level or 1) == level and type(it.page) == "number" then top[#top + 1] = it end
    end
    local i = #top
    while i >= 1 and isAppendix(top[i].titleText) do i = i - 1 end
    if i < 1 then return nil end
    if i == #top then return total end
    local ending = math.max(top[i].page, top[i + 1].page - 1)
    if ending < total * STORY_MIN then return nil end
    return ending
end

local bank
function Diary.bank()
    bank = bank or Language.data("diary")
    return bank
end

local function draws(list, draw)
    if not list or #list == 0 then return nil end
    return list[(draw or math.random)(#list)]
end

local function fill(template, v)
    local textValue = template:gsub("{([%w_]+)}", function(k) return v[k] or ("{" .. k .. "}") end)
    -- quotation punctuation: “Quem?”, disse → “Quem?” disse ; “Fim.”, disse → “Fim,” disse
    textValue = textValue:gsub("([%?!])\226\128\157,", "%1\226\128\157"):gsub("%.\226\128\157,", ",\226\128\157")
    return textValue
end

local function temperament(s)
    local ok, State = pcall(require, "yomimon_state")
    local t = ok and State.stage(s).temperament or "old"
    return t == "young" and "young" or "old"
end

local function biggestOf(t)
    local best, val = nil, 0
    for k, v in pairs(t or {}) do if v > val then best, val = k, v end end
    return best, val
end

-- Reading day ---------------------------------------------------------------------

--- Closes the previous day (if the day changed) and writes its entry. Call before counting the page.
function Diary.rollDay(s, M, now)
    local today = os.date("%Y-%m-%d", now)
    if s.day and s.day.data ~= today then
        local textValue = Diary.dayEntry(s, M, s.day)
        if textValue then M.note(s, s.day.last or now, textValue) end
        s.day = nil
    end
    s.day = s.day or { data = today, pages = 0, books = {}, order = {}, hours = { small_hours = 0, morning = 0, noite = 0 },
                       themes = {}, weather = 0, events = {} }
end

--- Counts a page on today's date.
-- contar: false when the page was already counted before and is now only digested.
function Diary.page(s, book, signal, speeches, now, count)
    local D = s.day
    if not D then return end
    D.last = now
    if count ~= false then
        D.pages = D.pages + 1
        if book then
            if not D.books[book] then D.order[#D.order + 1] = book end
            D.books[book] = (D.books[book] or 0) + 1
        end
        local h = tonumber(os.date("%H", now))
        if h < 5 then D.hours.small_hours = D.hours.small_hours + 1
        elseif h < 11 then D.hours.morning = D.hours.morning + 1
        elseif h >= 22 then D.hours.noite = D.hours.noite + 1 end
    end
    for t, c in pairs(signal.heavy_themes or signal.themes or {}) do D.themes[t] = (D.themes[t] or 0) + c end
    for ev, c in pairs(signal.events or {}) do D.events[ev] = (D.events[ev] or 0) + c end
    D.weather = D.weather + (signal.weather or 0)
    if speeches and #speeches > 0 and (not D.speech or math.random(3) == 1) then
        local f = speeches[math.random(#speeches)]
        D.speech = { nameText = f.nameText, speech = f.speech, book = book }
    end
end

--- Characters it "met" today (became a character and had not been noted yet).
local function metToday(s, M, D)
    local newOnes = {}
    for _, book in ipairs(D.order) do
        local L = s.books and s.books[book]
        if L then
            L.announced = L.announced or {}
            for i, p in ipairs(M.charactersInfo(s, book)) do
                if i > 6 then break end
                if not L.announced[p.nameText] then
                    L.announced[p.nameText] = true
                    newOnes[#newOnes + 1] = p.nameText
                end
            end
        end
    end
    return newOnes
end

--- Builds the entry of a reading day (or nil, if there was no reading).
function Diary.dayEntry(s, M, D)
    if not D or D.pages == 0 or #D.order == 0 then return nil end
    local B, temp = Diary.bank().day, temperament(s)
    local book = D.order[1]
    local bigger = 0
    for _, l in ipairs(D.order) do if D.books[l] > bigger then book, bigger = l, D.books[l] end end
    local v = { n = tostring(D.pages), book = book }
    -- opening: how much it ate
    local opening
    if #D.order >= 2 then
        v.book2 = D.order[1] == book and D.order[2] or D.order[1]
        opening = draws(B.two_books)
    elseif D.pages <= 5 then opening = draws(B.thin)
    elseif D.pages < 30 then opening = draws(B.normal)
    elseif D.pages < 80 then opening = draws(B.banquete)
    else opening = draws(B.huge_one) end
    local parts = { fill(opening, v) }
    -- time, when a period dominated the day
    local period, qty = biggestOf(D.hours)
    local time_of_day = period and qty >= D.pages * 0.6 and draws(B.time_of_day[period])
    -- details of the day, in order of interest
    -- details of the day, each with a weight (the most concrete weigh more)
    local details = {}
    local function detail(textValue, weight) if textValue then details[#details + 1] = { textValue = textValue, weight = weight } end end
    local newOnes = metToday(s, M, D)
    if #newOnes >= 2 then
        detail(fill(draws(B.newOnes2), { nameText = newOnes[1], name2 = newOnes[2] }), 4)
    elseif #newOnes == 1 then
        detail(fill(draws(B.new), { nameText = newOnes[1] }), 4)
    end
    -- character line: does not repeat who spoke on the last noted day
    if D.speech and #D.speech.speech <= 90 and D.speech.nameText ~= s.diary_last_speech then
        detail(fill(draws(B.speech[temp]), { nameText = D.speech.nameText, speech = D.speech.speech }), 3)
    end
    local ev, n_ev = biggestOf(D.events)
    if ev and n_ev >= 4 and B.event[ev] then detail(draws(B.event[ev]), 3) end
    local theme, n_tema = biggestOf(D.themes)
    if theme and n_tema >= 5 and M.theme then
        detail(fill(draws(B.theme), { theme = M.theme(theme), of_theme = M.theme(theme, "de") }), 1)
    end
    local weather = D.weather / D.pages
    if weather <= -1 then detail(draws(B.heavy), 2)
    elseif weather >= 1 then detail(draws(B.light), 2) end
    -- up to 2 details, drawn by weight
    for _ = 1, 2 do
        local sum = 0
        for _, d in ipairs(details) do sum = sum + d.weight end
        if sum == 0 then break end
        local target, acc = math.random() * sum, 0
        for i, d in ipairs(details) do
            acc = acc + d.weight
            if target <= acc then
                parts[#parts + 1] = d.textValue
                if D.speech and d.textValue:find(D.speech.speech, 1, true) then s.diary_last_speech = D.speech.nameText end
                table.remove(details, i)
                break
            end
        end
    end
    -- closing: in its tone, pulled by the day's weather
    local closing = draws((weather <= -1 and B.closing_dark or weather >= 1 and B.closing_light or B.closing)[temp])
    local function assemble(with_time, n_parts)
        local p = { parts[1] }
        if with_time and time_of_day then p[#p + 1] = time_of_day end
        for i = 2, n_parts do p[#p + 1] = parts[i] end
        if closing and closing ~= "" then p[#p + 1] = closing end
        return table.concat(p, " ")
    end
    local textValue = assemble(true, #parts)
    if #textValue > ENTRY_MAX then textValue = assemble(false, #parts) end
    if #textValue > ENTRY_MAX then textValue = assemble(false, math.min(2, #parts)) end
    return textValue
end

-- Start and end of a book --------------------------------------------------------

--- Entry of a new book. anterior: the book it had been eating before (or nil).
function Diary.bookStart(s, M, book, where, previous)
    local B = Diary.bank().beginning
    local v = { book = book, author = where and where.author, previous = previous }
    local Lant = previous and s.books and s.books[previous]
    local options = {}
    if Lant and not Lant.finished and (Lant.progress or 0) < 0.5 and (Lant.pages or 0) >= 5 then
        options = B.dropped
    elseif v.author then
        local same = false
        for titleText, L in pairs(s.books or {}) do
            if titleText ~= book and L.author == v.author then same = true end
        end
        options = same and B.same_author or (math.random(2) == 1 and B.author or B.generic_one)
    end
    if #options == 0 then options = B.generic_one end
    return fill(draws(options), v)
end

--- Entry of a re-read.
function Diary.reread(book)
    return fill(draws(Diary.bank().beginning.rereading), { book = book })
end

-- Trait that changed most during the book (or nil, if none changed enough).
local function bookTrait(s, L)
    local ok, Traits = pcall(require, "yomimon_traits")
    if not ok then return nil end
    local best, delta = nil, 8
    for _, tr in ipairs(Traits.LIST) do
        local d = ((s.traits or {})[tr.id] or 0) - ((L.traits_start or {})[tr.id] or 0)
        if math.abs(d) >= delta and tr.id ~= "clock" then best, delta = d > 0 and tr.pos or tr.neg, math.abs(d) end
    end
    return best
end

--- Closes a finished book: writes the short review in the diary and stores the full one in s.resenhas.
function Diary.bookEnd(s, M, book, now)
    local L = s.books and s.books[book]
    if not L then return end
    local B, temp = Diary.bank().ending, temperament(s)
    local info = M.charactersInfo(s, book)
    local protagonist
    for _, p in ipairs(info) do if p.protagonist then protagonist = p.nameText; break end end
    protagonist = protagonist or (info[1] and info[1].nameText)
    local characters = {}
    for i = 1, math.min(3, #info) do characters[i] = info[i].nameText end
    local theme = biggestOf(L.themes)
    local weather = (L.weather or 0) / math.max(1, L.pages)
    local days = L.days or 1
    -- grade: half by the pace you read at, half by the book's intensity (events and weather)
    local ppd = L.pages / math.max(1, days)
    local pace = ppd < 10 and 1 or ppd < 20 and 2 or ppd < 30 and 3 or ppd < 45 and 4 or 5
    local n_events = 0
    for _, c in pairs(L.events or {}) do n_events = n_events + c end
    local intensity = n_events / math.max(1, L.pages) * 2 + math.abs(weather)
    local strength = intensity < 0.3 and 1 or intensity < 0.6 and 2 or intensity < 1 and 3 or intensity < 1.5 and 4 or 5
    local grade = math.max(1, math.min(5, math.floor((pace + strength) / 2 + 0.5)))
    local trait = bookTrait(s, L)
    local quotation = M.quotation(s, book, function() return 1 end, 100)

    -- comparisons with the previous reviews
    s.reviews = s.reviews or {}
    local previous = s.reviews[#s.reviews]
    local series = 0
    for i = #s.reviews, 1, -1 do
        if s.reviews[i].theme == theme and s.reviews[i].book ~= book then series = series + 1 else break end
    end

    -- the book's compound name (book vector, yomimon_vector.lua): "a sea story, restless"
    local okV, Vector = pcall(require, "yomimon_vector")
    local nameText = okV and Vector.nameText(Vector.de(L)) or nil

    local parts = { fill(draws(B.opening), { book = book }) }
    if nameText and B.nameText then parts[#parts + 1] = fill(draws(B.nameText), { nameText = nameText }) end
    local optionals = {}
    if protagonist then optionals[#optionals + 1] = fill(draws(B.protagonist[temp]), { nameText = protagonist }) end
    if previous and previous.book ~= book and math.abs(weather - (previous.weather or 0)) >= 0.4 then
        optionals[#optionals + 1] = fill(draws(weather < (previous.weather or 0) and B.darker or B.lighter),
            { other = previous.book })
    end
    if theme and series == 1 then  -- 3rd in a row onwards becomes a guaranteed memory (yomimon_memories)
        local ordinal = Language.format().ordinals[math.min(series, 5)]
        optionals[#optionals + 1] = fill(draws(B.series), { ordinal = ordinal, theme = M.theme(theme), of_theme = M.theme(theme, "de") })
    end
    if trait and B.trait[trait] then optionals[#optionals + 1] = draws(B.trait[trait]) end
    for i = 1, math.min(2, #optionals) do
        local k = math.random(#optionals)
        parts[#parts + 1] = table.remove(optionals, k)
    end
    parts[#parts + 1] = fill(draws(B.grade[temp]), { n = tostring(grade) })
    M.note(s, now, table.concat(parts, " "))

    local verdict = draws(B.verdict[temp][grade])
    s.reviews[#s.reviews + 1] = {
        book = book, author = L.author, generation = s.generation or 1, beginning = L.beginning, ending = now, days = days,
        pages = L.pages, characters = characters, protagonist = protagonist, quotation = quotation,
        theme = theme, weather = weather, trait = trait, grade = grade, verdict = verdict, reread = L.rereading or nil,
        nameText = nameText,
    }
    while #s.reviews > REVIEWS_MAX do table.remove(s.reviews, 1) end
    -- the book's words (step 5): finished, keeps only the most counted
    if M.pruneVocab then M.pruneVocab(L, M.VOCAB_FIM) end
    local okLem, Mem = pcall(require, "yomimon_memories")
    if okLem then
        -- level C, stored and mute: probable genre and aura of the protagonist
        local r = s.reviews[#s.reviews]
        r.gender = Mem.gender(L.themes)
        r.aura = protagonist and L.aura and L.aura[protagonist] and Mem.aura(L.aura[protagonist]) or nil
        Mem.bookEnd(s, M, book, now, series)
    end
    -- names: only the final list of characters and places stays; the evidence leaves the saved state
    if M.freezeNames then M.freezeNames(L, book) end
end

--- Called on every page with the book already registered: reading days, progress, end and re-read.
function Diary.followBook(s, M, L, book, where, now)
    local today = os.date("%Y-%m-%d", now)
    if L.last_day ~= today then L.last_day, L.days = today, (L.days or 0) + 1 end
    local p = where and where.progress
    if not p then return end
    if L.finished and p < 0.1 and not L.rereading_now then
        -- restarted an already finished book: re-read
        L.finished, L.rereading, L.rereading_now = false, true, true
        L.traits_start = {}
        for k, v in pairs(s.traits or {}) do L.traits_start[k] = v end
        M.note(s, now, Diary.reread(book))
    end
    L.progress = p
    -- end: the last page of the story (onde.story_end, by the table of contents, in main.lua); without it, 98% of the file
    if p >= (where.story_end or BOOK_END) and not L.finished then
        L.finished, L.rereading_now = true, nil
        Diary.bookEnd(s, M, book, now)
    end
end

--- The book's status in KOReader ("reading", "complete", "abandoned"…), checked on opening, on closing and when
-- the Kindle sleeps. It became "complete" (you marked it as finished) while it was following: finished here
-- too, with a review. A book it sees for the first time already finished there (read before it) does not count; on a
-- re-read the status stays "complete" and the end comes from the table of contents. Returns true when the book finished.
function Diary.koreaderStatus(s, M, book, status, now)
    local L = book and s.books and s.books[book]
    if not L then return end
    status = type(status) == "string" and status or "nenhum"
    local before = L.koreader_status
    L.koreader_status = status
    if status == "complete" and before and before ~= "complete" and not L.finished then
        L.finished, L.rereading_now = true, nil
        Diary.bookEnd(s, M, book, now)
        return true
    end
end

--- Change of obsession (dominant theme), with varied phrases.
function Diary.obsession(M, oldOne, new)
    local B = Diary.bank().obsession
    local textValue
    if oldOne then
        textValue = fill(draws(B.swap), { before = M.theme(oldOne, "em"), now = M.theme(new, "em"),
            before_s = M.theme(oldOne), now_s = M.theme(new) })
    else
        textValue = fill(draws(B.new), { theme = M.theme(new, "em"), theme_s = M.theme(new) })
    end
    return (textValue:gsub("^%l", string.upper))
end

return Diary
