--[[--
Traços de personalidade da Yomimon: se movem devagar com o que VOCÊ lê.

Cinco eixos, de -100 a 100:
  humor    amarga  ↔ otimista   (tragédias, mortes ↔ amor, festas, casamentos)
  coragem  medrosa ↔ corajosa   (terror, crimes ↔ mar, viagens, aventuras)
  coracao  cínica  ↔ romântica  (dinheiro, política, vingança ↔ amor, casamentos, cartas)
  gosto    popular ↔ erudita    (crimes, festas ↔ filosofia, arte, ciência, fé)
  relogio  diurna  ↔ noturna    (o horário em que você lê)

Só páginas comidas de verdade mexem nos traços (nunca o que ela sabe do livro à frente).
Cada página empurra pela DIFERENÇA para uma página média (yomimon_base_traits.lua): família e amor num
romance antigo, ou saber e fé num clássico, estão em quase todo livro e não empurram; só o que o seu
livro tem acima (ou abaixo) do normal molda ela. O que você NÃO lê só desfaz excesso: uma página sem
nada para um traço puxa para o neutro, nunca para o polo oposto (não ler romance não deixa cínica).
Cada página empurra um pouco e tudo volta devagar para o meio: o que você leu por último
pesa mais. Quando um traço fica marcante, ela escreve no diário e ganha falas próprias
(em yomimon_data/traits_pt.lua e tracos_en.lua).

Lógica pura (sem KOReader), testável fora dele.
]]

local Lingua = require("yomimon_language")
local T = Lingua.t

local Tracos = {}

Tracos.LISTA = {
    { id = "humor",   neg = "amarga",  pos = "otimista" },
    { id = "coragem", neg = "medrosa", pos = "corajosa" },
    { id = "coracao", neg = "cinica",  pos = "romantica" },
    { id = "gosto",   neg = "popular", pos = "erudita" },
    { id = "relogio", neg = "diurna",  pos = "noturna" },
}
Tracos.PASSO = 0.5          -- quanto uma página pode mexer num traço
Tracos.DECAIMENTO = 0.998   -- a cada página, tudo volta um pouco para o meio
Tracos.MARCANTE = 25        -- daqui pra cima o traço aparece nas falas e no diário
Tracos.FORTE = 60
Tracos.FOLGA = 5            -- para descer de nível precisa cair 5 abaixo do limite (sem pisca-pisca)

local ROTULO = {
    amarga = "AMARGA", otimista = "OTIMISTA", medrosa = "MEDROSA", corajosa = "CORAJOSA",
    cinica = "CÍNICA", romantica = "ROMÂNTICA", popular = "POPULAR", erudita = "ERUDITA",
    diurna = "DIURNA", noturna = "NOTURNA",
}

-- O que cada sinal da página empurra (positivo = polo "pos" do eixo).
local PESOS = {
    humor = {
        temas = { morte = -1, guerra = -1, solidao = -1, vinganca = -1, medo = -0.5, loucura = -1, dinheiro = -0.5,
                  amor = 1, natureza = 0.5, comida = 1, infancia = 0.5, arte = 0.5, viagem = 0.5 },
        eventos = { morte = -2, doenca = -1, crime = -1, briga = -0.5, festa = 1.5, casamento = 1.5 },
        -- (27/10/2026, PLANO-VOZ.md Etapa 6: loucura -0.5 → -1 e dinheiro -0.5, para a tragédia deixá-la amarga
        -- e não só medrosa como o terror; Crime e Castigo, Hamlet e Macbeth são loucura, culpa e dinheiro)
        -- (sem clima: a lista antiga puxava o terror para otimista; o dicionário ordena bem trechos curtos,
        -- mas deixa Shakespeare e a prosa vitoriana "leves" — Hamlet e Romeu ficavam menos amargos com ele.
        -- Fora desde 25/10/2026; ver ferramentas/validacao/MEMORIA-VINCULO.md)
    },
    coragem = {
        temas = { medo = -1.5, loucura = -0.5, noite = -0.3, viagem = 1, mar = 1, liberdade = 1, guerra = 0.5 },
        eventos = { fuga = -0.5, tempestade = 0.5, viagem = 1 },
        -- (crime saiu em 27/10/2026: crime e investigação, de Sherlock a Crime e Castigo, não são histórias de
        -- medo; o crime continua deixando ela amarga e um pouco cínica)
    },
    coracao = {
        temas = { amor = 1.5, arte = 0.5, familia = 0.5, dinheiro = -1, politica = -1, vinganca = -1 },
        eventos = { casamento = 1.5, carta = 0.5, briga = -0.5, crime = -0.5 },
    },
    gosto = {
        temas = { saber = 1, arte = 1, fe = 0.5, ciencia = 0.5 },
        eventos = { crime = -0.5, festa = -0.3 },
    },
}

Tracos.PESOS = PESOS  -- exposto para as ferramentas de validação

local function limitar(v, a) return math.max(-a, math.min(a, v)) end

-- Empurrão médio de uma página, por língua: o que todo livro tem não molda ela.
Tracos.CENTRADOS = { "humor", "coragem", "coracao", "gosto" }
local okB, BASE = pcall(require, "yomimon_base_traits")
Tracos.BASE = okB and type(BASE) == "table" and BASE or nil

local banco
--- Falas e anotações de diário dos traços, no idioma atual.
function Tracos.banco()
    banco = banco or require("yomimon_data.traits_" .. Lingua.codigo())
    return banco
end

--- -2, -1, 0, 1 ou 2 para um valor (sem considerar o nível anterior).
function Tracos.nivel(v)
    if v >= Tracos.FORTE then return 2 elseif v >= Tracos.MARCANTE then return 1
    elseif v <= -Tracos.FORTE then return -2 elseif v <= -Tracos.MARCANTE then return -1 end
    return 0
end

-- Nível com folga: para enfraquecer, o valor precisa cair FOLGA abaixo do limite do nível atual.
local function nivelComFolga(v, atual)
    local alvo = Tracos.nivel(v)
    if atual ~= 0 and (alvo == 0 or (alvo > 0) == (atual > 0)) and math.abs(alvo) < math.abs(atual) then
        local limite = math.abs(atual) == 2 and Tracos.FORTE or Tracos.MARCANTE
        if math.abs(v) > limite - Tracos.FOLGA and (v > 0) == (atual > 0) then return atual end
    end
    return alvo
end

--- Quanto uma página empurra cada eixo (de -1 a 1). hora: a hora local da leitura.
-- bruto: sem descontar a página média (para calcular a média e para diagnóstico).
function Tracos.empurrao(sinal, hora, bruto)
    local out = {}
    for id, P in pairs(PESOS) do
        local v = 0
        for t, c in pairs(sinal.temas or {}) do v = v + (P.temas[t] or 0) * math.min(c, 3) end
        for ev in pairs(sinal.eventos or {}) do v = v + (P.eventos[ev] or 0) end
        if P.clima then v = v + P.clima * (sinal.clima or 0) end
        out[id] = v
    end
    -- (o tamanho médio das palavras empurrava o gosto; saiu em 25/10/2026: decidia 70–83% do traço e
    -- chamava quase toda prosa de "popular", Henry James e Dostoiévski inclusive)
    local base = not bruto and Tracos.BASE and Tracos.BASE[sinal.pt and "pt" or "en"]
    local ausente = {}
    if base then
        for _, id in ipairs(Tracos.CENTRADOS) do
            if out[id] == 0 then ausente[id] = true end
            out[id] = out[id] - (base[id] or 0)
        end
    end
    out.relogio = 0
    if hora then
        if hora >= 22 or hora < 5 then out.relogio = 1 elseif hora < 12 then out.relogio = -1 end
    end
    for id, v in pairs(out) do out[id] = limitar(v, 1) end
    return out, ausente
end

--- Empurrão médio de uma página, por língua, num corpus (linhas de livros30.txt; `fora`: livros a
-- ignorar). Usado por ferramentas/validacao/calcular_base_tracos.lua e pela régua da personalidade.
function Tracos.mediaDasPaginas(M, linhas, fora)
    local soma, n, livro = { en = {}, pt = {} }, { en = 0, pt = 0 }, nil
    for linha in linhas do
        local t = linha:match("^#LIVRO\t(.*)")
        if t then livro = t
        elseif not linha:match("^#") and livro and not (fora and fora[livro]) then
            local sn = M.sinais(linha, livro)
            local lg = sn.pt and "pt" or "en"
            local e = Tracos.empurrao(sn, nil, true)
            n[lg] = n[lg] + 1
            for _, id in ipairs(Tracos.CENTRADOS) do soma[lg][id] = (soma[lg][id] or 0) + e[id] end
        end
    end
    local base = { en = {}, pt = {} }
    for lg, sm in pairs(soma) do
        for _, id in ipairs(Tracos.CENTRADOS) do base[lg][id] = (sm[id] or 0) / math.max(1, n[lg]) end
    end
    return base, n
end

local function notaDiario(tr, antes, depois, livro)
    local polo, chave
    if depois == 0 then
        polo, chave = antes > 0 and tr.pos or tr.neg, "volta"
    elseif math.abs(depois) > math.abs(antes) or (depois > 0) ~= (antes > 0) then
        polo, chave = depois > 0 and tr.pos or tr.neg, math.abs(depois)
    else
        return nil  -- enfraqueceu de 2 para 1: não vale anotar
    end
    local lista = Tracos.banco().diario[polo]
    lista = lista and lista[chave]
    if not lista or #lista == 0 then return nil end
    local texto = lista[math.random(#lista)]
    return (texto:gsub("{livro}", livro or T"esse livro"))
end

--- Digere uma página: mexe nos traços e devolve as anotações de diário de quem mudou de nível.
function Tracos.digerir(s, sinal, agora, livro)
    s.tracos = s.tracos or {}
    s.tracos_nivel = s.tracos_nivel or {}
    local hora = agora and tonumber(os.date("%H", agora))
    local emp, ausente = Tracos.empurrao(sinal, hora)
    local notas = {}
    for _, tr in ipairs(Tracos.LISTA) do
        local atual = (s.tracos[tr.id] or 0) * Tracos.DECAIMENTO
        local v = limitar(atual + (emp[tr.id] or 0) * Tracos.PASSO, 100)
        -- página sem nada para este eixo: o desconto da média só desfaz excesso (puxa para o neutro),
        -- nunca leva ao polo oposto
        if ausente and ausente[tr.id] then
            if atual == 0 or (v > 0) ~= (atual > 0) then v = 0
            elseif math.abs(v) > math.abs(atual) then v = atual end
        end
        -- um livro sozinho não fixa um traço forte: só passa de FORTE se o traço já era marcante, no mesmo
        -- sentido, quando este livro começou
        if math.abs(v) >= Tracos.FORTE then
            local L = livro and s.livros and s.livros[livro]
            local ini = L and L.tracos_inicio and L.tracos_inicio[tr.id] or 0
            if math.abs(ini) < Tracos.MARCANTE or (ini > 0) ~= (v > 0) then
                v = (v > 0 and 1 or -1) * (Tracos.FORTE - 0.1)
            end
        end
        s.tracos[tr.id] = v
        local antes = s.tracos_nivel[tr.id] or 0
        local depois = nivelComFolga(v, antes)
        if depois ~= antes then
            s.tracos_nivel[tr.id] = depois
            local nota = notaDiario(tr, antes, depois, livro)
            if nota then notas[#notas + 1] = nota end
        end
    end
    return notas
end

--- Polos marcantes, do mais forte ao mais fraco: { {polo, valor}, ... }.
function Tracos.marcantes(tracos)
    local lista = {}
    for _, tr in ipairs(Tracos.LISTA) do
        local v = (tracos or {})[tr.id] or 0
        if math.abs(v) >= Tracos.MARCANTE then lista[#lista + 1] = { v > 0 and tr.pos or tr.neg, math.abs(v) } end
    end
    table.sort(lista, function(a, b) return a[2] > b[2] end)
    return lista
end

--- Rótulo traduzido de um polo ("AMARGA", "NIGHT OWL"…).
function Tracos.rotulo(polo)
    return T(ROTULO[polo] or polo)
end

--- Até `max` rótulos dos traços marcantes ("AMARGA", "NOTURNA"…), já traduzidos.
function Tracos.rotulos(tracos, max)
    local out = {}
    for i, m in ipairs(Tracos.marcantes(tracos)) do
        if i > (max or 2) then break end
        out[#out + 1] = Tracos.rotulo(m[1])
    end
    return out
end

--- Uma fala do jeito que ela ficou, ou nil. Quanto mais forte o traço, mais ele aparece
-- (no máximo 4 em cada 10 falas). temperamento: "jovem" ou "velha".
function Tracos.fala(s, temperamento, sorteio)
    sorteio = sorteio or math.random
    local fortes = Tracos.marcantes(s.tracos)
    if #fortes == 0 then return nil end
    if sorteio(100) > math.min(40, fortes[1][2] * 0.6) then return nil end
    local soma = 0
    for _, f in ipairs(fortes) do soma = soma + f[2] end
    local alvo, acc, polo = sorteio(math.max(1, math.floor(soma))), 0, fortes[1][1]
    for _, f in ipairs(fortes) do
        acc = acc + f[2]
        if alvo <= acc then polo = f[1]; break end
    end
    local porPolo = Tracos.banco().falas[polo]
    local lista = porPolo and porPolo[temperamento == "jovem" and "jovem" or "velha"]
    if not lista or #lista == 0 then return nil end
    return lista[sorteio(#lista)]
end

return Tracos
