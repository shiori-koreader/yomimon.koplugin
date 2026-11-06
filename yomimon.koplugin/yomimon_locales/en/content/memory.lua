-- Memory and notebook phrases. NAMES gives each theme with its article (English keeps prepositions in the
-- phrases); a language without NAMES uses the built-in grammar.
local M = {}

M.NAMES = {
    morte = "death", amor = "love", guerra = "war", mar = "the sea", fe = "God", dinheiro = "money",
    loucura = "madness", tempo = "time", cidade = "the city", natureza = "nature", comida = "food",
    familia = "family", infancia = "childhood", politica = "politics", ciencia = "science", solidao = "solitude",
    arte = "art", animais = "animals", noite = "the night", viagem = "travel", vinganca = "revenge",
    liberdade = "freedom", saber = "knowledge", medo = "fear",
}

M.SPEECHES_EVENT = {
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
M.SPEECHES_NEW = { "Someone called %s showed up. I already don't like them.", "Who is %s? Nobody introduced us.", "%s has arrived. Trouble." }
M.SPEECHES_VANISHED = { "A whole chapter without %s. Suspicious.", "Where's %s? Just vanished like that?", "No %s this chapter. Strange. Or a relief." }
M.SPEECHES_SOURED = { "This chapter went sour.", "Everything got darker all of a sudden. I liked it. I mean, what a shame." }
M.SPEECHES_SWEETENED = { "That chapter was light, actually. Suspicious.", "A sweet chapter. Someone will pay for it later.", "A little light. Don't get used to it." }
M.SPEECHES_TURNED = { "The book was about %s and this chapter only talked about %s.", "Change of subject: out goes %s, in comes %s." }

M.SPEECHES_REFERENCE = {
    young = {
        "This book mentions {nameText} {n} times. Who is {nameText}? Should I worry?",
        "{nameText} again. Everyone knows {nameText} except me.",
        "The book quoted {nameText} once more. I wrote it down, to look clever.",
    },
    old = {
        "This book quotes {nameText} {n} times. Show-off.",
        "{nameText} again. The author must have a poster on the wall.",
        "Another mention of {nameText}. I've read them too, you know. Eaten, actually.",
    },
}
M.SPEECHES_QUOTATION = {
    young = {
        "{nameText} said “{speech}”. I'd never be that brave.",
        "“{speech}” — that's what {nameText} said. I repeated it quietly.",
        "I can't stop thinking about what {nameText} said: “{speech}”.",
        "{nameText} said “{speech}”. I wrote it down to use one day.",
    },
    old = {
        "{nameText} said “{speech}”. Noted, never to be forgiven.",
        "“{speech}”, said {nameText}. I'd have said it better.",
        "{nameText}: “{speech}”. Spoken like someone who never ate a dictionary.",
        "Remember when {nameText} said “{speech}”? I do. I remember everything.",
    },
}

M.SPEECHES_NARRATOR = {
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
    neutral = {
        "This book is told by someone who says \"I\" a lot. I distrust people who say \"I\" a lot.",
        "A first-person narrator. In other words: one side of the story.",
        "Whoever's telling this talks about themselves a lot. So would I, if anyone read me.",
    },
}

M.SPEECHES_THEME = {
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

-- Notebook: comments with context (same keys as C in yomimon_memory.lua)
M.C = {}
local C = M.C
C.character = {
    "%s again? Are you in love or just suspicious?",
    "Everything revolves around %s. Even you.",
    "I wouldn't trust %s to hold a bookmark.",
    "%s talks pretty. Pretty talkers hide things.",
    "You highlighted %s. Noted. I'll use it against you.",
    "If %s knew they were being highlighted, they'd be unbearable.",
    "%s deserved a better book. Or a crueller author.",
    "I've nibbled the page where %s appears. It tasted of drama.",
}
C.two = {
    "%s and %s. Someone's going to regret this.",
    "%s and %s in the same sentence. That never ends well.",
}
C.theme = {
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
C.short_one = {
    "Three words and you're already moved. Easy.",
    "Short. Fits on a tombstone.",
    "Few words, lots of weight. Respect.",
    "That's almost a proverb. Or a threat.",
}
C.long = {
    "You highlighted half a page. Make up your mind.",
    "That's not a highlight, that's a change of address.",
    "If you're going to highlight everything, just give me the whole book.",
    "A whole paragraph. You weren't reading, you were agreeing.",
}
C.grade = {
    "You wrote “%s”. I'd write worse. Or better. Doesn't matter.",
    "Your note: “%s”. I kept it in my belly, with the rest.",
    "“%s”, you said. The sentence didn't ask for your opinion, but fine.",
}
C.small_hours = {
    "Highlighting in the small hours. Everything okay at home?",
    "The small hours. When every sentence sounds true.",
}
C.first_one = {
    "First highlight in “%s”. The romance begins.",
    "First mark in “%s”. There's still time to back out.",
}
C.many = {
    "That's %s highlights in this book. Obsession noted.",
    "%s highlights. One more and you'll have to pay rent.",
}
C.chapter = {
    "Again in “%s”. That chapter got you.",
    "Another one in “%s”. I'll call that chapter yours.",
}
C.general = {
    egg = { "…" },
    young = {
        "You highlighted this. Should I be worried?",
        "I kept it. But I'm not sure I understood.",
        "This scared me. In a good way. I think.",
        "Pretty. I distrust pretty things.",
        "Is this true? Books lie sometimes, right?",
    },
    old = {
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

return M
