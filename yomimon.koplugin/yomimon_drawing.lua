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

local Estado = require("yomimon_state")
local Baixar = require("yomimon_download")
local Sprite = require("yomimon_sprite")

-- "p<dex>" is the species' downloaded sprite; "bola" is the fallback while it does not exist.
local Sprites = { bola = Sprite.bola() }
setmetatable(Sprites, { __index = function(_, nome)
    local dex = type(nome) == "string" and nome:match("^p(%d+)$")
    return dex and Baixar.carregar(tonumber(dex)) or nil
end })

local Desenho = {}

-- Plugin folder, taken from the file itself ("plugins/yomimon.koplugin", or another name, or an absolute path).
local PASTA = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "plugins/yomimon.koplugin"

--- Path of a font in the `fontes` folder for KOReader's Font:getFace, which searches from its own fonts
-- folder (./fonts). Works with any plugin folder name.
function Desenho.caminhoFonte(arquivo)
    if PASTA:sub(1, 1) == "/" then
        return string.rep("../", 16) .. PASTA:sub(2) .. "/fonts/" .. arquivo  -- goes up to the root and comes down
    end
    return "../" .. (PASTA:gsub("^%./", "")) .. "/fonts/" .. arquivo
end

-- All drawings are 64x64 pixels.
Desenho.LARGURA, Desenho.ALTURA = 64, 64

-- Figma's 5 tones (exact e-ink levels) + the old grey.
local CORES = {
    ["#"] = Blitbuffer.COLOR_BLACK,
    ["1"] = Blitbuffer.Color8(0x55),
    ["2"] = Blitbuffer.Color8(0x88),
    ["3"] = Blitbuffer.Color8(0xBB),
    ["4"] = Blitbuffer.Color8(0xEE),
    ["+"] = Blitbuffer.COLOR_GRAY,
}

--- Lines of a drawing (to know its size).
function Desenho.sprite(nome)
    return Sprites[Desenho.resolver(nome)]
end

local topos = {}
--- First line with pixels in the drawing (where the head starts).
function Desenho.topoReal(nome)
    local real = Desenho.resolver(nome)
    if topos[real] == nil then
        topos[real] = 0
        for i, l in ipairs(Sprites[real] or {}) do
            if l:find("[^ ]") then topos[real] = i - 1; break end
        end
    end
    return topos[real]
end

--- Name of a drawing that exists: its own or, if that variation
-- (e.g. "p1_feliz") does not exist, the form's drawing ("p1"); without it, the ball.
function Desenho.resolver(nome)
    if nome and Sprites[nome] then return nome end
    local fase = nome and nome:match("^([^_]+)")
    if fase and Sprites[fase] then return fase end
    return "bola"
end

--- Animation frames that really exist, or nil if there is nothing to animate.
function Desenho.quadros(lista)
    if not lista then return nil end
    local reais, diferentes, visto = {}, 0, {}
    for i, nome in ipairs(lista) do
        reais[i] = Desenho.resolver(nome)
        if not visto[reais[i]] then visto[reais[i]] = true; diferentes = diferentes + 1 end
    end
    if diferentes < 2 then return nil end
    return reais
end

--- Paints the sprite `nome` with each pixel becoming a square of `escala` px.
-- In night mode KOReader inverts the whole screen; the sprite is drawn already inverted to keep its usual
-- look (white card) instead of becoming a negative. Does not apply when recording images (Desenho.gravando).
function Desenho.pintarSprite(bb, nome, x, y, escala)
    local linhas = Sprites[Desenho.resolver(nome)]
    if not linhas then return end
    local noturno = Screen.night_mode and not Desenho.gravando
    if noturno then
        bb:paintRect(x, y, Desenho.LARGURA * escala, Desenho.ALTURA * escala, Blitbuffer.COLOR_WHITE)
    end
    for j, linha in ipairs(linhas) do
        -- joins neighbouring pixels of the same colour into a single rectangle
        local i, n = 1, #linha
        while i <= n do
            local c = linha:sub(i, i)
            local k = i
            while k < n and linha:sub(k + 1, k + 1) == c do k = k + 1 end
            local cor = CORES[c]
            if cor then
                bb:paintRect(x + (i - 1) * escala, y + (j - 1) * escala, (k - i + 1) * escala, escala, cor)
            end
            i = k + 1
        end
    end
    if noturno then bb:invertRect(x, y, Desenho.LARGURA * escala, Desenho.ALTURA * escala) end
end

--- Runs fn(...) without the night-mode inversion (to record images to a file).
function Desenho.gravar(fn, ...)
    Desenho.gravando = true
    local ok, a, b = pcall(fn, ...)
    Desenho.gravando = false
    if not ok then error(a, 0) end
    return a, b
end

--- Widget that shows a sprite.
Desenho.SpriteWidget = Widget:extend{
    nome = nil,
    escala = 8,
}

function Desenho.SpriteWidget:getSize()
    return Geom:new{ w = Desenho.LARGURA * self.escala, h = Desenho.ALTURA * self.escala }
end

function Desenho.SpriteWidget:paintTo(bb, x, y)
    self.dimen = Geom:new{ x = x, y = y, w = Desenho.LARGURA * self.escala, h = Desenho.ALTURA * self.escala }
    Desenho.pintarSprite(bb, self.nome, x, y, self.escala)
end

--- Integer scale that makes the sprite fit in `largura` x `altura`.
function Desenho.escalaPara(largura, altura)
    return math.max(1, math.floor(math.min(largura / Desenho.LARGURA, altura / Desenho.ALTURA)))
end

local function pintarBarra(bb, x, y, w, h, fracao)
    local borda = math.max(2, math.floor(h / 8))
    bb:paintRect(x, y, w, h, Blitbuffer.COLOR_BLACK)
    bb:paintRect(x + borda, y + borda, w - 2 * borda, h - 2 * borda, Blitbuffer.COLOR_WHITE)
    local cheio = math.floor((w - 4 * borda) * math.max(0, math.min(1, fracao)))
    if cheio > 0 then
        bb:paintRect(x + 2 * borda, y + 2 * borda, cheio, h - 4 * borda, Blitbuffer.COLOR_DARK_GRAY)
    end
end

local function textoCentrado(bb, texto, face, largura_tela, y, largura_max)
    local w = TextBoxWidget:new{
        text = texto,
        face = face,
        width = largura_max,
        alignment = "center",
    }
    local tam = w:getSize()
    w:paintTo(bb, math.floor((largura_tela - tam.w) / 2), y)
    w:free()
    return tam.h
end

local function milhar(n)  -- 1.234 or 1,234, by language
    local sep = require("yomimon_language").format().thousands
    local s = tostring(math.floor(n))
    local r = s:reverse():gsub("(%d%d%d)", "%1" .. sep):reverse()
    return (r:gsub("^%p", ""))
end
Desenho.milhar = milhar

--- Generates the sleep-screen image (greyscale PNG) at `caminho`.
function Desenho.gerarTelaDescanso(s, caminho, agora)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local w, h = math.min(sw, sh), math.max(sw, sh) -- the sleep screen is always portrait
    local bb = Blitbuffer.new(w, h, Blitbuffer.TYPE_BB8)
    bb:fill(Blitbuffer.COLOR_WHITE)

    local margem = math.floor(w * 0.08)
    local escala = Desenho.escalaPara(w - 2 * margem, h * 0.45)
    local sprite_w, sprite_h = Desenho.LARGURA * escala, Desenho.ALTURA * escala
    local y = math.floor(h * 0.16)

    y = y + textoCentrado(bb, "Yomimon", Font:getFace("tfont", 34), w, math.floor(h * 0.06), w - 2 * margem)
    local pose = Estado.POSES[math.random(#Estado.POSES)]
    Desenho.pintarSprite(bb, Estado.sprite(s, agora, true, pose), math.floor((w - sprite_w) / 2), y, escala)
    y = y + sprite_h + math.floor(h * 0.04)

    y = y + textoCentrado(bb, Estado.fala(s, agora, nil, true), Font:getFace("cfont", 26), w, y, w - 2 * margem)
    y = y + math.floor(h * 0.04)

    local face_rotulo = Font:getFace("cfont", 20)
    local barra_w = math.floor((w - 2 * margem) * 0.62)
    local barra_h = math.floor(h * 0.022)
    for _, item in ipairs({ { "Barriga", s.barriga }, { "Humor", s.humor } }) do
        local rotulo = TextWidget:new{ text = item[1], face = face_rotulo }
        local rw = rotulo:getSize()
        local x0 = math.floor((w - (barra_w + rw.w + margem / 2)) / 2)
        rotulo:paintTo(bb, x0, y + math.floor((barra_h - rw.h) / 2))
        rotulo:free()
        pintarBarra(bb, x0 + rw.w + math.floor(margem / 2), y, barra_w, barra_h, item[2] / 100)
        y = y + barra_h + math.floor(h * 0.02)
    end

    local fase = Estado.fase(s)
    local rodape = string.format("%s · %s letras comidas", fase.titulo, milhar(s.letras))
    textoCentrado(bb, rodape, Font:getFace("cfont", 18), w, h - math.floor(h * 0.08), w - 2 * margem)

    local ok, err = pcall(bb.writePNG, bb, caminho)
    bb:free()
    return ok, err
end

return Desenho
