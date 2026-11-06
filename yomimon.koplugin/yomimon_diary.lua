--[[--
Diário da Yomimon: o que ela escreve sobre a sua leitura, com coisas concretas.

- Uma entrada por dia de leitura, montada com os dados daquele dia: quantas páginas, de qual
  livro, a que horas, quem ela conheceu, uma fala de personagem, o evento e o assunto do dia.
- Ao começar um livro: abertura variada (autor, mesmo autor de antes, livro largado, releitura).
- Ao terminar um livro: resenha curta (protagonista, comparação com outros livros, série de
  temas, o traço que o livro mexeu, nota) — e a resenha completa vai para s.resenhas.

As frases ficam em yomimon_locales/<code>/data/diary.lua. Lógica pura, testável fora do KOReader.
]]

local Lingua = require("yomimon_language")

local Diario = {}

local RESENHAS_MAX = 120
local FIM_DO_LIVRO = 0.98     -- livro sem sumário que ajude: progresso a partir do qual conta como terminado
local HISTORIA_MIN = 0.5      -- anexos que começariam antes da metade do arquivo: o sumário não é confiável
local ENTRADA_MAX = 200       -- entradas maiores perdem partes opcionais

-- Títulos de anexo (o que vem depois da história), em palavras inteiras: notas, cronologia, posfácio,
-- sobre o autor, créditos, propaganda da editora…
local ANEXOS = {}
for p in ([[nota notas posfácio posfacio cronologia créditos creditos colofon colofão autor autora autores
    bibliografia referências glossário índice apêndice apêndices anexo anexos agradecimentos copyright
    note notes endnotes footnotes afterword author credits colophon acknowledgments acknowledgements
    appendix appendices glossary index bibliography references license gutenberg transcriber]]):gmatch("%S+") do
    ANEXOS[" " .. p .. " "] = true
end
for _, p in ipairs({ "saiba mais", "outras leituras", "leia também", "leia mais", "outros títulos",
    "further reading", "also by", "reading group", "praise for" }) do
    ANEXOS[" " .. p .. " "] = true
end

local function ehAnexo(titulo)
    -- minúsculas (também À…Þ), sem números nem pontuação: "XLV. Notas" → " xlv notas "
    local t = " " .. tostring(titulo or ""):lower():gsub("\195([\128-\158])", function(c) return "\195" .. string.char(c:byte() + 32) end)
        :gsub("[^%a\128-\255]+", " ") .. " "
    for chave in pairs(ANEXOS) do
        if t:find(chave, 1, true) then return true end
    end
    return false
end

--- Última página da história, pelo sumário. De trás para frente, pula os títulos de anexo; a história acaba
-- logo antes do primeiro deles. De trás para frente porque um capítulo da história pode se chamar "Notas"
-- (Brás Cubas, XLV). Só o nível de cima do sumário conta: as notas podem ter subtítulos ("Capítulo 1"…).
-- toc: { { titulo =, pagina =, nivel = }, … } na ordem do livro; total: páginas do arquivo.
-- Devolve nil quando o sumário não ajuda (vazio, só anexos, ou anexos antes da metade do arquivo).
function Diario.fimDaHistoria(toc, total)
    if type(toc) ~= "table" or not total or total < 1 then return nil end
    local nivel
    for _, it in ipairs(toc) do nivel = math.min(nivel or math.huge, it.nivel or 1) end
    local topo = {}
    for _, it in ipairs(toc) do
        if (it.nivel or 1) == nivel and type(it.pagina) == "number" then topo[#topo + 1] = it end
    end
    local i = #topo
    while i >= 1 and ehAnexo(topo[i].titulo) do i = i - 1 end
    if i < 1 then return nil end
    if i == #topo then return total end
    local fim = math.max(topo[i].pagina, topo[i + 1].pagina - 1)
    if fim < total * HISTORIA_MIN then return nil end
    return fim
end

local banco
function Diario.banco()
    banco = banco or Lingua.data("diary")
    return banco
end

local function sorteia(lista, sorteio)
    if not lista or #lista == 0 then return nil end
    return lista[(sorteio or math.random)(#lista)]
end

local function preencher(modelo, v)
    local texto = modelo:gsub("{([%w_]+)}", function(k) return v[k] or ("{" .. k .. "}") end)
    -- pontuação de citação: “Quem?”, disse → “Quem?” disse ; “Fim.”, disse → “Fim,” disse
    texto = texto:gsub("([%?!])\226\128\157,", "%1\226\128\157"):gsub("%.\226\128\157,", ",\226\128\157")
    return texto
end

local function temperamento(s)
    local ok, Estado = pcall(require, "yomimon_state")
    local t = ok and Estado.fase(s).temperamento or "velha"
    return t == "jovem" and "jovem" or "velha"
end

local function maiorDe(t)
    local melhor, valor = nil, 0
    for k, v in pairs(t or {}) do if v > valor then melhor, valor = k, v end end
    return melhor, valor
end

-- Dia de leitura ---------------------------------------------------------------------

--- Fecha o dia anterior (se o dia mudou) e escreve a entrada dele. Chamar antes de contar a página.
function Diario.virarDia(s, M, agora)
    local hoje = os.date("%Y-%m-%d", agora)
    if s.dia and s.dia.data ~= hoje then
        local texto = Diario.entradaDoDia(s, M, s.dia)
        if texto then M.anotar(s, s.dia.ultimo or agora, texto) end
        s.dia = nil
    end
    s.dia = s.dia or { data = hoje, paginas = 0, livros = {}, ordem = {}, horas = { madrugada = 0, manha = 0, noite = 0 },
                       temas = {}, clima = 0, eventos = {} }
end

--- Conta uma página no dia de hoje.
-- contar: false quando a página já foi contada antes e agora só é digerida.
function Diario.pagina(s, livro, sinal, falas, agora, contar)
    local D = s.dia
    if not D then return end
    D.ultimo = agora
    if contar ~= false then
        D.paginas = D.paginas + 1
        if livro then
            if not D.livros[livro] then D.ordem[#D.ordem + 1] = livro end
            D.livros[livro] = (D.livros[livro] or 0) + 1
        end
        local h = tonumber(os.date("%H", agora))
        if h < 5 then D.horas.madrugada = D.horas.madrugada + 1
        elseif h < 11 then D.horas.manha = D.horas.manha + 1
        elseif h >= 22 then D.horas.noite = D.horas.noite + 1 end
    end
    for t, c in pairs(sinal.temas_pesados or sinal.temas or {}) do D.temas[t] = (D.temas[t] or 0) + c end
    for ev, c in pairs(sinal.eventos or {}) do D.eventos[ev] = (D.eventos[ev] or 0) + c end
    D.clima = D.clima + (sinal.clima or 0)
    if falas and #falas > 0 and (not D.fala or math.random(3) == 1) then
        local f = falas[math.random(#falas)]
        D.fala = { nome = f.nome, fala = f.fala, livro = livro }
    end
end

--- Personagens que ela "conheceu" hoje (viraram personagem e ainda não tinham sido anotados).
local function conhecidosHoje(s, M, D)
    local novos = {}
    for _, livro in ipairs(D.ordem) do
        local L = s.livros and s.livros[livro]
        if L then
            L.anunciados = L.anunciados or {}
            for i, p in ipairs(M.personagensInfo(s, livro)) do
                if i > 6 then break end
                if not L.anunciados[p.nome] then
                    L.anunciados[p.nome] = true
                    novos[#novos + 1] = p.nome
                end
            end
        end
    end
    return novos
end

--- Monta a entrada de um dia de leitura (ou nil, se não houve leitura).
function Diario.entradaDoDia(s, M, D)
    if not D or D.paginas == 0 or #D.ordem == 0 then return nil end
    local B, temp = Diario.banco().dia, temperamento(s)
    local livro = D.ordem[1]
    local maior = 0
    for _, l in ipairs(D.ordem) do if D.livros[l] > maior then livro, maior = l, D.livros[l] end end
    local v = { n = tostring(D.paginas), livro = livro }
    -- abertura: quanto ela comeu
    local abertura
    if #D.ordem >= 2 then
        v.livro2 = D.ordem[1] == livro and D.ordem[2] or D.ordem[1]
        abertura = sorteia(B.dois_livros)
    elseif D.paginas <= 5 then abertura = sorteia(B.magro)
    elseif D.paginas < 30 then abertura = sorteia(B.normal)
    elseif D.paginas < 80 then abertura = sorteia(B.banquete)
    else abertura = sorteia(B.enorme) end
    local partes = { preencher(abertura, v) }
    -- horário, quando um período dominou o dia
    local periodo, qtd = maiorDe(D.horas)
    local horario = periodo and qtd >= D.paginas * 0.6 and sorteia(B.horario[periodo])
    -- detalhes do dia, em ordem de interesse
    -- detalhes do dia, cada um com um peso (os mais concretos pesam mais)
    local detalhes = {}
    local function detalhe(texto, peso) if texto then detalhes[#detalhes + 1] = { texto = texto, peso = peso } end end
    local novos = conhecidosHoje(s, M, D)
    if #novos >= 2 then
        detalhe(preencher(sorteia(B.novos2), { nome = novos[1], nome2 = novos[2] }), 4)
    elseif #novos == 1 then
        detalhe(preencher(sorteia(B.novo), { nome = novos[1] }), 4)
    end
    -- fala de personagem: não repete quem falou no último dia anotado
    if D.fala and #D.fala.fala <= 90 and D.fala.nome ~= s.diario_ultima_fala then
        detalhe(preencher(sorteia(B.fala[temp]), { nome = D.fala.nome, fala = D.fala.fala }), 3)
    end
    local ev, n_ev = maiorDe(D.eventos)
    if ev and n_ev >= 4 and B.evento[ev] then detalhe(sorteia(B.evento[ev]), 3) end
    local tema, n_tema = maiorDe(D.temas)
    if tema and n_tema >= 5 and M.tema then
        detalhe(preencher(sorteia(B.tema), { tema = M.tema(tema), de_tema = M.tema(tema, "de") }), 1)
    end
    local clima = D.clima / D.paginas
    if clima <= -1 then detalhe(sorteia(B.pesado), 2)
    elseif clima >= 1 then detalhe(sorteia(B.leve), 2) end
    -- até 2 detalhes, sorteados pelo peso
    for _ = 1, 2 do
        local soma = 0
        for _, d in ipairs(detalhes) do soma = soma + d.peso end
        if soma == 0 then break end
        local alvo, acc = math.random() * soma, 0
        for i, d in ipairs(detalhes) do
            acc = acc + d.peso
            if alvo <= acc then
                partes[#partes + 1] = d.texto
                if D.fala and d.texto:find(D.fala.fala, 1, true) then s.diario_ultima_fala = D.fala.nome end
                table.remove(detalhes, i)
                break
            end
        end
    end
    -- fecho: no tom dela, puxado pelo clima do dia
    local fecho = sorteia((clima <= -1 and B.fecho_escuro or clima >= 1 and B.fecho_leve or B.fecho)[temp])
    local function montar(com_horario, n_partes)
        local p = { partes[1] }
        if com_horario and horario then p[#p + 1] = horario end
        for i = 2, n_partes do p[#p + 1] = partes[i] end
        if fecho and fecho ~= "" then p[#p + 1] = fecho end
        return table.concat(p, " ")
    end
    local texto = montar(true, #partes)
    if #texto > ENTRADA_MAX then texto = montar(false, #partes) end
    if #texto > ENTRADA_MAX then texto = montar(false, math.min(2, #partes)) end
    return texto
end

-- Começo e fim de livro --------------------------------------------------------------

--- Entrada de livro novo. anterior: o livro que ela vinha comendo antes (ou nil).
function Diario.inicioLivro(s, M, livro, onde, anterior)
    local B = Diario.banco().inicio
    local v = { livro = livro, autor = onde and onde.autor, anterior = anterior }
    local Lant = anterior and s.livros and s.livros[anterior]
    local opcoes = {}
    if Lant and not Lant.terminado and (Lant.progresso or 0) < 0.5 and (Lant.paginas or 0) >= 5 then
        opcoes = B.largou
    elseif v.autor then
        local mesmo = false
        for titulo, L in pairs(s.livros or {}) do
            if titulo ~= livro and L.autor == v.autor then mesmo = true end
        end
        opcoes = mesmo and B.mesmo_autor or (math.random(2) == 1 and B.autor or B.generico)
    end
    if #opcoes == 0 then opcoes = B.generico end
    return preencher(sorteia(opcoes), v)
end

--- Entrada de releitura.
function Diario.releitura(livro)
    return preencher(sorteia(Diario.banco().inicio.relendo), { livro = livro })
end

-- Traço que mais mudou durante o livro (ou nil, se nenhum mudou o bastante).
local function tracoDoLivro(s, L)
    local ok, Tracos = pcall(require, "yomimon_traits")
    if not ok then return nil end
    local melhor, delta = nil, 8
    for _, tr in ipairs(Tracos.LISTA) do
        local d = ((s.tracos or {})[tr.id] or 0) - ((L.tracos_inicio or {})[tr.id] or 0)
        if math.abs(d) >= delta and tr.id ~= "relogio" then melhor, delta = d > 0 and tr.pos or tr.neg, math.abs(d) end
    end
    return melhor
end

--- Fecha um livro terminado: escreve a resenha curta no diário e guarda a completa em s.resenhas.
function Diario.fimLivro(s, M, livro, agora)
    local L = s.livros and s.livros[livro]
    if not L then return end
    local B, temp = Diario.banco().fim, temperamento(s)
    local info = M.personagensInfo(s, livro)
    local protagonista
    for _, p in ipairs(info) do if p.protagonista then protagonista = p.nome; break end end
    protagonista = protagonista or (info[1] and info[1].nome)
    local personagens = {}
    for i = 1, math.min(3, #info) do personagens[i] = info[i].nome end
    local tema = maiorDe(L.temas)
    local clima = (L.clima or 0) / math.max(1, L.paginas)
    local dias = L.dias or 1
    -- nota: metade pelo ritmo com que você leu, metade pela intensidade do livro (eventos e clima)
    local ppd = L.paginas / math.max(1, dias)
    local ritmo = ppd < 10 and 1 or ppd < 20 and 2 or ppd < 30 and 3 or ppd < 45 and 4 or 5
    local n_eventos = 0
    for _, c in pairs(L.eventos or {}) do n_eventos = n_eventos + c end
    local intensidade = n_eventos / math.max(1, L.paginas) * 2 + math.abs(clima)
    local forca = intensidade < 0.3 and 1 or intensidade < 0.6 and 2 or intensidade < 1 and 3 or intensidade < 1.5 and 4 or 5
    local nota = math.max(1, math.min(5, math.floor((ritmo + forca) / 2 + 0.5)))
    local traco = tracoDoLivro(s, L)
    local citacao = M.citacao(s, livro, function() return 1 end, 100)

    -- comparações com as resenhas anteriores
    s.resenhas = s.resenhas or {}
    local anterior = s.resenhas[#s.resenhas]
    local serie = 0
    for i = #s.resenhas, 1, -1 do
        if s.resenhas[i].tema == tema and s.resenhas[i].livro ~= livro then serie = serie + 1 else break end
    end

    -- o nome composto do livro (vetor do livro, yomimon_vector.lua): "uma história de mar, agitada"
    local okV, Vetor = pcall(require, "yomimon_vector")
    local nome = okV and Vetor.nome(Vetor.de(L)) or nil

    local partes = { preencher(sorteia(B.abertura), { livro = livro }) }
    if nome and B.nome then partes[#partes + 1] = preencher(sorteia(B.nome), { nome = nome }) end
    local opcionais = {}
    if protagonista then opcionais[#opcionais + 1] = preencher(sorteia(B.protagonista[temp]), { nome = protagonista }) end
    if anterior and anterior.livro ~= livro and math.abs(clima - (anterior.clima or 0)) >= 0.4 then
        opcionais[#opcionais + 1] = preencher(sorteia(clima < (anterior.clima or 0) and B.mais_escuro or B.mais_leve),
            { outro = anterior.livro })
    end
    if tema and serie == 1 then  -- 3º seguido em diante vira lembrança garantida (yomimon_memories)
        local ordinal = Lingua.format().ordinals[math.min(serie, 5)]
        opcionais[#opcionais + 1] = preencher(sorteia(B.serie), { ordinal = ordinal, tema = M.tema(tema), de_tema = M.tema(tema, "de") })
    end
    if traco and B.traco[traco] then opcionais[#opcionais + 1] = sorteia(B.traco[traco]) end
    for i = 1, math.min(2, #opcionais) do
        local k = math.random(#opcionais)
        partes[#partes + 1] = table.remove(opcionais, k)
    end
    partes[#partes + 1] = preencher(sorteia(B.nota[temp]), { n = tostring(nota) })
    M.anotar(s, agora, table.concat(partes, " "))

    local veredito = sorteia(B.veredito[temp][nota])
    s.resenhas[#s.resenhas + 1] = {
        livro = livro, autor = L.autor, geracao = s.geracao or 1, inicio = L.inicio, fim = agora, dias = dias,
        paginas = L.paginas, personagens = personagens, protagonista = protagonista, citacao = citacao,
        tema = tema, clima = clima, traco = traco, nota = nota, veredito = veredito, releitura = L.relendo or nil,
        nome = nome,
    }
    while #s.resenhas > RESENHAS_MAX do table.remove(s.resenhas, 1) end
    -- palavras do livro (Etapa 5): terminado, guarda só as mais contadas
    if M.podarVocab then M.podarVocab(L, M.VOCAB_FIM) end
    local okLem, Lem = pcall(require, "yomimon_memories")
    if okLem then
        -- nível C, guardado e mudo: gênero provável e aura do protagonista
        local r = s.resenhas[#s.resenhas]
        r.genero = Lem.genero(L.temas)
        r.aura = protagonista and L.aura and L.aura[protagonista] and Lem.aura(L.aura[protagonista]) or nil
        Lem.fimLivro(s, M, livro, agora, serie)
    end
    -- nomes: fica só a lista final de personagens e lugares; as evidências saem do estado salvo
    if M.congelarNomes then M.congelarNomes(L, livro) end
end

--- Chamado a cada página com o livro já registrado: dias de leitura, progresso, fim e releitura.
function Diario.acompanharLivro(s, M, L, livro, onde, agora)
    local hoje = os.date("%Y-%m-%d", agora)
    if L.ultimo_dia ~= hoje then L.ultimo_dia, L.dias = hoje, (L.dias or 0) + 1 end
    local p = onde and onde.progresso
    if not p then return end
    if L.terminado and p < 0.1 and not L.relendo_agora then
        -- recomeçou um livro já terminado: releitura
        L.terminado, L.relendo, L.relendo_agora = false, true, true
        L.tracos_inicio = {}
        for k, v in pairs(s.tracos or {}) do L.tracos_inicio[k] = v end
        M.anotar(s, agora, Diario.releitura(livro))
    end
    L.progresso = p
    -- fim: a última página da história (onde.fim_historia, pelo sumário, em main.lua); sem ela, 98% do arquivo
    if p >= (onde.fim_historia or FIM_DO_LIVRO) and not L.terminado then
        L.terminado, L.relendo_agora = true, nil
        Diario.fimLivro(s, M, livro, agora)
    end
end

--- O status do livro no KOReader ("reading", "complete", "abandoned"…), olhado ao abrir, ao fechar e quando
-- o Kindle dorme. Virou "complete" (você marcou como terminado) enquanto ela acompanhava: terminado aqui
-- também, com resenha. Livro que ela vê pela primeira vez já terminado lá (lido antes dela) não conta; na
-- releitura o status continua "complete" e o fim vem pelo sumário. Devolve true quando terminou o livro.
function Diario.statusKOReader(s, M, livro, status, agora)
    local L = livro and s.livros and s.livros[livro]
    if not L then return end
    status = type(status) == "string" and status or "nenhum"
    local antes = L.status_koreader
    L.status_koreader = status
    if status == "complete" and antes and antes ~= "complete" and not L.terminado then
        L.terminado, L.relendo_agora = true, nil
        Diario.fimLivro(s, M, livro, agora)
        return true
    end
end

--- Mudança de obsessão (tema dominante), com frases variadas.
function Diario.obsessao(M, antigo, novo)
    local B = Diario.banco().obsessao
    local texto
    if antigo then
        texto = preencher(sorteia(B.troca), { antes = M.tema(antigo, "em"), agora = M.tema(novo, "em"),
            antes_s = M.tema(antigo), agora_s = M.tema(novo) })
    else
        texto = preencher(sorteia(B.nova), { tema = M.tema(novo, "em"), tema_s = M.tema(novo) })
    end
    return (texto:gsub("^%l", string.upper))
end

return Diario
