--[[--
Lote 2 de frases (português). Cada lista aqui é SOMADA à lista de mesmo nome no módulo
(Lingua.anexar): estado, contexto e memória. Mesmas brechas das listas originais:
  FALAS_LIVRO / FALAS_PERSONAGEM: %s · FALAS_MUDA_PERTO: %d · contexto: {n} {hora} {livro} {pct}
  FALAS_NOVO / FALAS_SUMIU: %s · FALAS_VIROU: %s %s (já com "do/da") · C.personagem / nota /
  primeiro / muitos / capitulo: %s · C.dois: %s %s · FALAS_CITACAO: {nome} {fala} ·
  FALAS_REFERENCIA: {nome} {n}
Nunca falar do leitor com adjetivo de gênero.
]]

local X = { estado = { FALAS = { ovo = {}, jovem = {}, velha = {} } }, contexto = {}, memoria = { C = {} } }
local E, M, C = X.estado, X.memoria, X.memoria.C

-- Estado: falas do dia a dia ------------------------------------------------------------
E.FALAS.ovo._todas = {
    "(uma rachadura minúscula apareceu e sumiu)",
    "(silêncio. Um silêncio que julga.)",
}
E.FALAS.jovem.feliz = {
    "Hoje o papel estava crocante na medida certa.<dominio: Com um fundinho de {gosto}.|>",
    "Acho que entendi uma piada do autor. Ri sozinha.",
    "Comi tão bem que esqueci de ter medo.<medrosa: Por cinco minutos.|>",
    "Estou tão cheia que vou ler deitada.",
    "Hoje nenhum personagem morreu. Pelo menos não perto de mim.",
    "Um capítulo inteiro sem susto. Que luxo.",
    "Gostei tanto que reli a mesma página. Duas vezes. Comendo.",
}
E.FALAS.jovem.normal = {
    "Será que as letras sentem cócegas quando eu passo?",
    "Encontrei uma mancha de café na margem. Alguém viveu aqui.",
    "Se eu juntar todas as vírgulas que comi, faço uma frase?",
    "Hoje tentei ler de cabeça pra baixo. Não recomendo.",
    "O índice é o mapa. Eu sou a exploradora<medrosa: que fica no acampamento|>.",
    "Às vezes acho que sou personagem secundária da minha própria vida.",
    "Li a palavra “fim” e fiquei nervosa. Era só um capítulo.",
    "As notas de rodapé cochicham. Eu ouço tudo.",
    "Gosto do barulho da página virando. Parece <medrosa:passo no corredor|romantica:alguém suspirando|o vento chamando>.",
}
E.FALAS.jovem.triste = {
    "A barriga ronca mais alto que a minha vontade de reclamar.",
    "Lambi a capa. Só tinha {gosto|poeira}.",
    "Se eu desmaiar, me ressuscite com um prefácio.",
    "Estou tão fraca que uma vírgula me derrubaria.",
    "Sonhei com um banquete de dicionários. Acordei com fome.",
    "Você lembra que eu existo? Eu lembro que você existe.",
    "Uma frase. Meia frase. Um ponto e vírgula. Qualquer coisa.",
    "O silêncio da estante está me deixando <medrosa:arrepiada|triste>.",
    "Prometo não reclamar do livro. Só me dá um.",
}
E.FALAS.jovem.casulo = {
    "Escondida. Bata três vezes na página que eu saio.",
    "Aqui dentro tem cheiro de livro esquecido. Que medo.",
    "Fiz um ninho com as orelhas das páginas. Volta logo.",
    "Estou de greve de fome. Não por escolha.",
    "Me escondi porque cansei de esperar em pé.",
    "Só saio quando ouvir uma página virar.",
    "Aqui é escuro, mas pelo menos não tem vilão.",
}
E.FALAS.jovem.repouso = {
    "Zzz… sonhando que eu era <corajosa:uma espada de papel|romantica:um bilhete de amor|{coisa|um marcador de página}>…",
    "Zzz… as letras estão dançando… <romantica:valsa…|medrosa:em volta de mim…|>",
    "Zzz… comi uma nuvem de papel… <otimista:tinha gosto de sol…|>",
}
E.FALAS.velha.feliz = {
    "Uma boa página. Vou guardar o gosto<dominio: de {gosto}|> até amanhã.",
    "Hoje a literatura funcionou. Não conte a ninguém.",
    "Satisfeita como quem achou uma primeira edição.",
    "Até o meu cigarro imaginário está de bom humor.",
    "O mundo continua ruim, mas a prosa estava boa.",
    "Comi bem. Vou ser gentil por uns quinze minutos.",
    "Que parágrafo. Quase perdoei o autor pelos outros.",
}
E.FALAS.velha.normal = {
    "Já vi tanto final que agora só leio os meios.",
    "Toda geração acha que inventou o sofrimento. Os livros riem.",
    "Uma estante organizada é um cemitério com sobrenome.",
    "Ler é <romantica:se apaixonar devagar|cinica:desconfiar por escrito|discordar devagar>.",
    "O autor morreu. A vírgula dele continua viva. Justiça poética.",
    "<otimista:Gosto de livros que me agradam logo de cara. Sem vergonha.|Desconfio de livros que me agradam logo de cara.>",
    "As melhores histórias são as que ninguém lembra de recomendar.",
    "Envelhecer é trocar de opinião sem admitir.",
    "Releituras são como velhos amigos: chatos e necessários.",
}
E.FALAS.velha.triste = {
    "Fome e lucidez. Prefiro só a fome.",
    "Comi a minha própria paciência. Não sobrou nada.",
    "Já tive bibliotecas. Hoje tenho saudade.",
    "Estou definhando com elegância. Pelo menos isso.",
    "Me deixaram no escuro com meus pensamentos. Péssima companhia.",
    "Fome velha é a pior fome: tem memória.",
    "Uma página, por caridade. Ou por literatura.",
    "Estou tão vazia quanto um prefácio de autor famoso.",
}
E.FALAS.velha.casulo = {
    "Me escondi. Não por medo: por princípio.",
    "Aqui dentro o silêncio é melhor escrito que muitos livros.",
    "Não insista. Leia. É a única chave.",
    "Estou em retiro espiritual involuntário.",
    "Volto quando você abrir um livro. Não antes.",
}
E.FALAS.velha.repouso = {
    "Zzz… sonhando com um sebo <romantica:e um amor antigo lá dentro|sem clientes>…",
    "Zzz… revisando o próprio epitáfio… <otimista:ficou bonito…|medrosa:cedo demais…|>",
    "Zzz… um fogo-fátuo de papel… <medrosa:me seguindo…|>",
}
E.FALAS_LIVRO = {
    jovem = {
        "“%s” faz barulho quando eu mordo. Isso é bom?",
        "Guardei um pedacinho de “%s” para mais tarde.",
        "Será que o fim de “%s” é feliz? <otimista:Aposto que sim.|amarga:Duvido.|Fico nervosa só de pensar.>",
        "“%s” tem cheiro de <medrosa:porão|romantica:carta guardada|aventura>. Ou de estante velha.",
        "“%s” me deixou com sede de mais páginas.",
    },
    velha = {
        "“%s”. Já vi capas mais honestas.",
        "“%s” tem pretensão. <erudita:Bem fundamentada, admito.|popular:Pretensão demais pro meu gosto.|Às vezes isso basta.>",
        "O problema de “%s” é que ele sabe que é bom.",
        "Vou falar mal de “%s” só depois de terminar. Justiça.",
        "“%s” me lembra outro livro. Melhor. Mas lembra.",
    },
}
E.FALAS_PERSONAGEM = {
    jovem = {
        "Toda vez que %s aparece, eu <romantica:suspiro|corajosa:fico mais atenta|prendo a respiração>.",
        "Será que %s sabe que eu estou lendo?",
        "Fiz um desenho de %s na margem. Ficou feio.",
        "%s é corajoso ou só não pensa? Nunca sei.",
        "Queria ser amiga de %s. <medrosa:Ou fugir. Fugir, acho.|Ou fugir. Tanto faz.>",
        "%s me lembra alguém que eu ainda não conheci.",
    },
    velha = {
        "%s é o tipo de gente que deixa xícara em cima do livro.",
        "Já vi %s em mil livros, só que com outro nome.",
        "%s tem a profundidade de <romantica:um poço. Mergulhei de amores|uma nota de rodapé>.",
        "Não confio em %s. <romantica:Mentira: confio. Pronto, confessei.|Nem em quem confia.>",
        "%s vai se arrepender. É questão de capítulo.",
        "Se %s fosse um livro, eu largaria no meio.",
    },
}
E.FALAS_MUDA_PERTO = {
    jovem = {
    },
    velha = {
    },
}
E.FALAS_MUDA_IMINENTE = {
    ovo = { "(algo lá dentro está impaciente)" },
    jovem = { "Tô quase saindo de mim mesma!", "Mais uma página e eu viro outra!" },
    velha = { "Mais um pouco e eu mudo. Por fora." },
}

-- Contexto: dados da leitura ----------------------------------------------------------
X.contexto.madrugada = {
    jovem = { "{hora}. Se a gente fizer silêncio, os fantasmas do livro não acordam.",
              "Lendo às {hora}? Vou ficar acordada com você.<medrosa: De mãos dadas, se puder.|>", "{hora}. As letras estão com sono, mas eu <diurna:também. Bocejo…|não>." },
    velha = { "{hora}. O horário oficial dos leitores incorrigíveis.", "São {hora}. <noturna:A melhor hora do mundo.|A insônia e o livro se merecem.>",
              "{hora}. Até os vilões estão dormindo. <medrosa:Tomara.|Você não.>" },
}
X.contexto.recorde = {
    jovem = { "{n} páginas! Ninguém nunca me deu tanta comida num dia só!", "Recorde: {n} páginas. Vou contar até pras vírgulas.",
              "{n} páginas hoje. Minha barriga quer fazer um discurso." },
    velha = { "{n} páginas. Novo recorde. Vou registrar com desconfiança.", "Recorde de {n} páginas. Você está bem?",
              "{n} páginas num dia. Isso não é leitura, é mudança de vida." },
}
X.contexto.maratona = {
    jovem = { "{n} páginas! <corajosa:Bora mais cinquenta?|Posso tirar um cochilo dentro do livro?>", "Já foram {n} páginas. Estou rolando pela estante.",
              "{n} páginas… minha barriga está do tamanho de um dicionário." },
    velha = { "{n} páginas. <erudita:Até Tolstói pediria uma pausa.|A literatura agradece. A coluna, não.>", "{n} páginas hoje. Até eu estou cansada, e eu só como.",
              "{n} páginas. Lembre-se de que existe vida fora do livro. Dizem." },
}
X.contexto.sumiu = {
    jovem = { "{n} dias! <medrosa:Pensei que tinha acontecido alguma coisa.|Pensei que você tinha me esquecido de vez.>", "Você voltou depois de {n} dias. <romantica:Senti muita saudade. E fome.|cinica:Vou fingir que não reparei.|Senti saudade. E fome.>",
              "{n} dias sem papel. Eu estava contando <erudita:as citações de cabeça|as fibras da capa>." },
    velha = { "{n} dias. <romantica:Contei cada um.|Vou fingir que não contei.>", "<dominio:Depois de {n} dias, a estante ficou com cheiro de {cheiro}.|Depois de {n} dias, a estante ficou com cara de museu.>",
              "{n} dias sem ler. Espero que tenha valido a pena. <otimista:Aposto que valeu.|Duvido.>" },
}
X.contexto.tarde = {
    jovem = { "{hora}. Ainda dá tempo de mais um capítulo. E de mais um.", "São {hora}. Eu bocejo, você vira a página.",
              "{hora} e o livro ainda está aberto. Gosto disso." },
    velha = { "{hora}. O dia acabou, a leitura não.", "São {hora}. Hora boa para livros e más decisões.",
              "{hora}. Ninguém lê a essa hora por obrigação." },
}
X.contexto.cedo = {
    jovem = { "{hora}! O sol mal acordou e você já está lendo. <diurna:Meu horário!|>", "Bom dia! Às {hora} as páginas têm cheiro de orvalho.",
              "{hora}. Café pra você, papel pra mim." },
    velha = { "{hora}. Leitura antes do mundo começar a falar besteira.", "São {hora}. <noturna:Hora estranha pra estar acordada.|A melhor hora do dia: ninguém atrapalha.>",
              "{hora}. Ler cedo é um luxo que poucos se permitem." },
}
X.contexto.sessao = {
    jovem = { "{n} páginas sem levantar! Seus pés estão bem?", "Já são {n} páginas seguidas. Estou tonta de tanto comer.",
              "{n} páginas de uma vez. Esse livro grudou em você." },
    velha = { "{n} páginas sem pausa. O livro deve estar bom. Ou você está fugindo.", "{n} páginas seguidas. Respeito. Mas pisque.",
              "Uma sessão de {n} páginas. Os antigos copistas aprovariam." },
}
X.contexto.sequencia = {
    jovem = { "{n} dias seguidos! <romantica:Acho que viramos um casal.|Acho que viramos uma rotina.>", "Dia {n} seguido. Minha barriga já sabe a hora de comer.",
              "{n} dias sem pular nenhum! <medrosa:Posso fazer uma festa? Uma pequena?|Posso fazer uma festa?>" },
    velha = { "{n} dias seguidos. Disciplina é o vício mais elegante.", "Dia {n}. Constância. Rara e tediosa. Gosto.",
              "{n} dias sem falhar. <otimista:Vai longe.|Não estrague isso agora.>" },
}
X.contexto.bom_dia = {
    jovem = { "{n} páginas hoje. Estou crescendo de verdade!", "Já comi {n} páginas hoje e ainda quero mais.",
              "{n} páginas hoje. Um dia bom pra ser um bichinho.<dominio: Cheirinho de {cheiro} no ar.|>" },
    velha = { "{n} páginas hoje. Decente. Anotado.", "{n} páginas. O dia não foi desperdiçado.",
              "{n} páginas hoje. Já dá para ter uma opinião." },
}
X.contexto.nada_hoje = {
    jovem = { "Hoje ainda não teve nada. Nem um parágrafo.", "Nenhuma página hoje. Estou olhando o livro fechado.",
              "O dia passou e eu fiquei com fome de história." },
    velha = { "Nenhuma página hoje. A estante notou.", "Hoje: zero. O livro está ofendido.",
              "Um dia inteiro sem ler. Que desperdício de luz." },
}
X.contexto.reta_final = {
    jovem = { "{pct} de “{livro}”! Quase lá. Estou nervosa.", "Falta pouco de “{livro}”. Vou comer devagar.",
              "Reta final de “{livro}”. Prometo não chorar. Talvez." },
    velha = { "{pct} de “{livro}”. Agora não dá mais para o autor fugir.", "Reta final de “{livro}”. Prepare o coração. E o cigarro.",
              "Quase no fim de “{livro}”. Os finais revelam quem o autor é." },
}
X.contexto.metade = {
    jovem = { "Metade de “{livro}”! Agora é ladeira abaixo, né?", "Estamos no meio de “{livro}”. O que vem agora?",
              "Metade de “{livro}” e eu já tenho teorias." },
    velha = { "Metade de “{livro}”. O momento em que o livro decide se presta.", "No meio de “{livro}”. A trama está pronta para desmoronar.",
              "Metade de “{livro}”. Aqui os autores costumam cansar." },
}
X.contexto.comeco = {
    jovem = { "Começando “{livro}”! Ainda não sei de quem gostar.", "Primeiras páginas de “{livro}”. Estou de olho em todo mundo.",
              "“{livro}” começou. Já gosto do cheiro." },
    velha = { "O começo de “{livro}”. Todo livro jura que vai ser diferente.", "Primeiras páginas de “{livro}”. Ainda estou sendo educada.",
              "“{livro}” começou. Vamos ver quanto tempo dura a minha paciência." },
}
X.contexto.fim_de_semana = {
    jovem = { "Fim de semana com livro é o melhor fim de semana.", "Sem pressa, sem escola, só papel.", "Hoje a gente pode ler até tarde, né?" },
    velha = { "Fim de semana. O mundo descansa, a estante trabalha.", "Folga do mundo, plantão da leitura.",
              "Fim de semana lendo. Civilização preservada." },
}

-- Memória: capítulos, temas, Caderno ----------------------------------------------------
M.FALAS_EVENTO = {
    morte = { "Mais um que se foi. A página ficou mais pesada.", "Teve morte. Fiquei de luto por três parágrafos." },
    casamento = { "Casaram. Vou marcar no calendário quantos capítulos dura.", "Sinos, véu, promessas. Já vi esse filme." },
    viagem = { "Alguém foi embora. O livro ficou maior." },
    carta = { "Uma carta. Alguém vai chorar ou mentir.", "Cartas nos livros nunca chegam na hora certa." },
    tempestade = { "Choveu no capítulo inteiro. Fiquei úmida de suspense.", "Raio, vento, drama. O céu do autor estava nervoso." },
    doenca = { "Doença no capítulo. Os livros adoram uma febre.", "Alguém de cama. Vou ler mais devagar, por respeito." },
    festa = { "Festa no capítulo. Alguém vai sair dela arrependido.", "Música e taças. Desconfio de tanta alegria." },
    briga = { "Brigaram feio. Pelo menos agora sabemos o que pensam.", "Discussão no capítulo. Eu tomaria um lado. O meu." },
    fuga = { "Alguém fugiu na calada da página.", "Fuga no capítulo. Às vezes é a única saída digna." },
    crime = { "Crime no capítulo. Eu estava comendo o índice, juro.", "Teve sangue. O livro acordou e eu também." },
}
M.FALAS_NOVO = { "Chegou um tal de %s. Vou observar de longe.", "%s entrou na história sem pedir licença.",
                 "Novo rosto: %s. Ainda não decidi se mordo.", "%s apareceu. Os livros sempre trazem gente nova na hora errada." }
M.FALAS_SUMIU = { "Nenhum sinal de %s. Alguém devia ir procurar.", "%s desapareceu do capítulo. Coincidência? Duvido.",
                  "Senti falta de %s. Não conte pra ninguém.", "Capítulo sem %s. O livro respirou diferente." }
M.FALAS_AZEDOU = { "O capítulo escureceu de repente.", 
                   "Esse capítulo tem gosto de notícia ruim.", "Tudo ficou cinza. Combina com o papel." }
M.FALAS_ADOCOU = { "Um capítulo gentil. Desconfio, mas aproveito.", "O livro sorriu nesse capítulo.",
                   "Teve leveza. Guardei um pouco para os dias ruins.", "Capítulo doce. Algo ruim vem por aí, aposto." }
M.FALAS_VIROU = { "Esse capítulo cansou %s e foi falar %s.", "O autor enjoou %s e partiu para falar %s." }

M.FALAS_TEMA = {
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

C.tema = {
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
C.curto = { "Poucas palavras, muito estrago.", 
            "Cabe numa tatuagem. Não faça isso.", "Frase pequena, eco grande." }
C.longo = { "Sublinhou um parágrafo inteiro. Concordou com tudo?", "Isso é um destaque ou um capítulo?",
            "Trecho comprido. Vou digerir em parcelas.", "Sublinhou tanto que a página ficou amarela." }
C.nota = { "Você anotou “%s”. Eu teria anotado com mais drama.", "“%s” — a sua nota. Concordo pela metade.",
           "Você escreveu “%s”. Guardei junto com a frase." }
C.madrugada = { "Sublinhado de madrugada. As frases da noite pesam mais.", "Destaque feito às %s da manhã. Guardei com carinho.",
                "Madrugada e marca-texto. Combinação perigosa." }
C.primeiro = { "O primeiro destaque de “%s”. Que comece a coleção.", "Primeira marca em “%s”. Gostei da escolha.",
               "“%s” ganhou o primeiro sublinhado. Ele vai se achar." }
C.muitos = { "%s destaques neste livro. Ele virou seu.", "Já são %s sublinhados. Esse livro te pegou.",
             "%s marcas. Daqui a pouco é mais fácil sublinhar o que não gostou." }
C.capitulo = { "“%s” de novo. Esse capítulo é um ímã.", "Outro destaque em “%s”. Esse capítulo tem algo com você.",
               "“%s” está cheio de marcas suas." }
C.personagem = { "%s de novo. Esse personagem mora na sua cabeça.", "Sublinhou %s. Não merece tanto.",
                 "%s na frase. Anotei pra fofocar depois.", "Você gosta de %s ou só tem pena?", "%s. Sempre. Que obsessão." }
C.dois = { "%s e %s no mesmo trecho. Isso vai dar o que falar.", "%s e %s juntos. Já vi como termina.",
           "Entre %s e %s, eu ficaria com o marcador de página.", "%s e %s. Que dupla perigosa." }
C.geral = {
    jovem = { "Guardei esse trecho no bolso da barriga.", "Isso é bonito ou triste? Os dois?", "Vou repetir isso baixinho antes de dormir.",
              "Fiquei pensando nessa frase. Pensando muito.", "Esse trecho tem gosto de segredo." },
    velha = { "Sublinhado. Mais um para a coleção de frases que ninguém relê.", "Isso tem pretensão. Gosto de pretensão bem feita.",
              "Guardei. Daqui a dez anos vai parecer óbvio.", "Uma frase com vocação de epígrafe.",
              "Concordo, com ressalvas. Sempre com ressalvas.", "Bonito. E eu odeio admitir que é bonito." },
}
M.FALAS_CITACAO = {
    jovem = { "Guardei o que {nome} falou: “{fala}”.",
              "“{fala}”. Foi {nome} quem disse. Fiquei impressionada." },
    velha = { "“{fala}”, disse {nome}. Eu teria editado.", "{nome} soltou um “{fala}”. Anotado, com desconfiança.",
              "Ainda estou digerindo “{fala}”, de {nome}." },
}
M.FALAS_REFERENCIA = {
    jovem = { "{nome} de novo! Vou pesquisar quem é. Não vou.", "O livro já falou de {nome} {n} vezes. Devo me preocupar?" },
    velha = { "{n} citações de {nome}. O autor queria parecer culto.", "{nome}, mais uma vez. Já entendemos que você leu, autor." },
}

return X
