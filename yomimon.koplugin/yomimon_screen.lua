--[[--
Yomimon screen, drawn as in Figma ("Yomimon Agent Sprites", 618x824).

Everything is painted straight on the screen in Figma coordinates multiplied by K
(on the Paperwhite 1236x1648, K = 2). The font is Silkscreen (OFL), in fonts/.

Taps: on the creature = pet it; hold on the creature = menu (sleep screen,
language); on the X = close.
]]

local Blitbuffer = require("ffi/blitbuffer")
local ButtonDialog = require("ui/widget/buttondialog")
local Device = require("device")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local InputContainer = require("ui/widget/container/inputcontainer")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local Screen = Device.screen

local Drawing = require("yomimon_drawing")
local T = require("yomimon_language").t
local State = require("yomimon_state")
local Memory = require("yomimon_memory")
local Traits = require("yomimon_traits")

local FRAME_SECONDS = 1.2      -- time between animation frames
local ANIMATION_MINUTES = 5       -- the normal animation stops by itself after this

local FRAME_W, FRAME_H = 618, 824       -- size of the Figma frame

local BLACK = Blitbuffer.COLOR_BLACK
local WHITE = Blitbuffer.COLOR_WHITE
local GREY_55 = Blitbuffer.Color8(0x55)
local GREY_BB = Blitbuffer.Color8(0xBB)

-- Icons of the status card, in Figma points (x, y, width, height), relative to the card.
local ICON_BOOK = {
    { 17, 17, 12, 3 }, { 35, 17, 12, 3 }, { 14, 20, 3, 3 }, { 29, 20, 6, 3 }, { 47, 20, 3, 3 },
    { 14, 23, 3, 3 }, { 29, 23, 6, 3 }, { 47, 23, 3, 3 }, { 14, 26, 3, 3 }, { 29, 26, 6, 3 },
    { 47, 26, 3, 3 }, { 14, 29, 3, 3 }, { 29, 29, 6, 3 }, { 47, 29, 3, 3 }, { 14, 32, 12, 3 },
    { 29, 32, 6, 3 }, { 38, 32, 12, 3 }, { 26, 35, 12, 3 },
}
local ICON_FACE = {
    { 25, 62, 15, 3 }, { 22, 65, 3, 3 }, { 40, 65, 3, 3 }, { 19, 68, 3, 3 }, { 43, 68, 3, 3 },
    { 19, 71, 3, 3 }, { 25, 71, 6, 3 }, { 34, 71, 6, 3 }, { 43, 71, 3, 3 }, { 19, 74, 3, 3 },
    { 43, 74, 3, 3 }, { 19, 77, 3, 3 }, { 28, 77, 9, 3 }, { 43, 77, 3, 3 }, { 19, 80, 3, 3 },
    { 25, 80, 3, 3 }, { 37, 80, 3, 3 }, { 43, 80, 3, 3 }, { 22, 83, 3, 3 }, { 40, 83, 3, 3 },
    { 25, 86, 15, 3 },
}

-- Hourglass of the stage card (relative to the card).
local ICON_HOURGLASS = {
    { 14, 79, 10, 2 }, { 14, 81, 2, 2 }, { 22, 81, 2, 2 }, { 16, 83, 2, 2 }, { 20, 83, 2, 2 },
    { 18, 85, 2, 2 }, { 16, 87, 2, 2 }, { 20, 87, 2, 2 }, { 14, 89, 2, 2 }, { 18, 89, 2, 2 },
    { 22, 89, 2, 2 }, { 14, 91, 10, 2 },
}

local YomimonScreen = InputContainer:extend{
    plugin = nil,    -- plugin instance
    message = nil, -- special phrase (e.g. the answer to a pet)
}

function YomimonScreen:init()
    if Device:hasKeys() then
        self.key_events.Close = { { Device.input.group.Back } }
    end
    if Device:isTouchDevice() then
        self.ges_events.Tap = { GestureRange:new{ ges = "tap", range = function() return self.dimen end } }
        self.ges_events.Hold = { GestureRange:new{ ges = "hold", range = function() return self.dimen end } }
    end
    self.covers_fullscreen = true
    local size = Screen:getSize()
    self.dimen = Geom:new{ x = 0, y = 0, w = size.w, h = size.h }
    -- Figma-to-screen scale, and margin to centre when the proportion does not match
    self.k = math.min(size.w / FRAME_W, size.h / FRAME_H)
    self.ox = math.floor((size.w - FRAME_W * self.k) / 2)
    self.oy = math.floor((size.h - FRAME_H * self.k) / 2)
    -- factor KOReader applies to font sizes; compensated in face()
    self.font_factor = Screen:scaleBySize(1000) / 1000
    self.faces = {}
    self.tick = function() self:nextFrame() end
    self:prepareSprite()
    self:startAnimation()
end

-- Drawing utilities ---------------------------------------------------------

function YomimonScreen:px(v)
    return math.floor(v * self.k + 0.5)
end

--- Silkscreen face with height `tam` in Figma points.
function YomimonScreen:face(bold, size)
    local lookupKey = (bold and "b" or "r") .. size
    if not self.faces[lookupKey] then
        local file_path = bold and "Silkscreen-Bold.ttf" or "Silkscreen-Regular.ttf"
        local path = Drawing.fontPath(file_path)
        local ok, f = pcall(Font.getFace, Font, path, size * self.k / self.font_factor)
        if not ok or not f then f = Font:getFace("cfont", size * self.k / self.font_factor) end
        self.faces[lookupKey] = f
    end
    return self.faces[lookupKey]
end

function YomimonScreen:ret(bb, x, y, w, h, color)
    local x0, y0 = self.ox + self:px(x), self.oy + self:px(y)
    local x1, y1 = self.ox + self:px(x + w), self.oy + self:px(y + h)
    if x1 > x0 and y1 > y0 then bb:paintRect(x0, y0, x1 - x0, y1 - y0, color) end
end

function YomimonScreen:rectangles(bb, list, dx, dy, color)
    for _, r in ipairs(list) do self:ret(bb, dx + r[1], dy + r[2], r[3], r[4], color) end
end

--- Text in the pixel font. Returns the width in Figma points.
function YomimonScreen:textValue(bb, str, x, y, bold, size, color, center_x)
    local w = TextWidget:new{ text = str, face = self:face(bold, size), fgcolor = color or BLACK, padding = 0 }
    local tw = w:getSize().w
    local px_x = center_x and (self.ox + self:px(center_x) - math.floor(tw / 2)) or (self.ox + self:px(x))
    w:paintTo(bb, px_x, self.oy + self:px(y))
    w:free()
    return tw / self.k
end

--- Width of a text in Figma points, without painting.
function YomimonScreen:textWidth(str, bold, size)
    local w = TextWidget:new{ text = str, face = self:face(bold, size), padding = 0 }
    local tw = w:getSize().w
    w:free()
    return tw / self.k
end

--- Text with the letters closer together (kerning reduced by `tightness` points per letter).
-- Pairs that need extra adjustment, in Silkscreen pixels (1/8 of the font size).
-- LV: the L is empty on the top right and the V thins at the bottom; without adjustment the gap is doubled.
local KERNING = { LV = 1 }

function YomimonScreen:tightText(bb, str, x, y, bold, size, tightness)
    local cx, previous = x, nil
    for letter in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if previous then cx = cx - (KERNING[previous .. letter] or 0) * size / 8 end
        cx = cx + self:textValue(bb, letter, cx, y, bold, size) - tightness
        previous = letter
    end
end

--- Box with clipped corners (border of 3), white background and offset shadow (as in Figma).
function YomimonScreen:card(bb, x, y, w, h, shadow)
    if shadow then
        self:ret(bb, x + 9, y + 6, w - 6, h, BLACK)
        self:ret(bb, x + 6, y + 9, w, h - 6, BLACK)
    end
    self:ret(bb, x + 3, y + 3, w - 6, h - 6, WHITE)
    self:ret(bb, x + 3, y, w - 6, 3, BLACK)
    self:ret(bb, x + 3, y + h - 3, w - 6, 3, BLACK)
    self:ret(bb, x, y + 3, 3, h - 6, BLACK)
    self:ret(bb, x + w - 3, y + 3, 3, h - 6, BLACK)
end

function YomimonScreen:dots(bb, x, y, full_dots)
    for i = 0, 3 do
        local bx = x + 32 * i
        if i < full_dots then
            self:ret(bb, bx + 3, y, 20, 26, BLACK)
            self:ret(bb, bx, y + 3, 26, 20, BLACK)
            self:ret(bb, bx + 6, y + 6, 3, 3, WHITE)
        else
            self:ret(bb, bx + 3, y, 20, 3, GREY_BB)
            self:ret(bb, bx + 3, y + 23, 20, 3, GREY_BB)
            self:ret(bb, bx, y + 3, 3, 20, GREY_BB)
            self:ret(bb, bx + 23, y + 3, 3, 20, GREY_BB)
        end
    end
end

local function capitals(s)
    local ok, Utf8Proc = pcall(require, "ffi/utf8proc")
    if ok and Utf8Proc and Utf8Proc.uppercase then
        local okUpper, r = pcall(Utf8Proc.uppercase, s)
        if okUpper and r then return r end
    end
    return s:upper()
end

-- Parts of the screen ----------------------------------------------------------------

--- Speech balloon (Figma 28:5911): border of 3, pixel shadow on the right and below,
-- tail in the middle. Text in Silkscreen Regular with 16 of padding on top and bottom;
-- the height grows with the number of lines.
--- Measures the balloon: width W (454, or 560 for phrases of 3+ lines), height H and the text box.
function YomimonScreen:measureBalloon(speech)
    local function boxFor(W)
        return TextBoxWidget:new{
            text = capitals(speech), face = self:face(false, 20.88),
            width = self:px(W - 47), alignment = "center",
        }
    end
    local line = TextWidget:new{ text = "A", face = self:face(false, 20.88) }
    local lh = line:getSize().h / self.k
    line:free()
    local W = 454
    local box = boxFor(W)
    if box:getSize().h / self.k > lh * 2.5 then  -- 3 lines or more: widen
        box:free()
        W = 560
        box = boxFor(W)
    end
    local th = box:getSize().h / self.k
    return { W = W, H = th + 35, box = box }
end

--- Main balloon (Figma 28:5911): border of 3, pixel shadow, tail in the middle at the bottom.
-- top: y of the balloon; without it, the tail tip is at y = 234. m: measure already done (optional).
function YomimonScreen:balloon(bb, speech, bx, top, m)
    m = m or self:measureBalloon(speech)
    local W, H = m.W, m.H
    bx = bx or ((FRAME_W - (W + 6)) / 2)        -- centred counting the shadow of 6
    local by = top or (234 - (H + 15))
    local t = math.floor(W / 2) - 7          -- start of the tail
    local function r(x, y, w, h, color) self:ret(bb, bx + x, by + y, w, h, color) end
    r(3, 3, W - 6, H - 3, WHITE)            -- background
    r(6, 0, W - 12, 3, BLACK)                -- top
    r(3, 3, 3, 3, BLACK); r(W - 6, 3, 3, 3, BLACK)
    r(0, 6, 3, H - 9, BLACK)                 -- left side
    r(3, H - 3, 3, 3, BLACK)
    r(W - 3, 6, 3, H - 3, BLACK)             -- right side
    r(W - 6, H - 3, 3, 6, BLACK)
    r(W, 9, 3, H - 3, BLACK)                 -- shadow on the right
    r(W + 3, 12, 3, H - 6, BLACK)
    r(6, H, W - 12, 3, BLACK)                -- base
    r(9, H + 3, W - 9, 3, BLACK)             -- shadow below
    r(12, H + 6, W - 9, 3, BLACK)
    r(t, H + 6, 3, 3, BLACK)                 -- tail
    r(t + 4, H + 9, 9, 3, BLACK); r(t + 7, H + 12, 3, 3, BLACK)
    r(t + 1, H, 15, 3, WHITE); r(t + 4, H + 3, 9, 3, WHITE); r(t + 7, H + 6, 3, 3, WHITE)
    m.box:paintTo(bb, self.ox + self:px(bx + 28), self.oy + self:px(by + 19))
    m.box:free()
end

function YomimonScreen:prepareSprite()
    -- The sprite (64x64) takes ~295 points in Figma, centred at (309.5, 412.5);
    -- integer scale so the pixels stay sharp.
    local scale = math.max(1, math.floor(295 * self.k / Drawing.WIDTH))
    local side = scale * Drawing.WIDTH
    self.sprite_scale = scale
    self.sprite_rect = Geom:new{
        x = self.ox + self:px(309.5) - math.floor(side / 2),
        y = self.oy + self:px(412.5) - math.floor(side / 2),
        w = side, h = side,
    }
    self.close_rect = Geom:new{
        x = self.ox + self:px(545), y = self.oy + self:px(6), w = self:px(70), h = self:px(64),
    }
end

function YomimonScreen:paintTo(bb, x, y)
    self.dimen.x, self.dimen.y = x, y
    local s, now = self.plugin.state, os.time()
    bb:paintRect(x, y, self.dimen.w, self.dimen.h, WHITE)
    self.targets = {}
    self:header(bb)
    if self.mode == "notebook" then
        self:paintNotebook(bb, s)
    elseif self.mode == "diary" then
        self:paintDiary(bb, s)
    elseif self.mode == "achievements" then
        self:paintAchievements(bb, s)
    elseif self.mode == "pokedex" then
        self:paintPokedex(bb, s)
    elseif self.mode == "perception" then
        self:paintPerception(bb, s)
    else
        self:paintHome(bb, s, now)
    end
    if self.menu_open then self:paintMenu(bb) end
end

--- Tappable area, in Figma points.
function YomimonScreen:target(x, y, w, h, action)
    table.insert(self.targets, {
        rect = Geom:new{ x = self.ox + self:px(x), y = self.oy + self:px(y), w = self:px(w), h = self:px(h) },
        action = action,
        layer = self.layer,
    })
end

local TITLES = { notebook = T"NOTEBOOK", diary = T"DIARY", achievements = T"ACHIEVEMENTS", pokedex = T"POKÉDEX",
                  perception = T"PERCEPTION" }

function YomimonScreen:header(bb)
    self.layer = "top"
    local titleText = TITLES[self.mode]
    if titleText then
        self:textValue(bb, titleText, 20, 18, true, 30)
    else
        self:tightText(bb, T"YOMIMON", 20, 10, true, 44, 6)
    end
    if self.plugin.state.dev_simulation and not self.exporting then self:textValue(bb, T"SIMULATION", 20, 56, false, 10, GREY_55) end
    -- ARCHIVE button with a pixel arrow
    self:card(bb, 403, 16, 140, 39, true)
    self:textValue(bb, T"ARCHIVE", 417, 25, true, 14)
    self:ret(bb, 517, 31, 12, 3, BLACK)
    self:ret(bb, 520, 34, 6, 3, BLACK)
    self:ret(bb, 522, 37, 2, 3, BLACK)
    self:target(398, 6, 152, 60, function() self.menu_open = not self.menu_open end)
    -- close
    self:card(bb, 555, 16, 42, 39, true)
    self:textValue(bb, "X", 0, 12, true, 32, BLACK, 576)
    self:target(550, 6, 64, 60, function() self:onClose(); return "closed" end)
    self.layer = "content"
end

-- ARCHIVE menu ------------------------------------------------------------------

local MENU_ITEMS = {
    { "home", T"YOMIMON", T"YOUR CURRENT POKÉMON" },
    { "notebook", T"NOTEBOOK", T"THE PASSAGES YOU MARKED" },
    { "diary", T"DIARY", T"WHAT IT REMEMBERS OF YOUR READING" },
    { "achievements", T"ACHIEVEMENTS", T"MILESTONES AND BOOKS READ" },
    { "pokedex", T"POKÉDEX", T"YOUR REGISTERED POKÉMON" },
    { "language", T"LANGUAGE", T"CHANGE THE LANGUAGE" },
}

function YomimonScreen:paintMenu(bb)
    self.layer = "menu"
    local x, y, w = 263, 66, 334
    local h = 14 + #MENU_ITEMS * 48 + 6
    self:card(bb, x, y, w, h, true)
    local iy = y + 12
    for _, item in ipairs(MENU_ITEMS) do
        local current = (self.mode or "home") == item[1]
        if current then
            self:ret(bb, x + 12, iy + 4, 6, 6, BLACK)
            self:ret(bb, x + 12, iy + 10, 6, 6, BLACK)
            self:ret(bb, x + 18, iy + 7, 6, 6, BLACK)
        end
        self:textValue(bb, item[2], x + 34, iy, true, 16)
        self:textValue(bb, item[3], x + 34, iy + 21, false, 10, GREY_55)
        local mode = item[1]
        self:target(x, iy - 6, w, 48, function()
            self.menu_open = false
            if mode == "language" then return self:languageMenu() end
            self:enter(mode)
        end)
        iy = iy + 48
    end
end

function YomimonScreen:enter(mode)
    self.mode = mode ~= "home" and mode or nil
    self.pg = 1
    self.message = nil
    if mode == "notebook" then
        self:loadHighlights()
    elseif mode == "achievements" then
        local s = self.plugin.state
        self.finishedList = s.dev_simulation and s.sim_finished or YomimonScreen.finishedBooks()
        local n = 0
        for _, L in ipairs(s.dev_simulation and s.sim_highlights or YomimonScreen.readHighlights()) do n = n + #L.items end
        self.n_highlights = n
    end
    self:refresh()
end

-- Home screen ------------------------------------------------------------------

function YomimonScreen:paintHome(bb, s, now)
    -- balloon with the phrase (drawn once per opening, so it does not change on every redraw)
    if not self.speech then self.speech = State.speech(s, now, nil, nil, "yomimon") end
    -- Yomimon always stays at Figma's spot; the balloon grows upwards (and widens for long
    -- phrases), never going past the header
    -- the tail sits right above the drawing's real head (small stages: the balloon comes down)
    local m = self:measureBalloon(self.message or self.speech)
    local nameText = self.current_frame or State.sprite(s, now)
    local head = (self.sprite_rect.y - self.oy) / self.k + Drawing.realTop(nameText) * self.sprite_scale / self.k
    local tip = head - 30
    local top = math.max(70, tip - (m.H + 15))
    self:balloon(bb, self.message or self.speech, nil, top, m)

    -- Yomimon
    local r = self.sprite_rect
    Drawing.paintSprite(bb, self.current_frame or State.sprite(s, now), r.x, r.y, self.sprite_scale)

    self:statusCards(bb, s, now)
end

-- Page navigation (notebook and diary) -------------------------------------

function YomimonScreen:navigation(bb, total)
    if total <= 1 then return end
    self.pg = math.max(1, math.min(self.pg or 1, total))
    self:card(bb, 20, 744, 84, 50, true)
    self:textValue(bb, "<", 0, 750, true, 28, BLACK, 62)
    self:card(bb, 514, 744, 84, 50, true)
    self:textValue(bb, ">", 0, 750, true, 28, BLACK, 556)
    self:textValue(bb, string.format("%d / %d", self.pg, total), 0, 760, false, 14, GREY_55, 309)
    self:target(14, 738, 100, 64, function() self.pg = math.max(1, self.pg - 1) end)
    self:target(508, 738, 100, 64, function() self.pg = math.min(total, self.pg + 1) end)
end

--- Balloon with the tail on the left (Figma 37:7072): same border and shadow as the
-- main balloon; the height grows with the text and the balloon is centred on `center_y`.
function YomimonScreen:sideBalloon(bb, textValue, bx, W, center_y, size)
    local box = TextBoxWidget:new{
        text = capitals(textValue), face = self:face(false, size or 13), width = self:px(W - 56),
    }
    local th = box:getSize().h / self.k
    local H = th + 35
    local by = center_y - H / 2
    local function r(x, y, w, h, color) self:ret(bb, bx + x, by + y, w, h, color) end
    r(3, 3, W - 6, H - 3, WHITE)                         -- background
    r(6, 0, W - 12, 3, BLACK)                             -- top
    r(3, 3, 3, 3, BLACK); r(W - 6, 3, 3, 3, BLACK)
    r(0, 6, 3, H - 9, BLACK)                              -- left side
    r(3, H - 3, 3, 3, BLACK)
    r(W - 3, 6, 3, H - 3, BLACK)                          -- right side
    r(W - 6, H - 3, 3, 6, BLACK)
    r(W, 9, 3, H - 3, BLACK); r(W + 3, 12, 3, H - 6, BLACK)          -- shadow on the right
    r(6, H, W - 12, 3, BLACK)                                         -- base
    r(9, H + 3, W - 9, 3, BLACK); r(12, H + 6, W - 9, 3, BLACK)      -- shadow below
    -- tail on the left, at mid height
    local ty = math.floor(H / 2) - 1
    r(0, ty - 6, 3, 15, WHITE)
    r(-3, ty - 3, 3, 9, WHITE); r(-6, ty, 3, 3, WHITE)
    r(-3, ty - 6, 3, 3, BLACK); r(-6, ty - 3, 3, 3, BLACK); r(-9, ty, 3, 3, BLACK)
    r(-6, ty + 3, 3, 3, BLACK); r(-3, ty + 6, 3, 3, BLACK)
    box:paintTo(bb, self.ox + self:px(bx + 28), self.oy + self:px(by + 19))
    box:free()
end

--- Yomimon's little face with a balloon beside it (used in the archive screens).
function YomimonScreen:footerSpeech(bb, s, textValue, y)
    local scale = math.max(1, math.floor(110 * self.k / Drawing.WIDTH))
    Drawing.paintSprite(bb, State.stage(s).nameText, self.ox + self:px(14), self.oy + self:px(y), scale)
    local side = scale * Drawing.WIDTH / self.k
    self:sideBalloon(bb, textValue, 14 + side + 16, FRAME_W - (14 + side + 16) - 20, y + side / 2)
end

-- Notebook: KOReader's highlights and notes, organised by book ---------------

function YomimonScreen:loadHighlights()
    local s = self.plugin.state
    self.notebook = s.dev_simulation and s.sim_highlights or YomimonScreen.readHighlights()
    self.open_book = nil
end

--- KOReader's highlights and notes, grouped by book (most recent first).
function YomimonScreen.readHighlights()
    local books = {}
    pcall(function()
        local ReadHistory = require("readhistory")
        local DocSettings = require("docsettings")
        for i, item in ipairs(ReadHistory.hist or {}) do
            if i > 80 then break end
            if item.file and DocSettings:hasSidecarFile(item.file) then
                local ds = DocSettings:open(item.file)
                local props = ds:readSetting("doc_props") or {}
                local titleText = props.display_title or props.title or item.text or "?"
                local items = {}
                for _, a in ipairs(ds:readSetting("annotations") or {}) do
                    if a.text and a.text ~= "" and (a.drawer or a.note) then
                        items[#items + 1] = { textValue = a.text, grade = a.note, chapter = a.chapter, data = a.datetime or "" }
                    end
                end
                if #items > 0 then
                    table.sort(items, function(a, b) return a.data < b.data end)
                    books[#books + 1] = { book = titleText, author = props.authors, items = items, recent = items[#items].data }
                end
            end
        end
    end)
    table.sort(books, function(a, b) return a.recent > b.recent end)
    return books
end

function YomimonScreen:paintNotebook(bb, s)
    local books = self.notebook or {}
    if #books == 0 then
        self:footerSpeech(bb, s, T"No highlights. Either you don't read or you don't feel. Hold your finger on a sentence and highlight it.", 380)
        return
    end
    if self.open_book then return self:paintHighlight(bb, s, books[self.open_book]) end

    -- shelf: 2 columns x 3 rows of little boxes
    local per_page = 6
    local total = math.ceil(#books / per_page)
    self.pg = math.max(1, math.min(self.pg or 1, total))
    for k = 0, per_page - 1 do
        local idx = (self.pg - 1) * per_page + k + 1
        local L = books[idx]
        if not L then break end
        local x = 20 + (k % 2) * 299
        local y = 92 + math.floor(k / 2) * 208
        self:card(bb, x, y, 279, 188, true)
        self:ret(bb, x + 16, y + 16, 6, 30, BLACK)  -- spine in pixels
        self:ret(bb, x + 22, y + 16, 3, 30, GREY_BB)
        local titleText = TextBoxWidget:new{
            text = capitals(L.book), face = self:face(true, 14), width = self:px(220),
            height = self:px(90), height_overflow_show_ellipsis = true,
        }
        titleText:paintTo(bb, self.ox + self:px(x + 38), self.oy + self:px(y + 16))
        titleText:free()
        if L.author then
            local author = TextBoxWidget:new{
                text = capitals(L.author:gsub("\n.*", "")), face = self:face(false, 10), fgcolor = GREY_55,
                width = self:px(220), height = self:px(28), height_overflow_show_ellipsis = true,
            }
            author:paintTo(bb, self.ox + self:px(x + 38), self.oy + self:px(y + 112))
            author:free()
        end
        local n = #L.items
        self:textValue(bb, string.format("%d %s", n, n == 1 and T"HIGHLIGHT" or T"HIGHLIGHTS"), x + 16, y + 154, true, 11, GREY_55)
        self:target(x, y, 279, 188, function()
            self.open_book = idx
            self.shelf_page = self.pg
            self.pg = 1
        end)
    end
    self:navigation(bb, total)
end

function YomimonScreen:paintHighlight(bb, s, L)
    -- back to the shelf
    self:card(bb, 20, 82, 150, 38, true)
    self:textValue(bb, T"< BOOKS", 0, 92, true, 13, BLACK, 95)
    self:target(14, 76, 162, 50, function()
        self.open_book = nil
        self.pg = self.shelf_page or 1
    end)
    local book = TextBoxWidget:new{
        text = capitals(L.book), face = self:face(true, 12), fgcolor = GREY_55, width = self:px(410),
        height = self:px(16), height_overflow_show_ellipsis = true,
    }
    book:paintTo(bb, self.ox + self:px(188), self.oy + self:px(94))
    book:free()

    local total = #L.items
    self.pg = math.max(1, math.min(self.pg or 1, total))
    local item = L.items[self.pg]
    self:card(bb, 20, 136, 578, 392, true)
    self:ret(bb, 44, 154, 18, 6, BLACK)  -- quotation marks in pixels
    self:ret(bb, 44, 160, 6, 12, BLACK)
    self:ret(bb, 68, 154, 18, 6, BLACK)
    self:ret(bb, 68, 160, 6, 12, BLACK)
    local body = TextBoxWidget:new{
        text = item.textValue, face = self:face(false, 16), width = self:px(526),
        height = self:px(290), height_overflow_show_ellipsis = true,
    }
    body:paintTo(bb, self.ox + self:px(44), self.oy + self:px(184))
    body:free()
    if item.chapter then
        local cap = TextBoxWidget:new{
            text = "— " .. capitals(item.chapter), face = self:face(false, 11), fgcolor = GREY_55,
            width = self:px(526), height = self:px(16), height_overflow_show_ellipsis = true,
        }
        cap:paintTo(bb, self.ox + self:px(44), self.oy + self:px(494))
        cap:free()
    end

    -- comment with context
    local chapter_count = 0
    for _, it in ipairs(L.items) do if it.chapter and it.chapter == item.chapter then chapter_count = chapter_count + 1 end end
    local chars = Memory.characters(s, L.book, 10)
    local comment = Memory.contextComment(item, {
        s = s, temperament = State.stage(s).temperament, book = L.book, characters = chars,
        order = self.pg, total = total, in_chapter = chapter_count,
    })
    self:footerSpeech(bb, s, comment, 560)
    self:navigation(bb, total)
end

-- Diary: memories and what the books did to it --------------------------------

local MONTHS = {}
for m in T"JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC":gmatch("%S+") do MONTHS[#MONTHS + 1] = m end

function YomimonScreen:paintDiary(bb, s)
    local y = 88
    -- summarised "inner library": who it became
    local a, b = Memory.ambivalent(s)
    local summary
    if a then
        summary = string.format(T"TORN BETWEEN %s AND %s", capitals(Memory.THEME_NAMES[a]), capitals(Memory.THEME_NAMES[b]))
    elseif s.dominant_theme then
        summary = string.format(T"OBSESSED WITH %s", capitals(Memory.theme(s.dominant_theme, "por")))
    end
    -- the way it ended up with your readings (up to 2 traits; 1 when it is already divided)
    local manner = Traits.labels(s.traits, a and 1 or 2)
    if #manner > 0 then summary = (summary and (summary .. " · ") or "") .. table.concat(manner, " · ") end
    summary = summary or T"NO OPINIONS YET. READ MORE."
    self:textValue(bb, summary, 20, y, true, 12, GREY_55)
    y = y + 26

    local entries = {}
    for i = #(s.diary or {}), 1, -1 do entries[#entries + 1] = s.diary[i] end
    if #entries == 0 then
        self:footerSpeech(bb, s, T"My diary is empty. Like your bookshelf.", 380)
        return
    end
    local per_page = 5
    local total = math.ceil(#entries / per_page)
    self.pg = math.max(1, math.min(self.pg or 1, total))
    for i = (self.pg - 1) * per_page + 1, math.min(#entries, self.pg * per_page) do
        local e = entries[i]
        local d = os.date("*t", e.t)
        self:textValue(bb, string.format("%02d %s", d.day, MONTHS[d.month]), 20, y, true, 12)
        local box = TextBoxWidget:new{
            text = capitals(e.textValue), face = self:face(false, 13), width = self:px(500),
            height = self:px(72), height_overflow_show_ellipsis = true,
        }
        local hh = box:getSize().h / self.k
        box:paintTo(bb, self.ox + self:px(96), self.oy + self:px(y))
        box:free()
        y = y + math.max(22, hh) + 14
        self:ret(bb, 20, y - 8, 578, 3, GREY_BB)
        y = y + 6
    end
    self:navigation(bb, total)
end

--- Belly/mood and stage cards (footer of the main screen).
function YomimonScreen:statusCards(bb, s, now)
    -- status card: belly and mood
    -- the two cards (380 + 20 of space + 174, plus 6 of shadow) centred on the screen
    local cx, cy = (FRAME_W - 580) / 2, 696
    self:card(bb, cx, cy, 380, 104, true)
    self:rectangles(bb, ICON_BOOK, cx, cy, BLACK)
    self:rectangles(bb, ICON_FACE, cx, cy, BLACK)
    self:textValue(bb, T"BELLY", cx + 62, cy + 12, true, 16)
    local today = State.pagesToday(s, now)
    self:textValue(bb, string.format(T"%s · %d PG TODAY", State.bellyLabel(s), today), cx + 62, cy + 33, false, 10, GREY_55)
    self:textValue(bb, T"MOOD", cx + 62, cy + 58, true, 16)
    self:textValue(bb, State.moodLabel(s), cx + 62, cy + 79, false, 10, GREY_55)
    self:dots(bb, cx + 244, cy + 16, State.dots(s.belly))
    self:dots(bb, cx + 244, cy + 62, State.dots(s.mood))

    -- form card: name, pages left for the next form and the bar up to it
    local ix, iy, wid = cx + 400, 696, 146
    self:card(bb, ix, iy, 174, 104, true)
    local pf = State.stageProgress(s)
    self:textValue(bb, capitals(pf.stage.titleText), ix + 14, iy + 8, true, 16)
    local target = pf.nextForm and capitals(pf.nextForm.titleText) or T"FINAL FORM"
    local line1 = pf.nextForm and (pf.pages == 1 and T"PAGE TO" or T"PAGES TO") or T"REACHED"
    local label = math.max(self:textWidth(line1, false, 10), self:textWidth(target, true, 10))
    local num = pf.nextForm and Drawing.thousands(pf.pages) or "OK"
    local size_num = 28
    while size_num > 16 and self:textWidth(num, true, size_num) + 6 + label > wid do size_num = size_num - 4 end
    local nw = self:textValue(bb, num, ix + 14, iy + 26, true, size_num)
    self:textValue(bb, line1, ix + 14 + nw + 6, iy + 30, false, 10, GREY_55)
    self:textValue(bb, target, ix + 14 + nw + 6, iy + 43, true, 10)
    -- bar: grey track and the progress in black
    self:ret(bb, ix + 14, iy + 64, wid, 6, GREY_BB)
    local full_one = math.floor(wid * pf.fraction + 0.5)
    if full_one > 0 then self:ret(bb, ix + 14, iy + 64, full_one, 6, BLACK) end
    self:rectangles(bb, ICON_HOURGLASS, ix, iy, GREY_55)
    self:textValue(bb, string.format(T"%s PAGES READ", Drawing.thousands(s.pages)), ix + 30, iy + 77, false, 10, GREY_55)
end

--- Sleep screen: the balloon and Yomimon asleep, alone, in the middle of the screen (no cards since 29/10/2026:
-- the image is drawn when the Kindle sleeps, and in the morning belly, mood and "pages today" would already be yesterday's).
-- Paints on an image and saves it as PNG; KOReader shows it when the Kindle sleeps.
-- pick = true only when the Kindle goes to sleep: the phrase is chosen now (State.restSpeech); in the other
-- redraws, it repeats the last one.
function YomimonScreen.generateSleepScreen(s, path, now, pick)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local w, h = math.min(sw, sh), math.max(sw, sh)  -- always portrait
    local bb = Blitbuffer.new(w, h, Blitbuffer.TYPE_BB8)
    bb:fill(WHITE)
    local k = math.min(w / FRAME_W, h / FRAME_H)
    local p = setmetatable({
        k = k, ox = math.floor((w - FRAME_W * k) / 2), oy = math.floor((h - FRAME_H * k) / 2),
        font_factor = Screen:scaleBySize(1000) / 1000, faces = {},
    }, { __index = YomimonScreen })
    -- the sleeping creature: the sprite of the current form with the "z"s (or the ball, if the sprite was not downloaded).
    -- 64 high, at the Home's pixel size.
    local nameText = State.sprite(s, now, true)
    local scale = math.max(1, math.floor(295 * k / Drawing.WIDTH))
    local L = Drawing.sprite(nameText)
    local wid = #L[1] * scale
    local real_top = Drawing.realTop(nameText) * scale           -- empty lines above the head
    local alt_real = #L * scale - real_top
    -- balloon and Yomimon as a group, like the Home (tail 30 above the head), in the middle of the screen
    local speech = State.restSpeech(s, now, pick)
    local m = p:measureBalloon(speech)
    local group = m.H + 15 + 30 + alt_real / k
    local top = math.max(20, (FRAME_H - group) / 2)
    p:balloon(bb, speech, nil, top, m)
    local head = p.oy + p:px(top + m.H + 15 + 30)
    Drawing.paintSprite(bb, nameText, p.ox + p:px(FRAME_W / 2) - math.floor(wid / 2), head - real_top, scale)
    local ok, err = pcall(bb.writePNG, bb, path)
    bb:free()
    return ok, err
end

-- Achievements: summary, milestones and shelf by year --------------------------------------

--- Books marked as finished in KOReader (or read to the end), with the date.
function YomimonScreen.finishedBooks()
    local list = {}
    pcall(function()
        local ReadHistory = require("readhistory")
        local DocSettings = require("docsettings")
        for _, item in ipairs(ReadHistory.hist or {}) do
            if item.file and DocSettings:hasSidecarFile(item.file) then
                local ds = DocSettings:open(item.file)
                local summary = ds:readSetting("summary") or {}
                local pct = ds:readSetting("percent_finished") or 0
                if summary.status == "complete" or pct >= 0.995 then
                    local props = ds:readSetting("doc_props") or {}
                    local data = summary.modified or (item.time and os.date("%Y-%m-%d", item.time)) or ""
                    list[#list + 1] = { titleText = props.display_title or props.title or item.text or "?", data = data }
                end
            end
        end
    end)
    table.sort(list, function(a, b) return a.data > b.data end)
    return list
end

function YomimonScreen:paintAchievements(bb, s)
    local finishedList = self.finishedList or {}
    -- page 1: summary + milestones; following pages: shelf by year
    local years, per_year = {}, {}
    for _, L in ipairs(finishedList) do
        local year = L.data:sub(1, 4)
        if year == "" then year = "????" end
        if not per_year[year] then per_year[year] = {}; years[#years + 1] = year end
        table.insert(per_year[year], L)
    end
    local shelf_pages = {}
    for _, year in ipairs(years) do
        local list = per_year[year]
        for i = 1, #list, 9 do
            shelf_pages[#shelf_pages + 1] = { year = year, total = #list, de = i, list = list }
        end
    end
    local total = 2 + #shelf_pages  -- 2 pages of milestones
    self.pg = math.max(1, math.min(self.pg or 1, total))

    if self.pg <= 2 then
        if self.pg == 1 then
            -- summary card
            self:card(bb, 20, 86, 578, 96, true)
            local function block(x, val, label)
                self:textValue(bb, val, x, 100, true, 28)
                self:textValue(bb, label, x, 140, false, 10, GREY_55)
            end
            local pages, days = State.totals(s)
            block(44, tostring(#finishedList), T"BOOKS FINISHED")
            block(240, Drawing.thousands(pages), T"PAGES READ")
            block(436, tostring(days), T"DAYS READING")
        end
        local milestones = State.milestones(s, {
            finished_books = #finishedList, highlights = self.n_highlights or 0,
            ambivalent = Memory.ambivalent(s) ~= nil,
        })
        local ini = self.pg == 1 and 1 or 11
        local y0 = self.pg == 1 and 200 or 92
        for k = 0, 9 do
            local m = milestones[ini + k]
            if not m then break end
            local x = 20 + (k % 2) * 299
            local y = y0 + math.floor(k / 2) * 104
            self:card(bb, x, y, 279, 88, true)
            -- seal: filled square if achieved, empty (grey) if not
            local sx, sy = x + 16, y + 26
            if m.done then
                self:ret(bb, sx + 3, sy, 20, 26, BLACK); self:ret(bb, sx, sy + 3, 26, 20, BLACK)
                self:ret(bb, sx + 6, sy + 6, 3, 3, WHITE)
            else
                self:ret(bb, sx + 3, sy, 20, 3, GREY_BB); self:ret(bb, sx + 3, sy + 23, 20, 3, GREY_BB)
                self:ret(bb, sx, sy + 3, 3, 20, GREY_BB); self:ret(bb, sx + 23, sy + 3, 3, 20, GREY_BB)
            end
            self:textValue(bb, m.titleText, x + 56, y + 16, true, 13, m.done and BLACK or GREY_55)
            local desc = m.done and m.description
                or (m.meta > 1 and string.format("%s / %s", Drawing.thousands(math.min(m.current, m.meta)), Drawing.thousands(m.meta)) or m.description)
            self:textValue(bb, desc, x + 56, y + 42, false, 9, GREY_55)
        end
    else
        local P = shelf_pages[self.pg - 2]
        self:textValue(bb, string.format("%s · %d %s", P.year, P.total, P.total == 1 and T"BOOK" or T"BOOKS"), 20, 88, true, 18)
        local y = 124
        for i = P.de, math.min(P.de + 8, #P.list) do
            local L = P.list[i]
            self:card(bb, 20, y, 578, 62, true)
            self:ret(bb, 36, y + 14, 6, 34, BLACK); self:ret(bb, 42, y + 14, 3, 34, GREY_BB)  -- spine
            local t = TextBoxWidget:new{
                text = capitals(L.titleText), face = self:face(true, 13), width = self:px(420),
                height = self:px(18), height_overflow_show_ellipsis = true,
            }
            t:paintTo(bb, self.ox + self:px(60), self.oy + self:px(y + 14))
            t:free()
            local d = L.data
            local day, month = d:sub(9, 10), tonumber(d:sub(6, 7))
            self:textValue(bb, month and (day .. " " .. MONTHS[month]) or "", 60, y + 38, false, 10, GREY_55)
            y = y + 70
        end
    end
    self:navigation(bb, total)
end

-- Pokédex: the Pokémon already chosen and the progress each one kept ---------------------------

--- Pokédex: the Pokémon already chosen, each with the progress it kept; tapping one switches to it.
function YomimonScreen:paintPokedex(bb, s)
    local list = State.collection(s)
    local items = {}
    for _, e in ipairs(list) do items[#items + 1] = e end
    items[#items + 1] = { new = true }
    local per_page = 5
    local total = math.ceil(#items / per_page)
    self.pg = math.max(1, math.min(self.pg or 1, total))
    local scale = math.max(1, math.floor(80 * self.k / Drawing.WIDTH))
    local y = 88
    for i = (self.pg - 1) * per_page + 1, math.min(#items, self.pg * per_page) do
        local e = items[i]
        self:card(bb, 20, y, 578, 104, true)
        if e.new then
            self:textValue(bb, T"+ PICK ANOTHER POKÉMON", 0, y + 38, true, 18, BLACK, 309)
            self:target(20, y, 578, 104, function() self.plugin:showWelcome(true) end)
        else
            Drawing.paintSprite(bb, e.form.nameText, self.ox + self:px(30), self.oy + self:px(y + 12), scale)
            self:textValue(bb, capitals(e.form.titleText), 130, y + 16, true, 15)
            self:textValue(bb, string.format(T"FORM %d OF %d", e.formIndex, e.total), 130, y + 42, false, 10, GREY_55)
            local pages = math.floor(e.letters / State.lettersPerPage(s))
            self:textValue(bb, string.format(T"%s PAGES READ WITH YOU", Drawing.thousands(pages)), 130, y + 62, false, 10, GREY_55)
            if e.current then
                self:textValue(bb, T"WITH YOU NOW", 130, y + 80, true, 10)
            else
                self:textValue(bb, ">", 0, y + 36, true, 24, BLACK, 570)
                self:target(20, y, 578, 104, function()
                    State.switchSpecies(s, e.base)
                    pcall(function() require("yomimon_simpleui").syncCritter(self.plugin) end)
                    self.speech = nil
                    self.plugin:save(true)
                    self.pg = 1
                end)
            end
        end
        y = y + 120
    end
    self:navigation(bb, total)
end

-- Text cards ---------------------------------------------------------------------

--- Height (in Figma points) a text takes at a width, with the pixel font.
function YomimonScreen:textHeight(textValue, bold, size, widthPx)
    local t = TextBoxWidget:new{ text = textValue, face = self:face(bold, size), width = self:px(widthPx) }
    local h = t:getSize().h / self.k
    t:free()
    return h
end

--- Card with a label and text, as tall as the text (up to max_heightPx). Returns the y right below.
function YomimonScreen:textBox(bb, y, label, textValue, max_heightPx)
    textValue = capitals(textValue)
    local heightPx = math.min(max_heightPx, math.ceil(self:textHeight(textValue, false, 13, 530)) + 52)
    self:card(bb, 20, y, 578, heightPx, true)
    self:textValue(bb, label, 40, y + 14, true, 11, GREY_55)
    local t = TextBoxWidget:new{
        text = textValue, face = self:face(false, 13), width = self:px(530),
        height = self:px(heightPx - 46), height_overflow_show_ellipsis = true,
    }
    t:paintTo(bb, self.ox + self:px(40), self.oy + self:px(y + 36))
    t:free()
    return y + heightPx + 18
end

--- Dev mode: saves each screen as PNG (koreader/yomimon/demo), at the device's resolution.
function YomimonScreen:exportScreens(folder)
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    folder = folder or DataStorage:getDataDir() .. "/yomimon/demo"
    local mother = folder:match("^(.*)/[^/]+$")
    if mother and lfs.attributes(mother, "mode") ~= "directory" then lfs.mkdir(mother) end
    if lfs.attributes(folder, "mode") ~= "directory" then lfs.mkdir(folder) end
    local bb = Blitbuffer.new(Screen:getWidth(), Screen:getHeight(), Blitbuffer.TYPE_BB8)
    local s = self.plugin.state
    local n, failures = 0, 0
    self.exporting = true  -- without the SIMULATION seal on the images
    local function photo(nameText, prepare)
        local ok = pcall(function()
            self.menu_open = false
            prepare()
            bb:fill(WHITE)
            self:paintTo(bb, 0, 0)
            bb:writePNG(string.format("%s/%02d-%s.png", folder, n + 1, nameText))
        end)
        if ok then n = n + 1 else failures = failures + 1 end
    end
    photo("home", function() self.mode = nil; self.message = nil end)
    photo("menu", function() self.mode = nil; self.menu_open = true end)
    photo("diary", function() self:enter("diary") end)
    photo("diary-2", function() self.pg = 2 end)
    photo("notebook", function() self:enter("notebook") end)
    photo("notebook-passage", function() self.open_book = 1; self.pg = 1 end)
    photo("achievements", function() self:enter("achievements") end)
    photo("achievements-2", function() self.pg = 2 end)
    photo("shelf", function() self.pg = 3 end)
    photo("perception", function() self:enter("perception") end)
    -- demo: phrases and dreams chosen (dev_speeches and dev_dreams, put in the simulated state), one screen
    -- for each, in place of the drawn ones
    for i, f in ipairs(s.dev_speeches or {}) do
        photo("home-" .. i, function() self:enter("home"); self.message = nil; self.speech = f end)
    end
    bb:free()
    if pcall(YomimonScreen.generateSleepScreen, s, string.format("%s/%02d-rest.png", folder, n + 1), os.time()) then n = n + 1 end
    for i, f in ipairs(s.dev_dreams or {}) do
        s.rest_speech = f
        if pcall(YomimonScreen.generateSleepScreen, s, string.format("%s/%02d-rest-%d.png", folder, n + 1, i), os.time(), false) then
            n = n + 1
        end
    end
    self.exporting = false
    self:enter("home")
    return n, folder, failures
end

--- Dev mode: exports the screens of each simulation in koreader/yomimon/simulations/*.lua, each in its own folder in
-- koreader/yomimon/demo/<file name>/. Saves nothing: at the end the state that was open comes back.
function YomimonScreen:exportSimulations()
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    local LuaSettings = require("luasettings")
    local base = DataStorage:getDataDir() .. "/yomimon"
    local files = {}
    if lfs.attributes(base .. "/simulations", "mode") == "directory" then
        for f in lfs.dir(base .. "/simulations") do
            if f:match("%.lua$") then files[#files + 1] = f end
        end
    end
    table.sort(files)
    local plugin, before = self.plugin, self.plugin.state
    self:stopAnimation()
    local sims, screens, failures = 0, 0, 0
    for _, f in ipairs(files) do
        local ok, sim = pcall(function() return LuaSettings:open(base .. "/simulations/" .. f):readSetting("state") end)
        if ok and type(sim) == "table" then
            plugin.state = State.normalize(sim, os.time())
            plugin.state.dev_simulation = true
            State.passTime(plugin.state, os.time())
            self.speech, self.current_frame = nil, nil  -- nothing from the previous simulation
            local n, _, x = self:exportScreens(base .. "/demo/" .. (f:gsub("%.lua$", "")))
            sims, screens, failures = sims + 1, screens + n, failures + x
        else
            failures = failures + 1
        end
    end
    plugin.state = before
    self.speech, self.current_frame = nil, nil
    return sims, screens, failures
end

-- Dev panel: what it noticed about the current book ----------------------------------------

local EVENT_NAMES = { death = T"DEATH", wedding = T"WEDDING", travel = T"JOURNEY", letter = T"LETTER",
    storm = T"STORM", illness = T"ILLNESS", party = T"PARTY", quarrel = T"FIGHT", escape = T"ESCAPE", crime = T"CRIME" }

function YomimonScreen:paintPerception(bb, s)
    local book = s.last_book
    local P = book and Memory.perception(s, book)
    if not P then
        self:footerSpeech(bb, s, T"I haven't noticed anything yet. Read a few pages with this version.", 380)
        return
    end
    local lines = { T"BOOK: " .. capitals(book), "" , T"CHARACTERS (MENTIONS · LINES · CHAPTERS)" }
    for i, p in ipairs(P.characters) do
        if i > 8 then break end
        lines[#lines + 1] = string.format("  %s%s  %d · %d · %d", p.protagonist and "★ " or "", capitals(p.nameText), p.times, p.speeches, p.chapters)
    end
    local place_names = {}
    for i, l in ipairs(P.places) do if i <= 6 then place_names[#place_names + 1] = capitals(l[1]) end end
    lines[#lines + 1] = ""
    lines[#lines + 1] = T"PLACES: " .. (#place_names > 0 and table.concat(place_names, ", ") or "—")
    local has = {}
    for i, t in ipairs(P.themes) do if i <= 4 then has[#has + 1] = string.format("%s %d", capitals(Memory.theme(t[1])), math.floor(t[2] + 0.5)) end end
    lines[#lines + 1] = T"THEMES: " .. (#has > 0 and table.concat(has, " · ") or "—")
    local refs = {}
    for i, r in ipairs(P.references or {}) do if i <= 4 then refs[#refs + 1] = string.format("%s %d", capitals(r[1]), r[2]) end end
    lines[#lines + 1] = T"QUOTED: " .. (#refs > 0 and table.concat(refs, " · ") or "—")
    local narration = P.narrator
    lines[#lines + 1] = T"NARRATOR: " .. (not narration and "?" or not narration.first and T"THIRD PERSON"
        or (T"FIRST PERSON" .. (narration.gender == "f" and (" · " .. T"WOMAN") or narration.gender == "m" and (" · " .. T"MAN") or "")))
    local tr = {}
    for _, t in ipairs(Traits.LIST) do
        local v = (s.traits or {})[t.id] or 0
        tr[#tr + 1] = string.format("%s %+d", Traits.label(v >= 0 and t.pos or t.neg), math.floor(v + 0.5))
    end
    lines[#lines + 1] = T"TRAITS: " .. table.concat(tr, " · ")
    lines[#lines + 1] = ""
    lines[#lines + 1] = T"LATEST CHAPTERS (PG · MOOD · EVENTS)"
    for i, c in ipairs(P.chapters) do
        if i > 6 then break end
        local evs = {}
        for ev in pairs(c.C.events or {}) do evs[#evs + 1] = EVENT_NAMES[ev] or ev end
        local weather = c.C.pages > 0 and c.C.weather / c.C.pages or 0
        lines[#lines + 1] = string.format("  %s · %d · %+.1f · %s", capitals(c.nameText):sub(1, 22), c.C.pages, weather,
            #evs > 0 and table.concat(evs, ", ") or "—")
    end
    local p = s.pending_comment
    lines[#lines + 1] = ""
    lines[#lines + 1] = T"LAST CHAPTER COMMENT: " .. (p and (capitals(p.textValue) .. (p.used and T" (ALREADY SAID)" or "")) or "—")
    local box = TextBoxWidget:new{
        text = table.concat(lines, "\n"), face = self:face(false, 11), width = self:px(578),
        height = self:px(700), height_overflow_show_ellipsis = true,
    }
    box:paintTo(bb, self.ox + self:px(20), self.oy + self:px(90))
    box:free()
end

function YomimonScreen:refresh()
    UIManager:setDirty(self, "ui")
end

-- Animation ------------------------------------------------------------------------

function YomimonScreen:startAnimation()
    self.frames = Drawing.frames(State.frames(self.plugin.state, os.time()))
    self.current_frame = nil
    if not self.frames then return end
    if not self.anim_until then
        self.anim_until = os.time() + 60 * ANIMATION_MINUTES
    end
    self.frame = 0
    UIManager:scheduleIn(FRAME_SECONDS, self.tick)
end

function YomimonScreen:stopAnimation()
    UIManager:unschedule(self.tick)
end

function YomimonScreen:nextFrame()
    local now = os.time()
    if now >= (self.anim_until or 0) then
        self.anim_until = nil
        return
    end
    self.frame = self.frame % #self.frames + 1
    self.current_frame = self.frames[self.frame]
    UIManager:setDirty(self, function() return "ui", self.sprite_rect end)
    UIManager:scheduleIn(FRAME_SECONDS, self.tick)
end

function YomimonScreen:restart()
    self:stopAnimation()
    self.speech = nil
    self:startAnimation()
    self:refresh()
end

-- Taps ----------------------------------------------------------------------------

function YomimonScreen:pet()
    if self.plugin:pet() then
        self.message = T"Hm. Fine. You may continue."
    elseif self.plugin.state.hibernating then
        self.message = T"(back in its ball; read a page to call it out)"
    else
        self.message = T"That's enough affection for now."
    end
    self:refresh()
end

function YomimonScreen:onTap(_, ges)
    local pos = ges and ges.pos
    if not pos then return end
    local targets = self.targets or {}
    for i = #targets, 1, -1 do  -- the ones drawn last (menu) take priority
        local a = targets[i]
        if (not self.menu_open or a.layer ~= "content") and pos:intersectWith(a.rect) then
            if a.action() ~= "closed" then self:refresh() end
            return true
        end
    end
    if self.menu_open then
        self.menu_open = false
        self:refresh()
        return true
    end
    if not self.mode and pos:intersectWith(self.sprite_rect) then
        self:pet()
        return true
    end
end

function YomimonScreen:onHold(_, ges)
    local pos = ges and ges.pos
    if self.mode or not (pos and pos:intersectWith(self.sprite_rect)) then return end
    local dialogue
    local buttonRows = {
            {{
                text = self.plugin:sleepScreenActive() and T"Sleep screen: on" or T"Sleep screen: off",
                callback = function()
                    UIManager:close(dialogue)
                    self.plugin:toggleSleepScreen()
                end,
            }},
    }
    table.insert(buttonRows, {{ text = T"Language…", callback = function()
        UIManager:close(dialogue)
        self:languageMenu()
    end }})
    if YomimonScreen.devOn() then
        table.insert(buttonRows, {{ text = T"Dev mode…", callback = function()
            UIManager:close(dialogue)
            self:menuDev()
        end }})
    end
    dialogue = ButtonDialog:new{ buttons = buttonRows }

    UIManager:show(dialogue)
    return true
end

--- Language menu: automatic (follows KOReader) plus every folder found in yomimon_locales/. Applies after a restart.
function YomimonScreen:languageMenu()
    local Language = require("yomimon_language")
    local current = Language.choice()
    local dialogue
    local function option(textValue, val)
        return {{ text = (current == val and "▸ " or "") .. textValue, callback = function()
            UIManager:close(dialogue)
            if val == current then return end
            Language.saveChoice(val)
            UIManager:show(require("ui/widget/infomessage"):new{ text = T"Restart KOReader to change the language." })
        end }}
    end
    local buttonRows = { option(T"Automatic (KOReader language)", "auto") }
    for _, language in ipairs(Language.available()) do buttonRows[#buttonRows + 1] = option(language.name, language.code) end
    dialogue = ButtonDialog:new{ title = T"Yomimon language", buttons = buttonRows }
    UIManager:show(dialogue)
end

--- Dev mode: only exists if the file koreader/yomimon/dev exists. Changes stage and mood for testing.
function YomimonScreen:menuDev(close_previous)
    local s = self.plugin.state
    local dialogue
    local function action(fn)
        return function()
            UIManager:close(dialogue)
            fn()
            self.plugin:save(true)
            self.message = nil
            self:restart()
        end
    end
    local stages = {}
    for _, f in ipairs(State.forms(s)) do
        stages[#stages + 1] = { text = (s.dev_stage == f.nameText and "▸ " or "") .. f.titleText, callback = action(function() s.dev_stage = f.nameText end) }
    end
    dialogue = ButtonDialog:new{
        title = T"YOMIMON · DEV MODE",
        buttons = {
            stages,
            {
                { text = T"Starving", callback = action(function() s.belly, s.mood = 5, 40 end) },
                { text = T"Grumpy", callback = action(function() s.belly, s.mood = 60, 10 end) },
                { text = T"Happy", callback = action(function() s.belly, s.mood = 90, 90 end) },
            },
            {
                { text = s.dev_night and T"Night: on" or T"Night: off", callback = action(function() s.dev_night = not s.dev_night or nil end) },
                { text = s.hibernating and T"Leave the ball" or T"Back to the ball", callback = action(function() s.hibernating = not s.hibernating end) },
            },
            {
                { text = T"What it noticed", callback = function()
                    UIManager:close(dialogue)
                    self:enter("perception")
                end },
            },
            {
                { text = T"End of cycle (test)", callback = function()
                    UIManager:close(dialogue)
                    s.dev_stage = nil
                    self:onClose()
                    self.plugin:cycleEnd()
                end },
            },
            (function()
                -- loading always reads the file again (the real state is stored the first time)
                local line = {
                    { text = T"Endgame simulation", callback = function()
                        UIManager:close(dialogue)
                        if not self.plugin:loadSimulation() then
                            UIManager:show(require("ui/widget/infomessage"):new{ text = T"No simulation at koreader/yomimon/simulation.lua." })
                        end
                        self.message = nil
                        self:restart()
                    end },
                }
                if self.plugin:inSimulation() then
                    line[2] = { text = T"Back to the real state", callback = function()
                        UIManager:close(dialogue)
                        self.plugin:restoreRealState()
                        self.message = nil
                        self:restart()
                    end }
                end
                return line
            end)(),
            {
                { text = T"Export screens (PNG)", callback = function()
                    UIManager:close(dialogue)
                    local n, folder, failures = self:exportScreens()
                    UIManager:show(require("ui/widget/infomessage"):new{
                        text = string.format(T"%d screens saved to %s", n, folder) .. (failures > 0 and string.format(" (%d ✗)", failures) or ""),
                    })
                end },
            },
            {
                { text = T"Export all simulations", callback = function()
                    UIManager:close(dialogue)
                    local InfoMessage = require("ui/widget/infomessage")
                    local notice = InfoMessage:new{ text = T"Exporting the simulations in koreader/yomimon/simulations…" }
                    UIManager:show(notice)
                    UIManager:forceRePaint()
                    local sims, n, failures = self:exportSimulations()
                    UIManager:close(notice)
                    self:restart()
                    UIManager:show(InfoMessage:new{
                        text = string.format(T"%d simulations, %d screens saved to koreader/yomimon/demo", sims, n)
                            .. (failures > 0 and string.format(" (%d ✗)", failures) or ""),
                    })
                end },
            },
            {
                { text = self.plugin.test_failure and T"Test failure: on" or T"Test failure: off", callback = function()
                    UIManager:close(dialogue)
                    self.plugin:toggleTestFailure()
                end },
            },
            {
                { text = T"Show welcome", callback = function()
                    UIManager:close(dialogue)
                    self:onClose()
                    self.plugin:showWelcome()
                end },
            },
            {
                { text = T"Leave test (back to normal)", callback = action(function()
                    s.dev_stage, s.dev_night, s.hibernating = nil, nil, false
                    s.belly, s.mood = math.max(s.belly, 60), math.max(s.mood, 60)
                end) },
            },
        },
    }
    UIManager:show(dialogue)
end

function YomimonScreen.devOn()
    local okVersion, Version = pcall(require, "yomimon_version")
    if okVersion and type(Version) == "table" and Version.public then return false end  -- community version: never
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    return lfs.attributes(DataStorage:getDataDir() .. "/yomimon/dev", "mode") == "file"
end

function YomimonScreen:onSuspend()
    self:stopAnimation()
end

function YomimonScreen:onResume()
    self.anim_until = nil
    self:restart()
end

function YomimonScreen:onCloseWidget()
    self:stopAnimation()
end

function YomimonScreen:onClose()
    UIManager:close(self, "flashpartial")
    return true
end

-- Protection: an error when drawing, tapping or animating cannot freeze KOReader. If it fails, the screen
-- shows a simple notice and any tap closes it (so the reader is never stuck on a broken screen).
local Guard = require("yomimon_guard")
Guard.default:wrap(YomimonScreen, { "paintTo", "onTap", "onHold", "nextFrame" }, function(nameText, self, bb, x, y)
    if nameText == "paintTo" then
        bb:paintRect(x, y, self.dimen.w, self.dimen.h, WHITE)
        local notice = TextBoxWidget:new{
            text = T"Yomimon tripped. Tap to close.", face = Font:getFace("cfont", 22), width = self.dimen.w - 80,
        }
        notice:paintTo(bb, x + 40, y + math.floor(self.dimen.h / 3))
        notice:free()
    elseif nameText == "onTap" or nameText == "onHold" then
        UIManager:close(self)
        return true
    end
end)

return YomimonScreen
