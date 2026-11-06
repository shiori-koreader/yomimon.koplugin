--[[--
Lembranças: a memória que cria vínculo. Ela compara o livro de agora com o histórico de leitura (as
resenhas, que passam de vida em vida) e lembra:

  nível A (fatos exatos)   autor de novo (com a conta), aniversário de um livro terminado, personagem
                           que volta (série), o livro mais longo, o lido mais rápido;
  nível B (percepção medida) terceiro livro seguido com o mesmo tema dominante.
  nível C (guardado, mudo)  gênero provável e aura do protagonista vão na resenha; "nada tão sombrio (ou
                           leve) desde X" é calculado mas não fala (CLIMA_FALA = false): a média de clima
                           de um livro inteiro põe Hamlet, Romeu e Julieta e Frankenstein entre os mais
                           leves do corpus. Ver ferramentas/validacao/MEMORIA-VINCULO.md.

Cada lembrança vira uma entrada no diário, a primeira fala da Home (uma vez) e um registro estruturado em
s.lembrancas, que a régua da memória confere contra o que aconteceu de verdade.

Lógica pura (sem KOReader), testável fora dele.
]]

local Lingua = require("yomimon_language")

local L = {}

local MAX = 200
local PAGINA_PERSONAGEM = 40   -- páginas do livro antes de procurar personagem que volta
local PASSO_PERSONAGEM = 20    -- e depois só a cada 20 páginas: a lista de personagens pesa o livro inteiro,
                               -- e refeita a cada página deixava a página 700 de Moby Dick 50 vezes mais lenta
local PAGINA_CLIMA = 60        -- páginas antes de comparar o clima do livro com o histórico
local LIVROS_NO_MEIO = 2       -- "desde X" só se houve pelo menos 2 livros depois de X
local DIAS_DESDE = 30          -- e se X terminou há pelo menos 30 dias
local BASE_RECORDE = 3         -- recordes só com pelo menos 3 livros terminados antes
local MARGEM_RAPIDO = 1.2      -- "o mais rápido" só se 20% mais rápido que o melhor anterior (livro curto
                               -- termina num dia incompleto e baixa a média: sem margem, todo livro longo ganhava)
L.CLIMA_FALA = false           -- nível C: "nada tão sombrio/leve desde" calculado, mas mudo

local function mes(t) return Lingua.format().months[tonumber(os.date("%m", t))] end

local function preencher(modelo, v)
    return (modelo:gsub("{([%w_]+)}", function(k) return v[k] ~= nil and tostring(v[k]) or ("{" .. k .. "}") end))
end
local function banco() return require("yomimon_diary").banco().lembranca or {} end

--- Registra uma lembrança: diário, Home (uma vez) e s.lembrancas.
local function lembrar(s, M, tipo, livro, agora, dados, v)
    local lista = banco()[tipo]
    if not lista or #lista == 0 then return nil end
    local texto = preencher(lista[math.random(#lista)], v or dados)
    s.lembrancas = s.lembrancas or {}
    s.lembrancas[#s.lembrancas + 1] = { tipo = tipo, livro = livro, t = agora, dados = dados }
    while #s.lembrancas > MAX do table.remove(s.lembrancas, 1) end
    M.anotar(s, agora, texto)
    s.lembranca_pendente = { texto = texto, t = agora }
    return texto
end

local function jaLembrou(Lv, tipo)
    Lv.lembrou = Lv.lembrou or {}
    if Lv.lembrou[tipo] then return true end
    Lv.lembrou[tipo] = true
    return false
end

local function terminados(s, livro)
    local out = {}
    for _, r in ipairs(s.resenhas or {}) do if r.livro ~= livro then out[#out + 1] = r end end
    return out
end

-- Nível A ----------------------------------------------------------------------------------

--- Começo de um livro: autor de novo, com a conta de quantos dele já foram. Devolve o texto (ou nil).
function L.inicioLivro(s, M, livro, onde, agora)
    local autor = onde and onde.autor
    if not autor or autor == "" then return nil end
    local vistos, n = {}, 1
    for _, r in ipairs(terminados(s, livro)) do
        if r.autor == autor and not vistos[r.livro] then vistos[r.livro] = true; n = n + 1 end
    end
    if n < 2 then return nil end
    local Lv = s.livros and s.livros[livro]
    if Lv and jaLembrou(Lv, "autor") then return nil end
    return lembrar(s, M, "autor", livro, agora, { autor = autor, n = n }, { autor = autor, n = n, livro = livro })
end

--- Uma vez por dia: aniversário de um livro terminado (mesmo dia e mês, um ano antes).
local function aniversario(s, M, livro, agora)
    local hoje = os.date("%Y-%m-%d", agora)
    if s.lembranca_dia == hoje then return end
    s.lembranca_dia = hoje
    local md, ano = os.date("%m-%d", agora), tonumber(os.date("%Y", agora))
    for _, r in ipairs(s.resenhas or {}) do
        if r.fim and os.date("%m-%d", r.fim) == md and tonumber(os.date("%Y", r.fim)) == ano - 1 and r.aniversario ~= ano then
            r.aniversario = ano
            lembrar(s, M, "aniversario", livro, agora, { livro = r.livro }, { livro = r.livro })
            return
        end
    end
end

--- Personagem que volta de um livro anterior (série). Não vale em releitura.
local function personagem(s, M, Lv, livro, agora)
    if Lv.relendo or (Lv.paginas or 0) < PAGINA_PERSONAGEM or (Lv.lembrou and Lv.lembrou.personagem) then return end
    if Lv.paginas % PASSO_PERSONAGEM ~= 0 or #(s.resenhas or {}) == 0 then return end
    local info = M.personagensInfo(s, livro)
    for i = 1, math.min(3, #info) do
        local nome = info[i].nome
        local formas = {}  -- "Holmes" na resenha antiga vale para "Sherlock Holmes" agora, e vice-versa
        for _, f in ipairs(info[i].formas or { nome }) do formas[f] = true end
        for k = #(s.resenhas or {}), 1, -1 do
            local r = s.resenhas[k]
            if r.livro ~= livro then
                for _, p in ipairs(r.personagens or {}) do
                    if formas[p] then
                        jaLembrou(Lv, "personagem")
                        lembrar(s, M, "personagem", livro, agora, { nome = nome, de = r.livro }, { nome = nome, livro = r.livro })
                        return
                    end
                end
            end
        end
    end
end

-- Nível B ----------------------------------------------------------------------------------

--- Clima do livro até aqui comparado com o histórico: "nada tão sombrio desde X" ou "o mais sombrio".
local function climaDesde(s, M, Lv, livro, agora)
    if (Lv.paginas or 0) < PAGINA_CLIMA or (Lv.lembrou and Lv.lembrou.clima) then return end
    jaLembrou(Lv, "clima")
    local media = (Lv.clima or 0) / math.max(1, Lv.paginas)
    local cal = M.CLIMA_CALIBRACAO and M.CLIMA_CALIBRACAO.livros
    if not cal then return end
    local escuro = media <= cal.sombrio
    if not escuro and media < cal.leve then return end
    local ant = terminados(s, livro)
    local function tanto(r) if escuro then return r.clima <= media else return r.clima >= media end end
    local alvo
    for k = #ant, 1, -1 do if tanto(ant[k]) then alvo = k; break end end
    if alvo then
        local no_meio = #ant - alvo
        local dias = ((Lv.inicio or agora) - (ant[alvo].fim or agora)) / 86400
        if no_meio >= LIVROS_NO_MEIO and dias >= DIAS_DESDE then
            local r = ant[alvo]
            Lv.clima_desde = { tipo = escuro and "sombrio_desde" or "leve_desde", livro = r.livro }
            if L.CLIMA_FALA then
                lembrar(s, M, Lv.clima_desde.tipo, livro, agora, { livro = r.livro }, { livro = r.livro, mes = mes(r.fim) })
            end
        end
    elseif #ant >= BASE_RECORDE then
        Lv.clima_desde = { tipo = escuro and "mais_sombrio" or "mais_leve" }
        if L.CLIMA_FALA then lembrar(s, M, Lv.clima_desde.tipo, livro, agora, {}, { livro = livro }) end
    end
end

--- Cada página lida.
function L.pagina(s, M, Lv, livro, agora)
    aniversario(s, M, livro, agora)
    if Lv then
        personagem(s, M, Lv, livro, agora)
        climaDesde(s, M, Lv, livro, agora)
    end
end

--- Fim de um livro (depois da resenha guardada): recordes e série de tema.
-- serie: quantos livros seguidos antes deste tinham o mesmo tema dominante.
function L.fimLivro(s, M, livro, agora, serie)
    local cur = s.resenhas and s.resenhas[#s.resenhas]
    if not cur or cur.livro ~= livro then return end
    local ant = {}
    for i = 1, #s.resenhas - 1 do ant[#ant + 1] = s.resenhas[i] end
    if cur.tema and (serie or 0) >= 2 then
        lembrar(s, M, "serie_tema", livro, agora, { tema = cur.tema, n = serie + 1 },
            { tema = M.tema(cur.tema), de_tema = M.tema(cur.tema, "de"), n = serie + 1 })
    end
    if #ant >= BASE_RECORDE then
        local function ppd(r) return r.paginas / math.max(1, r.dias or 1) end
        local longo, rapido = true, true
        for _, r in ipairs(ant) do
            if r.paginas >= cur.paginas then longo = false end
            if ppd(r) * MARGEM_RAPIDO >= ppd(cur) then rapido = false end
        end
        if longo then lembrar(s, M, "recorde_longo", livro, agora, {}, { livro = livro, n = cur.paginas }) end
        if rapido then lembrar(s, M, "recorde_rapido", livro, agora, {}, { livro = livro }) end
    end
end

-- Nível C (guardado, mudo) -----------------------------------------------------------------

local GENEROS = {
    terror = { "medo", "noite", "morte", "loucura" }, romance = { "amor", "familia" },
    aventura = { "mar", "viagem", "animais" }, ficcao_cientifica = { "ciencia" },
    tragedia = { "vinganca", "politica", "morte" },
}
local AURAS = {
    sombrio = { "medo", "morte", "loucura", "noite" }, romantico = { "amor" }, aventureiro = { "mar", "viagem", "guerra" },
    poderoso = { "politica", "dinheiro" }, intelectual = { "saber", "ciencia", "arte" }, familiar = { "familia" },
}
local function melhor(temas, grupos)
    local tot = 0
    for _, c in pairs(temas or {}) do tot = tot + c end
    if tot <= 0 then return nil end
    local l = {}
    for g, ts in pairs(grupos) do
        local v = 0
        for _, t in ipairs(ts) do v = v + (temas[t] or 0) / tot end
        l[#l + 1] = { g, v }
    end
    table.sort(l, function(a, b) return a[2] > b[2] end)
    return l
end
--- Gênero provável (≥ 30% dos temas e 8 pontos à frente) ou nil. NÃO usado em falas: acerta ~75%.
function L.genero(temas)
    local l = melhor(temas, GENEROS)
    if l and l[1][2] >= 0.30 and l[1][2] - (l[2] and l[2][2] or 0) >= 0.08 then return l[1][1] end
end
--- Aura de um personagem pelos temas das páginas em que ele aparece. NÃO usado em falas ainda.
function L.aura(temas)
    local l = melhor(temas, AURAS)
    return l and l[1][1] or nil
end

return L
