--[[--
Simple UI integration: a Yomimon card on the home screen and a quick-action button with its little face.
Uses Simple UI's public plugin API (moduleregistry and sui_quickactions); if Simple UI is not installed,
nothing happens.

]]

local Device = require("device")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local InputContainer = require("ui/widget/container/inputcontainer")
local LeftContainer = require("ui/widget/container/leftcontainer")
local ProgressWidget = require("ui/widget/progresswidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Blitbuffer = require("ffi/blitbuffer")
local logger = require("logger")
local Widget = require("ui/widget/widget")
local Screen = Device.screen

local Desenho = require("yomimon_drawing")
local T = require("yomimon_language").t
local Estado = require("yomimon_state")

local Integracao = {}

-- These ids keep the old names: Simple UI saves them in the user's layout, and renaming would orphan the saved
-- home card and quick-menu shortcut.
local MODULO_ID = "traca_cartao"
local ACAO_ID = "traca_abrir"

--- SVG icon of the button: a ball, the same for every species (their sprite is downloaded, it does not ship with the plugin).
function Integracao.icone(traca)
    return traca.path .. "/icons/bola.svg"
end

-- Home screen card --------------------------------------------------------

-- Balloon text: its thought (the same phrases as the main screen). It stays the same until
-- it eats, sleeps/wakes or 20 minutes pass, so it does not change on every Home redraw.
local TROCA_SEGUNDOS = 20 * 60
local MAX_LINHAS = 2        -- the card's balloon is small: at most 2 lines
local TENTATIVAS = 12       -- how many phrases it draws looking for one that fits (12 since step 4 of the voice:
                            -- the phrases that match it are the variants, a bit longer)
local cartao_cache = {}

-- In how many lines the text wraps in this font and width (TextBoxWidget itself tells).
local function contarLinhas(texto, face, largura)
    local ok, n = pcall(function()
        local c = TextBoxWidget:new{ text = texto, face = face, width = largura, alignment = "center" }
        local n = c.vertical_string_list and #c.vertical_string_list or math.huge
        c:free()
        return n
    end)
    return ok and n or math.huge
end

-- linhas(texto): how many lines the phrase takes in the balloon. Returns the text and the lines.
local function textoDoCartao(traca, linhas)
    local s, agora = traca.estado, os.time()
    local e = Estado.expressao(s, agora)
    local marca = table.concat({ Estado.fase(s).nome, tostring(e == "dormindo" or e == "casulo"), s.paginas or 0 }, ":")
    if cartao_cache.texto and cartao_cache.marca == marca and agora - cartao_cache.t < TROCA_SEGUNDOS then
        return cartao_cache.texto, linhas(cartao_cache.texto)
    end
    local texto, n = Estado.falaQueCabe(s, agora, linhas, MAX_LINHAS, TENTATIVAS)
    cartao_cache.texto, cartao_cache.marca, cartao_cache.t = texto, marca, agora
    return texto, n
end

-- The UI font, like the other Simple UI widgets; the pixel font stays inside the Yomimon screens.
local function fonte(tam_px)
    return Font:getFace("cfont", tam_px / (Screen:scaleBySize(1000) / 1000))
end

-- Card: Yomimon on the left and a pixel balloon (tail pointing at it) on the right.
local Cartao = Widget:extend{ traca = nil, largura = 0 }

function Cartao:init()
    self.u = math.max(2, math.floor(Screen:getWidth() / 618 * 3 + 0.5))   -- the balloon's "pixel" (3 Figma points)
    self.escala = math.max(2, math.floor(Screen:getHeight() * 0.16 / Desenho.ALTURA))
    self.lado = self.escala * Desenho.ALTURA
    self.altura = self.lado
end

function Cartao:getSize()
    return Geom:new{ w = self.largura, h = self.altura }
end

function Cartao:paintTo(bb, x, y)
    self.dimen = Geom:new{ x = x, y = y, w = self.largura, h = self.altura }
    local s, agora = self.traca.estado, os.time()
    Estado.passarTempo(s, agora)
    Desenho.pintarSprite(bb, Estado.sprite(s, agora), x, y, self.escala)

    local u, PRETO, BRANCO = self.u, Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    local bx = x + self.lado + 4 * u          -- start of the balloon (the tail comes before)
    local bw = math.floor((self.largura - (bx - x) - 2 * u) * 0.72)  -- does not take the whole width
    local bh = math.floor(self.altura * 0.62)
    local by = y + math.floor((self.altura - bh) / 2)
    local function r(rx, ry, rw, rh, cor) bb:paintRect(rx, ry, rw, rh, cor) end
    -- shadow, background and border with clipped corners
    r(bx + 3 * u, by + 2 * u, bw - 2 * u, bh, PRETO)
    r(bx + 2 * u, by + 3 * u, bw, bh - 2 * u, PRETO)
    r(bx + u, by + u, bw - 2 * u, bh - 2 * u, BRANCO)
    r(bx + u, by, bw - 2 * u, u, PRETO)
    r(bx + u, by + bh - u, bw - 2 * u, u, PRETO)
    r(bx, by + u, u, bh - 2 * u, PRETO)
    r(bx + bw - u, by + u, u, bh - 2 * u, PRETO)
    -- tail pointing at Yomimon
    local ty = by + math.floor(bh / 2) - u
    r(bx, ty - u, u, 4 * u, BRANCO)
    r(bx - u, ty - u, u, u, PRETO)
    r(bx - 2 * u, ty, u, u, PRETO)
    r(bx - 3 * u, ty + u, u, u, PRETO)
    r(bx - 2 * u, ty + 2 * u, u, u, PRETO)
    r(bx - u, ty + 2 * u, u, u, PRETO)
    r(bx - u, ty, u, 2 * u, BRANCO)
    r(bx - 2 * u, ty + u, u, u, BRANCO)
    -- text: its thought, centred in the balloon, in at most 2 lines (picks a phrase that fits;
    -- if none fits, a slightly smaller font and, last, "…")
    local pad = 4 * u
    local face, largura = fonte(5 * u), bw - 2 * pad
    local ok, texto, n = pcall(textoDoCartao, self.traca, function(t) return contarLinhas(t, face, largura) end)
    if not ok then
        logger.warn("Yomimon: could not pick the card text:", texto)
        texto, n = "…", 1
    end
    if (n or 0) > MAX_LINHAS then
        local menor = fonte(4 * u)
        if contarLinhas(texto, menor, largura) <= MAX_LINHAS then face = menor end
    end
    local caixa = TextBoxWidget:new{
        text = texto,
        face = face,
        width = largura,
        height = bh - 2 * pad,
        height_overflow_show_ellipsis = true,
        alignment = "center",
    }
    local th = caixa:getSize().h
    caixa:paintTo(bb, bx + pad, by + math.max(pad, math.floor((bh - th) / 2)))
    caixa:free()
end

-- Protection: if the card fails to draw, the Home carries on (the card stays blank).
require("yomimon_guard").padrao:envolver(Cartao, { "paintTo" })

local function criarModulo(traca)
    local M = {}
    M.id = MODULO_ID
    M.name = T"Yomimon"
    M.label = nil
    M.enabled_key = "yomimon_cartao_enabled"
    M.default_on = true

    function M.build(w, _ctx)
        local ok, cartao = pcall(function()
            local c = Cartao:new{ traca = traca, largura = w }
            local ic = InputContainer:new{ dimen = Geom:new{ w = w, h = c.altura }, c }
            ic.ges_events = {
                TapTraca = { GestureRange:new{ ges = "tap", range = function() return c.dimen end } },
            }
            function ic:onTapTraca()
                traca:onMostrarTraca()
                return true
            end
            return ic
        end)
        if not ok then
            logger.warn("Yomimon: could not build the Simple UI card:", cartao)
            return nil
        end
        return cartao
    end

    function M.getHeight(_ctx)
        return math.max(2, math.floor(Screen:getHeight() * 0.16 / Desenho.ALTURA)) * Desenho.ALTURA
    end

    function M.getMenuItems(_ctx_menu)
        return nil
    end

    return M
end

-- Registration ------------------------------------------------------------------------

function Integracao.registrar(traca)
    local ok_reg, Registry = pcall(require, "modules/moduleregistry")
    if ok_reg and type(Registry) == "table" and Registry.register then
        local ok, err = pcall(Registry.register, criarModulo(traca))
        if not ok then logger.warn("Yomimon: could not register the Simple UI card:", err) end
    end

    -- The button uses a bigger Simple UI module; register after everything has loaded.
    UIManager:nextTick(function()
        local ok_qa, QA = pcall(require, "features/sui_quickactions")
        if not (ok_qa and type(QA) == "table" and QA.register) then return end
        local ok, err = pcall(QA.register, {
            id = ACAO_ID,
            label = T"Yomimon",
            icon = traca.path .. "/icons/bola.svg",
            get_icon = function() return Integracao.icone(traca) end,
            is_in_place = true,
            is_async_in_place = true,
            execute = function(_ctx) traca:onMostrarTraca() end,
        })
        if not ok then logger.warn("Yomimon: could not register the Simple UI button:", err) end
    end)
end

-- Yomimon in place of the Tiny Critter ---------------------------------------------------------
-- Simple UI's Tiny Critter accepts the user's critters in <settings>/simpleui/sui_critters/ (a loose PNG
-- serves every mood) and phrases in phrases.lua. Yomimon writes the sprite of its current form and its phrases
-- there and picks that critter: the balloon, the chat and the mood stay Simple UI's own.

local MARCA_FRASES = "-- yomimon"
local HUMOR_DA_EXPRESSAO = { feliz = "happy", triste = "sad", dormindo = "sleepy", casulo = "sleepy", normal = "neutral" }

local function pastaCritters()
    return require("datastorage"):getSettingsDir() .. "/simpleui/sui_critters"
end

-- The drawing goes out at its own pixel size, only cropped to where it is painted: Simple UI sizes a critter by
-- its image height, so the empty margin of the 64x64 grid made it look small. RGBA with a transparent
-- background, like the bundled critters, so night mode shows no white box.
local ALTURA_CRITTER_PADRAO = 40

local function alturaDaTela()
    local caixa = Screen:scaleBySize(104)
    local fator = math.max(1, math.floor(caixa / ALTURA_CRITTER_PADRAO))
    return math.min(math.floor(caixa / fator), require("yomimon_sprite").LADO)
end

local function gravarSprite(traca, pasta)
    local Sprite = require("yomimon_sprite")
    local linhas = Desenho.sprite(Estado.fase(traca.estado).nome)
    local x0, y0, w, h = Sprite.caixa(linhas or {})
    if not x0 then return false end
    -- Simple UI derives the pixel factor it shares with the decorations from the image height, so every form
    -- goes out on a canvas of the height that gives the same factor as its 40px critters. Only taller forms
    -- are shrunk to fit it.
    local altura = alturaDaTela()
    local h2 = math.min(h, altura)
    local w2 = math.max(1, math.floor(w * h2 / h + 0.5))
    local topo = altura - h2
    local bb = Blitbuffer.new(w2, altura, Blitbuffer.TYPE_BBRGB32)
    -- Light mode draws the alpha channel over black, so the background is opaque white there; night mode keeps it
    -- transparent because Simple UI undoes the screen inversion for the critter.
    local noite = Screen.night_mode
    bb:fill(noite and Blitbuffer.ColorRGB32(0, 0, 0, 0) or Blitbuffer.ColorRGB32(255, 255, 255, 255))
    for y = 0, h2 - 1 do
        local linha = linhas[y0 + math.floor(y * h / h2) + 1]
        for x = 0, w2 - 1 do
            local sx = x0 + math.floor(x * w / w2) + 1
            local g = Sprite.cinza(linha:sub(sx, sx))
            if g then bb:setPixel(x, topo + y, Blitbuffer.ColorRGB32(g, g, g, 255)) end
        end
    end
    local caminho = pasta .. "/yomimon.png"
    local ok, gravou, err = pcall(bb.writePNG, bb, caminho)
    bb:free()
    if not (ok and gravou ~= false) then
        -- A stale image of another size would make the critter look wrong, so remove it.
        os.remove(caminho)
        logger.warn("Yomimon: could not write the critter image:", ok and err or gravou)
        return false
    end
    return true
end

-- Does not touch a phrases.lua the user wrote: only what Yomimon itself wrote.
local function gravarFrases(traca, pasta)
    local caminho = pasta .. "/phrases.lua"
    local f = io.open(caminho, "rb")
    if f then
        local inicio = f:read(#MARCA_FRASES)
        f:close()
        if inicio ~= MARCA_FRASES then return false end
    end
    local s, agora = traca.estado, os.time()
    local humor = HUMOR_DA_EXPRESSAO[Estado.expressao(s, agora)] or "neutral"
    local vistas, linhas = {}, { MARCA_FRASES, "return {" }
    for _ = 1, 60 do
        local ok, texto = pcall(Estado.fala, s, agora, nil, nil, "traca")
        if ok and type(texto) == "string" and not vistas[texto] then
            vistas[texto] = true
            linhas[#linhas + 1] = string.format("    { text = %q, mood = %q },", texto, humor)
        end
    end
    linhas[#linhas + 1] = "}"
    local out = io.open(caminho, "wb")
    if not out then return false end
    out:write(table.concat(linhas, "\n"), "\n")
    out:close()
    return true
end

--- Installs (or updates) Yomimon as a Simple UI critter and picks it. It only stops acting if the user turned the option off.
function Integracao.sincronizarCritter(traca, forcar)
    if not forcar and G_reader_settings:isFalse("yomimon_critter") then return false end
    if not pcall(require, "modules/moduleregistry") then return false end
    local ok, err = pcall(function()
        local util = require("util")
        local pasta = pastaCritters()
        util.makePath(pasta)
        gravarSprite(traca, pasta)
        gravarFrases(traca, pasta)
        local SUISettings = require("infra/sui_store")
        if forcar or not G_reader_settings:isTrue("yomimon_critter_escolhido") then
            SUISettings:set("simpleui_critter_cfg_pick", "yomimon")
            G_reader_settings:saveSetting("yomimon_critter_escolhido", true)
        end
        local engine = package.loaded["engines/sui_screen_engine"]
        if engine then engine.refreshAllLiveImmediate(false) end
    end)
    if not ok then logger.warn("Yomimon: could not install the Simple UI critter:", err) end
    return ok
end

return Integracao
