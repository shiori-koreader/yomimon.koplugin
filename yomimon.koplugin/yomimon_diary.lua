--[[--
Yomimon's diary: what it writes about your reading, with concrete things.

- One entry per reading day, built from that day's data: how many pages, of which
  book, at what time, who it met, a character's line, the event and the subject of the day.
- When starting a book: a varied opening (author, same author as before, abandoned book, re-read).
- When finishing a book: a short review (protagonist, comparison with other books, series of
  themes, the trait the book moved, grade) — and the full review goes to s.resenhas.

The phrases live in yomimon_locales/<code>/data/diary.lua. Pure logic, testable outside KOReader.
]]

local Lingua = require("yomimon_language")

local Diario = {}

local RESENHAS_MAX = 120
local FIM_DO_LIVRO = 0.98     -- book without a helpful table of contents: progress from which it counts as finished
local HISTORIA_MIN = 0.5      -- appendices that would start before the middle of the file: the table of contents is not reliable
local ENTRADA_MAX = 200       -- bigger entries lose optional parts

-- Appendix titles (what comes after the story), as whole words: notes, chronology, afterword,
-- about the author, credits, publisher ads…
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
    -- lowercase (also À…Þ), without numbers or punctuation: "XLV. Notas" → " xlv notas "
    local t = " " .. tostring(titulo or ""):lower():gsub("\195([\128-\158])", function(c) return "\195" .. string.char(c:byte() + 32) end)
        :gsub("[^%a\128-\255]+", " ") .. " "
    for chave in pairs(ANEXOS) do
        if t:find(chave, 1, true) then return true end
    end
    return false
end

--- Last page of the story, by the table of contents. Going backwards, it skips the appendix titles; the story ends
-- right before the first of them. Backwards because a chapter of the story may be called "Notas"
-- (Brás Cubas, XLV). Only the top level of the table of contents counts: the notes may have subtitles ("Capítulo 1"…).
-- toc: { { titulo =, pagina =, nivel = }, … } in the book's order; total: pages of the file.
-- Returns nil when the table of contents does not help (empty, only appendices, or appendices before the middle of the file).
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
    -- quotation punctuation: “Quem?”, disse → “Quem?” disse ; “Fim.”, disse → “Fim,” disse
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

-- Reading day ---------------------------------------------------------------------

--- Closes the previous day (if the day changed) and writes its entry. Call before counting the page.
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

--- Counts a page on today's date.
-- contar: false when the page was already counted before and is now only digested.
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

--- Characters it "met" today (became a character and had not been noted yet).
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

--- Builds the entry of a reading day (or nil, if there was no reading).
function Diario.entradaDoDia(s, M, D)
    if not D or D.paginas == 0 or #D.ordem == 0 then return nil end
    local B, temp = Diario.banco().dia, temperamento(s)
    local livro = D.ordem[1]
    local maior = 0
    for _, l in ipairs(D.ordem) do if D.livros[l] > maior then livro, maior = l, D.livros[l] end end
    local v = { n = tostring(D.paginas), livro = livro }
    -- opening: how much it ate
    local abertura
    if #D.ordem >= 2 then
        v.livro2 = D.ordem[1] == livro and D.ordem[2] or D.ordem[1]
        abertura = sorteia(B.dois_livros)
    elseif D.paginas <= 5 then abertura = sorteia(B.magro)
    elseif D.paginas < 30 then abertura = sorteia(B.normal)
    elseif D.paginas < 80 then abertura = sorteia(B.banquete)
    else abertura = sorteia(B.enorme) end
    local partes = { preencher(abertura, v) }
    -- time, when a period dominated the day
    local periodo, qtd = maiorDe(D.horas)
    local horario = periodo and qtd >= D.paginas * 0.6 and sorteia(B.horario[periodo])
    -- details of the day, in order of interest
    -- details of the day, each with a weight (the most concrete weigh more)
    local detalhes = {}
    local function detalhe(texto, peso) if texto then detalhes[#detalhes + 1] = { texto = texto, peso = peso } end end
    local novos = conhecidosHoje(s, M, D)
    if #novos >= 2 then
        detalhe(preencher(sorteia(B.novos2), { nome = novos[1], nome2 = novos[2] }), 4)
    elseif #novos == 1 then
        detalhe(preencher(sorteia(B.novo), { nome = novos[1] }), 4)
    end
    -- character line: does not repeat who spoke on the last noted day
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
    -- up to 2 details, drawn by weight
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
    -- closing: in its tone, pulled by the day's weather
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

-- Start and end of a book --------------------------------------------------------

--- Entry of a new book. anterior: the book it had been eating before (or nil).
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

--- Entry of a re-read.
function Diario.releitura(livro)
    return preencher(sorteia(Diario.banco().inicio.relendo), { livro = livro })
end

-- Trait that changed most during the book (or nil, if none changed enough).
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

--- Closes a finished book: writes the short review in the diary and stores the full one in s.resenhas.
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
    -- grade: half by the pace you read at, half by the book's intensity (events and weather)
    local ppd = L.paginas / math.max(1, dias)
    local ritmo = ppd < 10 and 1 or ppd < 20 and 2 or ppd < 30 and 3 or ppd < 45 and 4 or 5
    local n_eventos = 0
    for _, c in pairs(L.eventos or {}) do n_eventos = n_eventos + c end
    local intensidade = n_eventos / math.max(1, L.paginas) * 2 + math.abs(clima)
    local forca = intensidade < 0.3 and 1 or intensidade < 0.6 and 2 or intensidade < 1 and 3 or intensidade < 1.5 and 4 or 5
    local nota = math.max(1, math.min(5, math.floor((ritmo + forca) / 2 + 0.5)))
    local traco = tracoDoLivro(s, L)
    local citacao = M.citacao(s, livro, function() return 1 end, 100)

    -- comparisons with the previous reviews
    s.resenhas = s.resenhas or {}
    local anterior = s.resenhas[#s.resenhas]
    local serie = 0
    for i = #s.resenhas, 1, -1 do
        if s.resenhas[i].tema == tema and s.resenhas[i].livro ~= livro then serie = serie + 1 else break end
    end

    -- the book's compound name (book vector, yomimon_vector.lua): "a sea story, restless"
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
    if tema and serie == 1 then  -- 3rd in a row onwards becomes a guaranteed memory (yomimon_memories)
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
    -- the book's words (step 5): finished, keeps only the most counted
    if M.podarVocab then M.podarVocab(L, M.VOCAB_FIM) end
    local okLem, Lem = pcall(require, "yomimon_memories")
    if okLem then
        -- level C, stored and mute: probable genre and aura of the protagonist
        local r = s.resenhas[#s.resenhas]
        r.genero = Lem.genero(L.temas)
        r.aura = protagonista and L.aura and L.aura[protagonista] and Lem.aura(L.aura[protagonista]) or nil
        Lem.fimLivro(s, M, livro, agora, serie)
    end
    -- names: only the final list of characters and places stays; the evidence leaves the saved state
    if M.congelarNomes then M.congelarNomes(L, livro) end
end

--- Called on every page with the book already registered: reading days, progress, end and re-read.
function Diario.acompanharLivro(s, M, L, livro, onde, agora)
    local hoje = os.date("%Y-%m-%d", agora)
    if L.ultimo_dia ~= hoje then L.ultimo_dia, L.dias = hoje, (L.dias or 0) + 1 end
    local p = onde and onde.progresso
    if not p then return end
    if L.terminado and p < 0.1 and not L.relendo_agora then
        -- restarted an already finished book: re-read
        L.terminado, L.relendo, L.relendo_agora = false, true, true
        L.tracos_inicio = {}
        for k, v in pairs(s.tracos or {}) do L.tracos_inicio[k] = v end
        M.anotar(s, agora, Diario.releitura(livro))
    end
    L.progresso = p
    -- end: the last page of the story (onde.fim_historia, by the table of contents, in main.lua); without it, 98% of the file
    if p >= (onde.fim_historia or FIM_DO_LIVRO) and not L.terminado then
        L.terminado, L.relendo_agora = true, nil
        Diario.fimLivro(s, M, livro, agora)
    end
end

--- The book's status in KOReader ("reading", "complete", "abandoned"…), checked on opening, on closing and when
-- the Kindle sleeps. It became "complete" (you marked it as finished) while it was following: finished here
-- too, with a review. A book it sees for the first time already finished there (read before it) does not count; on a
-- re-read the status stays "complete" and the end comes from the table of contents. Returns true when the book finished.
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

--- Change of obsession (dominant theme), with varied phrases.
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
