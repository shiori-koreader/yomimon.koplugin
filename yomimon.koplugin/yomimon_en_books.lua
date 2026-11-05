--[[--
Yomimon: textos em inglês do gerador de falas e da memória (temas, capítulos, Caderno).

falas:   mesma estrutura de yomimon_speech.lua (abertura + núcleo + fecho por fase).
memoria: mesmas listas de yomimon_memory.lua; NOMES dá o nome de cada tema já com artigo
         (em inglês as preposições ficam nas frases, não no tema).
]]

local EN = {}

EN.falas = {
    ninfa = {
        abertura = {
            "", "", "<medrosa:Eek, a fright.|corajosa:Ready!|romantica:Sigh…|>", "Hey…", "Psst.", "Look!", "Guess what?", "Hmm…", "Ow.", "Hey, you.",
            "Can I ask you something?", "Don't laugh, okay?", "I think…",
        },
        nucleo = {
            "Letters taste like <medrosa:rain at night|otimista:jelly beans|romantica:love letters|{gosto|rain}>.",
            "Today a comma looked at me.",
            "Paper is soft when nobody's reading.",
            "I thought books were houses. They are, right?",
            "<corajosa:The dark between the pages doesn't even scare me anymore.|I'm scared of the dark between the pages.>",
            "I bit a capital letter. It was too big for me.",
            "Does the author know I exist?",
            "When I grow up, I want to live in <erudita:a Latin encyclopedia|popular:a comic book|corajosa:an atlas|an encyclopedia>.",
            "The smell of old books makes me <noturna:wide awake|sleepy> and hungry at the same time.",
            "If I stay really still, the words won't run away.",
            "I found a full stop and <amarga:felt relieved: one less chapter to suffer|otimista:wanted the next one already|got scared it was over>.",
            "The margins are my backyard.",
            "Today I read a whole word all by myself!",
            "Do stories keep going when you close the book? <medrosa:I hope not.|romantica:I hope so.|>",
            "“{livro}” is so big… will I fit inside?",
            "There's someone called {personagem} in there. Are they nice?",
            "{personagem} showed up again. <medrosa:I think {personagem} scares me.|cinica:I think {personagem} is hiding something.|I think I like {personagem}.>",
            "I ate the word “{palavra}”. It tickles my belly.",
            "Everyone in “{livro}” talks so loud.",
            "This book talks a lot about {tema}. What is that, exactly?",
            "I dreamt about {tema}. It was big and smelled of <medrosa:snuffed candles|corajosa:sea salt|ink>.",
            "I bit a comma. It tasted like {gosto}.",
            "I smelled {cheiro} between the pages. Is that normal?",
            "I dreamt I lived {lugar}.",
            "I found {coisa} in the margin. Can I keep it?",
            "There's so much “{marcante}” in this book. Can I eat it?",
            "I learned a new word: “{marcante}”. The book says it so often I memorised it.",
        },
        fecho = {
            "", "", "<medrosa:I'm shaking.|corajosa:I'm not scared!|otimista:What a good day.|romantica:How lovely.|>", "Don't tell anyone.", "Hehe.", "I think.", "Right?", "So scary.",
            "Nice.", "Can I stay a bit longer?",
        },
    },
    jovem = {
        abertura = {
            "", "", "Okay.", "So…", "Look.", "Seriously:", "Okay, confession:", "Hm.",
            "I don't want to alarm anyone, but", "I've thought about it and", "Listen.",
        },
        nucleo = {
            "I've started distrusting narrators. They all smile too much.",
            "I've read enough to get nervous, not enough to understand.",
            "Every new chapter is a door that <corajosa:I kick open|medrosa:I open with my eyes shut|maybe shouldn't open>.",
            "Sometimes I think the words read me back.",
            "I tried being ironic today. Nobody noticed. Not even me.",
            "The grown-ups in books complicate everything. Will I be like that?",
            "I know the difference between a metaphor and a lie now. Almost.",
            "I get angry when a page ends in the middle of a sentence.",
            "I prefer short chapters. <popular:Long ones are a punishment.|erudita:Lie: I've been enjoying the Russians.|Less time for things to go wrong.>",
            "Turns out not every villain knows they're the villain.",
            "Was the author of “{livro}” sad when they wrote it?",
            "{personagem} makes terrible choices. I'd make the same ones.",
            "I don't trust {personagem}. <cinica:Nor do I want to.|romantica:But my heart does.|But I'd like to.>",
            "{personagem} reminds me of someone. Maybe me.",
            "“{livro}” is teaching me things I never asked to learn.",
            "Ever since I started thinking about {tema}, <medrosa:I sleep with the light on|noturna:I don't sleep at all|I sleep badly>.",
            "Everything reminds me of {tema} now. Is that normal?",
            "I ate “{palavra}” and <erudita:knew its etymology right away|popular:pretended it was nothing|pretended I already knew it>.",
            "I used the word “{palavra}” in a sentence today. Nobody understood. Great.",
            "If “{livro}” ends badly, I'll <amarga:hardly be surprised|corajosa:take it on the chin|pretend I never read it>.",
            "Everything tastes like {gosto} lately.",
            "I closed my eyes and saw myself {lugar}. I didn't like it. Or I did.",
            "My heart went like {comparacao}.",
            "{exclamacao} Sorry. The book is rubbing off on me.",
            "This book won't stop saying “{marcante}”. Noted.",
            "One more “{marcante}” and I'll scream. Quietly.",
        },
        fecho = {
            "", "", "<medrosa:I'm shaking, okay?|corajosa:Bring it on.|amarga:As usual.|romantica:Sigh.|noturna:I won't sleep tonight.|>", "I think.", "Or not.", "Anyway.", "I'm fine. Really.", "Forget it.", "It'll work out. Maybe.",
            "Don't look at me like that.",
        },
    },
    adulta = {
        abertura = {
            "", "", "<cinica:No illusions:|erudita:As an old Greek would say,|otimista:Here's a nice thing:|romantica:Ah, the heart…|>", "Hm.", "Well.", "Look:", "Frankly,", "Let's be honest:", "Listen,",
            "Don't take this the wrong way, but", "After so much paper,", "Indeed.",
        },
        nucleo = {
            "Every narrator lies; the good ones lie elegantly.",
            "Hope is an <otimista:underrated literary genre. There, I said it|overrated literary genre>.",
            "I already know how this chapter ends. They all end like that.",
            "I read to understand people and end up <cinica:understanding them too well|romantica:liking them more|understanding them less>.",
            "A good sentence is worth more than <romantica:almost anything. Except a good love|most people I know>.",
            "Every library is a cemetery with good lighting.",
            "Prefaces are apologies in disguise.",
            "Life is a badly edited novel, full of filler chapters.",
            "<corajosa:I learned more from heroes than from footnotes. I've changed.|I learned more from footnotes than from heroes.>",
            "Paper ages better than opinions.",
            "Irony is what's left when innocence runs out.",
            "“{livro}” has good intentions. So does hell.",
            "{personagem} thinks they're the protagonist. <romantica:And they are, of my heart.|Poor thing.>",
            "{personagem} is the kind of person who dog-ears pages.",
            "Deep down, {personagem} just wanted to be read carefully. Like all of us.",
            "The author of “{livro}” knew how to write. How to live, I'm not so sure.",
            "This book insists on talking about {tema}. <erudita:The Greeks exhausted the subject long ago.|As if it were news.>",
            "Thinking about {tema} is the favourite hobby of people who read too much.",
            "“{palavra}”. A lovely word. Nobody has the patience for it anymore.",
            "I ate “{palavra}” and felt nostalgic for a world that never existed.",
            "“{livro}” won't change the world. But it changes the reader. <otimista:For the better, this time.|Sometimes for the worse.>",
            "This book smells of {cheiro}. Not a compliment. Not a complaint.",
            "Today I felt like {comparacao}. Literature does that.",
            "I found {coisa} between the chapters. I kept it, just in case.",
            "{exclamacao} There, I talk like the characters now.",
            "“{marcante}” again. The author has an obsession. Now so do I.",
            "I counted the “{marcante}” in this book. Lost count. Not interest.",
        },
        fecho = {
            "", "", "<cinica:Nobody is innocent.|romantica:The heart never learns.|erudita:I quote from memory.|popular:Simple as that.|>", "Anyway.", "Write that down.", "It is what it is.", "No surprises.", "But keep reading.",
            "I'd light a cigarette just thinking about it.", "Patience.",
        },
    },
    ancia = {
        abertura = {
            "", "", "<amarga:Wretched.|erudita:As someone better once wrote,|noturna:At this hour,|>", "Hmph.", "Listen here.", "I'll say this once:", "In my day,",
            "Nobody asks, but", "After a thousand books,", "Oh, here we go.", "For the record:", "Look at that.",
        },
        nucleo = {
            "I've read all this before, and <otimista:it was good the first time too. Rare|erudita:the first time it was in Greek, and better|it was bad the first time too>.",
            "The world doesn't get better; it just changes typeface.",
            "Wisdom is knowing exactly how badly everything will go.",
            "The young read to find themselves; I read to hide.",
            "Today's bestsellers are tomorrow's wrapping paper.",
            "I know every ending before the first page. <medrosa:And I still tremble.|romantica:And I still cry.|It's a curse.>",
            "I was an optimist once. It lasted a chapter and a paragraph.",
            "Everything beautiful ends up in a footnote.",
            "Culture is what's left when you forget what you read. I remember everything. Bad luck.",
            "I carry the weight of every library I ever ate<corajosa:, and I still climb the shelf alone|>.",
            "“{livro}”? I've eaten better. I've eaten worse. Still hungry, still right.",
            "{personagem} learned nothing. Like almost everyone.",
            "{personagem} will regret it. <otimista:Or not. Sometimes it works out.|They always do.>",
            "I've seen a thousand {personagem}s. They all end the same.",
            "The author of “{livro}” suffered. You can feel it in the binding.",
            "I spent my life thinking about {tema}. <otimista:I recommend it.|I don't recommend it.>",
            "The more I read about {tema}, the less I believe in anything.",
            "“{palavra}”. Nobody uses it anymore. I do, out of spite.",
            "I ate “{palavra}” and it tasted of <erudita:monastery Latin|popular:yesterday's paper|the last century>.",
            "After “{livro}”, I need <romantica:a handkerchief|medrosa:a light on|a cigarette> and a long silence.",
            "At my age, everything tastes like {gosto}.",
            "I once lived {lugar}, in another book. Never again.",
            "I'm like {comparacao}: nobody notices, but here I am.",
            "{exclamacao} Forgive me. Reading habit.",
            "If I read “{marcante}” one more time, I'm changing books.",
            "In my day, nobody wrote “{marcante}” so often. Or they did, and I ate it.",
        },
        fecho = {
            "", "", "<amarga:It all ends badly.|otimista:But it may get better. Perhaps.|medrosa:And lock the door.|>", "Hmph.", "Mark my words.", "Nobody listens.", "And spare me the optimism.",
            "That's all.", "How tiresome.", "Now let me read.",
        },
    },
}

EN.falas.sonho = {
    jovem = {
        abertura = { "Zzz…", "Zzz… zzz…", "(mumbling)", "(asleep)", "Hmm… zzz…", "<dominio:(dreaming {lugar})|Zzz…>" },
        nucleo = {
            "…{personagem}, no… don't close the book with me inside…",
            "…a whole library… and I'm not even hungry… <medrosa:and the lights going out…|>",
            "…the comma is chasing me…",
            "…“{livro}” turned into a house… I lived in the index…",
            "…I dreamt about {tema}… <medrosa:I hid under the cover…|otimista:it was huge and lovely…|it was huge…>",
            "…the word “{palavra}” tickling me…",
            "…mum? oh… no, it's just the cover…",
            "…the full stop… <corajosa:I jumped right over it…|so dark…>",
            "…{personagem} called me… <romantica:and I blushed all over…|I don't even have a name…>",
            "…don't turn off the light… I mean, do…",
            "…one more page… just one more…",
            "…the letters were flying… <corajosa:and I flew with them…|>",
            "…“{livro}” had <amarga:a sad ending… as always…|a happy ending… it was only a dream…>",
            "…the bookcase collapsed… and it was made of <medrosa:bones…|chocolate…>",
            "…I learned to read backwards… sdrawkcab…",
            "…the smell of {cheiro}… again…",
            "…I was {lugar}… all alone…",
            "…{coisa}… so big…",
            "…“{marcante}”… “{marcante}”… it won't leave my head…",
        },
        fecho = { "<dominio:(a smell of {cheiro})|>", "<medrosa:(shivered with fear)|romantica:(smiled in her sleep)|>", "…zzz", "(rolled over)", "(sighed)" },
    },
    velha = {
        abertura = { "Zzz…", "Zzz… zzz…", "(snoring)", "(grumbling in her sleep)", "Hmph… zzz…", "<dominio:(snoring {lugar})|(snoring)>" },
        nucleo = {
            "…grumbling about the state of literature…",
            "…no bestsellers… <popular:or just one… a little one…|please…>",
            "…a used bookshop closed just for me… <noturna:open all night…|>",
            "…{personagem} again… <romantica:I still like {personagem}…|nobody can stand {personagem}…>",
            "…“{livro}”… I'd have written it better…",
            "…{tema}… always {tema}… <romantica:how I miss it…|how tiresome…>",
            "…“{palavra}”… nobody uses it anymore… only me…",
            "…proofreading the world… <otimista:almost all correct… odd…|so many errors…>",
            "…I dreamt I was a footnote… nobody read me…",
            "…the author of “{livro}” apologising to me… deservedly…",
            "…a cigarette… a silence… <erudita:an encyclopedia in twelve volumes…|an encyclopedia…>",
            "…I wrote a review… <romantica:praised everyone…|destroyed everyone…>",
            "…the last page… <otimista:didn't disappoint this time…|always disappoints…>",
            "…grumbling in Latin… mea culpa… your culpa…",
            "…young people reading summaries… unacceptable…",
            "…{personagem} owes me money… typical…",
            "…a misplaced comma… nobody noticed… only me…",
            "…{lugar}… again…",
            "…a taste of {gosto} in my mouth… what a dream…",
            "…{coisa}… who left this here…",
            "…a whole book of “{marcante}”… how sleepy…",
        },
        fecho = { "<dominio:(muttered something about {coisa})|>", "<amarga:(muttered a curse)|romantica:(sighed a name)|>", "…zzz", "(rolled over)", "(coughed in her sleep)", "(grumbled)" },
    },
}

-- Memória ------------------------------------------------------------------------------
EN.memoria = {}

EN.memoria.NOMES = {
    morte = "death", amor = "love", guerra = "war", mar = "the sea", fe = "God", dinheiro = "money",
    loucura = "madness", tempo = "time", cidade = "the city", natureza = "nature", comida = "food",
    familia = "family", infancia = "childhood", politica = "politics", ciencia = "science", solidao = "solitude",
    arte = "art", animais = "animals", noite = "the night", viagem = "travel", vinganca = "revenge",
    liberdade = "freedom", saber = "knowledge", medo = "fear",
}

EN.memoria.FALAS_EVENTO = {
    morte = { "There was a funeral in that chapter. I smelled the candles.", "Someone died back there. I told you it would happen.",
              "A whole chapter of mourning. My paper got damp." },
    casamento = { "A wedding in this chapter. I give it three chapters before it goes wrong.", "Bride, altar, vows. Noted, for later." },
    viagem = { "Someone hit the road. I hope they don't come back the same." },
    carta = { "A letter arrived. Letters never bring good news.", "Someone wrote a letter. I'd have eaten it before anyone read it." },
    tempestade = { "A storm this chapter. The author was in a mood.", "Thunder and lightning. A cliché. Works every time." },
    doenca = { "Someone fell ill. In books, a fever is nearly a sentence.", "Doctor, fever, sickbed. I know how this ends." },
    festa = { "There was a party. Nobody invited me. As usual.", "Ball and music. Someone's about to fall for the wrong person." },
    briga = { "They fought. Finally someone said what they thought." },
    fuga = { "Someone ran away. Cowardice or wisdom, I never know.", "An escape this chapter. I'd flee this book too, sometimes." },
    crime = { "A crime this chapter. I have an alibi: I was eating the previous page.", "Blood and police. Now the book's awake." },
}
EN.memoria.FALAS_NOVO = { "Someone called %s showed up. I already don't like them.", "Who is %s? Nobody introduced us.", "%s has arrived. Trouble." }
EN.memoria.FALAS_SUMIU = { "A whole chapter without %s. Suspicious.", "Where's %s? Just vanished like that?", "No %s this chapter. Strange. Or a relief." }
EN.memoria.FALAS_AZEDOU = { "This chapter went sour.", "Everything got darker all of a sudden. I liked it. I mean, what a shame." }
EN.memoria.FALAS_ADOCOU = { "That chapter was light, actually. Suspicious.", "A sweet chapter. Someone will pay for it later.", "A little light. Don't get used to it." }
EN.memoria.FALAS_VIROU = { "The book was about %s and this chapter only talked about %s.", "Change of subject: out goes %s, in comes %s." }

EN.memoria.FALAS_REFERENCIA = {
    jovem = {
        "This book mentions {nome} {n} times. Who is {nome}? Should I worry?",
        "{nome} again. Everyone knows {nome} except me.",
        "The book quoted {nome} once more. I wrote it down, to look clever.",
    },
    velha = {
        "This book quotes {nome} {n} times. Show-off.",
        "{nome} again. The author must have a poster on the wall.",
        "Another mention of {nome}. I've read them too, you know. Eaten, actually.",
    },
}
EN.memoria.FALAS_CITACAO = {
    jovem = {
        "{nome} said “{fala}”. I'd never be that brave.",
        "“{fala}” — that's what {nome} said. I repeated it quietly.",
        "I can't stop thinking about what {nome} said: “{fala}”.",
        "{nome} said “{fala}”. I wrote it down to use one day.",
    },
    velha = {
        "{nome} said “{fala}”. Noted, never to be forgiven.",
        "“{fala}”, said {nome}. I'd have said it better.",
        "{nome}: “{fala}”. Spoken like someone who never ate a dictionary.",
        "Remember when {nome} said “{fala}”? I do. I remember everything.",
    },
}

EN.memoria.FALAS_NARRADOR = {
    f = {
        "The woman telling this story talks a lot about herself. I like it. No, I don't.",
        "The narrator won't stop talking about herself. I relate.",
        "She narrates like someone confessing. I read like someone judging.",
    },
    m = {
        "The man telling this thinks he's very interesting. We'll see.",
        "The narrator talks about himself like someone reading his own diary aloud.",
        "He narrates, he opines, he praises himself. Typical.",
    },
    neutro = {
        "This book is told by someone who says \"I\" a lot. I distrust people who say \"I\" a lot.",
        "A first-person narrator. In other words: one side of the story.",
        "Whoever's telling this talks about themselves a lot. So would I, if anyone read me.",
    },
}

EN.memoria.FALAS_TEMA = {
    morte = { "Every chapter is a small funeral.", "I've thought about my epitaph. It's short. Like me." },
    amor = { "Love. I've read so much about it I got heartburn.", "I've never loved anyone. Except a dictionary, once." },
    guerra = { "Every page turned is a trench.", "Peace is just the gap between two chapters." },
    mar = { "Since that book, everything looks like a shipwreck to me.", "Salt on the paper. Or mould. Same thing." },
    fe = { "If God exists, he doesn't read footnotes." },
    dinheiro = { "Banknotes taste worse than book paper.", "The rich in your books are never happy. Serves them right." },
    loucura = { "Last night I dreamt I was a semicolon.", "Sanity is overrated. Narrators know." },
    tempo = { "Time passes. I eat. Time passes again." },
    cidade = { "I miss a city I've never seen. Your fault.", "Trams. Smoke. People. Ugh. I love it." },
    natureza = { "A tree died so I could eat this book. Thank you.", "Rain outside. In here, just paper. I prefer it." },
    comida = { "These characters eat better than I do. I eat paper.", 
               "Every good book has a dinner where everything goes wrong." },
    familia = { "Family: the first novel nobody chooses to read.", "Mother, father, inheritance. I know where this is going.",
                "I have no family. I have a bookcase. Close enough." },
    infancia = { "Childhood in books is always better than it was.",
                 "A child in a book is an omen. Someone's going to grow up badly." },
    politica = { "Kings, laws, thrones. They all end up in footnotes.", "Revolution: when the people swap oppressors.",
                 "Politics in books is just like outside, only with more adjectives." },
    ciencia = { "Too much science. Someone is going to create something they shouldn't.", "Experiment, laboratory… I smell disaster.",
                "I'm an experiment too. Nobody asked my opinion." },
    solidao = { "Solitude. Finally a theme I understand.", "Nobody in this book has anyone to talk to. Neither do I.",
                "The silence between two pages is the loneliest place there is." },
    arte = { "Poetry. I ate a verse and now my mouth rhymes.", 
             "A painting described in words. Art inside art. Indigestible." },
    animais = { "Lots of animals in this book. I feel represented.", 
                "The animals in books are always more sensible than the people." },
    noite = { "Moon, candle, darkness. The author wrote this at 3 a.m., I bet.",
              "Nothing good happens after midnight in books. I love it." },
    viagem = { "Road, horizon, map. Someone's getting lost.",
               "Travelling is reading with your feet. I prefer my teeth." },
    vinganca = { "Revenge. A dish best served cold. Like paper.", "A grudge in storage. This book will end in blood.",
                 "Betrayal in the air. I can smell it before the narrator does." },
    liberdade = { "Chains, prisons, escapes. I live between two covers. I relate.", 
                  "Nobody is free in books. Only whoever closes the book." },
    saber = { "A book about books. Metafiction gives me heartburn.", "The more you know, the less you sleep. I know.",
              "Library is my favourite word. After glue." },
    medo = { "This book is scary. I'll sleep under the dust jacket.", "Monsters, ghosts. The real horror is the footnotes.",
             "A shiver ran down my spine. Keep going. But slowly." },
}

-- Caderno: comentários com contexto (mesmas chaves de C em yomimon_memory.lua)
EN.memoria.C = {}
local C = EN.memoria.C
C.personagem = {
    "%s again? Are you in love or just suspicious?",
    "Everything revolves around %s. Even you.",
    "I wouldn't trust %s to hold a bookmark.",
    "%s talks pretty. Pretty talkers hide things.",
    "You highlighted %s. Noted. I'll use it against you.",
    "If %s knew they were being highlighted, they'd be unbearable.",
    "%s deserved a better book. Or a crueller author.",
    "I've nibbled the page where %s appears. It tasted of drama.",
}
C.dois = {
    "%s and %s. Someone's going to regret this.",
    "%s and %s in the same sentence. That never ends well.",
}
C.tema = {
    morte = { "Another funeral. I'm already in mourning in advance.", "Death again. This author has a type.",
              "You highlighted death. I highlight lunch.", "Every beautiful sentence smells of the grave." },
    amor = { "Love. Nobody learns, everybody highlights.", "Romantic. I'll pretend I didn't see.",
             "That won't last three chapters." },
    guerra = { "Gunpowder. Even the paper got warm.", "Nobody wins a war. Only the bookbinder.",
               "You highlight battles like someone collecting scars." },
    mar = { "More water. This book is going to make me rust.", "The sea again. I suspect the author never left the harbour.",
            "You highlighted the sea. I'll take the shipwreck." },
    fe = { "God showed up. I pretended to be asleep.", 
           "If praying worked, I wouldn't eat paper." },
    dinheiro = { "Money. Nobody in books is rich and happy at once.", "Talks of gold, and it's still paper.",
                 "You highlighted the price of things. Smart." },
    loucura = { "Madness. Finally someone honest.", "This paragraph has a fever. I touched it and felt it.",
                "Delirium, highlighted. We're all mad here." },
    tempo = { "Nostalgia, highlighted. How old-fashioned. I like it.",
              "You highlight the past like someone saving crumbs." },
    cidade = { "The city. Noise, smoke and someone crying on a corner.", "This street smells like a used book.",
               "You highlighted the city. I highlight the silence of the bookshop." },
    natureza = { "Trees. One of them became this book. You're welcome.", "Rain on paper. What a waste of a dry page.",
                 "Nature, highlighted. Out there it's so big and so without footnotes." },
    comida = { "You highlighted food. Hungry, or just nostalgic?", "This passage has flavour. Literally." },
    familia = { "Family, highlighted. Want to talk about it?", "Everyone highlights their mother eventually." },
    infancia = { "You highlighted childhood. Missing when everything was a first time.", "A child in the passage. I kept it carefully." },
    politica = { "Politics, highlighted. Going to argue at dinner?", "Kings and laws. Do you like power or watching it fall?" },
    ciencia = { "Science, highlighted. Careful what you create.", "An experiment. I hope it goes wrong, it's more fun." },
    solidao = { "You highlighted solitude. I'm here. Sort of.", "This passage is alone. Like whoever highlighted it." },
    arte = { "Art, highlighted. What a sensitive reader. How dangerous.", "A verse. I caught it before it got away." },
    animais = { "You highlighted an animal. I'm an animal. Noted.", "An animal in the passage. Animals always understand everything." },
    noite = { "Night, highlighted. You like the dark too.", "The moon in the passage. A pretty cliché." },
    viagem = { "You highlighted a road. Want to leave?", "A journey. Take a book. Take me along." },
    vinganca = { "Revenge, highlighted. Should I be worried about you?", "A beautiful grudge. Scary, but beautiful." },
    liberdade = { "Freedom, highlighted. Beautiful. Rare.", "You highlighted chains. Who's holding you?" },
    saber = { "You highlighted a book inside the book. I like it.", "Knowledge. The best thing there is to eat." },
    medo = { "You highlighted fear. Brave of you.", "This passage gives me shivers. Good taste." },
}
C.curto = {
    "Three words and you're already moved. Easy.",
    "Short. Fits on a tombstone.",
    "Few words, lots of weight. Respect.",
    "That's almost a proverb. Or a threat.",
}
C.longo = {
    "You highlighted half a page. Make up your mind.",
    "That's not a highlight, that's a change of address.",
    "If you're going to highlight everything, just give me the whole book.",
    "A whole paragraph. You weren't reading, you were agreeing.",
}
C.nota = {
    "You wrote “%s”. I'd write worse. Or better. Doesn't matter.",
    "Your note: “%s”. I kept it in my belly, with the rest.",
    "“%s”, you said. The sentence didn't ask for your opinion, but fine.",
}
C.madrugada = {
    "Highlighting in the small hours. Everything okay at home?",
    "The small hours. When every sentence sounds true.",
}
C.primeiro = {
    "First highlight in “%s”. The romance begins.",
    "First mark in “%s”. There's still time to back out.",
}
C.muitos = {
    "That's %s highlights in this book. Obsession noted.",
    "%s highlights. One more and you'll have to pay rent.",
}
C.capitulo = {
    "Again in “%s”. That chapter got you.",
    "Another one in “%s”. I'll call that chapter yours.",
}
C.geral = {
    ovo = { "…" },
    jovem = {
        "You highlighted this. Should I be worried?",
        "I kept it. But I'm not sure I understood.",
        "This scared me. In a good way. I think.",
        "Pretty. I distrust pretty things.",
        "Is this true? Books lie sometimes, right?",
    },
    velha = {
        "Highlighted. Classic move for someone who doesn't know what to do with their hands.",
        "I've read better. But fine, I'll keep it.",
        "This will seem deep until tomorrow morning.",
        "I agree. I hate agreeing.",
        "I tore this page out of my heart. Figuratively. Maybe.",
        "Deep as a puddle. But a pretty puddle.",
        "Someone wrote this on purpose. The nerve.",
        "I'll pretend this sentence didn't get to me.",
    },
}

return EN
