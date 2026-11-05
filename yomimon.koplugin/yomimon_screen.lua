--[[--
Tela da Yomimon, desenhada como no Figma ("Yomimon Agent Sprites", 618x824).

Tudo é pintado direto na tela em coordenadas do Figma multiplicadas por K
(no Paperwhite 1236x1648, K = 2). A fonte é a Silkscreen (OFL), em fonts/.

Toques: no bichinho = carinho; segurar no bichinho = menu (tela de descanso,
idioma); no X = fechar.
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

local Desenho = require("yomimon_drawing")
local T = require("yomimon_language").t
local Estado = require("yomimon_state")
local Memoria = require("yomimon_memory")
local Tracos = require("yomimon_traits")

local QUADRO_SEGUNDOS = 1.2      -- tempo entre quadros da animação
local ANIMACAO_MINUTOS = 5       -- animação normal para sozinha depois disso

local LARG, ALT = 618, 824       -- tamanho do frame no Figma

local PRETO = Blitbuffer.COLOR_BLACK
local BRANCO = Blitbuffer.COLOR_WHITE
local CINZA_55 = Blitbuffer.Color8(0x55)
local CINZA_BB = Blitbuffer.Color8(0xBB)

-- Ícones do cartão de status, em pontos do Figma (x, y, largura, altura), relativos ao cartão.
local ICONE_LIVRO = {
    { 17, 17, 12, 3 }, { 35, 17, 12, 3 }, { 14, 20, 3, 3 }, { 29, 20, 6, 3 }, { 47, 20, 3, 3 },
    { 14, 23, 3, 3 }, { 29, 23, 6, 3 }, { 47, 23, 3, 3 }, { 14, 26, 3, 3 }, { 29, 26, 6, 3 },
    { 47, 26, 3, 3 }, { 14, 29, 3, 3 }, { 29, 29, 6, 3 }, { 47, 29, 3, 3 }, { 14, 32, 12, 3 },
    { 29, 32, 6, 3 }, { 38, 32, 12, 3 }, { 26, 35, 12, 3 },
}
local ICONE_CARA = {
    { 25, 62, 15, 3 }, { 22, 65, 3, 3 }, { 40, 65, 3, 3 }, { 19, 68, 3, 3 }, { 43, 68, 3, 3 },
    { 19, 71, 3, 3 }, { 25, 71, 6, 3 }, { 34, 71, 6, 3 }, { 43, 71, 3, 3 }, { 19, 74, 3, 3 },
    { 43, 74, 3, 3 }, { 19, 77, 3, 3 }, { 28, 77, 9, 3 }, { 43, 77, 3, 3 }, { 19, 80, 3, 3 },
    { 25, 80, 3, 3 }, { 37, 80, 3, 3 }, { 43, 80, 3, 3 }, { 22, 83, 3, 3 }, { 40, 83, 3, 3 },
    { 25, 86, 15, 3 },
}

-- Ampulheta do cartão de fase (relativa ao cartão).
local ICONE_AMPULHETA = {
    { 14, 79, 10, 2 }, { 14, 81, 2, 2 }, { 22, 81, 2, 2 }, { 16, 83, 2, 2 }, { 20, 83, 2, 2 },
    { 18, 85, 2, 2 }, { 16, 87, 2, 2 }, { 20, 87, 2, 2 }, { 14, 89, 2, 2 }, { 18, 89, 2, 2 },
    { 22, 89, 2, 2 }, { 14, 91, 10, 2 },
}

local YomimonScreen = InputContainer:extend{
    traca = nil,    -- instância do plugin
    mensagem = nil, -- fala especial (ex.: resposta ao carinho)
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
    local tam = Screen:getSize()
    self.dimen = Geom:new{ x = 0, y = 0, w = tam.w, h = tam.h }
    -- escala do Figma para a tela, e margem para centralizar se a proporção não bater
    self.k = math.min(tam.w / LARG, tam.h / ALT)
    self.ox = math.floor((tam.w - LARG * self.k) / 2)
    self.oy = math.floor((tam.h - ALT * self.k) / 2)
    -- fator que o KOReader aplica aos tamanhos de fonte; compensado em face()
    self.fator_fonte = Screen:scaleBySize(1000) / 1000
    self.faces = {}
    self.tick = function() self:proximoQuadro() end
    self:prepararSprite()
    self:iniciarAnimacao()
end

-- Utilidades de desenho ---------------------------------------------------------

function YomimonScreen:px(v)
    return math.floor(v * self.k + 0.5)
end

--- Face da Silkscreen com altura `tam` em pontos do Figma.
function YomimonScreen:face(negrito, tam)
    local chave = (negrito and "b" or "r") .. tam
    if not self.faces[chave] then
        local arquivo = negrito and "Silkscreen-Bold.ttf" or "Silkscreen-Regular.ttf"
        local caminho = Desenho.caminhoFonte(arquivo)
        local ok, f = pcall(Font.getFace, Font, caminho, tam * self.k / self.fator_fonte)
        if not ok or not f then f = Font:getFace("cfont", tam * self.k / self.fator_fonte) end
        self.faces[chave] = f
    end
    return self.faces[chave]
end

function YomimonScreen:ret(bb, x, y, w, h, cor)
    local x0, y0 = self.ox + self:px(x), self.oy + self:px(y)
    local x1, y1 = self.ox + self:px(x + w), self.oy + self:px(y + h)
    if x1 > x0 and y1 > y0 then bb:paintRect(x0, y0, x1 - x0, y1 - y0, cor) end
end

function YomimonScreen:retangulos(bb, lista, dx, dy, cor)
    for _, r in ipairs(lista) do self:ret(bb, dx + r[1], dy + r[2], r[3], r[4], cor) end
end

--- Texto com a fonte pixel. Devolve a largura em pontos do Figma.
function YomimonScreen:texto(bb, str, x, y, negrito, tam, cor, centro_x)
    local w = TextWidget:new{ text = str, face = self:face(negrito, tam), fgcolor = cor or PRETO, padding = 0 }
    local tw = w:getSize().w
    local px_x = centro_x and (self.ox + self:px(centro_x) - math.floor(tw / 2)) or (self.ox + self:px(x))
    w:paintTo(bb, px_x, self.oy + self:px(y))
    w:free()
    return tw / self.k
end

--- Largura de um texto em pontos do Figma, sem pintar.
function YomimonScreen:larguraTexto(str, negrito, tam)
    local w = TextWidget:new{ text = str, face = self:face(negrito, tam), padding = 0 }
    local tw = w:getSize().w
    w:free()
    return tw / self.k
end

--- Texto com as letras mais juntas (kerning reduzido em `aperto` pontos por letra).
-- Pares que pedem ajuste extra, em pixels da Silkscreen (1/8 do tamanho da fonte).
-- LV: o L é vazio à direita em cima e o V afina embaixo; sem ajuste, o vão fica dobrado.
local KERNING = { LV = 1 }

function YomimonScreen:textoApertado(bb, str, x, y, negrito, tam, aperto)
    local cx, anterior = x, nil
    for letra in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if anterior then cx = cx - (KERNING[anterior .. letra] or 0) * tam / 8 end
        cx = cx + self:texto(bb, letra, cx, y, negrito, tam) - aperto
        anterior = letra
    end
end

--- Caixa com cantos recortados (borda de 3), fundo branco e sombra deslocada (como no Figma).
function YomimonScreen:cartao(bb, x, y, w, h, sombra)
    if sombra then
        self:ret(bb, x + 9, y + 6, w - 6, h, PRETO)
        self:ret(bb, x + 6, y + 9, w, h - 6, PRETO)
    end
    self:ret(bb, x + 3, y + 3, w - 6, h - 6, BRANCO)
    self:ret(bb, x + 3, y, w - 6, 3, PRETO)
    self:ret(bb, x + 3, y + h - 3, w - 6, 3, PRETO)
    self:ret(bb, x, y + 3, 3, h - 6, PRETO)
    self:ret(bb, x + w - 3, y + 3, 3, h - 6, PRETO)
end

function YomimonScreen:bolinhas(bb, x, y, cheias)
    for i = 0, 3 do
        local bx = x + 32 * i
        if i < cheias then
            self:ret(bb, bx + 3, y, 20, 26, PRETO)
            self:ret(bb, bx, y + 3, 26, 20, PRETO)
            self:ret(bb, bx + 6, y + 6, 3, 3, BRANCO)
        else
            self:ret(bb, bx + 3, y, 20, 3, CINZA_BB)
            self:ret(bb, bx + 3, y + 23, 20, 3, CINZA_BB)
            self:ret(bb, bx, y + 3, 3, 20, CINZA_BB)
            self:ret(bb, bx + 23, y + 3, 3, 20, CINZA_BB)
        end
    end
end

local function maiusculas(s)
    local ok, Utf8Proc = pcall(require, "ffi/utf8proc")
    if ok and Utf8Proc and Utf8Proc.uppercase then
        local ok2, r = pcall(Utf8Proc.uppercase, s)
        if ok2 and r then return r end
    end
    return s:upper()
end

-- Partes da tela ----------------------------------------------------------------

--- Balão de fala (Figma 28:5911): borda de 3, sombra de pixels à direita e embaixo,
-- rabinho no meio. Texto em Silkscreen Regular com 16 de respiro em cima e embaixo;
-- a altura cresce com o número de linhas.
--- Mede o balão: largura W (454, ou 560 para frases de 3+ linhas), altura H e a caixa de texto.
function YomimonScreen:medirBalao(fala)
    local function caixaPara(W)
        return TextBoxWidget:new{
            text = maiusculas(fala), face = self:face(false, 20.88),
            width = self:px(W - 47), alignment = "center",
        }
    end
    local linha = TextWidget:new{ text = "A", face = self:face(false, 20.88) }
    local lh = linha:getSize().h / self.k
    linha:free()
    local W = 454
    local caixa = caixaPara(W)
    if caixa:getSize().h / self.k > lh * 2.5 then  -- 3 linhas ou mais: alarga
        caixa:free()
        W = 560
        caixa = caixaPara(W)
    end
    local th = caixa:getSize().h / self.k
    return { W = W, H = th + 35, caixa = caixa }
end

--- Balão principal (Figma 28:5911): borda de 3, sombra de pixels, rabinho no meio embaixo.
-- topo: y do balão; sem topo, a ponta do rabinho fica em y = 234. m: medida já feita (opcional).
function YomimonScreen:balao(bb, fala, bx, topo, m)
    m = m or self:medirBalao(fala)
    local W, H = m.W, m.H
    bx = bx or ((LARG - (W + 6)) / 2)        -- centralizado contando a sombra de 6
    local by = topo or (234 - (H + 15))
    local t = math.floor(W / 2) - 7          -- começo do rabinho
    local function r(x, y, w, h, cor) self:ret(bb, bx + x, by + y, w, h, cor) end
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
    m.caixa:paintTo(bb, self.ox + self:px(bx + 28), self.oy + self:px(by + 19))
    m.caixa:free()
end

function YomimonScreen:prepararSprite()
    -- O sprite (64x64) ocupa ~295 pontos no Figma, centrado em (309.5, 412.5);
    -- escala inteira para os pixels ficarem nítidos.
    local escala = math.max(1, math.floor(295 * self.k / Desenho.LARGURA))
    local lado = escala * Desenho.LARGURA
    self.sprite_escala = escala
    self.sprite_rect = Geom:new{
        x = self.ox + self:px(309.5) - math.floor(lado / 2),
        y = self.oy + self:px(412.5) - math.floor(lado / 2),
        w = lado, h = lado,
    }
    self.fechar_rect = Geom:new{
        x = self.ox + self:px(545), y = self.oy + self:px(6), w = self:px(70), h = self:px(64),
    }
end

function YomimonScreen:paintTo(bb, x, y)
    self.dimen.x, self.dimen.y = x, y
    local s, agora = self.traca.estado, os.time()
    bb:paintRect(x, y, self.dimen.w, self.dimen.h, BRANCO)
    self.alvos = {}
    self:cabecalho(bb)
    if self.modo == "caderno" then
        self:pintarCaderno(bb, s)
    elseif self.modo == "diario" then
        self:pintarDiario(bb, s)
    elseif self.modo == "conquistas" then
        self:pintarConquistas(bb, s)
    elseif self.modo == "pokedex" then
        self:pintarPokedex(bb, s)
    elseif self.modo == "percepcao" then
        self:pintarPercepcao(bb, s)
    else
        self:pintarCasa(bb, s, agora)
    end
    if self.menu_aberto then self:pintarMenu(bb) end
end

--- Área tocável, em pontos do Figma.
function YomimonScreen:alvo(x, y, w, h, acao)
    table.insert(self.alvos, {
        rect = Geom:new{ x = self.ox + self:px(x), y = self.oy + self:px(y), w = self:px(w), h = self:px(h) },
        acao = acao,
        camada = self.camada,
    })
end

local TITULOS = { caderno = T"CADERNO", diario = T"DIÁRIO", conquistas = T"CONQUISTAS", pokedex = T"POKÉDEX",
                  percepcao = T"PERCEPÇÃO" }

function YomimonScreen:cabecalho(bb)
    self.camada = "topo"
    local titulo = TITULOS[self.modo]
    if titulo then
        self:texto(bb, titulo, 20, 18, true, 30)
    else
        self:textoApertado(bb, T"YOMIMON", 20, 10, true, 44, 6)
    end
    if self.traca.estado.dev_simulacao and not self.exportando then self:texto(bb, T"SIMULAÇÃO", 20, 56, false, 10, CINZA_55) end
    -- botão ARQUIVO com setinha em pixels
    self:cartao(bb, 403, 16, 140, 39, true)
    self:texto(bb, T"ARQUIVO", 417, 25, true, 14)
    self:ret(bb, 517, 31, 12, 3, PRETO)
    self:ret(bb, 520, 34, 6, 3, PRETO)
    self:ret(bb, 522, 37, 2, 3, PRETO)
    self:alvo(398, 6, 152, 60, function() self.menu_aberto = not self.menu_aberto end)
    -- fechar
    self:cartao(bb, 555, 16, 42, 39, true)
    self:texto(bb, "X", 0, 12, true, 32, PRETO, 576)
    self:alvo(550, 6, 64, 60, function() self:onClose(); return "fechou" end)
    self.camada = "conteudo"
end

-- Menu ARQUIVO ------------------------------------------------------------------

local ITENS_MENU = {
    { "casa", T"YOMIMON", T"A CRIATURA" },
    { "caderno", T"CADERNO", T"SEUS SUBLINHADOS" },
    { "diario", T"DIÁRIO", T"MEMÓRIAS DELA" },
    { "conquistas", T"CONQUISTAS", T"MARCOS E LIVROS LIDOS" },
    { "pokedex", T"POKÉDEX", T"SEUS POKÉMON E O PROGRESSO DE CADA UM" },
}

function YomimonScreen:pintarMenu(bb)
    self.camada = "menu"
    local x, y, w = 263, 66, 334
    local h = 14 + #ITENS_MENU * 48 + 6
    self:cartao(bb, x, y, w, h, true)
    local iy = y + 12
    for _, item in ipairs(ITENS_MENU) do
        local atual = (self.modo or "casa") == item[1]
        if atual then
            self:ret(bb, x + 12, iy + 4, 6, 6, PRETO)
            self:ret(bb, x + 12, iy + 10, 6, 6, PRETO)
            self:ret(bb, x + 18, iy + 7, 6, 6, PRETO)
        end
        self:texto(bb, item[2], x + 34, iy, true, 16)
        self:texto(bb, item[3], x + 34, iy + 21, false, 10, CINZA_55)
        local modo = item[1]
        self:alvo(x, iy - 6, w, 48, function()
            self.menu_aberto = false
            self:entrar(modo)
        end)
        iy = iy + 48
    end
end

function YomimonScreen:entrar(modo)
    self.modo = modo ~= "casa" and modo or nil
    self.pag = 1
    self.mensagem = nil
    if modo == "caderno" then
        self:carregarSublinhados()
    elseif modo == "conquistas" then
        local s = self.traca.estado
        self.terminados = s.dev_simulacao and s.sim_terminados or YomimonScreen.livrosTerminados()
        local n = 0
        for _, L in ipairs(s.dev_simulacao and s.sim_sublinhados or YomimonScreen.lerSublinhados()) do n = n + #L.itens end
        self.n_sublinhados = n
    end
    self:atualizar()
end

-- Tela inicial ------------------------------------------------------------------

function YomimonScreen:pintarCasa(bb, s, agora)
    -- balão com a fala (sorteada uma vez por abertura, para não mudar a cada redesenho)
    if not self.fala then self.fala = Estado.fala(s, agora, nil, nil, "traca") end
    -- a Yomimon fica sempre no lugar do Figma; o balão cresce para cima (e se alarga nas
    -- frases longas), sem nunca passar do cabeçalho
    -- o rabinho fica logo acima da cabeça real do desenho (fases pequenas: o balão desce)
    local m = self:medirBalao(self.mensagem or self.fala)
    local nome = self.quadro_atual or Estado.sprite(s, agora)
    local cabeca = (self.sprite_rect.y - self.oy) / self.k + Desenho.topoReal(nome) * self.sprite_escala / self.k
    local ponta = cabeca - 30
    local topo = math.max(70, ponta - (m.H + 15))
    self:balao(bb, self.mensagem or self.fala, nil, topo, m)

    -- a Yomimon
    local r = self.sprite_rect
    Desenho.pintarSprite(bb, self.quadro_atual or Estado.sprite(s, agora), r.x, r.y, self.sprite_escala)

    self:cartoesStatus(bb, s, agora)
end

-- Navegação de páginas (caderno e diário) -------------------------------------

function YomimonScreen:navegacao(bb, total)
    if total <= 1 then return end
    self.pag = math.max(1, math.min(self.pag or 1, total))
    self:cartao(bb, 20, 744, 84, 50, true)
    self:texto(bb, "<", 0, 750, true, 28, PRETO, 62)
    self:cartao(bb, 514, 744, 84, 50, true)
    self:texto(bb, ">", 0, 750, true, 28, PRETO, 556)
    self:texto(bb, string.format("%d / %d", self.pag, total), 0, 760, false, 14, CINZA_55, 309)
    self:alvo(14, 738, 100, 64, function() self.pag = math.max(1, self.pag - 1) end)
    self:alvo(508, 738, 100, 64, function() self.pag = math.min(total, self.pag + 1) end)
end

--- Balão com o rabinho à esquerda (Figma 37:7072): mesma borda e sombra do balão
-- principal; a altura cresce com o texto e o balão fica centrado em `centro_y`.
function YomimonScreen:balaoLateral(bb, texto, bx, W, centro_y, tam)
    local caixa = TextBoxWidget:new{
        text = maiusculas(texto), face = self:face(false, tam or 13), width = self:px(W - 56),
    }
    local th = caixa:getSize().h / self.k
    local H = th + 35
    local by = centro_y - H / 2
    local function r(x, y, w, h, cor) self:ret(bb, bx + x, by + y, w, h, cor) end
    r(3, 3, W - 6, H - 3, BRANCO)                         -- fundo
    r(6, 0, W - 12, 3, PRETO)                             -- topo
    r(3, 3, 3, 3, PRETO); r(W - 6, 3, 3, 3, PRETO)
    r(0, 6, 3, H - 9, PRETO)                              -- lado esquerdo
    r(3, H - 3, 3, 3, PRETO)
    r(W - 3, 6, 3, H - 3, PRETO)                          -- lado direito
    r(W - 6, H - 3, 3, 6, PRETO)
    r(W, 9, 3, H - 3, PRETO); r(W + 3, 12, 3, H - 6, PRETO)          -- sombra à direita
    r(6, H, W - 12, 3, PRETO)                                         -- base
    r(9, H + 3, W - 9, 3, PRETO); r(12, H + 6, W - 9, 3, PRETO)      -- sombra embaixo
    -- rabinho à esquerda, no meio da altura
    local ty = math.floor(H / 2) - 1
    r(0, ty - 6, 3, 15, BRANCO)
    r(-3, ty - 3, 3, 9, BRANCO); r(-6, ty, 3, 3, BRANCO)
    r(-3, ty - 6, 3, 3, PRETO); r(-6, ty - 3, 3, 3, PRETO); r(-9, ty, 3, 3, PRETO)
    r(-6, ty + 3, 3, 3, PRETO); r(-3, ty + 6, 3, 3, PRETO)
    caixa:paintTo(bb, self.ox + self:px(bx + 28), self.oy + self:px(by + 19))
    caixa:free()
end

--- Carinha da Yomimon com um balão ao lado (usado nas telas do arquivo).
function YomimonScreen:rodapeFala(bb, s, texto, y)
    local escala = math.max(1, math.floor(110 * self.k / Desenho.LARGURA))
    Desenho.pintarSprite(bb, Estado.fase(s).nome, self.ox + self:px(14), self.oy + self:px(y), escala)
    local lado = escala * Desenho.LARGURA / self.k
    self:balaoLateral(bb, texto, 14 + lado + 16, LARG - (14 + lado + 16) - 20, y + lado / 2)
end

-- Caderno: os sublinhados e notas do KOReader, organizados por livro ---------------

function YomimonScreen:carregarSublinhados()
    local s = self.traca.estado
    self.caderno = s.dev_simulacao and s.sim_sublinhados or YomimonScreen.lerSublinhados()
    self.livro_aberto = nil
end

--- Sublinhados e notas do KOReader, agrupados por livro (mais recente primeiro).
function YomimonScreen.lerSublinhados()
    local livros = {}
    pcall(function()
        local ReadHistory = require("readhistory")
        local DocSettings = require("docsettings")
        for i, item in ipairs(ReadHistory.hist or {}) do
            if i > 80 then break end
            if item.file and DocSettings:hasSidecarFile(item.file) then
                local ds = DocSettings:open(item.file)
                local props = ds:readSetting("doc_props") or {}
                local titulo = props.display_title or props.title or item.text or "?"
                local itens = {}
                for _, a in ipairs(ds:readSetting("annotations") or {}) do
                    if a.text and a.text ~= "" and (a.drawer or a.note) then
                        itens[#itens + 1] = { texto = a.text, nota = a.note, capitulo = a.chapter, data = a.datetime or "" }
                    end
                end
                if #itens > 0 then
                    table.sort(itens, function(a, b) return a.data < b.data end)
                    livros[#livros + 1] = { livro = titulo, autor = props.authors, itens = itens, recente = itens[#itens].data }
                end
            end
        end
    end)
    table.sort(livros, function(a, b) return a.recente > b.recente end)
    return livros
end

function YomimonScreen:pintarCaderno(bb, s)
    local livros = self.caderno or {}
    if #livros == 0 then
        self:rodapeFala(bb, s, T"Nenhum sublinhado. Ou você não lê, ou não sente nada. Segure o dedo numa frase do livro e destaque.", 380)
        return
    end
    if self.livro_aberto then return self:pintarSublinhado(bb, s, livros[self.livro_aberto]) end

    -- estante: 2 colunas x 3 linhas de caixinhas
    local por_pag = 6
    local total = math.ceil(#livros / por_pag)
    self.pag = math.max(1, math.min(self.pag or 1, total))
    for k = 0, por_pag - 1 do
        local idx = (self.pag - 1) * por_pag + k + 1
        local L = livros[idx]
        if not L then break end
        local x = 20 + (k % 2) * 299
        local y = 92 + math.floor(k / 2) * 208
        self:cartao(bb, x, y, 279, 188, true)
        self:ret(bb, x + 16, y + 16, 6, 30, PRETO)  -- lombada em pixels
        self:ret(bb, x + 22, y + 16, 3, 30, CINZA_BB)
        local titulo = TextBoxWidget:new{
            text = maiusculas(L.livro), face = self:face(true, 14), width = self:px(220),
            height = self:px(90), height_overflow_show_ellipsis = true,
        }
        titulo:paintTo(bb, self.ox + self:px(x + 38), self.oy + self:px(y + 16))
        titulo:free()
        if L.autor then
            local autor = TextBoxWidget:new{
                text = maiusculas(L.autor:gsub("\n.*", "")), face = self:face(false, 10), fgcolor = CINZA_55,
                width = self:px(220), height = self:px(28), height_overflow_show_ellipsis = true,
            }
            autor:paintTo(bb, self.ox + self:px(x + 38), self.oy + self:px(y + 112))
            autor:free()
        end
        local n = #L.itens
        self:texto(bb, string.format("%d %s", n, n == 1 and T"SUBLINHADO" or T"SUBLINHADOS"), x + 16, y + 154, true, 11, CINZA_55)
        self:alvo(x, y, 279, 188, function()
            self.livro_aberto = idx
            self.pag_estante = self.pag
            self.pag = 1
        end)
    end
    self:navegacao(bb, total)
end

function YomimonScreen:pintarSublinhado(bb, s, L)
    -- voltar para a estante
    self:cartao(bb, 20, 82, 150, 38, true)
    self:texto(bb, T"< LIVROS", 0, 92, true, 13, PRETO, 95)
    self:alvo(14, 76, 162, 50, function()
        self.livro_aberto = nil
        self.pag = self.pag_estante or 1
    end)
    local livro = TextBoxWidget:new{
        text = maiusculas(L.livro), face = self:face(true, 12), fgcolor = CINZA_55, width = self:px(410),
        height = self:px(16), height_overflow_show_ellipsis = true,
    }
    livro:paintTo(bb, self.ox + self:px(188), self.oy + self:px(94))
    livro:free()

    local total = #L.itens
    self.pag = math.max(1, math.min(self.pag or 1, total))
    local item = L.itens[self.pag]
    self:cartao(bb, 20, 136, 578, 392, true)
    self:ret(bb, 44, 154, 18, 6, PRETO)  -- aspas em pixels
    self:ret(bb, 44, 160, 6, 12, PRETO)
    self:ret(bb, 68, 154, 18, 6, PRETO)
    self:ret(bb, 68, 160, 6, 12, PRETO)
    local corpo = TextBoxWidget:new{
        text = item.texto, face = self:face(false, 16), width = self:px(526),
        height = self:px(290), height_overflow_show_ellipsis = true,
    }
    corpo:paintTo(bb, self.ox + self:px(44), self.oy + self:px(184))
    corpo:free()
    if item.capitulo then
        local cap = TextBoxWidget:new{
            text = "— " .. maiusculas(item.capitulo), face = self:face(false, 11), fgcolor = CINZA_55,
            width = self:px(526), height = self:px(16), height_overflow_show_ellipsis = true,
        }
        cap:paintTo(bb, self.ox + self:px(44), self.oy + self:px(494))
        cap:free()
    end

    -- comentário com contexto
    local no_cap = 0
    for _, it in ipairs(L.itens) do if it.capitulo and it.capitulo == item.capitulo then no_cap = no_cap + 1 end end
    local pers = Memoria.personagens(s, L.livro, 10)
    local comentario = Memoria.comentarioContexto(item, {
        s = s, temperamento = Estado.fase(s).temperamento, livro = L.livro, personagens = pers,
        ordem = self.pag, total = total, no_capitulo = no_cap,
    })
    self:rodapeFala(bb, s, comentario, 560)
    self:navegacao(bb, total)
end

-- Diário: memórias e o que os livros fizeram com ela --------------------------------

local MESES = {}
for m in T"JAN FEV MAR ABR MAI JUN JUL AGO SET OUT NOV DEZ":gmatch("%S+") do MESES[#MESES + 1] = m end

function YomimonScreen:pintarDiario(bb, s)
    local y = 88
    -- "biblioteca interior" resumida: quem ela virou
    local a, b = Memoria.ambivalente(s)
    local resumo
    if a then
        resumo = string.format(T"DIVIDIDA ENTRE %s E %s", maiusculas(Memoria.NOMES_TEMA[a]), maiusculas(Memoria.NOMES_TEMA[b]))
    elseif s.tema_dominante then
        resumo = string.format(T"OBCECADA %s", maiusculas(Memoria.tema(s.tema_dominante, "por")))
    end
    -- o jeito que ela ficou com as suas leituras (até 2 traços; 1 quando já está dividida)
    local jeito = Tracos.rotulos(s.tracos, a and 1 or 2)
    if #jeito > 0 then resumo = (resumo and (resumo .. " · ") or "") .. table.concat(jeito, " · ") end
    resumo = resumo or T"AINDA SEM OPINIÕES. LEIA MAIS."
    self:texto(bb, resumo, 20, y, true, 12, CINZA_55)
    y = y + 26

    local entradas = {}
    for i = #(s.diario or {}), 1, -1 do entradas[#entradas + 1] = s.diario[i] end
    if #entradas == 0 then
        self:rodapeFala(bb, s, T"Meu diário está vazio. Como a sua estante.", 380)
        return
    end
    local por_pag = 5
    local total = math.ceil(#entradas / por_pag)
    self.pag = math.max(1, math.min(self.pag or 1, total))
    for i = (self.pag - 1) * por_pag + 1, math.min(#entradas, self.pag * por_pag) do
        local e = entradas[i]
        local d = os.date("*t", e.t)
        self:texto(bb, string.format("%02d %s", d.day, MESES[d.month]), 20, y, true, 12)
        local caixa = TextBoxWidget:new{
            text = maiusculas(e.texto), face = self:face(false, 13), width = self:px(500),
            height = self:px(72), height_overflow_show_ellipsis = true,
        }
        local hh = caixa:getSize().h / self.k
        caixa:paintTo(bb, self.ox + self:px(96), self.oy + self:px(y))
        caixa:free()
        y = y + math.max(22, hh) + 14
        self:ret(bb, 20, y - 8, 578, 3, CINZA_BB)
        y = y + 6
    end
    self:navegacao(bb, total)
end

--- Cartões de barriga/humor e de fase (rodapé da tela principal).
function YomimonScreen:cartoesStatus(bb, s, agora)
    -- cartão de status: barriga e humor
    -- os dois cartões (380 + 20 de espaço + 174, mais 6 de sombra) centralizados na tela
    local cx, cy = (LARG - 580) / 2, 696
    self:cartao(bb, cx, cy, 380, 104, true)
    self:retangulos(bb, ICONE_LIVRO, cx, cy, PRETO)
    self:retangulos(bb, ICONE_CARA, cx, cy, PRETO)
    self:texto(bb, T"BARRIGA", cx + 62, cy + 12, true, 16)
    local hoje = Estado.paginasHoje(s, agora)
    self:texto(bb, string.format(T"%s · %d PÁG. HOJE", Estado.rotuloBarriga(s), hoje), cx + 62, cy + 33, false, 10, CINZA_55)
    self:texto(bb, T"HUMOR", cx + 62, cy + 58, true, 16)
    self:texto(bb, Estado.rotuloHumor(s), cx + 62, cy + 79, false, 10, CINZA_55)
    self:bolinhas(bb, cx + 244, cy + 16, Estado.bolinhas(s.barriga))
    self:bolinhas(bb, cx + 244, cy + 62, Estado.bolinhas(s.humor))

    -- cartão de forma: nome, páginas que faltam para a próxima forma e a barra até lá
    local ix, iy, larg = cx + 400, 696, 146
    self:cartao(bb, ix, iy, 174, 104, true)
    local pf = Estado.progressoFase(s)
    self:texto(bb, maiusculas(pf.fase.titulo), ix + 14, iy + 8, true, 16)
    local alvo = pf.proxima and maiusculas(pf.proxima.titulo) or T"FORMA FINAL"
    local linha1 = pf.proxima and (pf.paginas == 1 and T"PÁG. PARA" or T"PÁGS. PARA") or T"CHEGOU À"
    local rotulo = math.max(self:larguraTexto(linha1, false, 10), self:larguraTexto(alvo, true, 10))
    local num = pf.proxima and Desenho.milhar(pf.paginas) or "OK"
    local tam_num = 28
    while tam_num > 16 and self:larguraTexto(num, true, tam_num) + 6 + rotulo > larg do tam_num = tam_num - 4 end
    local nw = self:texto(bb, num, ix + 14, iy + 26, true, tam_num)
    self:texto(bb, linha1, ix + 14 + nw + 6, iy + 30, false, 10, CINZA_55)
    self:texto(bb, alvo, ix + 14 + nw + 6, iy + 43, true, 10)
    -- barra: trilho cinza e o progresso em preto
    self:ret(bb, ix + 14, iy + 64, larg, 6, CINZA_BB)
    local cheio = math.floor(larg * pf.fracao + 0.5)
    if cheio > 0 then self:ret(bb, ix + 14, iy + 64, cheio, 6, PRETO) end
    self:retangulos(bb, ICONE_AMPULHETA, ix, iy, CINZA_55)
    self:texto(bb, string.format(T"%s PÁG. LIDAS", Desenho.milhar(s.paginas)), ix + 30, iy + 77, false, 10, CINZA_55)
end

--- Tela de descanso: o balão e a Yomimon dormindo, sozinhos, no meio da tela (sem cartões desde 29/10/2026:
-- a imagem é desenhada quando o Kindle dorme, e de manhã barriga, humor e "pág. hoje" já seriam de ontem).
-- Pinta numa imagem e salva em PNG; o KOReader mostra quando o Kindle dorme.
-- escolher = true só quando o Kindle vai dormir: a fala é escolhida agora (Estado.falaDescanso); nos outros
-- redesenhos, repete a última.
function YomimonScreen.gerarTelaDescanso(s, caminho, agora, escolher)
    local sw, sh = Screen:getWidth(), Screen:getHeight()
    local w, h = math.min(sw, sh), math.max(sw, sh)  -- sempre em pé
    local bb = Blitbuffer.new(w, h, Blitbuffer.TYPE_BB8)
    bb:fill(BRANCO)
    local k = math.min(w / LARG, h / ALT)
    local p = setmetatable({
        k = k, ox = math.floor((w - LARG * k) / 2), oy = math.floor((h - ALT * k) / 2),
        fator_fonte = Screen:scaleBySize(1000) / 1000, faces = {},
    }, { __index = YomimonScreen })
    -- o bichinho dormindo: o sprite da forma atual com os "z" (ou a bola, se o sprite não foi baixado).
    -- 64 de altura, no tamanho do pixel da Home.
    local nome = Estado.sprite(s, agora, true)
    local escala = math.max(1, math.floor(295 * k / Desenho.LARGURA))
    local L = Desenho.sprite(nome)
    local larg = #L[1] * escala
    local topo_real = Desenho.topoReal(nome) * escala           -- linhas vazias acima da antena
    local alt_real = #L * escala - topo_real
    -- balão e Yomimon como um grupo, igual à Home (rabinho 30 acima da cabeça), no meio da tela
    local fala = Estado.falaDescanso(s, agora, escolher)
    local m = p:medirBalao(fala)
    local grupo = m.H + 15 + 30 + alt_real / k
    local topo = math.max(20, (ALT - grupo) / 2)
    p:balao(bb, fala, nil, topo, m)
    local cabeca = p.oy + p:px(topo + m.H + 15 + 30)
    Desenho.pintarSprite(bb, nome, p.ox + p:px(LARG / 2) - math.floor(larg / 2), cabeca - topo_real, escala)
    local ok, err = pcall(bb.writePNG, bb, caminho)
    bb:free()
    return ok, err
end

-- Conquistas: resumo, marcos e estante por ano -------------------------------------

--- Livros marcados como terminados no KOReader (ou lidos até o fim), com a data.
function YomimonScreen.livrosTerminados()
    local lista = {}
    pcall(function()
        local ReadHistory = require("readhistory")
        local DocSettings = require("docsettings")
        for _, item in ipairs(ReadHistory.hist or {}) do
            if item.file and DocSettings:hasSidecarFile(item.file) then
                local ds = DocSettings:open(item.file)
                local resumo = ds:readSetting("summary") or {}
                local pct = ds:readSetting("percent_finished") or 0
                if resumo.status == "complete" or pct >= 0.995 then
                    local props = ds:readSetting("doc_props") or {}
                    local data = resumo.modified or (item.time and os.date("%Y-%m-%d", item.time)) or ""
                    lista[#lista + 1] = { titulo = props.display_title or props.title or item.text or "?", data = data }
                end
            end
        end
    end)
    table.sort(lista, function(a, b) return a.data > b.data end)
    return lista
end

function YomimonScreen:pintarConquistas(bb, s)
    local terminados = self.terminados or {}
    -- página 1: resumo + marcos; páginas seguintes: estante por ano
    local anos, por_ano = {}, {}
    for _, L in ipairs(terminados) do
        local ano = L.data:sub(1, 4)
        if ano == "" then ano = "????" end
        if not por_ano[ano] then por_ano[ano] = {}; anos[#anos + 1] = ano end
        table.insert(por_ano[ano], L)
    end
    local paginas_estante = {}
    for _, ano in ipairs(anos) do
        local lista = por_ano[ano]
        for i = 1, #lista, 9 do
            paginas_estante[#paginas_estante + 1] = { ano = ano, total = #lista, de = i, lista = lista }
        end
    end
    local total = 2 + #paginas_estante  -- 2 páginas de marcos
    self.pag = math.max(1, math.min(self.pag or 1, total))

    if self.pag <= 2 then
        if self.pag == 1 then
            -- cartão-resumo
            self:cartao(bb, 20, 86, 578, 96, true)
            local function bloco(x, valor, rotulo)
                self:texto(bb, valor, x, 100, true, 28)
                self:texto(bb, rotulo, x, 140, false, 10, CINZA_55)
            end
            local paginas, dias = Estado.totais(s)
            bloco(44, tostring(#terminados), T"LIVROS TERMINADOS")
            bloco(240, Desenho.milhar(paginas), T"PÁGINAS LIDAS")
            bloco(436, tostring(dias), T"DIAS LENDO")
        end
        local marcos = Estado.marcos(s, {
            livros_terminados = #terminados, sublinhados = self.n_sublinhados or 0,
            ambivalente = Memoria.ambivalente(s) ~= nil,
        })
        local ini = self.pag == 1 and 1 or 11
        local y0 = self.pag == 1 and 200 or 92
        for k = 0, 9 do
            local m = marcos[ini + k]
            if not m then break end
            local x = 20 + (k % 2) * 299
            local y = y0 + math.floor(k / 2) * 104
            self:cartao(bb, x, y, 279, 88, true)
            -- selo: quadrado cheio se conquistado, vazio (cinza) se não
            local sx, sy = x + 16, y + 26
            if m.feito then
                self:ret(bb, sx + 3, sy, 20, 26, PRETO); self:ret(bb, sx, sy + 3, 26, 20, PRETO)
                self:ret(bb, sx + 6, sy + 6, 3, 3, BRANCO)
            else
                self:ret(bb, sx + 3, sy, 20, 3, CINZA_BB); self:ret(bb, sx + 3, sy + 23, 20, 3, CINZA_BB)
                self:ret(bb, sx, sy + 3, 3, 20, CINZA_BB); self:ret(bb, sx + 23, sy + 3, 3, 20, CINZA_BB)
            end
            self:texto(bb, m.titulo, x + 56, y + 16, true, 13, m.feito and PRETO or CINZA_55)
            local desc = m.feito and m.descricao
                or (m.meta > 1 and string.format("%s / %s", Desenho.milhar(math.min(m.atual, m.meta)), Desenho.milhar(m.meta)) or m.descricao)
            self:texto(bb, desc, x + 56, y + 42, false, 9, CINZA_55)
        end
    else
        local P = paginas_estante[self.pag - 2]
        self:texto(bb, string.format("%s · %d %s", P.ano, P.total, P.total == 1 and T"LIVRO" or T"LIVROS"), 20, 88, true, 18)
        local y = 124
        for i = P.de, math.min(P.de + 8, #P.lista) do
            local L = P.lista[i]
            self:cartao(bb, 20, y, 578, 62, true)
            self:ret(bb, 36, y + 14, 6, 34, PRETO); self:ret(bb, 42, y + 14, 3, 34, CINZA_BB)  -- lombada
            local t = TextBoxWidget:new{
                text = maiusculas(L.titulo), face = self:face(true, 13), width = self:px(420),
                height = self:px(18), height_overflow_show_ellipsis = true,
            }
            t:paintTo(bb, self.ox + self:px(60), self.oy + self:px(y + 14))
            t:free()
            local d = L.data
            local dia, mes = d:sub(9, 10), tonumber(d:sub(6, 7))
            self:texto(bb, mes and (dia .. " " .. MESES[mes]) or "", 60, y + 38, false, 10, CINZA_55)
            y = y + 70
        end
    end
    self:navegacao(bb, total)
end

-- Linhagem: a geração viva e os memoriais das anteriores ---------------------------

--- Pokédex: os Pokémon já escolhidos, cada um com o progresso que guardou; tocar em um troca para ele.
function YomimonScreen:pintarPokedex(bb, s)
    local lista = Estado.colecao(s)
    local itens = {}
    for _, e in ipairs(lista) do itens[#itens + 1] = e end
    itens[#itens + 1] = { novo = true }
    local por_pag = 5
    local total = math.ceil(#itens / por_pag)
    self.pag = math.max(1, math.min(self.pag or 1, total))
    local escala = math.max(1, math.floor(80 * self.k / Desenho.LARGURA))
    local y = 88
    for i = (self.pag - 1) * por_pag + 1, math.min(#itens, self.pag * por_pag) do
        local e = itens[i]
        self:cartao(bb, 20, y, 578, 104, true)
        if e.novo then
            self:texto(bb, T"+ ESCOLHER OUTRO POKÉMON", 0, y + 38, true, 18, PRETO, 309)
            self:alvo(20, y, 578, 104, function() self.traca:mostrarBoasVindas(true) end)
        else
            Desenho.pintarSprite(bb, e.forma.nome, self.ox + self:px(30), self.oy + self:px(y + 12), escala)
            self:texto(bb, maiusculas(e.forma.titulo), 130, y + 16, true, 15)
            self:texto(bb, string.format(T"FORMA %d DE %d", e.estagio, e.total), 130, y + 42, false, 10, CINZA_55)
            local paginas = math.floor(e.letras / Estado.letrasPorPagina(s))
            self:texto(bb, string.format(T"%s PÁG. COM VOCÊ", Desenho.milhar(paginas)), 130, y + 62, false, 10, CINZA_55)
            if e.atual then
                self:texto(bb, T"COM VOCÊ AGORA", 130, y + 80, true, 10)
            else
                self:texto(bb, ">", 0, y + 36, true, 24, PRETO, 570)
                self:alvo(20, y, 578, 104, function()
                    Estado.trocarEspecie(s, e.base)
                    pcall(function() require("yomimon_simpleui").sincronizarCritter(self.traca) end)
                    self.fala = nil
                    self.traca:salvar(true)
                    self.pag = 1
                end)
            end
        end
        y = y + 120
    end
    self:navegacao(bb, total)
end

-- Cartões de texto (memorial) --------------------------------------------------------

--- Altura (em pontos do Figma) que um texto ocupa numa largura, com a fonte pixel.
function YomimonScreen:alturaTexto(texto, negrito, tam, largura)
    local t = TextBoxWidget:new{ text = texto, face = self:face(negrito, tam), width = self:px(largura) }
    local h = t:getSize().h / self.k
    t:free()
    return h
end

--- Cartão com rótulo e texto, da altura do texto (até altura_max). Devolve o y logo abaixo.
function YomimonScreen:caixaTexto(bb, y, rotulo, texto, altura_max)
    texto = maiusculas(texto)
    local altura = math.min(altura_max, math.ceil(self:alturaTexto(texto, false, 13, 530)) + 52)
    self:cartao(bb, 20, y, 578, altura, true)
    self:texto(bb, rotulo, 40, y + 14, true, 11, CINZA_55)
    local t = TextBoxWidget:new{
        text = texto, face = self:face(false, 13), width = self:px(530),
        height = self:px(altura - 46), height_overflow_show_ellipsis = true,
    }
    t:paintTo(bb, self.ox + self:px(40), self.oy + self:px(y + 36))
    t:free()
    return y + altura + 18
end

--- Modo dev: salva cada tela em PNG (koreader/yomimon/demo), na resolução do aparelho.
function YomimonScreen:exportarTelas(pasta)
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    pasta = pasta or DataStorage:getDataDir() .. "/yomimon/demo"
    local mae = pasta:match("^(.*)/[^/]+$")
    if mae and lfs.attributes(mae, "mode") ~= "directory" then lfs.mkdir(mae) end
    if lfs.attributes(pasta, "mode") ~= "directory" then lfs.mkdir(pasta) end
    local bb = Blitbuffer.new(Screen:getWidth(), Screen:getHeight(), Blitbuffer.TYPE_BB8)
    local s = self.traca.estado
    local n, falhas = 0, 0
    self.exportando = true  -- sem o selo SIMULAÇÃO nas imagens
    local function foto(nome, preparar)
        local ok = pcall(function()
            self.menu_aberto = false
            preparar()
            bb:fill(BRANCO)
            self:paintTo(bb, 0, 0)
            bb:writePNG(string.format("%s/%02d-%s.png", pasta, n + 1, nome))
        end)
        if ok then n = n + 1 else falhas = falhas + 1 end
    end
    foto("casa", function() self.modo = nil; self.mensagem = nil end)
    foto("menu", function() self.modo = nil; self.menu_aberto = true end)
    foto("diario", function() self:entrar("diario") end)
    foto("diario-2", function() self.pag = 2 end)
    foto("caderno", function() self:entrar("caderno") end)
    foto("caderno-trecho", function() self.livro_aberto = 1; self.pag = 1 end)
    foto("conquistas", function() self:entrar("conquistas") end)
    foto("conquistas-2", function() self.pag = 2 end)
    foto("estante", function() self.pag = 3 end)
    foto("percepcao", function() self:entrar("percepcao") end)
    -- demonstração: falas e sonhos escolhidos (dev_falas e dev_sonhos, postos no estado simulado), uma tela
    -- para cada, no lugar dos sorteados
    for i, f in ipairs(s.dev_falas or {}) do
        foto("casa-" .. i, function() self:entrar("casa"); self.mensagem = nil; self.fala = f end)
    end
    bb:free()
    if pcall(YomimonScreen.gerarTelaDescanso, s, string.format("%s/%02d-descanso.png", pasta, n + 1), os.time()) then n = n + 1 end
    for i, f in ipairs(s.dev_sonhos or {}) do
        s.fala_descanso = f
        if pcall(YomimonScreen.gerarTelaDescanso, s, string.format("%s/%02d-descanso-%d.png", pasta, n + 1, i), os.time(), false) then
            n = n + 1
        end
    end
    self.exportando = false
    self:entrar("casa")
    return n, pasta, falhas
end

--- Modo dev: exporta as telas de cada simulação em koreader/yomimon/simulacoes/*.lua, cada uma na sua pasta em
-- koreader/yomimon/demo/<nome do arquivo>/. Não salva nada: no fim volta o estado que estava aberto.
function YomimonScreen:exportarSimulacoes()
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    local LuaSettings = require("luasettings")
    local base = DataStorage:getDataDir() .. "/yomimon"
    local arquivos = {}
    if lfs.attributes(base .. "/simulacoes", "mode") == "directory" then
        for f in lfs.dir(base .. "/simulacoes") do
            if f:match("%.lua$") then arquivos[#arquivos + 1] = f end
        end
    end
    table.sort(arquivos)
    local traca, antes = self.traca, self.traca.estado
    self:pararAnimacao()
    local sims, telas, falhas = 0, 0, 0
    for _, f in ipairs(arquivos) do
        local ok, sim = pcall(function() return LuaSettings:open(base .. "/simulacoes/" .. f):readSetting("estado") end)
        if ok and type(sim) == "table" then
            traca.estado = Estado.normalizar(sim, os.time())
            traca.estado.dev_simulacao = true
            Estado.passarTempo(traca.estado, os.time())
            self.fala, self.quadro_atual = nil, nil  -- nada da simulação anterior
            local n, _, x = self:exportarTelas(base .. "/demo/" .. (f:gsub("%.lua$", "")))
            sims, telas, falhas = sims + 1, telas + n, falhas + x
        else
            falhas = falhas + 1
        end
    end
    traca.estado = antes
    self.fala, self.quadro_atual = nil, nil
    return sims, telas, falhas
end

-- Painel dev: o que ela percebeu do livro atual ----------------------------------------

local NOMES_EVENTO = { morte = T"MORTE", casamento = T"CASAMENTO", viagem = T"VIAGEM", carta = T"CARTA",
    tempestade = T"TEMPESTADE", doenca = T"DOENÇA", festa = T"FESTA", briga = T"BRIGA", fuga = T"FUGA", crime = T"CRIME" }

function YomimonScreen:pintarPercepcao(bb, s)
    local livro = s.ultimo_livro
    local P = livro and Memoria.percepcao(s, livro)
    if not P then
        self:rodapeFala(bb, s, T"Ainda não percebi nada. Leia umas páginas com esta versão.", 380)
        return
    end
    local linhas = { T"LIVRO: " .. maiusculas(livro), "" , T"PERSONAGENS (VEZES · FALAS · CAPÍTULOS)" }
    for i, p in ipairs(P.personagens) do
        if i > 8 then break end
        linhas[#linhas + 1] = string.format("  %s%s  %d · %d · %d", p.protagonista and "★ " or "", maiusculas(p.nome), p.vezes, p.falas, p.capitulos)
    end
    local lug = {}
    for i, l in ipairs(P.lugares) do if i <= 6 then lug[#lug + 1] = maiusculas(l[1]) end end
    linhas[#linhas + 1] = ""
    linhas[#linhas + 1] = T"LUGARES: " .. (#lug > 0 and table.concat(lug, ", ") or "—")
    local tem = {}
    for i, t in ipairs(P.temas) do if i <= 4 then tem[#tem + 1] = string.format("%s %d", maiusculas(Memoria.tema(t[1])), math.floor(t[2] + 0.5)) end end
    linhas[#linhas + 1] = T"TEMAS: " .. (#tem > 0 and table.concat(tem, " · ") or "—")
    local refs = {}
    for i, r in ipairs(P.referencias or {}) do if i <= 4 then refs[#refs + 1] = string.format("%s %d", maiusculas(r[1]), r[2]) end end
    linhas[#linhas + 1] = T"CITADOS: " .. (#refs > 0 and table.concat(refs, " · ") or "—")
    local narr = P.narrador
    linhas[#linhas + 1] = T"NARRADOR: " .. (not narr and "?" or not narr.primeira and T"TERCEIRA PESSOA"
        or (T"PRIMEIRA PESSOA" .. (narr.genero == "f" and (" · " .. T"MULHER") or narr.genero == "m" and (" · " .. T"HOMEM") or "")))
    local tr = {}
    for _, t in ipairs(Tracos.LISTA) do
        local v = (s.tracos or {})[t.id] or 0
        tr[#tr + 1] = string.format("%s %+d", Tracos.rotulo(v >= 0 and t.pos or t.neg), math.floor(v + 0.5))
    end
    linhas[#linhas + 1] = T"TRAÇOS: " .. table.concat(tr, " · ")
    linhas[#linhas + 1] = ""
    linhas[#linhas + 1] = T"ÚLTIMOS CAPÍTULOS (PÁG · CLIMA · EVENTOS)"
    for i, c in ipairs(P.capitulos) do
        if i > 6 then break end
        local evs = {}
        for ev in pairs(c.C.eventos or {}) do evs[#evs + 1] = NOMES_EVENTO[ev] or ev end
        local clima = c.C.paginas > 0 and c.C.clima / c.C.paginas or 0
        linhas[#linhas + 1] = string.format("  %s · %d · %+.1f · %s", maiusculas(c.nome):sub(1, 22), c.C.paginas, clima,
            #evs > 0 and table.concat(evs, ", ") or "—")
    end
    local p = s.comentario_pendente
    linhas[#linhas + 1] = ""
    linhas[#linhas + 1] = T"ÚLTIMO COMENTÁRIO DE CAPÍTULO: " .. (p and (maiusculas(p.texto) .. (p.usado and T" (JÁ DITO)" or "")) or "—")
    local caixa = TextBoxWidget:new{
        text = table.concat(linhas, "\n"), face = self:face(false, 11), width = self:px(578),
        height = self:px(700), height_overflow_show_ellipsis = true,
    }
    caixa:paintTo(bb, self.ox + self:px(20), self.oy + self:px(90))
    caixa:free()
end

function YomimonScreen:atualizar()
    UIManager:setDirty(self, "ui")
end

-- Animação ------------------------------------------------------------------------

function YomimonScreen:iniciarAnimacao()
    self.quadros = Desenho.quadros(Estado.quadros(self.traca.estado, os.time()))
    self.quadro_atual = nil
    if not self.quadros then return end
    if not self.anim_ate then
        self.anim_ate = os.time() + 60 * ANIMACAO_MINUTOS
    end
    self.quadro = 0
    UIManager:scheduleIn(QUADRO_SEGUNDOS, self.tick)
end

function YomimonScreen:pararAnimacao()
    UIManager:unschedule(self.tick)
end

function YomimonScreen:proximoQuadro()
    local agora = os.time()
    if agora >= (self.anim_ate or 0) then
        self.anim_ate = nil
        return
    end
    self.quadro = self.quadro % #self.quadros + 1
    self.quadro_atual = self.quadros[self.quadro]
    UIManager:setDirty(self, function() return "ui", self.sprite_rect end)
    UIManager:scheduleIn(QUADRO_SEGUNDOS, self.tick)
end

function YomimonScreen:reiniciar()
    self:pararAnimacao()
    self.fala = nil
    self:iniciarAnimacao()
    self:atualizar()
end

-- Toques ----------------------------------------------------------------------------

function YomimonScreen:carinho()
    if self.traca:carinho() then
        self.mensagem = T"Hm. Tá. Pode continuar."
    elseif self.traca.estado.hibernando then
        self.mensagem = T"(de volta na bola; leia uma página para chamá-lo)"
    else
        self.mensagem = T"Já chega de carinho por agora."
    end
    self:atualizar()
end

function YomimonScreen:onTap(_, ges)
    local pos = ges and ges.pos
    if not pos then return end
    local alvos = self.alvos or {}
    for i = #alvos, 1, -1 do  -- os desenhados por último (menu) têm prioridade
        local a = alvos[i]
        if (not self.menu_aberto or a.camada ~= "conteudo") and pos:intersectWith(a.rect) then
            if a.acao() ~= "fechou" then self:atualizar() end
            return true
        end
    end
    if self.menu_aberto then
        self.menu_aberto = false
        self:atualizar()
        return true
    end
    if not self.modo and pos:intersectWith(self.sprite_rect) then
        self:carinho()
        return true
    end
end

function YomimonScreen:onHold(_, ges)
    local pos = ges and ges.pos
    if self.modo or not (pos and pos:intersectWith(self.sprite_rect)) then return end
    local dialogo
    local botoes = {
            {{
                text = self.traca:telaDescansoAtiva() and T"Tela de descanso: ligada" or T"Tela de descanso: desligada",
                callback = function()
                    UIManager:close(dialogo)
                    self.traca:alternarTelaDescanso()
                end,
            }},
    }
    table.insert(botoes, {{ text = T"Idioma…", callback = function()
        UIManager:close(dialogo)
        self:menuIdioma()
    end }})
    if YomimonScreen.devLigado() then
        table.insert(botoes, {{ text = T"Modo dev…", callback = function()
            UIManager:close(dialogo)
            self:menuDev()
        end }})
    end
    dialogo = ButtonDialog:new{ buttons = botoes }

    UIManager:show(dialogo)
    return true
end

--- Idioma: automático (segue o KOReader), português ou inglês. Vale depois de reiniciar.
function YomimonScreen:menuIdioma()
    local Lingua = require("yomimon_language")
    local atual = Lingua.escolha()
    local dialogo
    local function opcao(texto, valor)
        return {{ text = (atual == valor and "▸ " or "") .. texto, callback = function()
            UIManager:close(dialogo)
            if valor == atual then return end
            Lingua.salvarEscolha(valor)
            UIManager:show(require("ui/widget/infomessage"):new{
                text = "Reinicie o KOReader para trocar o idioma.\nRestart KOReader to change the language.",
            })
        end }}
    end
    dialogo = ButtonDialog:new{
        title = T"Idioma do Yomimon",
        buttons = { opcao(T"Padrão (português)", "auto"), opcao("Português", "pt"), opcao("English", "en") },
    }
    UIManager:show(dialogo)
end

--- Modo dev: só existe se o arquivo koreader/yomimon/dev existir. Muda fase e humor para teste.
function YomimonScreen:menuDev(fechar_anterior)
    local s = self.traca.estado
    local dialogo
    local function acao(fn)
        return function()
            UIManager:close(dialogo)
            fn()
            self.traca:salvar(true)
            self.mensagem = nil
            self:reiniciar()
        end
    end
    local fases = {}
    for _, f in ipairs(Estado.formas(s)) do
        fases[#fases + 1] = { text = (s.dev_fase == f.nome and "▸ " or "") .. f.titulo, callback = acao(function() s.dev_fase = f.nome end) }
    end
    dialogo = ButtonDialog:new{
        title = T"YOMIMON · MODO DEV",
        buttons = {
            fases,
            {
                { text = T"Faminta", callback = acao(function() s.barriga, s.humor = 5, 40 end) },
                { text = T"Ranzinza", callback = acao(function() s.barriga, s.humor = 60, 10 end) },
                { text = T"Feliz", callback = acao(function() s.barriga, s.humor = 90, 90 end) },
            },
            {
                { text = s.dev_noite and T"Noite: ligada" or T"Noite: desligada", callback = acao(function() s.dev_noite = not s.dev_noite or nil end) },
                { text = s.hibernando and T"Sair da bola" or T"Voltar para a bola", callback = acao(function() s.hibernando = not s.hibernando end) },
            },
            {
                { text = T"O que ela percebeu", callback = function()
                    UIManager:close(dialogo)
                    self:entrar("percepcao")
                end },
            },
            {
                { text = T"Fim do ciclo (teste)", callback = function()
                    UIManager:close(dialogo)
                    s.dev_fase = nil
                    self:onClose()
                    self.traca:fimDoCiclo()
                end },
            },
            (function()
                -- carregar sempre lê o arquivo de novo (o estado real fica guardado na primeira vez)
                local linha = {
                    { text = T"Simulação de endgame", callback = function()
                        UIManager:close(dialogo)
                        if not self.traca:carregarSimulacao() then
                            UIManager:show(require("ui/widget/infomessage"):new{ text = T"Nenhuma simulação em koreader/yomimon/simulacao.lua." })
                        end
                        self.mensagem = nil
                        self:reiniciar()
                    end },
                }
                if self.traca:emSimulacao() then
                    linha[2] = { text = T"Voltar ao estado real", callback = function()
                        UIManager:close(dialogo)
                        self.traca:voltarEstadoReal()
                        self.mensagem = nil
                        self:reiniciar()
                    end }
                end
                return linha
            end)(),
            {
                { text = T"Exportar telas (PNG)", callback = function()
                    UIManager:close(dialogo)
                    local n, pasta, falhas = self:exportarTelas()
                    UIManager:show(require("ui/widget/infomessage"):new{
                        text = string.format(T"%d telas salvas em %s", n, pasta) .. (falhas > 0 and string.format(" (%d ✗)", falhas) or ""),
                    })
                end },
            },
            {
                { text = T"Exportar todas as simulações", callback = function()
                    UIManager:close(dialogo)
                    local InfoMessage = require("ui/widget/infomessage")
                    local aviso = InfoMessage:new{ text = T"Exportando as simulações de koreader/yomimon/simulacoes…" }
                    UIManager:show(aviso)
                    UIManager:forceRePaint()
                    local sims, n, falhas = self:exportarSimulacoes()
                    UIManager:close(aviso)
                    self:reiniciar()
                    UIManager:show(InfoMessage:new{
                        text = string.format(T"%d simulações, %d telas salvas em koreader/yomimon/demo", sims, n)
                            .. (falhas > 0 and string.format(" (%d ✗)", falhas) or ""),
                    })
                end },
            },
            {
                { text = self.traca.falha_teste and T"Falha de teste: ligada" or T"Falha de teste: desligada", callback = function()
                    UIManager:close(dialogo)
                    self.traca:alternarFalhaTeste()
                end },
            },
            {
                { text = T"Ver boas-vindas", callback = function()
                    UIManager:close(dialogo)
                    self:onClose()
                    self.traca:mostrarBoasVindas()
                end },
            },
            {
                { text = T"Sair do teste (volta ao normal)", callback = acao(function()
                    s.dev_fase, s.dev_noite, s.hibernando = nil, nil, false
                    s.barriga, s.humor = math.max(s.barriga, 60), math.max(s.humor, 60)
                end) },
            },
        },
    }
    UIManager:show(dialogo)
end

function YomimonScreen.devLigado()
    local okV, Versao = pcall(require, "yomimon_version")
    if okV and type(Versao) == "table" and Versao.publica then return false end  -- versão da comunidade: nunca
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    return lfs.attributes(DataStorage:getDataDir() .. "/yomimon/dev", "mode") == "file"
end

function YomimonScreen:onSuspend()
    self:pararAnimacao()
end

function YomimonScreen:onResume()
    self.anim_ate = nil
    self:reiniciar()
end

function YomimonScreen:onCloseWidget()
    self:pararAnimacao()
end

function YomimonScreen:onClose()
    UIManager:close(self, "flashpartial")
    return true
end

-- Proteção: um erro ao desenhar, tocar ou animar não pode travar o KOReader. Se falhar, a tela
-- mostra um aviso simples e qualquer toque fecha (para nunca prender o leitor numa tela quebrada).
local Guarda = require("yomimon_guard")
Guarda.padrao:envolver(YomimonScreen, { "paintTo", "onTap", "onHold", "proximoQuadro" }, function(nome, self, bb, x, y)
    if nome == "paintTo" then
        bb:paintRect(x, y, self.dimen.w, self.dimen.h, BRANCO)
        local aviso = TextBoxWidget:new{
            text = T"O Yomimon tropeçou. Toque para fechar.", face = Font:getFace("cfont", 22), width = self.dimen.w - 80,
        }
        aviso:paintTo(bb, x + 40, y + math.floor(self.dimen.h / 3))
        aviso:free()
    elseif nome == "onTap" or nome == "onHold" then
        UIManager:close(self)
        return true
    end
end)

return YomimonScreen
