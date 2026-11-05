--[[--
Integração com o Bookshelf: um cartão da Yomimon (um "micro-module" dele) na tela inicial, no menu inicial e
na estante, no meio dos livros. O Bookshelf acha bookshelf_modules/yomimon.lua dentro da pasta do plugin e
pede o desenho aqui; quem decide o tamanho do cartão é ele (a pessoa redimensiona à vontade). Se o
Bookshelf não estiver instalado, nada disto é usado.

Duas versões, pelo formato do cartão:
  estreito (quadrado ou alto)  só ela, para quem quer economizar espaço
  largo                        o balão em cima com até 2 linhas (o texto do cartão do Simple UI), o mesmo
                               balão da tela da Yomimon, e ela embaixo
  estante                      o balão já aparece num espaço mais estreito (a prateleira é alta), com a letra
                               menor se precisar, para ela não ocupar a prateleira inteira; ela fica em pé
                               na prateleira (na estante de capas, no meio da altura, como as capas)
O balão tem a largura da fala. Ela fica do maior tamanho que couber; o balão pode descer até as antenas,
porque o desenho tem margem vazia em cima. Num cartão largo baixo demais para os dois, ou na lista de
módulos para adicionar, fica só ela. Fora da estante, o conjunto fica no meio da altura.
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

-- O kit de módulos do Bookshelf (o Bookshelf já está carregado quando este arquivo é usado).
local ok_kit, Kit = pcall(require, "lib/bookshelf_module_kit")
if not ok_kit or type(Kit) ~= "table" then Kit = nil end

-- A pasta bookshelf_modules da Yomimon (o Bookshelf a passa para bookshelf_modules/yomimon.lua).
local pasta_modulos

-- A Yomimon aberta agora (biblioteca ou leitor). O Bookshelf 6.1 acha a instância pela pasta do plugin
-- (Kit.plugin); num Bookshelf mais antigo, fica a que o main.lua guarda no Screensaver ao iniciar.
local function instancia()
    if Kit and Kit.plugin and pasta_modulos then
        local ok, traca = pcall(Kit.plugin, pasta_modulos)
        if ok and traca then return traca end
    end
    local ok, Screensaver = pcall(require, "ui/screensaver")
    return ok and Screensaver and Screensaver.yomimon_instancia or nil
end

-- Formato do cartão pela proporção (os mesmos limites do Bookshelf).
local function formaDe(w, h)
    if not h or h <= 0 then return "quadrado" end
    local r = w / h
    if r >= 1.6 then return "largo" end
    if r <= 0.7 then return "alto" end
    return "quadrado"
end

local FORMAS = { wide = "largo", tall = "alto", square = "quadrado" }

-- Texto do balão ------------------------------------------------------------------

-- O mesmo pensamento até ela comer, dormir/acordar ou passarem 20 minutos (como no Simple UI).
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

-- Largura da linha mais longa da fala quebrada em `largura` (para o balão ficar do tamanho do texto).
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

-- O que, mudando, troca a fala: a fase, se ela está dormindo e as páginas lidas.
local function marcaDe(s, agora)
    local e = Estado.expressao(s, agora)
    return table.concat({ Estado.fase(s).nome, tostring(e == "dormindo" or e == "casulo"), s.paginas or 0 }, ":")
end

-- Uma fala que caiba em `max_linhas`; guarda a escolhida e só troca quando a marca muda ou o tempo passa.
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

-- Balão de pixels -------------------------------------------------------------------

-- O mesmo balão da tela da Yomimon (YomimonScreen:balao, Figma 28:5911): borda de 3, sombra de pixels à direita e
-- embaixo, rabinho no meio embaixo. As medidas são as do Figma, em pontos; o "pixel" do balão (u) tem 3
-- pontos. bw e bh são a largura e a altura do balão sem a sombra e o rabinho.
local function pintarBalao(bb, bx, by, bw, bh, u)
    local PRETO, BRANCO = Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    local k = u / 3
    local W, H = bw / k, bh / k
    local function r(rx, ry, rw, rh, cor)
        local x0, y0 = bx + math.floor(rx * k + 0.5), by + math.floor(ry * k + 0.5)
        local x1, y1 = bx + math.floor((rx + rw) * k + 0.5), by + math.floor((ry + rh) * k + 0.5)
        bb:paintRect(x0, y0, x1 - x0, y1 - y0, cor)
    end
    local t = math.floor(W / 2) - 7          -- começo do rabinho
    r(3, 3, W - 6, H - 3, BRANCO)            -- fundo
    r(6, 0, W - 12, 3, PRETO)                -- topo
    r(3, 3, 3, 3, PRETO); r(W - 6, 3, 3, 3, PRETO)
    r(0, 6, 3, H - 9, PRETO)                 -- lado esquerdo
    r(3, H - 3, 3, 3, PRETO)
    r(W - 3, 6, 3, H - 3, PRETO)             -- lado direito
    r(W - 6, H - 3, 3, 6, PRETO)
    r(W, 9, 3, H - 3, PRETO)                 -- sombra à direita
    r(W + 3, 12, 3, H - 6, PRETO)
    r(6, H, W - 12, 3, PRETO)                -- base
    r(9, H + 3, W - 9, 3, PRETO)             -- sombra embaixo
    r(12, H + 6, W - 9, 3, PRETO)
    r(t, H + 6, 3, 3, PRETO)                 -- rabinho
    r(t + 4, H + 9, 9, 3, PRETO); r(t + 7, H + 12, 3, 3, PRETO)
    r(t + 1, H, 15, 3, BRANCO); r(t + 4, H + 3, 9, 3, BRANCO); r(t + 7, H + 6, 3, 3, BRANCO)
end

-- Do fim do balão (bh) até a ponta do rabinho: 15 pontos do Figma, 5 "pixels".
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

-- O desenho dela ---------------------------------------------------------------------

-- Onde estão os pixels pintados de um desenho de 64x64 (deslocamento e tamanho, em pixels do desenho).
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

-- Os tons do desenho (os de yomimon_drawing.lua). A sombrinha embaixo dela é o cinza claro ("3") nas duas
-- últimas linhas com pixels; na madeira da prateleira do Bookshelf ela some, então aqui ela é pintada com o
-- cinza escuro. O mesmo tom "3" no corpo dela não muda, e o desenho fica igual em todo o resto do plugin.
local TONS = {
    ["#"] = Blitbuffer.COLOR_BLACK,
    ["1"] = Blitbuffer.Color8(0x55),
    ["2"] = Blitbuffer.Color8(0x88),
    ["3"] = Blitbuffer.Color8(0xBB),
    ["4"] = Blitbuffer.Color8(0xEE),
    ["+"] = Blitbuffer.COLOR_GRAY,
}
local TOM_DA_SOMBRA = "1"

-- Como Desenho.pintarSprite (cada pixel vira um quadrado de `escala` px), com a sombrinha mais escura.
local function pintarDesenho(bb, nome, x, y, escala)
    local linhas = Desenho.sprite(nome)
    if not linhas then return end
    local c = caixaDoDesenho(nome)
    local sombra_desde = c.y + c.h - 1  -- as duas últimas linhas com pixels
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

-- A caixa do desenho de agora junto com a do desenho da fase: o tamanho dela não muda a cada expressão.
local function caixaDela(sprite)
    local a, b = caixaDoDesenho(sprite), caixaDoDesenho(sprite:match("^([^_]+)") or sprite)
    local x0, y0 = math.min(a.x, b.x), math.min(a.y, b.y)
    local x1, y1 = math.max(a.x + a.w, b.x + b.w), math.max(a.y + a.h, b.y + b.h)
    return { x = x0, y = y0, w = x1 - x0, h = y1 - y0 }
end

-- O que cada cartão na tela desenhou por último (desenho e fala), pela chave do cartão. O on_minute
-- compara com o de agora e só redesenha o cartão quando algo mudou: sem mudança, a tela não pisca.
local desenhado = {}

local function chaveDo(ctx)
    local id = ctx and ctx.entry and ctx.entry.id
    return id and (tostring(ctx.surface) .. ":" .. tostring(id)) or nil
end

-- O cartão ----------------------------------------------------------------------------

local Cartao = Widget:extend{
    traca = nil,
    largura = 0,
    altura = 0,
    forma = "largo",
    estante = false,    -- em pé na prateleira, no meio dos livros
    capas = false,      -- na estante de capas: no meio da altura, como as capas, em vez de em pé
    so_desenho = false, -- na lista de módulos para adicionar: só ela, sem fala
    chave = nil,        -- para o on_minute saber o que este cartão desenhou
}

function Cartao:init()
    -- "pixel" do balão (3 pontos do Figma), o mesmo do cartão do Simple UI
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

    -- o balão: até 2 linhas, no máximo 90 "pixels" de largura, e só da largura da fala. Vai no cartão
    -- largo; na estante, onde a altura da prateleira é grande, já a partir de 56 "pixels" de largura, para
    -- ela não ocupar a prateleira inteira. Abaixo de 70, a letra fica a menor do cartão do Simple UI.
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
                logger.warn("Yomimon: could not pick o texto do cartão do Bookshelf:", texto)
                texto, n = nil, 0
            end
            if texto then bw = math.max(20 * u, math.min(bw, larguraDoTexto(texto, face, largura) + 2 * pad_x + u)) end
            local bh = math.min(n or 1, max_linhas) * lh + 2 * pad_y
            -- só com balão se ainda sobrar lugar para ela em pelo menos o dobro do tamanho do desenho
            if texto and escalaPara(h - bh - rabinho(u) - u) >= 2 then
                balao = { texto = texto, face = face, w = bw, h = bh, pad_x = pad_x, pad_y = pad_y }
            end
        end
    end

    -- tamanho dela e altura do conjunto (balão + rabinho + ela). Na estante, sem balão ela fica do tamanho
    -- que teria com um balão de 2 linhas: não fica maior que os livros nem cresce quando o balão some.
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
    -- o desenho é posicionado pelos pixels pintados (a margem vazia dele pode ficar por baixo do balão)
    local sx = x + math.floor((w - caixa.w * escala) / 2) - caixa.x * escala
    local sy = topo + acima - caixa.y * escala
    pintarDesenho(bb, sprite, sx, sy, escala)
end

-- Proteção: se o cartão falhar ao desenhar, o Bookshelf continua (o cartão fica em branco).
require("yomimon_guard").padrao:envolver(Cartao, { "paintTo" })

-- O módulo para o Bookshelf (o formato está em bookshelf.koplugin/micromodules/README.md) ----------

function Bookshelf.modulo(pasta)
    pasta_modulos = pasta
    return {
        key = "yomimon",  -- fica gravado nos layouts das pessoas: nunca mudar
        title = T"Yomimon",
        summary = T"Seu Pokémon. Funciona sem internet.",
        bare = true,          -- sem cartão por trás: ela e o balão direto no fundo, como no Simple UI
        -- ela se ajusta sozinha ao tamanho do cartão (o desenho em passos inteiros): o Bookshelf 6.1 desenha
        -- uma vez só, no tamanho do cartão, em vez de procurar um tamanho de letra
        self_sized = true,
        tap_feedback = true,  -- tocar abre a tela dela
        -- ao ser adicionado, começa com 2 de largura e 1 de altura: a versão com balão. O Bookshelf não tem
        -- largura máxima; mais largo só sobra espaço em volta, o desenho não muda.
        start_w = 2,
        start_h = 1,
        min_w = 1,
        min_h = 1,

        render = function(ctx)
            local w = math.max(1, math.floor(ctx.width or 0))
            local h = (ctx.height and ctx.height > 0) and math.floor(ctx.height) or nil
            if not h then
                -- menu inicial e lista para adicionar: altura natural, a do cartão do Simple UI
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

        -- Uma vez por minuto, com o cartão na tela: redesenha só quando o desenho dela muda (uma expressão sem
        -- desenho próprio cai no da fase, e aí nada muda) ou quando a fala do balão trocaria (a marca mudou ou
        -- passaram os 20 minutos).
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
