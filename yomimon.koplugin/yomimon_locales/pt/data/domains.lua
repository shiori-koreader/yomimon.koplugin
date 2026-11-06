--[[--
Vocabulário de cada tema (português): as palavras que ela pega do assunto que digeriu (yomimon_voice.lua,
PLANO-VOZ.md, Etapa 2). Cada tema tem os mesmos seis tipos, para caber nos mesmos lugares das frases:
  gosto       depois de "gosto de":   "sal"
  cheiro      depois de "cheiro de":  "maresia"
  comparacao  depois de "como":       "uma onda quebrando"
  exclamacao  frase solta:            "Terra à vista!"
  lugar       com a preposição:       "no convés"
  coisa       com o artigo:           "uma âncora"
_causa: o mau humor com motivo real do livro ({evento} já vem com "aquela"/"aquele").
Nunca falar do leitor com adjetivo de gênero.
]]

local D = {}

D.morte = {
    gosto = { "vela apagada", "terra molhada", "flor murcha", "cinza", "chá frio de velório" },
    cheiro = { "crisântemo", "vela queimada", "terra revirada", "flor de enterro" },
    comparacao = { "um sino de enterro", "uma vela no fim", "um retrato com fita preta", "uma carta que ninguém vai ler", "um relógio parado" },
    exclamacao = { "Que Deus o tenha!", "Descanse em paz!", "Ai, o luto!", "Cruz-credo!" },
    lugar = { "num cemitério", "atrás de um caixão", "numa capela vazia", "num velório", "debaixo de uma lápide" },
    coisa = { "uma coroa de flores", "um véu preto", "um caixão de papel", "uma lápide sem nome", "um relógio parado" },
}
D.amor = {
    gosto = { "bombom", "carta perfumada", "morango", "beijo roubado", "mel" },
    cheiro = { "rosa", "perfume de carta", "lavanda", "flor de laranjeira", "pó de arroz" },
    comparacao = { "um bilhete dobrado", "um suspiro de varanda", "um coração desenhado na margem", "uma valsa", "um par de luvas esquecido" },
    exclamacao = { "Ai, o amor!", "Que romance!", "Suspiro!", "Coração, aguenta!" },
    lugar = { "numa varanda ao luar", "num baile", "debaixo de uma janela", "num jardim de rosas", "num banco de praça" },
    coisa = { "uma carta de amor", "um anel", "uma rosa seca", "um lenço bordado", "um retrato num medalhão" },
}
D.guerra = {
    gosto = { "pólvora", "ferrugem", "ração de soldado", "fumaça", "lama de trincheira" },
    cheiro = { "pólvora", "fumaça", "couro de bota", "lama", "metal quente" },
    comparacao = { "um tambor de marcha", "uma bala perdida", "um mapa rasgado", "um canhão", "uma trincheira molhada" },
    exclamacao = { "Às armas!", "Fogo!", "Retirada!", "Sentido!" },
    lugar = { "numa trincheira", "no campo de batalha", "atrás de uma barricada", "num quartel", "na linha de frente" },
    coisa = { "uma medalha", "um capacete amassado", "uma baioneta", "uma bandeira rasgada", "um mapa de batalha" },
}
D.mar = {
    gosto = { "sal", "maresia", "água de coco", "peixe seco", "alga" },
    cheiro = { "maresia", "sal", "corda molhada", "alga", "madeira de navio" },
    comparacao = { "uma onda quebrando", "um navio em tempestade", "uma âncora", "uma maré baixa", "um farol aceso" },
    exclamacao = { "Terra à vista!", "Homem ao mar!", "Maré cheia!", "Pelas barbas de Netuno!" },
    lugar = { "no convés", "numa ilha deserta", "no porão de um navio", "num farol", "no fundo do mar" },
    coisa = { "uma âncora", "uma garrafa com bilhete", "uma bússola", "uma concha", "um mapa do tesouro" },
}
D.fe = {
    gosto = { "hóstia", "água benta", "pão de mosteiro", "incenso", "vinho de missa" },
    cheiro = { "incenso", "vela de igreja", "madeira de confessionário", "cera", "mirra" },
    comparacao = { "um sino de igreja", "uma oração baixinha", "um vitral", "uma procissão", "um terço gasto" },
    exclamacao = { "Valha-me Deus!", "Aleluia!", "Amém!", "Santo Deus!" },
    lugar = { "numa igreja vazia", "num mosteiro", "num confessionário", "num altar", "numa capela de estrada" },
    coisa = { "um terço", "uma vela de promessa", "um santinho", "uma bíblia gasta", "um crucifixo" },
}
D.dinheiro = {
    gosto = { "moeda", "nota velha", "ouro", "cofre", "juros" },
    cheiro = { "nota nova", "cofre fechado", "couro de carteira", "tinta de banco", "metal" },
    comparacao = { "um cofre trancado", "uma dívida", "uma moeda falsa", "um extrato bancário", "uma herança disputada" },
    exclamacao = { "Que fortuna!", "Ouro!", "Falência!", "Tostão furado!" },
    lugar = { "num banco", "atrás de um balcão", "num cofre", "numa casa de penhores", "num cartório" },
    coisa = { "uma moeda de ouro", "um testamento", "uma nota promissória", "um cofre", "um livro-caixa" },
}
D.loucura = {
    gosto = { "remédio amargo", "chá de camomila", "giz", "espelho", "papel de parede" },
    cheiro = { "éter", "sótão fechado", "papel de parede velho", "remédio", "vela de madrugada" },
    comparacao = { "um riso no corredor", "um espelho rachado", "um relógio de trás pra frente", "uma escada sem fim", "uma voz no sótão" },
    exclamacao = { "Endoideci!", "Que delírio!", "Ha!", "Socorro, as paredes falam!" },
    lugar = { "num sótão trancado", "num corredor sem fim", "num hospício", "atrás do papel de parede", "dentro de um espelho" },
    coisa = { "um espelho rachado", "uma camisa de força", "um diário rabiscado", "uma chave sem porta", "um papel de parede amarelo" },
}
D.tempo = {
    gosto = { "poeira", "ferrugem", "pão amanhecido", "chá frio", "bolo de ontem" },
    cheiro = { "poeira", "relógio antigo", "álbum de fotos", "sótão", "papel amarelado" },
    comparacao = { "um relógio de areia", "uma ampulheta", "um calendário arrancado", "um ponteiro atrasado", "um retrato desbotado" },
    exclamacao = { "Tic-tac!", "Já é tarde!", "Ah, os anos!", "Que horas são?" },
    lugar = { "numa torre de relógio", "num sótão empoeirado", "num álbum de fotos", "numa estação antiga", "no século passado" },
    coisa = { "um relógio de bolso", "uma ampulheta", "um calendário velho", "um retrato desbotado", "uma vela gasta" },
}
D.cidade = {
    gosto = { "fuligem", "café de esquina", "asfalto", "pastel de feira", "fumaça de bonde" },
    cheiro = { "fuligem", "chuva no asfalto", "café de padaria", "jornal molhado", "fumaça de fábrica" },
    comparacao = { "um bonde lotado", "uma esquina movimentada", "um poste aceso", "uma praça cheia", "um cortiço barulhento" },
    exclamacao = { "Que barulho!", "Olha o bonde!", "Extra! Extra!", "Que multidão!" },
    lugar = { "numa esquina", "num cortiço", "numa praça cheia", "num bonde", "numa rua de paralelepípedo" },
    coisa = { "um jornal amassado", "um bilhete de bonde", "um guarda-chuva", "um poste", "um chapéu esquecido" },
}
D.natureza = {
    gosto = { "folha", "orvalho", "capim", "fruta do pé", "terra" },
    cheiro = { "mato", "chuva na terra", "flor do campo", "eucalipto", "feno" },
    comparacao = { "um galho ao vento", "um rio correndo", "uma árvore velha", "um campo em flor", "uma cerca de pau" },
    exclamacao = { "Que verde!", "Olha o rio!", "Ah, o campo!", "Cheiro de chuva!" },
    lugar = { "no meio do mato", "à beira de um rio", "debaixo de uma árvore", "num campo de trigo", "numa clareira" },
    coisa = { "uma folha seca", "um galho", "uma pedra de rio", "um ninho", "uma flor prensada" },
}
D.comida = {
    gosto = { "bolo de fubá", "pão quente", "geleia", "manteiga", "café com leite" },
    cheiro = { "pão saindo do forno", "café", "canela", "sopa", "bolo" },
    comparacao = { "um banquete", "um pudim tremendo", "uma panela no fogo", "um bolo crescendo", "uma mesa de domingo" },
    exclamacao = { "Que fome!", "Delícia!", "Ao jantar!", "Que banquete!" },
    lugar = { "numa cozinha", "numa mesa de jantar", "numa confeitaria", "numa despensa", "num piquenique" },
    coisa = { "uma colher de pau", "um pudim", "uma cesta de pão", "uma xícara lascada", "um livro de receitas" },
}
D.familia = {
    gosto = { "almoço de domingo", "bolo de vó", "chá da tarde", "pão caseiro", "doce de compota" },
    cheiro = { "casa de vó", "roupa no varal", "almoço de domingo", "armário antigo", "sabonete antigo" },
    comparacao = { "uma mesa de jantar cheia", "um retrato de família", "uma briga na ceia", "uma casa com muitos quartos", "uma herança dividida" },
    exclamacao = { "Ai, a família!", "Que parentes!", "Mãe!", "Todo mundo pra mesa!" },
    lugar = { "na sala de jantar", "na casa da avó", "num quarto de criança", "numa ceia de Natal", "num casarão" },
    coisa = { "um álbum de família", "um testamento", "uma toalha bordada", "um retrato oval", "uma colcha de retalhos" },
}
D.infancia = {
    gosto = { "bala de goma", "algodão-doce", "leite com chocolate", "pirulito", "mingau" },
    cheiro = { "giz de cera", "massinha", "talco", "lápis de cor", "bala" },
    comparacao = { "um pião girando", "uma pipa no céu", "um balanço", "uma cantiga de roda", "um dente de leite" },
    exclamacao = { "Oba!", "Pique!", "Era uma vez!", "Tá com você!" },
    lugar = { "num balanço", "numa casa na árvore", "num quintal", "numa sala de aula", "debaixo da cama" },
    coisa = { "um pião", "uma boneca", "um caderno de caligrafia", "uma bolinha de gude", "um ursinho" },
}
D.politica = {
    gosto = { "discurso velho", "tinta de jornal", "promessa vazia", "café de gabinete", "papel carimbado" },
    cheiro = { "charuto", "tinta de jornal", "gabinete fechado", "papel carimbado", "cera de palácio" },
    comparacao = { "um discurso sem fim", "uma eleição apertada", "um decreto", "uma conspiração no corredor", "um carimbo" },
    exclamacao = { "Ordem!", "Viva a república!", "Abaixo o rei!", "Golpe!" },
    lugar = { "num parlamento", "num palácio", "num comício", "num gabinete fechado", "numa assembleia" },
    coisa = { "um decreto", "uma cédula de voto", "um carimbo", "um discurso amassado", "uma faixa presidencial" },
}
D.ciencia = {
    gosto = { "giz de quadro", "éter", "metal de laboratório", "tinta de fórmula", "pó de lente" },
    cheiro = { "laboratório", "éter", "álcool", "ozônio", "fio queimado" },
    comparacao = { "uma experiência que deu errado", "um tubo de ensaio", "um microscópio", "uma fórmula comprida", "uma faísca elétrica" },
    exclamacao = { "Eureca!", "Hipótese!", "Que descoberta!", "Pela ciência!" },
    lugar = { "num laboratório", "num observatório", "atrás de um microscópio", "numa aula de física", "dentro de uma máquina estranha" },
    coisa = { "um tubo de ensaio", "uma lente", "um caderno de fórmulas", "uma engrenagem", "um telescópio" },
}
D.solidao = {
    gosto = { "chá frio", "pão sozinho", "silêncio", "café de uma xícara só", "sopa rala" },
    cheiro = { "quarto fechado", "chuva na janela", "casa vazia", "lençol guardado", "poeira" },
    comparacao = { "uma cadeira vazia", "um farol sem navio", "uma carta sem resposta", "uma ilha", "um eco" },
    exclamacao = { "Tem alguém aí?", "Ninguém!", "Ah, o silêncio.", "Olá?" },
    lugar = { "num quarto vazio", "numa ilha", "num farol", "numa casa sem ninguém", "numa estação deserta" },
    coisa = { "uma cadeira vazia", "uma xícara só", "uma carta sem resposta", "um guarda-chuva sozinho", "uma vela acesa" },
}
D.arte = {
    gosto = { "tinta a óleo", "verniz", "carvão de desenho", "aquarela", "gesso" },
    cheiro = { "tinta a óleo", "terebintina", "verniz", "ateliê", "partitura velha" },
    comparacao = { "um quadro torto", "uma sinfonia", "uma escultura inacabada", "um soneto", "um palco vazio" },
    exclamacao = { "Bravo!", "Bis!", "Que obra!", "Musa, me ajuda!" },
    lugar = { "num ateliê", "num teatro", "num museu", "num palco", "numa galeria" },
    coisa = { "um pincel", "uma partitura", "um busto de gesso", "uma moldura vazia", "um violino" },
}
D.animais = {
    gosto = { "capim", "osso", "ração", "pena", "pelo" },
    cheiro = { "estábulo", "cachorro molhado", "feno", "ninho", "toca" },
    comparacao = { "um cavalo a galope", "uma coruja", "um gato no telhado", "uma baleia", "um cão fiel" },
    exclamacao = { "Au!", "Miau!", "Que bicho!", "Eia, cavalinho!" },
    lugar = { "num estábulo", "numa toca", "num ninho", "no lombo de um cavalo", "num celeiro" },
    coisa = { "uma ferradura", "uma pena", "uma coleira", "um ninho", "um osso" },
}
D.noite = {
    gosto = { "orvalho", "leite morno", "lua", "vela", "chá de madrugada" },
    cheiro = { "sereno", "vela acesa", "dama-da-noite", "lençol", "orvalho" },
    comparacao = { "uma lua cheia", "uma coruja acordada", "uma vela no fim", "um céu sem estrelas", "um corredor escuro" },
    exclamacao = { "Boa noite!", "Psiu, é madrugada!", "Que lua!", "Shh!" },
    lugar = { "debaixo da lua", "numa rua escura", "num telhado à meia-noite", "num quarto sem luz", "numa torre" },
    coisa = { "uma lamparina", "uma vela", "um castiçal", "um gorro de dormir", "uma lanterna" },
}
D.viagem = {
    gosto = { "poeira de estrada", "café de estação", "pão de viagem", "sal de porto", "fumaça de trem" },
    cheiro = { "mala velha", "fumaça de trem", "estrada de terra", "couro de sela", "carvão de locomotiva" },
    comparacao = { "uma carruagem sacolejando", "um trem apitando", "um mapa dobrado", "uma mala cheia", "uma estrada sem fim" },
    exclamacao = { "Partiu!", "Embarcar!", "Próxima estação!", "Pé na estrada!" },
    lugar = { "numa carruagem", "num trem noturno", "numa estalagem", "numa estação", "numa estrada de terra" },
    coisa = { "uma mala", "um bilhete de trem", "um mapa", "uma bússola", "um passaporte" },
}
D.vinganca = {
    gosto = { "ferro", "prato frio", "sangue", "cinza" },
    cheiro = { "pólvora", "ferro", "sangue", "fumaça" },
    comparacao = { "uma promessa de sangue", "uma lâmina guardada", "um prato frio", "uma dívida antiga", "um duelo ao amanhecer" },
    exclamacao = { "Vingança!", "Ele vai pagar!", "Olho por olho!", "Nunca esquecerei!" },
    lugar = { "num duelo ao amanhecer", "numa masmorra", "atrás de uma cortina", "numa encruzilhada", "num castelo em ruínas" },
    coisa = { "um punhal", "uma luva jogada no chão", "uma carta anônima", "uma lista de nomes" },
}
D.liberdade = {
    gosto = { "vento", "ar puro", "pão dividido", "fruta roubada", "chuva" },
    cheiro = { "vento", "campo aberto", "mar aberto", "chuva", "estrada" },
    comparacao = { "um pássaro fora da gaiola", "uma porta aberta", "um grito", "uma corrente partida", "um cavalo solto" },
    exclamacao = { "Liberdade!", "Abram as portas!", "Fora as correntes!", "Voa!" },
    lugar = { "em campo aberto", "fora da gaiola", "no alto de um morro", "numa estrada sem placa", "em mar aberto" },
    coisa = { "uma chave", "uma corrente partida", "uma gaiola aberta", "uma bandeira", "uma pipa" },
}
D.saber = {
    gosto = { "pergaminho", "tinta de pena", "poeira de biblioteca", "giz", "chá de estudo" },
    cheiro = { "biblioteca", "pergaminho", "tinta de pena", "vela de estudo" },
    comparacao = { "uma enciclopédia", "uma aula comprida", "uma nota de rodapé", "um dicionário aberto", "uma biblioteca inteira" },
    exclamacao = { "Sapere aude!", "Elementar!", "Que erudição!", "Quod erat demonstrandum!" },
    lugar = { "numa biblioteca", "numa universidade", "num gabinete de estudo", "num mosteiro de copistas", "numa academia" },
    coisa = { "um pergaminho", "uma lupa", "um tinteiro", "um dicionário", "um globo terrestre" },
}
D.medo = {
    gosto = { "suor frio", "vela apagada", "ferrugem", "pó de cripta", "teia de aranha" },
    cheiro = { "porão", "vela apagada", "cripta", "terra úmida" },
    comparacao = { "um rangido de porta", "uma sombra no corredor", "um uivo", "um passo no escuro", "um sussurro atrás da cortina" },
    exclamacao = { "Socorro!", "Quem está aí?", "Cruzes!", "Ai, um fantasma!" },
    lugar = { "num porão escuro", "numa cripta", "num castelo assombrado", "num corredor sem luz", "debaixo da escada" },
    coisa = { "uma teia de aranha", "uma chave enferrujada", "um castiçal apagado", "um retrato que segue com os olhos", "um caixão entreaberto" },
}

-- Causa inventada depois: o mau humor ganha um motivo real (o acontecimento de um capítulo recente).
D._causa = {
    eventos = {
        morte = "aquela morte", casamento = "aquele casamento", viagem = "aquela viagem", carta = "aquela carta",
        tempestade = "aquela tempestade", doenca = "aquela febre", festa = "aquela festa", briga = "aquela briga",
        fuga = "aquela fuga", crime = "aquele crime",
    },
    jovem = {
        "Acordei com a tristeza no ar. Deve ser {evento} de “{livro}”.",
        "Tô sem pique hoje. Acho que foi {evento} de “{livro}”.",
        "Não sei por que tô assim. Ou sei: {evento} de “{livro}”.",
        "Não sai da minha cabeça: {evento} de “{livro}”.",
    },
    velha = {
        "Mau humor. Deve ser {evento} de “{livro}”. Nunca me recuperei.",
        "Acordei com um azedume. Ainda é {evento} de “{livro}”, garanto.",
        "Se estou insuportável, foi {evento} de “{livro}”.",
        "Não me pergunte nada hoje. É {evento} de “{livro}” ainda.",
    },
}

return D
