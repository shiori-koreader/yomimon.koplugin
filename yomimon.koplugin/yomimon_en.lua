--[[--
Yomimon: textos em inglês da interface e das falas do dia a dia.

ui:     frase em português (a chave usada em Lingua.t) → tradução.
estado: as mesmas listas de yomimon_state.lua, em inglês (mesma estrutura).

As falas não são tradução literal: a piada vem antes da fidelidade.
]]

local EN = {}

EN.ui = {
    ["NO LUGAR DO CRITTER DO SIMPLE UI"] = "IN PLACE OF SIMPLE UI'S CRITTER",
    -- pokedex e troca
    ["POKÉDEX"] = "POKÉDEX", ["SEUS POKÉMON E O PROGRESSO DE CADA UM"] = "YOUR POKÉMON AND THEIR PROGRESS",
    ["+ ESCOLHER OUTRO POKÉMON"] = "+ PICK ANOTHER POKÉMON", ["FORMA %d DE %d"] = "FORM %d OF %d",
    ["%s PÁG. COM VOCÊ"] = "%s PG WITH YOU", ["COM VOCÊ AGORA"] = "WITH YOU NOW", ["SAIR"] = "EXIT",
    ["CARTÃO NO BOOKSHELF"] = "BOOKSHELF CARD", ["NA PRIMEIRA PRATELEIRA COM LIVROS"] = "ON THE FIRST SHELF WITH BOOKS",
    ["BOOKSHELF NÃO INSTALADO"] = "BOOKSHELF NOT INSTALLED", ["PRIMEIRA PÁGINA"] = "FIRST PAGE", ["LEU A 1ª PÁGINA"] = "READ THE 1ST PAGE",

    -- escolha do Pokémon e formas
    ["bola"] = "ball", ["%s evoluiu para %s!"] = "%s evolved into %s!",
    ["FORMA FINAL"] = "FINAL FORM", ["CHEGOU À"] = "REACHED",
    ["EVOLUIU"] = "EVOLVED", ["CHEGOU À SEGUNDA FORMA"] = "REACHED THE SECOND FORM",
    ["CHEGOU À ÚLTIMA FORMA"] = "REACHED THE LAST FORM",
    ["ESCOLHA SEU POKÉMON"] = "PICK YOUR POKÉMON", ["ESCOLHER ESTE"] = "PICK THIS ONE", ["VOLTAR"] = "BACK",
    ["BAIXAR (WI-FI)"] = "DOWNLOAD (WI-FI)", ["Baixando o desenho…"] = "Downloading the picture…",
    ["%s! Boa escolha. Vou ficar de olho na sua leitura."] = "%s! Good pick. I'll keep an eye on your reading.",
    ["(%s ainda não chegou: o desenho é baixado com o Wi-Fi ligado)"] = "(%s hasn't arrived yet: the picture downloads when Wi-Fi is on)",
    ["Onde você vai me achar? Escolha. Eu espero."] = "Where will you find me? Choose. I'll wait.",
    ["O YOMIMON APARECE QUANDO O KOREADER ABRE"] = "YOMIMON SHOWS UP WHEN KOREADER OPENS",
    -- plugin, menus e avisos
    ["Yomimon"] = "Yomimon",
    ["Yomimon: ver o bichinho"] = "Yomimon: show the creature",
    ["Seu Pokémon. Funciona sem internet."] = "Your Pokémon. Works offline.",
    ["O Yomimon virou %s!"] = "Yomimon is now %s!",
    ["O Yomimon saiu da bola. Com fome, claro."] = "Yomimon came out of its ball. Hungry, of course.",
    ["Idioma do Yomimon"] = "Yomimon language",
    ["Idioma…"] = "Language…",
    ["Padrão (português)"] = "Default (Portuguese)",

    -- fases
    ["ovo"] = "egg", ["ninfa"] = "nymph", ["jovem"] = "young", ["adulta"] = "adult", ["anciã"] = "elder",

    -- barriga e humor
    ["CHEIA"] = "FULL", ["SATISFEITA"] = "SATED", ["BELISCANDO"] = "PECKISH", ["COM FOME"] = "HUNGRY", ["FAMINTA"] = "STARVING",
    ["CHOCANDO"] = "HATCHING",
    ["ANIMADINHA"] = "PERKY", ["TRANQUILA"] = "CALM", ["ANSIOSA"] = "ANXIOUS", ["APAVORADA"] = "TERRIFIED",
    ["QUASE CONTENTE"] = "ALMOST CONTENT", ["CONFORMADA"] = "RESIGNED", ["RANZINZA"] = "GRUMPY", ["INSUPORTÁVEL"] = "UNBEARABLE",

    -- marcos
    ["PRIMEIRA MORDIDA"] = "FIRST BITE", ["COMEU A 1ª PÁGINA"] = "ATE THE 1ST PAGE",
    ["CEM PÁGINAS"] = "A HUNDRED PAGES", ["100 PÁGINAS LIDAS"] = "100 PAGES EATEN",
    ["MIL PÁGINAS"] = "A THOUSAND PAGES", ["1.000 PÁGINAS LIDAS"] = "1,000 PAGES EATEN",
    ["CINCO MIL"] = "FIVE THOUSAND", ["5.000 PÁGINAS LIDAS"] = "5,000 PAGES EATEN",
    ["DEZ MIL"] = "TEN THOUSAND", ["10.000 PÁGINAS LIDAS"] = "10,000 PAGES EATEN",
    ["NASCEU"] = "HATCHED", ["SAIU DO OVO"] = "LEFT THE EGG",
    ["PRIMEIRA MUDA"] = "FIRST MOLT", ["VIROU JOVEM"] = "GREW UP A LITTLE",
    ["ADULTA"] = "ADULT", ["LEU O BASTANTE PARA DESCONFIAR"] = "READ ENOUGH TO GET SUSPICIOUS",
    ["ANCIÃ"] = "ELDER", ["SABE DEMAIS"] = "KNOWS TOO MUCH",
    ["PRIMEIRO LIVRO"] = "FIRST BOOK", ["TERMINOU 1 LIVRO"] = "FINISHED 1 BOOK",
    ["ESTANTE"] = "BOOKCASE", ["TERMINOU 5 LIVROS"] = "FINISHED 5 BOOKS",
    ["PRATELEIRA CHEIA"] = "FULL SHELF", ["TERMINOU 10 LIVROS"] = "FINISHED 10 BOOKS",
    ["BIBLIÓFAGA"] = "BIBLIOPHAGE", ["TERMINOU 25 LIVROS"] = "FINISHED 25 BOOKS",
    ["BIBLIOTECA"] = "LIBRARY", ["TERMINOU 50 LIVROS"] = "FINISHED 50 BOOKS",
    ["MARATONA"] = "MARATHON", ["50 PÁGINAS NUM DIA"] = "50 PAGES IN A DAY",
    ["MADRUGADA"] = "SMALL HOURS", ["LEU DEPOIS DAS 2H"] = "READ PAST 2 AM",
    ["OBSESSÃO"] = "OBSESSION", ["UM TEMA TOMOU CONTA"] = "ONE THEME TOOK OVER",
    ["DIVIDIDA"] = "TORN", ["DOIS TEMAS OPOSTOS"] = "TWO OPPOSITE THEMES",
    ["COLECIONADORA"] = "COLLECTOR", ["50 SUBLINHADOS"] = "50 HIGHLIGHTS",
    ["LINHAGEM"] = "LINEAGE", ["UMA GERAÇÃO COMPLETA"] = "ONE FULL GENERATION",

    -- tela principal e arquivo
    ["YOMIMON"] = "YOMIMON", ["ARQUIVO"] = "ARCHIVE",
    ["A CRIATURA"] = "THE CREATURE",
    ["CADERNO"] = "NOTEBOOK", ["SEUS SUBLINHADOS"] = "YOUR HIGHLIGHTS",
    ["DIÁRIO"] = "DIARY", ["MEMÓRIAS DELA"] = "HER MEMORIES",
    ["CONQUISTAS"] = "ACHIEVEMENTS", ["MARCOS E LIVROS LIDOS"] = "MILESTONES AND BOOKS READ",
    ["PERCEPÇÃO"] = "PERCEPTION",
    ["Nenhum sublinhado. Ou você não lê, ou não sente nada. Segure o dedo numa frase do livro e destaque."] =
        "No highlights. Either you don't read or you don't feel. Hold your finger on a sentence and highlight it.",
    ["SUBLINHADO"] = "HIGHLIGHT", ["SUBLINHADOS"] = "HIGHLIGHTS",
    ["< LIVROS"] = "< BOOKS",
    ["JAN FEV MAR ABR MAI JUN JUL AGO SET OUT NOV DEZ"] = "JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC",
    ["DIVIDIDA ENTRE %s E %s"] = "TORN BETWEEN %s AND %s",
    ["OBCECADA %s"] = "OBSESSED WITH %s",
    ["AINDA SEM OPINIÕES. LEIA MAIS."] = "NO OPINIONS YET. READ MORE.",
    ["Meu diário está vazio. Como a sua estante."] = "My diary is empty. Like your bookshelf.",
    ["BARRIGA"] = "BELLY", ["%s · %d PÁG. HOJE"] = "%s · %d PG TODAY", ["HUMOR"] = "MOOD",
    ["%s PÁG. LIDAS"] = "%s PAGES READ",
    ["GER. %d"] = "GEN. %d",
    ["OVO"] = "EGG", ["NINFA"] = "NYMPH", ["JOVEM"] = "YOUNG", ["ANCIÃ"] = "ELDER",
    ["O OVO"] = "THE EGG", ["NASCER"] = "HATCH", ["PÁG. PARA"] = "PAGE TO", ["PÁGS. PARA"] = "PAGES TO",
    ["LIVROS TERMINADOS"] = "BOOKS FINISHED", ["PÁGINAS LIDAS"] = "PAGES READ", ["DIAS LENDO"] = "DAYS READING",
    ["LIVRO"] = "BOOK", ["LIVROS"] = "BOOKS",
    ["GERAÇÃO %d · VIVA"] = "GENERATION %d · ALIVE", ["DESDE "] = "SINCE ", ["%s PÁG. · %s"] = "%s PG · %s",
    ["HERDOU: "] = "INHERITED: ", ["GERAÇÃO %d"] = "GENERATION %d", ["%s PÁG. · %d LIVROS"] = "%s PG · %d BOOKS",
    ["Sou a primeira. Ainda. Um dia eu deixo um ovo e vocês me esquecem."] =
        "I'm the first. For now. One day I'll leave an egg and you'll all forget me.",
    ["< LINHAGEM"] = "< LINEAGE", ["%s PÁGINAS · %d LIVROS"] = "%s PAGES · %d BOOKS",
    [" · última palavra: “"] = " · last word: “", ["CITAÇÃO FAVORITA"] = "FAVOURITE QUOTE",
    ["ÚLTIMAS MEMÓRIAS"] = "LAST MEMORIES", ["Últimas palavras: “"] = "Last words: “",
    ["LIVROS DA GERAÇÃO %d"] = "GENERATION %d'S BOOKS",

    -- painel dev
    ["Ainda não percebi nada. Leia umas páginas com esta versão."] = "I haven't noticed anything yet. Read a few pages with this version.",
    ["LIVRO: "] = "BOOK: ", ["PERSONAGENS (VEZES · FALAS · CAPÍTULOS)"] = "CHARACTERS (MENTIONS · LINES · CHAPTERS)",
    ["LUGARES: "] = "PLACES: ", ["TEMAS: "] = "THEMES: ",
    ["ÚLTIMOS CAPÍTULOS (PÁG · CLIMA · EVENTOS)"] = "LATEST CHAPTERS (PG · MOOD · EVENTS)",
    ["ÚLTIMO COMENTÁRIO DE CAPÍTULO: "] = "LAST CHAPTER COMMENT: ", [" (JÁ DITO)"] = " (ALREADY SAID)",
    ["MORTE"] = "DEATH", ["CASAMENTO"] = "WEDDING", ["VIAGEM"] = "JOURNEY", ["CARTA"] = "LETTER",
    ["TEMPESTADE"] = "STORM", ["DOENÇA"] = "ILLNESS", ["FESTA"] = "PARTY", ["BRIGA"] = "FIGHT", ["FUGA"] = "ESCAPE",
    ["CRIME"] = "CRIME",

    -- toques e menus
    ["Hm. Tá. Pode continuar."] = "Hm. Fine. You may continue.",
    ["(de volta na bola; leia uma página para chamá-lo)"] = "(back in its ball; read a page to call it out)",
    ["Já chega de carinho por agora."] = "That's enough affection for now.",

    ["Tela de descanso: ligada"] = "Sleep screen: on", ["Tela de descanso: desligada"] = "Sleep screen: off",
    ["Modo dev…"] = "Dev mode…", ["YOMIMON · MODO DEV"] = "YOMIMON · DEV MODE",
    ["Faminta"] = "Starving", ["Ranzinza"] = "Grumpy", ["Feliz"] = "Happy",
    ["Noite: ligada"] = "Night: on", ["Noite: desligada"] = "Night: off",
    ["Sair da bola"] = "Leave the ball", ["Voltar para a bola"] = "Back to the ball",
    ["O que ela percebeu"] = "What she noticed", ["Fim do ciclo (teste)"] = "End of cycle (test)",
    ["Ver boas-vindas"] = "Show welcome",
    ["Simulação de endgame"] = "Endgame simulation", ["Voltar ao estado real"] = "Back to the real state",
    ["Nenhuma simulação em koreader/yomimon/simulacao.lua."] = "No simulation at koreader/yomimon/simulacao.lua.",
    ["SIMULAÇÃO"] = "SIMULATION",
    ["O Yomimon teve um problema e vai ficar quieto até você reiniciar o KOReader. Sua leitura não foi afetada."] =
        "Yomimon ran into a problem and will stay quiet until you restart KOReader. Your reading wasn't affected.",
    ["O Yomimon tropeçou. Toque para fechar."] = "Yomimon tripped. Tap to close.",
    ["Falha de teste: ligada"] = "Test failure: on", ["Falha de teste: desligada"] = "Test failure: off", ["Sair do teste (volta ao normal)"] = "Leave test (back to normal)",
    ["Exportar telas (PNG)"] = "Export screens (PNG)", ["%d telas salvas em %s"] = "%d screens saved to %s",
    ["Exportar todas as simulações"] = "Export all simulations",
    ["Exportando as simulações de koreader/yomimon/simulacoes…"] = "Exporting the simulations in koreader/yomimon/simulacoes…",
    ["%d simulações, %d telas salvas em koreader/yomimon/demo"] = "%d simulations, %d screens saved to koreader/yomimon/demo",

    -- boas-vindas
    ["(algo tremeu dentro do ovo…)"] = "(something trembled inside the egg…)",
    ["CHOCAR"] = "HATCH", ["CONTINUAR"] = "CONTINUE", ["PRONTO"] = "DONE",
    ["(o ovo rachou… ela só sai quando você ler as primeiras páginas)"] =
        "(the egg cracked… she'll only come out once you read the first pages)",
    ["ABRIR AO INICIAR"] = "OPEN AT STARTUP", ["O YOMIMON APARECE QUANDO O KOREADER ABRE"] = "YOMIMON APPEARS WHEN KOREADER OPENS",
    ["ATALHO POR GESTO"] = "GESTURE SHORTCUT", ["SEGURE O DEDO NO CANTO SUPERIOR DIREITO"] = "HOLD YOUR FINGER ON THE TOP RIGHT CORNER",
    ["CARTÃO NA HOME"] = "HOME SCREEN CARD", ["NA TELA INICIAL DO SIMPLE UI"] = "ON THE SIMPLE UI HOME SCREEN",
    ["SIMPLE UI NÃO INSTALADO"] = "SIMPLE UI NOT INSTALLED",

    -- traços
    ["AMARGA"] = "BITTER", ["OTIMISTA"] = "HOPEFUL", ["MEDROSA"] = "JUMPY", ["CORAJOSA"] = "BOLD",
    ["CÍNICA"] = "CYNICAL", ["ROMÂNTICA"] = "ROMANTIC", ["POPULAR"] = "LOWBROW", ["ERUDITA"] = "HIGHBROW",
    ["DIURNA"] = "EARLY BIRD", ["NOTURNA"] = "NIGHT OWL", ["JEITO"] = "NATURE", ["esse livro"] = "this book",
    ["TRAÇOS: "] = "TRAITS: ", ["CITADOS: "] = "QUOTED: ", ["NARRADOR: "] = "NARRATOR: ",
    ["PRIMEIRA PESSOA"] = "FIRST PERSON", ["TERCEIRA PESSOA"] = "THIRD PERSON", ["MULHER"] = "WOMAN", ["HOMEM"] = "MAN",

    -- diário (escrito pela memória)
    ["Comecei a roer “%s”. A capa prometia muito. Capas sempre prometem."] =
        "Started gnawing on “%s”. The cover promised a lot. Covers always do.",
    ["Antes eu pensava %s. Agora só penso %s. Culpa sua e dos seus livros."] =
        "I used to think about %s. Now all I think about is %s. Blame you and your books.",
    ["Percebi que penso muito %s. Não pedi por isso."] = "I noticed I think a lot about %s. I didn't ask for this.",
    ["Uma parte de mim pensa %s. A outra leu demais sobre %s."] = "Part of me thinks about %s. The other part read too much about %s.",
}

-- Falas do dia a dia (mesma estrutura de yomimon_state.lua) ------------------------------
EN.estado = {}

EN.estado.ULTIMAS = {
    "Close the cover gently. I always hated noise.",
    "Don't cry. Read. It's the same thing, just with more paper.",
}

EN.estado.FALAS = {
    ovo = {
        _todas = {
            "…",
            "Knock, knock. Read a bit more and I'll come out.",
            "(something inside grumbled)",
        },
    },
    jovem = {
        feliz = {
            "Ate a whole page and nothing bad happened. <medrosa:Yet. I'm watching.|otimista:And nothing will.|Yet.>",
            "Okay… that was tasty. Will it go wrong later?",
            "Today I understood a metaphor. By myself. I think.",
            "{exclamacao|} Ate a whole paragraph without choking. I'm growing.",
            "Is this book good, or am I just hungry?",
            "If only I could read as fast as I eat…",
            "Happy. Don't tell anyone. I have a reputation.",
            "Today I read a five-syllable word. It read me back.",
            "This book hugged me. <romantica:I let it.|medrosa:Or squashed me. Not sure.|Or squashed me. It was nice.>",
            "Swallowed a comma by accident. Now everything has a pause.",
        },
        normal = {
            "Will this book end well? Books never end well.",
            "I'm here. <corajosa:Steady and ready.|medrosa:Trembling, but here.|A bit nervous, but here.>",
            "If you stop reading, I'll… be fine. I think.",
            "I heard thick books have more filling.<dominio: This one's filling is {gosto}.|>",
            "When I grow up, I want to read the dictionary. All of it.",
            "You read in such a hurry. Is someone waiting for you?",
            "Sometimes I think the characters can see me. <medrosa:That's why I hide.|romantica:And they smile.|>",
            "Why do books smell like {cheiro|old rain}?",
            "<corajosa:I used to fear the end of books. Now I run towards it.|amarga:I'm afraid of the end of books. With good reason.|I'm afraid of the end of books. And the beginning. And the middle.>",
            "<corajosa:Today I'm brave. Tomorrow too.|Today I decided to be brave. We'll see about tomorrow.>",
            "Sometimes I read the same line three times. To make sure it exists.",
        },
        triste = {
            "I'm hungry. And <romantica:lovesick|scared>. Mostly hungry.",
            "Did you forget me? It's fine, everyone forgets.",
            "Just one tiny page… please?",
            "My belly is rumbling. Sounds like {comparacao|a suspense chapter}.",
            "If I disappear, look {lugar|between pages 40 and 41}.",
            "I counted the letters on the cover. All of them. Twice. It's all there was.",
            "Hungry for a story. Any story.",
            "Even the index looks like a feast right now.",
        },
        dormindo = {
            "Zzz… dreaming the bookcase collapsed… <corajosa:and I held it up alone…|>",
            "Zzz… don't turn off the light… <medrosa:leave it on…|I mean, do…>",
            "Zzz… one more page… just one more… <noturna:the night is ours…|>",
        },
        casulo = {
            "I'm in here. Dark, cozy and no letters. Awful.",
        },
        repouso = {
            "Zzz… dreaming of <romantica:letter paper|erudita:parchment|{coisa|rice paper}>…",
            "Zzz… who turned off the world's light? <medrosa:Turn it on…|>",
            "Zzz… dreaming of an endless library… <medrosa:with no way out…|corajosa:and me exploring it all…|>",
            "Zzz… the cover is so warm… <romantica:like a hug…|>",
        },
        palavra = "I ate the word “%s”. <otimista:It tasted like Sunday.|medrosa:I think it was haunted.|erudita:I'm saving it for a sonnet.|I think it disagreed with me.>",
    },
    velha = {
        feliz = {
            "Hm. Not a bad book, actually.",
            "Ate. Satisfied. Don't get used to it.",
            "{exclamacao|} A decent page. Rare, these days.",
            "That paragraph deserved a cigarette afterwards.",
            "Good book. I'll miss hating it.",
            "Literature spared me today. We'll see tomorrow.",
            "Satisfied. <otimista:That's how comedies begin.|That's how tragedies begin.>",
            "What prose. <otimista:It makes me believe in humanity. No almost.|It almost makes me believe in humanity. Almost.>",
            "A decent book. I'll note the date, to remember when the world was worth it.",
            "This author knew what they were doing. I hate when that happens.",
            "Good chapter. <romantica:I was moved and I won't pretend otherwise.|Excuse me while I pretend I wasn't moved.>",
        },
        normal = {
            "I've read too much to <otimista:lose hope|have hope>.",
            "Every book ends. Like everything.",
            "The more I read, the less I understand the world.",
            "Read. Or don't. The ending is the same.",
            "I lit a cigarette. A metaphorical one. Paper and fire don't mix.",
            "Every library is a cemetery with good lighting.",
            "The classics are books everyone quotes and nobody eats.",
            "A preface is where the author apologises in advance.",
            "I was young and optimistic once. <otimista:I still am.|It lasted a chapter.>",
            "Footnotes: where the truth goes to hide.",
            "Nobody reads anymore. That's why I eat.<dominio: Today's menu: {gosto}.|>",
            "Life is a badly edited novel.",
            "Today's bestseller is tomorrow's wrapping paper.",
            "I've read so many happy endings <romantica:and I still cry at every one|I lost faith in endings>.",
            "Every narrator lies. The honest ones lie better.",
            "Culture is what's left when you forget what you read. I remember everything. Bad luck.",
            "The young read to find themselves. The old read to hide.",
            "I don't hate people. Only the ones who dog-ear pages.",
            "My opinion of the world fits in a footnote. Small and ignored.",
        },
        triste = {
            "Hungry. As always. Like everyone.<dominio: I miss {gosto}.|>",
            "You know what's worse than a bad book? No book at all.",
            "I'm wasting away between two covers. How poetic. How useless.",
            "Leave me here with my imaginary cigarette and my very real hunger.",
            "Empty shelf, empty soul. Empty belly too.",
            "Hunger and lucidity. <otimista:At least the lucidity.|The worst combination.>",
            "Nobody reads. Nobody feeds me. Civilisation is over.",
            "I'm so starved I'd consider <erudita:an instruction manual. In German|popular:a gossip magazine. Gladly|an instruction manual>.",
        },
        dormindo = {
            "Zzz… grumbling about <dominio:{coisa}|the state of literature>…",
            "Zzz… no bestsellers… please…",
            "Zzz… dreaming of a used bookshop closed just for me…",
        },
        casulo = {
            "I'm not here. I'm between the pages, where it's more honest.",
        },
        repouso = {
            "Zzz… smoking a cigarette in a dream… <erudita:and quoting Baudelaire…|>",
            "Zzz… the last page <otimista:sometimes surprises|always disappoints>…",
            "Zzz… grumbling in <popular:plain English|Latin>…",
            "Zzz… proofreading the world… <otimista:fewer errors than I expected…|so many errors…>",
        },
        palavra = "“%s”. Ate it. <erudita:A noble word; this century doesn't deserve it.|popular:Dictionary word. No flavour.|Nobody uses that word anymore.>",
    },
}

EN.estado.FALAS_LIVRO = {
    jovem = {
        "“%s” tastes like <medrosa:a snuffed candle|corajosa:adventure|{gosto|mystery}>. Or mould.",
        "Does “%s” end well? Tell me without telling me.",
        "I dreamt about “%s” last night. <corajosa:I was the heroine.|romantica:It was a lovely dream.|I got scared.>",
    },
    velha = {
        "“%s”? I've eaten worse. I've eaten better. Still hungry.<dominio: This one smelled of {cheiro}.|>",
        "After “%s”, I need <romantica:a handkerchief|medrosa:a light on|a cigarette> and a long silence.",
        "“%s” won't change the world. But it changed me a little. For the worse.",
    },
}
EN.estado.FALAS_PERSONAGEM = {
    jovem = { "I like %s. <romantica:I like them a lot.|cinica:For now.|Is that dangerous?>", "%s showed up again. I got nervous." },
    velha = { "%s again. Is there nobody else in this book?", "I know %s's type. <otimista:It ends well, believe it or not.|It ends badly.>",
              "%s talks like someone who never read a book." },
}

EN.estado.FALAS_MUDA_PERTO = {
    jovem = {
        "%d more pages and I grow. What if I turn out ugly?",
        "In %d pages I'll be someone else. Promise you'll recognise me?",
    },
    velha = {
        "In %d pages I change. The world stays the same. As always.",
    },
}
EN.estado.FALAS_MUDA_IMINENTE = {
    ovo = { "Knock. Knock. KNOCK. Read a tiny bit more!" },
    jovem = {
        "My back is creaking. Is it now? It's now!",
    },
    velha = {
        "I'm about to change. I doubt it'll improve anything.",
    },
}

-- Falas com dados da leitura (mesmas chaves de yomimon_context.lua) -----------------------
EN.contexto = {
    madrugada = {
        jovem = {
            "It's {hora}. Shouldn't we be asleep? <noturna:I love this hour.|I'm scared of the dark and you're reading.>",
            "{hora} and you're here. Is everything okay? I'm okay. I think. I'm sleepy.",
            "Reading at {hora} feels forbidden. <medrosa:It scares me.|noturna:Our favourite hour.|I like it.>",
            "At {hora} the letters get bigger. Or my eyes get smaller.",
            "{hora}! If anyone asks, we were asleep.<dominio: Dreaming {lugar}.|>",
        },
        velha = {
            "{hora}. Nothing good was ever read after midnight. Except everything worth reading.",
            "Reading at {hora}. <noturna:The best hour, I always said so.|diurna:This is no hour for decent creatures.|Tomorrow you'll blame the book. I blame you.>",
            "{hora}. Me with my imaginary cigarette, you with your screen light. Two vices.",
            "{hora}. The hour when every sentence sounds true. Careful what you highlight.",
        },
    },
    recorde = {
        jovem = {
            "I've never eaten so much in one day: {n} pages. My belly is proud and scared.",
            "A record of {n} pages. I think I grew a millimetre.",
        },
        velha = {
            "New record: {n} pages in a day. Are you running away from something?",
            "{n} pages. I've never eaten so much. Note the date, so I can complain about it later.",
        },
    },
    maratona = {
        jovem = {
            "{n} pages today. <corajosa:I could take a hundred more.|My belly is all round.>",
            "That's {n} pages already! I can't walk anymore, I just roll.",
        },
        velha = {
            "{n} pages today. My belly thanks you; my dignity, less so.",
            "{n} pages. <erudita:Proust would approve. Perhaps.|That's not reading, that's moving house.>",
            "{n} pages already. Blink. Drink some water. Then come back, of course.",
        },
    },
    sumiu = {
        jovem = {
            "{n} days without paper. I counted every hour. <medrosa:Afraid you wouldn't come back.|There were a lot.>",
            "{n} days! I nearly ate my own shadow. <medrosa:It scared me.|corajosa:I wrestled it.|dominio:It tasted like {gosto}.|>",
        },
        velha = {
            "{n} days without reading. <otimista:It's fine, we start again.|Did civilisation fall and nobody told me?>",
            "{n} days without you. <romantica:I missed you. There, I said it.|I won't ask where you were. You weren't reading, that's what matters.>",
        },
    },
    tarde = {
        jovem = {
            "It's {hora} already. Just one more chapter, right? I know how this ends.",
            "<noturna:{hora}… I'm wide awake. Keep going.|{hora}… my little eyes are getting heavy, but keep going.>",
            "Reading at {hora} is like telling a secret. Quietly.",
        },
        velha = {
            "{hora}. The hour when every reader swears they'll sleep after this chapter.",
            "It's {hora}. The book won't run away. You will, from exhaustion.",
            "{hora}. Still awake <noturna:by choice. The night is mine|because of you. Not that I care>.",
        },
    },
    cedo = {
        jovem = {
            "Reading at {hora}? Before breakfast? <diurna:I love mornings!|noturna:I haven't even slept yet.|So brave.>",
            "{hora} and you're already feeding me. Good morning!",
            "You woke up early to read? I woke up early to eat. We're a team.",
        },
        velha = {
            "{hora}. Reading before coffee. <diurna:The only natural order of things.|I don't understand it, but I respect it.>",
            "It's {hora}. Birds sing, you read, I eat. The only natural order I approve of.",
            "Reading at {hora}. The day hasn't started and it's already better than yesterday.",
        },
    },
    sessao = {
        jovem = {
            "{n} pages without stopping! Can I breathe?",
            "You read {n} pages in one go. Is everything okay out there?",
            "{n} pages in a row. This book got you. It got me too.",
        },
        velha = {
            "{n} pages in a row. Either the book is good or your life got worse.",
            "A {n}-page session. The monks in the scriptorium would approve.",
        },
    },
    sequencia = {
        jovem = {
            "{n} days in a row reading! I'm getting spoiled.",
            "Day {n} in a row of food. I think you like me.<dominio: Today it was {gosto}.|>",
            "{n} days without missing one. <romantica:This is basically dating.|otimista:It'll be a hundred.|Don't stop now, okay?>",
        },
        velha = {
            "{n} days in a row. Consistency: the most boring and rarest virtue.",
            "{n} days reading without fail. <otimista:I believe in you.|cinica:Let's see how long it lasts.|I almost believe in you.>",
            "Day {n} in a row. I won't praise you. There, I praised you.",
        },
    },
    bom_dia = {
        jovem = {
            "{n} pages today. I'm getting chubby.",
            "{n} pages today. <amarga:At least there's that.|It's a good day, isn't it?>",
        },
        velha = {
            "{n} pages today. Respectable. Not spectacular, but respectable.<dominio: With a taste of {gosto}.|>",
            "{n} pages today. That almost counts as reading.",
            "{n} pages. A decent day. <otimista:They've been turning up more.|Rare things, decent days.>",
        },
    },
    nada_hoje = {
        jovem = {
            "No pages today… it's fine, I'll wait. I'm very good at waiting.",
            "I haven't eaten anything today. Not even a comma.",
            "The day is ending and the book is still closed. I sat staring at the cover.",
        },
        velha = {
            "No pages today. The day isn't over yet. But it's trying.",
            "Today: zero pages. Noted in my diary of disappointments.",
            "The book stayed closed all day. So did I, on the inside.",
        },
    },
    reta_final = {
        jovem = {
            "{pct} of “{livro}”. It's ending! I don't want it to end!",
            "The home stretch of “{livro}”. <corajosa:I'll go to the end without blinking.|medrosa:I'll eat with my eyes shut.|I'll eat slowly so it lasts.>",
            "Almost done with “{livro}”. And then what will I eat?",
        },
        velha = {
            "{pct} of “{livro}”. The home stretch. <otimista:This is where good authors shine.|This is where authors ruin everything.>",
            "Nearly the end of “{livro}”. Don't tell me. I'll eat the ending either way.",
            "Last pages of “{livro}”. Brace for the post-book void. I already live there.",
        },
    },
    metade = {
        jovem = {
            "Halfway through “{livro}”! It's getting good. Or bad. I can't tell yet.",
            "I've eaten half of “{livro}”. The other half is staring at me.",
        },
        velha = {
            "Halfway through “{livro}”. Downhill from here.",
            "The middle of “{livro}”. Where authors usually get lost.",
        },
    },
    comeco = {
        jovem = {
            "Starting “{livro}”… it smells like {cheiro|new paper}. Or trouble.",
            "The first pages of “{livro}”. <corajosa:I'm already excited.|I'm already nervous.>",
        },
        velha = {
            "The start of “{livro}”. Every cover promises. Let's see what it delivers.",
            "First bites of “{livro}”. <otimista:Promising.|I don't hate it yet. Yet.>",
        },
    },
    fim_de_semana = {
        jovem = {
            "Weekend reading! The best kind of weekend.",
            "Weekends are paper days. Yay.",
        },
        velha = {
            "The weekend and you're reading. No parties? Good. Parties are overrated.",
            "The weekend. The world goes out, you read. The right choice.",
        },
    },
}

return EN
