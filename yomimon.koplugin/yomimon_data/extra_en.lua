--[[--
Lote 2 de frases (inglês). Mesma estrutura e brechas de extra_pt.lua; adaptado, não traduzido
palavra por palavra. {tema} e os %s de FALAS_VIROU já vêm com artigo ("the sea").
]]

local X = { estado = { FALAS = { ovo = {}, jovem = {}, velha = {} } }, contexto = {}, memoria = { C = {} } }
local E, M, C = X.estado, X.memoria, X.memoria.C

E.FALAS.ovo._todas = {
    "(a tiny crack appeared and vanished)",
    "(silence. A judging silence.)",
}
E.FALAS.jovem.feliz = {
    "The paper was perfectly crunchy today.<dominio: With a hint of {gosto}.|>",
    "I think I got one of the author's jokes. I laughed alone.",
    "I ate so well I forgot to be scared.<medrosa: For five minutes.|>",
    "I'm so full I'll read lying down.",
    "Nobody died today. Not near me, anyway.",
    "A whole chapter without a fright. What luxury.",
    "I liked it so much I reread the same page. Twice. Eating.",
}
E.FALAS.jovem.normal = {
    "Do letters get ticklish when I walk over them?",
    "I found a coffee stain in the margin. Someone lived here.",
    "If I collect every comma I've eaten, can I make a sentence?",
    "I tried reading upside down today. Not recommended.",
    "The index is the map. I'm the explorer<medrosa: who stays at base camp|>.",
    "Sometimes I feel like a minor character in my own life.",
    "I read the word “end” and panicked. It was only a chapter.",
    "Footnotes whisper. I hear everything.",
    "I like the sound of a page turning. Like <medrosa:footsteps in the hall|romantica:someone sighing|wind calling>.",
}
E.FALAS.jovem.triste = {
    "My belly rumbles louder than my complaints.",
    "I licked the cover. Only {gosto|dust}.",
    "If I faint, revive me with a preface.",
    "I'm so weak a comma could knock me over.",
    "I dreamt of a banquet of dictionaries. Woke up hungry.",
    "Do you remember I exist? I remember you exist.",
    "One sentence. Half a sentence. A semicolon. Anything.",
    "The silence of the shelf is making me <medrosa:shiver|sad>.",
    "I promise not to complain about the book. Just give me one.",
}
E.FALAS.jovem.casulo = {
    "Hidden. Knock on the page three times and I'll come out.",
    "It smells like a forgotten book in here. Scary.",
    "I made a nest from dog-eared corners. Come back soon.",
    "I'm on hunger strike. Not by choice.",
    "I hid because I got tired of waiting standing up.",
    "I'll only come out when I hear a page turn.",
    "It's dark in here, but at least there's no villain.",
}
E.FALAS.jovem.repouso = {
    "Zzz… dreaming I was <corajosa:a paper sword|romantica:a love note|{coisa|a bookmark}>…",
    "Zzz… the letters are dancing… <romantica:a waltz…|medrosa:all around me…|>",
    "Zzz… I ate a paper cloud… <otimista:it tasted of sunshine…|>",
}
E.FALAS.velha.feliz = {
    "A good page. I'll keep the taste<dominio: of {gosto}|> until tomorrow.",
    "Literature worked today. Tell no one.",
    "As satisfied as someone who found a first edition.",
    "Even my imaginary cigarette is in a good mood.",
    "The world is still awful, but the prose was good.",
    "I ate well. I'll be kind for about fifteen minutes.",
    "What a paragraph. I almost forgave the author for the others.",
}
E.FALAS.velha.normal = {
    "I've seen so many endings that I only read the middles now.",
    "Every generation thinks it invented suffering. Books laugh.",
    "An organised bookshelf is a cemetery with surnames.",
    "Reading is <romantica:falling in love slowly|cinica:distrust in writing|disagreeing slowly>.",
    "The author died. His commas live on. Poetic justice.",
    "<otimista:I like books that please me straight away. No shame.|I distrust books that please me straight away.>",
    "The best stories are the ones nobody remembers to recommend.",
    "Ageing is changing your mind without admitting it.",
    "Rereads are like old friends: tiresome and necessary.",
}
E.FALAS.velha.triste = {
    "Hunger and clarity. I'd settle for just the hunger.",
    "I ate my own patience. Nothing left.",
    "I used to have libraries. Now I have nostalgia.",
    "I'm wasting away elegantly. That's something.",
    "They left me in the dark with my thoughts. Terrible company.",
    "Old hunger is the worst hunger: it has a memory.",
    "One page, for charity. Or for literature.",
    "I'm as empty as a famous author's preface.",
}
E.FALAS.velha.casulo = {
    "I've hidden. Not out of fear: out of principle.",
    "In here, the silence is better written than most books.",
    "Don't insist. Read. It's the only key.",
    "I'm on an involuntary spiritual retreat.",
    "I'll come back when you open a book. Not before.",
}
E.FALAS.velha.repouso = {
    "Zzz… dreaming of a bookshop <romantica:with an old love inside|with no customers>…",
    "Zzz… proofreading my own epitaph… <otimista:it came out lovely…|medrosa:too soon…|>",
    "Zzz… a will-o'-the-wisp made of paper… <medrosa:following me…|>",
}
E.FALAS_LIVRO = {
    jovem = {
        "I saved a little piece of “%s” for later.",
        "Does “%s” end happily? <otimista:I bet it does.|amarga:I doubt it.|I get nervous just thinking about it.>",
        "“%s” smells like <medrosa:a cellar|romantica:a kept letter|adventure>. Or an old shelf.",
        "“%s” left me thirsty for more pages.",
    },
    velha = {
        "“%s”. I've seen more honest covers.",
        "“%s” has ambitions. <erudita:Well founded, I admit.|popular:Too many for my taste.|Sometimes that's enough.>",
        "The trouble with “%s” is that it knows it's good.",
        "I'll speak ill of “%s” only when I'm finished. Fairness.",
        "“%s” reminds me of another book. A better one. But it reminds me.",
    },
}
E.FALAS_PERSONAGEM = {
    jovem = {
        "Does %s know I'm reading?",
        "I drew %s in the margin. It came out ugly.",
        "Is %s brave or just thoughtless? I can never tell.",
        "I'd like to be friends with %s. <medrosa:Or run away. Run away, I think.|Or run away. Either way.>",
        "%s reminds me of someone I haven't met yet.",
    },
    velha = {
        "%s is the kind of person who leaves mugs on books.",
        "I've seen %s in a thousand books, under other names.",
        "%s has the depth of <romantica:a well. I dived in, heart first|a footnote>.",
        "I don't trust %s. <romantica:Lie: I do. There, I confessed.|Or anyone who does.>",
        "%s will regret it. It's only a matter of chapters.",
        "If %s were a book, I'd abandon it halfway.",
    },
}
E.FALAS_MUDA_PERTO = {
    jovem = {
    },
    velha = {
    },
}
E.FALAS_MUDA_IMINENTE = {
    ovo = { "(something in there is impatient)" },
    jovem = { "I'm almost coming out of myself!", "One more page and I'll be someone else!" },
    velha = { "A little more and I change. On the outside." },
}

X.contexto.madrugada = {
    jovem = { "{hora}. If we're quiet, the book's ghosts won't wake up.", "Reading at {hora}? I'll stay up with you.<medrosa: Holding hands, if I may.|>",
              "{hora}. The letters are sleepy, <diurna:and so am I. Yawn…|but I'm not>." },
    velha = { "{hora}. Official hour of incorrigible readers.", "It's {hora}. <noturna:The best hour in the world.|Insomnia and this book deserve each other.>",
              "{hora}. Even the villains are asleep. <medrosa:I hope.|You're not.>" },
}
X.contexto.recorde = {
    jovem = { "{n} pages! Nobody ever fed me so much in one day!", "Record: {n} pages. I'm telling every comma.",
              "{n} pages today. My belly wants to give a speech." },
    velha = { "{n} pages. A new record. I'll log it with suspicion.", "A record of {n} pages. Are you all right?",
              "{n} pages in a day. That's not reading, that's a lifestyle change." },
}
X.contexto.maratona = {
    jovem = { "{n} pages! <corajosa:Fifty more?|Can I nap inside the book?>", "That's {n} pages already. I'm rolling across the shelf.",
              "{n} pages… my belly is the size of a dictionary." },
    velha = { "{n} pages today. Even I'm tired, and I only eat.",
              "{n} pages. Remember there's life outside the book. So I'm told." },
}
X.contexto.sumiu = {
    jovem = { "{n} days! <medrosa:I thought something had happened.|I thought you'd forgotten me for good.>", "You're back after {n} days. <romantica:I missed you so much. And food.|cinica:I'll pretend I didn't notice.|I missed you. And food.>",
              "{n} days without paper. I was <erudita:reciting quotations from memory|counting the fibres in the cover>." },
    velha = { "{n} days. <romantica:I counted every one.|I'll pretend I didn't count.>", "<dominio:After {n} days, the bookshelf smells of {cheiro}.|After {n} days, the bookshelf looks like a museum.>",
              "{n} days without reading. I hope it was worth it. <otimista:I bet it was.|I doubt it.>" },
}
X.contexto.tarde = {
    jovem = { "{hora}. There's still time for one more chapter. And another.", "It's {hora}. I yawn, you turn the page.",
              "{hora} and the book is still open. I like that." },
    velha = { "{hora}. The day is over, the reading isn't.", "It's {hora}. A fine hour for books and bad decisions.",
              "{hora}. Nobody reads at this hour out of obligation." },
}
X.contexto.cedo = {
    jovem = { "{hora}! The sun's barely up and you're already reading. <diurna:My hour!|>", "Good morning! At {hora} the pages smell of dew.",
              "{hora}. Coffee for you, paper for me." },
    velha = { "{hora}. Reading before the world starts talking nonsense.", "It's {hora}. <noturna:An odd hour to be awake.|The best hour: nobody interrupts.>",
              "{hora}. Reading early is a luxury few allow themselves." },
}
X.contexto.sessao = {
    jovem = { "{n} pages without getting up! Are your feet okay?", "{n} pages in a row. I'm dizzy from eating.",
              "{n} pages in one go. This book is stuck to you." },
    velha = { "{n} pages without a break. Either the book is good or you're hiding.", "{n} pages in a row. Respect. But blink.",
              "A {n}-page sitting. The old copyists would approve." },
}
X.contexto.sequencia = {
    jovem = { "{n} days in a row! <romantica:I think we're a couple now.|I think we have a routine.>", "Day {n} in a row. My belly knows when dinner is now.",
              "{n} days without skipping one! <medrosa:Can I throw a party? A small one?|Can I throw a party?>" },
    velha = { "{n} days in a row. Discipline is the most elegant vice.", "Day {n}. Consistency. Rare and dull. I like it.",
              "{n} days without fail. <otimista:This will go far.|Don't ruin it now.>" },
}
X.contexto.bom_dia = {
    jovem = { "{n} pages today. I'm really growing!", "I've eaten {n} pages today and I still want more.",
              "{n} pages today. A good day to be a Yomimon.<dominio: A whiff of {cheiro} in the air.|>" },
    velha = { "{n} pages today. Decent. Noted.", "{n} pages. The day wasn't wasted.", "{n} pages today. Enough to form an opinion." },
}
X.contexto.nada_hoje = {
    jovem = { "Nothing yet today. Not even a paragraph.", "No pages today. I'm staring at the closed book.",
              "The day went by and I'm hungry for a story." },
    velha = { "No pages today. The bookshelf noticed.", "Today: zero. The book is offended.", "A whole day without reading. What a waste of daylight." },
}
X.contexto.reta_final = {
    jovem = { "{pct} of “{livro}”! Almost there. I'm nervous.", "Not much of “{livro}” left. I'll eat slowly.",
              "The home stretch of “{livro}”. I promise not to cry. Maybe." },
    velha = { "{pct} of “{livro}”. The author can't escape now.", "Home stretch of “{livro}”. Ready your heart. And your cigarette.",
              "Nearly the end of “{livro}”. Endings reveal who the author really is." },
}
X.contexto.metade = {
    jovem = { "Halfway through “{livro}”! Downhill from here, right?", "We're in the middle of “{livro}”. What happens now?",
              "Halfway through “{livro}” and I already have theories." },
    velha = { "Halfway through “{livro}”. The moment a book decides whether it's any good.",
              "The middle of “{livro}”. The plot is ready to collapse.", "Halfway through “{livro}”. This is where authors get tired." },
}
X.contexto.comeco = {
    jovem = { "Starting “{livro}”! I don't know who to like yet.", "First pages of “{livro}”. I'm watching everyone.",
              "“{livro}” has begun. I already like the smell." },
    velha = { "The start of “{livro}”. Every book swears it'll be different.", "First pages of “{livro}”. I'm still being polite.",
              "“{livro}” has begun. Let's see how long my patience lasts." },
}
X.contexto.fim_de_semana = {
    jovem = { "A weekend with a book is the best weekend.", "No rush, no school, just paper.", "We can read till late today, right?" },
    velha = { "The weekend. The world rests, the bookshelf works.", "A day off from the world, a shift at the shelf.",
              "Weekend reading. Civilisation preserved." },
}

M.FALAS_EVENTO = {
    morte = { "Another one gone. The page got heavier.", "A death. I mourned for three paragraphs." },
    casamento = { "They married. I'm marking on the calendar how many chapters it lasts.", "Bells, veil, vows. I've seen this film." },
    viagem = { "Someone left. The book got bigger." },
    carta = { "A letter. Someone will cry or lie.", "Letters in books never arrive at the right time." },
    tempestade = { "It rained the whole chapter. I'm damp with suspense.", "Lightning, wind, drama. The author's sky was nervous." },
    doenca = { "Illness this chapter. Books love a fever.", "Someone bedridden. I'll read more slowly, out of respect." },
    festa = { "A party this chapter. Someone will leave it with regrets.", "Music and glasses. I distrust so much joy." },
    briga = { "They fought badly. At least now we know what they think.", "An argument this chapter. I'd take a side. Mine." },
    fuga = { "Someone slipped away in the dead of the page.", "An escape this chapter. Sometimes it's the only dignified way out." },
    crime = { "A crime this chapter. I was eating the index, I swear.", "Blood. The book woke up and so did I." },
}
M.FALAS_NOVO = { "Someone called %s arrived. I'll watch from a distance.", "%s entered the story without asking.",
                 "%s appeared. Books always bring new people at the worst time." }
M.FALAS_SUMIU = { "No sign of %s. Someone should go and look.", "%s disappeared from the chapter. Coincidence? I doubt it.",
                  "I missed %s. Don't tell anyone.", "A chapter without %s. The book breathed differently." }
M.FALAS_AZEDOU = { "The chapter suddenly went dark.", 
                   "This chapter tastes of bad news.", "Everything turned grey. It matches the paper." }
M.FALAS_ADOCOU = { "A gentle chapter. Suspicious, but I'll enjoy it.", "The book smiled this chapter.",
                   "Some lightness. I saved a bit for bad days.", "A sweet chapter. Something bad is coming, I bet." }
M.FALAS_VIROU = { "This chapter got tired of %s and wandered off to %s.", "The author grew bored of %s and moved on to %s." }

M.FALAS_TEMA = {
    morte = { "After so many funerals, I've learned to read in black.", "Death is the one spoiler every book gives away." },
    amor = { "Love in books beats the real thing: it's been edited.", "I've read so much love I've started to distrust hugs." },
    guerra = { "Wars in books end on the last page. The others don't.", "So much gunpowder. Even my paper got nervous." },
    mar = { "I keep dreaming of paper waves.", "I feel the ship rocking even when the page stops." },
    fe = { "I prayed for a happy ending. Nobody answered.", "If there's a heaven, I hope it has a library." },
    dinheiro = { "In books, people with money just have better problems.", "I counted coins the whole chapter. None were mine." },
    loucura = { "Madness in books seems more and more sensible to me.", "Some days I talk to the commas." },
    tempo = { "Time in books passes quickly. Out here too, but without an index.", "I aged a chapter today." },
    cidade = { "Smell of wet streets on the paper.", "So many people in the cities of books, and nobody reads." },
    natureza = { "A leaf in the book. A leaf of paper in my mouth.", "Books taught me the names of plants I'll never see." },
    comida = { "A book with food makes me twice as hungry." },
    familia = { "Every family in books has a secret in the pantry.", "Family: the plot nobody chooses and everyone reads." },
    infancia = { "Children in books know things adults forget." },
    politica = { "Crowns, laws and speeches. All paper.", "The powerful in books always fall. Good thing they're books." },
    ciencia = { "Science in books explodes a lot." },
    solidao = { "The characters' loneliness keeps me company.", "They're so alone in books. I feel so accompanied." },
    arte = { "A painting described in words paints my mind.", "Artists in books suffer beautifully." },
    animais = { "The animals in books are wiser than their owners." },
    noite = { "Night in books is darker than the real one.", "I like chapters set at night. Like us." },
    viagem = { "Suitcases, trains, ships. Me, just pages." },
    vinganca = { "Revenge in books always costs more than the insult.", "A well-written grudge is a dangerous art." },
    liberdade = { "Paper chains. Still chains.", "Freedom in books fits on one page. Ours doesn't." },
    saber = { "The more books about books, the more I want to eat libraries.", "Knowing too much is fattening. I know." },
    medo = { "This book makes me look under the page.", "Monsters on paper. I prefer real ones: they're slower." },
}

C.tema = {
    morte = { "You highlighted death again. Everything okay?", "A line of mourning. I kept it carefully." },
    amor = { "You highlighted love. I pretended not to see.", "That's something you underline when you love. Or remember." },
    guerra = { "You highlighted war. May it stay on paper.", "A battle passage. Kept without gunpowder." },
    mar = { "You highlighted the sea. I tasted salt.", "A wave, highlighted. The page got wet." },
    fe = { "You highlighted a prayer. I'd like one too.", "Faith, highlighted. Noted respectfully." },
    dinheiro = { "You highlighted money. Practical.", "Coins in the passage. None for me." },
    loucura = { "You highlighted madness. That makes two of us.", "This passage is a little mad. I like it." },
    tempo = { "You highlighted time. It'll pass anyway.", "Nostalgia in the passage. Saved for later." },
    cidade = { "You highlighted the city. Noisy, but lovely.", "A street, highlighted. Smell of rain on asphalt." },
    natureza = { "You highlighted a tree. It thanks you.", "Nature in the passage. I breathed better." },
    comida = { "You highlighted food. Now I want some." },
    familia = { "You highlighted family. There's something there.", "A family passage. Kept without questions." },
    infancia = { "You highlighted childhood. Such a small, enormous line.", "A child in the passage. Careful rereading it." },
    politica = { "You highlighted power. Be careful with it.", "A passage about a king. A paper crown." },
    ciencia = { "You highlighted an experiment. Let's see how it ends.", "Science in the passage. Smells like a laboratory." },
    solidao = { "You highlighted loneliness. I moved closer.", "A lonely passage. Now it has company: me." },
    arte = { "You highlighted a verse. It's prettier underlined.", "Art in the passage. Kept it framed." },
    animais = { "You highlighted an animal. I like you.", "An animal in the passage. Animals always understand." },
    noite = { "You highlighted the night. It suits us.", "A night passage. I lit an imaginary candle." },
    viagem = { "You highlighted a journey. Take me.", "A road passage. I kept the map." },
    vinganca = { "You highlighted revenge. I'll sleep with one eye open.", "A grudge in the passage. Noted, as a precaution." },
    liberdade = { "You highlighted freedom. Such a light line.", "A passage without chains. Lovely." },
    saber = { "You highlighted knowledge. Going to quote it at dinner?", "A wise passage. I got cleverer just eating it." },
    medo = { "You highlighted fear. Brave of you.", "A shiver of a passage. I left the light on." },
}
C.curto = { "Few words, lots of damage.", "It would fit on a tattoo. Don't.", "A small line, a big echo." }
C.longo = { "You highlighted a whole paragraph. Agreed with all of it?", "Is this a highlight or a chapter?",
            "You highlighted so much the page turned yellow." }
C.nota = { "You noted “%s”. I'd have noted it with more drama.", "“%s” — your note. I half agree.",
           "You wrote “%s”. I kept it with the sentence." }
C.madrugada = { "Highlighted in the small hours. Night sentences weigh more.", "Highlighted at %s in the morning. Kept with care.",
                "Small hours and a highlighter. A dangerous combination." }
C.primeiro = { "The first highlight in “%s”. Let the collection begin.", "First mark in “%s”. Good choice.",
               "“%s” got its first highlight. It'll be insufferable now." }
C.muitos = { "%s highlights in this book. It's yours now.", "That's %s highlights. This book got you.",
             "%s marks. Soon it'll be easier to highlight what you didn't like." }
C.capitulo = { "“%s” again. That chapter is a magnet.", "Another highlight in “%s”. That chapter has something with you.",
               "“%s” is full of your marks." }
C.personagem = { "%s again. That character lives in your head.", "You highlighted %s. They don't deserve that much.",
                 "%s in the sentence. Noted for gossip later.", "Do you like %s or just pity them?", "%s. Always. What an obsession." }
C.dois = { "%s and %s in the same passage. This will cause talk.", "%s and %s together. I've seen how this ends.",
           "Between %s and %s, I'd take the bookmark.", "%s and %s. A dangerous pair." }
C.geral = {
    jovem = { "I kept this passage in my belly pocket.", "Is this beautiful or sad? Both?", "I'll repeat this quietly before bed.",
              "I keep thinking about this line. A lot.", "This passage tastes like a secret." },
    velha = { "Highlighted. Another one for the collection nobody rereads.", "This has ambitions. I like well-made ambitions.",
              "Saved. In ten years it'll seem obvious.", "A sentence with an epigraph's calling.",
              "I agree, with reservations. Always with reservations.", "Beautiful. And I hate admitting it's beautiful." },
}
M.FALAS_CITACAO = {
    jovem = { "I saved what {nome} said: “{fala}”.",
              "“{fala}”. That was {nome}. I was impressed." },
    velha = { "“{fala}”, said {nome}. I'd have edited it.", "{nome} let slip a “{fala}”. Noted, with suspicion.",
              "I'm still digesting “{fala}”, from {nome}." },
}
M.FALAS_REFERENCIA = {
    jovem = { "{nome} again! I'll look up who that is. I won't.", "The book has mentioned {nome} {n} times. Should I worry?" },
    velha = { "{n} mentions of {nome}. The author wanted to look clever.", "{nome}, once more. We get it, author, you've read things." },
}

return X
