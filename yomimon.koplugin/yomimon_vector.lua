--[[--
The book vector: each book described as a mix, not as a genre.

Dimensions, all taken from sums the memory already keeps per page (yomimon_memory.lua):
  themes      what the book has ABOVE the average page (yomimon_base_topics.lua)
  tone        average sentiment per page (weather dictionaries), compared with the average book
  dialogue    dialogue marks per page («, “, quotes, dash)
  events    happenings per page (death, travel, fight…)
  sentence      words per sentence
  theatre     lines with a character label per page (plays have ~8; novels, fewer than 3)
  first   narrated by an "I" (3.5% or more of the words; never in theatre)
tone, dialogue, events and sentence become "how many deviations above or below the average book"
(yomimon_base_books.lua, generated offline from the simulation corpus).

The compound name joins the strongest theme with up to two other things that stand out:
  "uma história de mar, sombria, com cheiro de bichos" · "a family drama, bright and talkative"
It goes into the diary review when it finishes the book.

Pure logic (no KOReader), testable outside it.
]]

local Language = require("yomimon_language")

local Vector = {}

Vector.MIN_PAGES = 20          -- before this the book has no name yet
Vector.THEATRE_SPEECHES = 4          -- labelled lines per page from which it is a play
Vector.FIRST_PERSON = 0.035   -- "I" per word from which it is narrated in the first person
Vector.LIMIT = { tone = 1.0, dialogue = 1.0, events = 1.2, sentence = 1.2 }  -- deviations to become an adjective
Vector.SECOND_THEME = 0.5        -- the 2nd theme enters if it has at least half of the 1st's prominence
Vector.MAX_EXTRAS = 2            -- besides the theme, at most two things in the name

local okBase, BASE = pcall(require, "yomimon_base_books")
Vector.BASE = okBase and type(BASE) == "table" and BASE or nil
local okTraits, BASE_THEMES = pcall(require, "yomimon_base_topics")
Vector.BASE_THEMES = okTraits and type(BASE_THEMES) == "table" and BASE_THEMES or nil

--- Raw counts of the book (per page), or nil without pages with text.
function Vector.raws(L)
    local P = L and L.text_pages or 0
    if P < 1 then return nil end
    local ev, spoke = 0, 0
    for _, c in pairs(L.events or {}) do ev = ev + c end
    for _, c in pairs(L.spoke or {}) do spoke = spoke + c end
    local N = L.narrator or {}
    return {
        language = (L.pages_pt or 0) * 2 > P and "pt" or "en",
        pages = P,
        weather = (L.weather or 0) / P,
        dialogue = (L.dialogue or 0) / P,
        events = ev / P,
        sentence = (L.words or 0) / math.max(1, L.sentences or 0),
        theatre = spoke / P >= Vector.THEATRE_SPEECHES,
        firstPersonCount = (N.words or 0) > 0 and (N.firstPersonCount or 0) / N.words or 0,
    }
end

local function deviations(val, base)
    if not base or (base.deviation or 0) <= 0 then return 0 end
    return (val - base.media) / base.deviation
end

--- The book's vector, or nil if it is still early (fewer than Vector.MIN_PAGES pages with text).
function Vector.de(L)
    local b = Vector.raws(L)
    if not b or b.pages < Vector.MIN_PAGES then return nil end
    local B = Vector.BASE or {}
    local v = {
        language = b.language, pages = b.pages, theatre = b.theatre,
        first = not b.theatre and b.firstPersonCount >= Vector.FIRST_PERSON,
        tone = deviations(b.weather, B.weather and B.weather[b.language]),
        dialogue = deviations(b.dialogue, B.dialogue),
        events = deviations(b.events, B.events),
        sentence = deviations(b.sentence, B.sentence),
        themes = {},
    }
    local media = Vector.BASE_THEMES and Vector.BASE_THEMES[b.language] or {}
    for t, c in pairs(L.themes or {}) do
        local above = c / b.pages - (media[t] or 0)
        if above > 0 then v.themes[#v.themes + 1] = { t, above } end
    end
    table.sort(v.themes, function(x, y) return x[2] > y[2] or (x[2] == y[2] and x[1] < y[1]) end)
    return v
end

--- Distance between two books (0 = equal, 2 = opposite): cosine over the above-average themes and,
-- with less weight, tone, dialogue and rhythm.
function Vector.distance(a, b)
    local function plan(v)
        local x = {}
        for _, p in ipairs(v.themes or {}) do x[p[1]] = p[2] end
        x._tone, x._dialogue, x._events = (v.tone or 0) * 0.1, (v.dialogue or 0) * 0.1, (v.events or 0) * 0.1
        return x
    end
    local xa, xb = plan(a), plan(b)
    local dot, na, nb = 0, 0, 0
    for k, va in pairs(xa) do na = na + va * va; dot = dot + va * (xb[k] or 0) end
    for _, vb in pairs(xb) do nb = nb + vb * vb end
    if na == 0 or nb == 0 then return 1 end
    return 1 - dot / math.sqrt(na * nb)
end

local banks = {}
local function bank()
    local c = Language.code()
    if banks[c] == nil then
        local ok, b = pcall(Language.data, "vector")
        banks[c] = ok and type(b) == "table" and b or false
    end
    return banks[c] or nil
end

--- The book's compound name in the current language, or nil.
function Vector.nameText(v)
    local B = bank()
    if not (B and v and v.themes[1]) then return nil end
    local t1 = v.themes[1][1]
    local head, gender
    if v.theatre then
        head, gender = string.format(B.play[1], B.short_theme[t1] or t1), B.play[2]
    else
        local n = B.names[t1]
        if not n then return nil end
        head, gender = n[1], n[2]
    end
    -- candidates, with the strength of each (deviations from the average book)
    local cand = {}
    local function adjective(dim, pos, neg)
        local z, limit = v[dim] or 0, Vector.LIMIT[dim]
        if z >= limit then cand[#cand + 1] = { kind = "adj", lookupKey = pos, strength = z }
        elseif z <= -limit then cand[#cand + 1] = { kind = "adj", lookupKey = neg, strength = -z } end
    end
    if not v.theatre then  -- in plays, without quotes and in verse, the dictionaries' tone and the dialogue do not apply
        adjective("tone", "bright", "gloomy")
        adjective("dialogue", "speaker", "quiet")
        if math.abs(v.sentence or 0) >= Vector.LIMIT.sentence then
            cand[#cand + 1] = { kind = "sentence", lookupKey = v.sentence > 0 and "long_ones" or "shorts", strength = math.abs(v.sentence) }
        end
        if v.first then cand[#cand + 1] = { kind = "first", strength = 1.5 } end
    end
    adjective("events", "restless", "still")
    local t2 = v.themes[2]
    if t2 and t2[2] >= v.themes[1][2] * Vector.SECOND_THEME and B.short_theme[t2[1]] then
        cand[#cand + 1] = { kind = "theme", lookupKey = t2[1], strength = 2 * t2[2] / v.themes[1][2] }
    end
    table.sort(cand, function(a, b) return a.strength > b.strength end)
    local adjs, remainder = {}, {}
    for i = 1, math.min(Vector.MAX_EXTRAS, #cand) do
        local c = cand[i]
        if c.kind == "adj" then adjs[#adjs + 1] = B.adjectives[c.lookupKey][gender] or B.adjectives[c.lookupKey].m
        elseif c.kind == "theme" then remainder[#remainder + 1] = { 1, string.format(B.smell, B.short_theme[c.lookupKey]) }
        elseif c.kind == "sentence" then remainder[#remainder + 1] = { 2, B.sentences[c.lookupKey] }
        elseif c.kind == "first" then remainder[#remainder + 1] = { 3, B.first[gender] or B.first.m } end
    end
    table.sort(remainder, function(a, b) return a[1] < b[1] end)
    local parts = { head }
    if #adjs == 1 then parts[#parts + 1] = adjs[1]
    elseif #adjs == 2 then parts[#parts + 1] = adjs[1] .. B.e .. adjs[2] end
    for _, r in ipairs(remainder) do parts[#parts + 1] = r[2] end
    return table.concat(parts, ", ")
end

return Vector
