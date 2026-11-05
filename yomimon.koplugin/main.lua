--[[--
Yomimon: um bichinho virtual que se alimenta das letras que você lê.

Cada página lida (com pelo menos alguns segundos de leitura) vira comida.
O estado fica em settings/yomimon.lua; a imagem da tela de descanso em koreader/yomimon/.
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

-- Nenhum erro da Yomimon interrompe a leitura: vai para o log; depois de 3 seguidos ela se cala
-- até o KOReader reiniciar e avisa uma vez (ver yomimon_guard.lua e o fim deste arquivo).
Guarda.padrao:configurar(
    function(nome, err) logger.warn("Yomimon: erro em " .. tostring(nome) .. " (a leitura continua):", err) end,
    function()
        UIManager:nextTick(function()
            UIManager:show(InfoMessage:new{
                text = T"O Yomimon teve um problema e vai ficar quieto até você reiniciar o KOReader. Sua leitura não foi afetada.",
            })
        end)
    end)

local LETRAS_POR_SEGUNDO = 60    -- teto de velocidade de leitura
local LETRAS_ESTIMADAS = 1200    -- quando não dá para extrair o texto da página
local PAGINAS_ENTRE_IMAGENS = 10 -- de quantas em quantas páginas redesenha a tela de descanso

local Yomimon = WidgetContainer:extend{
    name = "yomimon",
    is_doc_only = false,
}

-- O KOReader mostra a tela de descanso antes de avisar os plugins que vai dormir (Screensaver:setup e show,
-- depois o evento Suspend). Para a fala ser escolhida quando o Kindle vai dormir, a Yomimon desenha a imagem
-- aqui, logo antes de o KOReader pegar a imagem da pasta. Embrulha uma vez só, mesmo se o plugin recarregar.
if not Screensaver.yomimon_setup_original then
    Screensaver.yomimon_setup_original = Screensaver.setup
    Screensaver.setup = function(...)
        local traca = Screensaver.yomimon_instancia
        if traca then pcall(traca.aoDormir, traca) end
        return Screensaver.yomimon_setup_original(...)
    end
end

function Yomimon:init()
    Screensaver.yomimon_instancia = self  -- a Yomimon aberta agora (biblioteca ou leitor)
    self.pasta = DataStorage:getDataDir() .. "/yomimon"
    self.imagem = self.pasta .. "/yomimon.png"
    self.db = LuaSettings:open(DataStorage:getSettingsDir() .. "/yomimon.lua")
    local agora = os.time()
    self.estado = Estado.normalizar(self.db:readSetting("estado"), agora)
    Estado.passarTempo(self.estado, agora)
    self.paginas_sem_imagem = 0
    -- modo dev: com o arquivo koreader/yomimon/falhar, a digestão da página falha de propósito (nunca na versão
    -- da comunidade)
    local okV, Versao = pcall(require, "yomimon_version")
    local publica = okV and type(Versao) == "table" and Versao.publica
    self.falha_teste = not publica and lfs.attributes(self.pasta .. "/falhar", "mode") == "file"
    self.ui.menu:registerToMainMenu(self)
    self:onDispatcherRegisterActions()
    self:aplicarGesto()
    UIManager:nextTick(function() self:aoIniciar() end)
    UIManager:nextTick(function() Guarda.padrao:chamar("garantirSprites", self.garantirSprites, self) end)
    -- cartão na tela inicial e botão no Simple UI, se ele estiver instalado
    local ok, Integracao = pcall(require, "yomimon_simpleui")
    if ok then
        Integracao.registrar(self)
    else
        logger.warn("Yomimon: integração com o Simple UI indisponível:", Integracao)
    end
end

function Yomimon:onDispatcherRegisterActions()
    Dispatcher:registerAction("yomimon_mostrar", {
        category = "none", event = "MostrarTraca", title = T"Yomimon: ver o bichinho", general = true,
    })
end

function Yomimon:addToMainMenu(menu_items)
    menu_items.yomimon = {
        text = T"Yomimon",
        sorting_hint = "tools",
        callback = function() self:onMostrarTraca() end,
    }
end

-- Telas da Yomimon abertas (a principal e as boas-vindas), de qualquer instância do plugin. Fica uma só por vez,
-- e ela fecha junto com a biblioteca ou o livro que a abriu. Sem isso, uma tela coberta por outra janela (ex.: o
-- Simple UI abre a Home por cima dela quando o Kindle acorda) ficava esquecida embaixo; ao sair do KOReader, que
-- só fecha quando não sobra janela, as telas esquecidas apareciam empilhadas.
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
    -- sem Pokémon escolhido: as boas-vindas vêm antes
    if not s.boasvindas or not s.especie then
        return self:mostrarBoasVindas()
    end
    self:mostrarTela(YomimonScreen:new{ traca = self })
    return true
end

--- so_escolha: abre só a lista de Pokémon (para trocar), sem as perguntas de instalação.
function Yomimon:mostrarBoasVindas(so_escolha)
    local BoasVindas = require("yomimon_welcome")
    self:mostrarTela(BoasVindas:new{
        traca = self,
        so_escolha = so_escolha == true,
        ao_terminar = function() self:mostrarTela(YomimonScreen:new{ traca = self }) end,
    })
    return true
end

-- Primeira abertura e "abrir ao iniciar" (só uma vez por sessão do KOReader, na biblioteca)
local ja_abriu_nesta_sessao = false

function Yomimon:aoIniciar()
    if ja_abriu_nesta_sessao or self.ui.document then return end
    ja_abriu_nesta_sessao = true
    local s = self.estado
    if not s.boasvindas or not s.especie then
        UIManager:scheduleIn(1, function() self:mostrarBoasVindas() end)
    elseif G_reader_settings:isTrue("yomimon_abrir_ao_iniciar") then
        UIManager:scheduleIn(1, function() self:onMostrarTraca() end)
    end
end

-- Atalho por gesto: segurar o dedo no canto superior direito abre a Yomimon.
function Yomimon:aplicarGesto()
    if not (self.ui and self.ui.registerTouchZones) then return end
    if self.ui.unregisterTouchZones then
        pcall(self.ui.unregisterTouchZones, self.ui, { { id = "yomimon_gesto" } })
    end
    if G_reader_settings:isTrue("yomimon_gesto") then
        self.ui:registerTouchZones({{
            id = "yomimon_gesto",
            ges = "hold",
            screen_zone = { ratio_x = 0.85, ratio_y = 0, ratio_w = 0.15, ratio_h = 0.1 },
            handler = function() return self:onMostrarTraca() end,
        }})
    end
end

-- Simple UI: está instalado? E o cartão da Yomimon está ligado na Home?
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

-- Leitura ------------------------------------------------------------------

function Yomimon:onPageUpdate(pageno)
    if not self.ui.document or type(pageno) ~= "number" then return end
    self:contarPaginaAtual()
    self.pagina = pageno
    self.pagina_desde = os.time()
end

--- Dá a página que estava aberta para a Yomimon comer.
-- Conta como as estatísticas do KOReader (uma vez por livro, tempo mínimo delas); só molda o Yomimon
-- (temas, personagens, traços, lembranças) se foi lida de verdade (yomimon_counting.lua).
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
    -- molda o Yomimon na primeira passagem que for leitura de verdade (pode ser depois de folhear)
    local lida = not Contagem.jaLida(self.estado, livro, p)
        and Contagem.lidaDeVerdade(self.estado, tempo, reais, onde.capitulo, texto)
    if not nova and not lida then return end
    if lida then Contagem.marcarLida(self.estado, livro, p) end
    local letras = nova and math.min(reais, tempo * LETRAS_POR_SEGUNDO) or 0
    self:alimentar(letras, Estado.palavraMaisLonga(texto), onde, lida and texto or nil, nova)
end

--- Livro e capítulo da página (para a "última refeição").
function Yomimon:ondeEstou(p)
    local onde = {}
    pcall(function()
        local props = self.ui.doc_props
        onde.livro = props and (props.display_title or props.title)
        onde.autor = props and props.authors and props.authors:gsub("\n.*", "")
        onde.etiquetas = props and props.keywords  -- assunto do EPUB, uma etiqueta por linha (yomimon_data/genres.lua)
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

--- Progresso (0 a 1) em que a história acaba, pelo sumário (Diario.fimDaHistoria): notas, cronologia,
-- posfácio e propaganda depois dela não contam para terminar o livro. Refeito quando o total de páginas
-- muda (fonte, margens); nil quando o sumário não ajuda (aí vale o 98% do arquivo).
function Yomimon:fimDaHistoria(total)
    if self.fim_historia_total ~= total then
        self.fim_historia_total, self.fim_historia = total, nil
        local toc = self.ui.toc
        if toc and toc.fillToc then toc:fillToc() end
        local itens = {}
        for _, item in ipairs(toc and toc.toc or {}) do
            local pagina = item.fixed_page or item.page  -- fixed_page: item fora de ordem corrigido pelo KOReader
            if type(pagina) == "number" then
                itens[#itens + 1] = { titulo = item.title, pagina = pagina, nivel = item.depth }
            end
        end
        local fim = Diario.fimDaHistoria(itens, total)
        if fim then self.fim_historia = fim / total end
    end
    return self.fim_historia
end

--- Reserva para o fim do livro: você marcou o livro como terminado no KOReader (Diario.statusKOReader).
-- Devolve true quando isso terminou o livro agora.
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
    if not ok then logger.dbg("Yomimon: sem texto da página", p, texto) end
end

-- contar: false quando a página já foi contada e agora só está sendo digerida (sem contar de novo).
function Yomimon:alimentar(letras, palavra, onde, texto, contar)
    if self.falha_teste then error("falha de teste injetada (modo dev: koreader/yomimon/falhar)") end
    if self.estado.dev_simulacao then return end  -- simulação de demo: congelada, leitura real não entra
    local agora = os.time()
    local ocorreu = contar ~= false and Estado.comer(self.estado, letras, palavra, agora, onde) or {}
    pcall(Memoria.digerir, self.estado, texto, onde, agora, contar)
    self.paginas_sem_imagem = self.paginas_sem_imagem + 1
    local aviso
    if ocorreu.evoluiu then
        aviso = ocorreu.evoluiu.aviso or string.format(T"O Yomimon virou %s!", ocorreu.evoluiu.titulo)
    elseif ocorreu.acordou then
        aviso = T"O Yomimon saiu da bola. Com fome, claro."
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

--- Baixa os sprites que faltam da espécie escolhida (só com o Wi-Fi já ligado: nunca pede para ligar).
function Yomimon:garantirSprites()
    if self.ui.document then return end
    local faltam = {}
    for _, f in ipairs(Estado.formas(self.estado)) do
        if f.dex and not Baixar.tem(f.dex) then faltam[#faltam + 1] = f.dex end
    end
    if #faltam > 0 and require("ui/network/manager"):isOnline() then Baixar.linha(faltam) end
    pcall(function() require("yomimon_simpleui").sincronizarCritter(self) end)
end

-- The critter image depends on night mode, so it is rewritten whenever the mode flips.
function Yomimon:onNightModeChanged()
    pcall(function() require("yomimon_simpleui").sincronizarCritter(self) end)
end

-- Modo dev: simulação de endgame ---------------------------------------------------
-- O estado simulado (koreader/yomimon/simulacao.lua, gerado por ferramentas/simular_endgame.lua)
-- entra no lugar do real, que fica guardado em settings/yomimon.lua ("estado_real") até voltar.

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

-- Persistência -------------------------------------------------------------

function Yomimon:salvar(com_imagem)
    self.db:saveSetting("estado", self.estado)
    self.db:flush()
    if com_imagem then self:gerarImagem() end
end

-- escolher = true só quando o Kindle vai dormir (aoDormir): nos outros redesenhos, que ninguém vê, a fala
-- é a última escolhida e nada se gasta (Estado.falaDescanso).
function Yomimon:gerarImagem(forcar, escolher)
    if not forcar and not self:telaDescansoAtiva() then return end
    if lfs.attributes(self.pasta, "mode") ~= "directory" then lfs.mkdir(self.pasta) end
    local ok, err = Desenho.gravar(YomimonScreen.gerarTelaDescanso, self.estado, self.imagem, os.time(), escolher)
    if not ok then logger.warn("Yomimon: falha ao gerar a tela de descanso:", err) end
    self.paginas_sem_imagem = 0
end

--- O Kindle vai dormir (chamado antes de o KOReader mostrar a tela de descanso): escolhe a fala e desenha a imagem.
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
    self:gerarImagem() -- deixa pronta a imagem para a próxima vez que o Kindle dormir
end

function Yomimon:onFlushSettings()
    self:salvar(false)
end

-- Tela de descanso -----------------------------------------------------------

function Yomimon:telaDescansoAtiva()
    return G_reader_settings:readSetting("screensaver_type") == "random_image"
        and G_reader_settings:readSetting("screensaver_dir") == self.pasta
end

--- Liga ou desliga a Yomimon como tela de descanso, guardando a configuração anterior.
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

--- Modo dev: liga ou desliga a falha de teste na leitura (cria ou apaga koreader/yomimon/falhar).
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

-- Todo ponto em que o KOReader chama a Yomimon passa pelo guarda.
Guarda.padrao:envolver(Yomimon, { "onPageUpdate", "onCloseDocument", "onSuspend", "onResume", "onFlushSettings",
    "onMostrarTraca", "aoIniciar", "mostrarBoasVindas", "onReaderReady", "aoDormir", "onCloseWidget" })

return Yomimon
