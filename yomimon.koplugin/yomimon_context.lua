--[[--
Phrases with data from your reading: time, pages today, record, streak of days,
non-stop session, days away and what part of the book you are in.

Each trigger looks at the state (filled by State.eat) and, if it applies, offers phrases
with gaps: {hour} ("2h13" / "2:13 a.m."), {n} (pages or days), {book}, {pct}.
"Strong" triggers (small hours, record, marathon, vanishing) usually beat the other phrases.

Pure logic (no KOReader), testable outside it.
]]

local Language = require("yomimon_language")
local Voice = require("yomimon_voice")

local Context = {}

local READING_NOW = 30 * 60   -- read in the last 30 min: it is reading now

-- Phrases by trigger and temperament ("young" = nymph and young; "old" = adult and elder).
local SPEECHES = Language.content("context")

Language.append(SPEECHES, Language.extra("context"))  -- new batches of phrases

--- Hour for the phrases, formatted by the language ("2h13", "2:13 a.m.").
function Context.hour(now)
    return Language.format().clock(os.date("*t", now))
end

--- Triggers that apply now, each { nameText, n, strong }, the strong ones first.
function Context.triggers(s, now)
    local list = {}
    local function add(nameText, n, strong) list[#list + 1] = { nameText = nameText, n = n, strong = strong or false } end
    local hour = tonumber(os.date("%H", now))
    local today_day = os.date("%Y-%m-%d", now)
    local today = s.today == today_day and (s.pages_today or 0) or 0
    local since = s.last_meal and (now - s.last_meal)
    local reading = since and since < READING_NOW

    if reading and hour < 5 then add("small_hours", nil, true) end
    if s.record_at == today_day and today >= 10 and today >= (s.day_record or 0) then add("record", today, true)
    elseif today >= 40 then add("marathon", today, true) end
    if since and since >= 2 * 86400 then add("vanished", math.floor(since / 86400), true) end

    if reading and hour >= 22 then add("afternoon") end
    if reading and hour >= 5 and hour < 9 then add("early") end
    if reading and (s.session_pages or 0) >= 25 then add("session", s.session_pages) end
    if (s.sequence or 0) >= 3 and s.today == today_day then add("sequence", s.sequence) end
    if today >= 15 and today < 40 then add("good_morning", today) end
    if today == 0 and hour >= 19 and since and since >= 6 * 3600 and since < 2 * 86400 then add("nothing_today") end
    local pct = s.last_progress
    if pct and s.last_book and since and since < 86400 then
        if pct >= 0.9 and pct < 1 then add("final_stretch", math.floor(pct * 100))
        elseif pct >= 0.45 and pct <= 0.55 then add("half")
        elseif pct < 0.05 then add("start") end
    end
    local weekday = tonumber(os.date("%w", now))
    if (weekday == 0 or weekday == 6) and today >= 5 then add("weekend") end
    return list
end

--- A phrase with reading data, or nil. Also returns whether the trigger is strong.
-- temperament: "young" or "old". draw(n) returns an integer from 1 to n.
function Context.speech(s, now, temperament, draw)
    draw = draw or math.random
    local list = Context.triggers(s, now)
    if #list == 0 then return nil end
    local g = list[1].strong and list[1] or list[draw(#list)]
    local bank = SPEECHES[g.nameText] and SPEECHES[g.nameText][temperament]
    if not bank then return nil end
    local values = {
        hour = Context.hour(now), n = g.n and tostring(g.n),
        book = s.last_book, pct = g.n and (g.n .. "%"),
    }
    -- domain words ({taste}, {smell}…) are left to the voice resolver (yomimon_voice.lua)
    local textValue = Voice.pick(bank, s, draw):gsub("{(%a+)}", function(b)
        if values[b] then return values[b] end
        if Voice.SLOTS[b] then return nil end
        return b
    end)
    textValue = textValue:gsub("([ap]%.m%.)%.", "%1")  -- "It's 2:13 a.m.." → "It's 2:13 a.m."
    return textValue, g.strong
end

return Context
