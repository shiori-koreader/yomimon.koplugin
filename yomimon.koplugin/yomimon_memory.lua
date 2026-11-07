--[[--
Yomimon's memory: what the books do to it.

Every page eaten goes through here. It records:
- themes (death, love, sea, war…) by keywords, which change its phrases;
- characters (proper names that repeat) of each book, used in the Notebook comments;
- the diary: events of its life, written in its own voice.

Pure logic (no KOReader), testable outside it.
]]

local Language = require("yomimon_language")
local Diary = require("yomimon_diary")
local Voice = require("yomimon_voice")
local T = Language.t

local M = {}

-- Themes and the words that feed them (Portuguese and English, lowercase).
M.THEMES = {
    death = { "morte", "morrer", "morreu", "morto", "morta", "mortos", "túmulo", "enterro", "cadáver", "luto", "funeral",
              "death", "dead", "die", "died", "grave", "funeral", "corpse",
              "morrera", "buried" },
    love = { "amor", "amar", "amava", "amo", "beijo", "beijou", "paixão", "coração", "amante", "querida", "querido",
             "love", "loved", "kiss", "heart", "darling", "beloved",
             "amores", "noiva", "noivo", "noivas", "afeição", "afeições", "ternura", "beijar", "beijos", "beijava", "adorar", "adorava", "adoro" },
    war = { "guerra", "batalha", "soldado", "soldados", "exército", "inimigo", "arma", "armas", "tiro", "sangue",
               "war", "battle", "soldier", "army", "enemy", "gun", "blood",
               "guerreiro", "guerreiros" },
    sea = { "mar", "navio", "onda", "ondas", "praia", "barco", "marinheiro", "oceano", "porto", "naufrágio",
            "sea", "ship", "wave", "waves", "boat", "sailor", "ocean", "shore" },
    faith = { "deus", "deuses", "alma", "fé", "igreja", "oração", "rezar", "pecado", "céu", "inferno", "diabo",
           "god", "soul", "faith", "church", "prayer", "sin", "heaven", "hell",
           "sagrado", "sagrada" },
    money = { "dinheiro", "ouro", "rico", "rica", "pobre", "dívida", "banco", "preço", "herança", "fortuna",
                 "money", "gold", "rich", "poor", "debt", "bank", "price", "fortune",
                 "réis", "dote", "riqueza", "riquezas", "credor", "credores", "pounds", "salary" },
    madness = { "louco", "louca", "loucura", "delírio", "sonho", "sonhos", "pesadelo", "febre", "alucinação",
                "mad", "madness", "insane", "dream", "dreams", "nightmare", "fever" },
    time = { "tempo", "relógio", "anos", "memória", "lembrança", "passado", "saudade", "velho", "velha",
              "time", "clock", "years", "memory", "past", "old" },
    city = { "cidade", "rua", "ruas", "praça", "bonde", "café", "multidão", "esquina",
               "city", "street", "streets", "square", "crowd", "corner" },
    nature = { "árvore", "árvores", "floresta", "rio", "chuva", "vento", "flor", "flores", "campo", "pássaro",
                 "tree", "trees", "forest", "river", "rain", "wind", "flower", "field", "bird",
                 "folhas", "hill", "hills" },
    food = { "comida", "comer", "comeu", "pão", "vinho", "jantar", "almoço", "banquete", "fome", "cozinha", "sopa",
               "carne", "fruta", "açúcar", "food", "bread", "wine", "dinner", "supper", "kitchen", "soup", "meat" },
    family = { "família", "mãe", "pai", "irmão", "irmã", "filho", "filha", "avó", "avô", "herdeiro", "parentes",
                "family", "mother", "father", "brother", "sister", "son", "daughter", "heir",
                "marido", "maridos", "prima", "primo", "primas", "primos", "mamãe", "papai", "wife", "wives", "daughters", "parents", "cousin", "cousins", "relations" },
    childhood = { "infância", "criança", "crianças", "menino", "menina", "brincar", "brinquedo", "escola", "inocência",
                 "childhood", "child", "children", "boy", "girl", "toy", "school", "innocence",
                 "baby", "babies" },
    politics = { "rei", "rainha", "império", "governo", "revolução", "povo", "lei", "leis", "trono", "príncipe",
                 "ministro", "king", "queen", "empire", "government", "revolution", "law", "throne", "prince",
                 "partido", "partidos", "política", "político" },
    science = { "ciência", "experimento", "laboratório", "química", "máquina", "invenção", "eletricidade", "cientista",
                "anatomia", "science", "experiment", "laboratory", "chemistry", "machine", "invention", "electricity" },
    solitude = { "solidão", "sozinho", "sozinha", "isolado", "isolada", "silêncio", "abandono", "exílio", "ausência",
                "lonely", "alone", "solitude", "silence", "abandoned", "exile", "absence",
                "abandonado", "abandonada", "desamparo" },
    art = { "arte", "pintura", "poema", "poesia", "artista", "quadro", "teatro", "canção", "verso", "versos", "pintor",
             "art", "painting", "poem", "poetry", "artist", "theatre", "song", "verse", "painter",
             "music" },
    animals = { "cavalo", "cão", "cachorro", "gato", "lobo", "cobra", "baleia", "rato", "pássaros", "bicho",
                "horse", "dog", "cat", "wolf", "snake", "whale", "rat", "insect", "beast" },
    night = { "noite", "lua", "escuridão", "estrelas", "madrugada", "vela", "lampião", "crepúsculo",
              "night", "moon", "darkness", "stars", "midnight", "candle", "dusk" },
    travel = { "viagem", "caminho", "trem", "viajante", "horizonte", "jornada", "bagagem", "mapa", "estrangeiro",
               "travel", "path", "train", "traveller", "horizon", "luggage", "map", "foreign",
               "partiu", "caminhava", "caminhar" },
    revenge = { "vingança", "vingar", "ódio", "traição", "traiu", "rancor", "culpa", "castigo", "inimizade",
                 "revenge", "avenge", "hatred", "betrayal", "betrayed", "grudge", "guilt", "punishment" },
    freedom = { "liberdade", "livre", "livres", "prisão", "preso", "presa", "escravo", "escravidão", "correntes", "cativeiro",
                  "freedom", "free", "prison", "prisoner", "slave", "slavery", "chains", "captivity" },
    knowledge = { "livro", "livros", "ler", "leitura", "biblioteca", "saber", "verdade", "conhecimento", "filosofia", "estudo",
              "book", "books", "reading", "library", "knowledge", "truth", "philosophy", "study" },
    fear = { "medo", "terror", "pavor", "monstro", "fantasma", "assombrado", "grito", "arrepio", "assombração",
             "fear", "terror", "monster", "ghost", "haunted", "scream", "dread",
             "scared", "dreaded" },
}

-- Gender of each theme, to get "no mar", "pela morte", "de Deus" right…
local THEME_INFO = {
    death = { "a", "morte" }, love = { "o", "amor" }, war = { "a", "guerra" }, sea = { "o", "mar" },
    faith = { nil, "Deus" }, money = { "o", "dinheiro" }, madness = { "a", "loucura" }, time = { "o", "tempo" },
    city = { "a", "cidade" }, nature = { "o", "mato" },
    food = { "a", "comida" }, family = { "a", "família" }, childhood = { "a", "infância" },
    politics = { "a", "política" }, science = { "a", "ciência" }, solitude = { "a", "solidão" }, art = { "a", "arte" },
    animals = { "os", "bichos" }, night = { "a", "noite" }, travel = { "a", "viagem" }, revenge = { "a", "vingança" },
    freedom = { "a", "liberdade" }, knowledge = { "o", "saber" }, fear = { "o", "medo" },
}
local CONTRACTION = {
    em = { o = "no", a = "na", os = "nos", as = "nas" }, de = { o = "do", a = "da", os = "dos", as = "das" },
    por = { o = "pelo", a = "pela", os = "pelos", as = "pelas" }, a = { o = "ao", a = "à", os = "aos", as = "às" },
}

--- Theme name with article and contracted preposition: M.theme("mar", "em") → "no mar".
function M.theme(t, prep)
    local info = THEME_INFO[t]
    if not info then return t end
    local art, nameText = info[1], info[2]
    if not prep then return art and (art .. " " .. nameText) or nameText end
    if art then return CONTRACTION[prep][art] .. " " .. nameText end
    return prep .. " " .. nameText
end

M.THEME_NAMES = {}
for t in pairs(THEME_INFO) do M.THEME_NAMES[t] = M.theme(t) end

-- Pairs that, together, leave it divided.
local OPPOSITES = { love = "war", war = "love", faith = "madness", madness = "faith", city = "nature",
                  nature = "city", money = "faith", family = "solitude", solitude = "family",
                  freedom = "politics", politics = "freedom", childhood = "death", science = "faith",
                  revenge = "love", art = "money", knowledge = "fear", fear = "knowledge" }

-- Words too common to make a theme by themselves ("old", "time", "night", "mother"):
-- they only count with another word of the same theme on the page (or repeated 3+ times).
local GENERICS = {}
for p in ([[tempo anos velho velha time years old rua ruas multidão street streets crowd corner square
    menino menina criança crianças escola boy girl child children school noite lua vela estrelas night moon candle
    stars livro livros ler leitura saber verdade estudo book books reading truth study pobre rico rica banco preço
    ouro poor rich bank price gold fortune mãe pai filho filha irmão irmã mother father son daughter brother sister
    coração heart alma céu deus soul heaven god livre livres free sangue inimigo blood enemy grave dead onda praia
    barco porto shore boat wave flor flores vento rio campo pássaro árvore wind river field bird tree flower
    jantar almoço cozinha vinho pão dinner supper kitchen wine bread rei rainha príncipe povo lei king queen prince
    law teatro canção quadro verso theatre song art verse sonho sonhos febre dream dreams fever culpa guilt
    silêncio silence alone sozinho caminho path cavalo cão horse dog marido maridos wife wives prima primo primas primos]]):gmatch("[%a\128-\255]+") do GENERICS[p] = true end

local index = {}
for theme, words in pairs(M.THEMES) do
    for _, p in ipairs(words) do index[p] = theme end
end

-- Events: groups of words that indicate something happening on the page.
M.EVENTS = {
    death = { "morreu", "morrera", "morto", "morta", "enterro", "enterraram", "caixão", "luto", "velório", "funeral",
              "cadáver", "faleceu", "died", "dead", "coffin", "buried", "corpse",
              "death" },
    wedding = { "casamento", "casaram", "casou", "noiva", "noivo", "altar", "núpcias", "aliança",
                  "wedding", "married", "bride", "groom",
                  "matrimônio", "marriage" },
    travel = { "partiu", "partida", "viagem", "viajou", "estrada", "carruagem", "chegou", "chegada", "embarcou",
               "journey", "departed", "voyage", "road", "carriage", "arrived",
               "partiram", "partir", "drove" },
    letter = { "carta", "cartas", "escreveu", "envelope", "bilhete", "correio", "letter", "letters", "wrote",
              "seal" },
    storm = { "tempestade", "trovão", "relâmpago", "relâmpagos", "ventania", "temporal", "storm", "thunder", "lightning", "gale",
                   "trovoada" },
    illness = { "doença", "doente", "febre", "médico", "tosse", "enfermo", "leito", "illness", "sick", "fever", "doctor", "cough" },
    party = { "festa", "baile", "dança", "dançaram", "banquete", "música", "party", "ball", "dance", "feast", "music" },
    quarrel = { "briga", "brigaram", "discussão", "gritou", "insulto", "insultou", "quarrel", "argued", "shouted", "insult" },
    escape = { "fugiu", "fuga", "escapou", "escondeu", "perseguição", "fled", "escape", "escaped", "hid", "chase",
             "fugir", "fugiram" },
    crime = { "crime", "assassinato", "matou", "assassino", "roubo", "polícia", "murder", "killed", "murderer", "theft", "police" },
}
local event_index = {}
for ev, words in pairs(M.EVENTS) do
    for _, p in ipairs(words) do event_index[p] = ev end
end

-- Chapter subjects, for the cards (yomimon_data/topics.lua): counted like the events. A single word
-- also matches its plural (-s, -es); a multi-word expression counts as a sequence, unless it contains
-- a word of the list itself ("great-grandfather" already counts as "grandfather").
local okSubjects, SUBJECTS = pcall(require, "yomimon_data.topics")
M.SUBJECTS = okSubjects and type(SUBJECTS) == "table" and SUBJECTS or {}
local subject_index, subject_sentences = {}, {}
for as, words in pairs(M.SUBJECTS) do
    local loose = {}
    for _, p in ipairs(words) do if not p:find("[^%a\128-\255]") then loose[p] = true end end
    for _, p in ipairs(words) do
        if loose[p] then
            for _, f in ipairs({ p, p .. "s", p .. "es" }) do subject_index[f] = subject_index[f] or as end
        else
            local seq, contained = {}, false
            for w in p:gmatch("[%a\128-\255]+") do
                seq[#seq + 1] = w
                if loose[w] then contained = true end
            end
            if #seq > 1 and not contained then subject_sentences[#subject_sentences + 1] = { subject = as, seq = seq, nameText = p } end
        end
    end
end
table.sort(subject_sentences, function(a, b) return a.nameText < b.nameText end)
-- counts the expressions in the word sequence ws (1..n): calls found_it(subject, expression) for each one
local function subjectSentences(ws, n, found_it)
    for _, f in ipairs(subject_sentences) do
        local k = #f.seq
        for i = 1, n - k + 1 do
            local equal = true
            for j = 1, k do
                if ws[i + j - 1] ~= f.seq[j] then equal = false; break end
            end
            if equal then found_it(f.subject, f.nameText) end
        end
    end
end

-- Weather: words that warm (+1) or cool (-1) the page.
local WEATHER = {}
for p in ([[feliz alegria riso riu sorriu sorriso belo bela doce esperança paz luz gentil carinho ternura
    felicidade happy joy smile smiled laugh laughed beautiful sweet hope peace light kind gentle delighted delight]]):gmatch("%S+") do WEATHER[p] = 1 end
for p in ([[triste tristeza dor medo chorou choro lágrimas escuro sombra ódio raiva sofrimento desespero frio
    angústia horror melancolia infeliz infelizes sad pain fear cried tears dark shadow hate anger suffering despair
    cold horror dread grief weep weeping]]):gmatch("%S+") do WEATHER[p] = -1 end

-- Old Portuguese spelling (almost all of the public domain: "sciencia", "philosophia", "lagryma",
-- "afflicção", "egreja"). A word that is not in the lists is also looked up in its modernised form:
-- no accent, ph→f, th→t, y→i, sc→c at the start, doubled consonants become one (except ss and rr).
-- Only on Portuguese pages: in English "three" would become "tree" and "good" would become "god".
local NO_ACCENT = { ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["é"] = "e", ["ê"] = "e", ["í"] = "i",
    ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ü"] = "u", ["ç"] = "c" }
local FIXED_SPELLING = { egreja = "igreja", egrejas = "igrejas", pae = "pai", paes = "pais" }
local function modernSpelling(w)
    w = w:gsub("\195[\128-\191]", NO_ACCENT):gsub("ph", "f"):gsub("th", "t"):gsub("y", "i"):gsub("^sc([ei])", "c%1")
    w = w:gsub("([b-df-hj-np-tv-z])%1", function(c) if c == "s" or c == "r" then return c .. c end return c end)
    return FIXED_SPELLING[w] or w
end
-- parallel index by the modern form; a form that falls in two different groups is left out
local function modernIndex(map)
    local out, conflict = {}, {}
    for p, v in pairs(map) do
        local m = modernSpelling(p)
        if out[m] ~= nil and out[m] ~= v then conflict[m] = true end
        out[m] = v
    end
    for m in pairs(conflict) do out[m] = nil end
    return out
end
local mod_index, event_mod, weather_mod = modernIndex(index), modernIndex(event_index), modernIndex(WEATHER)
local subject_mod = modernIndex(subject_index)
local GENERICS_MOD = {}
for p in pairs(GENERICS) do GENERICS_MOD[modernSpelling(p)] = true end
local function generic(w) return GENERICS[w] or GENERICS_MOD[modernSpelling(w)] or false end
M.modernSpelling = modernSpelling  -- used by the dictionaries and the tools

-- The book's own words --------------------------------------------------
-- Candidates: lowercase (a proper name never enters), 5 letters or more, letters only, outside the
-- language's common words (yomimon_common_words.lua, generated from the corpus) and outside adverbs and
-- offensive words the classics use. In Portuguese, the comparison with the common ones uses modern spelling.
local okCommons, COMMONS = pcall(require, "yomimon_common_words")
COMMONS = okCommons and type(COMMONS) == "table" and COMMONS or nil
local OFFENSIVE = {}
for p in ([[nigger niggers nigga niggas negro negroes darkie darkies coolie coolies squaw squaws savage savages
            crioulo crioula crioulos crioulas negrinho negrinha negrinhos negrinhas mulato mulata mulatos mulatas
            selvagem selvagens bugre bugres]]):gmatch("%S+") do OFFENSIVE[p] = true end
-- To be striking, the word must appear at least once right after an article or possessive
-- ("o seminário", "the harpoon"): the cheap way to keep nouns and leave out verbs
-- and adverbs ("montou", "afterward"). Per book both counts are kept: vocab (all) and vocab_art.
local DETERMINERS = {}
for p in ([[the a an this that these those his her my your their our its some no every
            o a os as um uma uns umas do da dos das no na nos nas ao aos pelo pela pelos pelas seu sua seus suas
            meu minha meus minhas teu tua este esta estes estas esse essa esses essas aquele aquela aqueles aquelas
            num numa dum duma]]):gmatch("%S+") do DETERMINERS[p] = true end
M.VOCAB_MAX, M.VOCAB_PRUNED = 150, 100   -- per book: past 150 words, the 100 most counted stay
M.VOCAB_FINISHED = 20                       -- a finished book keeps only the 20 most counted
M.STRIKING_MIN = 3                     -- times in the book for the word to be striking

--- Can the word be striking? (w as it is in the text; pt = Portuguese page)
function M.candidate(w, pt)
    if not COMMONS or not (w:find("^%l") or w:find("^\195[\160-\191]")) then return false end
    if not w:find("^[%a\128-\255]+$") or #w - select(2, w:gsub("[\128-\191]", "")) < 5 then return false end
    if OFFENSIVE[w] then return false end
    if pt then
        if w:find("mente$") or COMMONS.pt[modernSpelling(w)] then return false end
    elseif (#w >= 7 and w:find("ly$")) or COMMONS.en[w] then
        return false
    end
    return true
end

-- Strength of a word in the book: all the times, plus the times after an article.
local function strength(L, w) return (L.vocab[w] or 0) + ((L.vocab_art or {})[w] or 0) end

--- Keeps in the book's vocabulary only the `n` strongest words.
function M.pruneVocab(L, n)
    local list = {}
    for w in pairs(L.vocab or {}) do list[#list + 1] = { w, strength(L, w) } end
    if #list <= n then return end
    table.sort(list, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    local new, new_art = {}, {}
    for i = 1, n do
        local w = list[i][1]
        new[w], new_art[w] = L.vocab[w], (L.vocab_art or {})[w]
    end
    L.vocab, L.vocab_art = new, new_art
end

-- Weather by sentiment dictionary: VADER (English, MIT) and SentiLex-PT 02 (Portuguese, CC-BY 4.0).
-- Page score = sum of valences per 100 words ("não"/"never" invert the next 3), and the
-- weather is that score centred on the language's median and divided by the corpus' central half-range
-- (yomimon_weather_calibration.lua): a typical page ~0, the 30% gloomiest or lightest go past ±1.
-- Without the dictionaries, it falls back to the short word list (WEATHER).
local okEnglish, LEX_EN = pcall(require, "yomimon_lexicon_en")
local okPortuguese, LEX_PT = pcall(require, "yomimon_lexicon_pt")
local okCalibration, WEATHER_CAL = pcall(require, "yomimon_weather_calibration")
local LEXICON = { en = okEnglish and LEX_EN or nil, pt = okPortuguese and LEX_PT or nil }
M.WEATHER_CALIBRATION = okCalibration and WEATHER_CAL or nil
local NEGATION = {}
for w in ("no not never none nobody nothing neither nor nowhere cannot without não nunca jamais nem nada nenhum nenhuma ninguém sem"):gmatch("%S+") do
    NEGATION[w] = true
end
--- Sentiment score (per 100 words) of an already clean text, or nil if there is no dictionary for the language.
function M.sentiment(clean, pt)
    local lex = LEXICON[pt and "pt" or "en"]
    if not lex then return nil end
    local sum, n, neg = 0, 0, 0
    for w in clean:gmatch("[%a\128-\255]+") do
        n = n + 1
        if NEGATION[w] then neg = 3
        else
            local v = lex[pt and modernSpelling(w) or w]
            if v then sum = sum + (neg > 0 and -v or v) end
            if neg > 0 then neg = neg - 1 end
        end
    end
    return n > 0 and sum * 100 / n or 0
end
local function themeOf(w, pt) return index[w] or (pt and mod_index[modernSpelling(w)]) or nil end
local function eventOf(w, pt) return event_index[w] or (pt and event_mod[modernSpelling(w)]) or nil end
local function subjectOf(w, pt) return subject_index[w] or (pt and subject_mod[modernSpelling(w)]) or nil end
local function weatherOf(w, pt) return WEATHER[w] or (pt and weather_mod[modernSpelling(w)]) or nil end
-- Language of the page by the most common words of each.
local FUNCTIONAL = {}
for p in ("que não uma com para ele ela elle ella mas como seu sua dos das pelo pela"):gmatch("%S+") do FUNCTIONAL[p] = "pt" end
for p in ("the and was with that his her which this have from were they would"):gmatch("%S+") do FUNCTIONAL[p] = "en" end
local function inPortuguese(clean)
    local pt, en = 0, 0
    for w in clean:gmatch("[%a\128-\255]+") do
        local l = FUNCTIONAL[w]
        if l == "pt" then pt = pt + 1 elseif l == "en" then en = en + 1 end
    end
    return pt > en
end
-- Specificity weight (yomimon_topic_weights.lua): a theme that appears in almost every book ("family",
-- "time") adds less to the memory of the book, chapter, day and its own; a rare theme adds more.
-- Per-page detection does not change.
local okWeights, WEIGHTS = pcall(require, "yomimon_topic_weights")
M.WEIGHTS = okWeights and type(WEIGHTS) == "table" and WEIGHTS or {}
function M.themeWeight(t, pt) return (M.WEIGHTS[pt and "pt" or "en"] or {})[t] or 1 end

-- for the validation tool to show what triggered each theme
function M.wordTheme(w, textValue) return themeOf(w, textValue and inPortuguese(M.clear(textValue))) end

-- Words before a name that indicate a place ("em Genebra", "para Londres").
local PLACE_PREP = {}
for p in ("em no na in at into"):gmatch("%S+") do PLACE_PREP[p] = true end

-- Speech verbs ("disse Victor", "Victor perguntou").
local SPEECH_VERB = {}
for p in ([[disse dizia perguntou respondeu gritou murmurou exclamou sussurrou falou continuou acrescentou
    retrucou tornou replicou said says asked replied shouted whispered cried continued added answered
    exclaimed observed remarked rejoined repeated]]):gmatch("%S+") do SPEECH_VERB[p] = true end

-- Capitalised words that are not characters.
local NOT_NAMES = {}
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
    NOT_NAMES[p] = true
end

-- Theatre: roles that, as a speech label ("KING.", "NURSE."), are characters even though common words.
local THEATRE_ROLE = {}
for p in ("King Queen Prince Princess Duke Lord Lady Ghost Nurse Porter Servant Doctor Captain Friar Clown Messenger"):gmatch("%S+") do
    THEATRE_ROLE[p] = true
end

-- Abbreviations followed by a full stop that do not end the sentence ("Mr. Collins", "D. Glória").
local ABBREVIATION = {}
for p in ("Mr Mrs Ms Dr Drs St Sr Sra Srs Srta Prof Exmo Exma Revd Rev Gen Col Capt Lt Jr"):gmatch("%S+") do
    ABBREVIATION[p] = true
end

-- Words that, right before a name, make it a place ("Rio Comprido", "rua dos Inválidos").
local BEFORE_PLACE = {}
for p in ([[rio rua praia largo travessa morro serra ilha lagoa monte lago cabo porto forte bairro engenho
    fazenda river mount lake cape fort port isle island vale sertão chapada ribeirão enseada baía cidade vila
    county valley bay gulf são santa santo san]]):gmatch("[%a\128-\255]+") do BEFORE_PLACE[p] = true end

-- Titles before a name ("Dona Glória", "Mr. Darcy"): they count as proof that it is a person.
local TITLES = {}
for p in ([[Sr Sra Srta Dona Dom Dr Dra Seu Sinhá Sinhô Padre Frei Irmã Irmão Tio Tia Capitão Coronel Major Conde
    Condessa Barão Mr Mrs Miss Ms Dr Sir Lady Lord Captain Colonel Uncle Aunt Madame Monsieur Mademoiselle
    Mister Señor D Professor Professora Prof]]):gmatch("[%a\128-\255]+") do TITLES[p] = true end

-- Famous people, myths and works: they appear capitalised, but are quotations, not characters.
-- (If the name is in the book's title, then it is a character: reading "Hamlet", Hamlet counts.)
local REFERENCES = {}
for p in ([[Shakespeare Hamlet Homero Homer Dante Cervantes Goethe Tolstói Tolstoi Tolstoy Dostoiévski Dostoevsky
    Kafka Proust Joyce Camões Saramago Eça Alencar Drummond Lispector Borges Neruda Nietzsche Kant Descartes
    Platão Plato Aristóteles Aristotle Sócrates Socrates Marx Freud Jung Darwin Einstein Newton Galileu Galileo
    Copérnico Voltaire Rousseau Montaigne Balzac Flaubert Zola Baudelaire Rimbaud Byron Milton Chaucer Dickens
    Austen Wilde Poe Twain Melville Hemingway Faulkner Woolf Orwell Huxley Hitler Stalin Napoleão Napoleon
    Mussolini Lenin César Caesar Cleópatra Cleopatra Churchill Jesus Cristo Christ Maomé Buda Buddha Moisés
    Moses Bíblia Bible Corão Alcorão Torá Mozart Beethoven Bach Wagner Chopin Picasso Michelangelo Rembrandt
    Ulisses Ulysses Odisseu Quixote Fausto Faust Édipo Oedipus Prometeu Prometheus Narciso Vênus Venus Zeus
    Apolo Júpiter Jupiter Satanás Satan Lúcifer Lucifer]]):gmatch("[%a\128-\255]+") do REFERENCES[p] = true end

-- Known places (countries, cities, regions, rivers): never characters.
local KNOWN_PLACES = {}
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
    KNOWN_PLACES[p] = true
end

-- Known cities (GeoNames, CC-BY 4.0; 50 thousand+ inhabitants): such a name only becomes a character with proof
-- (speech, title, person verb). It never excludes alone: Elizabeth, Charlotte, Paris and Hamilton are cities.
local okCities, CITIES = pcall(require, "yomimon_cities")
CITIES = okCities and type(CITIES) == "table" and CITIES or {}

-- Words that, right after a name, make it a place ("Baker Street", "Rua do Ouvidor").
local AFTER_PLACE = {}
for p in ([[Street Road Lane Square Avenue Hall House Lodge Park Abbey Manor Castle Court Place Bridge Inn
    Hotel Hill Heights Grange Rua Avenida Praça Largo Travessa Estrada Fazenda Engenho
    Valley Valleys River Rivers County Bay Creek Canyon Ranch Mountains Mountain Range Coast Island Islands
    Desert Forest Woods Plains Springs Falls Harbor Harbour Peninsula Gulf Ocean Strait Channel Ridge Moor
    Moors Marsh Heath Downs]]):gmatch("[%a\128-\255]+") do AFTER_PLACE[p] = true end

-- Verbs that, right after a name, show it is a person ("Capitu olhou", "Victor fled").
local PERSON_VERB = {}
for p in ([[disse falou perguntou respondeu gritou murmurou sussurrou olhou sorriu riu chorou pensou sentiu
    suspirou voltou saiu entrou chegou partiu morreu matou beijou abraçou correu levantou sentou parou viu ouviu
    lembrou acordou dormiu tremeu hesitou insistiu continuou pegou segurou abriu fechou quis sabia amava odiava
    said asked replied cried shouted whispered murmured looked smiled laughed wept thought felt sighed turned
    walked ran came went left returned died killed kissed sat stood saw heard remembered woke slept trembled
    hesitated nodded frowned took gave held opened closed wanted knew loved hated]]):gmatch("[%a\128-\255]+") do
    PERSON_VERB[p] = true
end

-- First person: many of these words = a narrator who talks about themselves.
local FIRST_PERSON_WORDS = {}
for p in ("eu me mim comigo meu minha meus minhas i my mine myself"):gmatch("%S+") do FIRST_PERSON_WORDS[p] = true end
-- Gender of the narrator (Portuguese): "eu estava cansada", "fiquei sozinho", "sou mulher".
local COPULA_I = {}      -- only exist in the first person
for p in ("sou estou fiquei fui estive senti sinto"):gmatch("%S+") do COPULA_I[p] = true end
local COPULA_MAYBE = {}  -- first or third person: they only count after "eu"/"me"
for p in ("era estava ficava seria sentia"):gmatch("%S+") do COPULA_MAYBE[p] = true end
local INTENSIFIES = {}
for p in ("muito tão meio bem mais ainda um uma toda todo completamente"):gmatch("%S+") do INTENSIFIES[p] = true end
local GENDER_WORD = {}
for p in ("mulher moça menina senhora velha nova sozinha bonita linda feia viúva grávida tola louca"):gmatch("%S+") do GENDER_WORD[p] = "f" end
for p in ("homem rapaz menino senhor velho novo sozinho bonito lindo feio viúvo tolo louco"):gmatch("%S+") do GENDER_WORD[p] = "m" end

local function genderOf(w)
    if GENDER_WORD[w] then return GENDER_WORD[w] end
    if #w < 5 then return nil end
    if w:find("ada$") or w:find("ida$") or w:find("osa$") or w:find("inha$") then return "f" end
    if w:find("ado$") or w:find("ido$") or w:find("oso$") or w:find("inho$") then return "m" end
end

-- Set phrases that would fool the count ("morrer de rir" is not about death).
local EXPRESSIONS = {
    "morr%a* de rir", "mort[oa]s? de cansaço", "mort[oa]s? de fome", "mort[oa]s? de vergonha", "morr%a* de medo",
    "mar de gente", "mar de rosas", "guerra fria", "pelo amor de deus", "meu deus", "graças a deus",
    "deus me livre", "ao deus dará", "tempo todo", "de vez em quando", "dead tired", "oh my god",
    "scared to death", "bored to death", "dying to", "sea of faces", "cold war", "for god's sake",
    "thank god", "god knows", "all the time", "from time to time", "in no time", "heart of gold",
}

--- Lowercase text without the set phrases.
function M.clear(textValue)
    local t = textValue:lower()
    for _, e in ipairs(EXPRESSIONS) do t = t:gsub(e, " ") end
    return t
end

local DIARY_MAX = 150
M.THEME_FORGETTING = 0.998  -- per page (half-life ~350 pages, the same as the traits)
local STRETCH_PAGES = 25   -- huge chapter (or a book without a table of contents): every 25 pages counts as a new stretch

local function draws(list, draw)
    return list[(draw or math.random)(#list)]
end

local function ensure(s)
    s.themes = s.themes or {}
    s.books = s.books or {}
    s.diary = s.diary or {}
end

--- Writes in the diary (the newest goes at the end).
function M.note(s, now, textValue)
    ensure(s)
    textValue = (Voice.resolver(textValue, s))  -- the diary is written in its way of the day
    table.insert(s.diary, { t = now, textValue = textValue })
    while #s.diary > DIARY_MAX do table.remove(s.diary, 1) end
end

--- The two strongest themes (name, points), or nil.
function M.strongThemes(s)
    local list = {}
    for theme, pts in pairs(s.themes or {}) do list[#list + 1] = { theme, pts } end
    table.sort(list, function(a, b) return a[2] > b[2] end)
    return list[1], list[2]
end

--- Is it divided between two strong opposite themes?
function M.ambivalent(s)
    local a, b = M.strongThemes(s)
    if not (a and b) or b[2] < 15 then return nil end
    if OPPOSITES[a[1]] == b[1] and b[2] >= a[2] * 0.6 then return a[1], b[1] end
end

--- Characters of a book, most cited first (only those who appear at least 3 times). Each one:
-- { nameText, times, speeches, chapters, protagonist, forms (all names of the person) }.
-- Since 27/10/2026, from the evidence in L.names (charactersNew); a finished book keeps only the final list.
-- Books read before that (without L.names) follow the old rule, below.
function M.charactersInfo(s, book)
    local L = book and s.books and s.books[book]
    if not L then return {} end
    if L.characters_end then return L.characters_end end  -- finished (on a re-read, until it is finished again)
    if L.names then return (M._charactersNew(L, book)) end
    -- old rule: "Sherlock Holmes": the first and last name become a single person (the most cited form)
    local nickname = {}
    for b, a in pairs(L.surname or {}) do
        if (L.chars[a] or 0) >= (L.chars[b] or 0) then nickname[b] = a else nickname[a] = b end
    end
    local total = {}
    for nameText, c in pairs(L.chars or {}) do
        nameText = nickname[nameText] or nameText
        if (L.places or {})[nameText] == nil or (L.places[nameText] < (L.chars[nameText] or 0)) then
            total[nameText] = (total[nameText] or 0) + c
        end
    end
    local n_capitals, caps_of = 0, {}
    for _, C in pairs(L.caps or {}) do
        n_capitals = n_capitals + 1
        for nameText in pairs(C.chars or {}) do caps_of[nameText] = (caps_of[nameText] or 0) + 1 end
    end
    local list = {}
    for nameText, c in pairs(total) do
        local proof = ((L.proof or {})[nameText] or 0) + ((L.spoke or {})[nameText] or 0)
        local pages = (L.pages_seen or {})[nameText] or 0
        -- suspected of not being a person (known city, or usually comes with an article: "the Nautilus",
        -- "os Tupinambás"): only with proof, never just for appearing a lot
        local suspect = CITIES[nameText] or ((L.thing or {})[nameText] or 0) * 2 >= c
        if (c >= 3 and proof >= 1) or (not suspect and c >= 5 and pages >= 3) then
            list[#list + 1] = {
                nameText = nameText, times = c, speeches = (L.spoke or {})[nameText] or 0, chapters = caps_of[nameText] or 0,
                protagonist = n_capitals >= 3 and (caps_of[nameText] or 0) >= n_capitals * 0.6, forms = { nameText },
            }
        end
    end
    table.sort(list, function(a, b) return a.times > b.times end)
    return list
end

--- The striking words of a book (step 5): 3+ times in it and at least one after an article, from the
-- strongest to the weakest, except those that are also in the vocabulary of 2 or more other books of its own
-- (those are its own, not the book's). Up to `n`.
function M.strikings(s, book, n)
    local L = book and s.books and s.books[book]
    if not (L and L.vocab) then return {} end
    local others = {}
    for nameText, O in pairs(s.books) do
        if nameText ~= book and O.vocab then for w in pairs(O.vocab) do others[w] = (others[w] or 0) + 1 end end
    end
    local list = {}
    for w, c in pairs(L.vocab) do
        if c >= M.STRIKING_MIN and ((L.vocab_art or {})[w] or 0) >= 1 and (others[w] or 0) < 2 and not OFFENSIVE[w] then
            list[#list + 1] = { w, strength(L, w) }
        end
    end
    table.sort(list, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    local out = {}
    for i = 1, math.min(n or 10, #list) do out[i] = list[i][1] end
    return out
end

function M.characters(s, book, n)
    local out = {}
    for i, p in ipairs(M.charactersInfo(s, book)) do
        if i > (n or 5) then break end
        out[i] = p.nameText
    end
    return out
end

local function capital(w)
    local b1, b2 = w:byte(1), w:byte(2)
    if not b1 then return false end
    if b1 >= 65 and b1 <= 90 then return true end
    return b1 == 195 and b2 and b2 >= 128 and b2 <= 158  -- À…Þ in UTF-8
end

local function accumulate(t, k, v) t[k] = (t[k] or 0) + (v or 1) end

-- Names with evidence (since 27/10/2026) --------------------------------------------------------
-- Each page notes the names (also multi-word ones: "Petra Cotes", "Paulo Afonso") and the clues
-- that came with each one, by rule. Who is a person, who is a place and who is the same person is only decided
-- at query time, with the evidence of the whole book (charactersNew).

local function lowercased(w)
    return (w:lower():gsub("\195([\128-\158])", function(c) return "\195" .. string.char(c:byte() + 32) end))
end

-- title before the name → gender ("m", "f" or false); compared in lowercase ("madama Carlota", "lady Madeline")
local TITLE_GENDER = {}
for p in ([[seu sinhô dom sr senhor doutor dr padre frei coronel capitão tenente sargento cabo major general comandante
    tio compadre mestre professor conselheiro barão conde marquês visconde rei príncipe sir mr mister monsieur lord
    captain colonel doctor uncle king prince count duke father brother commander master lieutenant sergeant inspector
    reverend]]):gmatch("%S+") do TITLE_GENDER[p] = "m" end
for p in ([[dona sinhá sra srta senhora doutora dra madama madame irmã tia comadre professora baronesa condessa marquesa
    viscondessa rainha princesa lady mrs miss mademoiselle aunt queen princess countess duchess mother sister]]):gmatch("%S+") do
    TITLE_GENDER[p] = "f"
end
TITLE_GENDER.d, TITLE_GENDER.ms = false, "f"
local INTERJECTIONS = {}
for p in ("Ah Oh Ó Ai Eh Ei Olá Oi Hein Hem Ui Psiu Oba Opa Ué Uai Arre Ora Hum Puxa Credo Ufa Ha Ho Hey Alas"):gmatch("%S+") do
    INTERJECTIONS[p] = true
end
local NAME_CONNECTOR = {}
for p in ("de da do das dos del la los las"):gmatch("%S+") do NAME_CONNECTOR[p] = true end
local EXTRA_SPEECH, EXTRA_PERSON = {}, {}
for p in ([[retrucou replicou explicou indagou berrou bradou declarou concordou protestou admitiu prosseguiu completou
    interrompeu acudiu tornou observou ponderou atalhou volveu dissera falara gemeu queixou]]):gmatch("%S+") do EXTRA_SPEECH[p] = true end
for p in ([[mandou contou atendeu achou trocou observava comia comeu bebia bebeu chegara sorria chorava olhava pensava
    sentia dizia queria gostava amou casou nasceu rezou rezava cantou cantava dançou escreveu leu beijava abraçava fumava
    fumou dormia acordava sonhou sonhava piscou corou gemia soluçou tossiu ajoelhou virou aproximou despediu agradeceu
    prometeu jurou decidiu resolveu esperou esperava calou calava ouvia escutava lia escrevia caminhou fugiu
    voltara saíra entrara morrera nascera]]):gmatch("%S+") do EXTRA_PERSON[p] = true end
local PERSON_NAME = {}
for p in ([[homem mulher moça moço rapaz menina menino velho velha senhor senhora sargento tenente coronel padre médico
    médica datilógrafa cartomante preso criada criado escravo escrava viúva viúvo noiva noivo marido esposa filho filha
    pai mãe irmão irmã tio tia avô avó amigo amiga cigano cigana patrão patroa]]):gmatch("%S+") do PERSON_NAME[p] = true end
local PLACE_BEFORE = {}  -- "cidade de Recife", "rua do Ouvidor", "estado de Sergipe" ("fazenda de Fulano" belongs to someone)
for p in ([[estado cidade vila povoado município rio serra rua praça largo bairro sertão capital porto ilha lagoa morro
    travessa avenida aldeia arraial chapada ribeirão enseada baía praia cabo forte river mount lake cape fort port isle
    island valley bay gulf county]]):gmatch("%S+") do PLACE_BEFORE[p] = true end
local SAINT = { ["são"] = true, santo = true, santa = true, san = true }
local BR_STATES = {}
for p in ([[Acre Alagoas Amapá Amazonas Bahia Ceará Goiás Maranhão Pará Paraíba Paraná Pernambuco Piauí Rondônia Roraima
    Sergipe Tocantins]]):gmatch("%S+") do BR_STATES[p] = true end
local COMPOUND_STATES = { ["Espírito Santo"] = true, ["Mato Grosso"] = true, ["Minas Gerais"] = true,
    ["Rio de Janeiro"] = true, ["Rio Grande do Norte"] = true, ["Rio Grande do Sul"] = true, ["Santa Catarina"] = true,
    ["São Paulo"] = true, ["Distrito Federal"] = true }
local PREPOSITION = {}
for p in ("de da do em para com por in at of to from with by"):gmatch("%S+") do PREPOSITION[p] = true end

-- Weight of each rule: for being a person, for being a place, and against being a name (common word, quotation)
local PERSON_WEIGHT = { titleText = 2, speech = 2, verb = 1, vocative = 1.5, apposition = 1.5 }
local PLACE_WEIGHT = { place = 2, route = 2, saint = 1, locative = 0.5 }
local NAME_FORMS_MAX = 150     -- forms kept per book while reading (those seen once go first)
local MIN_MENTIONS = 3

local function verbBase(w)
    return (lowercased(w):gsub("%-[%a\128-\255]+$", ""))  -- "levantou-se" → "levantou"
end
local function isSpeech(w) local b = verbBase(w) return SPEECH_VERB[b] or EXTRA_SPEECH[b] end
local function isPerson(w) local b = verbBase(w) return PERSON_VERB[b] or EXTRA_PERSON[b] or isSpeech(w) end

local function candidateName(tk)
    local w = tk.w
    return capital(w) and #w >= 2 and not w:find("^[%u%p]+$") and not NOT_NAMES[w] and not INTERJECTIONS[w]
        and TITLE_GENDER[lowercased(w)] == nil and not ABBREVIATION[w]  -- "St." of St. John is not a name
end

--- Names on a page, with the clues of each one (toks: the words of M.signals).
-- Returns { [form] = { n, ini, middle, ev = { rule = times }, gen = { m, f } } } and the sentences with
-- names where one is the start of another ("Macabéa, a minha querida Maca"), so as not to join two people.
local function pageNames(toks, dialogue)
    local names, joined = {}, {}
    local per_sentence, sentence = {}, 0
    local i = 1
    while i <= #toks do
        local tk = toks[i]
        if tk.beginning then sentence = sentence + 1 end
        if candidateName(tk) then
            local j = i
            while j - i < 5 and not toks[j].punct do  -- joins "Petra Cotes", "Olímpico de Jesus Moreira Chaves"
                local k = j + 1
                while k <= #toks and NAME_CONNECTOR[toks[k].w] and not toks[k].punct and not toks[k].opens do k = k + 1 end
                local nextItem = toks[k]
                if nextItem and not nextItem.opens and not nextItem.beginning and candidateName(nextItem) and nextItem.w ~= toks[j].w
                        and (k == j + 1 or not toks[k - 1].punct) then
                    j = k
                else
                    break
                end
            end
            local parts = {}
            for k = i, j do parts[#parts + 1] = toks[k].w end
            local form = table.concat(parts, " ")
            local d = names[form] or { n = 0, ini = 0, middle = 0, ev = {}, gen = {} }
            names[form] = d
            d.n = d.n + 1
            if tk.beginning then d.ini = d.ini + 1 else d.middle = d.middle + 1 end
            local p, pp, n1, n2, n3 = toks[i - 1], toks[i - 2], toks[j + 1], toks[j + 2], toks[j + 3]
            local lastItem = toks[j]
            local stuck_before = p and not p.punct and not tk.opens
            local stuck_after = n1 and not lastItem.punct and not n1.opens
            local pl = p and lowercased(p.w)
            -- title before ("madama Carlota", "D. Plácida", "Seu Nestor")
            if p and TITLE_GENDER[pl] ~= nil and not tk.opens and (not p.punct or (p.point and #p.w <= 4)) then
                accumulate(d.ev, "titleText")
                if TITLE_GENDER[pl] then accumulate(d.gen, TITLE_GENDER[pl]) end
            end
            -- who speaks, or does something human right after the name
            -- ("said the Hatter", "disse o Paulo": the speech verb comes before the article)
            local article_before = stuck_before and (pl == "the" or pl == "o" or pl == "a") and pp and not pp.punct
            if (stuck_before and isSpeech(p.w)) or (stuck_after and isSpeech(n1.w)) or (article_before and isSpeech(pp.w)) then
                accumulate(d.ev, "speech")
            elseif stuck_after and isPerson(n1.w) and not (stuck_before and PREPOSITION[pl]) then
                accumulate(d.ev, "verb")
            end
            -- called by name in a line of speech: "– Maca, o quê?", "Logo ela, Maca?"
            local ending = lastItem.raw:sub(-1)
            if (tk.beginning and dialogue > 0 and (ending == "," or ending == "?" or ending == "!") and not (n1 and candidateName(n1)))
                    or (p and p.raw:sub(-1) == "," and (ending == "?" or ending == "!")) then
                accumulate(d.ev, "vocative")
            end
            -- apposition: "Carlota, a cartomante" (not "Amaranta, o coronel Aureliano", which is a list)
            if ending == "," and n1 and n2 and not n1.punct and (n1.w == "o" or n1.w == "a" or n1.w == "um" or n1.w == "uma")
                    and PERSON_NAME[lowercased(n2.w)] and not (n3 and not n2.punct and capital(n3.w)) then
                accumulate(d.ev, "apposition")
                accumulate(d.gen, (n1.w == "o" or n1.w == "um") and "m" or "f")
            end
            -- article before: only gender ("a Bahia" also takes an article)
            if stuck_before and (pl == "o" or pl == "a") then accumulate(d.gen, pl == "o" and "m" or "f") end
            -- place
            if stuck_before and pp and not pp.punct and NAME_CONNECTOR[pl] and PLACE_BEFORE[lowercased(pp.w)] then
                accumulate(d.ev, "place")
            elseif stuck_before and PLACE_BEFORE[pl] then
                accumulate(d.ev, "place")
            elseif stuck_after and AFTER_PLACE[n1.w] then
                accumulate(d.ev, "place")
            elseif stuck_before and (pl == "de" or pl == "from") and stuck_after and (n1.w == "até" or n1.w == "to") then
                accumulate(d.ev, "route")
            elseif stuck_before and SAINT[pl] then
                accumulate(d.ev, "saint")
            elseif stuck_before and PLACE_PREP[pl] then
                accumulate(d.ev, "locative")
            end
            if stuck_before and (pl == "the" or pl == "os" or pl == "as") then accumulate(d.ev, "thing") end
            per_sentence[sentence] = per_sentence[sentence] or {}
            per_sentence[sentence][#per_sentence[sentence] + 1] = form
            i = j + 1
        else
            i = i + 1
        end
    end
    -- same sentence, one name is the start of another ("Macabéa" and "Maca"): counts, so as not to join two people
    for _, fs in pairs(per_sentence) do
        for a = 1, #fs do
            for b = 1, #fs do
                local x, y = fs[a], fs[b]
                if x ~= y and #x < #y and y:sub(1, #x) == x then accumulate(joined, x .. "\t" .. y) end
            end
        end
    end
    return names, joined
end

local function wordsOf(form)
    local out = {}
    for w in form:gmatch("%S+") do if not NAME_CONNECTOR[w] then out[#out + 1] = w end end
    return out
end

--- Stores the page's names in the book (called by M.digest).
local function storeNames(L, signal, pg)
    L.names, L.box, L.joined = L.names or {}, L.box or {}, L.joined or {}
    L.names_version = (L.names_version or 0) + 1
    local new_ones = {}
    for form, d in pairs(signal.names or {}) do
        local N = L.names[form]
        if not N then
            N = { n = 0, middle = 0, ev = {}, gen = {}, ex = {} }
            L.names[form] = N
            new_ones[#new_ones + 1] = form
        end
        N.n, N.middle = N.n + d.n, N.middle + d.middle
        for r, c in pairs(d.ev) do
            accumulate(N.ev, r, c)
            N.ex[r] = N.ex[r] or pg  -- the page of the first time, to check afterwards
        end
        for g, c in pairs(d.gen) do accumulate(N.gen, g, c) end
        for _, w in ipairs(wordsOf(form)) do
            local cx = L.box[w] or { M = 0, m = 0 }
            L.box[w] = cx
            if d.middle > 0 then cx.M = cx.M + d.middle end
        end
    end
    -- new one-word name: who was on the same page (to find a nickname that shows up right after the
    -- name: "Macabéa" → "Maca")
    for _, form in ipairs(new_ones) do
        if not form:find(" ") then
            local neighbour = {}
            for other_f in pairs(signal.names) do
                if other_f ~= form and #neighbour < 5 and #other_f > #form then neighbour[#neighbour + 1] = other_f end
            end
            if #neighbour > 0 then L.names[form].neighbour = neighbour end
        end
    end
    -- how many times each name word appears in lowercase ("quanto", "seu")
    for w, cx in pairs(L.box) do
        local c = (signal.minus or {})[lowercased(w)]
        if c then cx.m = cx.m + c end
    end
    for pair, c in pairs(signal.together_prefix or {}) do accumulate(L.joined, pair, c) end
    -- cleanup (every 10 pages): a word that only appeared at the start of a sentence and that the book writes more in
    -- lowercase ("É", "Pois", "Quanto") leaves; the capital count stays only for name words
    if L.names_version % 10 == 0 then
        for form, N in pairs(L.names) do
            local cx = L.box[form:match("^%S+")]
            if N.middle == 0 and cx and cx.m >= 2 and cx.m > cx.M then L.names[form] = nil end
        end
        local used_ones = {}
        for form in pairs(L.names) do for _, w in ipairs(wordsOf(form)) do used_ones[w] = true end end
        for w in pairs(L.box) do if not used_ones[w] then L.box[w] = nil end end
        for pair in pairs(L.joined) do
            local a, b = pair:match("^(.-)\t(.*)$")
            if not (L.names[a] and L.names[b]) then L.joined[pair] = nil end
        end
    end
    -- pruning: the saved state does not grow forever
    local n = 0
    for _ in pairs(L.names) do n = n + 1 end
    if n > NAME_FORMS_MAX then
        for form, N in pairs(L.names) do
            if N.n <= 1 and not next(N.ev) then L.names[form] = nil end
        end
    end
end

local cache_chars = setmetatable({}, { __mode = "k" })

--- Characters of a book by the evidence (L.names). Returns the same list as M.charactersInfo, with
-- `forms` (all names of the person) and `places` apart.
local function charactersNew(L, book)
    local c = cache_chars[L]
    if c and c.pages_seen == L.pages and c.n == L.names_version then return c.list, c.places end
    local N, CX = L.names, L.box or {}
    local titleText = book and lowercased(book) or ""
    -- the words of each name, split once: inside the loops below (name × name), splitting again
    -- on every pair was almost all of the query time in a long book (Moby Dick, page 700: 250 ms on the Mac)
    local PW, WITH = {}, {}
    local function pw(f)
        local p = PW[f]
        if not p then p = wordsOf(f); PW[f] = p end
        return p
    end
    local function withConnectors(f)  -- all the words, with "de", "da"
        local ws = WITH[f]
        if not ws then
            ws = {}
            for w in f:gmatch("%S+") do ws[#ws + 1] = w end
            WITH[f] = ws
        end
        return ws
    end
    -- 1. a form that only appears at the start of a sentence is valid if the book writes the first word more capitalised
    --    mid-sentence than in lowercase ("Quanto a mim", "Talvez Cotrim" → "Cotrim"); otherwise the word leaves
    local function common(w)
        local cx = CX[w] or { M = 0, m = 0 }
        return cx.M == 0 or cx.m > cx.M
    end
    local F = {}
    for form, d in pairs(N) do
        local target = form
        local cx1 = not form:find(" ") and CX[form]
        if cx1 and cx1.m >= 3 and cx1.m > 2 * cx1.M then
            target = nil  -- the book uses the word almost always in lowercase ("Já disse…"): it is not a name
        elseif d.middle == 0 then
            local ps = {}
            for w in form:gmatch("%S+") do ps[#ps + 1] = w end
            while #ps > 0 and (common(ps[1]) or NAME_CONNECTOR[ps[1]]) do table.remove(ps, 1) end
            target = #ps > 0 and table.concat(ps, " ") or nil
        end
        if target then
            local e = F[target]
            if not e then
                e = { n = 0, middle = 0, ev = {}, gen = {}, neighbour = {} }
                F[target] = e
            end
            e.n, e.middle = e.n + d.n, e.middle + d.middle
            for r, v in pairs(d.ev) do accumulate(e.ev, r, v) end
            for g, v in pairs(d.gen) do accumulate(e.gen, g, v) end
            for _, v in ipairs(d.neighbour or {}) do e.neighbour[v] = true end
        end
    end
    -- 2. clues from the whole book: common word, famous person cited, known place
    for form, e in pairs(F) do
        if not form:find(" ") then
            local cx = CX[form]
            if cx and cx.m >= 3 and cx.m >= cx.M then e.ev.common = 2 end
            if REFERENCES[form] and not titleText:find(lowercased(form), 1, true) then e.ev.quotation = 2 end
            if KNOWN_PLACES[form] or BR_STATES[form] then e.place_list = 1.5
            elseif CITIES[form] then e.place_list = 0.5 end
        elseif COMPOUND_STATES[form] then
            e.place_list = 2
        else
            local all = true  -- "Jesus Cristo": all the words are of a famous person cited
            for _, w in ipairs(pw(form)) do if not REFERENCES[w] then all = false end end
            if all and not titleText:find(lowercased(form), 1, true) then e.ev.quotation = 2 end
        end
    end
    -- 3. the same person
    local group, compound = {}, {}
    for form in pairs(F) do
        group[form] = form
        if form:find(" ") then compound[#compound + 1] = form end
    end
    table.sort(compound, function(a, b) return #pw(a) < #pw(b) or (#pw(a) == #pw(b) and a < b) end)
    local function root(f) while group[f] ~= f do f = group[f] end return f end
    -- "Olímpico de Jesus" is the start of a single longer name ("… Moreira Chaves"): the same person
    for _, c1 in ipairs(compound) do
        local p1 = pw(c1)
        local j1 = table.concat(p1, " ")
        local roots, target = {}, nil
        for _, c2 in ipairs(compound) do
            local p2 = pw(c2)
            if #p2 > #p1 and table.concat(p2, " ", 1, #p1) == j1 then
                local r = root(c2)
                if not roots[r] then
                    roots[r] = true
                    if target == nil then target = r else target = false end
                end
            end
        end
        if target then group[target] = root(c1) end
    end
    -- a loose name that is the first (or the last, without "de" before) of a single compound name that appears 2+ times
    local family_times = {}
    for _, c1 in ipairs(compound) do accumulate(family_times, root(c1), F[c1].n) end
    for form in pairs(F) do
        if not form:find(" ") then
            local target, several = nil, false
            for _, c1 in ipairs(compound) do
                local p1, ws = pw(c1), withConnectors(c1)
                if (p1[1] == form or (p1[#p1] == form and not NAME_CONNECTOR[ws[#ws - 1]]))
                        and family_times[root(c1)] >= 2 then
                    local r = root(c1)
                    if target and target ~= r then several = true end
                    target = target or r
                end
            end
            if target and not several then group[form] = target end
        end
    end
    -- nickname: the start of a name, which appeared for the first time near it ("Macabéa" → "Maca")
    for form, e in pairs(F) do
        if group[form] == form and not form:find(" ") and #form >= 3 then
            for other_f in pairs(F) do
                local p1 = pw(other_f)[1]
                if other_f ~= form and p1 and #p1 > #form and p1:sub(1, #form) == form
                        and (e.neighbour[other_f] or F[other_f].neighbour[form])
                        and ((L.joined or {})[form .. "\t" .. other_f] or 0) < 2 then
                    group[form] = root(other_f)
                    break
                end
            end
        end
    end
    -- 4. type of each person or thing, with the clues of all its names
    local G = {}
    for form, e in pairs(F) do
        local r = root(form)
        local g = G[r]
        if not g then
            g = { forms = {}, n = 0, human = 0, place = 0, common = 0, quotation = 0, speeches = 0 }
            G[r] = g
        end
        g.forms[#g.forms + 1] = form
        g.n = g.n + e.n
        for rule, v in pairs(e.ev) do
            if PERSON_WEIGHT[rule] then g.human = g.human + PERSON_WEIGHT[rule] * v end
            if PLACE_WEIGHT[rule] then g.place = g.place + PLACE_WEIGHT[rule] * v end
        end
        g.place = g.place + (e.place_list or 0)
        g.thing = (g.thing or 0) + 0.5 * (e.ev.thing or 0)  -- "the Nautilus": only weighs against someone who never speaks
        g.common = g.common + (e.ev.common or 0)
        g.quotation = g.quotation + (e.ev.quotation or 0)
        g.speeches = g.speeches + (e.ev.speech or 0)
    end
    local n_capitals, caps_of = 0, {}
    for _, C in pairs(L.caps or {}) do
        n_capitals = n_capitals + 1
        for nameText in pairs(C.chars or {}) do caps_of[nameText] = (caps_of[nameText] or 0) + 1 end
    end
    local list, places = {}, {}
    for _, g in pairs(G) do
        local against = g.place + g.common + g.quotation + (g.speeches == 0 and g.thing or 0)
        table.sort(g.forms, function(a, b) return F[a].n > F[b].n or (F[a].n == F[b].n and #a > #b) end)
        local nameText = g.forms[1]
        if g.place >= 2 and g.place > g.human then
            places[#places + 1] = { nameText, g.n }
        elseif g.quotation == 0 and g.common <= g.human and g.human >= 2 and g.human >= 2 * against and g.n >= MIN_MENTIONS then
            local caps = 0
            for _, f in ipairs(g.forms) do caps = math.max(caps, caps_of[f] or 0) end
            list[#list + 1] = { nameText = nameText, times = g.n, speeches = g.speeches, chapters = caps, forms = g.forms,
                                  protagonist = n_capitals >= 3 and caps >= n_capitals * 0.6 }
        end
    end
    table.sort(list, function(a, b) return a.times > b.times or (a.times == b.times and a.nameText < b.nameText) end)
    table.sort(places, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    cache_chars[L] = { pages_seen = L.pages, n = L.names_version, list = list, places = places }
    return list, places
end
M._charactersNew = charactersNew

--- Finished book: keeps only the final list of characters and places and erases the evidence (the saved state
-- does not grow with each book). On a re-read, the evidence starts again.
function M.freezeNames(L, book)
    if not L or not L.names then return end
    local list, places = charactersNew(L, book)
    L.characters_end, L.places_end = list, places
    L.names, L.box, L.joined, L.names_version, L.aura = nil, nil, nil, nil, nil
end

--- Reads the signals of a page: themes, events, weather, characters, places, quotations, who speaks,
-- proof that a name is a person, first person and word size.
-- book (optional): names that are in the book's title are never treated as a quotation.
-- chapter (optional): if the page starts with the chapter title ("XXV Na Tijuca Nisto…"), the title words and the
-- first one after it count as the start of a sentence (only for the names).
function M.signals(textValue, book, chapter)
    local signal = { themes = {}, events = {}, subjects = {}, weather = 0, chars = {}, chars_start = {}, places = {}, spoke = {},
                    pairsList = {}, thing = {}, refs = {}, proof = {}, firstPersonCount = 0, words = 0, letters = 0, gender = {}, sentences = 0,
                    dialogue = 0 }
    local clean = M.clear(textValue)
    local pt = inPortuguese(clean)
    signal.pt = pt
    local event_hits, theme_hits, subject_hits = {}, {}, {}
    local function subject(as, word)
        subject_hits[as] = subject_hits[as] or {}
        subject_hits[as][word] = true
        accumulate(signal.subjects, as)
    end
    local lowercases, n = {}, 0
    for word in clean:gmatch("[%a\128-\255]+") do
        n = n + 1
        lowercases[n] = word
        if FIRST_PERSON_WORDS[word] then signal.firstPersonCount = signal.firstPersonCount + 1 end
        signal.letters = signal.letters + #word - select(2, word:gsub("[\128-\191]", ""))
        local t = themeOf(word, pt)
        if t then
            theme_hits[t] = theme_hits[t] or {}
            theme_hits[t][word] = true
            accumulate(signal.themes, t)
        end
        local ev = eventOf(word, pt)
        if ev then
            event_hits[ev] = event_hits[ev] or {}
            event_hits[ev][word] = true
            accumulate(signal.events, ev)
        end
        local as = subjectOf(word, pt)
        if as then subject(as, word) end
        if not LEXICON[pt and "pt" or "en"] then
            local cl = weatherOf(word, pt)
            if cl then signal.weather = signal.weather + cl end
        end
    end
    signal.words = n
    local grade = M.sentiment(clean, pt)
    if grade then
        signal.sentiment = grade
        local cal = M.WEATHER_CALIBRATION and M.WEATHER_CALIBRATION[pt and "pt" or "en"]
        signal.weather = cal and (grade - cal.median) / cal.half_range or grade
    end
    -- gender of whoever says "eu" (Portuguese)
    for i = 1, n - 1 do
        local w = lowercases[i]
        local i_before = i > 1 and (lowercases[i - 1] == "eu" or lowercases[i - 1] == "me")
        if COPULA_I[w] or (COPULA_MAYBE[w] and i_before) then
            local j = i + 1
            while j < n and INTENSIFIES[lowercases[j]] do j = j + 1 end
            local g = genderOf(lowercases[j])
            if g then accumulate(signal.gender, g) end
        end
    end
    -- an event only counts with 2+ different words of the group (or 3+ occurrences); a subject too
    for ev, c in pairs(signal.events) do
        local different = 0
        for _ in pairs(event_hits[ev]) do different = different + 1 end
        if different < 2 and c < 3 then signal.events[ev] = nil end
    end
    subjectSentences(lowercases, n, subject)
    for as, c in pairs(signal.subjects) do
        local different = 0
        for _ in pairs(subject_hits[as]) do different = different + 1 end
        if different < 2 and c < 3 then signal.subjects[as] = nil end
    end
    -- theme: a loose generic word ("time", "old", "night") does not make a subject
    for t, c in pairs(signal.themes) do
        local different, specific = 0, false
        for p in pairs(theme_hits[t]) do
            different = different + 1
            if not generic(p) then specific = true end
        end
        if not specific and different < 2 and c < 3 then signal.themes[t] = nil end
    end
    -- words in order, knowing which ones start a sentence
    -- curly quotes, dashes and « » become a space; ellipses become "..." (end of sentence)
    local normal = textValue:gsub("\226\128\166", "... "):gsub("\226\128[\148\156]", " . ")
        :gsub("\194\171", " . "):gsub("\226\128[\147\152\153\157]", " "):gsub("\194\187", " ")
    local toks, beginning = {}, true
    for raw in normal:gmatch("%S+") do
        local w = raw:gsub("^%p+", ""):gsub("%p+$", "")
        -- pont: the word ends in punctuation (comma, "!", end of speech…)
        if w ~= "" then
            toks[#toks + 1] = { w = w, beginning = beginning, punct = raw:find("%p$") ~= nil, point = raw:find("%.$") ~= nil,
                                raw = raw, opens = raw:find("^%p") ~= nil }
        end
        -- "Mr." and "D." do not end a sentence; a lone initial ("J.") neither
        beginning = raw:find("[%.!%?:]$") ~= nil and not (raw:find("%.$") and (ABBREVIATION[w] or w:find("^%u$")))
    end
    -- style and rhythm of the book (book vector, yomimon_vector.lua): sentences and dialogue marks on the page
    for _, tk in ipairs(toks) do if tk.beginning then signal.sentences = signal.sentences + 1 end end
    -- the book's own words (step 5): candidates from the page
    signal.vocab, signal.vocab_art = {}, {}
    for i, tk in ipairs(toks) do
        if M.candidate(tk.w, pt) then
            signal.vocab[tk.w] = (signal.vocab[tk.w] or 0) + 1
            local prev_tok = toks[i - 1]
            if prev_tok and not prev_tok.punct and DETERMINERS[prev_tok.w:lower()] then
                signal.vocab_art[tk.w] = (signal.vocab_art[tk.w] or 0) + 1
            end
        end
    end
    local _, quotes = textValue:gsub("\226\128\156", "")       -- “
    local _, guillemets = textValue:gsub("\194\171", "")       -- «
    local _, straights = textValue:gsub('"', "")
    local _, dashes = textValue:gsub("\226\128\148%s*%u", "")  -- — Speech (Portuguese-style dialogue)
    signal.dialogue = quotes + guillemets + math.floor(straights / 2) + dashes
    -- names with evidence (charactersNew) and how many times each word appears in lowercase
    local _, short_dashes = textValue:gsub("\226\128\147", "")  -- – (Clarice-style dialogue)
    local name_toks = toks
    if type(chapter) == "string" and chapter ~= "" and textValue:match("^%s*(.*)"):sub(1, #chapter) == chapter then
        local n_title = select(2, chapter:gsub("%S+", ""))
        name_toks = {}
        for k, tk in ipairs(toks) do
            name_toks[k] = k <= n_title + 1 and setmetatable({ beginning = true }, { __index = tk }) or tk
        end
    end
    signal.names, signal.together_prefix = pageNames(name_toks, signal.dialogue + short_dashes)
    signal.minus = {}
    for _, tk in ipairs(toks) do
        if tk.w:find("^%l") or tk.w:find("^\195[\159-\191]") then accumulate(signal.minus, lowercased(tk.w)) end
    end
    -- all caps (ADVENTURE, DIARY, XXIX) is a title, header or label, not a name
    local function isName(w) return capital(w) and #w >= 3 and not NOT_NAMES[w] and not w:find("^[%u%p]+$") end
    -- a word that also appears in lowercase on the page is a common word ("Let" at the start of the verse, "let" in the middle)
    local in_lowercase = {}
    for _, tk in ipairs(toks) do if tk.w:find("^%l") then in_lowercase[tk.w] = true end end
    -- theatre: speech label in caps at the start of a sentence ("HAMLET.", "LADY MACBETH."); only valid with 2+ on the page
    local labels = {}
    for i, tk in ipairs(toks) do
        local prev_tok = toks[i - 1]
        if tk.point and tk.w:find("^%u%u%u+$") and (tk.beginning or (prev_tok and prev_tok.beginning and prev_tok.w:find("^%u+$"))) then
            local nameText = tk.w:sub(1, 1) .. tk.w:sub(2):lower()
            if THEATRE_ROLE[nameText] or not NOT_NAMES[nameText] then labels[#labels + 1] = nameText end
        end
    end
    if #labels >= 2 then
        for _, nameText in ipairs(labels) do
            accumulate(signal.chars, nameText); accumulate(signal.spoke, nameText)
            -- theatre: the label of who speaks ("HAMLET.") is proof of a person
            local d = signal.names[nameText] or { n = 0, ini = 0, middle = 0, ev = {}, gen = {} }
            signal.names[nameText] = d
            d.n, d.middle = d.n + 1, d.middle + 1
            accumulate(d.ev, "speech")
        end
    end
    local function afterPlace(i)
        local a1, a2 = toks[i - 1], toks[i - 2]
        if a1 and BEFORE_PLACE[a1.w:lower()] then return true end
        local prep = a1 and a1.w:lower()
        return a2 and (prep == "do" or prep == "da" or prep == "dos" or prep == "das" or prep == "de" or prep == "of")
            and BEFORE_PLACE[a2.w:lower()] or false
    end
    for i, tk in ipairs(toks) do
        local w, prev_tok, nextItem = tk.w, toks[i - 1], toks[i + 1]
        local quotation = REFERENCES[w] and not (book and book:find(w, 1, true))
        if isName(w) and quotation then
            accumulate(signal.refs, w)
        elseif isName(w) and (KNOWN_PLACES[w] or (nextItem and AFTER_PLACE[nextItem.w]) or afterPlace(i)) then
            accumulate(signal.places, w)
        elseif isName(w) and in_lowercase[w:lower()] and not (prev_tok and TITLES[prev_tok.w]) then  -- luacheck: ignore 542
            -- common word with a capital: not a name
        elseif tk.beginning and isName(w) then
            accumulate(signal.chars_start, w)  -- only counts if already known as a character
        elseif not tk.beginning and isName(w) then
            if prev_tok and PLACE_PREP[prev_tok.w:lower()] then
                accumulate(signal.places, w)
            else
                accumulate(signal.chars, w)
                if prev_tok and not prev_tok.beginning and capital(prev_tok.w) and not NOT_NAMES[prev_tok.w] then
                    accumulate(signal.pairsList, prev_tok.w .. " " .. w)
                end
            end
        end
        -- article before the name: "the Nautilus", "the Pequod" (English); "os Tupinambás" (Portuguese, plural).
        -- A person almost never takes an article like this; those who do (the Duchess, the Nurse) usually speak and have proof.
        if isName(w) and prev_tok and not prev_tok.punct then
            local a = prev_tok.w:lower()
            if (not pt and a == "the") or (pt and (a == "os" or a == "as")) then accumulate(signal.thing, w) end
        end
        -- proof that a name is a person: title before ("Dona Glória") or person verb after ("Capitu olhou")
        if isName(w) and not quotation and not KNOWN_PLACES[w] then
            if (prev_tok and TITLES[prev_tok.w]) or (nextItem and PERSON_VERB[nextItem.w:lower()]) then accumulate(signal.proof, w) end
        end
        -- who speaks: "disse Capitu" / "said Mr. Bennet" / "Capitu disse". A name stuck to punctuation
        -- ("Overboard!” said", "Mr. Wilson,” said", "—Viu? perguntou") is part of the speech, not who speaks.
        if SPEECH_VERB[w:lower()] then
            local after = nextItem
            if after and TITLES[after.w] then after = toks[i + 2] end
            if not tk.punct and after and isName(after.w) and not REFERENCES[after.w] then accumulate(signal.spoke, after.w)
            elseif prev_tok and not prev_tok.punct and isName(prev_tok.w) and not REFERENCES[prev_tok.w] then accumulate(signal.spoke, prev_tok.w) end
        end
    end
    return signal
end

-- Characters' speech ----------------------------------------------------------------
-- “Fala,” disse Nome. / “Fala,” Nome disse. / Nome disse: “Fala.” / — Fala — disse Nome.
local OPEN, CLOSE, DASH = "\226\128\156", "\226\128\157", "\226\128\148"
local SPEECH_MIN, SPEECH_MAX = 18, 140
local OPEN2, CLOSE2 = "\194\171", "\194\187"  -- « »

local function personName(w)
    return w and capital(w) and #w >= 3 and not NOT_NAMES[w] and not REFERENCES[w] and not KNOWN_PLACES[w]
end

-- Who said it: speech verb right after the speech ("disse Darcy", "Darcy said") or right before ("Darcy said:").
local function whoSaid(after, before)
    local a, b = after:match("^[%s,%.!%?;:]*([%a\128-\255]+)%s+([%a\128-\255]+)")
    if a and SPEECH_VERB[a:lower()] and TITLES[b] then  -- "said Mr. Bennet"
        b = after:match("^[%s,%.!%?;:]*[%a\128-\255]+%s+[%a\128-\255]+%.?%s+([%a\128-\255]+)")
    end
    if a and SPEECH_VERB[a:lower()] and personName(b) then return b end
    if a and personName(a) and b and SPEECH_VERB[b:lower()] then return a end
    local c, d = (before or ""):match("([%a\128-\255]+)%s+([%a\128-\255]+)[%s,:]*$")
    if c and personName(c) and d and SPEECH_VERB[d:lower()] then return c end
end

local function clearSpeech(f)
    return (f:gsub("%s+", " "):gsub("^%s+", ""):gsub("[%s,;—]+$", ""))
end

--- Speech attributed on a page: { {nameText =, speech =}, ... } (only speeches of a reasonable size).
function M.pageSpeeches(textValue)
    local out = {}
    local function store(speech, nameText)
        if nameText and #speech >= SPEECH_MIN and #speech <= SPEECH_MAX and not speech:find(OPEN, 1, true) then
            out[#out + 1] = { nameText = nameText, speech = speech }
        end
    end
    for _, pair in ipairs({ { OPEN, CLOSE }, { OPEN2, CLOSE2 }, { '"', '"' } }) do
        local opens, closes, i = pair[1], pair[2], 1
        while true do
            local a = textValue:find(opens, i, true)
            if not a then break end
            local b = textValue:find(closes, a + #opens, true)
            if not b then break end
            local raw_f = textValue:sub(a + #opens, b - 1)
            local after = textValue:sub(b + #closes, b + #closes + 60)
            local nameText = whoSaid(after, textValue:sub(math.max(1, a - 40), a - 1))
            -- “Primeira parte,” disse Fulano, “e o resto.” → joins the two parts
            -- (only joins if the second part continues the sentence, in lowercase; otherwise the first ends there)
            if nameText and raw_f:find(",%s*$") then
                local c = textValue:find(opens, b + #closes, true)
                local d = c and c - b < 60 and textValue:find(closes, c + #opens, true)
                local remainder = d and textValue:sub(c + #opens, d - 1):gsub("^%s+", "")
                if remainder and remainder:find("^%l") then
                    raw_f, b = raw_f:gsub(",%s*$", "") .. " " .. remainder, d
                else
                    raw_f = raw_f:gsub(",%s*$", ".")
                end
            end
            store(clearSpeech(raw_f), nameText)
            i = b + #closes
        end
    end
    local i = 1
    while true do
        local a = textValue:find(DASH, i, true)
        if not a then break end
        local b = textValue:find(DASH, a + 3, true)
        if not b then break end
        local nameText = whoSaid(textValue:sub(b + 3, b + 63))
        if nameText then store(clearSpeech(textValue:sub(a + 3, b - 1)), nameText); i = b + 3 else i = a + 3 end
    end
    return out
end

local QUOTATIONS_PER_BOOK = 12

local function storeQuotations(L, speeches)
    L.quotations = L.quotations or {}
    for _, f in ipairs(speeches) do
        local repeated = false
        for _, c in ipairs(L.quotations) do if c.speech == f.speech then repeated = true; break end end
        if not repeated then
            if #L.quotations < QUOTATIONS_PER_BOOK then
                L.quotations[#L.quotations + 1] = f
            elseif math.random(4) == 1 then
                L.quotations[math.random(#L.quotations)] = f
            end
        end
    end
end

--- A striking line of a character in the book: { nameText, speech }, or nil.
-- Prefers the protagonist and shorter lines; max_tam limits the size.
function M.quotation(s, book, draw, max_size)
    local L = book and s.books and s.books[book]
    if not L or not L.quotations then return nil end
    local chars = {}  -- any name of the person ("Cotes" and "Petra Cotes") → their position in the list
    for i, p in ipairs(M.charactersInfo(s, book)) do
        for _, f in ipairs(p.forms or { p.nameText }) do chars[f] = chars[f] or i end
    end
    local good = {}
    for _, c in ipairs(L.quotations) do
        if chars[c.nameText] and #c.speech <= (max_size or SPEECH_MAX) then good[#good + 1] = c end
    end
    if #good == 0 then return nil end
    table.sort(good, function(a, b) return chars[a.nameText] < chars[b.nameText] end)
    return good[(draw or math.random)(math.min(#good, 4))]
end

--- Digests a page: updates themes, book, chapter and writes in the diary when something changes.
-- When the chapter changes, leaves a comment on the chapter that ended (s.pending_comment).
-- count: false when the page was already counted before (flipped through) and is now only digested: it does not add again
-- to the pages of the book, chapter and day.
function M.digest(s, textValue, where, now, count)
    count = count ~= false
    ensure(s)
    Diary.rollDay(s, M, now)  -- new day: writes the entry of the previous day
    local book = where and where.book
    local L
    if book then
        L = s.books[book]
        if not L then
            L = { beginning = now, pages = 0, chars = {}, themes = {}, author = where.author, weather = 0, traits_start = {} }
            for k, v in pairs(s.traits or {}) do L.traits_start[k] = v end
            s.books[book] = L
            local previous = s.current_book ~= book and s.current_book or nil
            -- author who returns, counted by the reviews (memory); otherwise, the usual opening
            local okMemories, Memories = pcall(require, "yomimon_memories")
            if not (okMemories and Memories.bookStart(s, M, book, where, now)) then
                M.note(s, now, Diary.bookStart(s, M, book, where, previous))
            end
        end
        s.current_book = book
        -- EPUB genre tags (one per line): only a genre map, in Infl.profile
        if not L.tags and type(where.tags) == "string" and where.tags:find("%S") then
            L.tags = {}
            for e in where.tags:gmatch("[^\n]+") do
                e = e:gsub("^%s+", ""):gsub("%s+$", "")
                if e ~= "" and #L.tags < 12 then L.tags[#L.tags + 1] = e:sub(1, 80) end
            end
        end
        if count then L.pages = L.pages + 1 end
        L.last = now
        L.caps, L.places, L.spoke = L.caps or {}, L.places or {}, L.spoke or {}
        L.refs, L.events, L.subjects = L.refs or {}, L.events or {}, L.subjects or {}
        L.narrator = L.narrator or { firstPersonCount = 0, words = 0, f = 0, m = 0 }
    end
    local has_text = type(textValue) == "string"
    local signal = M.signals(has_text and textValue or "", book, where and where.chapter)
    local theme_weight = {}
    for t, c in pairs(signal.themes) do theme_weight[t] = c * M.themeWeight(t, signal.pt) end
    signal.heavy_themes = theme_weight
    local speeches = has_text and M.pageSpeeches(textValue) or {}
    if L then
        storeQuotations(L, speeches)
        L.weather = (L.weather or 0) + signal.weather
        if signal.pt then L.pages_pt = (L.pages_pt or 0) + 1 end
    end
    Diary.page(s, book, signal, speeches, now, count)
    -- personality traits: only what you read moves them
    if has_text then
        local okTraits, notes = pcall(function() return require("yomimon_traits").digest(s, signal, now, book) end)
        if okTraits and notes then for _, grade in ipairs(notes) do M.note(s, now, grade) end end
        -- literary influences: the same door (page really read, only once)
        if book and L then pcall(function() require("yomimon_influences").digest(s, book, L) end) end
    end

    -- its themes forget slowly, like the traits: the obsession follows what you have been reading
    if has_text then
        for t, v in pairs(s.themes) do s.themes[t] = v * M.THEME_FORGETTING end
    end
    for t, c in pairs(theme_weight) do
        accumulate(s.themes, t, c)
        if L then accumulate(L.themes, t, c) end
    end

    if L then
        -- names with evidence: who is a person, place or the same person comes out of here, at query time (charactersNew).
        -- A finished book already has the final list: pages after the end (notes, afterword) do not enter.
        if not L.finished then storeNames(L, signal, L.pages) end
        -- aura: themes of the pages of each recurring name with a clue of being a person (stored; not yet turned into a phrase)
        L.aura = L.aura or {}
        for nameText in pairs(L.names and signal.names or {}) do
            local Nn = L.names[nameText]
            if Nn and Nn.n >= 3 and (Nn.ev.speech or Nn.ev.verb or Nn.ev.titleText or Nn.ev.vocative or Nn.ev.apposition) then
                local a = L.aura[nameText] or {}
                L.aura[nameText] = a
                for t, c in pairs(theme_weight) do a[t] = (a[t] or 0) + c end
            end
        end
        for nameText, c in pairs(signal.places) do accumulate(L.places, nameText, c) end
        for nameText, c in pairs(signal.spoke) do accumulate(L.spoke, nameText, c) end
        for nameText, c in pairs(signal.refs) do accumulate(L.refs, nameText, c) end
        -- book vector: words, sentences and dialogue, for style and rhythm (sums only)
        L.words = (L.words or 0) + (signal.words or 0)
        L.sentences = (L.sentences or 0) + (signal.sentences or 0)
        L.dialogue = (L.dialogue or 0) + (signal.dialogue or 0)
        if has_text then L.text_pages = (L.text_pages or 0) + 1 end
        -- the book's own words (step 5): sum and prune (the saved state does not grow forever)
        if signal.vocab and next(signal.vocab) then
            L.vocab, L.vocab_art = L.vocab or {}, L.vocab_art or {}
            local n = 0
            for w, c in pairs(signal.vocab) do accumulate(L.vocab, w, c) end
            for w, c in pairs(signal.vocab_art) do accumulate(L.vocab_art, w, c) end
            for _ in pairs(L.vocab) do n = n + 1 end
            if n > M.VOCAB_MAX then M.pruneVocab(L, M.VOCAB_PRUNED) end
        end
        local N = L.narrator
        N.firstPersonCount, N.words = N.firstPersonCount + signal.firstPersonCount, N.words + signal.words
        N.f, N.m = N.f + (signal.gender.f or 0), N.m + (signal.gender.m or 0)
        if L.names then for nameText in pairs(L.aura) do if not L.names[nameText] then L.aura[nameText] = nil end end end  -- pruned name

        -- chapter: own memory and a comment when it changes
        for ev, c in pairs(signal.events) do accumulate(L.events, ev, c) end
        for as, c in pairs(signal.subjects) do accumulate(L.subjects, as, c) end
        local cap = where.chapter or "?"
        -- huge chapter (or a book without a table of contents): splits into stretches of 25 pages
        if L.cap_base ~= cap then
            L.cap_base, L.chapter_part = cap, 1
        elseif L.caps[L.cur_chapter] and L.caps[L.cur_chapter].pages >= STRETCH_PAGES then
            L.chapter_part = (L.chapter_part or 1) + 1
        end
        if (L.chapter_part or 1) > 1 then cap = string.format("%s (%d)", cap, L.chapter_part) end
        if L.cur_chapter and cap ~= L.cur_chapter and L.caps[L.cur_chapter] then
            local comment = M.chapterComment(s, L, L.cur_chapter)
            if comment then
                s.pending_comment = { textValue = (Voice.resolver(comment.textValue, s)), t = now, book = book,
                                          event = comment.event }
            end
            -- the chapter that ended talked about a card subject (by the text or by the title)
            M.chapterCard(s, L, L.cur_chapter, true, now, book)
        end
        if not L.caps[cap] then
            L.n_capitals = (L.n_capitals or 0) + 1
            L.caps[cap] = { order = L.n_capitals, chars = {}, themes = {}, events = {}, weather = 0, pages = 0 }
            -- keeps only the 40 most recent chapters
            if L.n_capitals > 40 then
                for nameText, C in pairs(L.caps) do if C.order <= L.n_capitals - 40 then L.caps[nameText] = nil end end
            end
            -- new chapter: the title may already light up a card subject
            if (L.chapter_part or 1) == 1 then M.chapterCard(s, L, cap, false, now, book) end
        end
        L.cur_chapter = cap
        local C = L.caps[cap]
        if count then C.pages = C.pages + 1 end
        C.weather = C.weather + signal.weather
        -- (only names that already appeared mid-sentence: "É" and "Pois" at the start of a sentence do not enter)
        for nameText, d in pairs(signal.names) do
            local Nn = L.names and L.names[nameText]
            if d.middle > 0 or (Nn and Nn.middle > 0) then accumulate(C.chars, nameText, d.n) end
        end
        for t, c in pairs(theme_weight) do accumulate(C.themes, t, c) end
        for ev, c in pairs(signal.events) do accumulate(C.events, ev, c) end
        if next(signal.subjects) then
            C.subjects = C.subjects or {}
            for as, c in pairs(signal.subjects) do accumulate(C.subjects, as, c) end
        end
        -- reading days, end of the book (review) and re-read
        Diary.followBook(s, M, L, book, where, now)
    end

    -- memories: anniversary, character who returns, nothing so gloomy since…
    if has_text then
        local okMemories, Memories = pcall(require, "yomimon_memories")
        if okMemories then Memories.page(s, M, L, book, now) end
    end

    local strong = M.strongThemes(s)
    local current_pts = s.dominant_theme and (s.themes[s.dominant_theme] or 0) or 0
    if strong and strong[2] >= 20 and strong[1] ~= s.dominant_theme and strong[2] >= current_pts * 1.2
            and s.obsession_at ~= os.date("%Y-%m-%d", now) then
        s.obsession_at = os.date("%Y-%m-%d", now)
        local oldOne = s.dominant_theme
        s.dominant_theme = strong[1]
        M.note(s, now, Diary.obsession(M, oldOne, strong[1]))
    end
end

-- End-of-chapter comment -------------------------------------------------------

local Content = Language.content("memory")
local SPEECHES_EVENT, SPEECHES_NEW, SPEECHES_VANISHED = Content.SPEECHES_EVENT, Content.SPEECHES_NEW, Content.SPEECHES_VANISHED
local SPEECHES_SOURED, SPEECHES_SWEETENED, SPEECHES_TURNED = Content.SPEECHES_SOURED, Content.SPEECHES_SWEETENED, Content.SPEECHES_TURNED
local SPEECHES_THEME, COMMENTS = Content.SPEECHES_THEME, Content.C
local SPEECHES_REFERENCE, SPEECHES_NARRATOR, SPEECHES_QUOTATION = Content.SPEECHES_REFERENCE, Content.SPEECHES_NARRATOR, Content.SPEECHES_QUOTATION


local function biggestOf(t)
    local best, val = nil, 0
    for k, v in pairs(t or {}) do if v > val then best, val = k, v end end
    return best, val
end

-- Card subjects ----------------------------------------------------------------------------

--- Subjects that a chapter title lights up ("III Genealogia" → ancestors): { subject = true }.
-- Whole words, lowercase, with the plural; without the old spelling (the title may be in English).
function M.titleSubjects(titleText)
    local lit = {}
    if type(titleText) ~= "string" then return lit end
    local ws, n = {}, 0
    for w in lowercased(titleText):gmatch("[%a\128-\255]+") do
        n = n + 1
        ws[n] = w
        if subject_index[w] then lit[subject_index[w]] = true end
    end
    subjectSentences(ws, n, function(as) lit[as] = true end)
    return lit
end

--- Subjects a chapter talks about by the text, with the events rule: with little of the book read before, 3+
-- signals; afterwards, double the frequency of the rest of the book (and 2+ signals). { subject = true }.
function M.chapterSubjects(L, C)
    local lit = {}
    if not C or (C.pages or 0) < 1 then return lit end
    local pages_before = (L.pages or 0) - C.pages
    for as, c in pairs(C.subjects or {}) do
        local before = ((L.subjects or {})[as] or c) - c
        if pages_before < 10 then
            if c >= 3 then lit[as] = true end
        elseif c >= 2 and c / C.pages >= 2 * before / pages_before then
            lit[as] = true
        end
    end
    return lit
end

--- A chapter started (ended = false: only the title counts) or ended (title and text): if it talks about a
-- subject, the first card that fits is stored (yomimon_cards.lua). One card per chapter.
function M.chapterCard(s, L, chapter_name, ended, now, book)
    local C = L.caps and L.caps[chapter_name]
    if not C or C.card then return end
    -- the title only counts in the first part of a huge chapter ("X (2)" does not repeat)
    local subjects = chapter_name:find(" %(%d+%)$") and {} or M.titleSubjects(chapter_name)
    if ended then for as in pairs(M.chapterSubjects(L, C)) do subjects[as] = true end end
    if not next(subjects) then return end
    local okCards, Cards = pcall(require, "yomimon_cards")
    local okState, State = pcall(require, "yomimon_state")
    if not (okCards and okState) then return end
    -- {character}: who appears most in the chapter (by the most used name of the person)
    local person = {}
    for _, p in ipairs(M.charactersInfoOf(L)) do for _, f in ipairs(p.forms or { p.nameText }) do person[f] = p end end
    local nameText = biggestOf(C.chars)
    local who = nameText and person[nameText]
    local data = { character = who and who.nameText, stage = State.stage(s).speech_stage }
    if Cards.chapter(s, subjects, data, now, book) then C.card = true end
end

--- The event that stands out most in a chapter, or nil. With little of the book read before, asks for 3+
-- signals of the event; afterwards, double the frequency of the rest of the book (and 2+ signals).
function M.chapterEvent(L, C)
    local pages_before = (L.pages or 0) - C.pages
    local best, grade = nil, 0
    for ev, c in pairs(C.events or {}) do
        local before = ((L.events or {})[ev] or c) - c
        local highlight
        if pages_before < 10 then
            highlight = c >= 3 and c or 0
        else
            local rate, base = c / C.pages, before / pages_before
            highlight = (c >= 2 and rate >= 2 * base) and (rate / math.max(base, 0.01)) or 0
        end
        if highlight > grade then best, grade = ev, highlight end
    end
    return best
end

--- Comment on a chapter that just ended: { textValue, event? } or nil.
function M.chapterComment(s, L, chapter_name, draw)
    draw = draw or math.random
    local C = L.caps[chapter_name]
    if not C or C.pages < 1 then return nil end
    local earlier = {}
    for _, D in pairs(L.caps) do if D.order < C.order then earlier[#earlier + 1] = D end end
    -- 1) event that stands out: much more frequent in this chapter than in the rest of the book
    local ev = M.chapterEvent(L, C)
    if ev and SPEECHES_EVENT[ev] then return { textValue = draws(SPEECHES_EVENT[ev], draw), event = ev } end
    -- 2) new character (strong in this chapter, absent before)
    local info = M.charactersInfoOf(L)
    local person = {}  -- any name of the person → the person
    for _, p in ipairs(info) do for _, f in ipairs(p.forms or { p.nameText }) do person[f] = p end end
    local function inChapter(D, p)
        local c = 0
        for _, f in ipairs(p.forms or { p.nameText }) do c = c + (D.chars[f] or 0) end
        return c
    end
    if #earlier >= 1 then
        local nameText, c = biggestOf(C.chars)
        local p = nameText and person[nameText]
        if p and c >= 3 then
            local seen = false
            for _, D in ipairs(earlier) do if inChapter(D, p) > 0 then seen = true; break end end
            if not seen then return { textValue = string.format(draws(SPEECHES_NEW, draw), p.nameText) } end
        end
    end
    -- 3) protagonist vanished
    for _, p in ipairs(info) do
        if p.protagonist and inChapter(C, p) == 0 and C.pages >= 3 then
            return { textValue = string.format(draws(SPEECHES_VANISHED, draw), p.nameText) }
        end
    end
    -- 4) chapter theme different from the book's theme
    local t_cap = biggestOf(C.themes)
    local t_book = biggestOf(L.themes)
    if t_cap and t_book and t_cap ~= t_book and (C.themes[t_cap] or 0) >= 3 then
        return { textValue = string.format(draws(SPEECHES_TURNED, draw), M.theme(t_book, "de"), M.theme(t_cap, "de")) }
    end
    -- 5) weather compared with the average of the previous ones
    if #earlier >= 1 then
        local sum, pages_seen = 0, 0
        for _, D in ipairs(earlier) do sum, pages_seen = sum + D.weather, pages_seen + D.pages end
        local before = pages_seen > 0 and sum / pages_seen or 0
        local now_c = C.weather / C.pages
        -- limits calibrated on the books (10% of the chapters each); without calibration, ±1
        local lg = (L.pages_pt or 0) * 2 > (L.pages or 0) and "pt" or "en"
        local cal = M.WEATHER_CALIBRATION and M.WEATHER_CALIBRATION[lg] or {}
        if now_c < before + (cal.soured or -1) then return { textValue = draws(SPEECHES_SOURED, draw) } end
        if now_c > before + (cal.sweetened or 1) then return { textValue = draws(SPEECHES_SWEETENED, draw) } end
    end
    return nil
end

--- Who narrates the book: { first = true/false, gender = "f"/"m"/nil }, or nil if it is still early.
-- First person = more than 2% of the words are "eu/me/meu…" (with at least 1,500 words read).
function M.narrator(L)
    local N = L and L.narrator
    if not N or N.words < 1500 then return nil end
    local info = { first = N.firstPersonCount / N.words >= 0.02 }
    if info.first then
        if N.f >= 3 and N.f >= 2 * N.m then info.gender = "f"
        elseif N.m >= 3 and N.m >= 2 * N.f then info.gender = "m" end
    end
    return info
end

--- People and works cited in a book, most cited first: { {nameText, times}, ... }.
function M.references(s, book)
    local L = book and s.books and s.books[book]
    local list = {}
    for nameText, c in pairs(L and L.refs or {}) do list[#list + 1] = { nameText, c } end
    table.sort(list, function(a, b) return a[2] > b[2] end)
    return list
end

--- charactersInfo from the book's table (without needing the title).
function M.charactersInfoOf(L)
    return M.charactersInfo({ books = { x = L } }, "x")
end

--- Everything it noticed about a book (for the dev panel).
function M.perception(s, book)
    local L = book and s.books and s.books[book]
    if not L then return nil end
    local out = { characters = M.charactersInfo(s, book), places = {}, themes = {}, chapters = {},
                  references = M.references(s, book), narrator = M.narrator(L) }
    if L.places_end then out.places = L.places_end
    elseif L.names then out.places = select(2, M._charactersNew(L, book))
    else
        for nameText, c in pairs(L.places or {}) do if c >= 2 then out.places[#out.places + 1] = { nameText, c } end end
    end
    table.sort(out.places, function(a, b) return a[2] > b[2] end)
    for t, c in pairs(L.themes or {}) do out.themes[#out.themes + 1] = { t, c } end
    table.sort(out.themes, function(a, b) return a[2] > b[2] end)
    for nameText, cap in pairs(L.caps or {}) do out.chapters[#out.chapters + 1] = { nameText = nameText, C = cap } end
    table.sort(out.chapters, function(a, b) return a.C.order > b.C.order end)
    return out
end

-- Phrases that come from the books ------------------------------------------------------


-- Quotations of the current book ({nameText} cited {n} times) and who narrates.
-- A character's line quoted by it ({nameText} said {speech}).


--- A phrase influenced by the books, or nil. temperament (optional): "young" or "old".
function M.speech(s, draw, temperament)
    draw = draw or math.random
    local a, b = M.ambivalent(s)
    if a then
        return string.format(T"Part of me thinks about %s. The other part read too much about %s.",
            M.theme(a, "em"), M.theme(b))
    end
    local options = {}
    local t = s.dominant_theme
    if t and SPEECHES_THEME[t] then options[#options + 1] = function() return draws(SPEECHES_THEME[t], draw) end end
    local book = s.last_book
    local L = book and s.books and s.books[book]
    local ref = M.references(s, book)[1]
    if ref and ref[2] >= 4 then
        local bank = SPEECHES_REFERENCE[temperament == "young" and "young" or "old"]
        options[#options + 1] = function()
            return (draws(bank, draw):gsub("{nameText}", ref[1]):gsub("{n}", tostring(ref[2])))
        end
    end
    local quoted = M.quotation(s, book, draw, 90)
    if quoted then
        local bank = SPEECHES_QUOTATION[temperament == "young" and "young" or "old"]
        options[#options + 1] = function()
            local line = draws(bank, draw):gsub("{nameText}", quoted.nameText):gsub("{speech}", function() return quoted.speech end)
            return (line:gsub("([%?!])\226\128\157,", "%1\226\128\157"):gsub("%.\226\128\157,", ",\226\128\157"))
        end
    end
    local narration = M.narrator(L)
    if narration and narration.first then
        options[#options + 1] = function() return draws(SPEECHES_NARRATOR[narration.gender or "neutro"], draw) end
    end
    if #options > 0 then return options[draw(#options)]() end
end

-- Notebook: comments with context ------------------------------------------------
--
-- No AI: Yomimon gathers real clues from the passage (characters cited, subject, length,
-- note, time, chapter, how many highlights the book has) and picks a ready-made phrase that
-- matches them. The choice is stable: the same passage always gets the same comment.

--- Subject most present in a passage (by the theme lists), or nil.
function M.textTheme(textValue)
    local counter, best, theme = {}, 0, nil
    local clean = M.clear(textValue or "")
    local pt = inPortuguese(clean)
    for word in clean:gmatch("[%a\128-\255]+") do
        local t = themeOf(word, pt)
        if t then
            counter[t] = (counter[t] or 0) + 1
            if counter[t] > best then best, theme = counter[t], t end
        end
    end
    return theme
end

local function hash(textValue)
    local h = 0
    for i = 1, #(textValue or "") do h = (h * 31 + textValue:byte(i)) % 1000003 end
    return h
end



local function textNames(textValue, names)
    local found = {}
    for _, n in ipairs(names or {}) do
        if textValue:find(n, 1, true) then found[#found + 1] = n end
    end
    return found
end

--- Yomimon's comment on a highlight.
-- item: { textValue, grade, chapter, data ("YYYY-MM-DD HH:MM:SS") }
-- ctx:  { temperament, book, characters = {...}, order = n-th of the book, total = n of the book,
--         in_chapter = how many in the same chapter, s = state (for the trait variants) }
function M.contextComment(item, ctx)
    local textValue = item.textValue or ""
    local h = hash(textValue)
    local function takes(list) return list[h % #list + 1] end
    local temp = ctx.temperament or "old"
    if temp == "egg" then return takes(COMMENTS.general.egg) end

    local candidates = {}
    local function add(f) candidates[#candidates + 1] = f end

    if item.grade and item.grade ~= "" then
        local grade = item.grade:gsub("%s+", " ")
        if #grade > 60 then grade = grade:sub(1, 57):gsub("[\192-\255][\128-\191]*$", "") .. "…" end
        add(string.format(takes(COMMENTS.grade), grade))
    end
    local names = textNames(textValue, ctx.characters)
    if #names >= 2 then add(string.format(takes(COMMENTS.two), names[1], names[2])) end
    if #names >= 1 then add(string.format(takes(COMMENTS.character), names[1])) end
    local theme = M.textTheme(textValue)
    if theme and COMMENTS.theme[theme] then add(takes(COMMENTS.theme[theme])) end
    local n_words = select(2, textValue:gsub("%S+", ""))
    if n_words <= 6 then add(takes(COMMENTS.short_one)) elseif n_words >= 70 then add(takes(COMMENTS.long)) end
    local hour = tonumber((item.data or ""):match(" (%d%d):"))
    if hour and hour >= 0 and hour < 5 then add(string.format(takes(COMMENTS.small_hours), tostring(hour))) end
    if ctx.order == 1 and ctx.book then add(string.format(takes(COMMENTS.first_one), ctx.book)) end
    if ctx.total and ctx.total >= 10 and ctx.order == ctx.total then add(string.format(takes(COMMENTS.many), ctx.total)) end
    if item.chapter and (ctx.in_chapter or 0) >= 3 then add(string.format(takes(COMMENTS.chapter), item.chapter)) end
    add(takes(COMMENTS.general[temp] or COMMENTS.general.old))

    -- specific clues come first; the general comment only enters when there is no other
    if #candidates > 1 then table.remove(candidates) end
    local picked_one = candidates[h % #candidates + 1]
    -- ctx.s (optional): the state, for the trait variants
    if ctx.s then picked_one = (Voice.resolver(picked_one, ctx.s)) end
    return picked_one
end

--- Compatible with the previous version: comment only by the text and temperament.
function M.comment(textValue, temperament)
    return M.contextComment({ textValue = textValue }, { temperament = temperament })
end

-- Languages with article-ready theme names (English) look them up instead of using the built-in grammar.
if Content.NAMES then
    function M.theme(t) return Content.NAMES[t] or t end
    for t in pairs(M.THEME_NAMES) do M.THEME_NAMES[t] = M.theme(t) end
end

-- New batches of phrases (yomimon_locales/<code>/data/extra.lua) add to the lists above.
Language.append({ SPEECHES_EVENT = SPEECHES_EVENT, SPEECHES_NEW = SPEECHES_NEW, SPEECHES_VANISHED = SPEECHES_VANISHED,
    SPEECHES_SOURED = SPEECHES_SOURED, SPEECHES_SWEETENED = SPEECHES_SWEETENED, SPEECHES_TURNED = SPEECHES_TURNED, SPEECHES_THEME = SPEECHES_THEME,
    C = COMMENTS, SPEECHES_QUOTATION = SPEECHES_QUOTATION, SPEECHES_REFERENCE = SPEECHES_REFERENCE }, Language.extra("memory"))

return M
