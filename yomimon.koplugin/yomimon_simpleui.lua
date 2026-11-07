--[[--
Simple UI integration: a Yomimon card on the home screen and a quick-action button with its little face.
Uses Simple UI's public plugin API (moduleregistry and sui_quickactions); if Simple UI is not installed,
nothing happens.

]]

local Device = require("device")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local InputContainer = require("ui/widget/container/inputcontainer")
local TextBoxWidget = require("ui/widget/textboxwidget")
local UIManager = require("ui/uimanager")
local Blitbuffer = require("ffi/blitbuffer")
local logger = require("logger")
local Widget = require("ui/widget/widget")
local Screen = Device.screen

local Drawing = require("yomimon_drawing")
local T = require("yomimon_language").t
local State = require("yomimon_state")

local Integration = {}

local MODULE_ID = "yomimon_card"
local ACTION_ID = "yomimon_open"

--- SVG icon of the button: a ball, the same for every species (their sprite is downloaded, it does not ship with the plugin).
function Integration.iconName(plugin)
    return plugin.path .. "/icons/bola.svg"
end

-- Home screen card --------------------------------------------------------

-- Balloon text: its thought (the same phrases as the main screen). It stays the same until
-- it eats, sleeps/wakes or 20 minutes pass, so it does not change on every Home redraw.
local CHANGE_SECONDS = 20 * 60
local MAX_LINES = 2        -- the card's balloon is small: at most 2 lines
local ATTEMPTS = 12       -- how many phrases it draws looking for one that fits (12 since step 4 of the voice:
                            -- the phrases that match it are the variants, a bit longer)
local card_cache = {}

-- In how many lines the text wraps in this font and width (TextBoxWidget itself tells).
local function countLines(textValue, face, widthPx)
    local ok, n = pcall(function()
        local c = TextBoxWidget:new{ text = textValue, face = face, width = widthPx, alignment = "center" }
        local n = c.vertical_string_list and #c.vertical_string_list or math.huge
        c:free()
        return n
    end)
    return ok and n or math.huge
end

-- lines(textValue): how many lines the phrase takes in the balloon. Returns the text and the lines.
local function cardText(plugin, lines)
    local s, now = plugin.state, os.time()
    local e = State.expression(s, now)
    local mark = table.concat({ State.stage(s).nameText, tostring(e == "sleeping" or e == "cocoon"), s.pages or 0 }, ":")
    if card_cache.textValue and card_cache.mark == mark and now - card_cache.t < CHANGE_SECONDS then
        return card_cache.textValue, lines(card_cache.textValue)
    end
    local textValue, n = State.speechThatFits(s, now, lines, MAX_LINES, ATTEMPTS)
    card_cache.textValue, card_cache.mark, card_cache.t = textValue, mark, now
    return textValue, n
end

-- The UI font, like the other Simple UI widgets; the pixel font stays inside the Yomimon screens.
local function font(size_px)
    return Font:getFace("cfont", size_px / (Screen:scaleBySize(1000) / 1000))
end

-- Card: Yomimon on the left and a pixel balloon (tail pointing at it) on the right.
local Card = Widget:extend{ plugin = nil, widthPx = 0 }

function Card:init()
    self.u = math.max(2, math.floor(Screen:getWidth() / 618 * 3 + 0.5))   -- the balloon's "pixel" (3 Figma points)
    self.scale = math.max(2, math.floor(Screen:getHeight() * 0.16 / Drawing.HEIGHT))
    self.side = self.scale * Drawing.HEIGHT
    self.heightPx = self.side
end

function Card:getSize()
    return Geom:new{ w = self.widthPx, h = self.heightPx }
end

function Card:paintTo(bb, x, y)
    self.dimen = Geom:new{ x = x, y = y, w = self.widthPx, h = self.heightPx }
    local s, now = self.plugin.state, os.time()
    State.passTime(s, now)
    Drawing.paintSprite(bb, State.sprite(s, now), x, y, self.scale)

    local u, BLACK, WHITE = self.u, Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    local bx = x + self.side + 4 * u          -- start of the balloon (the tail comes before)
    local bw = math.floor((self.widthPx - (bx - x) - 2 * u) * 0.72)  -- does not take the whole width
    local bh = math.floor(self.heightPx * 0.62)
    local by = y + math.floor((self.heightPx - bh) / 2)
    local function r(rx, ry, rw, rh, color) bb:paintRect(rx, ry, rw, rh, color) end
    -- shadow, background and border with clipped corners
    r(bx + 3 * u, by + 2 * u, bw - 2 * u, bh, BLACK)
    r(bx + 2 * u, by + 3 * u, bw, bh - 2 * u, BLACK)
    r(bx + u, by + u, bw - 2 * u, bh - 2 * u, WHITE)
    r(bx + u, by, bw - 2 * u, u, BLACK)
    r(bx + u, by + bh - u, bw - 2 * u, u, BLACK)
    r(bx, by + u, u, bh - 2 * u, BLACK)
    r(bx + bw - u, by + u, u, bh - 2 * u, BLACK)
    -- tail pointing at Yomimon
    local ty = by + math.floor(bh / 2) - u
    r(bx, ty - u, u, 4 * u, WHITE)
    r(bx - u, ty - u, u, u, BLACK)
    r(bx - 2 * u, ty, u, u, BLACK)
    r(bx - 3 * u, ty + u, u, u, BLACK)
    r(bx - 2 * u, ty + 2 * u, u, u, BLACK)
    r(bx - u, ty + 2 * u, u, u, BLACK)
    r(bx - u, ty, u, 2 * u, WHITE)
    r(bx - 2 * u, ty + u, u, u, WHITE)
    -- text: its thought, centred in the balloon, in at most 2 lines (picks a phrase that fits;
    -- if none fits, a slightly smaller font and, last, "…")
    local pad = 4 * u
    local face, widthPx = font(5 * u), bw - 2 * pad
    local ok, textValue, n = pcall(cardText, self.plugin, function(t) return countLines(t, face, widthPx) end)
    if not ok then
        logger.warn("Yomimon: could not pick the card text:", textValue)
        textValue, n = "…", 1
    end
    if (n or 0) > MAX_LINES then
        local smaller = font(4 * u)
        if countLines(textValue, smaller, widthPx) <= MAX_LINES then face = smaller end
    end
    local box = TextBoxWidget:new{
        text = textValue,
        face = face,
        width = widthPx,
        height = bh - 2 * pad,
        height_overflow_show_ellipsis = true,
        alignment = "center",
    }
    local th = box:getSize().h
    box:paintTo(bb, bx + pad, by + math.max(pad, math.floor((bh - th) / 2)))
    box:free()
end

-- Protection: if the card fails to draw, the Home carries on (the card stays blank).
require("yomimon_guard").default:wrap(Card, { "paintTo" })

local function createModule(plugin)
    local M = {}
    M.id = MODULE_ID
    M.name = T"Yomimon"
    M.label = nil
    M.enabled_key = "yomimon_card_enabled"
    M.default_on = true

    function M.build(w, _ctx)
        local ok, card = pcall(function()
            local c = Card:new{ plugin = plugin, widthPx = w }
            local ic = InputContainer:new{ dimen = Geom:new{ w = w, h = c.heightPx }, c }
            ic.ges_events = {
                TapYomimon = { GestureRange:new{ ges = "tap", range = function() return c.dimen end } },
            }
            function ic:onTapYomimon()
                plugin:onShowYomimon()
                return true
            end
            return ic
        end)
        if not ok then
            logger.warn("Yomimon: could not build the Simple UI card:", card)
            return nil
        end
        return card
    end

    function M.getHeight(_ctx)
        return math.max(2, math.floor(Screen:getHeight() * 0.16 / Drawing.HEIGHT)) * Drawing.HEIGHT
    end

    function M.getMenuItems(_ctx_menu)
        return nil
    end

    return M
end

-- Registration ------------------------------------------------------------------------

function Integration.registrar(plugin)
    local ok_reg, Registry = pcall(require, "modules/moduleregistry")
    if ok_reg and type(Registry) == "table" and Registry.register then
        local ok, err = pcall(Registry.register, createModule(plugin))
        if not ok then logger.warn("Yomimon: could not register the Simple UI card:", err) end
    end

    -- The button uses a bigger Simple UI module; register after everything has loaded.
    UIManager:nextTick(function()
        local ok_qa, QA = pcall(require, "features/sui_quickactions")
        if not (ok_qa and type(QA) == "table" and QA.register) then return end
        local ok, err = pcall(QA.register, {
            id = ACTION_ID,
            label = T"Yomimon",
            icon = plugin.path .. "/icons/bola.svg",
            get_icon = function() return Integration.iconName(plugin) end,
            is_in_place = true,
            is_async_in_place = true,
            execute = function(_ctx) plugin:onShowYomimon() end,
        })
        if not ok then logger.warn("Yomimon: could not register the Simple UI button:", err) end
    end)
end

-- Yomimon in place of the Tiny Critter ---------------------------------------------------------
-- Simple UI's Tiny Critter accepts the user's critters in <settings>/simpleui/sui_critters/ (a loose PNG
-- serves every mood) and phrases in phrases.lua. Yomimon writes the sprite of its current form and its phrases
-- there and picks that critter: the balloon, the chat and the mood stay Simple UI's own.

local PHRASES_MARK = "-- yomimon"
local MOOD_OF_EXPRESSION = { happy = "happy", sad = "sad", sleeping = "sleepy", cocoon = "sleepy", normal = "neutral" }

local function crittersFolder()
    return require("datastorage"):getSettingsDir() .. "/simpleui/sui_critters"
end

-- The drawing goes out at its own pixel size, only cropped to where it is painted: Simple UI sizes a critter by
-- its image height, so the empty margin of the 64x64 grid made it look small. RGBA with a transparent
-- background, like the bundled critters, so night mode shows no white box.
local DEFAULT_CRITTER_HEIGHT = 40

local function screenHeight()
    local box = Screen:scaleBySize(104)
    local factor = math.max(1, math.floor(box / DEFAULT_CRITTER_HEIGHT))
    return math.min(math.floor(box / factor), require("yomimon_sprite").SIDE)
end

local function recordSprite(plugin, folder)
    local Sprite = require("yomimon_sprite")
    local lines = Drawing.sprite(State.stage(plugin.state).nameText)
    local x0, y0, w, h = Sprite.box(lines or {})
    if not x0 then return false end
    -- Simple UI derives the pixel factor it shares with the decorations from the image height, so every form
    -- goes out on a canvas of the height that gives the same factor as its 40px critters. Only taller forms
    -- are shrunk to fit it.
    local heightPx = screenHeight()
    local h2 = math.min(h, heightPx)
    local w2 = math.max(1, math.floor(w * h2 / h + 0.5))
    local top = heightPx - h2
    local bb = Blitbuffer.new(w2, heightPx, Blitbuffer.TYPE_BBRGB32)
    -- Light mode draws the alpha channel over black, so the background is opaque white there; night mode keeps it
    -- transparent because Simple UI undoes the screen inversion for the critter.
    local night = Screen.night_mode
    bb:fill(night and Blitbuffer.ColorRGB32(0, 0, 0, 0) or Blitbuffer.ColorRGB32(255, 255, 255, 255))
    for y = 0, h2 - 1 do
        local line = lines[y0 + math.floor(y * h / h2) + 1]
        for x = 0, w2 - 1 do
            local sx = x0 + math.floor(x * w / w2) + 1
            local g = Sprite.grey(line:sub(sx, sx))
            if g then bb:setPixel(x, top + y, Blitbuffer.ColorRGB32(g, g, g, 255)) end
        end
    end
    local path = folder .. "/yomimon.png"
    local ok, didRecord, err = pcall(bb.writePNG, bb, path)
    bb:free()
    if not (ok and didRecord ~= false) then
        -- A stale image of another size would make the critter look wrong, so remove it.
        os.remove(path)
        logger.warn("Yomimon: could not write the critter image:", ok and err or didRecord)
        return false
    end
    return true
end

-- Does not touch a phrases.lua the user wrote: only what Yomimon itself wrote.
local function recordPhrases(plugin, folder)
    local path = folder .. "/phrases.lua"
    local f = io.open(path, "rb")
    if f then
        local beginning = f:read(#PHRASES_MARK)
        f:close()
        if beginning ~= PHRASES_MARK then return false end
    end
    local s, now = plugin.state, os.time()
    local mood = MOOD_OF_EXPRESSION[State.expression(s, now)] or "neutral"
    local seenList, lines = {}, { PHRASES_MARK, "return {" }
    for _ = 1, 60 do
        local ok, textValue = pcall(State.speech, s, now, nil, nil, "yomimon")
        if ok and type(textValue) == "string" and not seenList[textValue] then
            seenList[textValue] = true
            lines[#lines + 1] = string.format("    { text = %q, mood = %q },", textValue, mood)
        end
    end
    lines[#lines + 1] = "}"
    local out = io.open(path, "wb")
    if not out then return false end
    out:write(table.concat(lines, "\n"), "\n")
    out:close()
    return true
end

--- Installs (or updates) Yomimon as a Simple UI critter and picks it. It only stops acting if the user turned the option off.
function Integration.syncCritter(plugin, force)
    if not force and G_reader_settings:isFalse("yomimon_critter") then return false end
    if not pcall(require, "modules/moduleregistry") then return false end
    local ok, err = pcall(function()
        local util = require("util")
        local folder = crittersFolder()
        util.makePath(folder)
        recordSprite(plugin, folder)
        recordPhrases(plugin, folder)
        local SUISettings = require("infra/sui_store")
        if force or not G_reader_settings:isTrue("yomimon_critter_chosen") then
            SUISettings:set("simpleui_critter_cfg_pick", "yomimon")
            G_reader_settings:saveSetting("yomimon_critter_chosen", true)
        end
        local engine = package.loaded["engines/sui_screen_engine"]
        if engine then engine.refreshAllLiveImmediate(false) end
    end)
    if not ok then logger.warn("Yomimon: could not install the Simple UI critter:", err) end
    return ok
end

return Integration
