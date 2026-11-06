--[[--
Card box: phrases written by you for the right moments (yomimon_locales/<code>/data/cards.lua).

When a chapter talks about a subject (yomimon_memory.lua, M.chapterCard), the first card that fits
is stored in s.pending_card. It becomes the next Home phrase for up to 24 hours (State.fala). If it does
not fit in the Home's 2 lines, it waits for the Yomimon screen (State.speechThatFits marks `did_not_fit`). When it says the
phrase, the card records what it has to record (s.gravado) and, if it is one-time, enters s.said_cards.
Both live its life: a fresh start begins without them.
]]

local Language = require("yomimon_language")

local Cards = {}

Cards.VALIDITY = 24 * 3600  -- how long the stored card waits to be said

local box
--- The cards in the current language (list, in the file's order).
function Cards.box()
    if box == nil then
        local ok, b = pcall(Language.data, "cards")
        box = ok and type(b) == "table" and b or false
    end
    return box or {}
end

--- Swaps the box (for tests); nil goes back to reading the file.
function Cards.useBox(b) box = b end

local function serve(s, c, subjects, data)
    local q = c.when or {}
    if c.turned_off or type(c.speech) ~= "string" or c.speech == "" then return false end
    if q.subject and not subjects[q.subject] then return false end
    if q.stage and data.stage ~= q.stage then return false end
    if q.stored and not (s.stored or {})[q.stored] then return false end
    if c.once and (s.said_cards or {})[c.id] then return false end
    return true
end

--- A chapter talked about `subjects` ({ pressagio = true, … }): stores the first card that fits.
-- dados: { personagem = name of who appears most in the chapter (or nil), fase = "jovem"… }. A card with
-- {personagem} without a character does not fit. While a stored card has not been said, no other enters.
-- Returns true if it stored one.
function Cards.chapter(s, subjects, data, now, book)
    local p = s.pending_card
    if p and not p.used and now - (p.t or 0) < Cards.VALIDITY then return false end
    for _, c in ipairs(Cards.box()) do
        if serve(s, c, subjects, data) then
            local textValue = c.speech
            if textValue:find("{character}", 1, true) then
                textValue = data.character and textValue:gsub("{character}", (data.character:gsub("%%", "%%%%"))) or nil
            end
            if textValue then
                local okV, Voice = pcall(require, "yomimon_voice")
                if okV then textValue = (Voice.resolver(textValue, s)) end
                s.pending_card = { id = c.id, textValue = textValue, t = now, book = book, records = c.records,
                                      once = c.once or nil }
                return true
            end
        end
    end
    return false
end

--- The stored card that can be said now on this screen, or nil: on the Home; on the Yomimon screen only after
-- not fitting on the Home.
function Cards.pending(s, now, screen)
    local p = s.pending_card
    if not p or p.used or now - (p.t or 0) >= Cards.VALIDITY then return nil end
    if screen == "home" or (screen == "yomimon" and p.did_not_fit) then return p end
    return nil
end

--- It said the stored card: records what it records and, if it is one-time, stores the id.
function Cards.said(s, p, now)
    p.used = true
    if p.records then
        s.stored = s.stored or {}
        s.stored[p.records] = s.stored[p.records] or now
    end
    if p.once then
        s.said_cards = s.said_cards or {}
        s.said_cards[p.id] = now
    end
end

return Cards
