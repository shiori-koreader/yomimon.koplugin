-- Frases da memória e do caderno. Sem NOMES, o módulo usa a gramática própria (artigo + preposição).
local T = {}

T.FALAS_EVENTO = {
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

T.FALAS_NOVO = { "Apareceu um tal de %s. Já não gosto.", "Quem é %s? Ninguém me apresentou.", "%s chegou. Vai dar trabalho." }

T.FALAS_SUMIU = { "Um capítulo inteiro sem %s. Suspeito.", "Cadê %s? Some assim do nada?", "Sem %s nesse capítulo. Estranho. Ou alívio." }

T.FALAS_AZEDOU = { "Esse capítulo azedou.", "Ficou tudo mais escuro de repente. Gostei. Quer dizer, que pena." }

T.FALAS_ADOCOU = { "Até que esse capítulo foi leve. Desconfio.", "Capítulo doce. Alguém vai pagar por isso depois.", "Um pouco de luz. Não se acostume." }

T.FALAS_VIROU = { "O livro era %s e esse capítulo só falou %s.", "Mudou de assunto: saiu %s e entrou %s." }

T.FALAS_TEMA = {
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
    animais = { "Muito bicho nesse livro. Me sinto em casa.", 
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

T.FALAS_REFERENCIA = {
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

T.FALAS_CITACAO = {
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

T.FALAS_NARRADOR = {
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

T.C = {}
local C = T.C  -- bancos de frases por pista; %s = personagem, livro ou capítulo
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

return T
