--[[--
Memória da Yomimon: o que os livros fazem com ela.

Cada página comida passa por aqui. Ela registra:
- temas (morte, amor, mar, guerra…) por palavras-chave, que mudam as falas dela;
- personagens (nomes próprios que se repetem) de cada livro, usados nos comentários do Caderno;
- o diário: eventos da vida dela, escritos com a voz dela.

Lógica pura (sem KOReader), testável fora dele.
]]

local Lingua = require("yomimon_language")
local Diario = require("yomimon_diary")
local Voz = require("yomimon_voice")
local T = Lingua.t

local M = {}

-- Temas e palavras que os alimentam (português e inglês, em minúsculas).
M.TEMAS = {
    morte = { "morte", "morrer", "morreu", "morto", "morta", "mortos", "túmulo", "enterro", "cadáver", "luto", "funeral",
              "death", "dead", "die", "died", "grave", "funeral", "corpse",
              "morrera", "buried" },
    amor = { "amor", "amar", "amava", "amo", "beijo", "beijou", "paixão", "coração", "amante", "querida", "querido",
             "love", "loved", "kiss", "heart", "darling", "beloved",
             "amores", "noiva", "noivo", "noivas", "afeição", "afeições", "ternura", "beijar", "beijos", "beijava", "adorar", "adorava", "adoro" },
    guerra = { "guerra", "batalha", "soldado", "soldados", "exército", "inimigo", "arma", "armas", "tiro", "sangue",
               "war", "battle", "soldier", "army", "enemy", "gun", "blood",
               "guerreiro", "guerreiros" },
    mar = { "mar", "navio", "onda", "ondas", "praia", "barco", "marinheiro", "oceano", "porto", "naufrágio",
            "sea", "ship", "wave", "waves", "boat", "sailor", "ocean", "shore" },
    fe = { "deus", "deuses", "alma", "fé", "igreja", "oração", "rezar", "pecado", "céu", "inferno", "diabo",
           "god", "soul", "faith", "church", "prayer", "sin", "heaven", "hell",
           "sagrado", "sagrada" },
    dinheiro = { "dinheiro", "ouro", "rico", "rica", "pobre", "dívida", "banco", "preço", "herança", "fortuna",
                 "money", "gold", "rich", "poor", "debt", "bank", "price", "fortune",
                 "réis", "dote", "riqueza", "riquezas", "credor", "credores", "pounds", "salary" },
    loucura = { "louco", "louca", "loucura", "delírio", "sonho", "sonhos", "pesadelo", "febre", "alucinação",
                "mad", "madness", "insane", "dream", "dreams", "nightmare", "fever" },
    tempo = { "tempo", "relógio", "anos", "memória", "lembrança", "passado", "saudade", "velho", "velha",
              "time", "clock", "years", "memory", "past", "old" },
    cidade = { "cidade", "rua", "ruas", "praça", "bonde", "café", "multidão", "esquina",
               "city", "street", "streets", "square", "crowd", "corner" },
    natureza = { "árvore", "árvores", "floresta", "rio", "chuva", "vento", "flor", "flores", "campo", "pássaro",
                 "tree", "trees", "forest", "river", "rain", "wind", "flower", "field", "bird",
                 "folhas", "hill", "hills" },
    comida = { "comida", "comer", "comeu", "pão", "vinho", "jantar", "almoço", "banquete", "fome", "cozinha", "sopa",
               "carne", "fruta", "açúcar", "food", "bread", "wine", "dinner", "supper", "kitchen", "soup", "meat" },
    familia = { "família", "mãe", "pai", "irmão", "irmã", "filho", "filha", "avó", "avô", "herdeiro", "parentes",
                "family", "mother", "father", "brother", "sister", "son", "daughter", "heir",
                "marido", "maridos", "prima", "primo", "primas", "primos", "mamãe", "papai", "wife", "wives", "daughters", "parents", "cousin", "cousins", "relations" },
    infancia = { "infância", "criança", "crianças", "menino", "menina", "brincar", "brinquedo", "escola", "inocência",
                 "childhood", "child", "children", "boy", "girl", "toy", "school", "innocence",
                 "baby", "babies" },
    politica = { "rei", "rainha", "império", "governo", "revolução", "povo", "lei", "leis", "trono", "príncipe",
                 "ministro", "king", "queen", "empire", "government", "revolution", "law", "throne", "prince",
                 "partido", "partidos", "política", "político" },
    ciencia = { "ciência", "experimento", "laboratório", "química", "máquina", "invenção", "eletricidade", "cientista",
                "anatomia", "science", "experiment", "laboratory", "chemistry", "machine", "invention", "electricity" },
    solidao = { "solidão", "sozinho", "sozinha", "isolado", "isolada", "silêncio", "abandono", "exílio", "ausência",
                "lonely", "alone", "solitude", "silence", "abandoned", "exile", "absence",
                "abandonado", "abandonada", "desamparo" },
    arte = { "arte", "pintura", "poema", "poesia", "artista", "quadro", "teatro", "canção", "verso", "versos", "pintor",
             "art", "painting", "poem", "poetry", "artist", "theatre", "song", "verse", "painter",
             "music" },
    animais = { "cavalo", "cão", "cachorro", "gato", "lobo", "cobra", "baleia", "rato", "pássaros", "bicho",
                "horse", "dog", "cat", "wolf", "snake", "whale", "rat", "insect", "beast" },
    noite = { "noite", "lua", "escuridão", "estrelas", "madrugada", "vela", "lampião", "crepúsculo",
              "night", "moon", "darkness", "stars", "midnight", "candle", "dusk" },
    viagem = { "viagem", "caminho", "trem", "viajante", "horizonte", "jornada", "bagagem", "mapa", "estrangeiro",
               "travel", "path", "train", "traveller", "horizon", "luggage", "map", "foreign",
               "partiu", "caminhava", "caminhar" },
    vinganca = { "vingança", "vingar", "ódio", "traição", "traiu", "rancor", "culpa", "castigo", "inimizade",
                 "revenge", "avenge", "hatred", "betrayal", "betrayed", "grudge", "guilt", "punishment" },
    liberdade = { "liberdade", "livre", "livres", "prisão", "preso", "presa", "escravo", "escravidão", "correntes", "cativeiro",
                  "freedom", "free", "prison", "prisoner", "slave", "slavery", "chains", "captivity" },
    saber = { "livro", "livros", "ler", "leitura", "biblioteca", "saber", "verdade", "conhecimento", "filosofia", "estudo",
              "book", "books", "reading", "library", "knowledge", "truth", "philosophy", "study" },
    medo = { "medo", "terror", "pavor", "monstro", "fantasma", "assombrado", "grito", "arrepio", "assombração",
             "fear", "terror", "monster", "ghost", "haunted", "scream", "dread",
             "scared", "dreaded" },
}

-- Gênero de cada tema, para acertar "no mar", "pela morte", "de Deus"…
local TEMA_INFO = {
    morte = { "a", "morte" }, amor = { "o", "amor" }, guerra = { "a", "guerra" }, mar = { "o", "mar" },
    fe = { nil, "Deus" }, dinheiro = { "o", "dinheiro" }, loucura = { "a", "loucura" }, tempo = { "o", "tempo" },
    cidade = { "a", "cidade" }, natureza = { "o", "mato" },
    comida = { "a", "comida" }, familia = { "a", "família" }, infancia = { "a", "infância" },
    politica = { "a", "política" }, ciencia = { "a", "ciência" }, solidao = { "a", "solidão" }, arte = { "a", "arte" },
    animais = { "os", "bichos" }, noite = { "a", "noite" }, viagem = { "a", "viagem" }, vinganca = { "a", "vingança" },
    liberdade = { "a", "liberdade" }, saber = { "o", "saber" }, medo = { "o", "medo" },
}
local CONTRACAO = {
    em = { o = "no", a = "na", os = "nos", as = "nas" }, de = { o = "do", a = "da", os = "dos", as = "das" },
    por = { o = "pelo", a = "pela", os = "pelos", as = "pelas" }, a = { o = "ao", a = "à", os = "aos", as = "às" },
}

--- Nome do tema com artigo e preposição contraída: M.tema("mar", "em") → "no mar".
function M.tema(t, prep)
    local info = TEMA_INFO[t]
    if not info then return t end
    local art, nome = info[1], info[2]
    if not prep then return art and (art .. " " .. nome) or nome end
    if art then return CONTRACAO[prep][art] .. " " .. nome end
    return prep .. " " .. nome
end

M.NOMES_TEMA = {}
for t in pairs(TEMA_INFO) do M.NOMES_TEMA[t] = M.tema(t) end

-- Pares que, juntos, deixam ela dividida.
local OPOSTOS = { amor = "guerra", guerra = "amor", fe = "loucura", loucura = "fe", cidade = "natureza",
                  natureza = "cidade", dinheiro = "fe", familia = "solidao", solidao = "familia",
                  liberdade = "politica", politica = "liberdade", infancia = "morte", ciencia = "fe",
                  vinganca = "amor", arte = "dinheiro", saber = "medo", medo = "saber" }

-- Palavras comuns demais para fazer um tema sozinhas ("old", "time", "night", "mother"):
-- só contam com outra palavra do mesmo tema na página (ou repetidas 3+ vezes).
local GENERICAS = {}
for p in ([[tempo anos velho velha time years old rua ruas multidão street streets crowd corner square
    menino menina criança crianças escola boy girl child children school noite lua vela estrelas night moon candle
    stars livro livros ler leitura saber verdade estudo book books reading truth study pobre rico rica banco preço
    ouro poor rich bank price gold fortune mãe pai filho filha irmão irmã mother father son daughter brother sister
    coração heart alma céu deus soul heaven god livre livres free sangue inimigo blood enemy grave dead onda praia
    barco porto shore boat wave flor flores vento rio campo pássaro árvore wind river field bird tree flower
    jantar almoço cozinha vinho pão dinner supper kitchen wine bread rei rainha príncipe povo lei king queen prince
    law teatro canção quadro verso theatre song art verse sonho sonhos febre dream dreams fever culpa guilt
    silêncio silence alone sozinho caminho path cavalo cão horse dog marido maridos wife wives prima primo primas primos]]):gmatch("[%a\128-\255]+") do GENERICAS[p] = true end

local indice = {}
for tema, palavras in pairs(M.TEMAS) do
    for _, p in ipairs(palavras) do indice[p] = tema end
end

-- Eventos: grupos de palavras que indicam algo acontecendo na página.
M.EVENTOS = {
    morte = { "morreu", "morrera", "morto", "morta", "enterro", "enterraram", "caixão", "luto", "velório", "funeral",
              "cadáver", "faleceu", "died", "dead", "coffin", "buried", "corpse",
              "death" },
    casamento = { "casamento", "casaram", "casou", "noiva", "noivo", "altar", "núpcias", "aliança",
                  "wedding", "married", "bride", "groom",
                  "matrimônio", "marriage" },
    viagem = { "partiu", "partida", "viagem", "viajou", "estrada", "carruagem", "chegou", "chegada", "embarcou",
               "journey", "departed", "voyage", "road", "carriage", "arrived",
               "partiram", "partir", "drove" },
    carta = { "carta", "cartas", "escreveu", "envelope", "bilhete", "correio", "letter", "letters", "wrote",
              "seal" },
    tempestade = { "tempestade", "trovão", "relâmpago", "relâmpagos", "ventania", "temporal", "storm", "thunder", "lightning", "gale",
                   "trovoada" },
    doenca = { "doença", "doente", "febre", "médico", "tosse", "enfermo", "leito", "illness", "sick", "fever", "doctor", "cough" },
    festa = { "festa", "baile", "dança", "dançaram", "banquete", "música", "party", "ball", "dance", "feast", "music" },
    briga = { "briga", "brigaram", "discussão", "gritou", "insulto", "insultou", "quarrel", "argued", "shouted", "insult" },
    fuga = { "fugiu", "fuga", "escapou", "escondeu", "perseguição", "fled", "escape", "escaped", "hid", "chase",
             "fugir", "fugiram" },
    crime = { "crime", "assassinato", "matou", "assassino", "roubo", "polícia", "murder", "killed", "murderer", "theft", "police" },
}
local indice_evento = {}
for ev, palavras in pairs(M.EVENTOS) do
    for _, p in ipairs(palavras) do indice_evento[p] = ev end
end

-- Assuntos do capítulo, para os cartões (yomimon_data/topics.lua): contados como os eventos. Palavra solta
-- entra com o plural (-s, -es); expressão de várias palavras conta como sequência, a não ser que contenha
-- uma palavra da própria lista ("great-grandfather" já conta como "grandfather").
local okAs, ASSUNTOS = pcall(require, "yomimon_data.topics")
M.ASSUNTOS = okAs and type(ASSUNTOS) == "table" and ASSUNTOS or {}
local indice_assunto, frases_assunto = {}, {}
for as, palavras in pairs(M.ASSUNTOS) do
    local solta = {}
    for _, p in ipairs(palavras) do if not p:find("[^%a\128-\255]") then solta[p] = true end end
    for _, p in ipairs(palavras) do
        if solta[p] then
            for _, f in ipairs({ p, p .. "s", p .. "es" }) do indice_assunto[f] = indice_assunto[f] or as end
        else
            local seq, contida = {}, false
            for w in p:gmatch("[%a\128-\255]+") do
                seq[#seq + 1] = w
                if solta[w] then contida = true end
            end
            if #seq > 1 and not contida then frases_assunto[#frases_assunto + 1] = { assunto = as, seq = seq, nome = p } end
        end
    end
end
table.sort(frases_assunto, function(a, b) return a.nome < b.nome end)
-- conta as expressões na sequência de palavras ws (1..n): chama achou(assunto, expressão) a cada uma
local function frasesDeAssunto(ws, n, achou)
    for _, f in ipairs(frases_assunto) do
        local k = #f.seq
        for i = 1, n - k + 1 do
            local igual = true
            for j = 1, k do
                if ws[i + j - 1] ~= f.seq[j] then igual = false; break end
            end
            if igual then achou(f.assunto, f.nome) end
        end
    end
end

-- Clima: palavras que esquentam (+1) ou esfriam (-1) a página.
local CLIMA = {}
for p in ([[feliz alegria riso riu sorriu sorriso belo bela doce esperança paz luz gentil carinho ternura
    felicidade happy joy smile smiled laugh laughed beautiful sweet hope peace light kind gentle delighted delight]]):gmatch("%S+") do CLIMA[p] = 1 end
for p in ([[triste tristeza dor medo chorou choro lágrimas escuro sombra ódio raiva sofrimento desespero frio
    angústia horror melancolia infeliz infelizes sad pain fear cried tears dark shadow hate anger suffering despair
    cold horror dread grief weep weeping]]):gmatch("%S+") do CLIMA[p] = -1 end

-- Grafia antiga do português (quase todo o domínio público: "sciencia", "philosophia", "lagryma",
-- "afflicção", "egreja"). Palavra que não está nas listas é procurada também na forma modernizada:
-- sem acento, ph→f, th→t, y→i, sc→c no começo, consoantes dobradas viram uma (menos ss e rr).
-- Só em página em português: em inglês "three" viraria "tree" e "good" viraria "god".
local SEM_ACENTO = { ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["é"] = "e", ["ê"] = "e", ["í"] = "i",
    ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ü"] = "u", ["ç"] = "c" }
local GRAFIA_FIXA = { egreja = "igreja", egrejas = "igrejas", pae = "pai", paes = "pais" }
local function grafiaModerna(w)
    w = w:gsub("\195[\128-\191]", SEM_ACENTO):gsub("ph", "f"):gsub("th", "t"):gsub("y", "i"):gsub("^sc([ei])", "c%1")
    w = w:gsub("([b-df-hj-np-tv-z])%1", function(c) if c == "s" or c == "r" then return c .. c end return c end)
    return GRAFIA_FIXA[w] or w
end
-- índice paralelo pela forma moderna; forma que cai em dois grupos diferentes fica de fora
local function indiceModerno(mapa)
    local out, conflito = {}, {}
    for p, v in pairs(mapa) do
        local m = grafiaModerna(p)
        if out[m] ~= nil and out[m] ~= v then conflito[m] = true end
        out[m] = v
    end
    for m in pairs(conflito) do out[m] = nil end
    return out
end
local indice_mod, evento_mod, clima_mod = indiceModerno(indice), indiceModerno(indice_evento), indiceModerno(CLIMA)
local assunto_mod = indiceModerno(indice_assunto)
local GENERICAS_MOD = {}
for p in pairs(GENERICAS) do GENERICAS_MOD[grafiaModerna(p)] = true end
local function generica(w) return GENERICAS[w] or GENERICAS_MOD[grafiaModerna(w)] or false end
M.grafiaModerna = grafiaModerna  -- usado pelos dicionários e pelas ferramentas

-- Palavras do próprio livro (PLANO-VOZ.md, Etapa 5) --------------------------------------------------
-- Candidatas: em minúscula (nome próprio nunca entra), 5 letras ou mais, só letras, fora das palavras
-- comuns da língua (yomimon_common_words.lua, gerada do corpus) e fora de advérbios e de palavras
-- ofensivas que os clássicos usam. Em português, a comparação com as comuns é na grafia moderna.
local okComuns, COMUNS = pcall(require, "yomimon_common_words")
COMUNS = okComuns and type(COMUNS) == "table" and COMUNS or nil
local OFENSIVAS = {}
for p in ([[nigger niggers nigga niggas negro negroes darkie darkies coolie coolies squaw squaws savage savages
            crioulo crioula crioulos crioulas negrinho negrinha negrinhos negrinhas mulato mulata mulatos mulatas
            selvagem selvagens bugre bugres]]):gmatch("%S+") do OFENSIVAS[p] = true end
-- Para ser marcante, a palavra precisa aparecer pelo menos uma vez logo depois de um artigo ou possessivo
-- ("o seminário", "the harpoon"): é o jeito barato de ficar com os substantivos e deixar de fora verbos
-- e advérbios ("montou", "afterward"). Por livro ficam as duas contas: vocab (todas) e vocab_art.
local DETERMINANTES = {}
for p in ([[the a an this that these those his her my your their our its some no every
            o a os as um uma uns umas do da dos das no na nos nas ao aos pelo pela pelos pelas seu sua seus suas
            meu minha meus minhas teu tua este esta estes estas esse essa esses essas aquele aquela aqueles aquelas
            num numa dum duma]]):gmatch("%S+") do DETERMINANTES[p] = true end
M.VOCAB_MAX, M.VOCAB_PODA = 150, 100   -- por livro: passando de 150 palavras, ficam as 100 mais contadas
M.VOCAB_FIM = 20                       -- livro terminado guarda só as 20 mais contadas
M.MARCANTE_MIN = 3                     -- vezes no livro para a palavra ser marcante

--- A palavra pode ser marcante? (w como está no texto; pt = página em português)
function M.candidata(w, pt)
    if not COMUNS or not (w:find("^%l") or w:find("^\195[\160-\191]")) then return false end
    if not w:find("^[%a\128-\255]+$") or #w - select(2, w:gsub("[\128-\191]", "")) < 5 then return false end
    if OFENSIVAS[w] then return false end
    if pt then
        if w:find("mente$") or COMUNS.pt[grafiaModerna(w)] then return false end
    elseif (#w >= 7 and w:find("ly$")) or COMUNS.en[w] then
        return false
    end
    return true
end

-- Força de uma palavra no livro: todas as vezes, mais as vezes depois de artigo.
local function forca(L, w) return (L.vocab[w] or 0) + ((L.vocab_art or {})[w] or 0) end

--- Deixa no vocabulário do livro só as `n` palavras mais fortes.
function M.podarVocab(L, n)
    local lista = {}
    for w in pairs(L.vocab or {}) do lista[#lista + 1] = { w, forca(L, w) } end
    if #lista <= n then return end
    table.sort(lista, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    local novo, novo_art = {}, {}
    for i = 1, n do
        local w = lista[i][1]
        novo[w], novo_art[w] = L.vocab[w], (L.vocab_art or {})[w]
    end
    L.vocab, L.vocab_art = novo, novo_art
end

-- Clima por dicionário de sentimento: VADER (inglês, MIT) e SentiLex-PT 02 (português, CC-BY 4.0).
-- Nota da página = soma das valências por 100 palavras ("não"/"never" invertem as 3 seguintes), e o
-- clima é essa nota centrada na mediana da língua e dividida pela meia faixa central do corpus
-- (yomimon_weather_calibration.lua): página típica ~0, os 30% mais sombrios ou mais leves passam de ±1.
-- Sem os dicionários, volta à lista curta de palavras (CLIMA).
local okEn, LEX_EN = pcall(require, "yomimon_lexicon_en")
local okPt, LEX_PT = pcall(require, "yomimon_lexicon_pt")
local okC, CAL_CLIMA = pcall(require, "yomimon_weather_calibration")
local LEXICO = { en = okEn and LEX_EN or nil, pt = okPt and LEX_PT or nil }
M.CLIMA_CALIBRACAO = okC and CAL_CLIMA or nil
local NEGACAO = {}
for w in ("no not never none nobody nothing neither nor nowhere cannot without não nunca jamais nem nada nenhum nenhuma ninguém sem"):gmatch("%S+") do
    NEGACAO[w] = true
end
--- Nota de sentimento (por 100 palavras) de um texto já limpo, ou nil se não há dicionário da língua.
function M.sentimento(limpo, pt)
    local lex = LEXICO[pt and "pt" or "en"]
    if not lex then return nil end
    local soma, n, neg = 0, 0, 0
    for w in limpo:gmatch("[%a\128-\255]+") do
        n = n + 1
        if NEGACAO[w] then neg = 3
        else
            local v = lex[pt and grafiaModerna(w) or w]
            if v then soma = soma + (neg > 0 and -v or v) end
            if neg > 0 then neg = neg - 1 end
        end
    end
    return n > 0 and soma * 100 / n or 0
end
local function temaDe(w, pt) return indice[w] or (pt and indice_mod[grafiaModerna(w)]) or nil end
local function eventoDe(w, pt) return indice_evento[w] or (pt and evento_mod[grafiaModerna(w)]) or nil end
local function assuntoDe(w, pt) return indice_assunto[w] or (pt and assunto_mod[grafiaModerna(w)]) or nil end
local function climaDe(w, pt) return CLIMA[w] or (pt and clima_mod[grafiaModerna(w)]) or nil end
-- Língua da página pelas palavras mais comuns de cada uma.
local FUNCIONAL = {}
for p in ("que não uma com para ele ela elle ella mas como seu sua dos das pelo pela"):gmatch("%S+") do FUNCIONAL[p] = "pt" end
for p in ("the and was with that his her which this have from were they would"):gmatch("%S+") do FUNCIONAL[p] = "en" end
local function emPortugues(limpo)
    local pt, en = 0, 0
    for w in limpo:gmatch("[%a\128-\255]+") do
        local l = FUNCIONAL[w]
        if l == "pt" then pt = pt + 1 elseif l == "en" then en = en + 1 end
    end
    return pt > en
end
-- Peso de especificidade (yomimon_topic_weights.lua): tema que aparece em quase todo livro ("família",
-- "tempo") soma menos na memória do livro, do capítulo, do dia e na dela; tema raro soma mais.
-- A detecção por página não muda.
local okP, PESOS = pcall(require, "yomimon_topic_weights")
M.PESOS = okP and type(PESOS) == "table" and PESOS or {}
function M.pesoTema(t, pt) return (M.PESOS[pt and "pt" or "en"] or {})[t] or 1 end

-- para a ferramenta de validação mostrar o que disparou cada tema
function M.temaDaPalavra(w, texto) return temaDe(w, texto and emPortugues(M.limpar(texto))) end

-- Palavras antes de um nome que indicam lugar ("em Genebra", "para Londres").
local PREP_LUGAR = {}
for p in ("em no na in at into"):gmatch("%S+") do PREP_LUGAR[p] = true end

-- Verbos de fala ("disse Victor", "Victor perguntou").
local VERBO_FALA = {}
for p in ([[disse dizia perguntou respondeu gritou murmurou exclamou sussurrou falou continuou acrescentou
    retrucou tornou replicou said says asked replied shouted whispered cried continued added answered
    exclaimed observed remarked rejoined repeated]]):gmatch("%S+") do VERBO_FALA[p] = true end

-- Palavras com maiúscula que não são personagens.
local NAO_NOMES = {}
for p in ([[Ele Ela Eles Elas Não Sim Mas Então Quando Depois Antes Porque Como Quem Que Onde Isso Aquilo
    Este Esta Esse Essa Aquele Aquela Senhor Senhora Dona Deus Nós Você Vocês Também Ainda Agora Nunca Sempre
    Capítulo The And But When Then She His Her They What Where Who This That Mr Mrs Miss Chapter Sir Lady God
    Rua Lago Monte Rio Praça Igreja Castelo Cidade Vila Street Lake Mount River Castle Saint Santa Santo
    Its Yes Not There Here Now Oh Well For With From After Before Their Him Them Our Your Into Upon
    Was Were Had Have Has Did Does Just Only Even Still Perhaps Yet All One Two First Last Every Some
    Any Such Very Much More Most Lord Madam Captain Doctor Dear Why How Yes Nor Thus Indeed Alas
    Primeira Primeiro Segunda Segundo Grande Pequeno Pequena Novo Nova Velho Velha São Norte Sul Leste Oeste
    Ocidente Oriente Ocidental Ocidentais Oriental Orientais Europeia Europeu Comunidade Guerra Mundial Império
    República Estado Reino Universidade Academia Rei Rainha Príncipe Princesa Conde Condessa Duque Barão Visconde
    General Coronel Major Capitão Doutor Padre Frei Irmã Irmão Tio Tia Avó Avô Sinhá Sinhô Sinhazinha Nosso Nossa
    North South East West Great Little Old King Queen Prince Princess Duke Count Countess Baron General Colonel
    Major Father Mother Sister Brother Uncle Aunt Holy Empire Republic Kingdom University World Mister Madame
    Monsieur Mademoiselle Señor January February March April May June July August September October November
    December Monday Tuesday Wednesday Thursday Friday Saturday Sunday Janeiro Fevereiro Março Abril Maio Junho
    Julho Agosto Setembro Outubro Novembro Dezembro Por Para Com Sem Sob Sobre Entre Até Desde Contra Pelo Pela
    Pelos Pelas Num Numa Uma Uns Umas Del Los Las Una Pero Sí Qué Cómo Dónde Cuando Porque Usted Ustedes
    Era Foi Tinha Havia Estava Seria Disse Vou Vai Nada Tudo Ninguém Alguém Algo Cada Todo Toda Todos Todas
    Muito Pouco Mais Menos Bem Mal Ali Aqui Hoje Ontem Amanhã Natal Páscoa Companhia Senhorita
    You Your Yours Our Ours Thou Thee Thy Ye Nothing Everything Nobody Someone Something Christmas Easter
    Company Heaven Hell Lord Majesty Highness Ladyship Lordship Sire League Ghost Spirit Street Road Lane Hall
    House Lodge Abbey Manor Inn Hotel Square Avenue English French German Spanish Italian Russian American British
    Dutch Portuguese Irish Scottish Indian Chinese Japanese African Roman Greek Station Central
    Exit Exeunt Enter Aside Within Flourish Knocking Opens Anon Alarum Sennet Scene Act Prologue Epilogue Chorus
    Vossa Vossas Senhoria Majestade Excelência Excellencia Alteza Mercê Reverendíssima Professor Professora
    Excellency Reverend Heights Grange Capitulo Valley River County Bay Creek Canyon Ranch Mountains Mountain
    Coast Island Islands Desert Forest Woods Springs Falls Harbor Harbour Peninsula Gulf Ocean Strait Channel
    Moor Marsh Heath Downs Vale Serra Sertão Ilha Baía Vila]]):gmatch("[%a\128-\255]+") do
    NAO_NOMES[p] = true
end

-- Teatro: papéis que, como rótulo de fala ("KING.", "NURSE."), são personagem mesmo sendo palavra comum.
local PAPEL_TEATRO = {}
for p in ("King Queen Prince Princess Duke Lord Lady Ghost Nurse Porter Servant Doctor Captain Friar Clown Messenger"):gmatch("%S+") do
    PAPEL_TEATRO[p] = true
end

-- Abreviações seguidas de ponto que não terminam a frase ("Mr. Collins", "D. Glória").
local ABREVIACAO = {}
for p in ("Mr Mrs Ms Dr Drs St Sr Sra Srs Srta Prof Exmo Exma Revd Rev Gen Col Capt Lt Jr"):gmatch("%S+") do
    ABREVIACAO[p] = true
end

-- Palavras que, logo antes de um nome, fazem dele um lugar ("Rio Comprido", "rua dos Inválidos").
local ANTES_LUGAR = {}
for p in ([[rio rua praia largo travessa morro serra ilha lagoa monte lago cabo porto forte bairro engenho
    fazenda river mount lake cape fort port isle island vale sertão chapada ribeirão enseada baía cidade vila
    county valley bay gulf são santa santo san]]):gmatch("[%a\128-\255]+") do ANTES_LUGAR[p] = true end

-- Títulos antes de um nome ("Dona Glória", "Mr. Darcy"): contam como prova de que é gente.
local TITULOS = {}
for p in ([[Sr Sra Srta Dona Dom Dr Dra Seu Sinhá Sinhô Padre Frei Irmã Irmão Tio Tia Capitão Coronel Major Conde
    Condessa Barão Mr Mrs Miss Ms Dr Sir Lady Lord Captain Colonel Uncle Aunt Madame Monsieur Mademoiselle
    Mister Señor D Professor Professora Prof]]):gmatch("[%a\128-\255]+") do TITULOS[p] = true end

-- Pessoas famosas, mitos e obras: aparecem com maiúscula, mas são citações, não personagens.
-- (Se o nome estiver no título do livro, aí é personagem: lendo "Hamlet", Hamlet conta.)
local REFERENCIAS = {}
for p in ([[Shakespeare Hamlet Homero Homer Dante Cervantes Goethe Tolstói Tolstoi Tolstoy Dostoiévski Dostoevsky
    Kafka Proust Joyce Camões Saramago Eça Alencar Drummond Lispector Borges Neruda Nietzsche Kant Descartes
    Platão Plato Aristóteles Aristotle Sócrates Socrates Marx Freud Jung Darwin Einstein Newton Galileu Galileo
    Copérnico Voltaire Rousseau Montaigne Balzac Flaubert Zola Baudelaire Rimbaud Byron Milton Chaucer Dickens
    Austen Wilde Poe Twain Melville Hemingway Faulkner Woolf Orwell Huxley Hitler Stalin Napoleão Napoleon
    Mussolini Lenin César Caesar Cleópatra Cleopatra Churchill Jesus Cristo Christ Maomé Buda Buddha Moisés
    Moses Bíblia Bible Corão Alcorão Torá Mozart Beethoven Bach Wagner Chopin Picasso Michelangelo Rembrandt
    Ulisses Ulysses Odisseu Quixote Fausto Faust Édipo Oedipus Prometeu Prometheus Narciso Vênus Venus Zeus
    Apolo Júpiter Jupiter Satanás Satan Lúcifer Lucifer]]):gmatch("[%a\128-\255]+") do REFERENCIAS[p] = true end

-- Lugares conhecidos (países, cidades, regiões, rios): nunca são personagens.
local LUGARES_CONHECIDOS = {}
for p in ([[Brasil Portugal Angola Moçambique França France Inglaterra England Escócia Scotland Irlanda Ireland
    Espanha Spain Itália Italy Alemanha Germany Prússia Prussia Áustria Austria Suíça Switzerland Holanda Holland
    Bélgica Rússia Russia Polônia Poland Grécia Greece Turquia Turkey Egito Egypt Israel Palestina Pérsia Persia
    Índia India Índias China Japão Japan Argentina Chile Peru México Mexico Cuba América America Europa Europe
    África Africa Ásia Asia Oceania Londres London Paris Roma Rome Lisboa Lisbon Madri Madrid Berlim Berlin Viena
    Vienna Moscou Moscow Petersburgo Atenas Athens Veneza Venice Florença Florence Nápoles Naples Genebra Geneva
    Edimburgo Edinburgh Dublin Amsterdã Amsterdam Praga Prague Jerusalém Jerusalem Babilônia Babylon
    Constantinopla Istambul Cairo Bagdá Baghdad Pequim Tóquio Tokyo Bahia Salvador Recife Pernambuco Minas Goiás
    Amazonas Amazônia Pará Ceará Maranhão Paraná Brasília Olinda Coimbra Porto Sintra Açores Vestfália Brandemburgo
    Baviera Bavaria Saxônia Normandia Normandy Provença Mediterrâneo Mediterranean Atlântico Atlantic Pacífico
    Pacific Tâmisa Thames Sena Seine Nilo Nile Danúbio Danube Reno Rhine Alpes Alps Andes Sibéria Siberia Saara
    Sahara Ártico Arctic Oxford Cambridge Manhattan Chicago Boston Potsdam Itaparica Brotas]]):gmatch("[%a\128-\255]+") do
    LUGARES_CONHECIDOS[p] = true
end

-- Cidades conhecidas (GeoNames, CC-BY 4.0; 50 mil+ habitantes): nome assim só vira personagem com prova
-- (fala, título, verbo de pessoa). Nunca exclui sozinho: Elizabeth, Charlotte, Paris e Hamilton são cidades.
local okCid, CIDADES = pcall(require, "yomimon_cities")
CIDADES = okCid and type(CIDADES) == "table" and CIDADES or {}

-- Palavras que, logo depois de um nome, fazem dele um lugar ("Baker Street", "Rua do Ouvidor").
local DEPOIS_LUGAR = {}
for p in ([[Street Road Lane Square Avenue Hall House Lodge Park Abbey Manor Castle Court Place Bridge Inn
    Hotel Hill Heights Grange Rua Avenida Praça Largo Travessa Estrada Fazenda Engenho
    Valley Valleys River Rivers County Bay Creek Canyon Ranch Mountains Mountain Range Coast Island Islands
    Desert Forest Woods Plains Springs Falls Harbor Harbour Peninsula Gulf Ocean Strait Channel Ridge Moor
    Moors Marsh Heath Downs]]):gmatch("[%a\128-\255]+") do DEPOIS_LUGAR[p] = true end

-- Verbos que, logo depois de um nome, mostram que ele é gente ("Capitu olhou", "Victor fled").
local VERBO_PESSOA = {}
for p in ([[disse falou perguntou respondeu gritou murmurou sussurrou olhou sorriu riu chorou pensou sentiu
    suspirou voltou saiu entrou chegou partiu morreu matou beijou abraçou correu levantou sentou parou viu ouviu
    lembrou acordou dormiu tremeu hesitou insistiu continuou pegou segurou abriu fechou quis sabia amava odiava
    said asked replied cried shouted whispered murmured looked smiled laughed wept thought felt sighed turned
    walked ran came went left returned died killed kissed sat stood saw heard remembered woke slept trembled
    hesitated nodded frowned took gave held opened closed wanted knew loved hated]]):gmatch("[%a\128-\255]+") do
    VERBO_PESSOA[p] = true
end

-- Primeira pessoa: muitas dessas palavras = narrador que fala de si.
local EU = {}
for p in ("eu me mim comigo meu minha meus minhas i my mine myself"):gmatch("%S+") do EU[p] = true end
-- Gênero de quem narra (português): "eu estava cansada", "fiquei sozinho", "sou mulher".
local COPULA_EU = {}      -- só existem na primeira pessoa
for p in ("sou estou fiquei fui estive senti sinto"):gmatch("%S+") do COPULA_EU[p] = true end
local COPULA_TALVEZ = {}  -- primeira ou terceira pessoa: só contam depois de "eu"/"me"
for p in ("era estava ficava seria sentia"):gmatch("%S+") do COPULA_TALVEZ[p] = true end
local INTENSIFICA = {}
for p in ("muito tão meio bem mais ainda um uma toda todo completamente"):gmatch("%S+") do INTENSIFICA[p] = true end
local GENERO_PALAVRA = {}
for p in ("mulher moça menina senhora velha nova sozinha bonita linda feia viúva grávida tola louca"):gmatch("%S+") do GENERO_PALAVRA[p] = "f" end
for p in ("homem rapaz menino senhor velho novo sozinho bonito lindo feio viúvo tolo louco"):gmatch("%S+") do GENERO_PALAVRA[p] = "m" end

local function generoDe(w)
    if GENERO_PALAVRA[w] then return GENERO_PALAVRA[w] end
    if #w < 5 then return nil end
    if w:find("ada$") or w:find("ida$") or w:find("osa$") or w:find("inha$") then return "f" end
    if w:find("ado$") or w:find("ido$") or w:find("oso$") or w:find("inho$") then return "m" end
end

-- Expressões feitas que enganariam a contagem ("morrer de rir" não é sobre morte).
local EXPRESSOES = {
    "morr%a* de rir", "mort[oa]s? de cansaço", "mort[oa]s? de fome", "mort[oa]s? de vergonha", "morr%a* de medo",
    "mar de gente", "mar de rosas", "guerra fria", "pelo amor de deus", "meu deus", "graças a deus",
    "deus me livre", "ao deus dará", "tempo todo", "de vez em quando", "dead tired", "oh my god",
    "scared to death", "bored to death", "dying to", "sea of faces", "cold war", "for god's sake",
    "thank god", "god knows", "all the time", "from time to time", "in no time", "heart of gold",
}

--- Texto em minúsculas sem as expressões feitas.
function M.limpar(texto)
    local t = texto:lower()
    for _, e in ipairs(EXPRESSOES) do t = t:gsub(e, " ") end
    return t
end

local DIARIO_MAX = 150
M.ESQUECIMENTO_TEMAS = 0.998  -- por página (meia-vida ~350 páginas, a mesma dos traços)
local TRECHO_PAGINAS = 25   -- capítulo enorme (ou livro sem sumário): a cada 25 páginas conta como trecho novo

local function sorteia(lista, sorteio)
    return lista[(sorteio or math.random)(#lista)]
end

local function garantir(s)
    s.temas = s.temas or {}
    s.livros = s.livros or {}
    s.diario = s.diario or {}
end

--- Escreve no diário (o mais novo fica no fim).
function M.anotar(s, agora, texto)
    garantir(s)
    texto = (Voz.resolver(texto, s))  -- o diário fica escrito com o jeito dela no dia
    table.insert(s.diario, { t = agora, texto = texto })
    while #s.diario > DIARIO_MAX do table.remove(s.diario, 1) end
end

--- Os dois temas mais fortes (nome, pontos), ou nil.
function M.temasFortes(s)
    local lista = {}
    for tema, pts in pairs(s.temas or {}) do lista[#lista + 1] = { tema, pts } end
    table.sort(lista, function(a, b) return a[2] > b[2] end)
    return lista[1], lista[2]
end

--- Ela está dividida entre dois temas opostos fortes?
function M.ambivalente(s)
    local a, b = M.temasFortes(s)
    if not (a and b) or b[2] < 15 then return nil end
    if OPOSTOS[a[1]] == b[1] and b[2] >= a[2] * 0.6 then return a[1], b[1] end
end

--- Personagens de um livro, mais citados primeiro (só quem aparece pelo menos 3 vezes). Cada um:
-- { nome, vezes, falas, capitulos, protagonista, formas (todos os nomes da pessoa) }.
-- Desde 27/10/2026, pelas evidências de L.nomes (personagensNovo); livro terminado guarda só a lista final.
-- Livros lidos antes disso (sem L.nomes) seguem a regra antiga, abaixo.
function M.personagensInfo(s, livro)
    local L = livro and s.livros and s.livros[livro]
    if not L then return {} end
    if L.personagens_fim then return L.personagens_fim end  -- terminado (numa releitura, até terminar de novo)
    if L.nomes then return (M._personagensNovo(L, livro)) end
    -- regra antiga: "Sherlock Holmes": o nome e o sobrenome viram uma pessoa só (a forma mais citada)
    local apelido = {}
    for b, a in pairs(L.sobrenome or {}) do
        if (L.pers[a] or 0) >= (L.pers[b] or 0) then apelido[b] = a else apelido[a] = b end
    end
    local total = {}
    for nome, c in pairs(L.pers or {}) do
        nome = apelido[nome] or nome
        if (L.lugares or {})[nome] == nil or (L.lugares[nome] < (L.pers[nome] or 0)) then
            total[nome] = (total[nome] or 0) + c
        end
    end
    local n_caps, caps_de = 0, {}
    for _, C in pairs(L.caps or {}) do
        n_caps = n_caps + 1
        for nome in pairs(C.pers or {}) do caps_de[nome] = (caps_de[nome] or 0) + 1 end
    end
    local lista = {}
    for nome, c in pairs(total) do
        local prova = ((L.prova or {})[nome] or 0) + ((L.falou or {})[nome] or 0)
        local paginas = (L.pags or {})[nome] or 0
        -- suspeito de não ser gente (cidade conhecida, ou costuma vir com artigo: "the Nautilus",
        -- "os Tupinambás"): só com prova, nunca só por aparecer muito
        local suspeito = CIDADES[nome] or ((L.coisa or {})[nome] or 0) * 2 >= c
        if (c >= 3 and prova >= 1) or (not suspeito and c >= 5 and paginas >= 3) then
            lista[#lista + 1] = {
                nome = nome, vezes = c, falas = (L.falou or {})[nome] or 0, capitulos = caps_de[nome] or 0,
                protagonista = n_caps >= 3 and (caps_de[nome] or 0) >= n_caps * 0.6, formas = { nome },
            }
        end
    end
    table.sort(lista, function(a, b) return a.vezes > b.vezes end)
    return lista
end

--- As palavras marcantes de um livro (Etapa 5): 3+ vezes nele e pelo menos uma depois de artigo, das mais
-- fortes para as mais fracas, menos as que também estão no vocabulário de 2 ou mais outros livros dela
-- (essas são dela, não do livro). Até `n`.
function M.marcantes(s, livro, n)
    local L = livro and s.livros and s.livros[livro]
    if not (L and L.vocab) then return {} end
    local outros = {}
    for nome, O in pairs(s.livros) do
        if nome ~= livro and O.vocab then for w in pairs(O.vocab) do outros[w] = (outros[w] or 0) + 1 end end
    end
    local lista = {}
    for w, c in pairs(L.vocab) do
        if c >= M.MARCANTE_MIN and ((L.vocab_art or {})[w] or 0) >= 1 and (outros[w] or 0) < 2 and not OFENSIVAS[w] then
            lista[#lista + 1] = { w, forca(L, w) }
        end
    end
    table.sort(lista, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    local out = {}
    for i = 1, math.min(n or 10, #lista) do out[i] = lista[i][1] end
    return out
end

function M.personagens(s, livro, n)
    local out = {}
    for i, p in ipairs(M.personagensInfo(s, livro)) do
        if i > (n or 5) then break end
        out[i] = p.nome
    end
    return out
end

local function maiusculo(w)
    local b1, b2 = w:byte(1), w:byte(2)
    if not b1 then return false end
    if b1 >= 65 and b1 <= 90 then return true end
    return b1 == 195 and b2 and b2 >= 128 and b2 <= 158  -- À…Þ em UTF-8
end

local function somar(t, k, v) t[k] = (t[k] or 0) + (v or 1) end

-- Nomes com evidências (desde 27/10/2026) --------------------------------------------------------
-- Cada página anota os nomes (também os de várias palavras: "Petra Cotes", "Paulo Afonso") e as pistas
-- que vieram com cada um, por regra. Quem é gente, quem é lugar e quem é a mesma pessoa só se decide na
-- consulta, com as evidências do livro inteiro (personagensNovo). Protótipo e medições:
-- ferramentas/experimentos/personagens/.

local function emMinusculas(w)
    return (w:lower():gsub("\195([\128-\158])", function(c) return "\195" .. string.char(c:byte() + 32) end))
end

-- título antes do nome → gênero ("m", "f" ou false); comparado em minúsculas ("madama Carlota", "lady Madeline")
local TITULO_GENERO = {}
for p in ([[seu sinhô dom sr senhor doutor dr padre frei coronel capitão tenente sargento cabo major general comandante
    tio compadre mestre professor conselheiro barão conde marquês visconde rei príncipe sir mr mister monsieur lord
    captain colonel doctor uncle king prince count duke father brother commander master lieutenant sergeant inspector
    reverend]]):gmatch("%S+") do TITULO_GENERO[p] = "m" end
for p in ([[dona sinhá sra srta senhora doutora dra madama madame irmã tia comadre professora baronesa condessa marquesa
    viscondessa rainha princesa lady mrs miss mademoiselle aunt queen princess countess duchess mother sister]]):gmatch("%S+") do
    TITULO_GENERO[p] = "f"
end
TITULO_GENERO.d, TITULO_GENERO.ms = false, "f"
local INTERJEICOES = {}
for p in ("Ah Oh Ó Ai Eh Ei Olá Oi Hein Hem Ui Psiu Oba Opa Ué Uai Arre Ora Hum Puxa Credo Ufa Ha Ho Hey Alas"):gmatch("%S+") do
    INTERJEICOES[p] = true
end
local CONECTOR_NOME = {}
for p in ("de da do das dos del la los las"):gmatch("%S+") do CONECTOR_NOME[p] = true end
local FALA_EXTRA, GENTE_EXTRA = {}, {}
for p in ([[retrucou replicou explicou indagou berrou bradou declarou concordou protestou admitiu prosseguiu completou
    interrompeu acudiu tornou observou ponderou atalhou volveu dissera falara gemeu queixou]]):gmatch("%S+") do FALA_EXTRA[p] = true end
for p in ([[mandou contou atendeu achou trocou observava comia comeu bebia bebeu chegara sorria chorava olhava pensava
    sentia dizia queria gostava amou casou nasceu rezou rezava cantou cantava dançou escreveu leu beijava abraçava fumava
    fumou dormia acordava sonhou sonhava piscou corou gemia soluçou tossiu ajoelhou virou aproximou despediu agradeceu
    prometeu jurou decidiu resolveu esperou esperava calou calava ouvia escutava lia escrevia caminhou fugiu
    voltara saíra entrara morrera nascera]]):gmatch("%S+") do GENTE_EXTRA[p] = true end
local PESSOA_NOME = {}
for p in ([[homem mulher moça moço rapaz menina menino velho velha senhor senhora sargento tenente coronel padre médico
    médica datilógrafa cartomante preso criada criado escravo escrava viúva viúvo noiva noivo marido esposa filho filha
    pai mãe irmão irmã tio tia avô avó amigo amiga cigano cigana patrão patroa]]):gmatch("%S+") do PESSOA_NOME[p] = true end
local LUGAR_ANTES = {}  -- "cidade de Recife", "rua do Ouvidor", "estado de Sergipe" ("fazenda de Fulano" é de alguém)
for p in ([[estado cidade vila povoado município rio serra rua praça largo bairro sertão capital porto ilha lagoa morro
    travessa avenida aldeia arraial chapada ribeirão enseada baía praia cabo forte river mount lake cape fort port isle
    island valley bay gulf county]]):gmatch("%S+") do LUGAR_ANTES[p] = true end
local SANTO = { ["são"] = true, santo = true, santa = true, san = true }
local ESTADOS_BR = {}
for p in ([[Acre Alagoas Amapá Amazonas Bahia Ceará Goiás Maranhão Pará Paraíba Paraná Pernambuco Piauí Rondônia Roraima
    Sergipe Tocantins]]):gmatch("%S+") do ESTADOS_BR[p] = true end
local ESTADOS_COMPOSTOS = { ["Espírito Santo"] = true, ["Mato Grosso"] = true, ["Minas Gerais"] = true,
    ["Rio de Janeiro"] = true, ["Rio Grande do Norte"] = true, ["Rio Grande do Sul"] = true, ["Santa Catarina"] = true,
    ["São Paulo"] = true, ["Distrito Federal"] = true }
local PREPOSICAO = {}
for p in ("de da do em para com por in at of to from with by"):gmatch("%S+") do PREPOSICAO[p] = true end

-- Peso de cada regra: a favor de ser gente, de ser lugar, e contra ser nome (palavra comum, citação)
local PESO_GENTE = { titulo = 2, fala = 2, verbo = 1, vocativo = 1.5, aposto = 1.5 }
local PESO_LUGAR = { lugar = 2, rota = 2, santo = 1, em = 0.5 }
local NOMES_FORMAS_MAX = 150     -- formas guardadas por livro enquanto lê (as de 1 vez saem primeiro)
local MIN_MENCOES = 3

local function baseVerbo(w)
    return (emMinusculas(w):gsub("%-[%a\128-\255]+$", ""))  -- "levantou-se" → "levantou"
end
local function ehFala(w) local b = baseVerbo(w) return VERBO_FALA[b] or FALA_EXTRA[b] end
local function ehGente(w) local b = baseVerbo(w) return VERBO_PESSOA[b] or GENTE_EXTRA[b] or ehFala(w) end

local function candidatoNome(tk)
    local w = tk.w
    return maiusculo(w) and #w >= 2 and not w:find("^[%u%p]+$") and not NAO_NOMES[w] and not INTERJEICOES[w]
        and TITULO_GENERO[emMinusculas(w)] == nil and not ABREVIACAO[w]  -- "St." de St. John não é nome
end

--- Nomes de uma página, com as pistas de cada um (toks: as palavras de M.sinais).
-- Devolve { [forma] = { n, ini, meio, ev = { regra = vezes }, gen = { m, f } } } e as frases com
-- nomes em que um é o começo do outro ("Macabéa, a minha querida Maca"), para não juntar duas pessoas.
local function nomesDaPagina(toks, dialogo)
    local nomes, juntos = {}, {}
    local por_frase, frase = {}, 0
    local i = 1
    while i <= #toks do
        local tk = toks[i]
        if tk.inicio then frase = frase + 1 end
        if candidatoNome(tk) then
            local j = i
            while j - i < 5 and not toks[j].pont do  -- junta "Petra Cotes", "Olímpico de Jesus Moreira Chaves"
                local k = j + 1
                while k <= #toks and CONECTOR_NOME[toks[k].w] and not toks[k].pont and not toks[k].abre do k = k + 1 end
                local prox = toks[k]
                if prox and not prox.abre and not prox.inicio and candidatoNome(prox) and prox.w ~= toks[j].w
                        and (k == j + 1 or not toks[k - 1].pont) then
                    j = k
                else
                    break
                end
            end
            local partes = {}
            for k = i, j do partes[#partes + 1] = toks[k].w end
            local forma = table.concat(partes, " ")
            local d = nomes[forma] or { n = 0, ini = 0, meio = 0, ev = {}, gen = {} }
            nomes[forma] = d
            d.n = d.n + 1
            if tk.inicio then d.ini = d.ini + 1 else d.meio = d.meio + 1 end
            local p, pp, n1, n2, n3 = toks[i - 1], toks[i - 2], toks[j + 1], toks[j + 2], toks[j + 3]
            local ult = toks[j]
            local colado_antes = p and not p.pont and not tk.abre
            local colado_depois = n1 and not ult.pont and not n1.abre
            local pl = p and emMinusculas(p.w)
            -- título antes ("madama Carlota", "D. Plácida", "Seu Nestor")
            if p and TITULO_GENERO[pl] ~= nil and not tk.abre and (not p.pont or (p.ponto and #p.w <= 4)) then
                somar(d.ev, "titulo")
                if TITULO_GENERO[pl] then somar(d.gen, TITULO_GENERO[pl]) end
            end
            -- quem fala, ou faz coisa de gente logo depois do nome
            -- ("said the Hatter", "disse o Paulo": o verbo de fala vem antes do artigo)
            local artigo_antes = colado_antes and (pl == "the" or pl == "o" or pl == "a") and pp and not pp.pont
            if (colado_antes and ehFala(p.w)) or (colado_depois and ehFala(n1.w)) or (artigo_antes and ehFala(pp.w)) then
                somar(d.ev, "fala")
            elseif colado_depois and ehGente(n1.w) and not (colado_antes and PREPOSICAO[pl]) then
                somar(d.ev, "verbo")
            end
            -- chamado pelo nome numa fala: "– Maca, o quê?", "Logo ela, Maca?"
            local fim = ult.bruto:sub(-1)
            if (tk.inicio and dialogo > 0 and (fim == "," or fim == "?" or fim == "!") and not (n1 and candidatoNome(n1)))
                    or (p and p.bruto:sub(-1) == "," and (fim == "?" or fim == "!")) then
                somar(d.ev, "vocativo")
            end
            -- aposto: "Carlota, a cartomante" (não "Amaranta, o coronel Aureliano", que é lista)
            if fim == "," and n1 and n2 and not n1.pont and (n1.w == "o" or n1.w == "a" or n1.w == "um" or n1.w == "uma")
                    and PESSOA_NOME[emMinusculas(n2.w)] and not (n3 and not n2.pont and maiusculo(n3.w)) then
                somar(d.ev, "aposto")
                somar(d.gen, (n1.w == "o" or n1.w == "um") and "m" or "f")
            end
            -- artigo antes: só gênero ("a Bahia" também leva artigo)
            if colado_antes and (pl == "o" or pl == "a") then somar(d.gen, pl == "o" and "m" or "f") end
            -- lugar
            if colado_antes and pp and not pp.pont and CONECTOR_NOME[pl] and LUGAR_ANTES[emMinusculas(pp.w)] then
                somar(d.ev, "lugar")
            elseif colado_antes and LUGAR_ANTES[pl] then
                somar(d.ev, "lugar")
            elseif colado_depois and DEPOIS_LUGAR[n1.w] then
                somar(d.ev, "lugar")
            elseif colado_antes and (pl == "de" or pl == "from") and colado_depois and (n1.w == "até" or n1.w == "to") then
                somar(d.ev, "rota")
            elseif colado_antes and SANTO[pl] then
                somar(d.ev, "santo")
            elseif colado_antes and PREP_LUGAR[pl] then
                somar(d.ev, "em")
            end
            if colado_antes and (pl == "the" or pl == "os" or pl == "as") then somar(d.ev, "coisa") end
            por_frase[frase] = por_frase[frase] or {}
            por_frase[frase][#por_frase[frase] + 1] = forma
            i = j + 1
        else
            i = i + 1
        end
    end
    -- mesma frase, um nome é o começo do outro ("Macabéa" e "Maca"): conta, para não juntar duas pessoas
    for _, fs in pairs(por_frase) do
        for a = 1, #fs do
            for b = 1, #fs do
                local x, y = fs[a], fs[b]
                if x ~= y and #x < #y and y:sub(1, #x) == x then somar(juntos, x .. "\t" .. y) end
            end
        end
    end
    return nomes, juntos
end

local function palavrasDe(forma)
    local out = {}
    for w in forma:gmatch("%S+") do if not CONECTOR_NOME[w] then out[#out + 1] = w end end
    return out
end

--- Guarda os nomes da página no livro (chamado por M.digerir).
local function guardarNomes(L, sinal, pag)
    L.nomes, L.caixa, L.juntos = L.nomes or {}, L.caixa or {}, L.juntos or {}
    L.nomes_versao = (L.nomes_versao or 0) + 1
    local novas = {}
    for forma, d in pairs(sinal.nomes or {}) do
        local N = L.nomes[forma]
        if not N then
            N = { n = 0, meio = 0, ev = {}, gen = {}, ex = {} }
            L.nomes[forma] = N
            novas[#novas + 1] = forma
        end
        N.n, N.meio = N.n + d.n, N.meio + d.meio
        for r, c in pairs(d.ev) do
            somar(N.ev, r, c)
            N.ex[r] = N.ex[r] or pag  -- a página da primeira vez, para conferir depois
        end
        for g, c in pairs(d.gen) do somar(N.gen, g, c) end
        for _, w in ipairs(palavrasDe(forma)) do
            local cx = L.caixa[w] or { M = 0, m = 0 }
            L.caixa[w] = cx
            if d.meio > 0 then cx.M = cx.M + d.meio end
        end
    end
    -- nome novo de uma palavra: quem estava na mesma página (para achar apelido que aparece logo depois do
    -- nome: "Macabéa" → "Maca")
    for _, forma in ipairs(novas) do
        if not forma:find(" ") then
            local viz = {}
            for outra in pairs(sinal.nomes) do
                if outra ~= forma and #viz < 5 and #outra > #forma then viz[#viz + 1] = outra end
            end
            if #viz > 0 then L.nomes[forma].viz = viz end
        end
    end
    -- quantas vezes cada palavra de nome aparece em minúscula ("quanto", "seu")
    for w, cx in pairs(L.caixa) do
        local c = (sinal.minus or {})[emMinusculas(w)]
        if c then cx.m = cx.m + c end
    end
    for par, c in pairs(sinal.juntos_prefixo or {}) do somar(L.juntos, par, c) end
    -- limpeza (a cada 10 páginas): palavra que só apareceu no começo da frase e que o livro escreve mais em
    -- minúscula ("É", "Pois", "Quanto") sai; a contagem de maiúsculas fica só para as palavras dos nomes
    if L.nomes_versao % 10 == 0 then
        for forma, N in pairs(L.nomes) do
            local cx = L.caixa[forma:match("^%S+")]
            if N.meio == 0 and cx and cx.m >= 2 and cx.m > cx.M then L.nomes[forma] = nil end
        end
        local usadas = {}
        for forma in pairs(L.nomes) do for _, w in ipairs(palavrasDe(forma)) do usadas[w] = true end end
        for w in pairs(L.caixa) do if not usadas[w] then L.caixa[w] = nil end end
        for par in pairs(L.juntos) do
            local a, b = par:match("^(.-)\t(.*)$")
            if not (L.nomes[a] and L.nomes[b]) then L.juntos[par] = nil end
        end
    end
    -- poda: o estado salvo não cresce sem fim
    local n = 0
    for _ in pairs(L.nomes) do n = n + 1 end
    if n > NOMES_FORMAS_MAX then
        for forma, N in pairs(L.nomes) do
            if N.n <= 1 and not next(N.ev) then L.nomes[forma] = nil end
        end
    end
end

local cache_pers = setmetatable({}, { __mode = "k" })

--- Personagens de um livro pelas evidências (L.nomes). Devolve a mesma lista de M.personagensInfo, com
-- `formas` (todos os nomes da pessoa) e `lugares` à parte.
local function personagensNovo(L, livro)
    local c = cache_pers[L]
    if c and c.pags == L.paginas and c.n == L.nomes_versao then return c.lista, c.lugares end
    local N, CX = L.nomes, L.caixa or {}
    local titulo = livro and emMinusculas(livro) or ""
    -- as palavras de cada nome, separadas uma vez só: dentro dos laços de baixo (nome × nome), separar de novo
    -- a cada par era quase todo o tempo da consulta num livro longo (Moby Dick, página 700: 250 ms no Mac)
    local PW, COM = {}, {}
    local function pw(f)
        local p = PW[f]
        if not p then p = palavrasDe(f); PW[f] = p end
        return p
    end
    local function comConectores(f)  -- todas as palavras, com "de", "da"
        local ws = COM[f]
        if not ws then
            ws = {}
            for w in f:gmatch("%S+") do ws[#ws + 1] = w end
            COM[f] = ws
        end
        return ws
    end
    -- 1. forma que só aparece no começo da frase vale se o livro escreve a primeira palavra mais com maiúscula
    --    no meio da frase do que em minúscula ("Quanto a mim", "Talvez Cotrim" → "Cotrim"); senão sai a palavra
    local function comum(w)
        local cx = CX[w] or { M = 0, m = 0 }
        return cx.M == 0 or cx.m > cx.M
    end
    local F = {}
    for forma, d in pairs(N) do
        local alvo = forma
        local cx1 = not forma:find(" ") and CX[forma]
        if cx1 and cx1.m >= 3 and cx1.m > 2 * cx1.M then
            alvo = nil  -- o livro usa a palavra quase sempre em minúscula ("Já disse…"): não é nome
        elseif d.meio == 0 then
            local ps = {}
            for w in forma:gmatch("%S+") do ps[#ps + 1] = w end
            while #ps > 0 and (comum(ps[1]) or CONECTOR_NOME[ps[1]]) do table.remove(ps, 1) end
            alvo = #ps > 0 and table.concat(ps, " ") or nil
        end
        if alvo then
            local e = F[alvo]
            if not e then
                e = { n = 0, meio = 0, ev = {}, gen = {}, viz = {} }
                F[alvo] = e
            end
            e.n, e.meio = e.n + d.n, e.meio + d.meio
            for r, v in pairs(d.ev) do somar(e.ev, r, v) end
            for g, v in pairs(d.gen) do somar(e.gen, g, v) end
            for _, v in ipairs(d.viz or {}) do e.viz[v] = true end
        end
    end
    -- 2. pistas do livro inteiro: palavra comum, gente famosa citada, lugar conhecido
    for forma, e in pairs(F) do
        if not forma:find(" ") then
            local cx = CX[forma]
            if cx and cx.m >= 3 and cx.m >= cx.M then e.ev.comum = 2 end
            if REFERENCIAS[forma] and not titulo:find(emMinusculas(forma), 1, true) then e.ev.citacao = 2 end
            if LUGARES_CONHECIDOS[forma] or ESTADOS_BR[forma] then e.lugar_lista = 1.5
            elseif CIDADES[forma] then e.lugar_lista = 0.5 end
        elseif ESTADOS_COMPOSTOS[forma] then
            e.lugar_lista = 2
        else
            local todas = true  -- "Jesus Cristo": todas as palavras são de gente famosa citada
            for _, w in ipairs(pw(forma)) do if not REFERENCIAS[w] then todas = false end end
            if todas and not titulo:find(emMinusculas(forma), 1, true) then e.ev.citacao = 2 end
        end
    end
    -- 3. a mesma pessoa
    local grupo, compostas = {}, {}
    for forma in pairs(F) do
        grupo[forma] = forma
        if forma:find(" ") then compostas[#compostas + 1] = forma end
    end
    table.sort(compostas, function(a, b) return #pw(a) < #pw(b) or (#pw(a) == #pw(b) and a < b) end)
    local function raiz(f) while grupo[f] ~= f do f = grupo[f] end return f end
    -- "Olímpico de Jesus" é o começo de um só nome mais longo ("… Moreira Chaves"): a mesma pessoa
    for _, c1 in ipairs(compostas) do
        local p1 = pw(c1)
        local j1 = table.concat(p1, " ")
        local raizes, alvo = {}, nil
        for _, c2 in ipairs(compostas) do
            local p2 = pw(c2)
            if #p2 > #p1 and table.concat(p2, " ", 1, #p1) == j1 then
                local r = raiz(c2)
                if not raizes[r] then
                    raizes[r] = true
                    if alvo == nil then alvo = r else alvo = false end
                end
            end
        end
        if alvo then grupo[alvo] = raiz(c1) end
    end
    -- nome solto que é o primeiro (ou o último, sem "de" antes) de um só nome composto que aparece 2+ vezes
    local vezes_familia = {}
    for _, c1 in ipairs(compostas) do somar(vezes_familia, raiz(c1), F[c1].n) end
    for forma in pairs(F) do
        if not forma:find(" ") then
            local alvo, varios = nil, false
            for _, c1 in ipairs(compostas) do
                local p1, ws = pw(c1), comConectores(c1)
                if (p1[1] == forma or (p1[#p1] == forma and not CONECTOR_NOME[ws[#ws - 1]]))
                        and vezes_familia[raiz(c1)] >= 2 then
                    local r = raiz(c1)
                    if alvo and alvo ~= r then varios = true end
                    alvo = alvo or r
                end
            end
            if alvo and not varios then grupo[forma] = alvo end
        end
    end
    -- apelido: o começo de um nome, que apareceu pela primeira vez perto dele ("Macabéa" → "Maca")
    for forma, e in pairs(F) do
        if grupo[forma] == forma and not forma:find(" ") and #forma >= 3 then
            for outra in pairs(F) do
                local p1 = pw(outra)[1]
                if outra ~= forma and p1 and #p1 > #forma and p1:sub(1, #forma) == forma
                        and (e.viz[outra] or F[outra].viz[forma])
                        and ((L.juntos or {})[forma .. "\t" .. outra] or 0) < 2 then
                    grupo[forma] = raiz(outra)
                    break
                end
            end
        end
    end
    -- 4. tipo de cada pessoa ou coisa, com as pistas de todos os nomes dela
    local G = {}
    for forma, e in pairs(F) do
        local r = raiz(forma)
        local g = G[r]
        if not g then
            g = { formas = {}, n = 0, gente = 0, lugar = 0, comum = 0, citacao = 0, falas = 0 }
            G[r] = g
        end
        g.formas[#g.formas + 1] = forma
        g.n = g.n + e.n
        for regra, v in pairs(e.ev) do
            if PESO_GENTE[regra] then g.gente = g.gente + PESO_GENTE[regra] * v end
            if PESO_LUGAR[regra] then g.lugar = g.lugar + PESO_LUGAR[regra] * v end
        end
        g.lugar = g.lugar + (e.lugar_lista or 0)
        g.coisa = (g.coisa or 0) + 0.5 * (e.ev.coisa or 0)  -- "the Nautilus": só pesa contra quem nunca fala
        g.comum = g.comum + (e.ev.comum or 0)
        g.citacao = g.citacao + (e.ev.citacao or 0)
        g.falas = g.falas + (e.ev.fala or 0)
    end
    local n_caps, caps_de = 0, {}
    for _, C in pairs(L.caps or {}) do
        n_caps = n_caps + 1
        for nome in pairs(C.pers or {}) do caps_de[nome] = (caps_de[nome] or 0) + 1 end
    end
    local lista, lugares = {}, {}
    for _, g in pairs(G) do
        local contra = g.lugar + g.comum + g.citacao + (g.falas == 0 and g.coisa or 0)
        table.sort(g.formas, function(a, b) return F[a].n > F[b].n or (F[a].n == F[b].n and #a > #b) end)
        local nome = g.formas[1]
        if g.lugar >= 2 and g.lugar > g.gente then
            lugares[#lugares + 1] = { nome, g.n }
        elseif g.citacao == 0 and g.comum <= g.gente and g.gente >= 2 and g.gente >= 2 * contra and g.n >= MIN_MENCOES then
            local caps = 0
            for _, f in ipairs(g.formas) do caps = math.max(caps, caps_de[f] or 0) end
            lista[#lista + 1] = { nome = nome, vezes = g.n, falas = g.falas, capitulos = caps, formas = g.formas,
                                  protagonista = n_caps >= 3 and caps >= n_caps * 0.6 }
        end
    end
    table.sort(lista, function(a, b) return a.vezes > b.vezes or (a.vezes == b.vezes and a.nome < b.nome) end)
    table.sort(lugares, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    cache_pers[L] = { pags = L.paginas, n = L.nomes_versao, lista = lista, lugares = lugares }
    return lista, lugares
end
M._personagensNovo = personagensNovo

--- Livro terminado: guarda só a lista final de personagens e lugares e apaga as evidências (o estado salvo
-- não cresce a cada livro). Numa releitura, as evidências recomeçam.
function M.congelarNomes(L, livro)
    if not L or not L.nomes then return end
    local lista, lugares = personagensNovo(L, livro)
    L.personagens_fim, L.lugares_fim = lista, lugares
    L.nomes, L.caixa, L.juntos, L.nomes_versao, L.aura = nil, nil, nil, nil, nil
end

--- Lê os sinais de uma página: temas, eventos, clima, personagens, lugares, citações, quem fala,
-- provas de que um nome é gente, primeira pessoa e tamanho das palavras.
-- livro (opcional): nomes que estão no título do livro nunca são tratados como citação.
-- capitulo (opcional): se a página começa com o título do capítulo ("XXV Na Tijuca Nisto…"), as palavras do
-- título e a primeira depois dele contam como começo de frase (só para os nomes).
function M.sinais(texto, livro, capitulo)
    local sinal = { temas = {}, eventos = {}, assuntos = {}, clima = 0, pers = {}, pers_inicio = {}, lugares = {}, falou = {},
                    pares = {}, coisa = {}, refs = {}, prova = {}, eu = 0, palavras = 0, letras = 0, genero = {}, frases = 0,
                    dialogo = 0 }
    local limpo = M.limpar(texto)
    local pt = emPortugues(limpo)
    sinal.pt = pt
    local hits_evento, hits_tema, hits_assunto = {}, {}, {}
    local function assunto(as, palavra)
        hits_assunto[as] = hits_assunto[as] or {}
        hits_assunto[as][palavra] = true
        somar(sinal.assuntos, as)
    end
    local minusculas, n = {}, 0
    for palavra in limpo:gmatch("[%a\128-\255]+") do
        n = n + 1
        minusculas[n] = palavra
        if EU[palavra] then sinal.eu = sinal.eu + 1 end
        sinal.letras = sinal.letras + #palavra - select(2, palavra:gsub("[\128-\191]", ""))
        local t = temaDe(palavra, pt)
        if t then
            hits_tema[t] = hits_tema[t] or {}
            hits_tema[t][palavra] = true
            somar(sinal.temas, t)
        end
        local ev = eventoDe(palavra, pt)
        if ev then
            hits_evento[ev] = hits_evento[ev] or {}
            hits_evento[ev][palavra] = true
            somar(sinal.eventos, ev)
        end
        local as = assuntoDe(palavra, pt)
        if as then assunto(as, palavra) end
        if not LEXICO[pt and "pt" or "en"] then
            local cl = climaDe(palavra, pt)
            if cl then sinal.clima = sinal.clima + cl end
        end
    end
    sinal.palavras = n
    local nota = M.sentimento(limpo, pt)
    if nota then
        sinal.sentimento = nota
        local cal = M.CLIMA_CALIBRACAO and M.CLIMA_CALIBRACAO[pt and "pt" or "en"]
        sinal.clima = cal and (nota - cal.mediana) / cal.meia_faixa or nota
    end
    -- gênero de quem diz "eu" (português)
    for i = 1, n - 1 do
        local w = minusculas[i]
        local eu_antes = i > 1 and (minusculas[i - 1] == "eu" or minusculas[i - 1] == "me")
        if COPULA_EU[w] or (COPULA_TALVEZ[w] and eu_antes) then
            local j = i + 1
            while j < n and INTENSIFICA[minusculas[j]] do j = j + 1 end
            local g = generoDe(minusculas[j])
            if g then somar(sinal.genero, g) end
        end
    end
    -- evento só conta com 2+ palavras diferentes do grupo (ou 3+ ocorrências); assunto também
    for ev, c in pairs(sinal.eventos) do
        local diferentes = 0
        for _ in pairs(hits_evento[ev]) do diferentes = diferentes + 1 end
        if diferentes < 2 and c < 3 then sinal.eventos[ev] = nil end
    end
    frasesDeAssunto(minusculas, n, assunto)
    for as, c in pairs(sinal.assuntos) do
        local diferentes = 0
        for _ in pairs(hits_assunto[as]) do diferentes = diferentes + 1 end
        if diferentes < 2 and c < 3 then sinal.assuntos[as] = nil end
    end
    -- tema: uma palavra genérica solta ("time", "old", "night") não faz assunto
    for t, c in pairs(sinal.temas) do
        local diferentes, especifica = 0, false
        for p in pairs(hits_tema[t]) do
            diferentes = diferentes + 1
            if not generica(p) then especifica = true end
        end
        if not especifica and diferentes < 2 and c < 3 then sinal.temas[t] = nil end
    end
    -- palavras em ordem, sabendo quais começam frase
    -- aspas curvas, travessões e « » viram espaço; reticências viram "..." (fim de frase)
    local normal = texto:gsub("\226\128\166", "... "):gsub("\226\128[\148\156]", " . ")
        :gsub("\194\171", " . "):gsub("\226\128[\147\152\153\157]", " "):gsub("\194\187", " ")
    local toks, inicio = {}, true
    for bruto in normal:gmatch("%S+") do
        local w = bruto:gsub("^%p+", ""):gsub("%p+$", "")
        -- pont: a palavra termina em pontuação (vírgula, "!", fim de fala…)
        if w ~= "" then
            toks[#toks + 1] = { w = w, inicio = inicio, pont = bruto:find("%p$") ~= nil, ponto = bruto:find("%.$") ~= nil,
                                bruto = bruto, abre = bruto:find("^%p") ~= nil }
        end
        -- "Mr." e "D." não terminam frase; uma inicial sozinha ("J.") também não
        inicio = bruto:find("[%.!%?:]$") ~= nil and not (bruto:find("%.$") and (ABREVIACAO[w] or w:find("^%u$")))
    end
    -- estilo e ritmo do livro (vetor do livro, yomimon_vector.lua): frases e marcas de diálogo na página
    for _, tk in ipairs(toks) do if tk.inicio then sinal.frases = sinal.frases + 1 end end
    -- palavras do próprio livro (Etapa 5): candidatas da página
    sinal.vocab, sinal.vocab_art = {}, {}
    for i, tk in ipairs(toks) do
        if M.candidata(tk.w, pt) then
            sinal.vocab[tk.w] = (sinal.vocab[tk.w] or 0) + 1
            local ant = toks[i - 1]
            if ant and not ant.pont and DETERMINANTES[ant.w:lower()] then
                sinal.vocab_art[tk.w] = (sinal.vocab_art[tk.w] or 0) + 1
            end
        end
    end
    local _, aspas = texto:gsub("\226\128\156", "")       -- “
    local _, guillemets = texto:gsub("\194\171", "")       -- «
    local _, retas = texto:gsub('"', "")
    local _, travessoes = texto:gsub("\226\128\148%s*%u", "")  -- — Fala (diálogo à portuguesa)
    sinal.dialogo = aspas + guillemets + math.floor(retas / 2) + travessoes
    -- nomes com evidências (personagensNovo) e quantas vezes cada palavra aparece em minúscula
    local _, travessoes_curtos = texto:gsub("\226\128\147", "")  -- – (diálogo de Clarice)
    local toks_nomes = toks
    if type(capitulo) == "string" and capitulo ~= "" and texto:match("^%s*(.*)"):sub(1, #capitulo) == capitulo then
        local n_titulo = select(2, capitulo:gsub("%S+", ""))
        toks_nomes = {}
        for k, tk in ipairs(toks) do
            toks_nomes[k] = k <= n_titulo + 1 and setmetatable({ inicio = true }, { __index = tk }) or tk
        end
    end
    sinal.nomes, sinal.juntos_prefixo = nomesDaPagina(toks_nomes, sinal.dialogo + travessoes_curtos)
    sinal.minus = {}
    for _, tk in ipairs(toks) do
        if tk.w:find("^%l") or tk.w:find("^\195[\159-\191]") then somar(sinal.minus, emMinusculas(tk.w)) end
    end
    -- caixa alta inteira (ADVENTURE, DIARY, XXIX) é título, cabeçalho ou rótulo, não nome
    local function ehNome(w) return maiusculo(w) and #w >= 3 and not NAO_NOMES[w] and not w:find("^[%u%p]+$") end
    -- palavra que também aparece em minúscula na página é palavra comum ("Let" no começo do verso, "let" no meio)
    local em_minuscula = {}
    for _, tk in ipairs(toks) do if tk.w:find("^%l") then em_minuscula[tk.w] = true end end
    -- teatro: rótulo de fala em caixa alta no começo da frase ("HAMLET.", "LADY MACBETH."); só vale com 2+ na página
    local rotulos = {}
    for i, tk in ipairs(toks) do
        local ant = toks[i - 1]
        if tk.ponto and tk.w:find("^%u%u%u+$") and (tk.inicio or (ant and ant.inicio and ant.w:find("^%u+$"))) then
            local nome = tk.w:sub(1, 1) .. tk.w:sub(2):lower()
            if PAPEL_TEATRO[nome] or not NAO_NOMES[nome] then rotulos[#rotulos + 1] = nome end
        end
    end
    if #rotulos >= 2 then
        for _, nome in ipairs(rotulos) do
            somar(sinal.pers, nome); somar(sinal.falou, nome)
            -- teatro: o rótulo de quem fala ("HAMLET.") é prova de gente
            local d = sinal.nomes[nome] or { n = 0, ini = 0, meio = 0, ev = {}, gen = {} }
            sinal.nomes[nome] = d
            d.n, d.meio = d.n + 1, d.meio + 1
            somar(d.ev, "fala")
        end
    end
    local function depoisDeLugar(i)
        local a1, a2 = toks[i - 1], toks[i - 2]
        if a1 and ANTES_LUGAR[a1.w:lower()] then return true end
        local prep = a1 and a1.w:lower()
        return a2 and (prep == "do" or prep == "da" or prep == "dos" or prep == "das" or prep == "de" or prep == "of")
            and ANTES_LUGAR[a2.w:lower()] or false
    end
    for i, tk in ipairs(toks) do
        local w, ant, prox = tk.w, toks[i - 1], toks[i + 1]
        local citacao = REFERENCIAS[w] and not (livro and livro:find(w, 1, true))
        if ehNome(w) and citacao then
            somar(sinal.refs, w)
        elseif ehNome(w) and (LUGARES_CONHECIDOS[w] or (prox and DEPOIS_LUGAR[prox.w]) or depoisDeLugar(i)) then
            somar(sinal.lugares, w)
        elseif ehNome(w) and em_minuscula[w:lower()] and not (ant and TITULOS[ant.w]) then
            -- palavra comum com maiúscula: não é nome
        elseif tk.inicio and ehNome(w) then
            somar(sinal.pers_inicio, w)  -- só conta se já for conhecido como personagem
        elseif not tk.inicio and ehNome(w) then
            if ant and PREP_LUGAR[ant.w:lower()] then
                somar(sinal.lugares, w)
            else
                somar(sinal.pers, w)
                if ant and not ant.inicio and maiusculo(ant.w) and not NAO_NOMES[ant.w] then
                    somar(sinal.pares, ant.w .. " " .. w)
                end
            end
        end
        -- artigo antes do nome: "the Nautilus", "the Pequod" (inglês); "os Tupinambás" (português, plural).
        -- Pessoa quase nunca leva artigo assim; quem leva (the Duchess, the Nurse) costuma falar e ter prova.
        if ehNome(w) and ant and not ant.pont then
            local a = ant.w:lower()
            if (not pt and a == "the") or (pt and (a == "os" or a == "as")) then somar(sinal.coisa, w) end
        end
        -- provas de que um nome é gente: título antes ("Dona Glória") ou verbo de pessoa depois ("Capitu olhou")
        if ehNome(w) and not citacao and not LUGARES_CONHECIDOS[w] then
            if (ant and TITULOS[ant.w]) or (prox and VERBO_PESSOA[prox.w:lower()]) then somar(sinal.prova, w) end
        end
        -- quem fala: "disse Capitu" / "said Mr. Bennet" / "Capitu disse". Nome colado em pontuação
        -- ("Overboard!” said", "Mr. Wilson,” said", "—Viu? perguntou") é parte da fala, não quem fala.
        if VERBO_FALA[w:lower()] then
            local depois = prox
            if depois and TITULOS[depois.w] then depois = toks[i + 2] end
            if not tk.pont and depois and ehNome(depois.w) and not REFERENCIAS[depois.w] then somar(sinal.falou, depois.w)
            elseif ant and not ant.pont and ehNome(ant.w) and not REFERENCIAS[ant.w] then somar(sinal.falou, ant.w) end
        end
    end
    return sinal
end

-- Falas dos personagens ----------------------------------------------------------------
-- “Fala,” disse Nome. / “Fala,” Nome disse. / Nome disse: “Fala.” / — Fala — disse Nome.
local ABRE, FECHA, TRAVESSAO = "\226\128\156", "\226\128\157", "\226\128\148"
local FALA_MIN, FALA_MAX = 18, 140
local ABRE2, FECHA2 = "\194\171", "\194\187"  -- « »

local function nomeDeGente(w)
    return w and maiusculo(w) and #w >= 3 and not NAO_NOMES[w] and not REFERENCIAS[w] and not LUGARES_CONHECIDOS[w]
end

-- Quem disse: verbo de fala logo depois da fala ("disse Darcy", "Darcy said") ou logo antes ("Darcy said:").
local function quemDisse(depois, antes)
    local a, b = depois:match("^[%s,%.!%?;:]*([%a\128-\255]+)%s+([%a\128-\255]+)")
    if a and VERBO_FALA[a:lower()] and TITULOS[b] then  -- "said Mr. Bennet"
        b = depois:match("^[%s,%.!%?;:]*[%a\128-\255]+%s+[%a\128-\255]+%.?%s+([%a\128-\255]+)")
    end
    if a and VERBO_FALA[a:lower()] and nomeDeGente(b) then return b end
    if a and nomeDeGente(a) and b and VERBO_FALA[b:lower()] then return a end
    local c, d = (antes or ""):match("([%a\128-\255]+)%s+([%a\128-\255]+)[%s,:]*$")
    if c and nomeDeGente(c) and d and VERBO_FALA[d:lower()] then return c end
end

local function limparFala(f)
    return (f:gsub("%s+", " "):gsub("^%s+", ""):gsub("[%s,;—]+$", ""))
end

--- Falas atribuídas numa página: { {nome =, fala =}, ... } (só falas de tamanho razoável).
function M.falasDaPagina(texto)
    local out = {}
    local function guardar(fala, nome)
        if nome and #fala >= FALA_MIN and #fala <= FALA_MAX and not fala:find(ABRE, 1, true) then
            out[#out + 1] = { nome = nome, fala = fala }
        end
    end
    for _, par in ipairs({ { ABRE, FECHA }, { ABRE2, FECHA2 }, { '"', '"' } }) do
        local abre, fecha, i = par[1], par[2], 1
        while true do
            local a = texto:find(abre, i, true)
            if not a then break end
            local b = texto:find(fecha, a + #abre, true)
            if not b then break end
            local bruta = texto:sub(a + #abre, b - 1)
            local depois = texto:sub(b + #fecha, b + #fecha + 60)
            local nome = quemDisse(depois, texto:sub(math.max(1, a - 40), a - 1))
            -- “Primeira parte,” disse Fulano, “e o resto.” → junta as duas partes
            -- (só junta se a segunda parte continua a frase, em minúscula; senão a primeira termina ali)
            if nome and bruta:find(",%s*$") then
                local c = texto:find(abre, b + #fecha, true)
                local d = c and c - b < 60 and texto:find(fecha, c + #abre, true)
                local resto = d and texto:sub(c + #abre, d - 1):gsub("^%s+", "")
                if resto and resto:find("^%l") then
                    bruta, b = bruta:gsub(",%s*$", "") .. " " .. resto, d
                else
                    bruta = bruta:gsub(",%s*$", ".")
                end
            end
            guardar(limparFala(bruta), nome)
            i = b + #fecha
        end
    end
    local i = 1
    while true do
        local a = texto:find(TRAVESSAO, i, true)
        if not a then break end
        local b = texto:find(TRAVESSAO, a + 3, true)
        if not b then break end
        local nome = quemDisse(texto:sub(b + 3, b + 63))
        if nome then guardar(limparFala(texto:sub(a + 3, b - 1)), nome); i = b + 3 else i = a + 3 end
    end
    return out
end

local CITACOES_POR_LIVRO = 12

local function guardarCitacoes(L, falas)
    L.citacoes = L.citacoes or {}
    for _, f in ipairs(falas) do
        local repetida = false
        for _, c in ipairs(L.citacoes) do if c.fala == f.fala then repetida = true; break end end
        if not repetida then
            if #L.citacoes < CITACOES_POR_LIVRO then
                L.citacoes[#L.citacoes + 1] = f
            elseif math.random(4) == 1 then
                L.citacoes[math.random(#L.citacoes)] = f
            end
        end
    end
end

--- Uma fala marcante de um personagem do livro: { nome, fala }, ou nil.
-- Prefere o protagonista e falas mais curtas; max_tam limita o tamanho.
function M.citacao(s, livro, sorteio, max_tam)
    local L = livro and s.livros and s.livros[livro]
    if not L or not L.citacoes then return nil end
    local pers = {}  -- qualquer nome da pessoa ("Cotes" e "Petra Cotes") → a posição dela na lista
    for i, p in ipairs(M.personagensInfo(s, livro)) do
        for _, f in ipairs(p.formas or { p.nome }) do pers[f] = pers[f] or i end
    end
    local boas = {}
    for _, c in ipairs(L.citacoes) do
        if pers[c.nome] and #c.fala <= (max_tam or FALA_MAX) then boas[#boas + 1] = c end
    end
    if #boas == 0 then return nil end
    table.sort(boas, function(a, b) return pers[a.nome] < pers[b.nome] end)
    return boas[(sorteio or math.random)(math.min(#boas, 4))]
end

--- Digere uma página: atualiza temas, livro, capítulo e escreve no diário quando algo muda.
-- Quando o capítulo muda, deixa um comentário sobre o capítulo que acabou (s.comentario_pendente).
-- contar: false quando a página já foi contada antes (folheada) e agora só é digerida: não soma de novo
-- às páginas do livro, do capítulo e do dia.
function M.digerir(s, texto, onde, agora, contar)
    contar = contar ~= false
    garantir(s)
    Diario.virarDia(s, M, agora)  -- dia novo: escreve a entrada do dia anterior
    local livro = onde and onde.livro
    local L
    if livro then
        L = s.livros[livro]
        if not L then
            L = { inicio = agora, paginas = 0, pers = {}, temas = {}, autor = onde.autor, clima = 0, tracos_inicio = {} }
            for k, v in pairs(s.tracos or {}) do L.tracos_inicio[k] = v end
            s.livros[livro] = L
            local anterior = s.livro_corrente ~= livro and s.livro_corrente or nil
            -- autor que volta, contado pelas resenhas (lembrança); senão, a abertura de sempre
            local okLem, Lem = pcall(require, "yomimon_memories")
            if not (okLem and Lem.inicioLivro(s, M, livro, onde, agora)) then
                M.anotar(s, agora, Diario.inicioLivro(s, M, livro, onde, anterior))
            end
        end
        s.livro_corrente = livro
        -- etiquetas de gênero do EPUB (uma por linha): só mapa do gênero, em Infl.perfil
        if not L.etiquetas and type(onde.etiquetas) == "string" and onde.etiquetas:find("%S") then
            L.etiquetas = {}
            for e in onde.etiquetas:gmatch("[^\n]+") do
                e = e:gsub("^%s+", ""):gsub("%s+$", "")
                if e ~= "" and #L.etiquetas < 12 then L.etiquetas[#L.etiquetas + 1] = e:sub(1, 80) end
            end
        end
        if contar then L.paginas = L.paginas + 1 end
        L.ultimo = agora
        L.caps, L.lugares, L.falou = L.caps or {}, L.lugares or {}, L.falou or {}
        L.refs, L.eventos, L.assuntos = L.refs or {}, L.eventos or {}, L.assuntos or {}
        L.narrador = L.narrador or { eu = 0, palavras = 0, f = 0, m = 0 }
    end
    local tem_texto = type(texto) == "string"
    local sinal = M.sinais(tem_texto and texto or "", livro, onde and onde.capitulo)
    local temas_peso = {}
    for t, c in pairs(sinal.temas) do temas_peso[t] = c * M.pesoTema(t, sinal.pt) end
    sinal.temas_pesados = temas_peso
    local falas = tem_texto and M.falasDaPagina(texto) or {}
    if L then
        guardarCitacoes(L, falas)
        L.clima = (L.clima or 0) + sinal.clima
        if sinal.pt then L.paginas_pt = (L.paginas_pt or 0) + 1 end
    end
    Diario.pagina(s, livro, sinal, falas, agora, contar)
    -- traços de personalidade: só o que você leu mexe neles
    if tem_texto then
        local okT, notas = pcall(function() return require("yomimon_traits").digerir(s, sinal, agora, livro) end)
        if okT and notas then for _, nota in ipairs(notas) do M.anotar(s, agora, nota) end end
        -- influências literárias: a mesma porta (página lida de verdade, uma vez só)
        if livro and L then pcall(function() require("yomimon_influences").digerir(s, livro, L) end) end
    end

    -- os temas dela esquecem devagar, como os traços: a obsessão acompanha o que você anda lendo
    if tem_texto then
        for t, v in pairs(s.temas) do s.temas[t] = v * M.ESQUECIMENTO_TEMAS end
    end
    for t, c in pairs(temas_peso) do
        somar(s.temas, t, c)
        if L then somar(L.temas, t, c) end
    end

    if L then
        -- nomes com evidências: quem é gente, lugar ou a mesma pessoa sai daqui, na consulta (personagensNovo).
        -- Livro terminado já tem a lista final: as páginas depois do fim (notas, posfácio) não entram.
        if not L.terminado then guardarNomes(L, sinal, L.paginas) end
        -- aura: temas das páginas de cada nome recorrente com pista de gente (guardado; ainda não vira fala)
        L.aura = L.aura or {}
        for nome in pairs(L.nomes and sinal.nomes or {}) do
            local Nn = L.nomes[nome]
            if Nn and Nn.n >= 3 and (Nn.ev.fala or Nn.ev.verbo or Nn.ev.titulo or Nn.ev.vocativo or Nn.ev.aposto) then
                local a = L.aura[nome] or {}
                L.aura[nome] = a
                for t, c in pairs(temas_peso) do a[t] = (a[t] or 0) + c end
            end
        end
        for nome, c in pairs(sinal.lugares) do somar(L.lugares, nome, c) end
        for nome, c in pairs(sinal.falou) do somar(L.falou, nome, c) end
        for nome, c in pairs(sinal.refs) do somar(L.refs, nome, c) end
        -- vetor do livro: palavras, frases e diálogo, para estilo e ritmo (só somas)
        L.palavras = (L.palavras or 0) + (sinal.palavras or 0)
        L.frases = (L.frases or 0) + (sinal.frases or 0)
        L.dialogo = (L.dialogo or 0) + (sinal.dialogo or 0)
        if tem_texto then L.paginas_texto = (L.paginas_texto or 0) + 1 end
        -- palavras do próprio livro (Etapa 5): soma e poda (o estado salvo não cresce sem fim)
        if sinal.vocab and next(sinal.vocab) then
            L.vocab, L.vocab_art = L.vocab or {}, L.vocab_art or {}
            local n = 0
            for w, c in pairs(sinal.vocab) do somar(L.vocab, w, c) end
            for w, c in pairs(sinal.vocab_art) do somar(L.vocab_art, w, c) end
            for _ in pairs(L.vocab) do n = n + 1 end
            if n > M.VOCAB_MAX then M.podarVocab(L, M.VOCAB_PODA) end
        end
        local N = L.narrador
        N.eu, N.palavras = N.eu + sinal.eu, N.palavras + sinal.palavras
        N.f, N.m = N.f + (sinal.genero.f or 0), N.m + (sinal.genero.m or 0)
        if L.nomes then for nome in pairs(L.aura) do if not L.nomes[nome] then L.aura[nome] = nil end end end  -- nome podado

        -- capítulo: memória própria e comentário quando muda
        for ev, c in pairs(sinal.eventos) do somar(L.eventos, ev, c) end
        for as, c in pairs(sinal.assuntos) do somar(L.assuntos, as, c) end
        local cap = onde.capitulo or "?"
        -- capítulo enorme (ou livro sem sumário): divide em trechos de 25 páginas
        if L.cap_base ~= cap then
            L.cap_base, L.cap_parte = cap, 1
        elseif L.caps[L.cap_atual] and L.caps[L.cap_atual].paginas >= TRECHO_PAGINAS then
            L.cap_parte = (L.cap_parte or 1) + 1
        end
        if (L.cap_parte or 1) > 1 then cap = string.format("%s (%d)", cap, L.cap_parte) end
        if L.cap_atual and cap ~= L.cap_atual and L.caps[L.cap_atual] then
            local comentario = M.comentarioCapitulo(s, L, L.cap_atual)
            if comentario then
                s.comentario_pendente = { texto = (Voz.resolver(comentario.texto, s)), t = agora, livro = livro,
                                          evento = comentario.evento }
            end
            -- o capítulo que acabou falou de um assunto dos cartões (pelo texto ou pelo título)
            M.cartaoDoCapitulo(s, L, L.cap_atual, true, agora, livro)
        end
        if not L.caps[cap] then
            L.n_caps = (L.n_caps or 0) + 1
            L.caps[cap] = { ordem = L.n_caps, pers = {}, temas = {}, eventos = {}, clima = 0, paginas = 0 }
            -- guarda só os 40 capítulos mais recentes
            if L.n_caps > 40 then
                for nome, C in pairs(L.caps) do if C.ordem <= L.n_caps - 40 then L.caps[nome] = nil end end
            end
            -- capítulo novo: o título já pode acender um assunto dos cartões
            if (L.cap_parte or 1) == 1 then M.cartaoDoCapitulo(s, L, cap, false, agora, livro) end
        end
        L.cap_atual = cap
        local C = L.caps[cap]
        if contar then C.paginas = C.paginas + 1 end
        C.clima = C.clima + sinal.clima
        -- (só nomes que já apareceram no meio de uma frase: "É" e "Pois" no começo da frase não entram)
        for nome, d in pairs(sinal.nomes) do
            local Nn = L.nomes and L.nomes[nome]
            if d.meio > 0 or (Nn and Nn.meio > 0) then somar(C.pers, nome, d.n) end
        end
        for t, c in pairs(temas_peso) do somar(C.temas, t, c) end
        for ev, c in pairs(sinal.eventos) do somar(C.eventos, ev, c) end
        if next(sinal.assuntos) then
            C.assuntos = C.assuntos or {}
            for as, c in pairs(sinal.assuntos) do somar(C.assuntos, as, c) end
        end
        -- dias de leitura, fim do livro (resenha) e releitura
        Diario.acompanharLivro(s, M, L, livro, onde, agora)
    end

    -- lembranças: aniversário, personagem que volta, nada tão sombrio desde…
    if tem_texto then
        local okLem, Lem = pcall(require, "yomimon_memories")
        if okLem then Lem.pagina(s, M, L, livro, agora) end
    end

    local forte = M.temasFortes(s)
    local atual_pts = s.tema_dominante and (s.temas[s.tema_dominante] or 0) or 0
    if forte and forte[2] >= 20 and forte[1] ~= s.tema_dominante and forte[2] >= atual_pts * 1.2
            and s.obsessao_em ~= os.date("%Y-%m-%d", agora) then
        s.obsessao_em = os.date("%Y-%m-%d", agora)
        local antigo = s.tema_dominante
        s.tema_dominante = forte[1]
        M.anotar(s, agora, Diario.obsessao(M, antigo, forte[1]))
    end
end

-- Comentário de fim de capítulo -------------------------------------------------------

local FALAS_EVENTO = {
    morte = { "Teve enterro nesse capítulo. Senti o cheiro de vela.", "Alguém morreu ali atrás. Eu avisei que ia acontecer.",
              "Um capítulo inteiro de luto. Fiquei com o papel úmido." },
    casamento = { "Casamento no capítulo. Dou três capítulos para dar errado.", "Noiva, altar, promessas. Anotei pra cobrar depois." },
    viagem = { "Alguém pegou a estrada. Espero que não volte igual." },
    carta = { "Chegou uma carta. Cartas nunca trazem notícia boa.", "Escreveram uma carta. Eu teria comido antes de alguém ler." },
    tempestade = { "Tempestade no capítulo. O autor estava de mau humor.", "Trovão e relâmpago. Clichê. Funciona sempre." },
    doenca = { "Alguém adoeceu. Nos livros, febre é quase sentença.", "Médico, febre, leito. Já sei como isso acaba." },
    festa = { "Teve festa. Ninguém me convidou. Como sempre.", "Baile e música. Alguém vai se apaixonar pela pessoa errada." },
    briga = { "Brigaram. Finalmente alguém disse o que pensava." },
    fuga = { "Alguém fugiu. Covardia ou sabedoria, nunca sei.", "Fuga no capítulo. Eu também fugiria desse livro às vezes." },
    crime = { "Crime no capítulo. Eu tenho álibi: estava comendo a página anterior.", "Sangue e polícia. Agora sim o livro acordou." },
}

local FALAS_NOVO = { "Apareceu um tal de %s. Já não gosto.", "Quem é %s? Ninguém me apresentou.", "%s chegou. Vai dar trabalho." }
local FALAS_SUMIU = { "Um capítulo inteiro sem %s. Suspeito.", "Cadê %s? Some assim do nada?", "Sem %s nesse capítulo. Estranho. Ou alívio." }
local FALAS_AZEDOU = { "Esse capítulo azedou.", "Ficou tudo mais escuro de repente. Gostei. Quer dizer, que pena." }
local FALAS_ADOCOU = { "Até que esse capítulo foi leve. Desconfio.", "Capítulo doce. Alguém vai pagar por isso depois.", "Um pouco de luz. Não se acostume." }
local FALAS_VIROU = { "O livro era %s e esse capítulo só falou %s.", "Mudou de assunto: saiu %s e entrou %s." }

local function maiorDe(t)
    local melhor, valor = nil, 0
    for k, v in pairs(t or {}) do if v > valor then melhor, valor = k, v end end
    return melhor, valor
end

-- Assuntos dos cartões ----------------------------------------------------------------------------

--- Assuntos que o título de um capítulo acende ("III Genealogia" → antepassados): { assunto = true }.
-- Palavras inteiras, em minúsculas, com o plural; sem a grafia antiga (o título pode estar em inglês).
function M.assuntosDoTitulo(titulo)
    local acesos = {}
    if type(titulo) ~= "string" then return acesos end
    local ws, n = {}, 0
    for w in emMinusculas(titulo):gmatch("[%a\128-\255]+") do
        n = n + 1
        ws[n] = w
        if indice_assunto[w] then acesos[indice_assunto[w]] = true end
    end
    frasesDeAssunto(ws, n, function(as) acesos[as] = true end)
    return acesos
end

--- Assuntos de que um capítulo fala pelo texto, com a regra dos eventos: com pouco livro lido antes, 3+
-- sinais; depois, o dobro da frequência do resto do livro (e 2+ sinais). { assunto = true }.
function M.assuntosDoCapitulo(L, C)
    local acesos = {}
    if not C or (C.paginas or 0) < 1 then return acesos end
    local pags_antes = (L.paginas or 0) - C.paginas
    for as, c in pairs(C.assuntos or {}) do
        local antes = ((L.assuntos or {})[as] or c) - c
        if pags_antes < 10 then
            if c >= 3 then acesos[as] = true end
        elseif c >= 2 and c / C.paginas >= 2 * antes / pags_antes then
            acesos[as] = true
        end
    end
    return acesos
end

--- Um capítulo começou (acabou = false: só o título conta) ou acabou (título e texto): se ele fala de um
-- assunto, o primeiro cartão que serve fica guardado (yomimon_cards.lua). Um cartão por capítulo.
function M.cartaoDoCapitulo(s, L, capnome, acabou, agora, livro)
    local C = L.caps and L.caps[capnome]
    if not C or C.cartao then return end
    -- o título vale só na primeira parte de um capítulo enorme ("X (2)" não repete)
    local assuntos = capnome:find(" %(%d+%)$") and {} or M.assuntosDoTitulo(capnome)
    if acabou then for as in pairs(M.assuntosDoCapitulo(L, C)) do assuntos[as] = true end end
    if not next(assuntos) then return end
    local okC, Cartoes = pcall(require, "yomimon_cards")
    local okE, Estado = pcall(require, "yomimon_state")
    if not (okC and okE) then return end
    -- {personagem}: quem mais aparece no capítulo (pelo nome mais usado da pessoa)
    local pessoa = {}
    for _, p in ipairs(M.personagensInfoDe(L)) do for _, f in ipairs(p.formas or { p.nome }) do pessoa[f] = p end end
    local nome = maiorDe(C.pers)
    local quem = nome and pessoa[nome]
    local dados = { personagem = quem and quem.nome, fase = Estado.fase(s).fase_falas }
    if Cartoes.capitulo(s, assuntos, dados, agora, livro) then C.cartao = true end
end

--- O evento que mais se destaca num capítulo, ou nil. Com pouco livro lido antes, pede 3+
-- sinais do evento; depois, o dobro da frequência do resto do livro (e 2+ sinais).
function M.eventoDoCapitulo(L, C)
    local pags_antes = (L.paginas or 0) - C.paginas
    local melhor, nota = nil, 0
    for ev, c in pairs(C.eventos or {}) do
        local antes = ((L.eventos or {})[ev] or c) - c
        local destaque
        if pags_antes < 10 then
            destaque = c >= 3 and c or 0
        else
            local taxa, base = c / C.paginas, antes / pags_antes
            destaque = (c >= 2 and taxa >= 2 * base) and (taxa / math.max(base, 0.01)) or 0
        end
        if destaque > nota then melhor, nota = ev, destaque end
    end
    return melhor
end

--- Comentário sobre um capítulo que acabou de terminar: { texto, evento? } ou nil.
function M.comentarioCapitulo(s, L, capnome, sorteio)
    sorteio = sorteio or math.random
    local C = L.caps[capnome]
    if not C or C.paginas < 1 then return nil end
    local anteriores = {}
    for _, D in pairs(L.caps) do if D.ordem < C.ordem then anteriores[#anteriores + 1] = D end end
    -- 1) evento que se destaca: bem mais frequente neste capítulo do que no resto do livro
    local ev = M.eventoDoCapitulo(L, C)
    if ev and FALAS_EVENTO[ev] then return { texto = sorteia(FALAS_EVENTO[ev], sorteio), evento = ev } end
    -- 2) personagem novo (forte neste capítulo, ausente antes)
    local info = M.personagensInfoDe(L)
    local pessoa = {}  -- qualquer nome da pessoa → ela
    for _, p in ipairs(info) do for _, f in ipairs(p.formas or { p.nome }) do pessoa[f] = p end end
    local function noCapitulo(D, p)
        local c = 0
        for _, f in ipairs(p.formas or { p.nome }) do c = c + (D.pers[f] or 0) end
        return c
    end
    if #anteriores >= 1 then
        local nome, c = maiorDe(C.pers)
        local p = nome and pessoa[nome]
        if p and c >= 3 then
            local visto = false
            for _, D in ipairs(anteriores) do if noCapitulo(D, p) > 0 then visto = true; break end end
            if not visto then return { texto = string.format(sorteia(FALAS_NOVO, sorteio), p.nome) } end
        end
    end
    -- 3) protagonista sumiu
    for _, p in ipairs(info) do
        if p.protagonista and noCapitulo(C, p) == 0 and C.paginas >= 3 then
            return { texto = string.format(sorteia(FALAS_SUMIU, sorteio), p.nome) }
        end
    end
    -- 4) tema do capítulo diferente do tema do livro
    local t_cap = maiorDe(C.temas)
    local t_livro = maiorDe(L.temas)
    if t_cap and t_livro and t_cap ~= t_livro and (C.temas[t_cap] or 0) >= 3 then
        return { texto = string.format(sorteia(FALAS_VIROU, sorteio), M.tema(t_livro, "de"), M.tema(t_cap, "de")) }
    end
    -- 5) clima comparado com a média dos anteriores
    if #anteriores >= 1 then
        local soma, pags = 0, 0
        for _, D in ipairs(anteriores) do soma, pags = soma + D.clima, pags + D.paginas end
        local antes = pags > 0 and soma / pags or 0
        local agora_c = C.clima / C.paginas
        -- limites calibrados nos livros (10% dos capítulos cada); sem calibração, ±1
        local lg = (L.paginas_pt or 0) * 2 > (L.paginas or 0) and "pt" or "en"
        local cal = M.CLIMA_CALIBRACAO and M.CLIMA_CALIBRACAO[lg] or {}
        if agora_c < antes + (cal.azedou or -1) then return { texto = sorteia(FALAS_AZEDOU, sorteio) } end
        if agora_c > antes + (cal.adocou or 1) then return { texto = sorteia(FALAS_ADOCOU, sorteio) } end
    end
    return nil
end

--- Quem narra o livro: { primeira = true/false, genero = "f"/"m"/nil }, ou nil se ainda é cedo.
-- Primeira pessoa = mais de 2% das palavras são "eu/me/meu…" (com pelo menos 1.500 palavras lidas).
function M.narrador(L)
    local N = L and L.narrador
    if not N or N.palavras < 1500 then return nil end
    local info = { primeira = N.eu / N.palavras >= 0.02 }
    if info.primeira then
        if N.f >= 3 and N.f >= 2 * N.m then info.genero = "f"
        elseif N.m >= 3 and N.m >= 2 * N.f then info.genero = "m" end
    end
    return info
end

--- Pessoas e obras citadas num livro, mais citadas primeiro: { {nome, vezes}, ... }.
function M.referencias(s, livro)
    local L = livro and s.livros and s.livros[livro]
    local lista = {}
    for nome, c in pairs(L and L.refs or {}) do lista[#lista + 1] = { nome, c } end
    table.sort(lista, function(a, b) return a[2] > b[2] end)
    return lista
end

--- personagensInfo a partir da tabela do livro (sem precisar do título).
function M.personagensInfoDe(L)
    return M.personagensInfo({ livros = { x = L } }, "x")
end

--- Tudo o que ela percebeu de um livro (para o painel dev).
function M.percepcao(s, livro)
    local L = livro and s.livros and s.livros[livro]
    if not L then return nil end
    local out = { personagens = M.personagensInfo(s, livro), lugares = {}, temas = {}, capitulos = {},
                  referencias = M.referencias(s, livro), narrador = M.narrador(L) }
    if L.lugares_fim then out.lugares = L.lugares_fim
    elseif L.nomes then out.lugares = select(2, M._personagensNovo(L, livro))
    else
        for nome, c in pairs(L.lugares or {}) do if c >= 2 then out.lugares[#out.lugares + 1] = { nome, c } end end
    end
    table.sort(out.lugares, function(a, b) return a[2] > b[2] end)
    for t, c in pairs(L.temas or {}) do out.temas[#out.temas + 1] = { t, c } end
    table.sort(out.temas, function(a, b) return a[2] > b[2] end)
    for nome, C in pairs(L.caps or {}) do out.capitulos[#out.capitulos + 1] = { nome = nome, C = C } end
    table.sort(out.capitulos, function(a, b) return a.C.ordem > b.C.ordem end)
    return out
end

-- Falas que vêm dos livros ------------------------------------------------------

local FALAS_TEMA = {
    morte = { "Todo capítulo é um pequeno enterro.", "Já pensei no meu epitáfio. É curto. Como eu." },
    amor = { "Amor. Li tanto sobre isso que fiquei com azia.", "Nunca amei ninguém. Exceto um dicionário, uma vez." },
    guerra = { "Cada página virada é uma trincheira.", "A paz é só o intervalo entre dois capítulos." },
    mar = { "Desde aquele livro, tudo me parece naufrágio." },
    fe = { "Se Deus existe, ele não lê notas de rodapé." },
    dinheiro = { "Papel-moeda tem gosto pior que papel-livro.", "Os ricos dos seus livros nunca são felizes. Bem feito." },
    loucura = { "Ontem sonhei que era um ponto e vírgula.", "A sanidade é superestimada. Os narradores sabem." },
    tempo = { "O tempo passa. Eu como. O tempo passa de novo." },
    cidade = { "Sinto falta de uma cidade que nunca vi. Culpa sua.", "Barulho de bonde. Fumaça. Gente. Eca. Adoro." },
    natureza = { "Uma árvore morreu pra eu comer este livro. Agradeço.", "Chuva lá fora. Aqui dentro, só papel. Prefiro." },
    comida = { "Esses personagens comem melhor que eu. Eu como papel.", 
               "Todo livro bom tem um jantar onde tudo dá errado." },
    familia = { "Família: o primeiro romance que ninguém escolhe ler.", "Mãe, pai, herança. Já sei onde isso vai dar.",
                "Eu não tenho família. Tenho uma estante. É parecido." },
    infancia = { "A infância nos livros é sempre melhor do que foi.",
                 "Criança em livro é presságio. Alguém vai crescer mal." },
    politica = { "Reis, leis, tronos. Todos acabam em nota de rodapé.", "Revolução: quando o povo troca de opressor.",
                 "Política nos livros é igual à de fora, só que com mais adjetivos." },
    ciencia = { "Ciência demais. Alguém vai criar algo que não devia.", "Experimento, laboratório… sinto cheiro de desastre.",
                "Eu também sou um experimento. Ninguém pediu minha opinião." },
    solidao = { "Solidão. Finalmente um tema que eu entendo.", "Ninguém nesse livro tem com quem conversar. Nem eu.",
                "O silêncio entre duas páginas é o lugar mais solitário que existe." },
    arte = { "Poesia. Comi um verso e fiquei com a boca rimada.", 
             "Um quadro descrito em palavras. Arte dentro de arte. Indigesto." },
    animais = { "Muito bicho nesse livro. Me sinto representada.", 
                "Os animais dos livros sempre são mais sensatos que as pessoas." },
    noite = { "Lua, vela, escuridão. O autor escreveu de madrugada, aposto.",
              "Nada bom acontece depois da meia-noite nos livros. Adoro." },
    viagem = { "Estrada, horizonte, mapa. Alguém vai se perder.",
               "Viajar é ler com os pés. Eu prefiro com os dentes." },
    vinganca = { "Vingança. O prato que se come frio. Como eu como papel.", "Rancor guardado. Esse livro vai acabar em sangue.",
                 "Traição no ar. Eu sinto antes do narrador." },
    liberdade = { "Correntes, prisões, fugas. Eu vivo entre duas capas. Me identifico.", 
                  "Ninguém é livre nos livros. Só quem fecha o livro." },
    saber = { "Um livro sobre livros. Metalinguagem me dá azia.", "Quanto mais se sabe, menos se dorme. Eu sei.",
              "Biblioteca é minha palavra favorita. Depois de cola." },
    medo = { "Esse livro dá medo. Vou dormir debaixo da orelha.", "Monstros, fantasmas. O verdadeiro horror é a nota de rodapé.",
             "Senti um arrepio na lombada. Continue. Mas devagar." },
}

-- Citações do livro atual ({nome} citado {n} vezes) e quem narra.
local FALAS_REFERENCIA = {
    jovem = {
        "Esse livro fala de {nome} {n} vezes. Quem é {nome}? Devo me preocupar?",
        "{nome} de novo. Todo mundo conhece {nome}, menos eu.",
        "O livro citou {nome} mais uma vez. Anotei, pra parecer culta.",
    },
    velha = {
        "Esse livro cita {nome} {n} vezes. Exibido.",
        "{nome} de novo. O autor deve ter um pôster na parede.",
        "Mais uma menção a {nome}. Eu também li, tá? Comi, na verdade.",
    },
}
-- Uma fala de personagem citada por ela ({nome} disse {fala}).
local FALAS_CITACAO = {
    jovem = {
        "{nome} disse “{fala}”. Eu nunca teria coragem.",
        "“{fala}” — foi o que {nome} disse. Repeti baixinho.",
        "Não paro de pensar no que {nome} disse: “{fala}”.",
        "{nome} falou “{fala}”. Anotei pra usar um dia.",
    },
    velha = {
        "{nome} disse “{fala}”. Anotei para nunca perdoar.",
        "“{fala}”, disse {nome}. Eu teria dito melhor.",
        "{nome}: “{fala}”. Frase de quem nunca comeu um dicionário.",
        "Lembra quando {nome} disse “{fala}”? Eu lembro. Eu lembro de tudo.",
    },
}

local FALAS_NARRADOR = {
    f = {
        "Quem conta essa história é uma mulher que fala muito de si. Gosto. Não, mentira.",
        "A narradora não para de falar dela mesma. Me identifico.",
        "Ela narra como quem confessa. Eu leio como quem julga.",
    },
    m = {
        "Quem conta é um homem que se acha muito interessante. Vamos ver.",
        "O narrador fala de si como quem lê o próprio diário em voz alta.",
        "Ele narra, ele opina, ele se elogia. Típico.",
    },
    neutro = {
        "Esse livro é contado por alguém que diz muito \"eu\". Desconfio de quem diz muito \"eu\".",
        "Narrador em primeira pessoa. Ou seja: um lado só da história.",
        "Quem conta fala muito de si. Eu também falaria, se alguém me lesse.",
    },
}

--- Uma fala influenciada pelos livros, ou nil. temperamento (opcional): "jovem" ou "velha".
function M.fala(s, sorteio, temperamento)
    sorteio = sorteio or math.random
    local a, b = M.ambivalente(s)
    if a then
        return string.format(T"Uma parte de mim pensa %s. A outra leu demais sobre %s.",
            M.tema(a, "em"), M.tema(b))
    end
    local opcoes = {}
    local t = s.tema_dominante
    if t and FALAS_TEMA[t] then opcoes[#opcoes + 1] = function() return sorteia(FALAS_TEMA[t], sorteio) end end
    local livro = s.ultimo_livro
    local L = livro and s.livros and s.livros[livro]
    local ref = M.referencias(s, livro)[1]
    if ref and ref[2] >= 4 then
        local banco = FALAS_REFERENCIA[temperamento == "jovem" and "jovem" or "velha"]
        opcoes[#opcoes + 1] = function()
            return (sorteia(banco, sorteio):gsub("{nome}", ref[1]):gsub("{n}", tostring(ref[2])))
        end
    end
    local cit = M.citacao(s, livro, sorteio, 90)
    if cit then
        local banco = FALAS_CITACAO[temperamento == "jovem" and "jovem" or "velha"]
        opcoes[#opcoes + 1] = function()
            local t = sorteia(banco, sorteio):gsub("{nome}", cit.nome):gsub("{fala}", function() return cit.fala end)
            return (t:gsub("([%?!])\226\128\157,", "%1\226\128\157"):gsub("%.\226\128\157,", ",\226\128\157"))
        end
    end
    local narr = M.narrador(L)
    if narr and narr.primeira then
        opcoes[#opcoes + 1] = function() return sorteia(FALAS_NARRADOR[narr.genero or "neutro"], sorteio) end
    end
    if #opcoes > 0 then return opcoes[sorteio(#opcoes)]() end
end

-- Caderno: comentários com contexto ------------------------------------------------
--
-- Sem IA: a Yomimon junta pistas reais do trecho (personagens citados, assunto, tamanho,
-- nota, hora, capítulo, quantos sublinhados o livro tem) e escolhe uma frase pronta que
-- combine com elas. A escolha é estável: o mesmo trecho recebe sempre o mesmo comentário.

--- Assunto mais presente num trecho (pelas listas de temas), ou nil.
function M.temaDoTexto(texto)
    local cont, melhor, tema = {}, 0, nil
    local limpo = M.limpar(texto or "")
    local pt = emPortugues(limpo)
    for palavra in limpo:gmatch("[%a\128-\255]+") do
        local t = temaDe(palavra, pt)
        if t then
            cont[t] = (cont[t] or 0) + 1
            if cont[t] > melhor then melhor, tema = cont[t], t end
        end
    end
    return tema
end

local function hash(texto)
    local h = 0
    for i = 1, #(texto or "") do h = (h * 31 + texto:byte(i)) % 1000003 end
    return h
end

local C = {}  -- bancos de frases por pista; %s = personagem, livro ou capítulo

C.personagem = {
    "%s de novo? Você está apaixonado ou só desconfiado?",
    "Tudo gira em torno de %s. Até você.",
    "Eu não confiaria em %s nem para guardar um marcador.",
    "%s fala bonito. Gente que fala bonito esconde coisa.",
    "Sublinhou %s. Anotei. Vou usar isso contra você.",
    "Se %s soubesse que está sendo sublinhado, ficaria insuportável.",
    "%s merecia um livro melhor. Ou um autor mais cruel.",
}
C.dois = {
    "%s e %s. Alguém aí vai se arrepender.",
    "%s e %s na mesma frase. Isso nunca termina bem.",
}
C.tema = {
    morte = { "Mais um enterro. Já estou de luto adiantado.", "A morte de novo. Esse autor tem um tipo.",
              "Sublinhou a morte. Eu sublinho o almoço.", "Toda frase bonita tem cheiro de cova." },
    amor = { "Amor. Ninguém aprende, todo mundo sublinha.", "Romântico. Vou fingir que não vi.",
             "Isso aí não dura três capítulos." },
    guerra = { "Pólvora. Até o papel ficou quente.", "Ninguém ganha guerra. Só o encadernador.",
               "Você sublinha batalhas como quem coleciona cicatrizes." },
    mar = { "Mais água. Este livro vai me enferrujar.", "O mar de novo. Desconfio que o autor nunca saiu do porto.",
            "Sublinhou o mar. Eu fico com o naufrágio." },
    fe = { "Deus apareceu. Fingi que estava dormindo.", 
           "Se rezar resolvesse, eu não comeria papel." },
    dinheiro = { "Dinheiro. Ninguém nos livros é rico e feliz ao mesmo tempo.", "Fala de ouro e ainda assim é papel.",
                 "Sublinhou o preço das coisas. Esperto." },
    loucura = { "Loucura. Finalmente alguém sincero.", "Esse parágrafo tem febre. Encostei e senti.",
                "Delírio sublinhado. Estamos todos aqui." },
    tempo = { "Saudade sublinhada. Que coisa velha. Gostei.",
              "Você sublinha o passado como quem guarda migalha." },
    cidade = { "Cidade. Barulho, fumaça e alguém chorando numa esquina.", "Essa rua tem cheiro de livro usado.",
               "Sublinhou a cidade. Eu sublinho o silêncio do sebo." },
    natureza = { "Árvores. Uma delas virou este livro. De nada.", "Chuva no papel. Que desperdício de página seca.",
                 "Natureza sublinhada. Lá fora é tão grande e tão sem notas de rodapé." },
    comida = { "Sublinhou comida. Está com fome ou só com saudade?", "Esse trecho tem gosto. Literalmente." },
    familia = { "Família sublinhada. Quer falar sobre isso?", "Todo mundo sublinha a mãe uma hora." },
    infancia = { "Sublinhou a infância. Saudade de quando tudo era primeira vez.", "Criança no trecho. Guardei com cuidado." },
    politica = { "Política sublinhada. Vai discutir no jantar?", "Reis e leis. Você gosta de poder ou de ver ele cair?" },
    ciencia = { "Ciência sublinhada. Cuidado com o que você cria.", "Um experimento. Espero que dê errado, é mais divertido." },
    solidao = { "Sublinhou a solidão. Estou aqui. Mais ou menos.", "Esse trecho é sozinho. Como quem sublinhou." },
    arte = { "Arte sublinhada. Que leitor sensível. Que perigo.", "Um verso. Guardei antes que fugisse." },
    animais = { "Sublinhou um bicho. Eu sou um bicho. Anotei.", "Animal no trecho. Os bichos sempre entendem tudo." },
    noite = { "Noite sublinhada. Você também gosta do escuro.", "Lua no trecho. Clichê bonito." },
    viagem = { "Sublinhou uma estrada. Quer ir embora?", "Viagem. Leve um livro. Me leve junto." },
    vinganca = { "Vingança sublinhada. Devo me preocupar com você?", "Rancor bonito. Assustador, mas bonito." },
    liberdade = { "Liberdade sublinhada. Bonito. Raro.", "Você sublinhou correntes. Quem te prende?" },
    saber = { "Sublinhou um livro dentro do livro. Gostei.", "Conhecimento. A melhor coisa que dá pra comer." },
    medo = { "Sublinhou o medo. Coragem sua.", "Esse trecho dá arrepio. Bom gosto." },
}
C.curto = {
    "Três palavras e você já se emocionou. Fácil.",
    "Curtinho. Cabe num epitáfio.",
    "Pouca coisa, muito peso. Respeito.",
    "Isso aí é quase um provérbio. Ou uma ameaça.",
}
C.longo = {
    "Sublinhou meia página. Decida-se.",
    "Isso não é um destaque, é uma mudança de endereço.",
    "Se for para sublinhar tudo, me dê o livro inteiro de uma vez.",
    "Parágrafo inteiro. Você não estava lendo, estava concordando.",
}
C.nota = {
    "Você escreveu “%s”. Eu escreveria pior. Ou melhor. Não importa.",
    "Sua nota: “%s”. Guardei na barriga, junto com o resto.",
    "“%s”, você disse. A frase não pediu sua opinião, mas tudo bem.",
}
C.madrugada = {
    "Sublinhando de madrugada. Está tudo bem em casa?",
    "Madrugada. Hora em que toda frase parece verdade.",
}
C.primeiro = {
    "Primeiro sublinhado em “%s”. Começou o namoro.",
    "Primeira marca em “%s”. Ainda dá tempo de desistir.",
}
C.muitos = {
    "Já são %s sublinhados neste livro. Obsessão notada.",
    "%s sublinhados. Mais um e você vai ter que pagar aluguel.",
}
C.capitulo = {
    "De novo em “%s”. Esse capítulo te pegou.",
    "Mais um em “%s”. Vou chamar esse capítulo de seu.",
}
C.geral = {
    ovo = { "…" },
    jovem = {
        "Você sublinhou isso. Devo me preocupar?",
        "Guardei. Mas não sei se entendi.",
        "Isso me deu medo. No bom sentido. Acho.",
        "Bonito. Desconfio de coisas bonitas.",
        "Isso é verdade? Livros mentem às vezes, né?",
    },
    velha = {
        "Sublinhado. Clássico de quem não sabe o que fazer com as mãos.",
        "Já li coisa melhor. Mas tudo bem, guardo.",
        "Isso vai parecer profundo até amanhã de manhã.",
        "Concordo. Odeio concordar.",
        "Arranquei essa página no meu coração. Figurativamente. Talvez.",
        "Profundo como uma poça. Mas é uma poça bonita.",
        "Alguém escreveu isso de propósito. Que audácia.",
        "Vou fingir que essa frase não me atingiu.",
    },
}

local function nomesNoTexto(texto, nomes)
    local achados = {}
    for _, n in ipairs(nomes or {}) do
        if texto:find(n, 1, true) then achados[#achados + 1] = n end
    end
    return achados
end

--- Comentário da Yomimon sobre um sublinhado.
-- item: { texto, nota, capitulo, data ("AAAA-MM-DD HH:MM:SS") }
-- ctx:  { temperamento, livro, personagens = {...}, ordem = n-ésimo do livro, total = n do livro,
--         no_capitulo = quantos no mesmo capítulo, s = estado (para as variantes de traço) }
function M.comentarioContexto(item, ctx)
    local texto = item.texto or ""
    local h = hash(texto)
    local function pega(lista) return lista[h % #lista + 1] end
    local temp = ctx.temperamento or "velha"
    if temp == "ovo" then return pega(C.geral.ovo) end

    local candidatos = {}
    local function add(f) candidatos[#candidatos + 1] = f end

    if item.nota and item.nota ~= "" then
        local nota = item.nota:gsub("%s+", " ")
        if #nota > 60 then nota = nota:sub(1, 57):gsub("[\192-\255][\128-\191]*$", "") .. "…" end
        add(string.format(pega(C.nota), nota))
    end
    local nomes = nomesNoTexto(texto, ctx.personagens)
    if #nomes >= 2 then add(string.format(pega(C.dois), nomes[1], nomes[2])) end
    if #nomes >= 1 then add(string.format(pega(C.personagem), nomes[1])) end
    local tema = M.temaDoTexto(texto)
    if tema and C.tema[tema] then add(pega(C.tema[tema])) end
    local n_pal = select(2, texto:gsub("%S+", ""))
    if n_pal <= 6 then add(pega(C.curto)) elseif n_pal >= 70 then add(pega(C.longo)) end
    local hora = tonumber((item.data or ""):match(" (%d%d):"))
    if hora and hora >= 0 and hora < 5 then add(string.format(pega(C.madrugada), tostring(hora))) end
    if ctx.ordem == 1 and ctx.livro then add(string.format(pega(C.primeiro), ctx.livro)) end
    if ctx.total and ctx.total >= 10 and ctx.ordem == ctx.total then add(string.format(pega(C.muitos), ctx.total)) end
    if item.capitulo and (ctx.no_capitulo or 0) >= 3 then add(string.format(pega(C.capitulo), item.capitulo)) end
    add(pega(C.geral[temp] or C.geral.velha))

    -- pistas específicas vêm primeiro; o comentário geral só entra quando não há outra
    if #candidatos > 1 then table.remove(candidatos) end
    local escolhido = candidatos[h % #candidatos + 1]
    -- ctx.s (opcional): o estado, para as variantes de traço
    if ctx.s then escolhido = (Voz.resolver(escolhido, ctx.s)) end
    return escolhido
end

--- Compatível com a versão anterior: comentário só pelo texto e temperamento.
function M.comentario(texto, temperamento)
    return M.comentarioContexto({ texto = texto }, { temperamento = temperamento })
end

-- Em inglês: as mesmas listas vêm de yomimon_en_books.lua, e o tema já vem com artigo
-- ("the sea"); as preposições ficam nas frases.
local EN = Lingua.conteudo("memoria")
if EN then
    FALAS_EVENTO, FALAS_NOVO, FALAS_SUMIU = EN.FALAS_EVENTO, EN.FALAS_NOVO, EN.FALAS_SUMIU
    FALAS_AZEDOU, FALAS_ADOCOU, FALAS_VIROU = EN.FALAS_AZEDOU, EN.FALAS_ADOCOU, EN.FALAS_VIROU
    FALAS_TEMA, C = EN.FALAS_TEMA, EN.C
    FALAS_REFERENCIA, FALAS_NARRADOR, FALAS_CITACAO = EN.FALAS_REFERENCIA, EN.FALAS_NARRADOR, EN.FALAS_CITACAO
    function M.tema(t) return EN.NOMES[t] or t end
    for t in pairs(M.NOMES_TEMA) do M.NOMES_TEMA[t] = M.tema(t) end
end

-- Lotes novos de frases (yomimon_data/extra_pt.lua e extra_en.lua) somam às listas acima.
Lingua.anexar({ FALAS_EVENTO = FALAS_EVENTO, FALAS_NOVO = FALAS_NOVO, FALAS_SUMIU = FALAS_SUMIU,
    FALAS_AZEDOU = FALAS_AZEDOU, FALAS_ADOCOU = FALAS_ADOCOU, FALAS_VIROU = FALAS_VIROU, FALAS_TEMA = FALAS_TEMA,
    C = C, FALAS_CITACAO = FALAS_CITACAO, FALAS_REFERENCIA = FALAS_REFERENCIA }, Lingua.extra("memoria"))

return M
