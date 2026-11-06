--[[--
Bookshelf integration: a Yomimon card (one of its "micro-modules") on the home screen, the start menu and
the shelf, among the books. Bookshelf finds bookshelf_modules/yomimon.lua inside the plugin folder and asks
for the drawing here; it decides the card size (the user resizes it freely). If Bookshelf is not installed,
none of this is used.

Two versions, by the card's shape:
  narrow (square or tall)  only Yomimon, for those who want to save space
  wide                     the balloon on top with up to 2 lines (the Simple UI card's text), the same
                           balloon as the Yomimon screen, and Yomimon below
  shelf                    the balloon already shows in a narrower space (the shelf is tall), with a smaller
                           font if needed, so it does not take the whole shelf; it stands on the shelf (on
                           the covers shelf, at mid height, like the covers)
The balloon is as wide as the phrase. Yomimon gets the biggest size that fits; the balloon may come down to its
head, because the drawing has an empty margin on top. On a wide card too low for both, or in the list of
modules to add, only Yomimon shows. Outside the shelf, the group is centred in the height.
]]

local Device = require("device")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local TextBoxWidget = require("ui/widget/textboxwidget")
local Blitbuffer = require("ffi/blitbuffer")
local logger = require("logger")
local Widget = require("ui/widget/widget")
local Screen = Device.screen

local Drawing = require("yomimon_drawing")
local T = require("yomimon_language").t
local State = require("yomimon_state")

local Bookshelf = {}

-- Bookshelf's module kit (Bookshelf is already loaded when this file is used).
local ok_kit, Kit = pcall(require, "lib/bookshelf_module_kit")
if not ok_kit or type(Kit) ~= "table" then Kit = nil end

-- Yomimon's bookshelf_modules folder (Bookshelf passes it to bookshelf_modules/yomimon.lua).
local modules_folder

-- The Yomimon open right now (library or reader). Bookshelf 6.1 finds the instance by the plugin folder
-- (Kit.plugin); on an older Bookshelf, it is the one main.lua stores in Screensaver at startup.
local function instance()
    if Kit and Kit.plugin and modules_folder then
        local ok, plugin = pcall(Kit.plugin, modules_folder)
        if ok and plugin then return plugin end
    end
    local ok, Screensaver = pcall(require, "ui/screensaver")
    return ok and Screensaver and Screensaver.yomimon_instance or nil
end

-- Card shape by aspect ratio (the same limits as Bookshelf).
local function formOf(w, h)
    if not h or h <= 0 then return "quadrado" end
    local r = w / h
    if r >= 1.6 then return "largo" end
    if r <= 0.7 then return "alto" end
    return "quadrado"
end

local FORMS = { wide = "largo", tall = "alto", square = "quadrado" }

-- Balloon text ------------------------------------------------------------------

-- The same thought until it eats, sleeps/wakes or 20 minutes pass (as in Simple UI).
local CHANGE_SECONDS = 20 * 60
local ATTEMPTS = 12
local cache = {}

local function font(tam_px)
    return Font:getFace("cfont", tam_px / (Screen:scaleBySize(1000) / 1000))
end

local function countLines(textValue, face, widthPx)
    local ok, n = pcall(function()
        local c = TextBoxWidget:new{ text = textValue, face = face, width = widthPx, alignment = "center" }
        local n = c.vertical_string_list and #c.vertical_string_list or math.huge
        c:free()
        return n
    end)
    return ok and n or math.huge
end

-- Width of the longest line of the phrase wrapped to `widthPx` (so the balloon is as big as the text).
local function textWidthOf(textValue, face, widthPx)
    local ok, bigger = pcall(function()
        local c = TextBoxWidget:new{ text = textValue, face = face, width = widthPx, alignment = "center" }
        local bigger = 0
        for _, line in ipairs(c.vertical_string_list or {}) do
            if type(line) == "table" and line.width then bigger = math.max(bigger, line.width) end
        end
        c:free()
        return bigger
    end)
    return (ok and bigger > 0) and math.min(bigger, widthPx) or widthPx
end

local function lineHeight(face, widthPx)
    local ok, h = pcall(function()
        local c = TextBoxWidget:new{ text = "Ag", face = face, width = widthPx }
        local h = c:getSize().h
        c:free()
        return h
    end)
    return ok and h or 1
end

-- What changes the phrase when it changes: the stage, whether it is sleeping and the pages read.
local function markOf(s, now)
    local e = State.expression(s, now)
    return table.concat({ State.stage(s).nameText, tostring(e == "sleeping" or e == "cocoon"), s.pages or 0 }, ":")
end

-- A phrase that fits in `max_lines`; keeps the chosen one and only changes when the mark changes or time passes.
local function balloonText(plugin, lines, max_lines)
    local s, now = plugin.state, os.time()
    local mark = markOf(s, now)
    if cache.textValue and cache.mark == mark and now - cache.t < CHANGE_SECONDS then
        local n = lines(cache.textValue)
        if n <= max_lines then return cache.textValue, n end
    end
    -- Lines with a number are reading metrics (pages today, streak, days away): the shelf card skips them.
    local function withoutMetrics(t) return t:find("%d") and math.huge or lines(t) end
    local textValue, n = State.speechThatFits(s, now, withoutMetrics, max_lines, ATTEMPTS)
    if textValue and textValue:find("%d") then textValue, n = nil, 0 end
    cache.textValue, cache.mark, cache.t = textValue, mark, now
    return textValue, n
end

-- Pixel balloon -------------------------------------------------------------------

-- The same balloon as the Yomimon screen (YomimonScreen:balao, Figma 28:5911): border of 3, pixel shadow on the right and
-- below, tail in the middle at the bottom. The measures are Figma's, in points; the balloon's "pixel" (u) is 3
-- points. bw and bh are the width and height of the balloon without the shadow and the tail.
local function paintBalloon(bb, bx, by, bw, bh, u)
    local BLACK, WHITE = Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    local k = u / 3
    local W, H = bw / k, bh / k
    local function r(rx, ry, rw, rh, cor)
        local x0, y0 = bx + math.floor(rx * k + 0.5), by + math.floor(ry * k + 0.5)
        local x1, y1 = bx + math.floor((rx + rw) * k + 0.5), by + math.floor((ry + rh) * k + 0.5)
        bb:paintRect(x0, y0, x1 - x0, y1 - y0, cor)
    end
    local t = math.floor(W / 2) - 7          -- start of the tail
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
end

-- From the end of the balloon (bh) to the tip of the tail: 15 Figma points, 5 "pixels".
local function tail(u) return 5 * u end

local function paintText(bb, textValue, face, tx, ty, widthPx, heightPx)
    local box = TextBoxWidget:new{
        text = textValue,
        face = face,
        width = widthPx,
        height = heightPx,
        height_overflow_show_ellipsis = true,
        alignment = "center",
    }
    local th = box:getSize().h
    box:paintTo(bb, tx, ty + math.max(0, math.floor((heightPx - th) / 2)))
    box:free()
end

-- The drawing ---------------------------------------------------------------------

-- Where the painted pixels of a 64x64 drawing are (offset and size, in drawing pixels).
local boxes = {}
local function drawingBox(nameText)
    local real = Drawing.resolver(nameText)
    if not boxes[real] then
        local x0, y0, x1, y1 = math.huge, math.huge, 0, 0
        for j, l in ipairs(Drawing.sprite(real) or {}) do
            local a = l:find("[#1234%+]")
            if a then
                local b = #l - l:reverse():find("[#1234%+]") + 1
                x0, x1, y0, y1 = math.min(x0, a), math.max(x1, b), math.min(y0, j), math.max(y1, j)
            end
        end
        if x0 == math.huge then x0, y0, x1, y1 = 1, 1, Drawing.WIDTH, Drawing.HEIGHT end
        boxes[real] = { x = x0 - 1, y = y0 - 1, w = x1 - x0 + 1, h = y1 - y0 + 1 }
    end
    return boxes[real]
end

-- The drawing's tones (those of yomimon_drawing.lua). The little shadow under it is the light grey ("3") on the two
-- last lines with pixels; on the wood of Bookshelf's shelf it disappears, so here it is painted with the dark
-- grey. The same tone "3" in the body does not change, and the drawing stays the same in the rest of the plugin.
local TONES = {
    ["#"] = Blitbuffer.COLOR_BLACK,
    ["1"] = Blitbuffer.Color8(0x55),
    ["2"] = Blitbuffer.Color8(0x88),
    ["3"] = Blitbuffer.Color8(0xBB),
    ["4"] = Blitbuffer.Color8(0xEE),
    ["+"] = Blitbuffer.COLOR_GRAY,
}
local SHADOW_TONE = "1"

-- Like Drawing.paintSprite (each pixel becomes a square of `scale` px), with the darker little shadow.
local function paintDrawing(bb, nameText, x, y, scale)
    local lines = Drawing.sprite(nameText)
    if not lines then return end
    local c = drawingBox(nameText)
    local shadow_since = c.y + c.h - 1  -- the last two lines with pixels
    for j, line in ipairs(lines) do
        local i, n = 1, #line
        while i <= n do
            local tone = line:sub(i, i)
            local k = i
            while k < n and line:sub(k + 1, k + 1) == tone do k = k + 1 end
            if tone == "3" and j >= shadow_since then tone = SHADOW_TONE end
            local cor = TONES[tone]
            if cor then
                bb:paintRect(x + (i - 1) * scale, y + (j - 1) * scale, (k - i + 1) * scale, scale, cor)
            end
            i = k + 1
        end
    end
end

-- The box of the current drawing together with that of the stage's drawing: its size does not change with each expression.
local function itsBox(sprite)
    local a, b = drawingBox(sprite), drawingBox(sprite:match("^([^_]+)") or sprite)
    local x0, y0 = math.min(a.x, b.x), math.min(a.y, b.y)
    local x1, y1 = math.max(a.x + a.w, b.x + b.w), math.max(a.y + a.h, b.y + b.h)
    return { x = x0, y = y0, w = x1 - x0, h = y1 - y0 }
end

-- What each card on screen drew last (drawing and phrase), by the card's key. on_minute
-- compares it with the current one and only redraws the card when something changed: without change, the screen does not flicker.
local drawn = {}

local function keyOf(ctx)
    local id = ctx and ctx.entry and ctx.entry.id
    return id and (tostring(ctx.surface) .. ":" .. tostring(id)) or nil
end

-- The card ----------------------------------------------------------------------------

local Card = Widget:extend{
    plugin = nil,
    widthPx = 0,
    heightPx = 0,
    form = "largo",
    shelf = false,    -- standing on the shelf, among the books
    covers = false,      -- on the covers shelf: at mid height, like the covers, instead of standing
    drawing_only = false, -- in the list of modules to add: only Yomimon, without a phrase
    lookupKey = nil,        -- so on_minute knows what this card drew
}

function Card:init()
    -- the balloon's "pixel" (3 Figma points), the same as the Simple UI card
    self.u = math.max(2, math.floor(Screen:getWidth() / 618 * 3 + 0.5))
end

function Card:getSize()
    return Geom:new{ w = self.widthPx, h = self.heightPx }
end

function Card:paintTo(bb, x, y)
    self.dimen = Geom:new{ x = x, y = y, w = self.widthPx, h = self.heightPx }
    local w, h, u = self.widthPx, self.heightPx, self.u
    local plugin = self.plugin
    local sprite = "ball"
    if plugin then
        local now = os.time()
        State.passTime(plugin.state, now)
        sprite = State.sprite(plugin.state, now)
    end
    local box = itsBox(sprite)
    local function scaleFor(heightPx) return math.floor(math.min(w * 0.9 / box.w, heightPx / box.h)) end

    -- the balloon: up to 2 lines, at most 90 "pixels" wide, and only as wide as the phrase. It goes on the wide
    -- card; on the shelf, where the shelf height is large, already from 56 "pixels" of width, so
    -- Yomimon does not take the whole shelf. Below 70, the font is the smallest of the Simple UI card.
    local balloon
    local wants_balloon = self.form == "largo" or (self.shelf and w >= 56 * u)
    if plugin and not self.drawing_only and wants_balloon then
        local pad_x, pad_y = 4 * u, 3 * u
        local bw = math.min(w - 4 * u, 90 * u)
        local face, widthPx = font(bw >= 70 * u and 5 * u or 4 * u), bw - 2 * pad_x
        if widthPx >= 30 * u then
            local lh = lineHeight(face, widthPx)
            local max_lines = 2
            local ok, textValue, n = pcall(balloonText, plugin,
                function(t) return countLines(t, face, widthPx) end, max_lines)
            if not ok then
                logger.warn("Yomimon: could not pick the Bookshelf card text:", textValue)
                textValue, n = nil, 0
            end
            if textValue then bw = math.max(20 * u, math.min(bw, textWidthOf(textValue, face, widthPx) + 2 * pad_x + u)) end
            local bh = math.min(n or 1, max_lines) * lh + 2 * pad_y
            -- only with a balloon if there is still room for Yomimon at least at twice the drawing's size
            if textValue and scaleFor(h - bh - tail(u) - u) >= 2 then
                balloon = { textValue = textValue, face = face, w = bw, h = bh, pad_x = pad_x, pad_y = pad_y }
            end
        end
    end

    -- its size and the height of the group (balloon + tail + Yomimon). On the shelf, without a balloon it keeps the size
    -- it would have with a 2-line balloon: it is not bigger than the books and does not grow when the balloon goes away.
    local above = balloon and (balloon.h + tail(u) + u) or 0
    local fallback = above
    if self.shelf and not balloon then
        fallback = 2 * lineHeight(font(5 * u), 50 * u) + 6 * u + tail(u) + u
    end
    local scale = math.max(1, scaleFor(h - fallback))
    local total = above + box.h * scale
    local em_pe = self.shelf and not self.covers
    local top = em_pe and (y + h - total) or (y + math.floor((h - total) / 2))
    if self.lookupKey then
        drawn[self.lookupKey] = { sprite = Drawing.resolver(sprite), speech = balloon ~= nil, mark = cache.mark, t = cache.t }
    end

    if balloon then
        local bx = x + math.floor((w - balloon.w) / 2)
        paintBalloon(bb, bx, top, balloon.w, balloon.h, u)
        paintText(bb, balloon.textValue, balloon.face, bx + balloon.pad_x, top + balloon.pad_y,
            balloon.w - 2 * balloon.pad_x, balloon.h - 2 * balloon.pad_y)
    end
    -- the drawing is positioned by its painted pixels (its empty margin may sit under the balloon)
    local sx = x + math.floor((w - box.w * scale) / 2) - box.x * scale
    local sy = top + above - box.y * scale
    paintDrawing(bb, sprite, sx, sy, scale)
end

-- Protection: if the card fails to draw, Bookshelf carries on (the card stays blank).
require("yomimon_guard").default:wrap(Card, { "paintTo" })

-- The module for Bookshelf (the format is in bookshelf.koplugin/micromodules/README.md) ----------

function Bookshelf.module(folder)
    modules_folder = folder
    return {
        key = "yomimon",  -- saved in people's layouts: never change
        title = T"Yomimon",
        summary = T"Your Pokémon. Works offline.",
        bare = true,          -- no card behind: Yomimon and the balloon straight on the background, as in Simple UI
        -- it fits the card size by itself (the drawing in whole steps): Bookshelf 6.1 draws
        -- once, at the card's size, instead of searching for a font size
        self_sized = true,
        tap_feedback = true,  -- tapping opens its screen
        -- when added, it starts 2 wide and 1 high: the version with a balloon. Bookshelf has no
        -- maximum width; wider only leaves space around, the drawing does not change.
        start_w = 2,
        start_h = 1,
        min_w = 1,
        min_h = 1,

        render = function(ctx)
            local w = math.max(1, math.floor(ctx.width or 0))
            local h = (ctx.height and ctx.height > 0) and math.floor(ctx.height) or nil
            if not h then
                -- start menu and list to add: natural height, that of the Simple UI card
                h = math.floor(Screen:getHeight() * 0.16 * (ctx.scale or 100) / 100)
                if ctx.max_height and ctx.max_height > 0 then h = math.min(h, math.floor(ctx.max_height)) end
            end
            return Card:new{
                plugin = instance(),
                widthPx = w,
                heightPx = h,
                form = FORMS[ctx.shape] or formOf(w, h),
                shelf = ctx.surface == "shelf",
                covers = ctx.shelf_view == "covers",
                drawing_only = ctx.preview or ctx.surface == "picker",
                lookupKey = keyOf(ctx),
            }
        end,

        -- Once a minute, with the card on screen: redraws only when its drawing changes (an expression without its own
        -- drawing falls back to the stage's, and then nothing changes) or when the balloon's phrase would change (the mark changed or
        -- the 20 minutes passed).
        on_minute = function(ctx)
            local before = drawn[keyOf(ctx)]
            local plugin = before and instance()
            if not plugin or type(ctx.refresh) ~= "function" then return end
            local now = os.time()
            State.passTime(plugin.state, now)
            local changed = Drawing.resolver(State.sprite(plugin.state, now)) ~= before.sprite
            if not changed and before.speech then
                changed = markOf(plugin.state, now) ~= before.mark or now - (before.t or 0) >= CHANGE_SECONDS
            end
            if changed then ctx.refresh() end
        end,

        on_tap = function(_ctx)
            local plugin = instance()
            if plugin then plugin:onShowYomimon() end
        end,
    }
end

return Bookshelf
