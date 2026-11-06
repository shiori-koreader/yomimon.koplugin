--[[--
Memories: the memory that creates a bond. It compares the current book with the reading history (the
reviews, which pass from life to life) and remembers:

  level A (exact facts)   author again (with the count), anniversary of a finished book, character
                          who returns (series), the longest book, the fastest read;
  level B (measured perception) third book in a row with the same dominant theme.
  level C (stored, mute)  probable genre and aura of the protagonist go in the review; "nothing so gloomy (or
                          light) since X" is computed but does not speak (WEATHER_SPEECH = false): the weather average
                          of a whole book puts Hamlet, Romeo and Juliet and Frankenstein among the lightest
                          of the corpus. See ferramentas/validacao/MEMORIA-VINCULO.md.

Each memory becomes a diary entry, the first Home phrase (once) and a structured record in
s.lembrancas, which the memory ruler checks against what really happened.

Pure logic (no KOReader), testable outside it.
]]

local Language = require("yomimon_language")

local L = {}

local MAX = 200
local CHARACTER_PAGE = 40   -- pages of the book before looking for a returning character
local CHARACTER_STEP = 20    -- and afterwards only every 20 pages: the character list weighs the whole book,
                               -- and redone on every page it made page 700 of Moby Dick 50 times slower
local WEATHER_PAGE = 60        -- pages before comparing the book's weather with the history
local BOOKS_BETWEEN = 2       -- "since X" only if there were at least 2 books after X
local DAYS_SINCE = 30          -- and if X finished at least 30 days ago
local RECORD_BASE = 3         -- records only with at least 3 books finished before
local FAST_MARGIN = 1.2      -- "the fastest" only if 20% faster than the previous best (a short book
                               -- ends on an incomplete day and lowers the average: without a margin, every long book won)
L.WEATHER_SPEECH = false           -- level C: "nothing so gloomy/light since" computed, but mute

local function month(t) return Language.format().months[tonumber(os.date("%m", t))] end

local function fill(template, v)
    return (template:gsub("{([%w_]+)}", function(k) return v[k] ~= nil and tostring(v[k]) or ("{" .. k .. "}") end))
end
local function bank() return require("yomimon_diary").bank().recollection or {} end

--- Records a memory: diary, Home (once) and s.lembrancas.
local function remember(s, M, kind, book, now, data, v)
    local list = bank()[kind]
    if not list or #list == 0 then return nil end
    local textValue = fill(list[math.random(#list)], v or data)
    s.memories = s.memories or {}
    s.memories[#s.memories + 1] = { kind = kind, book = book, t = now, data = data }
    while #s.memories > MAX do table.remove(s.memories, 1) end
    M.note(s, now, textValue)
    s.pending_memory = { textValue = textValue, t = now }
    return textValue
end

local function alreadyRemembered(Lv, kind)
    Lv.remembered = Lv.remembered or {}
    if Lv.remembered[kind] then return true end
    Lv.remembered[kind] = true
    return false
end

local function finishedList(s, book)
    local out = {}
    for _, r in ipairs(s.reviews or {}) do if r.book ~= book then out[#out + 1] = r end end
    return out
end

-- Level A ----------------------------------------------------------------------------------

--- Start of a book: author again, with the count of how many of theirs there were. Returns the text (or nil).
function L.bookStart(s, M, book, where, now)
    local author = where and where.author
    if not author or author == "" then return nil end
    local seenItems, n = {}, 1
    for _, r in ipairs(finishedList(s, book)) do
        if r.author == author and not seenItems[r.book] then seenItems[r.book] = true; n = n + 1 end
    end
    if n < 2 then return nil end
    local Lv = s.books and s.books[book]
    if Lv and alreadyRemembered(Lv, "author") then return nil end
    return remember(s, M, "author", book, now, { author = author, n = n }, { author = author, n = n, book = book })
end

--- Once a day: anniversary of a finished book (same day and month, a year before).
local function anniversary(s, M, book, now)
    local today = os.date("%Y-%m-%d", now)
    if s.memory_day == today then return end
    s.memory_day = today
    local md, year = os.date("%m-%d", now), tonumber(os.date("%Y", now))
    for _, r in ipairs(s.reviews or {}) do
        if r.ending and os.date("%m-%d", r.ending) == md and tonumber(os.date("%Y", r.ending)) == year - 1 and r.anniversary ~= year then
            r.anniversary = year
            remember(s, M, "anniversary", book, now, { book = r.book }, { book = r.book })
            return
        end
    end
end

--- Character who returns from a previous book (series). Does not apply on a re-read.
local function character(s, M, Lv, book, now)
    if Lv.rereading or (Lv.pages or 0) < CHARACTER_PAGE or (Lv.remembered and Lv.remembered.character) then return end
    if Lv.pages % CHARACTER_STEP ~= 0 or #(s.reviews or {}) == 0 then return end
    local info = M.charactersInfo(s, book)
    for i = 1, math.min(3, #info) do
        local nameText = info[i].nameText
        local forms = {}  -- "Holmes" in the old review counts for "Sherlock Holmes" now, and vice versa
        for _, f in ipairs(info[i].forms or { nameText }) do forms[f] = true end
        for k = #(s.reviews or {}), 1, -1 do
            local r = s.reviews[k]
            if r.book ~= book then
                for _, p in ipairs(r.characters or {}) do
                    if forms[p] then
                        alreadyRemembered(Lv, "character")
                        remember(s, M, "character", book, now, { nameText = nameText, de = r.book }, { nameText = nameText, book = r.book })
                        return
                    end
                end
            end
        end
    end
end

-- Level B ----------------------------------------------------------------------------------

--- The book's weather so far compared with the history: "nothing so gloomy since X" or "the gloomiest".
local function weatherSince(s, M, Lv, book, now)
    if (Lv.pages or 0) < WEATHER_PAGE or (Lv.remembered and Lv.remembered.weather) then return end
    alreadyRemembered(Lv, "weather")
    local media = (Lv.weather or 0) / math.max(1, Lv.pages)
    local cal = M.WEATHER_CALIBRATION and M.WEATHER_CALIBRATION.books
    if not cal then return end
    local dark = media <= cal.gloomy
    if not dark and media < cal.light then return end
    local ant = finishedList(s, book)
    local function so_much(r) if dark then return r.weather <= media else return r.weather >= media end end
    local target
    for k = #ant, 1, -1 do if so_much(ant[k]) then target = k; break end end
    if target then
        local no_meio = #ant - target
        local days = ((Lv.beginning or now) - (ant[target].ending or now)) / 86400
        if no_meio >= BOOKS_BETWEEN and days >= DAYS_SINCE then
            local r = ant[target]
            Lv.weather_since = { kind = dark and "gloomy_since" or "light_since", book = r.book }
            if L.WEATHER_SPEECH then
                remember(s, M, Lv.weather_since.kind, book, now, { book = r.book }, { book = r.book, month = month(r.ending) })
            end
        end
    elseif #ant >= RECORD_BASE then
        Lv.weather_since = { kind = dark and "gloomiest" or "lighter" }
        if L.WEATHER_SPEECH then remember(s, M, Lv.weather_since.kind, book, now, {}, { book = book }) end
    end
end

--- Each page read.
function L.page(s, M, Lv, book, now)
    anniversary(s, M, book, now)
    if Lv then
        character(s, M, Lv, book, now)
        weatherSince(s, M, Lv, book, now)
    end
end

--- End of a book (after the review is stored): records and theme series.
-- serie: how many books in a row before this one had the same dominant theme.
function L.bookEnd(s, M, book, now, series)
    local cur = s.reviews and s.reviews[#s.reviews]
    if not cur or cur.book ~= book then return end
    local ant = {}
    for i = 1, #s.reviews - 1 do ant[#ant + 1] = s.reviews[i] end
    if cur.theme and (series or 0) >= 2 then
        remember(s, M, "theme_series", book, now, { theme = cur.theme, n = series + 1 },
            { theme = M.theme(cur.theme), of_theme = M.theme(cur.theme, "de"), n = series + 1 })
    end
    if #ant >= RECORD_BASE then
        local function ppd(r) return r.pages / math.max(1, r.days or 1) end
        local long, fast = true, true
        for _, r in ipairs(ant) do
            if r.pages >= cur.pages then long = false end
            if ppd(r) * FAST_MARGIN >= ppd(cur) then fast = false end
        end
        if long then remember(s, M, "longest_record", book, now, {}, { book = book, n = cur.pages }) end
        if fast then remember(s, M, "fastest_record", book, now, {}, { book = book }) end
    end
end

-- Level C (stored, mute) -----------------------------------------------------------------

local GENRES = {
    terror = { "medo", "noite", "morte", "loucura" }, romance = { "amor", "familia" },
    aventura = { "mar", "viagem", "animais" }, science_fiction = { "ciencia" },
    tragedia = { "vinganca", "politica", "morte" },
}
local AURAS = {
    gloomy = { "medo", "morte", "loucura", "noite" }, romantico = { "amor" }, adventurer = { "mar", "viagem", "guerra" },
    powerful = { "politica", "dinheiro" }, intellectual = { "saber", "ciencia", "arte" }, familiar = { "familia" },
}
local function best(themes, groups)
    local tot = 0
    for _, c in pairs(themes or {}) do tot = tot + c end
    if tot <= 0 then return nil end
    local l = {}
    for g, ts in pairs(groups) do
        local v = 0
        for _, t in ipairs(ts) do v = v + (themes[t] or 0) / tot end
        l[#l + 1] = { g, v }
    end
    table.sort(l, function(a, b) return a[2] > b[2] end)
    return l
end
--- Probable genre (≥ 30% of the themes and 8 points ahead) or nil. NOT used in phrases: right ~75% of the time.
function L.gender(themes)
    local l = best(themes, GENRES)
    if l and l[1][2] >= 0.30 and l[1][2] - (l[2] and l[2][2] or 0) >= 0.08 then return l[1][1] end
end
--- Aura of a character by the themes of the pages where they appear. NOT used in phrases yet.
function L.aura(themes)
    local l = best(themes, AURAS)
    return l and l[1][1] or nil
end

return L
