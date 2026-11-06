--[[--
A vida da Yomimon: fome, humor, evolução e hibernação.

Lógica pura (sem dependências do KOReader), para poder ser testada fora dele.
Todos os tempos são em segundos desde a época (os.time()).
]]

local Lingua = require("yomimon_language")
local Voz = require("yomimon_voice")
local Especies = require("yomimon_species")
local T = Lingua.t

local Estado = {}

Estado.FOME_POR_HORA = 100 / 48     -- barriga cheia esvazia em 2 dias
Estado.HUMOR_POR_HORA = 100 / 72    -- humor cheio some em 3 dias
Estado.LETRAS_POR_PONTO = 300       -- 300 letras = +1 de barriga (uma página ≈ +5)
Estado.HIBERNA_APOS = 3 * 24 * 3600 -- barriga vazia há 3 dias: se esconde na lombada
Estado.CARINHO_INTERVALO = 3600     -- um carinho por hora conta
Estado.REFEICAO_RECENTE = 120       -- fica "feliz" até 2 min depois de comer
Estado.LENDO_AGORA = 30 * 60        -- leu nos últimos 30 min: está lendo (de noite, fica acordada)
Estado.PAUSA_SESSAO = 30 * 60       -- pausa maior que isso começa outra sessão de leitura
Estado.FALAS_RECENTES = 80          -- quantas falas recentes ela evita repetir (80 desde a Etapa 4 da voz: com o
                                    -- sorteio com peso, as poucas falas que combinam com ela voltavam a cada 40)

-- Cada espécie tem uma linha de 1 a 3 formas (yomimon_species.lua); a escolhida fica em s.especie (número da
-- Pokédex da forma inicial). Sem espécie escolhida (ainda nas boas-vindas) ela é uma bola.
-- temperamento: "jovem" (ansiosa, insegura) ou "velha" (carrancuda, sabe demais), nas formas finais.
local MIN_LETRAS = { { 0 }, { 0, 300000 }, { 0, 150000, 600000 } }  -- 150000 letras ~ 100 páginas
-- Os bancos de falas ainda se organizam pelas fases da Yomimon (ninfa, jovem, adulta, anciã): cada forma usa uma.
local FASE_DAS_FALAS = { { "jovem" }, { "ninfa", "adulta" }, { "ninfa", "jovem", "ancia" } }
local formas_por_especie = {}

local function linhaDe(base)
    for _, l in ipairs(Especies.linhas) do
        if l[1] == base then return l end
    end
end

--- Formas da espécie de `s`, da inicial à final: { nome = "p<dex>", dex, titulo, min, temperamento, aviso }.
function Estado.formas(s)
    local base = s and s.especie
    local linha = base and linhaDe(base)
    if not linha then
        return { { nome = "bola", titulo = T"ball", min = 0, temperamento = "jovem", fase_falas = "ninfa" } }
    end
    if formas_por_especie[base] then return formas_por_especie[base] end
    local lista = {}
    for i, dex in ipairs(linha) do
        local nome = Especies.nomes[dex]
        lista[i] = {
            nome = "p" .. dex, dex = dex, titulo = nome, min = MIN_LETRAS[#linha][i], fase_falas = FASE_DAS_FALAS[#linha][i],
            temperamento = (i == #linha and #linha > 1) and "velha" or "jovem",
            aviso = i > 1 and string.format(T"%s evolved into %s!", Especies.nomes[linha[i - 1]], nome) or nil,
        }
    end
    formas_por_especie[base] = lista
    return lista
end

local function limitar(v)
    return math.max(0, math.min(100, v))
end

function Estado.novo(agora)
    return {
        nascimento = agora,
        atualizado = agora,
        barriga = 60,
        humor = 70,
        letras = 0,
        paginas = 0,
        carinho_em = 0,
        hibernando = false,
    }
end

-- Campos que, quando existem, precisam ser tabelas.
local CAMPOS_TABELA = { "temas", "livros", "diario", "colecao", "resenhas", "tracos", "tracos_nivel",
                        "falas_recentes", "dia", "comentario_pendente", "sim_terminados", "sim_sublinhados",
                        "lembrancas", "lembranca_pendente", "vistas", "ritmo", "cartao_pendente", "gravado",
                        "cartoes_ditos", "influencias" }

--- Garante que um estado lido do disco tem todos os campos, com os tipos certos.
-- Campo básico ausente, de tipo errado ou NaN volta ao valor inicial; tabela de tipo errado é descartada;
-- barriga e humor ficam entre 0 e 100.
function Estado.normalizar(s, agora)
    local base = Estado.novo(agora)
    if type(s) ~= "table" then return base end
    for k, v in pairs(base) do
        if type(s[k]) ~= type(v) or s[k] ~= s[k] then s[k] = v end
    end
    for _, k in ipairs(CAMPOS_TABELA) do
        if s[k] ~= nil and type(s[k]) ~= "table" then s[k] = nil end
    end
    s.barriga, s.humor = limitar(s.barriga), limitar(s.humor)
    if s.letras < 0 then s.letras = 0 end
    if s.paginas < 0 then s.paginas = 0 end
    return s
end

--- Aplica a passagem do tempo desde a última atualização.
function Estado.passarTempo(s, agora)
    local dt = agora - s.atualizado
    if dt <= 0 then -- relógio voltou (ou nada passou): não pune
        s.atualizado = math.max(s.atualizado, agora)
        return
    end
    local horas = dt / 3600
    local barriga_antes = s.barriga
    s.barriga = limitar(s.barriga - horas * Estado.FOME_POR_HORA)
    local fator = s.barriga < 20 and 2 or 1 -- com fome, o humor cai mais rápido
    s.humor = limitar(s.humor - horas * Estado.HUMOR_POR_HORA * fator)
    if s.barriga <= 0 then
        if not s.vazio_desde then
            local horas_ate_zerar = barriga_antes / Estado.FOME_POR_HORA
            s.vazio_desde = s.atualizado + math.floor(horas_ate_zerar * 3600)
        end
        if agora - s.vazio_desde >= Estado.HIBERNA_APOS then
            s.hibernando = true
        end
    end
    s.atualizado = agora
end

function Estado.fase(s)
    local formas = Estado.formas(s)
    if s.dev_fase then  -- modo dev: fase forçada só para teste
        for _, f in ipairs(formas) do if f.nome == s.dev_fase then return f end end
    end
    local atual = formas[1]
    for _, f in ipairs(formas) do
        if s.letras >= f.min then atual = f end
    end
    return atual
end

--- Troca (ou escolhe) o Pokémon. O progresso de cada um fica guardado em s.colecao[base] (letras lidas
-- com ele) e volta quando ele é escolhido de novo. A primeira escolha herda as letras já lidas.
function Estado.trocarEspecie(s, base)
    s.colecao = s.colecao or {}
    if s.especie then
        s.colecao[s.especie] = s.letras
        s.letras = s.colecao[base] or 0
    end
    s.colecao[base] = s.letras
    s.especie, s.dev_fase = base, nil
end

--- Os Pokémon já escolhidos: { base, forma, estagio, total, letras, atual }, o de agora primeiro.
function Estado.colecao(s)
    local lista = {}
    for base, letras in pairs(s.colecao or {}) do
        local atual = base == s.especie
        if atual then letras = s.letras end
        local formas = Estado.formas({ especie = base })
        local estagio = 1
        for i, f in ipairs(formas) do if letras >= f.min then estagio = i end end
        lista[#lista + 1] = { base = base, forma = formas[estagio], estagio = estagio, total = #formas,
                              letras = letras, atual = atual }
    end
    table.sort(lista, function(a, b)
        if a.atual ~= b.atual then return a.atual end
        return a.letras > b.letras
    end)
    return lista
end

--- Próxima forma e quantas letras faltam (nil se já é a final).
function Estado.proximaFase(s)
    for _, f in ipairs(Estado.formas(s)) do
        if s.letras < f.min then return f, f.min - s.letras end
    end
end

--- Letras por página deste leitor (média do que ela comeu), ou 1.500 antes de ter base.
function Estado.letrasPorPagina(s)
    local p = s.paginas or 0
    if p < 20 then return 1500 end
    return math.max(500, math.min(4000, (s.letras_vida or s.letras or 0) / p))
end

--- Progresso até a próxima forma.
-- Devolve { fase, proxima (nil na forma final), fracao 0..1, paginas que faltam }.
function Estado.progressoFase(s)
    local fase = Estado.fase(s)
    local prox, faltam = Estado.proximaFase(s)
    if not prox then return { fase = fase, fracao = 1, paginas = 0 } end
    local fracao = math.max(0, math.min(1, (s.letras - fase.min) / math.max(1, prox.min - fase.min)))
    local paginas = faltam > 0 and math.max(1, math.ceil(faltam / Estado.letrasPorPagina(s))) or 0
    return { fase = fase, proxima = prox, fracao = fracao, paginas = paginas }
end

--- Alimenta com letras lidas. Retorna o que aconteceu: {evoluiu = fase, acordou = true}.
-- onde (opcional): { livro = "Título", capitulo = "Cap. VII" } da página comida.
function Estado.comer(s, letras, palavra, agora, onde)
    Estado.passarTempo(s, agora)
    local ocorreu = {}
    if not letras or letras <= 0 then return ocorreu end
    local fase_antes = Estado.fase(s)
    s.letras = s.letras + letras
    s.letras_vida = (s.letras_vida or s.letras - letras) + letras
    s.paginas = s.paginas + 1
    local pontos = letras / Estado.LETRAS_POR_PONTO
    s.barriga = limitar(s.barriga + pontos)
    s.humor = limitar(s.humor + pontos * 0.5)
    s.vazio_desde = nil
    -- sessão: uma pausa longa começa outra
    if not s.ultima_refeicao or agora - s.ultima_refeicao > Estado.PAUSA_SESSAO then
        s.sessao_inicio, s.sessao_paginas = agora, 0
    end
    s.sessao_paginas = (s.sessao_paginas or 0) + 1
    s.ultima_refeicao = agora
    if palavra then s.ultima_palavra = palavra end
    if onde then
        s.ultimo_livro = onde.livro or s.ultimo_livro
        s.ultimo_capitulo = onde.capitulo
        s.ultimo_arquivo = onde.arquivo or s.ultimo_arquivo
        s.ultimo_progresso = onde.progresso
    end
    local dia = os.date("%Y-%m-%d", agora)
    if s.hoje ~= dia then
        -- sequência de dias seguidos lendo (s.hoje ainda é o último dia em que ela comeu)
        local ontem = os.date("%Y-%m-%d", agora - 86400)
        s.sequencia = s.hoje == ontem and (s.sequencia or 1) + 1 or 1
        s.hoje, s.paginas_hoje = dia, 0
        s.dias_lidos = (s.dias_lidos or 0) + 1
    end
    s.paginas_hoje = (s.paginas_hoje or 0) + 1
    if s.paginas_hoje > (s.recorde_dia or 0) and (s.recorde_dia or 0) >= 10 then s.recorde_em = dia end
    s.recorde_dia = math.max(s.recorde_dia or 0, s.paginas_hoje)
    if tonumber(os.date("%H", agora)) < 5 then s.madrugada = true end
    if s.hibernando then
        s.hibernando = false
        ocorreu.acordou = true
    end
    local fase_depois = Estado.fase(s)
    if fase_depois ~= fase_antes then ocorreu.evoluiu = fase_depois end
    return ocorreu
end

function Estado.totais(s)
    return s.paginas or 0, s.dias_lidos or 0
end

-- Marcos (conquistas) ----------------------------------------------------------------
-- Cada marco: { titulo, descricao, atual, meta }. "atual >= meta" = conquistado.
function Estado.marcos(s, extras)
    extras = extras or {}
    local paginas, livros = Estado.totais(s), extras.livros_terminados or 0
    local formas, fase = Estado.formas(s), Estado.fase(s)
    local estagio
    for i, f in ipairs(formas) do if f == fase then estagio = i end end
    local lista = {
        { "FIRST PAGE", "READ THE 1ST PAGE", paginas, 1 },
        { "A HUNDRED PAGES", "100 PAGES READ", paginas, 100 },
        { "A THOUSAND PAGES", "1,000 PAGES READ", paginas, 1000 },
        { "FIVE THOUSAND", "5,000 PAGES READ", paginas, 5000 },
        { "TEN THOUSAND", "10,000 PAGES READ", paginas, 10000 },
        { "EVOLVED", "REACHED THE SECOND FORM", estagio >= 2 and 1 or 0, 1 },
        { "FINAL FORM", "REACHED THE LAST FORM", (#formas > 1 and estagio == #formas) and 1 or 0, 1 },
        { "FIRST BOOK", "FINISHED 1 BOOK", livros, 1 },
        { "BOOKCASE", "FINISHED 5 BOOKS", livros, 5 },
        { "FULL SHELF", "FINISHED 10 BOOKS", livros, 10 },
        { "BIBLIOPHAGE", "FINISHED 25 BOOKS", livros, 25 },
        { "LIBRARY", "FINISHED 50 BOOKS", livros, 50 },
        { "MARATHON", "50 PAGES IN A DAY", s.recorde_dia or 0, 50 },
        { "SMALL HOURS", "READ PAST 2 AM", s.madrugada and 1 or 0, 1 },
        { "OBSESSION", "ONE THEME TOOK OVER", s.tema_dominante and 1 or 0, 1 },
        { "TORN", "TWO OPPOSITE THEMES", extras.ambivalente and 1 or 0, 1 },
        { "COLLECTOR", "50 HIGHLIGHTS", extras.sublinhados or 0, 50 },
    }
    local out = {}
    for _, m in ipairs(lista) do
        out[#out + 1] = { titulo = T(m[1]), descricao = T(m[2]), atual = m[3], meta = m[4], feito = m[3] >= m[4] }
    end
    return out
end

--- Faz carinho. Retorna false se já ganhou carinho na última hora.
function Estado.carinho(s, agora)
    Estado.passarTempo(s, agora)
    if s.hibernando or agora - s.carinho_em < Estado.CARINHO_INTERVALO then
        return false
    end
    s.humor = limitar(s.humor + 15)
    s.carinho_em = agora
    return true
end

--- Você leu nos últimos minutos?
function Estado.lendoAgora(s, agora)
    return s.ultima_refeicao ~= nil and agora - s.ultima_refeicao < Estado.LENDO_AGORA
end

--- "normal", "feliz", "triste" ou "dormindo" ("casulo" quando hibernando).
-- dormir = true força o sono quando ela está bem (usado na tela de descanso).
function Estado.expressao(s, agora, dormir)
    if s.hibernando then return "casulo" end
    if s.barriga < 25 or s.humor < 25 then return "triste" end
    local hora = s.dev_noite and 2 or tonumber(os.date("%H", agora))
    -- de noite ela dorme, a não ser que você esteja lendo agora
    if dormir or ((hora >= 23 or hora < 6) and not Estado.lendoAgora(s, agora)) then return "dormindo" end
    if (s.ultima_refeicao and agora - s.ultima_refeicao < Estado.REFEICAO_RECENTE) or s.humor >= 75 then
        return "feliz"
    end
    return "normal"
end

-- Poses de dormir sorteadas na tela de descanso.
Estado.POSES = { "", "_cobertor", "_estrelas" }

--- Nome do sprite (fase_expressão). pose (opcional, de Estado.POSES) enfeita quem dorme.
-- Quando o desenho daquela variação não existe, o desenho cai para o da fase.
function Estado.sprite(s, agora, dormir, pose)
    local e = Estado.expressao(s, agora, dormir)
    local nome = (e == "casulo" and "bola" or Estado.fase(s).nome) .. "_" .. e
    if e == "dormindo" and pose then nome = nome .. pose end
    return nome
end

--- Quadros da animação: dormindo respira e solta Zzz; acordada só respira,
-- e de vez em quando pisca (quando está normal).
function Estado.quadros(s, agora, dormir)
    local e = Estado.expressao(s, agora, dormir)
    local fase = e == "casulo" and "bola" or Estado.fase(s).nome
    if e == "casulo" or e == "dormindo" then
        local base = fase .. "_" .. e
        return { base .. "_1", base .. "_2", base .. "_3", base .. "_4" }
    end
    local a, b = fase .. "_" .. e .. "_1", fase .. "_" .. e .. "_2"
    if e == "normal" then
        return { a, b, a, b, a, fase .. "_piscar" }
    end
    return { a, b }
end

-- Falas por temperamento e humor. "casulo" = escondida na lombada (hibernando).
-- "repouso" = tela de descanso (o Kindle dormindo).
local Content = Lingua.content("state")
local FALAS, FALAS_LIVRO, FALAS_PERSONAGEM = Content.FALAS, Content.FALAS_LIVRO, Content.FALAS_PERSONAGEM
local FALAS_MUDA_PERTO, FALAS_MUDA_IMINENTE = Content.FALAS_MUDA_PERTO, Content.FALAS_MUDA_IMINENTE

-- Falas sobre o que você está lendo (%s = livro, personagem ou número).

-- Perto de trocar de pele (crescer de fase). %d = páginas que faltam.

-- Lotes novos de frases (locales/<code>/data/extra.lua) somam às listas acima.
Lingua.append({ FALAS = FALAS, FALAS_LIVRO = FALAS_LIVRO, FALAS_PERSONAGEM = FALAS_PERSONAGEM,
    FALAS_MUDA_PERTO = FALAS_MUDA_PERTO, FALAS_MUDA_IMINENTE = FALAS_MUDA_IMINENTE }, Lingua.extra("estado"))

-- s (opcional): a fala que combina com ela pesa mais (yomimon_voice.lua, PLANO-VOZ.md Etapa 4)
local function sorteiaLista(lista, sorteio, s)
    return Voz.escolher(lista, s, sorteio)
end

-- Brechas das falas geradas: livro, palavra, tema e um personagem do livro atual. Com um domínio
-- (yomimon_voice.lua), os núcleos com {gosto}, {cheiro}… também valem (o resolvedor troca as palavras).
local function dadosDaFala(s, sorteio, Memoria)
    local dados = { livro = s.ultimo_livro, palavra = s.ultima_palavra,
                    voz = function(t, sem_dominio) return Voz.resolver(t, s, sorteio, sem_dominio) end,
                    escolher = function(lista, sem_dominio) return Voz.escolher(lista, s, sorteio, sem_dominio) end }
    if Voz.temDominio(s) then
        for slot in pairs(Voz.SLOTS) do dados[slot] = "{" .. slot .. "}" end
    end
    if Memoria then
        -- palavras do próprio livro (Etapa 5): {palavra} e {marcante} sorteiam entre as marcantes do
        -- livro atual; sem elas ainda, {palavra} é a última palavra longa comida e {marcante} fica sem dado
        local marc = s.ultimo_livro and Memoria.marcantes and Memoria.marcantes(s, s.ultimo_livro, 10) or {}
        if #marc > 0 then
            dados.marcante = marc[sorteio(#marc)]
            dados.palavra = dados.marcante
        end
        if s.tema_dominante then dados.tema = Memoria.NOMES_TEMA[s.tema_dominante] end
        local nomes = s.ultimo_livro and Memoria.personagens(s, s.ultimo_livro, 5) or {}
        if #nomes > 0 then dados.personagem = nomes[sorteio(#nomes)] end
    end
    return dados
end

local function chaveCurta(t)
    local h = 0
    for i = 1, #t do h = (h * 31 + t:byte(i)) % 2147483647 end
    return h
end

--- Sorteia uma fala. Devolve a fala e a chave para evitar repetição (o núcleo, nas geradas).
local function sortearFala(s, agora, sorteio, dormir, tela)
    local e = Estado.expressao(s, agora, dormir)
    local temp = Estado.fase(s).temperamento
    local grupo = FALAS[temp]
    -- tela de descanso: só sonho, mesmo com fome, triste, perto da muda ou escondida na lombada (fala de quem
    -- está acordada quebra a cena); o ovo não sonha: só os barulhos de dentro da casca (as falas entre
    -- parênteses; "Toc, toc. Lê mais um pouco" fica para quando você está lendo)
    if dormir then
        if grupo._todas then
            local rachando = Estado.proximaFase(s) and Estado.progressoFase(s).paginas <= 10
            local quietas = {}
            for _, f in ipairs(rachando and FALAS_MUDA_IMINENTE.ovo or grupo._todas) do
                if f:sub(1, 1) == "(" or f == "…" then quietas[#quietas + 1] = f end
            end
            return sorteiaLista(quietas, sorteio)
        end
        local okF, Falas = pcall(require, "yomimon_speech")
        local okM, Memoria = pcall(require, "yomimon_memory")
        local dados = dadosDaFala(s, sorteio, okM and Memoria)
        if okF and sorteio(2) ~= 2 then
            local f, chave = Falas.sonhar(temp, dados, sorteio)
            if f then return f, chave end
        end
        return sorteiaLista(grupo.repouso, sorteio, s)
    end
    -- um cartão da caixa (yomimon_cards.lua): na Home; na tela da Yomimon, se não coube na Home. Vem antes de
    -- qualquer sorteio, para que tentar um cartão que não cabe na Home não mude as falas seguintes.
    if e ~= "dormindo" and e ~= "casulo" and not grupo._todas then
        local okCar, Cartoes = pcall(require, "yomimon_cards")
        local car = okCar and Cartoes.pendente(s, agora, tela)
        if car then
            car.usado = true
            return car.texto
        end
    end
    -- muda chegando: quantas páginas faltam para a próxima fase (a mesma conta do cartão de fase)
    local prox = Estado.proximaFase(s)
    if prox and e ~= "casulo" then
        local paginas = Estado.progressoFase(s).paginas
        if paginas <= 10 then
            return sorteiaLista(FALAS_MUDA_IMINENTE[temp], sorteio)
        elseif paginas <= 60 and temp ~= "ovo" and sorteio(4) == 1 then
            return (sorteiaLista(FALAS_MUDA_PERTO[temp], sorteio):gsub("%%d", tostring(paginas)))
        end
    end
    if grupo._todas then
        return sorteiaLista(grupo._todas, sorteio)
    end
    if e == "casulo" then return sorteiaLista(grupo.casulo, sorteio) end

    local okF, Falas = pcall(require, "yomimon_speech")
    local okM, Memoria = pcall(require, "yomimon_memory")
    local dados = dadosDaFala(s, sorteio, okM and Memoria)
    -- dormindo de noite: quase sempre um sonho gerado (com o livro, o tema e os personagens dela)
    if e == "dormindo" then
        if okF and sorteio(4) ~= 4 then
            local f, chave = Falas.sonhar(temp, dados, sorteio)
            if f then return f, chave end
        end
        return sorteiaLista(grupo.dormindo, sorteio, s)
    end
    -- uma lembrança nova (autor que volta, aniversário, nada tão sombrio desde…): a primeira fala, uma vez,
    -- por até 24h
    local lem = s.lembranca_pendente
    if lem and not lem.usado and agora - (lem.t or 0) < 24 * 3600 then
        lem.usado = true
        return lem.texto
    end
    -- acabou um capítulo: a primeira fala depois disso é sobre ele (uma vez só, por até 12h)
    local p = s.comentario_pendente
    if p and not p.usado and agora - (p.t or 0) < 12 * 3600 then
        p.usado = true
        return p.texto  -- se ela disse isso há pouco, a regra de não repetir escolhe outra
    end
    -- dados da sua leitura: hora, páginas de hoje, recorde, sequência, sessão, parte do livro. Os fortes
    -- (madrugada, recorde, maratona, dias sumido) vêm antes das influências; os outros, depois.
    local okC, Contexto = pcall(require, "yomimon_context")
    local fc, forte
    if okC then fc, forte = Contexto.fala(s, agora, temp, sorteio) end
    if fc and forte and sorteio(10) <= 6 then return fc end
    -- influências literárias e personalidade-base (yomimon_influences.lua), o repertório principal: a mais
    -- forte escolhe a frase, a segunda pode entrar na mesma fala; sem influência, a personalidade-base
    local okI, Influencias = pcall(require, "yomimon_influences")
    if okI then
        local hora = tonumber(os.date("%H", agora))
        local situ = { triste = e == "triste", feliz = e == "feliz", fome = s.barriga < 40, cheia = s.barriga >= 85,
                       noite = hora >= 22 or hora < 5,
                       muda = (prox and Estado.progressoFase(s).paginas <= 60) and true or false,
                       fase = Estado.fase(s).fase_falas, tela = tela }
        -- frases ditas há pouco ficam de fora; se não sobrar nenhuma, a vez passa para o resto
        local recentes = {}
        for _, h in ipairs(s.falas_recentes or {}) do recentes[h] = true end
        local function dita(chave) return recentes[chaveCurta(chave)] == true end
        local f, chave = Influencias.fala(s, dados, sorteio, situ, dita)
        if f then return f, chave end
    end
    if fc and not forte and sorteio(10) <= 3 then return fc end
    -- o jeito que ela ficou com as suas leituras (amarga, medrosa, romântica, noturna…)
    local okT, Tracos = pcall(require, "yomimon_traits")
    if okT then
        local f = Tracos.fala(s, temp, sorteio)
        if f then return f end
    end
    -- às vezes ela fala do que você leu ou do que os livros fizeram com ela
    local sorte = sorteio(10)
    if sorte == 1 then
        local f = okM and Memoria.fala(s, sorteio, temp)
        if f then return f end
    elseif sorte == 2 and s.ultimo_livro then
        return string.format(sorteiaLista(FALAS_LIVRO[temp], sorteio, s), s.ultimo_livro)
    elseif sorte == 3 and dados.personagem then
        return string.format(sorteiaLista(FALAS_PERSONAGEM[temp], sorteio, s), dados.personagem)
    elseif sorte == 4 and dados.palavra then
        return string.format(grupo.palavra, dados.palavra)
    end
    -- de mau humor, às vezes ela culpa algo que aconteceu no livro (causa inventada depois)
    if e == "triste" and s.humor < 25 and sorteio(3) == 1 then
        local f = Voz.causa(s, temp, sorteio)
        if f then return f end
    end
    -- na maioria das vezes, uma fala gerada para a fase
    if (e == "normal" or e == "feliz") and okF and sorteio(3) ~= 1 then
        local f, chave = Falas.gerar(Estado.fase(s).fase_falas, dados, sorteio)
        if f then return f, chave end
    end
    return sorteiaLista(grupo[e], sorteio, s)
end


--- Uma frase para o estado atual. sorteio(n) deve devolver um inteiro de 1 a n.
-- dormir = true é a tela de descanso (usa as falas de repouso e os sonhos).
-- Evita repetir as últimas falas (guarda só um número por fala, em s.falas_recentes; a chave é a frase
-- antes de escolher a variante de traço, então as variantes de uma mesma frase contam como uma só).
-- tela: "home" (só por Estado.falaQueCabe), "traca" ou nil; decide se um cartão da caixa pode sair.
function Estado.fala(s, agora, sorteio, dormir, tela)
    sorteio = sorteio or math.random
    local recentes = s.falas_recentes or {}
    local usadas = {}
    for _, h in ipairs(recentes) do usadas[h] = true end
    local car = s.cartao_pendente
    local car_usado = car and car.usado
    local texto, chave
    for _ = 1, 8 do
        texto, chave = sortearFala(s, agora, sorteio, dormir, tela)
        if not usadas[chaveCurta(chave or texto)] then break end
    end
    recentes[#recentes + 1] = chaveCurta(chave or texto)
    while #recentes > Estado.FALAS_RECENTES do table.remove(recentes, 1) end
    s.falas_recentes = recentes
    local final = (Voz.resolver(texto, s, sorteio))
    -- o cartão saiu nesta fala: na tela da Yomimon, está dito; na Home, quem decide é falaQueCabe (se coube)
    if car and car.usado and not car_usado then
        if final ~= car.texto then
            car.usado = car_usado  -- a regra de não repetir escolheu outra
        elseif tela ~= "home" then
            local okCar, Cartoes = pcall(require, "yomimon_cards")
            if okCar then Cartoes.dito(s, car, agora) end
        end
    end
    return final
end

--- A fala da tela de descanso. Só é escolhida quando o Kindle vai dormir (escolher = true): aí entra nas
-- recentes e pode usar a lembrança ou o comentário de capítulo. Os redesenhos que ninguém vê (a cada 10
-- páginas, ao acordar, ao fechar o livro) repetem a última escolhida, sem gastar nada; se ainda não houve
-- nenhuma, sorteiam uma e devolvem o estado como estava.
function Estado.falaDescanso(s, agora, escolher, sorteio)
    if escolher then
        s.fala_descanso = Estado.fala(s, agora, sorteio, true)
        return s.fala_descanso
    end
    if type(s.fala_descanso) == "string" then return s.fala_descanso end
    local recentes = {}
    for i, v in ipairs(s.falas_recentes or {}) do recentes[i] = v end
    local lem, com = s.lembranca_pendente, s.comentario_pendente
    local lem_usado, com_usado = lem and lem.usado, com and com.usado
    local texto = Estado.fala(s, agora, sorteio, true)
    s.falas_recentes = recentes
    if lem then lem.usado = lem_usado end
    if com then com.usado = com_usado end
    return texto
end

--- Uma fala que caiba num espaço pequeno (o cartão da Home): linhas(texto) diz quantas linhas ela ocupa.
-- Sorteia de novo (até `tentativas`) quando passa de `max_linhas`, sem efeito colateral das tentativas:
-- só a fala escolhida entra nas recentes, e lembrança ou comentário de capítulo que não couber continua
-- guardado para a tela principal (onde há espaço). Devolve o texto e quantas linhas ele ocupa; se nada
-- couber, a mais curta das tentativas. É a fala da Home: o cartão da caixa sai aqui primeiro; se não
-- couber, fica marcado (nao_coube) e espera a tela da Yomimon.
function Estado.falaQueCabe(s, agora, linhas, max_linhas, tentativas, sorteio)
    local function copia(t) local o = {} for i, v in ipairs(t or {}) do o[i] = v end return o end
    local lem, com, car = s.lembranca_pendente, s.comentario_pendente, s.cartao_pendente
    local orig = { recentes = copia(s.falas_recentes), lem = lem and lem.usado, com = com and com.usado,
                   car = car and car.usado }
    local escolhido, n_esc, melhor, n_melhor
    for _ = 1, tentativas or 8 do
        s.falas_recentes = copia(orig.recentes)
        local texto = Estado.fala(s, agora, sorteio, nil, "home")
        if texto then
            local n = linhas(texto)
            if n <= (max_linhas or 2) then escolhido, n_esc = texto, n; break end
            if not melhor or n < n_melhor then melhor, n_melhor = texto, n end
        end
    end
    -- lembrança/comentário que apareceu numa tentativa e não coube: continua guardado
    if lem and lem.texto ~= escolhido then lem.usado = orig.lem end
    if com and com.texto ~= escolhido then com.usado = orig.com end
    if car and not orig.car then
        if car.texto == (escolhido or melhor) then
            local okCar, Cartoes = pcall(require, "yomimon_cards")
            if okCar then Cartoes.dito(s, car, agora) end
        else
            if car.usado then car.nao_coube = true end  -- apareceu numa tentativa e não coube
            car.usado = orig.car
        end
    end
    if not escolhido then
        s.falas_recentes = orig.recentes
        return melhor, n_melhor
    end
    return escolhido, n_esc
end

--- Páginas comidas hoje (zera à meia-noite).
function Estado.paginasHoje(s, agora)
    if s.hoje ~= os.date("%Y-%m-%d", agora) then return 0 end
    return s.paginas_hoje or 0
end

--- Quantas das 4 bolinhas estão cheias para um valor de 0 a 100.
function Estado.bolinhas(valor)
    return math.max(0, math.min(4, math.ceil((valor or 0) / 25 - 1e-9)))
end

local ROTULO_BARRIGA = { { 75, "FULL" }, { 50, "SATED" }, { 25, "PECKISH" }, { 0.5, "HUNGRY" }, { -1, "STARVING" } }
local ROTULO_HUMOR = {
    jovem = { { 75, "PERKY" }, { 50, "CALM" }, { 25, "ANXIOUS" }, { -1, "TERRIFIED" } },
    velha = { { 75, "ALMOST CONTENT" }, { 50, "RESIGNED" }, { 25, "GRUMPY" }, { -1, "UNBEARABLE" } },
}

local function rotulo(tabela, valor)
    for _, r in ipairs(tabela) do
        if valor >= r[1] then return T(r[2]) end
    end
    return T(tabela[#tabela][2])
end

function Estado.rotuloBarriga(s)
    return rotulo(ROTULO_BARRIGA, s.barriga)
end

function Estado.rotuloHumor(s)
    return rotulo(ROTULO_HUMOR[Estado.fase(s).temperamento], s.humor)
end

--- Conta letras num texto UTF-8 (letras ASCII + um por caractere acentuado).
function Estado.contarLetras(texto)
    if type(texto) ~= "string" then return 0 end
    local _, ascii = texto:gsub("%a", "")
    local _, multibyte = texto:gsub("[\194-\244]", "")
    return ascii + multibyte
end

--- A palavra mais comprida (até 20 bytes) do texto, ou nil.
function Estado.palavraMaisLonga(texto)
    if type(texto) ~= "string" then return nil end
    -- travessões, aspas curvas, reticências e « » não fazem parte de palavras
    texto = texto:gsub("\226\128[\128-\191]", " "):gsub("\194[\160-\191]", " ")
    local melhor
    for p in texto:gmatch("[%a\128-\255]+") do
        if #p <= 20 and (not melhor or #p > #melhor) then melhor = p end
    end
    if melhor and #melhor >= 6 then return melhor:lower() end
end

return Estado
