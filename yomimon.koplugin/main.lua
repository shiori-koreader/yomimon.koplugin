--[[--
Yomimon: a virtual pet that feeds on the letters you read.

Each page read (with at least a few seconds of reading) becomes food.
The state lives in settings/yomimon.lua; the sleep-screen image in koreader/yomimon/.
]]

local DataStorage = require("datastorage")
local Dispatcher = require("dispatcher")
local InfoMessage = require("ui/widget/infomessage")
local LuaSettings = require("luasettings")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")

local Baixar = require("yomimon_download")
local Desenho = require("yomimon_drawing")
local Guarda = require("yomimon_guard")
local T = require("yomimon_language").t
local Estado = require("yomimon_state")
local Contagem = require("yomimon_counting")
local Memoria = require("yomimon_memory")
local Diario = require("yomimon_diary")
local YomimonScreen = require("yomimon_screen")
local Screensaver = require("ui/screensaver")

-- No Yomimon error interrupts reading: it goes to the log; after 3 in a row it stays quiet
-- until KOReader restarts and warns once (see yomimon_guard.lua and the end of this file).
Guarda.padrao:configurar(
    function(nome, err) logger.warn("Yomimon: error in " .. tostring(nome) .. " (reading continues):", err) end,
    function()
        UIManager:nextTick(function()
            UIManager:show(InfoMessage:new{
                text = T"Yomimon ran into a problem and will stay quiet until you restart KOReader. Your reading wasn't affected.",
            })
        end)
    end)

local LETRAS_POR_SEGUNDO = 60    -- reading speed ceiling
local LETRAS_ESTIMADAS = 1200    -- used when the page text cannot be extracted
local PAGINAS_ENTRE_IMAGENS = 10 -- how many pages between sleep-screen redraws

local Yomimon = WidgetContainer:extend{
    name = "yomimon",
    is_doc_only = false,
}

-- KOReader shows the sleep screen before telling plugins it is going to sleep (Screensaver:setup and show,
-- then the Suspend event). So that the phrase is chosen when the Kindle goes to sleep, Yomimon draws the image
-- here, right before KOReader picks the image up from the folder. Wrapped once, even if the plugin reloads.
if not Screensaver.yomimon_original_setup then
    Screensaver.yomimon_original_setup = Screensaver.setup
    Screensaver.setup = function(...)
        local traca = Screensaver.yomimon_instance
        if traca then pcall(traca.aoDormir, traca) end
        return Screensaver.yomimon_original_setup(...)
    end
end

-- Settings keys renamed in 1.0.0: carry the old values over so nobody has to set them again.
local function migrarConfiguracoes()
    for velho, novo in pairs({ yomimon_gesto = "yomimon_gesture", yomimon_abrir_ao_iniciar = "yomimon_open_at_startup" }) do
        local valor = G_reader_settings:readSetting(velho)
        if valor ~= nil then
            if G_reader_settings:readSetting(novo) == nil then G_reader_settings:saveSetting(novo, valor) end
            G_reader_settings:delSetting(velho)
        end
    end
end

function Yomimon:init()
    migrarConfiguracoes()
    Screensaver.yomimon_instance = self  -- the Yomimon open right now (library or reader)
    self.pasta = DataStorage:getDataDir() .. "/yomimon"
    self.imagem = self.pasta .. "/yomimon.png"
    self.db = LuaSettings:open(DataStorage:getSettingsDir() .. "/yomimon.lua")
    local agora = os.time()
    self.estado = Estado.normalizar(self.db:readSetting("estado"), agora)
    Estado.passarTempo(self.estado, agora)
    self.paginas_sem_imagem = 0
    -- dev mode: with the file koreader/yomimon/falhar, page digestion fails on purpose (never in the community
    -- version)
    local okV, Versao = pcall(require, "yomimon_version")
    local publica = okV and type(Versao) == "table" and Versao.publica
    self.falha_teste = not publica and lfs.attributes(self.pasta .. "/falhar", "mode") == "file"
    self.ui.menu:registerToMainMenu(self)
    self:onDispatcherRegisterActions()
    self:aplicarGesto()
    UIManager:nextTick(function() self:aoIniciar() end)
    UIManager:nextTick(function() Guarda.padrao:chamar("garantirSprites", self.garantirSprites, self) end)
    -- card on the home screen and button in Simple UI, if it is installed
    local ok, Integracao = pcall(require, "yomimon_simpleui")
    if ok then
        Integracao.registrar(self)
    else
        logger.warn("Yomimon: Simple UI integration unavailable:", Integracao)
    end
end

-- The action id and the event name below stay as they are: the Dispatcher saves them in the user's gesture
-- settings, and renaming would unbind a gesture someone already set.
function Yomimon:onDispatcherRegisterActions()
    Dispatcher:registerAction("yomimon_mostrar", {
        category = "none", event = "MostrarTraca", title = T"Yomimon: show the creature", general = true,
    })
end

function Yomimon:addToMainMenu(menu_items)
    menu_items.yomimon = {
        text = T"Yomimon",
        sorting_hint = "tools",
        sub_item_table = {
            { text = T"Open Yomimon", callback = function() self:onMostrarTraca() end },
            {
                -- Bilingual on purpose: someone on the wrong language must be able to find it.
                text = "Language / Idioma",
                sub_item_table_func = function() return self:itensIdioma() end,
            },
            { text = T"About and disclaimer", callback = function() self:mostrarSobre() end },
        },
    }
end

function Yomimon:itensIdioma()
    local Lingua = require("yomimon_language")
    local function item(texto, valor)
        return {
            text = texto,
            radio = true,
            checked_func = function() return Lingua.choice() == valor end,
            callback = function()
                Lingua.saveChoice(valor)
                UIManager:show(require("ui/widget/infomessage"):new{ text = T"Restart KOReader to change the language." })
            end,
        }
    end
    local itens = { item(T"Automatic (KOReader language)", "auto") }
    for _, idioma in ipairs(Lingua.available()) do itens[#itens + 1] = item(idioma.name, idioma.code) end
    return itens
end

function Yomimon:mostrarSobre()
    UIManager:show(require("ui/widget/infomessage"):new{
        text = T"Yomimon is an unofficial fan project. It is not affiliated with or endorsed by Nintendo, Game Freak, Creatures or The Pokémon Company. Pokémon names and sprites belong to their owners: the sprites are downloaded on your device from PokeAPI and are not part of this plugin.\n\nBased on Silverfish by Matheus Oliveira. Code under GPL-3.0; phrases under CC BY-NC-SA 4.0.",
    })
end

-- Yomimon screens that are open (the main one and the welcome), from any plugin instance. Only one at a time,
-- and it closes with the library or book that opened it. Without this, a screen covered by another window (for
-- example Simple UI opening the Home over it when the Kindle wakes up) was forgotten underneath; when leaving
-- KOReader, which only closes once no window is left, the forgotten screens showed up piled together.
local telas = setmetatable({}, { __mode = "k" })

local function fecharTelas(dono)
    for tela in pairs(telas) do
        if not dono or tela.traca == dono then
            telas[tela] = nil
            if not UIManager.isWidgetShown or UIManager:isWidgetShown(tela) then UIManager:close(tela) end
        end
    end
end

function Yomimon:mostrarTela(tela)
    fecharTelas()
    telas[tela] = true
    UIManager:show(tela)
end

function Yomimon:onCloseWidget()
    fecharTelas(self)
end

function Yomimon:onMostrarTraca()
    Estado.passarTempo(self.estado, os.time())
    local s = self.estado
    -- no Pokémon chosen yet: the welcome comes first
    if not s.boasvindas or not s.especie then
        return self:mostrarBoasVindas()
    end
    self:mostrarTela(YomimonScreen:new{ traca = self })
    return true
end

--- so_escolha: opens only the Pokémon list (to switch), without the install questions.
function Yomimon:mostrarBoasVindas(so_escolha)
    local BoasVindas = require("yomimon_welcome")
    self:mostrarTela(BoasVindas:new{
        traca = self,
        so_escolha = so_escolha == true,
        ao_terminar = function()
            self:mostrarTela(YomimonScreen:new{ traca = self })
            if not G_reader_settings:isTrue("yomimon_about_seen") then
                G_reader_settings:saveSetting("yomimon_about_seen", true)
                self:mostrarSobre()
            end
        end,
    })
    return true
end

-- First opening and "open at startup" (once per KOReader session, in the library)
local ja_abriu_nesta_sessao = false

function Yomimon:aoIniciar()
    if ja_abriu_nesta_sessao or self.ui.document then return end
    ja_abriu_nesta_sessao = true
    local s = self.estado
    if not s.boasvindas or not s.especie then
        UIManager:scheduleIn(1, function() self:mostrarBoasVindas() end)
    elseif G_reader_settings:isTrue("yomimon_open_at_startup") then
        UIManager:scheduleIn(1, function() self:onMostrarTraca() end)
    end
end

-- Gesture shortcut: holding a finger on the top right corner opens Yomimon.
function Yomimon:aplicarGesto()
    if not (self.ui and self.ui.registerTouchZones) then return end
    if self.ui.unregisterTouchZones then
        pcall(self.ui.unregisterTouchZones, self.ui, { { id = "yomimon_gesture" } })
    end
    if G_reader_settings:isTrue("yomimon_gesture") then
        self.ui:registerTouchZones({{
            id = "yomimon_gesture",
            ges = "hold",
            screen_zone = { ratio_x = 0.85, ratio_y = 0, ratio_w = 0.15, ratio_h = 0.1 },
            handler = function() return self:onMostrarTraca() end,
        }})
    end
end

-- Simple UI: is it installed? And is the Yomimon card on the Home?
function Yomimon:temSimpleUI()
    local ok = pcall(require, "modules/moduleregistry")
    return ok
end

function Yomimon:cartaoSimpleUI(ligar)
    local ok, SUISettings = pcall(require, "infra/sui_store")
    if not ok or not SUISettings then return false end
    local chave = "simpleui_hs_traca_cartao_enabled"
    if ligar ~= nil then
        pcall(SUISettings.saveSetting, SUISettings, chave, ligar and true or false)
        G_reader_settings:saveSetting("yomimon_critter", ligar and true or nil)
        if ligar then pcall(function() require("yomimon_simpleui").sincronizarCritter(self, true) end) end
    end
    local okr, v = pcall(SUISettings.readSetting, SUISettings, chave)
    if not okr or v == nil then return true end
    return v == true
end

-- Reading ------------------------------------------------------------------

function Yomimon:onPageUpdate(pageno)
    if not self.ui.document or type(pageno) ~= "number" then return end
    self:contarPaginaAtual()
    self.pagina = pageno
    self.pagina_desde = os.time()
end

--- Gives the page that was open to Yomimon to eat.
-- It counts like KOReader's statistics (once per book, their minimum time); it only shapes Yomimon
-- (themes, characters, traits, memories) if it was really read (yomimon_counting.lua).
function Yomimon:contarPaginaAtual()
    local p, desde = self.pagina, self.pagina_desde
    if not p or not desde then return end
    local tempo = os.time() - desde
    if tempo < Contagem.minimoSegundos(G_reader_settings:readSetting("statistics")) then return end
    local onde = self:ondeEstou(p)
    local livro = onde.livro or "?"
    local total = self.ui.document and self.ui.document:getPageCount()
    local nova = Contagem.primeiraVez(self.estado, livro, p, total, os.time())
    local texto = self:textoDaPagina(p)
    local reais = texto and Estado.contarLetras(texto) or LETRAS_ESTIMADAS
    -- shapes Yomimon on the first pass that is real reading (it may come after flipping through)
    local lida = not Contagem.jaLida(self.estado, livro, p)
        and Contagem.lidaDeVerdade(self.estado, tempo, reais, onde.capitulo, texto)
    if not nova and not lida then return end
    if lida then Contagem.marcarLida(self.estado, livro, p) end
    local letras = nova and math.min(reais, tempo * LETRAS_POR_SEGUNDO) or 0
    self:alimentar(letras, Estado.palavraMaisLonga(texto), onde, lida and texto or nil, nova)
end

--- Book and chapter of the page (for the "last meal").
function Yomimon:ondeEstou(p)
    local onde = {}
    pcall(function()
        local props = self.ui.doc_props
        onde.livro = props and (props.display_title or props.title)
        onde.autor = props and props.authors and props.authors:gsub("\n.*", "")
        onde.etiquetas = props and props.keywords  -- the EPUB subject, one tag per line (yomimon_data/genres.lua)
        onde.arquivo = self.ui.document and self.ui.document.file
        if self.ui.toc then onde.capitulo = self.ui.toc:getTocTitleByPage(p) end
        local total = self.ui.document and self.ui.document:getPageCount()
        if total and total > 0 then
            onde.progresso = math.min(1, p / total)
            onde.fim_historia = self:fimDaHistoria(total)
        end
    end)
    if onde.capitulo == "" then onde.capitulo = nil end
    return onde
end

--- Progress (0 to 1) where the story ends, from the table of contents (Diario.fimDaHistoria): notes, timeline,
-- afterword and ads after it do not count towards finishing the book. Redone when the total of pages
-- changes (font, margins); nil when the table of contents does not help (then the file's 98% applies).
function Yomimon:fimDaHistoria(total)
    if self.fim_historia_total ~= total then
        self.fim_historia_total, self.fim_historia = total, nil
        local toc = self.ui.toc
        if toc and toc.fillToc then toc:fillToc() end
        local itens = {}
        for _, item in ipairs(toc and toc.toc or {}) do
            local pagina = item.fixed_page or item.page  -- fixed_page: an out-of-order item corrected by KOReader
            if type(pagina) == "number" then
                itens[#itens + 1] = { titulo = item.title, pagina = pagina, nivel = item.depth }
            end
        end
        local fim = Diario.fimDaHistoria(itens, total)
        if fim then self.fim_historia = fim / total end
    end
    return self.fim_historia
end

--- Fallback for the end of the book: you marked the book as finished in KOReader (Diario.statusKOReader).
-- Returns true when that finished the book just now.
function Yomimon:conferirTerminado()
    if not self.ui.document or self.estado.dev_simulacao then return false end
    local resumo = self.ui.doc_settings and self.ui.doc_settings:readSetting("summary")
    local livro = self:ondeEstou(self.pagina or 1).livro
    return Diario.statusKOReader(self.estado, Memoria, livro, type(resumo) == "table" and resumo.status or nil,
        os.time()) == true
end

function Yomimon:onReaderReady()
    if self:conferirTerminado() then self:salvar(true) end
end

function Yomimon:textoDaPagina(p)
    local doc = self.ui.document
    local ok, texto = pcall(function()
        if self.ui.rolling then
            if p >= doc:getPageCount() then return end
            local xp0, xp1 = doc:getPageXPointer(p), doc:getPageXPointer(p + 1)
            if not (xp0 and xp1) then return end
            local r = doc:getTextFromXPointers(xp0, xp1)
            return type(r) == "table" and r.text or r
        elseif doc.getPageTextBoxes then
            local caixas = doc:getPageTextBoxes(p)
            if not caixas then return end
            local partes = {}
            for _, linha in ipairs(caixas) do
                for _, palavra in ipairs(linha) do
                    if palavra.word then partes[#partes + 1] = palavra.word end
                end
            end
            return table.concat(partes, " ")
        end
    end)
    if ok and type(texto) == "string" and texto ~= "" then return texto end
    if not ok then logger.dbg("Yomimon: no text for the page", p, texto) end
end

-- contar: false when the page was already counted and is now only being digested (not counted again).
function Yomimon:alimentar(letras, palavra, onde, texto, contar)
    if self.falha_teste then error("falha de teste injetada (modo dev: koreader/yomimon/falhar)") end
    if self.estado.dev_simulacao then return end  -- demo simulation: frozen, real reading does not enter
    local agora = os.time()
    local ocorreu = contar ~= false and Estado.comer(self.estado, letras, palavra, agora, onde) or {}
    pcall(Memoria.digerir, self.estado, texto, onde, agora, contar)
    self.paginas_sem_imagem = self.paginas_sem_imagem + 1
    local aviso
    if ocorreu.evoluiu then
        aviso = ocorreu.evoluiu.aviso or string.format(T"Yomimon is now %s!", ocorreu.evoluiu.titulo)
    elseif ocorreu.acordou then
        aviso = T"Yomimon came out of its ball. Hungry, of course."
    end
    if aviso then
        if ocorreu.evoluiu then pcall(function() require("yomimon_simpleui").sincronizarCritter(self) end) end
        Memoria.anotar(self.estado, agora, aviso)
        UIManager:show(InfoMessage:new{ text = aviso, timeout = 4 })
        self:salvar(true)
    elseif self.paginas_sem_imagem >= PAGINAS_ENTRE_IMAGENS then
        self:salvar(true)
    end
end

--- Downloads the missing sprites of the chosen species and of every registered one (only with Wi-Fi already on: it never asks to turn it on).
function Yomimon:garantirSprites()
    if self.ui.document then return end
    local faltam = {}
    local especies = { self.estado.especie }
    for base in pairs(self.estado.colecao or {}) do especies[#especies + 1] = base end
    for _, base in ipairs(especies) do
        for _, f in ipairs(Estado.formas({ especie = base })) do
            if f.dex and not Baixar.tem(f.dex) then faltam[#faltam + 1] = f.dex end
        end
    end
    if #faltam > 0 and require("ui/network/manager"):isOnline() then Baixar.linha(faltam) end
    pcall(function() require("yomimon_simpleui").sincronizarCritter(self) end)
end

-- The critter image depends on night mode, so it is rewritten whenever the mode flips.
function Yomimon:onNightModeChanged()
    pcall(function() require("yomimon_simpleui").sincronizarCritter(self) end)
end

-- Dev mode: endgame simulation ---------------------------------------------------
-- The simulated state (koreader/yomimon/simulacao.lua, generated by ferramentas/simular_endgame.lua)
-- takes the place of the real one, which stays saved in settings/yomimon.lua ("estado_real") until it comes back.

function Yomimon:emSimulacao()
    return self.db:readSetting("estado_real") ~= nil
end

function Yomimon:carregarSimulacao()
    local arquivo = self.pasta .. "/simulacao.lua"
    if lfs.attributes(arquivo, "mode") ~= "file" then return false end
    local ok, sim = pcall(function() return LuaSettings:open(arquivo):readSetting("estado") end)
    if not ok or type(sim) ~= "table" then return false end
    if not self:emSimulacao() then self.db:saveSetting("estado_real", self.estado) end
    self.estado = Estado.normalizar(sim, os.time())
    self.estado.dev_simulacao = true
    Estado.passarTempo(self.estado, os.time())
    self:salvar(true)
    return true
end

function Yomimon:voltarEstadoReal()
    local real = self.db:readSetting("estado_real")
    if not real then return false end
    self.estado = Estado.normalizar(real, os.time())
    self.db:delSetting("estado_real")
    self:salvar(true)
    return true
end

function Yomimon:carinho()
    local ok = Estado.carinho(self.estado, os.time())
    if ok then self:salvar(true) end
    return ok
end

-- Persistence -------------------------------------------------------------

function Yomimon:salvar(com_imagem)
    self.db:saveSetting("estado", self.estado)
    self.db:flush()
    if com_imagem then self:gerarImagem() end
end

-- escolher = true only when the Kindle goes to sleep (aoDormir): in the other redraws, which nobody sees, the
-- phrase is the last one chosen and nothing is spent (Estado.falaDescanso).
function Yomimon:gerarImagem(forcar, escolher)
    if not forcar and not self:telaDescansoAtiva() then return end
    if lfs.attributes(self.pasta, "mode") ~= "directory" then lfs.mkdir(self.pasta) end
    local ok, err = Desenho.gravar(YomimonScreen.gerarTelaDescanso, self.estado, self.imagem, os.time(), escolher)
    if not ok then logger.warn("Yomimon: falha ao gerar a tela de descanso:", err) end
    self.paginas_sem_imagem = 0
end

--- The Kindle is going to sleep (called before KOReader shows the sleep screen): picks the phrase and draws the image.
function Yomimon:aoDormir()
    if not self:telaDescansoAtiva() then return end
    Estado.passarTempo(self.estado, os.time())
    self:gerarImagem(false, true)
end

function Yomimon:onCloseDocument()
    self:contarPaginaAtual()
    self:conferirTerminado()
    self:salvar(true)
end

function Yomimon:onSuspend()
    self:contarPaginaAtual()
    self:conferirTerminado()
    Estado.passarTempo(self.estado, os.time())
    self:salvar(true)
end

function Yomimon:onResume()
    if self.pagina then self.pagina_desde = os.time() end
    Estado.passarTempo(self.estado, os.time())
    self:gerarImagem() -- leaves the image ready for the next time the Kindle sleeps
end

function Yomimon:onFlushSettings()
    self:salvar(false)
end

-- Sleep screen -----------------------------------------------------------

function Yomimon:telaDescansoAtiva()
    return G_reader_settings:readSetting("screensaver_type") == "random_image"
        and G_reader_settings:readSetting("screensaver_dir") == self.pasta
end

--- Turns Yomimon on or off as the sleep screen, keeping the previous setting.
function Yomimon:alternarTelaDescanso()
    if self:telaDescansoAtiva() then
        local ant = self.db:readSetting("tela_anterior") or {}
        G_reader_settings:saveSetting("screensaver_type", ant.tipo or "disable")
        if ant.pasta then
            G_reader_settings:saveSetting("screensaver_dir", ant.pasta)
        else
            G_reader_settings:delSetting("screensaver_dir")
        end
        if ant.mensagem ~= nil then
            G_reader_settings:saveSetting("screensaver_show_message", ant.mensagem)
        end
        self.db:delSetting("tela_anterior")
    else
        self.db:saveSetting("tela_anterior", {
            tipo = G_reader_settings:readSetting("screensaver_type"),
            pasta = G_reader_settings:readSetting("screensaver_dir"),
            mensagem = G_reader_settings:readSetting("screensaver_show_message"),
        })
        self:gerarImagem(true)
        G_reader_settings:saveSetting("screensaver_type", "random_image")
        G_reader_settings:saveSetting("screensaver_dir", self.pasta)
        G_reader_settings:saveSetting("screensaver_show_message", false)
    end
    self:salvar(false)
end

--- Dev mode: turns the test failure on or off in reading (creates or deletes koreader/yomimon/falhar).
function Yomimon:alternarFalhaTeste()
    local arquivo = self.pasta .. "/falhar"
    if self.falha_teste then
        os.remove(arquivo)
        self.falha_teste = false
    else
        if lfs.attributes(self.pasta, "mode") ~= "directory" then lfs.mkdir(self.pasta) end
        local f = io.open(arquivo, "w")
        if f then f:write("teste\n"); f:close() end
        self.falha_teste = true
    end
    return self.falha_teste
end

-- Every point where KOReader calls Yomimon goes through the guard.
Guarda.padrao:envolver(Yomimon, { "onPageUpdate", "onCloseDocument", "onSuspend", "onResume", "onFlushSettings",
    "onMostrarTraca", "aoIniciar", "mostrarBoasVindas", "onReaderReady", "aoDormir", "onCloseWidget" })

return Yomimon
