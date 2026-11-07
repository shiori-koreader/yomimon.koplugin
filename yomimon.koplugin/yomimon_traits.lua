--[[--
Yomimon's personality traits: they move slowly with what YOU read.

Five axes, from -100 to 100:
  mood    bitter  ↔ hopeful   (tragedies, deaths ↔ love, parties, weddings)
  courage  fearful ↔ brave   (horror, crimes ↔ sea, travel, adventures)
  heart  cínica  ↔ romântica  (money, politics, revenge ↔ love, weddings, letters)
  taste    popular ↔ erudite    (crimes, parties ↔ philosophy, art, science, faith)
  clock  diurnal  ↔ nocturnal    (the time you read)

Only pages really eaten move the traits (never what it knows of the book ahead).
Each page pushes by the DIFFERENCE from an average page (yomimon_base_traits.lua): family and love in an old
novel, or knowledge and faith in a classic, are in almost every book and do not push; only what your
book has above (or below) normal shapes it. What you do NOT read only undoes excess: a page with
nothing for a trait pulls towards neutral, never towards the opposite pole (not reading romance does not make it cynical).
Each page pushes a little and everything slowly returns to the middle: what you read last
weighs more. When a trait becomes striking, it writes in the diary and gets its own phrases
(in yomimon_locales/<code>/data/traits.lua).

Pure logic (no KOReader), testable outside it.
]]

local Language = require("yomimon_language")
local T = Language.t

local Traits = {}

Traits.LIST = {
    { id = "mood",   neg = "bitter",  pos = "hopeful" },
    { id = "courage", neg = "fearful", pos = "brave" },
    { id = "heart", neg = "cynical",  pos = "romantic" },
    { id = "taste",   neg = "popular", pos = "erudite" },
    { id = "clock", neg = "diurnal",  pos = "nocturnal" },
}
Traits.STEP = 0.5          -- how much a page can move a trait
Traits.DECAY = 0.998   -- on each page, everything returns a little to the middle
Traits.STRIKING = 25        -- from here up the trait shows in the phrases and in the diary
Traits.STRONG = 60
Traits.SLACK = 5            -- to drop a level it must fall 5 below the limit (no flicker)

local LABEL = {
    bitter = "BITTER", hopeful = "HOPEFUL", fearful = "JUMPY", brave = "BOLD",
    cynical = "CYNICAL", romantic = "ROMANTIC", popular = "LOWBROW", erudite = "HIGHBROW",
    diurnal = "EARLY BIRD", nocturnal = "NIGHT OWL",
}

-- What each page signal pushes (positive = the axis' "pos" pole).
local WEIGHTS = {
    mood = {
        themes = { death = -1, war = -1, solitude = -1, revenge = -1, fear = -0.5, madness = -1, money = -0.5,
                  love = 1, nature = 0.5, food = 1, childhood = 0.5, art = 0.5, travel = 0.5 },
        events = { death = -2, illness = -1, crime = -1, quarrel = -0.5, party = 1.5, wedding = 1.5 },
        -- (27/10/2026, madness -0.5 → -1 and money -0.5, so tragedy leaves it bitter
        -- and not just fearful like horror; Crime and Punishment, Hamlet and Macbeth are madness, guilt and money)
        -- (without weather: the old list pulled horror towards optimistic; the dictionary orders short passages well,
        -- but leaves Shakespeare and Victorian prose "light" — Hamlet and Romeo were less bitter with it.
        -- Out since 25/10/2026)
    },
    courage = {
        themes = { fear = -1.5, madness = -0.5, night = -0.3, travel = 1, sea = 1, freedom = 1, war = 0.5 },
        events = { escape = -0.5, storm = 0.5, travel = 1 },
        -- (crime left on 27/10/2026: crime and investigation, from Sherlock to Crime and Punishment, are not stories of
        -- fear; crime still leaves it bitter and a little cynical)
    },
    heart = {
        themes = { love = 1.5, art = 0.5, family = 0.5, money = -1, politics = -1, revenge = -1 },
        events = { wedding = 1.5, letter = 0.5, quarrel = -0.5, crime = -0.5 },
    },
    taste = {
        themes = { knowledge = 1, art = 1, faith = 0.5, science = 0.5 },
        events = { crime = -0.5, party = -0.3 },
    },
}

Traits.WEIGHTS = WEIGHTS  -- exposed for the validation tools

local function limitTo(v, a) return math.max(-a, math.min(a, v)) end

-- Average push of a page, by language: what every book has does not shape it.
Traits.CENTERED = { "mood", "courage", "heart", "taste" }
local okBase, BASE = pcall(require, "yomimon_base_traits")
Traits.BASE = okBase and type(BASE) == "table" and BASE or nil

local bank
--- Phrases and diary notes of the traits, in the current language.
function Traits.bank()
    bank = bank or Language.data("traits")
    return bank
end

--- -2, -1, 0, 1 or 2 for a value (without considering the previous level).
function Traits.level(v)
    if v >= Traits.STRONG then return 2 elseif v >= Traits.STRIKING then return 1
    elseif v <= -Traits.STRONG then return -2 elseif v <= -Traits.STRIKING then return -1 end
    return 0
end

-- Level with slack: to weaken, the value must fall SLACK below the current level's limit.
local function levelWithSlack(v, current)
    local target = Traits.level(v)
    if current ~= 0 and (target == 0 or (target > 0) == (current > 0)) and math.abs(target) < math.abs(current) then
        local limit = math.abs(current) == 2 and Traits.STRONG or Traits.STRIKING
        if math.abs(v) > limit - Traits.SLACK and (v > 0) == (current > 0) then return current end
    end
    return target
end

--- How much a page pushes each axis (from -1 to 1). hour: the local time of reading.
-- raw: without discounting the average page (to compute the average and for diagnosis).
function Traits.push(signal, hour, raw)
    local out = {}
    for id, P in pairs(WEIGHTS) do
        local v = 0
        for t, c in pairs(signal.themes or {}) do v = v + (P.themes[t] or 0) * math.min(c, 3) end
        for ev in pairs(signal.events or {}) do v = v + (P.events[ev] or 0) end
        if P.weather then v = v + P.weather * (signal.weather or 0) end
        out[id] = v
    end
    -- (the average word size pushed taste; out since 25/10/2026: it decided 70–83% of the trait and
    -- called almost all prose "popular", Henry James and Dostoevsky included)
    local base = not raw and Traits.BASE and Traits.BASE[signal.pt and "pt" or "en"]
    local absent = {}
    if base then
        for _, id in ipairs(Traits.CENTERED) do
            if out[id] == 0 then absent[id] = true end
            out[id] = out[id] - (base[id] or 0)
        end
    end
    out.clock = 0
    if hour then
        if hour >= 22 or hour < 5 then out.clock = 1 elseif hour < 12 then out.clock = -1 end
    end
    for id, v in pairs(out) do out[id] = limitTo(v, 1) end
    return out, absent
end

--- Average push of a page, by language, over a corpus (lines of the corpus file; `excluded`: books to
-- ignore). Used by the personality ruler.
function Traits.pagesAverage(M, lines, excluded)
    local sum, n, book = { en = {}, pt = {} }, { en = 0, pt = 0 }, nil
    for line in lines do
        local t = line:match("^#LIVRO\t(.*)")
        if t then book = t
        elseif not line:match("^#") and book and not (excluded and excluded[book]) then
            local sn = M.signals(line, book)
            local lg = sn.pt and "pt" or "en"
            local e = Traits.push(sn, nil, true)
            n[lg] = n[lg] + 1
            for _, id in ipairs(Traits.CENTERED) do sum[lg][id] = (sum[lg][id] or 0) + e[id] end
        end
    end
    local base = { en = {}, pt = {} }
    for lg, sm in pairs(sum) do
        for _, id in ipairs(Traits.CENTERED) do base[lg][id] = (sm[id] or 0) / math.max(1, n[lg]) end
    end
    return base, n
end

local function diaryNote(tr, before, after, book)
    local pole, lookupKey
    if after == 0 then
        pole, lookupKey = before > 0 and tr.pos or tr.neg, "fadeBack"
    elseif math.abs(after) > math.abs(before) or (after > 0) ~= (before > 0) then
        pole, lookupKey = after > 0 and tr.pos or tr.neg, math.abs(after)
    else
        return nil  -- weakened from 2 to 1: not worth noting
    end
    local list = Traits.bank().diary[pole]
    list = list and list[lookupKey]
    if not list or #list == 0 then return nil end
    local textValue = list[math.random(#list)]
    return (textValue:gsub("{book}", book or T"this book"))
end

--- Digests a page: moves the traits and returns the diary notes of whoever changed level.
function Traits.digest(s, signal, now, book)
    s.traits = s.traits or {}
    s.traits_level = s.traits_level or {}
    local hour = now and tonumber(os.date("%H", now))
    local tie, absent = Traits.push(signal, hour)
    local notes = {}
    for _, tr in ipairs(Traits.LIST) do
        local current = (s.traits[tr.id] or 0) * Traits.DECAY
        local v = limitTo(current + (tie[tr.id] or 0) * Traits.STEP, 100)
        -- page with nothing for this axis: the average discount only undoes excess (pulls towards neutral),
        -- never leads to the opposite pole
        if absent and absent[tr.id] then
            if current == 0 or (v > 0) ~= (current > 0) then v = 0
            elseif math.abs(v) > math.abs(current) then v = current end
        end
        -- a single book does not fix a strong trait: it only goes past STRONG if the trait was already striking, in the same
        -- direction, when this book started
        if math.abs(v) >= Traits.STRONG then
            local L = book and s.books and s.books[book]
            local ini = L and L.traits_start and L.traits_start[tr.id] or 0
            if math.abs(ini) < Traits.STRIKING or (ini > 0) ~= (v > 0) then
                v = (v > 0 and 1 or -1) * (Traits.STRONG - 0.1)
            end
        end
        s.traits[tr.id] = v
        local before = s.traits_level[tr.id] or 0
        local after = levelWithSlack(v, before)
        if after ~= before then
            s.traits_level[tr.id] = after
            local grade = diaryNote(tr, before, after, book)
            if grade then notes[#notes + 1] = grade end
        end
    end
    return notes
end

--- Striking poles, from strongest to weakest: { {pole, val}, ... }.
function Traits.strikings(traits)
    local list = {}
    for _, tr in ipairs(Traits.LIST) do
        local v = (traits or {})[tr.id] or 0
        if math.abs(v) >= Traits.STRIKING then list[#list + 1] = { v > 0 and tr.pos or tr.neg, math.abs(v) } end
    end
    table.sort(list, function(a, b) return a[2] > b[2] end)
    return list
end

--- Translated label of a pole ("BITTER", "NIGHT OWL"…).
function Traits.label(pole)
    return T(LABEL[pole] or pole)
end

--- Up to `max` labels of the striking traits ("BITTER", "NIGHT OWL"…), already translated.
function Traits.labels(traits, max)
    local out = {}
    for i, m in ipairs(Traits.strikings(traits)) do
        if i > (max or 2) then break end
        out[#out + 1] = Traits.label(m[1])
    end
    return out
end

--- A phrase in the way it ended up, or nil. The stronger the trait, the more it shows
-- (at most 4 in every 10 phrases). temperament: "young" or "old".
function Traits.speech(s, temperament, draw)
    draw = draw or math.random
    local strongOnes = Traits.strikings(s.traits)
    if #strongOnes == 0 then return nil end
    if draw(100) > math.min(40, strongOnes[1][2] * 0.6) then return nil end
    local sum = 0
    for _, f in ipairs(strongOnes) do sum = sum + f[2] end
    local target, acc, pole = draw(math.max(1, math.floor(sum))), 0, strongOnes[1][1]
    for _, f in ipairs(strongOnes) do
        acc = acc + f[2]
        if target <= acc then pole = f[1]; break end
    end
    local byPole = Traits.bank().speeches[pole]
    local list = byPole and byPole[temperament == "young" and "young" or "old"]
    if not list or #list == 0 then return nil end
    return list[draw(#list)]
end

return Traits
