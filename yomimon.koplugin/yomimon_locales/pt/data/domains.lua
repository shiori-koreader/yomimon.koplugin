--[[--
Vocabulary of each theme (Portuguese): the words it picks from the subject it digested (yomimon_voice.lua,
PLANO-VOZ.md, step 2). Each theme has the same six kinds, to fit the same places in the phrases:
  taste       after "gosto de":   "sal"
  smell      after "cheiro de":  "maresia"
  comparison  after "como":       "uma onda quebrando"
  exclamation  on its own:         "Terra à vista!"
  place       with the preposition: "no convés"
  thing       with the article:   "uma âncora"
_cause: the bad mood with a real reason from the book ({event} already comes with "aquela"/"aquele").
Never describe the reader with a gendered adjective.
]]

local D = {}

D.morte = {
    taste = { "vela apagada", "terra molhada", "flor murcha", "grey", "chá frio de velório" },
    smell = { "crisântemo", "vela queimada", "terra revirada", "flor de enterro" },
    comparison = { "um sino de enterro", "uma vela no fim", "um retrato com fita preta", "uma carta que ninguém vai ler", "um relógio parado" },
    exclamation = { "Que Deus o tenha!", "Descanse em paz!", "Ai, o luto!", "Cruz-credo!" },
    place = { "num cemitério", "atrás de um caixão", "numa capela vazia", "num velório", "debaixo de uma lápide" },
    thing = { "uma coroa de flores", "um véu preto", "um caixão de papel", "uma lápide sem nome", "um relógio parado" },
}
D.amor = {
    taste = { "bombom", "carta perfumada", "morango", "beijo roubado", "mel" },
    smell = { "rosa", "perfume de carta", "lavanda", "flor de laranjeira", "pó de arroz" },
    comparison = { "um bilhete dobrado", "um suspiro de varanda", "um coração desenhado na margem", "uma valsa", "um par de luvas esquecido" },
    exclamation = { "Ai, o amor!", "Que romance!", "Suspiro!", "Coração, aguenta!" },
    place = { "numa varanda ao luar", "num baile", "debaixo de uma janela", "num jardim de rosas", "num banco de praça" },
    thing = { "uma carta de amor", "um anel", "uma rosa seca", "um lenço bordado", "um retrato num medalhão" },
}
D.guerra = {
    taste = { "pólvora", "ferrugem", "ração de soldado", "fumaça", "lama de trincheira" },
    smell = { "pólvora", "fumaça", "couro de bota", "lama", "metal quente" },
    comparison = { "um tambor de marcha", "uma bala perdida", "um mapa rasgado", "um canhão", "uma trincheira molhada" },
    exclamation = { "Às armas!", "Fogo!", "Retirada!", "Sentido!" },
    place = { "numa trincheira", "no campo de batalha", "atrás de uma barricada", "num quartel", "na linha de frente" },
    thing = { "uma medalha", "um capacete amassado", "uma baioneta", "uma bandeira rasgada", "um mapa de batalha" },
}
D.mar = {
    taste = { "sal", "maresia", "água de coco", "peixe seco", "alga" },
    smell = { "maresia", "sal", "corda molhada", "alga", "madeira de navio" },
    comparison = { "uma onda quebrando", "um navio em tempestade", "uma âncora", "uma maré baixa", "um farol aceso" },
    exclamation = { "Terra à vista!", "Homem ao mar!", "Maré cheia!", "Pelas barbas de Netuno!" },
    place = { "no convés", "numa ilha deserta", "no porão de um navio", "num farol", "no fundo do mar" },
    thing = { "uma âncora", "uma garrafa com bilhete", "uma bússola", "uma concha", "um mapa do tesouro" },
}
D.fe = {
    taste = { "hóstia", "água benta", "pão de mosteiro", "incenso", "vinho de missa" },
    smell = { "incenso", "vela de igreja", "madeira de confessionário", "cera", "mirra" },
    comparison = { "um sino de igreja", "uma oração baixinha", "um vitral", "uma procissão", "um terço gasto" },
    exclamation = { "Valha-me Deus!", "Aleluia!", "Amém!", "Santo Deus!" },
    place = { "numa igreja vazia", "num mosteiro", "num confessionário", "num altar", "numa capela de estrada" },
    thing = { "um terço", "uma vela de promessa", "um santinho", "uma bíblia gasta", "um crucifixo" },
}
D.dinheiro = {
    taste = { "moeda", "nota velha", "ouro", "cofre", "juros" },
    smell = { "nota nova", "cofre fechado", "couro de carteira", "tinta de banco", "metal" },
    comparison = { "um cofre trancado", "uma dívida", "uma moeda falsa", "um extrato bancário", "uma herança disputada" },
    exclamation = { "Que fortuna!", "Ouro!", "Falência!", "Tostão furado!" },
    place = { "num banco", "atrás de um balcão", "num cofre", "numa casa de penhores", "num cartório" },
    thing = { "uma moeda de ouro", "um testamento", "uma nota promissória", "um cofre", "um livro-caixa" },
}
D.loucura = {
    taste = { "remédio amargo", "chá de camomila", "giz", "espelho", "papel de parede" },
    smell = { "éter", "sótão fechado", "papel de parede velho", "remédio", "vela de madrugada" },
    comparison = { "um riso no corredor", "um espelho rachado", "um relógio de trás pra frente", "uma escada sem fim", "uma voz no sótão" },
    exclamation = { "Endoideci!", "Que delírio!", "Ha!", "Socorro, as paredes falam!" },
    place = { "num sótão trancado", "num corredor sem fim", "num hospício", "atrás do papel de parede", "dentro de um espelho" },
    thing = { "um espelho rachado", "uma camisa de força", "um diário rabiscado", "uma chave sem porta", "um papel de parede amarelo" },
}
D.tempo = {
    taste = { "poeira", "ferrugem", "pão amanhecido", "chá frio", "bolo de ontem" },
    smell = { "poeira", "relógio antigo", "álbum de fotos", "sótão", "papel amarelado" },
    comparison = { "um relógio de areia", "uma ampulheta", "um calendário arrancado", "um ponteiro atrasado", "um retrato desbotado" },
    exclamation = { "Tic-tac!", "Já é tarde!", "Ah, os anos!", "Que horas são?" },
    place = { "numa torre de relógio", "num sótão empoeirado", "num álbum de fotos", "numa estação antiga", "no século passado" },
    thing = { "um relógio de bolso", "uma ampulheta", "um calendário velho", "um retrato desbotado", "uma vela gasta" },
}
D.cidade = {
    taste = { "fuligem", "café de esquina", "asfalto", "pastel de feira", "fumaça de bonde" },
    smell = { "fuligem", "chuva no asfalto", "café de padaria", "jornal molhado", "fumaça de fábrica" },
    comparison = { "um bonde lotado", "uma esquina movimentada", "um poste aceso", "uma praça cheia", "um cortiço barulhento" },
    exclamation = { "Que barulho!", "Olha o bonde!", "Extra! Extra!", "Que multidão!" },
    place = { "numa esquina", "num cortiço", "numa praça cheia", "num bonde", "numa rua de paralelepípedo" },
    thing = { "um jornal amassado", "um bilhete de bonde", "um guarda-chuva", "um poste", "um chapéu esquecido" },
}
D.natureza = {
    taste = { "folha", "orvalho", "capim", "fruta do pé", "terra" },
    smell = { "mato", "chuva na terra", "flor do campo", "eucalipto", "feno" },
    comparison = { "um galho ao vento", "um rio correndo", "uma árvore velha", "um campo em flor", "uma cerca de pau" },
    exclamation = { "Que verde!", "Olha o rio!", "Ah, o campo!", "Cheiro de chuva!" },
    place = { "no meio do mato", "à beira de um rio", "debaixo de uma árvore", "num campo de trigo", "numa clareira" },
    thing = { "uma folha seca", "um galho", "uma pedra de rio", "um ninho", "uma flor prensada" },
}
D.comida = {
    taste = { "bolo de fubá", "pão quente", "geleia", "manteiga", "café com leite" },
    smell = { "pão saindo do forno", "café", "canela", "sopa", "bolo" },
    comparison = { "um banquete", "um pudim tremendo", "uma panela no fogo", "um bolo crescendo", "uma mesa de domingo" },
    exclamation = { "Que fome!", "Delícia!", "Ao jantar!", "Que banquete!" },
    place = { "numa cozinha", "numa mesa de jantar", "numa confeitaria", "numa despensa", "num piquenique" },
    thing = { "uma colher de pau", "um pudim", "uma cesta de pão", "uma xícara lascada", "um livro de receitas" },
}
D.familia = {
    taste = { "almoço de domingo", "bolo de vó", "chá da tarde", "pão caseiro", "doce de compota" },
    smell = { "casa de vó", "roupa no varal", "almoço de domingo", "armário antigo", "sabonete antigo" },
    comparison = { "uma mesa de jantar cheia", "um retrato de família", "uma briga na ceia", "uma casa com muitos quartos", "uma herança dividida" },
    exclamation = { "Ai, a família!", "Que parentes!", "Mãe!", "Todo mundo pra mesa!" },
    place = { "na sala de jantar", "na casa da avó", "num quarto de criança", "numa ceia de Natal", "num casarão" },
    thing = { "um álbum de família", "um testamento", "uma toalha bordada", "um retrato oval", "uma colcha de retalhos" },
}
D.infancia = {
    taste = { "bala de goma", "algodão-doce", "leite com chocolate", "pirulito", "mingau" },
    smell = { "giz de cera", "massinha", "talco", "lápis de cor", "bala" },
    comparison = { "um pião girando", "uma pipa no céu", "um balanço", "uma cantiga de roda", "um dente de leite" },
    exclamation = { "Oba!", "Pique!", "Era uma vez!", "Tá com você!" },
    place = { "num balanço", "numa casa na árvore", "num quintal", "numa sala de aula", "debaixo da cama" },
    thing = { "um pião", "uma boneca", "um caderno de caligrafia", "uma bolinha de gude", "um ursinho" },
}
D.politica = {
    taste = { "discurso velho", "tinta de jornal", "promessa vazia", "café de gabinete", "papel carimbado" },
    smell = { "charuto", "tinta de jornal", "gabinete fechado", "papel carimbado", "cera de palácio" },
    comparison = { "um discurso sem fim", "uma eleição apertada", "um decreto", "uma conspiração no corredor", "um carimbo" },
    exclamation = { "Ordem!", "Viva a república!", "Abaixo o rei!", "Golpe!" },
    place = { "num parlamento", "num palácio", "num comício", "num gabinete fechado", "numa assembleia" },
    thing = { "um decreto", "uma cédula de voto", "um carimbo", "um discurso amassado", "uma faixa presidencial" },
}
D.ciencia = {
    taste = { "giz de quadro", "éter", "metal de laboratório", "tinta de fórmula", "pó de lente" },
    smell = { "laboratório", "éter", "álcool", "ozônio", "fio queimado" },
    comparison = { "uma experiência que deu errado", "um tubo de ensaio", "um microscópio", "uma fórmula comprida", "uma faísca elétrica" },
    exclamation = { "Eureca!", "Hipótese!", "Que descoberta!", "Pela ciência!" },
    place = { "num laboratório", "num observatório", "atrás de um microscópio", "numa aula de física", "dentro de uma máquina estranha" },
    thing = { "um tubo de ensaio", "uma lente", "um caderno de fórmulas", "uma engrenagem", "um telescópio" },
}
D.solidao = {
    taste = { "chá frio", "pão sozinho", "silêncio", "café de uma xícara só", "sopa rala" },
    smell = { "quarto fechado", "chuva na janela", "casa vazia", "lençol guardado", "poeira" },
    comparison = { "uma cadeira vazia", "um farol sem navio", "uma carta sem resposta", "uma ilha", "um eco" },
    exclamation = { "Tem alguém aí?", "Ninguém!", "Ah, o silêncio.", "Olá?" },
    place = { "num quarto vazio", "numa ilha", "num farol", "numa casa sem ninguém", "numa estação deserta" },
    thing = { "uma cadeira vazia", "uma xícara só", "uma carta sem resposta", "um guarda-chuva sozinho", "uma vela acesa" },
}
D.arte = {
    taste = { "tinta a óleo", "verniz", "carvão de desenho", "aquarela", "gesso" },
    smell = { "tinta a óleo", "terebintina", "verniz", "ateliê", "partitura velha" },
    comparison = { "um quadro torto", "uma sinfonia", "uma escultura inacabada", "um soneto", "um palco vazio" },
    exclamation = { "Bravo!", "Bis!", "Que obra!", "Musa, me ajuda!" },
    place = { "num ateliê", "num teatro", "num museu", "num palco", "numa galeria" },
    thing = { "um pincel", "uma partitura", "um busto de gesso", "uma moldura vazia", "um violino" },
}
D.animais = {
    taste = { "capim", "osso", "ração", "pena", "pelo" },
    smell = { "estábulo", "cachorro molhado", "feno", "ninho", "toca" },
    comparison = { "um cavalo a galope", "uma coruja", "um gato no telhado", "uma baleia", "um cão fiel" },
    exclamation = { "Au!", "Miau!", "Que bicho!", "Eia, cavalinho!" },
    place = { "num estábulo", "numa toca", "num ninho", "no lombo de um cavalo", "num celeiro" },
    thing = { "uma ferradura", "uma pena", "uma coleira", "um ninho", "um osso" },
}
D.noite = {
    taste = { "orvalho", "leite morno", "lua", "vela", "chá de madrugada" },
    smell = { "sereno", "vela acesa", "dama-da-noite", "lençol", "orvalho" },
    comparison = { "uma lua cheia", "uma coruja acordada", "uma vela no fim", "um céu sem estrelas", "um corredor escuro" },
    exclamation = { "Boa noite!", "Psiu, é madrugada!", "Que lua!", "Shh!" },
    place = { "debaixo da lua", "numa rua escura", "num telhado à meia-noite", "num quarto sem luz", "numa torre" },
    thing = { "uma lamparina", "uma vela", "um castiçal", "um gorro de dormir", "uma lanterna" },
}
D.viagem = {
    taste = { "poeira de estrada", "café de estação", "pão de viagem", "sal de porto", "fumaça de trem" },
    smell = { "mala velha", "fumaça de trem", "estrada de terra", "couro de sela", "carvão de locomotiva" },
    comparison = { "uma carruagem sacolejando", "um trem apitando", "um mapa dobrado", "uma mala cheia", "uma estrada sem fim" },
    exclamation = { "Partiu!", "Embarcar!", "Próxima estação!", "Pé na estrada!" },
    place = { "numa carruagem", "num trem noturno", "numa estalagem", "numa estação", "numa estrada de terra" },
    thing = { "uma mala", "um bilhete de trem", "um mapa", "uma bússola", "um passaporte" },
}
D.vinganca = {
    taste = { "ferro", "prato frio", "sangue", "grey" },
    smell = { "pólvora", "ferro", "sangue", "fumaça" },
    comparison = { "uma promessa de sangue", "uma lâmina guardada", "um prato frio", "uma dívida antiga", "um duelo ao amanhecer" },
    exclamation = { "Vingança!", "Ele vai pagar!", "Olho por olho!", "Nunca esquecerei!" },
    place = { "num duelo ao amanhecer", "numa masmorra", "atrás de uma cortina", "numa encruzilhada", "num castelo em ruínas" },
    thing = { "um punhal", "uma luva jogada no chão", "uma carta anônima", "uma lista de nomes" },
}
D.liberdade = {
    taste = { "vento", "ar puro", "pão dividido", "fruta roubada", "chuva" },
    smell = { "vento", "campo aberto", "mar aberto", "chuva", "estrada" },
    comparison = { "um pássaro fora da gaiola", "uma porta aberta", "um grito", "uma corrente partida", "um cavalo solto" },
    exclamation = { "Liberdade!", "Abram as portas!", "Fora as correntes!", "Voa!" },
    place = { "em campo aberto", "fora da gaiola", "no alto de um morro", "numa estrada sem placa", "em mar aberto" },
    thing = { "uma chave", "uma corrente partida", "uma gaiola aberta", "uma bandeira", "uma pipa" },
}
D.saber = {
    taste = { "pergaminho", "tinta de pena", "poeira de biblioteca", "giz", "chá de estudo" },
    smell = { "biblioteca", "pergaminho", "tinta de pena", "vela de estudo" },
    comparison = { "uma enciclopédia", "uma aula comprida", "uma nota de rodapé", "um dicionário aberto", "uma biblioteca inteira" },
    exclamation = { "Sapere aude!", "Elementar!", "Que erudição!", "Quod erat demonstrandum!" },
    place = { "numa biblioteca", "numa universidade", "num gabinete de estudo", "num mosteiro de copistas", "numa academia" },
    thing = { "um pergaminho", "uma lupa", "um tinteiro", "um dicionário", "um globo terrestre" },
}
D.medo = {
    taste = { "suor frio", "vela apagada", "ferrugem", "pó de cripta", "teia de aranha" },
    smell = { "porão", "vela apagada", "cripta", "terra úmida" },
    comparison = { "um rangido de porta", "uma sombra no corredor", "um uivo", "um passo no escuro", "um sussurro atrás da cortina" },
    exclamation = { "Socorro!", "Quem está aí?", "Cruzes!", "Ai, um fantasma!" },
    place = { "num porão escuro", "numa cripta", "num castelo assombrado", "num corredor sem luz", "debaixo da escada" },
    thing = { "uma teia de aranha", "uma chave enferrujada", "um castiçal apagado", "um retrato que segue com os olhos", "um caixão entreaberto" },
}

-- Cause invented afterwards: the bad mood gets a real reason (the event of a recent chapter).
D._cause = {
    events = {
        morte = "aquela morte", casamento = "aquele casamento", viagem = "aquela viagem", carta = "aquela carta",
        tempestade = "aquela tempestade", doenca = "aquela febre", festa = "aquela festa", briga = "aquela briga",
        fuga = "aquela fuga", crime = "aquele crime",
    },
    young = {
        "Acordei com a tristeza no ar. Deve ser {event} de “{book}”.",
        "Tô sem pique hoje. Acho que foi {event} de “{book}”.",
        "Não sei por que tô assim. Ou sei: {event} de “{book}”.",
        "Não sai da minha cabeça: {event} de “{book}”.",
    },
    old = {
        "Mau humor. Deve ser {event} de “{book}”. Nunca me recuperei.",
        "Acordei com um azedume. Ainda é {event} de “{book}”, garanto.",
        "Se estou insuportável, foi {event} de “{book}”.",
        "Não me pergunte nada hoje. É {event} de “{book}” ainda.",
    },
}

return D
