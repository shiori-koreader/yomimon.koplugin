--[[--
Boas-vindas: aparece na primeira vez que o Yomimon abre (ou pelo modo dev).

Tela 1 · escolha      — lista dos Pokémon, em ordem alfabética, com atalho por letra
Tela 2 · confirmação  — o sprite dele (baixado no aparelho) + ESCOLHER ESTE
Tela 3 · onde me achar — 3 opções (abrir ao iniciar, gesto, cartão no Simple UI) + PRONTO

Reaproveita os componentes da tela principal (balão, cartões, fonte e escala do Figma).
]]

local Device = require("device")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local InfoMessage = require("ui/widget/infomessage")
local NetworkMgr = require("ui/network/manager")
local InputContainer = require("ui/widget/container/inputcontainer")
local UIManager = require("ui/uimanager")
local Blitbuffer = require("ffi/blitbuffer")
local Screen = Device.screen

local Desenho = require("yomimon_drawing")
local T = require("yomimon_language").t
local Estado = require("yomimon_state")
local Especies = require("yomimon_species")
local Baixar = require("yomimon_download")
local YomimonScreen = require("yomimon_screen")

local okKit, Kit = pcall(require, "lib/bookshelf_module_kit")
local tem_bookshelf = okKit and type(Kit) == "table" and Kit.setOnHomeShelf ~= nil
local MODULO_BOOKSHELF = "yomimon"

local LARG, ALT = 618, 824
local PRETO, BRANCO = Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
local CINZA_55, CINZA_BB = Blitbuffer.Color8(0x55), Blitbuffer.Color8(0xBB)

local POR_PAGINA = 8
local LETRAS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                 "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }

-- A Silkscreen não tem ♀, ♂ nem ’.
local function rotulo(nome)
    return (nome:gsub("♀", " F"):gsub("♂", " M"):gsub("’", "'"):upper())
end

local function listaOrdenada()
    local itens = {}
    for _, linha in ipairs(Especies.linhas) do
        local ultimo = linha[#linha]
        itens[#itens + 1] = {
            base = linha[1], linha = linha,
            nome = rotulo(Especies.nomes[linha[1]]),
            final = ultimo ~= linha[1] and rotulo(Especies.nomes[ultimo]) or nil,
        }
    end
    table.sort(itens, function(a, b) return a.nome < b.nome end)
    return itens
end

local BoasVindas = InputContainer:extend{
    traca = nil,
    passo = 1,
    pagina = 1,
    escolha = nil,      -- item da lista escolhido (tela 2)
    so_escolha = false, -- só trocar de Pokémon: termina na tela 2, sem as perguntas de instalação
    ao_terminar = nil,  -- função chamada no fim
}

-- componentes emprestados da tela da Yomimon
for _, nome in ipairs({ "px", "face", "ret", "texto", "larguraTexto", "cartao", "medirBalao", "balao", "alvo" }) do
    BoasVindas[nome] = YomimonScreen[nome]
end

function BoasVindas:init()
    if Device:isTouchDevice() then
        self.ges_events.Tap = { GestureRange:new{ ges = "tap", range = function() return self.dimen end } }
    end
    if Device:hasKeys() then
        self.key_events.Close = { { Device.input.group.Back } }
    end
    self.covers_fullscreen = true
    local tam = Screen:getSize()
    self.dimen = Geom:new{ x = 0, y = 0, w = tam.w, h = tam.h }
    self.k = math.min(tam.w / LARG, tam.h / ALT)
    self.ox = math.floor((tam.w - LARG * self.k) / 2)
    self.oy = math.floor((tam.h - ALT * self.k) / 2)
    self.fator_fonte = Screen:scaleBySize(1000) / 1000
    self.faces = {}
    self.itens = listaOrdenada()
    self.letras_com = {}
    for _, it in ipairs(self.itens) do self.letras_com[it.nome:sub(1, 1)] = true end
    self.op = {
        iniciar = G_reader_settings:isTrue("yomimon_abrir_ao_iniciar"),
        gesto = G_reader_settings:isTrue("yomimon_gesto"),
        cartao = self.traca:cartaoSimpleUI(),
        estante = tem_bookshelf and Kit.onHomeShelf and Kit.onHomeShelf(MODULO_BOOKSHELF) or false,
    }
end

--- Sprite centrado, com o balão logo acima da cabeça real (como na tela principal).
function BoasVindas:sprite(bb, nome, fala, centro_y, tamanho)
    local escala = math.max(1, math.floor(tamanho * self.k / Desenho.LARGURA))
    local lado = escala * Desenho.LARGURA
    local x = self.ox + self:px(LARG / 2) - math.floor(lado / 2)
    local y = self.oy + self:px(centro_y) - math.floor(lado / 2)
    Desenho.pintarSprite(bb, nome, x, y, escala)
    local cabeca = (y - self.oy) / self.k + Desenho.topoReal(nome) * escala / self.k
    local m = self:medirBalao(fala)
    self:balao(bb, fala, nil, math.max(24, cabeca - 30 - (m.H + 15)), m)
end

--- Botão grande (cartão com sombra) com texto centralizado.
function BoasVindas:botao(bb, texto, y, acao)
    self:cartao(bb, 20, y, 578, 80, true)
    self:texto(bb, texto, 0, y + 24, true, 24, PRETO, LARG / 2)
    self:alvo(14, y - 6, 590, 92, acao)
end

--- Opção com caixinha de marcar (quadrado de pixels, cheio quando ligada).
function BoasVindas:opcao(bb, y, titulo, detalhe, ligada, acao, desativada)
    self:cartao(bb, 20, y, 578, 74, true)
    local cx, cy = 40, y + 24
    if ligada then
        self:ret(bb, cx + 3, cy, 20, 26, PRETO)
        self:ret(bb, cx, cy + 3, 26, 20, PRETO)
        self:ret(bb, cx + 6, cy + 6, 3, 3, BRANCO)
    else
        local cor = desativada and CINZA_BB or PRETO
        self:ret(bb, cx + 3, cy, 20, 3, cor); self:ret(bb, cx + 3, cy + 23, 20, 3, cor)
        self:ret(bb, cx, cy + 3, 3, 20, cor); self:ret(bb, cx + 23, cy + 3, 3, 20, cor)
    end
    self:texto(bb, titulo, 86, y + 16, true, 15, desativada and CINZA_BB or PRETO)
    self:texto(bb, detalhe, 86, y + 42, false, 10, desativada and CINZA_BB or CINZA_55)
    if not desativada then self:alvo(14, y - 4, 590, 82, acao) end
end

--- As espécies da letra escolhida (todas, quando nenhuma está escolhida).
function BoasVindas:visiveis()
    if not self.letra then return self.itens end
    local lista = {}
    for _, it in ipairs(self.itens) do
        if it.nome:sub(1, 1) == self.letra then lista[#lista + 1] = it end
    end
    return lista
end

function BoasVindas:totalPaginas()
    return math.max(1, math.ceil(#self:visiveis() / POR_PAGINA))
end

--- Mostra só a letra tocada; tocar de novo nela volta à lista toda.
function BoasVindas:filtrarLetra(letra)
    self.letra = self.letra ~= letra and letra or nil
    self.pagina = 1
end

function BoasVindas:pintarLista(bb)
    self:texto(bb, T"ESCOLHA SEU POKÉMON", 0, 22, true, 24, PRETO, LARG / 2)
    for i, letra in ipairs(LETRAS) do
        local col, lin = (i - 1) % 13, math.floor((i - 1) / 13)
        local lx, ly = 21 + col * 44, 70 + lin * 44
        local tem = self.letras_com[letra]
        local escolhida = self.letra == letra
        self:cartao(bb, lx, ly, 40, 38, false)
        if escolhida then self:ret(bb, lx + 2, ly + 2, 36, 34, PRETO) end
        self:texto(bb, letra, 0, ly + 8, true, 18, escolhida and BRANCO or (tem and PRETO or CINZA_BB), lx + 20)
        if tem then self:alvo(lx - 2, ly - 2, 44, 42, function() self:filtrarLetra(letra) end) end
    end
    local itens = self:visiveis()
    local primeiro = (self.pagina - 1) * POR_PAGINA
    for n = 1, POR_PAGINA do
        local it = itens[primeiro + n]
        if not it then break end
        local y = 170 + (n - 1) * 68
        self:cartao(bb, 20, y, 578, 58, true)
        self:texto(bb, it.nome, 40, y + 16, true, 20)
        if it.final then
            self:texto(bb, "> " .. it.final, 590 - self:larguraTexto("> " .. it.final, false, 12), y + 22, false, 12, CINZA_55)
        end
        self:alvo(14, y - 4, 590, 66, function() self.escolha, self.passo = it, 2 end)
    end
    local ny = 730
    if self.so_escolha then
        self:cartao(bb, 250, ny, 118, 52, true)
        self:texto(bb, T"SAIR", 0, ny + 14, true, 16, PRETO, 309)
        self:alvo(244, ny - 6, 130, 64, function() self:onClose(); if self.ao_terminar then self.ao_terminar() end end)
    end
    self:cartao(bb, 20, ny, 90, 52, true)
    self:texto(bb, "<", 0, ny + 10, true, 28, PRETO, 65)
    self:alvo(14, ny - 6, 102, 64, function() self.pagina = math.max(1, self.pagina - 1) end)
    self:cartao(bb, 508, ny, 90, 52, true)
    self:texto(bb, ">", 0, ny + 10, true, 28, PRETO, 553)
    self:alvo(502, ny - 6, 102, 64, function() self.pagina = math.min(self:totalPaginas(), self.pagina + 1) end)
    self:texto(bb, string.format("%d/%d", self.pagina, self:totalPaginas()), 0, self.so_escolha and ny + 62 or ny + 16, false, 16, PRETO, LARG / 2)
end

--- Descrição da Pokédex num cartão, quebrada em até 4 linhas (a última termina em "..." se não couber).
function BoasVindas:pintarDescricao(bb, texto, y)
    local largura, linhas, atual = 510, {}, ""
    for palavra in texto:gmatch("%S+") do
        local candidata = atual == "" and palavra or atual .. " " .. palavra
        if atual ~= "" and self:larguraTexto(candidata, false, 11) > largura then
            linhas[#linhas + 1], atual = atual, palavra
        else
            atual = candidata
        end
    end
    if atual ~= "" then linhas[#linhas + 1] = atual end
    if #linhas > 4 then
        linhas[4] = linhas[4]:gsub("%s*%S+$", "") .. "..."
        for i = #linhas, 5, -1 do linhas[i] = nil end
    end
    self:cartao(bb, 20, y, 578, 20 + #linhas * 16, false)
    for i, linha in ipairs(linhas) do
        self:texto(bb, linha, 40, y + 10 + (i - 1) * 16, false, 11, PRETO)
    end
end

function BoasVindas:pintarConfirmacao(bb)
    local it = self.escolha
    local forma = Especies.nomes[it.base]
    local baixado = self:spriteBaixado(it)
    local nome = baixado and "p" .. it.base or "bola"
    local fala = baixado and string.format(T"%s! Boa escolha. Vou ficar de olho na sua leitura.", forma)
        or string.format(T"(%s ainda não chegou: o desenho é baixado com o Wi-Fi ligado)", forma)
    local descricao = Baixar.descricao(it.base)
    if descricao then
        self:sprite(bb, nome, fala, 375, 230)
        self:pintarDescricao(bb, descricao, 500)
    else
        self:sprite(bb, nome, fala, 430, 295)
    end
    if not baixado then
        self:botao(bb, T"BAIXAR (WI-FI)", 590, function() self:baixarSprites() end)
    end
    self:botao(bb, T"ESCOLHER ESTE", 690, function() self:escolher() end)
    self:cartao(bb, 20, 760, 120, 40, true)
    self:texto(bb, T"VOLTAR", 0, 770, true, 14, PRETO, 80)
    self:alvo(14, 754, 132, 52, function() self.passo = 1 end)
end

function BoasVindas:spriteBaixado(it)
    for _, dex in ipairs(it.linha) do
        if not Baixar.tem(dex) then return false end
    end
    return true
end

-- Mostra "Baixando…" antes de bloquear a tela com o download (arquivos de ~1 KB, mas a conexão pode demorar).
function BoasVindas:baixar(linha)
    local aviso = InfoMessage:new{ text = T"Baixando o desenho…" }
    UIManager:show(aviso)
    UIManager:forceRePaint()
    pcall(Baixar.linha, linha)
    UIManager:close(aviso)
end

function BoasVindas:baixarSprites()
    local it = self.escolha
    NetworkMgr:runWhenOnline(function()
        self:baixar(it.linha)
        UIManager:setDirty(self, "ui")
    end)
end

function BoasVindas:escolher()
    local it = self.escolha
    Estado.trocarEspecie(self.traca.estado, it.base)
    if not self:spriteBaixado(it) and NetworkMgr:isOnline() then self:baixar(it.linha) end
    if NetworkMgr:isOnline() then pcall(Baixar.baixarDescricao, it.base) end
    pcall(function() require("yomimon_simpleui").sincronizarCritter(self.traca) end)
    if self.so_escolha then
        self.traca:salvar(true)
        UIManager:close(self)
        if self.ao_terminar then self.ao_terminar() end
        return
    end
    self.passo = 3
end

function BoasVindas:paintTo(bb, x, y)
    self.dimen.x, self.dimen.y = x, y
    bb:paintRect(x, y, self.dimen.w, self.dimen.h, BRANCO)
    self.alvos = {}
    self.camada = "conteudo"
    if self.passo == 1 then
        self:pintarLista(bb)

    elseif self.passo == 2 then
        self:pintarConfirmacao(bb)

    else
        local s = self.traca.estado
        local f = Estado.fase(s)
        self:sprite(bb, self:spriteBaixado({ linha = { f.dex or 0 } }) and f.nome or "bola",
            T"Onde você vai me achar? Escolha. Eu espero.", 245, 170)
        self:opcao(bb, 360, T"ABRIR AO INICIAR", T"O YOMIMON APARECE QUANDO O KOREADER ABRE",
            self.op.iniciar, function() self.op.iniciar = not self.op.iniciar end)
        self:opcao(bb, 440, T"ATALHO POR GESTO", T"SEGURE O DEDO NO CANTO SUPERIOR DIREITO",
            self.op.gesto, function() self.op.gesto = not self.op.gesto end)
        local tem_sui = self.traca:temSimpleUI()
        self:opcao(bb, 520, T"CARTÃO NA HOME", tem_sui and T"NO LUGAR DO CRITTER DO SIMPLE UI" or T"SIMPLE UI NÃO INSTALADO",
            tem_sui and self.op.cartao, function() self.op.cartao = not self.op.cartao end, not tem_sui)
        self:opcao(bb, 600, T"CARTÃO NO BOOKSHELF", tem_bookshelf and T"NA PRIMEIRA PRATELEIRA COM LIVROS" or T"BOOKSHELF NÃO INSTALADO",
            tem_bookshelf and self.op.estante, function() self.op.estante = not self.op.estante end, not tem_bookshelf)
        self:botao(bb, T"PRONTO", 696, function() self:terminar() end)
    end
end

function BoasVindas:terminar()
    local s = self.traca.estado
    s.boasvindas = true
    G_reader_settings:saveSetting("yomimon_abrir_ao_iniciar", self.op.iniciar or nil)
    G_reader_settings:saveSetting("yomimon_gesto", self.op.gesto or nil)
    self.traca:aplicarGesto()
    if self.traca:temSimpleUI() then self.traca:cartaoSimpleUI(self.op.cartao) end
    if tem_bookshelf then pcall(Kit.setOnHomeShelf, MODULO_BOOKSHELF, self.op.estante) end
    self.traca:salvar(false)
    self.alvos = nil
    UIManager:close(self)
    if self.ao_terminar then self.ao_terminar() end
end

function BoasVindas:onTap(_, ges)
    local pos = ges and ges.pos
    if not pos then return end
    for i = #(self.alvos or {}), 1, -1 do
        local a = self.alvos[i]
        if pos:intersectWith(a.rect) then
            a.acao()
            if self.alvos then UIManager:setDirty(self, "ui") end
            return true
        end
    end
    return true
end

function BoasVindas:onClose()
    UIManager:close(self)  -- fechar no meio: sem Pokémon escolhido; as perguntas voltam depois
    return true
end

-- Proteção (como na tela da Yomimon): se falhar, toque fecha.
require("yomimon_guard").padrao:envolver(BoasVindas, { "paintTo", "onTap" }, function(nome, self, bb, x, y)
    if nome == "paintTo" then
        bb:paintRect(x, y, self.dimen.w, self.dimen.h, BRANCO)
    elseif nome == "onTap" then
        UIManager:close(self)
        return true
    end
end)

return BoasVindas
