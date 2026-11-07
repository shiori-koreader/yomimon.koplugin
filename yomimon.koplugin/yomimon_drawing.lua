--[[--
Drawing: paints the pixel-art sprites and generates the sleep-screen image.
]]

local Blitbuffer = require("ffi/blitbuffer")
local Device = require("device")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local Widget = require("ui/widget/widget")
local Screen = Device.screen
local T = require("yomimon_language").t

local State = require("yomimon_state")
local Download = require("yomimon_download")
local Sprite = require("yomimon_sprite")

-- "p<dex>" is the species' downloaded sprite; "ball" is the fallback while it does not exist.
local Sprites = { ball = Sprite.ball() }
setmetatable(Sprites, { __index = function(_, nameText)
    local dex = type(nameText) == "string" and nameText:match("^p(%d+)$")
    return dex and Download.loadFile(tonumber(dex)) or nil
end })

local Drawing = {}

-- Plugin folder, taken from the file itself ("plugins/yomimon.koplugin", or another name, or an absolute path).
local FOLDER = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "plugins/yomimon.koplugin"

--- Path of a font in the `fontes` folder for KOReader's Font:getFace, which searches from its own fonts
-- folder (./fonts). Works with any plugin folder name.
function Drawing.fontPath(file_path)
    if FOLDER:sub(1, 1) == "/" then
        return string.rep("../", 16) .. FOLDER:sub(2) .. "/fonts/" .. file_path  -- goes up to the root and comes down
    end
    return "../" .. (FOLDER:gsub("^%./", "")) .. "/fonts/" .. file_path
end

-- All drawings are 64x64 pixels.
Drawing.WIDTH, Drawing.HEIGHT = 64, 64

-- Figma's 5 tones (exact e-ink levels) + the old grey.
local COLOURS = {
    ["#"] = Blitbuffer.COLOR_BLACK,
    ["1"] = Blitbuffer.Color8(0x55),
    ["2"] = Blitbuffer.Color8(0x88),
    ["3"] = Blitbuffer.Color8(0xBB),
    ["4"] = Blitbuffer.Color8(0xEE),
    ["+"] = Blitbuffer.COLOR_GRAY,
}

--- Lines of a drawing (to know its size).
function Drawing.sprite(nameText)
    return Sprites[Drawing.resolver(nameText)]
end

local tops = {}
--- First line with pixels in the drawing (where the head starts).
function Drawing.realTop(nameText)
    local real = Drawing.resolver(nameText)
    if tops[real] == nil then
        tops[real] = 0
        for i, l in ipairs(Sprites[real] or {}) do
            if l:find("[^ ]") then tops[real] = i - 1; break end
        end
    end
    return tops[real]
end

--- Name of a drawing that exists: its own or, if that variation
-- (e.g. "p1_feliz") does not exist, the form's drawing ("p1"); without it, the ball.
function Drawing.resolver(nameText)
    if nameText and Sprites[nameText] then return nameText end
    local stage = nameText and nameText:match("^([^_]+)")
    if stage and Sprites[stage] then return stage end
    return "ball"
end

--- Animation frames that really exist, or nil if there is nothing to animate.
function Drawing.frames(list)
    if not list then return nil end
    local real_ones, different, seen = {}, 0, {}
    for i, nameText in ipairs(list) do
        real_ones[i] = Drawing.resolver(nameText)
        if not seen[real_ones[i]] then seen[real_ones[i]] = true; different = different + 1 end
    end
    if different < 2 then return nil end
    return real_ones
end

--- Paints the sprite `nameText` with each pixel becoming a square of `scale` px.
-- In night mode KOReader inverts the whole screen; the sprite is drawn already inverted to keep its usual
-- look (white card) instead of becoming a negative. Does not apply when recording images (Drawing.recording).
function Drawing.paintSprite(bb, nameText, x, y, scale)
    local lines = Sprites[Drawing.resolver(nameText)]
    if not lines then return end
    local nocturnal_one = Screen.night_mode and not Drawing.recording
    if nocturnal_one then
        bb:paintRect(x, y, Drawing.WIDTH * scale, Drawing.HEIGHT * scale, Blitbuffer.COLOR_WHITE)
    end
    for j, line in ipairs(lines) do
        -- joins neighbouring pixels of the same colour into a single rectangle
        local i, n = 1, #line
        while i <= n do
            local c = line:sub(i, i)
            local k = i
            while k < n and line:sub(k + 1, k + 1) == c do k = k + 1 end
            local color = COLOURS[c]
            if color then
                bb:paintRect(x + (i - 1) * scale, y + (j - 1) * scale, (k - i + 1) * scale, scale, color)
            end
            i = k + 1
        end
    end
    if nocturnal_one then bb:invertRect(x, y, Drawing.WIDTH * scale, Drawing.HEIGHT * scale) end
end

--- Runs fn(...) without the night-mode inversion (to record images to a file).
function Drawing.writeRecord(fn, ...)
    Drawing.recording = true
    local ok, a, b = pcall(fn, ...)
    Drawing.recording = false
    if not ok then error(a, 0) end
    return a, b
end

--- Widget that shows a sprite.
Drawing.SpriteWidget = Widget:extend{
    nameText = nil,
    scale = 8,
}

function Drawing.SpriteWidget:getSize()
    return Geom:new{ w = Drawing.WIDTH * self.scale, h = Drawing.HEIGHT * self.scale }
end

function Drawing.SpriteWidget:paintTo(bb, x, y)
    self.dimen = Geom:new{ x = x, y = y, w = Drawing.WIDTH * self.scale, h = Drawing.HEIGHT * self.scale }
    Drawing.paintSprite(bb, self.nameText, x, y, self.scale)
end

--- Integer scale that makes the sprite fit in `widthPx` x `heightPx`.
function Drawing.scaleFor(widthPx, heightPx)
    return math.max(1, math.floor(math.min(widthPx / Drawing.WIDTH, heightPx / Drawing.HEIGHT)))
end

local function paintBar(bb, x, y, w, h, fraction)
    local edge = math.max(2, math.floor(h / 8))
    bb:paintRect(x, y, w, h, Blitbuffer.COLOR_BLACK)
    bb:paintRect(x + edge, y + edge, w - 2 * edge, h - 2 * edge, Blitbuffer.COLOR_WHITE)
    local full_one = math.floor((w - 4 * edge) * math.max(0, math.min(1, fraction)))
    if full_one > 0 then
        bb:paintRect(x + 2 * edge, y + 2 * edge, full_one, h - 4 * edge, Blitbuffer.COLOR_DARK_GRAY)
    end
end

local function centeredText(bb, textValue, face, screen_width, y, max_width)
    local w = TextBoxWidget:new{
        text = textValue,
        face = face,
        width = max_width,
        alignment = "center",
    }
    local size = w:getSize()
    w:paintTo(bb, math.floor((screen_width - size.w) / 2), y)
    w:free()
    return size.h
end

local function thousands(n)  -- 1.234 or 1,234, by language
    local sep = require("yomimon_language").format().thousands
    local s = tostring(math.floor(n))
    local r = s:reverse():gsub("(%d%d%d)", "%1" .. sep):reverse()
    return (r:gsub("^%p", ""))
end
Drawing.thousands = thousands

--- Generates the sleep-screen image (greyscale PNG) at `path`.
function Drawing.generateSleepScreen(s, path, now)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local w, h = math.min(sw, sh), math.max(sw, sh) -- the sleep screen is always portrait
    local bb = Blitbuffer.new(w, h, Blitbuffer.TYPE_BB8)
    bb:fill(Blitbuffer.COLOR_WHITE)

    local margin = math.floor(w * 0.08)
    local scale = Drawing.scaleFor(w - 2 * margin, h * 0.45)
    local sprite_w, sprite_h = Drawing.WIDTH * scale, Drawing.HEIGHT * scale
    local y = math.floor(h * 0.16)

    y = y + centeredText(bb, "Yomimon", Font:getFace("tfont", 34), w, math.floor(h * 0.06), w - 2 * margin)
    local pose = State.POSES[math.random(#State.POSES)]
    Drawing.paintSprite(bb, State.sprite(s, now, true, pose), math.floor((w - sprite_w) / 2), y, scale)
    y = y + sprite_h + math.floor(h * 0.04)

    y = y + centeredText(bb, State.speech(s, now, nil, true), Font:getFace("cfont", 26), w, y, w - 2 * margin)
    y = y + math.floor(h * 0.04)

    local face_label = Font:getFace("cfont", 20)
    local bar_w = math.floor((w - 2 * margin) * 0.62)
    local bar_h = math.floor(h * 0.022)
    for _, item in ipairs({ { T"Belly", s.belly }, { T"Mood", s.mood } }) do
        local label = TextWidget:new{ text = item[1], face = face_label }
        local rw = label:getSize()
        local x0 = math.floor((w - (bar_w + rw.w + margin / 2)) / 2)
        label:paintTo(bb, x0, y + math.floor((bar_h - rw.h) / 2))
        label:free()
        paintBar(bb, x0 + rw.w + math.floor(margin / 2), y, bar_w, bar_h, item[2] / 100)
        y = y + bar_h + math.floor(h * 0.02)
    end

    local stage = State.stage(s)
    local footer = string.format("%s · %s letras comidas", stage.titleText, thousands(s.letters))
    centeredText(bb, footer, Font:getFace("cfont", 18), w, h - math.floor(h * 0.08), w - 2 * margin)

    local ok, err = pcall(bb.writePNG, bb, path)
    bb:free()
    return ok, err
end

return Drawing
