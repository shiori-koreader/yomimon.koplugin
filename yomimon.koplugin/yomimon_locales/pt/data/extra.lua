--[[--
Batch 2 of phrases (Portuguese). Each list here is ADDED to the list of the same name in the module
(Language.append): state, context and memory. Same gaps as the original lists:
  SPEECHES_BOOK / SPEECHES_CHARACTER: %s · SPEECHES_NEXT_FORM_NEAR: %d · contexto: {n} {hora} {livro} {pct}
  SPEECHES_NEW / SPEECHES_VANISHED: %s · SPEECHES_TURNED: %s %s (already with "do/da") · C.character / grade /
  primeiro / muitos / capitulo: %s · C.dois: %s %s · SPEECHES_QUOTATION: {nome} {fala} ·
  SPEECHES_REFERENCE: {nome} {n}
Never describe the reader with a gendered adjective.
]]

local X = { state = { SPEECHES = { egg = {}, young = {}, old = {} } }, context = {}, memory = { C = {} } }
local E, M, C = X.state, X.memory, X.memory.C

-- State: day-to-day phrases ------------------------------------------------------------
E.SPEECHES.egg._all = {
    "(uma rachadura minúscula apareceu e sumiu)",
    "(silêncio. Um silêncio que julga.)",
}
E.SPEECHES.young.happy = {
    "Hoje o papel estava crocante na medida certa.<domain: Com um fundinho de {taste}.|>",
    "Acho que entendi uma piada do autor. Ri sem ninguém.",
    "Comi tão bem que esqueci de ter medo.<fearful: Por cinco minutos.|>",
    "A barriga tá tão cheia que vou ler deitando.",
    "Hoje nenhum personagem morreu. Pelo menos não perto de mim.",
    "Um capítulo inteiro sem susto. Que luxo.",
    "Gostei tanto que reli a mesma página. Duas vezes. Comendo.",
}
E.SPEECHES.young.normal = {
    "Será que as letras sentem cócegas quando eu passo?",
    "Encontrei uma mancha de café na margem. Alguém viveu aqui.",
    "Se eu juntar todas as vírgulas que comi, faço uma frase?",
    "Hoje tentei ler de cabeça pra baixo. Não recomendo.",
    "O índice é o mapa. Eu sou a exploradora<fearful: que fica no acampamento|>.",
    "Às vezes acho que sou personagem secundária da minha própria vida.",
    "Li a palavra “fim” e me deu um nervoso. Era só um capítulo.",
    "As notas de rodapé cochicham. Eu ouço tudo.",
    "Gosto do barulho da página virando. Parece <fearful:passo no corredor|romantic:alguém suspirando|o vento chamando>.",
}
E.SPEECHES.young.sad = {
    "A barriga ronca mais alto que a minha vontade de reclamar.",
    "Lambi a capa. Só tinha {taste|poeira}.",
    "Se eu desmaiar, me ressuscite com um prefácio.",
    "Tô sem força nenhuma: uma vírgula me derrubaria.",
    "Sonhei com um banquete de dicionários. Acordei com fome.",
    "Você lembra que eu existo? Eu lembro que você existe.",
    "Uma frase. Meia frase. Um ponto e vírgula. Qualquer coisa.",
    "O silêncio da estante está me deixando <fearful:arrepiada|triste>.",
    "Prometo não reclamar do livro. Só me dá um.",
}
E.SPEECHES.young.cocoon = {
    "Tô escondendo. Bata três vezes na página que eu saio.",
    "Aqui dentro tem cheiro de livro esquecido. Que medo.",
    "Fiz um ninho com as orelhas das páginas. Volta logo.",
    "Estou de greve de fome. Não por escolha.",
    "Me escondi porque cansei de esperar em pé.",
    "Só saio quando ouvir uma página virar.",
    "Aqui é escuro, mas pelo menos não tem vilão.",
}
E.SPEECHES.young.sleepRest = {
    "Zzz… sonhando que eu era <brave:uma espada de papel|romantic:um bilhete de amor|{thing|um marcador de página}>…",
    "Zzz… as letras estão dançando… <romantic:valsa…|fearful:em volta de mim…|>",
    "Zzz… comi uma nuvem de papel… <hopeful:tinha gosto de sol…|>",
}
E.SPEECHES.old.happy = {
    "Uma boa página. Vou guardar o gosto<domain: de {taste}|> até amanhã.",
    "Hoje a literatura funcionou. Não conte a ninguém.",
    "Barriga satisfeita como quem achou uma primeira edição.",
    "Até o meu cigarro imaginário está de bom humor.",
    "O mundo continua ruim, mas a prosa estava boa.",
    "Comi bem. Vou ser gentil por uns quinze minutos.",
    "Que parágrafo. Quase perdoei o autor pelos outros.",
}
E.SPEECHES.old.normal = {
    "Já vi tanto final que agora só leio os meios.",
    "Toda geração acha que inventou o sofrimento. Os livros riem.",
    "Uma estante organizada é um cemitério com sobrenome.",
    "Ler é <romantic:se apaixonar devagar|cynical:desconfiar por escrito|discordar devagar>.",
    "O autor morreu. A vírgula dele continua viva. Justiça poética.",
    "<hopeful:Gosto de livros que me agradam logo de cara. Sem vergonha.|Desconfio de livros que me agradam logo de cara.>",
    "As melhores histórias são as que ninguém lembra de recomendar.",
    "Envelhecer é trocar de opinião sem admitir.",
    "Releituras são como velhos amigos: chatos e necessários.",
}
E.SPEECHES.old.sad = {
    "Fome e lucidez. Prefiro só a fome.",
    "Comi a minha própria paciência. Não sobrou nada.",
    "Já tive bibliotecas. Hoje tenho saudade.",
    "Estou definhando com elegância. Pelo menos isso.",
    "Me deixaram no escuro com meus pensamentos. Péssima companhia.",
    "Fome velha é a pior fome: tem memória.",
    "Uma página, por caridade. Ou por literatura.",
    "Tô com o vazio de um prefácio de autor famoso.",
}
E.SPEECHES.old.cocoon = {
    "Me escondi. Não por medo: por princípio.",
    "Aqui dentro o silêncio é melhor escrito que muitos livros.",
    "Não insista. Leia. É a única chave.",
    "Estou em retiro espiritual involuntário.",
    "Volto quando você abrir um livro. Não antes.",
}
E.SPEECHES.old.sleepRest = {
    "Zzz… sonhando com um sebo <romantic:e um amor antigo lá dentro|sem clientes>…",
    "Zzz… revisando o próprio epitáfio… <hopeful:ficou bonito…|fearful:cedo demais…|>",
    "Zzz… um fogo-fátuo de papel… <fearful:me seguindo…|>",
}
E.SPEECHES_BOOK = {
    young = {
        "“%s” faz barulho quando eu mordo. Isso é bom?",
        "Guardei um pedacinho de “%s” para mais tarde.",
        "Será que o fim de “%s” é feliz? <hopeful:Aposto que sim.|bitter:Duvido.|Dá um nervoso só de pensar.>",
        "“%s” tem cheiro de <fearful:porão|romantic:carta guardada|aventura>. Ou de estante velha.",
        "“%s” me deixou com sede de mais páginas.",
    },
    old = {
        "“%s”. Já vi capas mais honestas.",
        "“%s” tem pretensão. <erudite:Bem fundamentada, admito.|popular:Pretensão demais pro meu gosto.|Às vezes isso basta.>",
        "O problema de “%s” é que ele sabe que é bom.",
        "Vou falar mal de “%s” só depois de terminar. Justiça.",
        "“%s” me lembra outro livro. Melhor. Mas lembra.",
    },
}
E.SPEECHES_CHARACTER = {
    young = {
        "Toda vez que %s aparece, eu <romantic:suspiro|brave:fico de orelha em pé|prendo a respiração>.",
        "Será que %s sabe que eu estou lendo?",
        "Fiz um desenho de %s na margem. Ficou feio.",
        "%s é corajoso ou só não pensa? Nunca sei.",
        "Queria ser amiga de %s. <fearful:Ou fugir. Fugir, acho.|Ou fugir. Tanto faz.>",
        "%s me lembra alguém que eu ainda não conheci.",
    },
    old = {
        "%s é o tipo de gente que deixa xícara em cima do livro.",
        "Já vi %s em mil livros, só que com outro nome.",
        "%s tem a profundidade de <romantic:um poço. Mergulhei de amores|uma nota de rodapé>.",
        "Não confio em %s. <romantic:Mentira: confio. Pronto, confessei.|Nem em quem confia.>",
        "%s vai se arrepender. É questão de capítulo.",
        "Se %s fosse um livro, eu largaria no meio.",
    },
}
E.SPEECHES_NEXT_FORM_NEAR = {
    young = {
    },
    old = {
    },
}
E.SPEECHES_NEXT_FORM_IMMINENT = {
    egg = { "(algo lá dentro está impaciente)" },
    young = { "Tô quase saindo de mim mesma!", "Mais uma página e eu viro outra!" },
    old = { "Mais um pouco e eu mudo. Por fora." },
}

-- Context: reading data ----------------------------------------------------------
X.context.small_hours = {
    young = { "{hour}. Se a gente fizer silêncio, os fantasmas do livro não acordam.",
              "Lendo às {hour}? Vou ficar de olhos abertos com você.<fearful: De mãos dadas, se puder.|>", "{hour}. As letras estão com sono, mas eu <diurnal:também. Bocejo…|não>." },
    old = { "{hour}. O horário oficial dos leitores incorrigíveis.", "São {hour}. <nocturnal:A melhor hora do mundo.|A insônia e o livro se merecem.>",
              "{hour}. Até os vilões estão dormindo. <fearful:Tomara.|Você não.>" },
}
X.context.record = {
    young = { "{n} páginas! Ninguém nunca me deu tanta comida num dia só!", "Recorde: {n} páginas. Vou contar até pras vírgulas.",
              "{n} páginas hoje. Minha barriga quer fazer um discurso." },
    old = { "{n} páginas. Novo recorde. Vou registrar com desconfiança.", "Recorde de {n} páginas. Você está bem?",
              "{n} páginas num dia. Isso não é leitura, é mudança de vida." },
}
X.context.marathon = {
    young = { "{n} páginas! <brave:Bora mais cinquenta?|Posso tirar um cochilo dentro do livro?>", "Já foram {n} páginas. Estou rolando pela estante.",
              "{n} páginas… minha barriga está do tamanho de um dicionário." },
    old = { "{n} páginas. <erudite:Até Tolstói pediria uma pausa.|A literatura agradece. A coluna, não.>", "{n} páginas hoje. Até eu tô sem fôlego, e eu só como.",
              "{n} páginas. Lembre-se de que existe vida fora do livro. Dizem." },
}
X.context.vanished = {
    young = { "{n} dias! <fearful:Pensei que tinha acontecido alguma coisa.|Pensei que você tinha me esquecido de vez.>", "Você voltou depois de {n} dias. <romantic:Senti muita saudade. E fome.|cynical:Vou fingir que não reparei.|Senti saudade. E fome.>",
              "{n} dias sem papel. Eu estava contando <erudite:as citações de cabeça|as fibras da capa>." },
    old = { "{n} dias. <romantic:Contei cada um.|Vou fingir que não contei.>", "<domain:Depois de {n} dias, a estante ficou com cheiro de {smell}.|Depois de {n} dias, a estante ficou com cara de museu.>",
              "{n} dias sem ler. Espero que tenha valido a pena. <hopeful:Aposto que valeu.|Duvido.>" },
}
X.context.afternoon = {
    young = { "{hour}. Ainda dá tempo de mais um capítulo. E de mais um.", "São {hour}. Eu bocejo, você vira a página.",
              "{hour} e o livro ainda está aberto. Gosto disso." },
    old = { "{hour}. O dia acabou, a leitura não.", "São {hour}. Hora boa para livros e más decisões.",
              "{hour}. Ninguém lê a essa hora por obrigação." },
}
X.context.early = {
    young = { "{hour}! O sol mal acordou e você já está lendo. <diurnal:Meu horário!|>", "Bom dia! Às {hour} as páginas têm cheiro de orvalho.",
              "{hour}. Café pra você, papel pra mim." },
    old = { "{hour}. Leitura antes do mundo começar a falar besteira.", "São {hour}. <nocturnal:Hora estranha pra estar de olhos abertos.|A melhor hora do dia: ninguém atrapalha.>",
              "{hour}. Ler cedo é um luxo que poucos se permitem." },
}
X.context.session = {
    young = { "{n} páginas sem levantar! Seus pés estão bem?", "Já são {n} páginas seguidas. Tô com a cabeça rodando de tanto comer.",
              "{n} páginas de uma vez. Esse livro grudou em você." },
    old = { "{n} páginas sem pausa. O livro deve estar bom. Ou você está fugindo.", "{n} páginas seguidas. Respeito. Mas pisque.",
              "Uma sessão de {n} páginas. Os antigos copistas aprovariam." },
}
X.context.sequence = {
    young = { "{n} dias seguidos! <romantic:Acho que viramos um casal.|Acho que viramos uma rotina.>", "Dia {n} seguido. Minha barriga já sabe a hora de comer.",
              "{n} dias sem pular nenhum! <fearful:Posso fazer uma festa? Uma pequena?|Posso fazer uma festa?>" },
    old = { "{n} dias seguidos. Disciplina é o vício mais elegante.", "Dia {n}. Constância. Rara e tediosa. Gosto.",
              "{n} dias sem falhar. <hopeful:Vai longe.|Não estrague isso agora.>" },
}
X.context.good_morning = {
    young = { "{n} páginas hoje. Estou crescendo de verdade!", "Já comi {n} páginas hoje e ainda quero mais.",
              "{n} páginas hoje. Um dia bom pra ser um bichinho.<domain: Cheirinho de {smell} no ar.|>" },
    old = { "{n} páginas hoje. Decente. Anotado.", "{n} páginas. O dia não foi desperdiçado.",
              "{n} páginas hoje. Já dá para ter uma opinião." },
}
X.context.nothing_today = {
    young = { "Hoje ainda não teve nada. Nem um parágrafo.", "Nenhuma página hoje. Estou olhando o livro fechado.",
              "O dia passou e eu fiquei com fome de história." },
    old = { "Nenhuma página hoje. A estante notou.", "Hoje: zero. O livro está ofendido.",
              "Um dia inteiro sem ler. Que desperdício de luz." },
}
X.context.final_stretch = {
    young = { "{pct} de “{book}”! Quase lá. Que nervoso.", "Falta pouco de “{book}”. Vou comer devagar.",
              "Reta final de “{book}”. Prometo não chorar. Talvez." },
    old = { "{pct} de “{book}”. Agora não dá mais para o autor fugir.", "Reta final de “{book}”. Prepare o coração. E o cigarro.",
              "Quase no fim de “{book}”. Os finais revelam quem o autor é." },
}
X.context.half = {
    young = { "Metade de “{book}”! Agora é ladeira abaixo, né?", "Estamos no meio de “{book}”. O que vem agora?",
              "Metade de “{book}” e eu já tenho teorias." },
    old = { "Metade de “{book}”. O momento em que o livro decide se presta.", "No meio de “{book}”. A trama está pronta para desmoronar.",
              "Metade de “{book}”. Aqui os autores costumam cansar." },
}
X.context.start = {
    young = { "Começando “{book}”! Ainda não sei de quem gostar.", "Primeiras páginas de “{book}”. Estou de olho em todo mundo.",
              "“{book}” começou. Já gosto do cheiro." },
    old = { "O começo de “{book}”. Todo livro jura que vai ser diferente.", "Primeiras páginas de “{book}”. Ainda estou me comportando.",
              "“{book}” começou. Vamos ver quanto tempo dura a minha paciência." },
}
X.context.weekend = {
    young = { "Fim de semana com livro é o melhor fim de semana.", "Sem pressa, sem escola, só papel.", "Hoje a gente pode ler até tarde, né?" },
    old = { "Fim de semana. O mundo descansa, a estante trabalha.", "Folga do mundo, plantão da leitura.",
              "Fim de semana lendo. Civilização preservada." },
}

-- Memory: chapters, themes, Notebook ----------------------------------------------------
M.SPEECHES_EVENT = {
    morte = { "Mais um que se foi. A página ficou mais pesada.", "Teve morte. Fiquei de luto por três parágrafos." },
    casamento = { "Casaram. Vou marcar no calendário quantos capítulos dura.", "Sinos, véu, promessas. Já vi esse filme." },
    viagem = { "Alguém foi embora. O livro ficou maior." },
    carta = { "Uma carta. Alguém vai chorar ou mentir.", "Cartas nos livros nunca chegam na hora certa." },
    tempestade = { "Choveu no capítulo inteiro. O suspense molhou até as minhas páginas.", "Raio, vento, drama. O céu do autor estava nervoso." },
    doenca = { "Doença no capítulo. Os livros adoram uma febre.", "Alguém de cama. Vou ler mais devagar, por respeito." },
    festa = { "Festa no capítulo. Alguém vai sair dela arrependido.", "Música e taças. Desconfio de tanta alegria." },
    briga = { "Brigaram feio. Pelo menos agora sabemos o que pensam.", "Discussão no capítulo. Eu tomaria um lado. O meu." },
    fuga = { "Alguém fugiu na calada da página.", "Fuga no capítulo. Às vezes é a única saída digna." },
    crime = { "Crime no capítulo. Eu estava comendo o índice, juro.", "Teve sangue. O livro acordou e eu também." },
}
M.SPEECHES_NEW = { "Chegou um tal de %s. Vou observar de longe.", "%s entrou na história sem pedir licença.",
                 "Novo rosto: %s. Ainda não decidi se mordo.", "%s apareceu. Os livros sempre trazem gente nova na hora errada." }
M.SPEECHES_VANISHED = { "Nenhum sinal de %s. Alguém devia ir procurar.", "%s desapareceu do capítulo. Coincidência? Duvido.",
                  "Senti falta de %s. Não conte pra ninguém.", "Capítulo sem %s. O livro respirou diferente." }
M.SPEECHES_SOURED = { "O capítulo escureceu de repente.", 
                   "Esse capítulo tem gosto de notícia ruim.", "Tudo ficou cinza. Combina com o papel." }
M.SPEECHES_SWEETENED = { "Um capítulo gentil. Desconfio, mas aproveito.", "O livro sorriu nesse capítulo.",
                   "Teve leveza. Guardei um pouco para os dias ruins.", "Capítulo doce. Algo ruim vem por aí, aposto." }
M.SPEECHES_TURNED = { "Esse capítulo cansou %s e foi falar %s.", "O autor enjoou %s e partiu para falar %s." }

M.SPEECHES_THEME = {
    morte = { "Depois de tantos enterros, aprendi a ler de preto.", "A morte é o único spoiler que todo livro conta." },
    amor = { "Amor de livro é melhor que de verdade: tem revisão.", "Li tanto amor que comecei a desconfiar de abraços." },
    guerra = { "As guerras dos livros terminam na última página. As outras, não.", "Muita pólvora. Até o meu papel ficou nervoso." },
    mar = { "Ando sonhando com ondas de papel.", "Sinto o balanço do navio até quando a página para." },
    fe = { "Rezei por um final feliz. Ninguém respondeu.", "Se existe um céu, espero que tenha biblioteca." },
    dinheiro = { "Nos livros, quem tem dinheiro tem problemas melhores.", "Contei moedas no capítulo inteiro. Nenhuma era minha." },
    loucura = { "A loucura dos livros me parece cada vez mais sensata.", "Tem dias em que eu converso com as vírgulas." },
    tempo = { "O tempo nos livros passa rápido. Aqui fora também, mas sem índice.", "Envelheci um capítulo hoje." },
    cidade = { "Cheiro de rua molhada no papel.", "Tanta gente nas cidades dos livros, e ninguém lê." },
    natureza = { "Uma folha de árvore no livro. Uma folha de papel na minha boca.", "Os livros me ensinaram o nome de plantas que eu nunca vou ver." },
    comida = { "Um livro com comida me deixa com o dobro da fome." },
    familia = { "Toda família dos livros tem um segredo na despensa.", "Família: o enredo que ninguém escolhe e todo mundo lê." },
    infancia = { "As crianças dos livros sabem coisas que os adultos esquecem." },
    politica = { "Coroas, leis e discursos. Tudo papel.", "Os poderosos dos livros sempre caem. Ainda bem que são livros." },
    ciencia = { "A ciência dos livros explode bastante." },
    solidao = { "A solidão dos personagens me faz companhia.", "Tão sozinhos nos livros. Tão acompanhada eu fico." },
    arte = { "Um quadro descrito em palavras pinta minha cabeça.", "Os artistas dos livros sofrem bonito." },
    animais = { "Os bichos dos livros são mais sábios que os donos." },
    noite = { "A noite dos livros é mais escura que a de verdade.", "Gosto de capítulos que acontecem de madrugada. Como a gente." },
    viagem = { "Malas, trens, navios. Eu, só páginas." },
    vinganca = { "A vingança nos livros sempre custa mais que a ofensa.", "Rancor bem escrito é uma arte perigosa." },
    liberdade = { "Correntes de papel. Ainda assim, correntes.", "A liberdade dos livros cabe numa página. A nossa, não." },
    saber = { "Quanto mais livros sobre livros, mais eu quero comer bibliotecas.", "Saber demais engorda. Eu sei." },
    medo = { "Esse livro me faz olhar debaixo da página.", "Monstros no papel. Prefiro os de verdade: são mais lentos." },
}

C.theme = {
    morte = { "Sublinhou a morte de novo. Está tudo bem?", "Frase de luto. Guardei com cuidado." },
    amor = { "Sublinhou o amor. Eu fingi que não vi.", "Isso aí é coisa de quem ama. Ou de quem lembra." },
    guerra = { "Sublinhou a guerra. Que essa fique só no papel.", "Trecho de batalha. Guardei sem pólvora." },
    mar = { "Sublinhou o mar. Senti o sal na boca.", "Onda sublinhada. Molhou a página." },
    fe = { "Sublinhou uma prece. Também quero uma.", "Fé sublinhada. Anotei com respeito." },
    dinheiro = { "Sublinhou dinheiro. Prático.", "Moedas no trecho. Nenhuma pra mim." },
    loucura = { "Sublinhou a loucura. Somos dois.", "Esse trecho é meio doido. Gostei." },
    tempo = { "Sublinhou o tempo. Ele vai passar mesmo assim.", "Saudade no trecho. Guardei para depois." },
    cidade = { "Sublinhou a cidade. Barulhenta, mas bonita.", "Rua sublinhada. Cheiro de chuva no asfalto." },
    natureza = { "Sublinhou uma árvore. Ela agradece.", "Natureza no trecho. Respirei melhor." },
    comida = { "Sublinhou comida. Agora eu quero." },
    familia = { "Sublinhou a família. Tem coisa aí.", "Trecho de família. Guardei sem perguntar." },
    infancia = { "Sublinhou a infância. Que frase pequena e enorme.", "Trecho de criança. Cuidado ao reler." },
    politica = { "Sublinhou o poder. Cuidado com ele.", "Trecho de rei. Coroa de papel." },
    ciencia = { "Sublinhou um experimento. Vamos ver no que dá.", "Ciência no trecho. Cheiro de laboratório." },
    solidao = { "Sublinhou a solidão. Fiquei pertinho.", "Trecho sozinho. Agora tem companhia: eu." },
    arte = { "Sublinhou um verso. Ficou mais bonito sublinhado.", "Arte no trecho. Guardei emoldurado." },
    animais = { "Sublinhou um bicho. Gosto de você.", "Animal no trecho. Os bichos sempre entendem." },
    noite = { "Sublinhou a noite. Combina com a gente.", "Trecho noturno. Acendi uma vela imaginária." },
    viagem = { "Sublinhou uma viagem. Me leve.", "Trecho de estrada. Guardei o mapa." },
    vinganca = { "Sublinhou uma vingança. Vou dormir de olho aberto.", "Rancor no trecho. Anotei, por precaução." },
    liberdade = { "Sublinhou a liberdade. Que frase leve.", "Trecho sem correntes. Bonito." },
    saber = { "Sublinhou o saber. Vai citar em algum jantar?", "Trecho sábio. Fiquei mais culta só de comer." },
    medo = { "Sublinhou o medo. Coragem sua.", "Trecho de arrepio. Deixei a luz acesa." },
}
C.short_one = { "Poucas palavras, muito estrago.", 
            "Cabe numa tatuagem. Não faça isso.", "Frase pequena, eco grande." }
C.long = { "Sublinhou um parágrafo inteiro. Concordou com tudo?", "Isso é um destaque ou um capítulo?",
            "Trecho comprido. Vou digerir em parcelas.", "Sublinhou tanto que a página ficou amarela." }
C.grade = { "Você anotou “%s”. Eu teria anotado com mais drama.", "“%s” — a sua nota. Concordo pela metade.",
           "Você escreveu “%s”. Guardei junto com a frase." }
C.small_hours = { "Sublinhado de madrugada. As frases da noite pesam mais.", "Destaque feito às %s da manhã. Guardei com carinho.",
                "Madrugada e marca-texto. Combinação perigosa." }
C.first_one = { "O primeiro destaque de “%s”. Que comece a coleção.", "Primeira marca em “%s”. Gostei da escolha.",
               "“%s” ganhou o primeiro sublinhado. Ele vai se achar." }
C.many = { "%s destaques neste livro. Ele virou seu.", "Já são %s sublinhados. Esse livro te pegou.",
             "%s marcas. Daqui a pouco é mais fácil sublinhar o que não gostou." }
C.chapter = { "“%s” de novo. Esse capítulo é um ímã.", "Outro destaque em “%s”. Esse capítulo tem algo com você.",
               "“%s” está cheio de marcas suas." }
C.character = { "%s de novo. Esse personagem mora na sua cabeça.", "Sublinhou %s. Não merece tanto.",
                 "%s na frase. Anotei pra fofocar depois.", "Você gosta de %s ou só tem pena?", "%s. Sempre. Que obsessão." }
C.two = { "%s e %s no mesmo trecho. Isso vai dar o que falar.", "%s e %s juntos. Já vi como termina.",
           "Entre %s e %s, eu ficaria com o marcador de página.", "%s e %s. Que dupla perigosa." }
C.general = {
    young = { "Guardei esse trecho no bolso da barriga.", "Isso é bonito ou triste? Os dois?", "Vou repetir isso baixinho antes de dormir.",
              "Fiquei pensando nessa frase. Pensando muito.", "Esse trecho tem gosto de segredo." },
    old = { "Sublinhado. Mais um para a coleção de frases que ninguém relê.", "Isso tem pretensão. Gosto de pretensão bem feita.",
              "Guardei. Daqui a dez anos vai parecer óbvio.", "Uma frase com vocação de epígrafe.",
              "Concordo, com ressalvas. Sempre com ressalvas.", "Bonito. E eu odeio admitir que é bonito." },
}
M.SPEECHES_QUOTATION = {
    young = { "Guardei o que {nameText} falou: “{speech}”.",
              "“{speech}”. Foi {nameText} quem disse. Fiquei de queixo caído." },
    old = { "“{speech}”, disse {nameText}. Eu teria editado.", "{nameText} soltou um “{speech}”. Anotado, com desconfiança.",
              "Ainda estou digerindo “{speech}”, de {nameText}." },
}
M.SPEECHES_REFERENCE = {
    young = { "{nameText} de novo! Vou pesquisar quem é. Não vou.", "O livro já falou de {nameText} {n} vezes. Devo me preocupar?" },
    old = { "{n} citações de {nameText}. O autor queria parecer culto.", "{nameText}, mais uma vez. Já entendemos que você leu, autor." },
}

return X
