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

local Desenho = require("yomimon_drawing")
local T = require("yomimon_language").t
local Estado = require("yomimon_state")

local Bookshelf = {}

-- Bookshelf's module kit (Bookshelf is already loaded when this file is used).
local ok_kit, Kit = pcall(require, "lib/bookshelf_module_kit")
if not ok_kit or type(Kit) ~= "table" then Kit = nil end

-- Yomimon's bookshelf_modules folder (Bookshelf passes it to bookshelf_modules/yomimon.lua).
local pasta_modulos

-- The Yomimon open right now (library or reader). Bookshelf 6.1 finds the instance by the plugin folder
-- (Kit.plugin); on an older Bookshelf, it is the one main.lua stores in Screensaver at startup.
local function instancia()
    if Kit and Kit.plugin and pasta_modulos then
        local ok, traca = pcall(Kit.plugin, pasta_modulos)
        if ok and traca then return traca end
    end
    local ok, Screensaver = pcall(require, "ui/screensaver")
    return ok and Screensaver and Screensaver.yomimon_instance or nil
end

-- Card shape by aspect ratio (the same limits as Bookshelf).
local function formaDe(w, h)
    if not h or h <= 0 then return "quadrado" end
    local r = w / h
    if r >= 1.6 then return "largo" end
    if r <= 0.7 then return "alto" end
    return "quadrado"
end

local FORMAS = { wide = "largo", tall = "alto", square = "quadrado" }

-- Balloon text ------------------------------------------------------------------

-- The same thought until it eats, sleeps/wakes or 20 minutes pass (as in Simple UI).
local TROCA_SEGUNDOS = 20 * 60
local TENTATIVAS = 12
local cache = {}

local function fonte(tam_px)
    return Font:getFace("cfont", tam_px / (Screen:scaleBySize(1000) / 1000))
end

local function contarLinhas(texto, face, largura)
    local ok, n = pcall(function()
        local c = TextBoxWidget:new{ text = texto, face = face, width = largura, alignment = "center" }
        local n = c.vertical_string_list and #c.vertical_string_list or math.huge
        c:free()
        return n
    end)
    return ok and n or math.huge
end

-- Width of the longest line of the phrase wrapped to `largura` (so the balloon is as big as the text).
local function larguraDoTexto(texto, face, largura)
    local ok, maior = pcall(function()
        local c = TextBoxWidget:new{ text = texto, face = face, width = largura, alignment = "center" }
        local maior = 0
        for _, linha in ipairs(c.vertical_string_list or {}) do
            if type(linha) == "table" and linha.width then maior = math.max(maior, linha.width) end
        end
        c:free()
        return maior
    end)
    return (ok and maior > 0) and math.min(maior, largura) or largura
end

local function alturaDaLinha(face, largura)
    local ok, h = pcall(function()
        local c = TextBoxWidget:new{ text = "Ag", face = face, width = largura }
        local h = c:getSize().h
        c:free()
        return h
    end)
    return ok and h or 1
end

-- What changes the phrase when it changes: the stage, whether it is sleeping and the pages read.
local function marcaDe(s, agora)
    local e = Estado.expressao(s, agora)
    return table.concat({ Estado.fase(s).nome, tostring(e == "dormindo" or e == "casulo"), s.paginas or 0 }, ":")
end

-- A phrase that fits in `max_linhas`; keeps the chosen one and only changes when the mark changes or time passes.
local function textoDoBalao(traca, linhas, max_linhas)
    local s, agora = traca.estado, os.time()
    local marca = marcaDe(s, agora)
    if cache.texto and cache.marca == marca and agora - cache.t < TROCA_SEGUNDOS then
        local n = linhas(cache.texto)
        if n <= max_linhas then return cache.texto, n end
    end
    -- Lines with a number are reading metrics (pages today, streak, days away): the shelf card skips them.
    local function semMetricas(t) return t:find("%d") and math.huge or linhas(t) end
    local texto, n = Estado.falaQueCabe(s, agora, semMetricas, max_linhas, TENTATIVAS)
    if texto and texto:find("%d") then texto, n = nil, 0 end
    cache.texto, cache.marca, cache.t = texto, marca, agora
    return texto, n
end

-- Pixel balloon -------------------------------------------------------------------

-- The same balloon as the Yomimon screen (YomimonScreen:balao, Figma 28:5911): border of 3, pixel shadow on the right and
-- below, tail in the middle at the bottom. The measures are Figma's, in points; the balloon's "pixel" (u) is 3
-- points. bw and bh are the width and height of the balloon without the shadow and the tail.
local function pintarBalao(bb, bx, by, bw, bh, u)
    local PRETO, BRANCO = Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    local k = u / 3
    local W, H = bw / k, bh / k
    local function r(rx, ry, rw, rh, cor)
        local x0, y0 = bx + math.floor(rx * k + 0.5), by + math.floor(ry * k + 0.5)
        local x1, y1 = bx + math.floor((rx + rw) * k + 0.5), by + math.floor((ry + rh) * k + 0.5)
        bb:paintRect(x0, y0, x1 - x0, y1 - y0, cor)
    end
    local t = math.floor(W / 2) - 7          -- start of the tail
    r(3, 3, W - 6, H - 3, BRANCO)            -- background
    r(6, 0, W - 12, 3, PRETO)                -- top
    r(3, 3, 3, 3, PRETO); r(W - 6, 3, 3, 3, PRETO)
    r(0, 6, 3, H - 9, PRETO)                 -- left side
    r(3, H - 3, 3, 3, PRETO)
    r(W - 3, 6, 3, H - 3, PRETO)             -- right side
    r(W - 6, H - 3, 3, 6, PRETO)
    r(W, 9, 3, H - 3, PRETO)                 -- shadow on the right
    r(W + 3, 12, 3, H - 6, PRETO)
    r(6, H, W - 12, 3, PRETO)                -- base
    r(9, H + 3, W - 9, 3, PRETO)             -- shadow below
    r(12, H + 6, W - 9, 3, PRETO)
    r(t, H + 6, 3, 3, PRETO)                 -- tail
    r(t + 4, H + 9, 9, 3, PRETO); r(t + 7, H + 12, 3, 3, PRETO)
    r(t + 1, H, 15, 3, BRANCO); r(t + 4, H + 3, 9, 3, BRANCO); r(t + 7, H + 6, 3, 3, BRANCO)
end

-- From the end of the balloon (bh) to the tip of the tail: 15 Figma points, 5 "pixels".
local function rabinho(u) return 5 * u end

local function pintarTexto(bb, texto, face, tx, ty, largura, altura)
    local caixa = TextBoxWidget:new{
        text = texto,
        face = face,
        width = largura,
        height = altura,
        height_overflow_show_ellipsis = true,
        alignment = "center",
    }
    local th = caixa:getSize().h
    caixa:paintTo(bb, tx, ty + math.max(0, math.floor((altura - th) / 2)))
    caixa:free()
end

-- The drawing ---------------------------------------------------------------------

-- Where the painted pixels of a 64x64 drawing are (offset and size, in drawing pixels).
local caixas = {}
local function caixaDoDesenho(nome)
    local real = Desenho.resolver(nome)
    if not caixas[real] then
        local x0, y0, x1, y1 = math.huge, math.huge, 0, 0
        for j, l in ipairs(Desenho.sprite(real) or {}) do
            local a = l:find("[#1234%+]")
            if a then
                local b = #l - l:reverse():find("[#1234%+]") + 1
                x0, x1, y0, y1 = math.min(x0, a), math.max(x1, b), math.min(y0, j), math.max(y1, j)
            end
        end
        if x0 == math.huge then x0, y0, x1, y1 = 1, 1, Desenho.LARGURA, Desenho.ALTURA end
        caixas[real] = { x = x0 - 1, y = y0 - 1, w = x1 - x0 + 1, h = y1 - y0 + 1 }
    end
    return caixas[real]
end

-- The drawing's tones (those of yomimon_drawing.lua). The little shadow under it is the light grey ("3") on the two
-- last lines with pixels; on the wood of Bookshelf's shelf it disappears, so here it is painted with the dark
-- grey. The same tone "3" in the body does not change, and the drawing stays the same in the rest of the plugin.
local TONS = {
    ["#"] = Blitbuffer.COLOR_BLACK,
    ["1"] = Blitbuffer.Color8(0x55),
    ["2"] = Blitbuffer.Color8(0x88),
    ["3"] = Blitbuffer.Color8(0xBB),
    ["4"] = Blitbuffer.Color8(0xEE),
    ["+"] = Blitbuffer.COLOR_GRAY,
}
local TOM_DA_SOMBRA = "1"

-- Like Desenho.pintarSprite (each pixel becomes a square of `escala` px), with the darker little shadow.
local function pintarDesenho(bb, nome, x, y, escala)
    local linhas = Desenho.sprite(nome)
    if not linhas then return end
    local c = caixaDoDesenho(nome)
    local sombra_desde = c.y + c.h - 1  -- the last two lines with pixels
    for j, linha in ipairs(linhas) do
        local i, n = 1, #linha
        while i <= n do
            local tom = linha:sub(i, i)
            local k = i
            while k < n and linha:sub(k + 1, k + 1) == tom do k = k + 1 end
            if tom == "3" and j >= sombra_desde then tom = TOM_DA_SOMBRA end
            local cor = TONS[tom]
            if cor then
                bb:paintRect(x + (i - 1) * escala, y + (j - 1) * escala, (k - i + 1) * escala, escala, cor)
            end
            i = k + 1
        end
    end
end

-- The box of the current drawing together with that of the stage's drawing: its size does not change with each expression.
local function caixaDela(sprite)
    local a, b = caixaDoDesenho(sprite), caixaDoDesenho(sprite:match("^([^_]+)") or sprite)
    local x0, y0 = math.min(a.x, b.x), math.min(a.y, b.y)
    local x1, y1 = math.max(a.x + a.w, b.x + b.w), math.max(a.y + a.h, b.y + b.h)
    return { x = x0, y = y0, w = x1 - x0, h = y1 - y0 }
end

-- What each card on screen drew last (drawing and phrase), by the card's key. on_minute
-- compares it with the current one and only redraws the card when something changed: without change, the screen does not flicker.
local desenhado = {}

local function chaveDo(ctx)
    local id = ctx and ctx.entry and ctx.entry.id
    return id and (tostring(ctx.surface) .. ":" .. tostring(id)) or nil
end

-- The card ----------------------------------------------------------------------------

local Cartao = Widget:extend{
    traca = nil,
    largura = 0,
    altura = 0,
    forma = "largo",
    estante = false,    -- standing on the shelf, among the books
    capas = false,      -- on the covers shelf: at mid height, like the covers, instead of standing
    so_desenho = false, -- in the list of modules to add: only Yomimon, without a phrase
    chave = nil,        -- so on_minute knows what this card drew
}

function Cartao:init()
    -- the balloon's "pixel" (3 Figma points), the same as the Simple UI card
    self.u = math.max(2, math.floor(Screen:getWidth() / 618 * 3 + 0.5))
end

function Cartao:getSize()
    return Geom:new{ w = self.largura, h = self.altura }
end

function Cartao:paintTo(bb, x, y)
    self.dimen = Geom:new{ x = x, y = y, w = self.largura, h = self.altura }
    local w, h, u = self.largura, self.altura, self.u
    local traca = self.traca
    local sprite = "bola"
    if traca then
        local agora = os.time()
        Estado.passarTempo(traca.estado, agora)
        sprite = Estado.sprite(traca.estado, agora)
    end
    local caixa = caixaDela(sprite)
    local function escalaPara(altura) return math.floor(math.min(w * 0.9 / caixa.w, altura / caixa.h)) end

    -- the balloon: up to 2 lines, at most 90 "pixels" wide, and only as wide as the phrase. It goes on the wide
    -- card; on the shelf, where the shelf height is large, already from 56 "pixels" of width, so
    -- Yomimon does not take the whole shelf. Below 70, the font is the smallest of the Simple UI card.
    local balao
    local quer_balao = self.forma == "largo" or (self.estante and w >= 56 * u)
    if traca and not self.so_desenho and quer_balao then
        local pad_x, pad_y = 4 * u, 3 * u
        local bw = math.min(w - 4 * u, 90 * u)
        local face, largura = fonte(bw >= 70 * u and 5 * u or 4 * u), bw - 2 * pad_x
        if largura >= 30 * u then
            local lh = alturaDaLinha(face, largura)
            local max_linhas = 2
            local ok, texto, n = pcall(textoDoBalao, traca,
                function(t) return contarLinhas(t, face, largura) end, max_linhas)
            if not ok then
                logger.warn("Yomimon: could not pick the Bookshelf card text:", texto)
                texto, n = nil, 0
            end
            if texto then bw = math.max(20 * u, math.min(bw, larguraDoTexto(texto, face, largura) + 2 * pad_x + u)) end
            local bh = math.min(n or 1, max_linhas) * lh + 2 * pad_y
            -- only with a balloon if there is still room for Yomimon at least at twice the drawing's size
            if texto and escalaPara(h - bh - rabinho(u) - u) >= 2 then
                balao = { texto = texto, face = face, w = bw, h = bh, pad_x = pad_x, pad_y = pad_y }
            end
        end
    end

    -- its size and the height of the group (balloon + tail + Yomimon). On the shelf, without a balloon it keeps the size
    -- it would have with a 2-line balloon: it is not bigger than the books and does not grow when the balloon goes away.
    local acima = balao and (balao.h + rabinho(u) + u) or 0
    local reserva = acima
    if self.estante and not balao then
        reserva = 2 * alturaDaLinha(fonte(5 * u), 50 * u) + 6 * u + rabinho(u) + u
    end
    local escala = math.max(1, escalaPara(h - reserva))
    local total = acima + caixa.h * escala
    local em_pe = self.estante and not self.capas
    local topo = em_pe and (y + h - total) or (y + math.floor((h - total) / 2))
    if self.chave then
        desenhado[self.chave] = { sprite = Desenho.resolver(sprite), fala = balao ~= nil, marca = cache.marca, t = cache.t }
    end

    if balao then
        local bx = x + math.floor((w - balao.w) / 2)
        pintarBalao(bb, bx, topo, balao.w, balao.h, u)
        pintarTexto(bb, balao.texto, balao.face, bx + balao.pad_x, topo + balao.pad_y,
            balao.w - 2 * balao.pad_x, balao.h - 2 * balao.pad_y)
    end
    -- the drawing is positioned by its painted pixels (its empty margin may sit under the balloon)
    local sx = x + math.floor((w - caixa.w * escala) / 2) - caixa.x * escala
    local sy = topo + acima - caixa.y * escala
    pintarDesenho(bb, sprite, sx, sy, escala)
end

-- Protection: if the card fails to draw, Bookshelf carries on (the card stays blank).
require("yomimon_guard").padrao:envolver(Cartao, { "paintTo" })

-- The module for Bookshelf (the format is in bookshelf.koplugin/micromodules/README.md) ----------

function Bookshelf.modulo(pasta)
    pasta_modulos = pasta
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
            return Cartao:new{
                traca = instancia(),
                largura = w,
                altura = h,
                forma = FORMAS[ctx.shape] or formaDe(w, h),
                estante = ctx.surface == "shelf",
                capas = ctx.shelf_view == "covers",
                so_desenho = ctx.preview or ctx.surface == "picker",
                chave = chaveDo(ctx),
            }
        end,

        -- Once a minute, with the card on screen: redraws only when its drawing changes (an expression without its own
        -- drawing falls back to the stage's, and then nothing changes) or when the balloon's phrase would change (the mark changed or
        -- the 20 minutes passed).
        on_minute = function(ctx)
            local antes = desenhado[chaveDo(ctx)]
            local traca = antes and instancia()
            if not traca or type(ctx.refresh) ~= "function" then return end
            local agora = os.time()
            Estado.passarTempo(traca.estado, agora)
            local mudou = Desenho.resolver(Estado.sprite(traca.estado, agora)) ~= antes.sprite
            if not mudou and antes.fala then
                mudou = marcaDe(traca.estado, agora) ~= antes.marca or agora - (antes.t or 0) >= TROCA_SEGUNDOS
            end
            if mudou then ctx.refresh() end
        end,

        on_tap = function(_ctx)
            local traca = instancia()
            if traca then traca:onMostrarTraca() end
        end,
    }
end

return Bookshelf
