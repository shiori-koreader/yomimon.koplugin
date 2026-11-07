-- Memory and notebook phrases. Without NAMES, the module uses its own grammar (article + preposition).
local T = {}

T.SPEECHES_EVENT = {
    death = { "Teve enterro nesse capítulo. Senti o cheiro de vela.", "Alguém morreu ali atrás. Eu avisei que ia acontecer.",
              "Um capítulo inteiro de luto. Fiquei com o papel úmido." },
    wedding = { "Casamento no capítulo. Dou três capítulos para dar errado.", "Noiva, altar, promessas. Anotei pra cobrar depois." },
    travel = { "Alguém pegou a estrada. Espero que não volte igual." },
    letter = { "Chegou uma carta. Cartas nunca trazem notícia boa.", "Escreveram uma carta. Eu teria comido antes de alguém ler." },
    storm = { "Tempestade no capítulo. O autor estava de mau humor.", "Trovão e relâmpago. Clichê. Funciona sempre." },
    illness = { "Alguém adoeceu. Nos livros, febre é quase sentença.", "Médico, febre, leito. Já sei como isso acaba." },
    party = { "Teve festa. Ninguém me convidou. Como sempre.", "Baile e música. Alguém vai se apaixonar pela pessoa errada." },
    quarrel = { "Brigaram. Finalmente alguém disse o que pensava." },
    escape = { "Alguém fugiu. Covardia ou sabedoria, nunca sei.", "Fuga no capítulo. Eu também fugiria desse livro às vezes." },
    crime = { "Crime no capítulo. Eu tenho álibi: estava comendo a página anterior.", "Sangue e polícia. Agora sim o livro acordou." },
}

T.SPEECHES_NEW = { "Apareceu um tal de %s. Já não gosto.", "Quem é %s? Ninguém me apresentou.", "%s chegou. Vai dar trabalho." }

T.SPEECHES_VANISHED = { "Um capítulo inteiro sem %s. Suspeito.", "Cadê %s? Some assim do nada?", "Sem %s nesse capítulo. Estranho. Ou alívio." }

T.SPEECHES_SOURED = { "Esse capítulo azedou.", "Ficou tudo mais escuro de repente. Gostei. Quer dizer, que pena." }

T.SPEECHES_SWEETENED = { "Até que esse capítulo foi leve. Desconfio.", "Capítulo doce. Alguém vai pagar por isso depois.", "Um pouco de luz. Não se acostume." }

T.SPEECHES_TURNED = { "O livro era %s e esse capítulo só falou %s.", "Mudou de assunto: saiu %s e entrou %s." }

T.SPEECHES_THEME = {
    death = { "Todo capítulo é um pequeno enterro.", "Já pensei no meu epitáfio. É curto. Como eu." },
    love = { "Amor. Li tanto sobre isso que fiquei com azia.", "Nunca amei ninguém. Exceto um dicionário, uma vez." },
    war = { "Cada página virada é uma trincheira.", "A paz é só o intervalo entre dois capítulos." },
    sea = { "Desde aquele livro, tudo me parece naufrágio." },
    faith = { "Se Deus existe, ele não lê notas de rodapé." },
    money = { "Papel-moeda tem gosto pior que papel-livro.", "Os ricos dos seus livros nunca são felizes. Bem feito." },
    madness = { "Ontem sonhei que era um ponto e vírgula.", "A sanidade é superestimada. Os narradores sabem." },
    time = { "O tempo passa. Eu como. O tempo passa de novo." },
    city = { "Sinto falta de uma cidade que nunca vi. Culpa sua.", "Barulho de bonde. Fumaça. Gente. Eca. Adoro." },
    nature = { "Uma árvore morreu pra eu comer este livro. Agradeço.", "Chuva lá fora. Aqui dentro, só papel. Prefiro." },
    food = { "Esses personagens comem melhor que eu. Eu como papel.", 
               "Todo livro bom tem um jantar onde tudo dá errado." },
    family = { "Família: o primeiro romance que ninguém escolhe ler.", "Mãe, pai, herança. Já sei onde isso vai dar.",
                "Eu não tenho família. Tenho uma estante. É parecido." },
    childhood = { "A infância nos livros é sempre melhor do que foi.",
                 "Criança em livro é presságio. Alguém vai crescer mal." },
    politics = { "Reis, leis, tronos. Todos acabam em nota de rodapé.", "Revolução: quando o povo troca de opressor.",
                 "Política nos livros é igual à de fora, só que com mais adjetivos." },
    science = { "Ciência demais. Alguém vai criar algo que não devia.", "Experimento, laboratório… sinto cheiro de desastre.",
                "Eu também sou um experimento. Ninguém pediu minha opinião." },
    solitude = { "Solidão. Finalmente um tema que eu entendo.", "Ninguém nesse livro tem com quem conversar. Nem eu.",
                "O silêncio entre duas páginas é o lugar mais solitário que existe." },
    art = { "Poesia. Comi um verso e fiquei com a boca rimada.", 
             "Um quadro descrito em palavras. Arte dentro de arte. Indigesto." },
    animals = { "Muito bicho nesse livro. Me sinto em casa.", 
                "Os animais dos livros sempre são mais sensatos que as pessoas." },
    night = { "Lua, vela, escuridão. O autor escreveu de madrugada, aposto.",
              "Nada bom acontece depois da meia-noite nos livros. Adoro." },
    travel = { "Estrada, horizonte, mapa. Alguém vai se perder.",
               "Viajar é ler com os pés. Eu prefiro com os dentes." },
    revenge = { "Vingança. O prato que se come frio. Como eu como papel.", "Rancor guardado. Esse livro vai acabar em sangue.",
                 "Traição no ar. Eu sinto antes do narrador." },
    freedom = { "Correntes, prisões, fugas. Eu vivo entre duas capas. Me identifico.", 
                  "Ninguém é livre nos livros. Só quem fecha o livro." },
    knowledge = { "Um livro sobre livros. Metalinguagem me dá azia.", "Quanto mais se sabe, menos se dorme. Eu sei.",
              "Biblioteca é minha palavra favorita. Depois de cola." },
    fear = { "Esse livro dá medo. Vou dormir debaixo da orelha.", "Monstros, fantasmas. O verdadeiro horror é a nota de rodapé.",
             "Senti um arrepio na lombada. Continue. Mas devagar." },
}

T.SPEECHES_REFERENCE = {
    young = {
        "Esse livro fala de {nameText} {n} vezes. Quem é {nameText}? Devo me preocupar?",
        "{nameText} de novo. Todo mundo conhece {nameText}, menos eu.",
        "O livro citou {nameText} mais uma vez. Anotei, pra parecer culta.",
    },
    old = {
        "Esse livro cita {nameText} {n} vezes. Exibido.",
        "{nameText} de novo. O autor deve ter um pôster na parede.",
        "Mais uma menção a {nameText}. Eu também li, tá? Comi, na verdade.",
    },
}

T.SPEECHES_QUOTATION = {
    young = {
        "{nameText} disse “{speech}”. Eu nunca teria coragem.",
        "“{speech}” — foi o que {nameText} disse. Repeti baixinho.",
        "Não paro de pensar no que {nameText} disse: “{speech}”.",
        "{nameText} falou “{speech}”. Anotei pra usar um dia.",
    },
    old = {
        "{nameText} disse “{speech}”. Anotei para nunca perdoar.",
        "“{speech}”, disse {nameText}. Eu teria dito melhor.",
        "{nameText}: “{speech}”. Frase de quem nunca comeu um dicionário.",
        "Lembra quando {nameText} disse “{speech}”? Eu lembro. Eu lembro de tudo.",
    },
}

T.SPEECHES_NARRATOR = {
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
    neutral = {
        "Esse livro é contado por alguém que diz muito \"eu\". Desconfio de quem diz muito \"eu\".",
        "Narrador em primeira pessoa. Ou seja: um lado só da história.",
        "Quem conta fala muito de si. Eu também falaria, se alguém me lesse.",
    },
}

T.C = {}
local C = T.C  -- phrase banks by clue; %s = character, book or chapter
C.character = {
    "%s de novo? Você está apaixonado ou só desconfiado?",
    "Tudo gira em torno de %s. Até você.",
    "Eu não confiaria em %s nem para guardar um marcador.",
    "%s fala bonito. Gente que fala bonito esconde coisa.",
    "Sublinhou %s. Anotei. Vou usar isso contra você.",
    "Se %s soubesse que está sendo sublinhado, ficaria insuportável.",
    "%s merecia um livro melhor. Ou um autor mais cruel.",
}

C.two = {
    "%s e %s. Alguém aí vai se arrepender.",
    "%s e %s na mesma frase. Isso nunca termina bem.",
}

C.theme = {
    death = { "Mais um enterro. Já estou de luto adiantado.", "A morte de novo. Esse autor tem um tipo.",
              "Sublinhou a morte. Eu sublinho o almoço.", "Toda frase bonita tem cheiro de cova." },
    love = { "Amor. Ninguém aprende, todo mundo sublinha.", "Romântico. Vou fingir que não vi.",
             "Isso aí não dura três capítulos." },
    war = { "Pólvora. Até o papel ficou quente.", "Ninguém ganha guerra. Só o encadernador.",
               "Você sublinha batalhas como quem coleciona cicatrizes." },
    sea = { "Mais água. Este livro vai me enferrujar.", "O mar de novo. Desconfio que o autor nunca saiu do porto.",
            "Sublinhou o mar. Eu fico com o naufrágio." },
    faith = { "Deus apareceu. Fingi que estava dormindo.", 
           "Se rezar resolvesse, eu não comeria papel." },
    money = { "Dinheiro. Ninguém nos livros é rico e feliz ao mesmo tempo.", "Fala de ouro e ainda assim é papel.",
                 "Sublinhou o preço das coisas. Esperto." },
    madness = { "Loucura. Finalmente alguém sincero.", "Esse parágrafo tem febre. Encostei e senti.",
                "Delírio sublinhado. Estamos todos aqui." },
    time = { "Saudade sublinhada. Que coisa velha. Gostei.",
              "Você sublinha o passado como quem guarda migalha." },
    city = { "Cidade. Barulho, fumaça e alguém chorando numa esquina.", "Essa rua tem cheiro de livro usado.",
               "Sublinhou a cidade. Eu sublinho o silêncio do sebo." },
    nature = { "Árvores. Uma delas virou este livro. De nada.", "Chuva no papel. Que desperdício de página seca.",
                 "Natureza sublinhada. Lá fora é tão grande e tão sem notas de rodapé." },
    food = { "Sublinhou comida. Está com fome ou só com saudade?", "Esse trecho tem gosto. Literalmente." },
    family = { "Família sublinhada. Quer falar sobre isso?", "Todo mundo sublinha a mãe uma hora." },
    childhood = { "Sublinhou a infância. Saudade de quando tudo era primeira vez.", "Criança no trecho. Guardei com cuidado." },
    politics = { "Política sublinhada. Vai discutir no jantar?", "Reis e leis. Você gosta de poder ou de ver ele cair?" },
    science = { "Ciência sublinhada. Cuidado com o que você cria.", "Um experimento. Espero que dê errado, é mais divertido." },
    solitude = { "Sublinhou a solidão. Estou aqui. Mais ou menos.", "Esse trecho é sozinho. Como quem sublinhou." },
    art = { "Arte sublinhada. Que leitor sensível. Que perigo.", "Um verso. Guardei antes que fugisse." },
    animals = { "Sublinhou um bicho. Eu sou um bicho. Anotei.", "Animal no trecho. Os bichos sempre entendem tudo." },
    night = { "Noite sublinhada. Você também gosta do escuro.", "Lua no trecho. Clichê bonito." },
    travel = { "Sublinhou uma estrada. Quer ir embora?", "Viagem. Leve um livro. Me leve junto." },
    revenge = { "Vingança sublinhada. Devo me preocupar com você?", "Rancor bonito. Assustador, mas bonito." },
    freedom = { "Liberdade sublinhada. Bonito. Raro.", "Você sublinhou correntes. Quem te prende?" },
    knowledge = { "Sublinhou um livro dentro do livro. Gostei.", "Conhecimento. A melhor coisa que dá pra comer." },
    fear = { "Sublinhou o medo. Coragem sua.", "Esse trecho dá arrepio. Bom gosto." },
}

C.short_one = {
    "Três palavras e você já se emocionou. Fácil.",
    "Curtinho. Cabe num epitáfio.",
    "Pouca coisa, muito peso. Respeito.",
    "Isso aí é quase um provérbio. Ou uma ameaça.",
}

C.long = {
    "Sublinhou meia página. Decida-se.",
    "Isso não é um destaque, é uma mudança de endereço.",
    "Se for para sublinhar tudo, me dê o livro inteiro de uma vez.",
    "Parágrafo inteiro. Você não estava lendo, estava concordando.",
}

C.grade = {
    "Você escreveu “%s”. Eu escreveria pior. Ou melhor. Não importa.",
    "Sua nota: “%s”. Guardei na barriga, junto com o resto.",
    "“%s”, você disse. A frase não pediu sua opinião, mas tudo bem.",
}

C.small_hours = {
    "Sublinhando de madrugada. Está tudo bem em casa?",
    "Madrugada. Hora em que toda frase parece verdade.",
}

C.first_one = {
    "Primeiro sublinhado em “%s”. Começou o namoro.",
    "Primeira marca em “%s”. Ainda dá tempo de desistir.",
}

C.many = {
    "Já são %s sublinhados neste livro. Obsessão notada.",
    "%s sublinhados. Mais um e você vai ter que pagar aluguel.",
}

C.chapter = {
    "De novo em “%s”. Esse capítulo te pegou.",
    "Mais um em “%s”. Vou chamar esse capítulo de seu.",
}

C.general = {
    egg = { "…" },
    young = {
        "Você sublinhou isso. Devo me preocupar?",
        "Guardei. Mas não sei se entendi.",
        "Isso me deu medo. No bom sentido. Acho.",
        "Bonito. Desconfio de coisas bonitas.",
        "Isso é verdade? Livros mentem às vezes, né?",
    },
    old = {
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

return T
