--[[--
Converts an RGBA image into a 64x64 sprite in the drawing's text format (' ', '4', '3', '2', '1', '#').

Pure logic (no KOReader dependencies), so it also runs on the PC.
]]

local Sprite = {}

Sprite.SIDE = 64
local MARGIN = 2
local FITS = Sprite.SIDE - 2 * MARGIN

-- starts from the average in the cell's tone; the rest comes from the darkest pixel, which keeps the outline
local MEDIA = 0.5

-- luminance thresholds (0-255) for the tones EE, BB, 88, 55 and black
local TONES = { { 0xF6, "4" }, { 0xB8, "3" }, { 0x78, "2" }, { 0x3C, "1" } }

local function tone(lum)
    for _, t in ipairs(TONES) do
        if lum >= t[1] then return t[2] end
    end
    return "#"
end

--- pixel(x, y) with x and y from 0 returns r, g, b, alpha (0-255). Returns 64 lines of 64 characters.
-- Without a useful alpha channel (all opaque), the background is the colour of the top left corner.
function Sprite.convert(w, h, pixel)
    if not w or not h or w < 1 or h < 1 then return nil, "imagem vazia" end
    local lum, alpha = {}, {}
    local opaque = true
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = pixel(x, y)
            local i = y * w + x + 1
            -- premultiplied colour: adds the missing white to composite over the paper
            local c = (0.299 * r + 0.587 * g + 0.114 * b)
            if a < 255 then
                opaque = false
                c = math.min(255, c + (255 - a))
            end
            lum[i], alpha[i] = c, a
        end
    end
    if opaque then
        local r0, g0, b0 = pixel(0, 0)
        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local r, g, b = pixel(x, y)
                if math.abs(r - r0) + math.abs(g - g0) + math.abs(b - b0) < 24 then alpha[y * w + x + 1] = 0 end
            end
        end
    end
    local x0, y0, x1, y1 = w, h, -1, -1
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            if alpha[y * w + x + 1] >= 128 then
                if x < x0 then x0 = x end
                if x > x1 then x1 = x end
                if y < y0 then y0 = y end
                if y > y1 then y1 = y end
            end
        end
    end
    if x1 < 0 then return nil, "no visible pixels" end
    local bw, bh = x1 - x0 + 1, y1 - y0 + 1
    local scale = math.min(FITS / bw, FITS / bh, 1)
    local tw, th = math.max(1, math.floor(bw * scale + 0.5)), math.max(1, math.floor(bh * scale + 0.5))
    local ox, oy = math.floor((Sprite.SIDE - tw) / 2), Sprite.SIDE - MARGIN - th
    local passo_x, passo_y = bw / tw, bh / th
    local lines = {}
    for j = 0, Sprite.SIDE - 1 do
        local line = {}
        for i = 0, Sprite.SIDE - 1 do
            local c = " "
            local ti, tj = i - ox, j - oy
            if ti >= 0 and ti < tw and tj >= 0 and tj < th then
                local sx0, sx1 = x0 + ti * passo_x, x0 + (ti + 1) * passo_x
                local sy0, sy1 = y0 + tj * passo_y, y0 + (tj + 1) * passo_y
                local weight, cob, sum, minimum = 0, 0, 0, 255
                for sy = math.floor(sy0), math.ceil(sy1) - 1 do
                    local wy = math.min(sy + 1, sy1) - math.max(sy, sy0)
                    for sx = math.floor(sx0), math.ceil(sx1) - 1 do
                        local wx = math.min(sx + 1, sx1) - math.max(sx, sx0)
                        local wgt = wx * wy
                        weight = weight + wgt
                        if sx >= 0 and sx < w and sy >= 0 and sy < h then
                            local k = sy * w + sx + 1
                            local a = alpha[k] / 255
                            cob = cob + wgt * a
                            sum = sum + wgt * a * lum[k]
                            if alpha[k] >= 128 and lum[k] < minimum then minimum = lum[k] end
                        end
                    end
                end
                if weight > 0 and cob / weight >= 0.45 then c = tone(MEDIA * sum / cob + (1 - MEDIA) * minimum) end
            end
            line[#line + 1] = c
        end
        lines[#lines + 1] = table.concat(line)
    end
    return lines
end

--- Reads a stored sprite (one line per drawing line). Returns nil unless it has 64 lines of 64 characters.
function Sprite.readFile(textValue)
    if type(textValue) ~= "string" then return nil end
    local lines = {}
    for l in textValue:gmatch("([^\r\n]*)\r?\n?") do
        if l ~= "" or #lines < Sprite.SIDE then lines[#lines + 1] = l end
        if #lines == Sprite.SIDE then break end
    end
    if #lines ~= Sprite.SIDE then return nil end
    for _, l in ipairs(lines) do
        if #l ~= Sprite.SIDE or l:find("[^ 1234#]") then return nil end
    end
    return lines
end

function Sprite.store(lines)
    return table.concat(lines, "\n") .. "\n"
end

--- Fallback ball: used while the creature's sprite has not been downloaded (or without internet).
function Sprite.ball()
    local side, c = Sprite.SIDE, (Sprite.SIDE - 1) / 2
    local lightning = 26
    local cy = side - MARGIN - lightning - 0.5
    local lines = {}
    for j = 0, side - 1 do
        local line = {}
        for i = 0, side - 1 do
            local dx, dy = i - c, j - cy
            local d = math.sqrt(dx * dx + dy * dy)
            local ch = " "
            if d <= lightning then
                if d > lightning - 2 or math.abs(dy) < 2 then
                    ch = "#"
                elseif d < 7 then
                    ch = d > 5 and "#" or "4"
                elseif dy < 0 then
                    ch = "2"
                else
                    ch = "4"
                end
            end
            line[#line + 1] = ch
        end
        lines[#lines + 1] = table.concat(line)
    end
    return lines
end

local GRIS = { ["#"] = 0, ["1"] = 0x55, ["2"] = 0x88, ["3"] = 0xBB, ["4"] = 0xEE }

--- Smallest rectangle that contains the drawing: x, y (from 0), width and height; nil if empty.
function Sprite.box(lines)
    local x0, y0, x1, y1 = Sprite.SIDE, Sprite.SIDE, -1, -1
    for j, l in ipairs(lines) do
        for i = 1, #l do
            if GRIS[l:sub(i, i)] then
                x0, x1 = math.min(x0, i - 1), math.max(x1, i - 1)
                y0, y1 = math.min(y0, j - 1), math.max(y1, j - 1)
            end
        end
    end
    if x1 < 0 then return nil end
    return x0, y0, x1 - x0 + 1, y1 - y0 + 1
end

--- Grey tone (0-255) of a drawing character, or nil for background.
function Sprite.grey(c)
    return GRIS[c]
end

return Sprite
