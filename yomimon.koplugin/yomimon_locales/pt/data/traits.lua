--[[--
Trait phrase bank (Portuguese).

speeches[pole][temperament]: what it says when the trait is striking.
  temperament "young" = nymph and young (anxious, innocent); "old" = adult and elder (cynical, cultured).
diary[pole][1|2|"fadeBack"]: what it notes when the trait becomes striking (1), strong (2) or fades.
  {book} = the book it was eating when it changed.

Never refer to the reader as masculine or feminine: "você", with no gendered adjective.
]]

local B = { speeches = {}, diary = {} }

B.speeches.bitter = {
    young = {
        "Ando triste e nem sei de quê. Desconfio dos seus livros.",
        "Antes eu achava que tudo acabava bem. Você me deu livros demais.",
        "Hoje acordei com gosto de tragédia na boca.",
        "Será que existe livro em que ninguém morre? Pergunto por uma amiga. Eu.",
        "Tô ficando com cara de quem leu coisa pesada. Porque li.",
        "As vírgulas agora me parecem pequenas lágrimas.",
        "Me dá um livro com cachorro feliz. Por favor. Só um.",
        "Aprendi uma palavra nova: melancolia. Acho que ela me aprendeu antes.",
        "Comi tanto final triste que já espero o pior de cada capítulo.",
        "Você lê umas coisas tristes, sabia? Eu sei. Eu como elas.",
        "Meu coração tá do tamanho de um ponto final.",
        "Quando eu crescer, quero ser menos triste. Ou mais ranzinza. Tanto faz.",
    },
    old = {
        "Amargura? Eu? Só como o que você me dá. Tire suas conclusões.",
        "Já não espero final feliz. Espero só o final.",
        "Toda página tem um defunto escondido. Eu encontro todos.",
        "A felicidade é um capítulo curto entre duas tragédias longas.",
        "Fiquei com amargura de papel velho. Culpa da sua estante.",
        "Otimismo é falta de leitura. Eu li demais.",
        "Me ofereça um livro alegre e eu acho a tragédia nas entrelinhas.",
        "O mundo é um romance russo sem índice.",
        "Já ri uma vez. Foi num livro. Depois alguém morreu.",
        "Não sou pessimista. Tenho boas fontes.",
        "Meu cigarro imaginário tem gosto de luto.",
        "Esperança é a nota de rodapé que ninguém lê.",
        "Todo começo me parece a véspera de um enterro.",
        "Se a vida fosse um livro, eu pularia para o fim. São todos iguais.",
        "Eu fico com amargura e você fica com olheiras. Seus livros acabam com a gente.",
    },
}

B.speeches.hopeful = {
    young = {
        "Hoje tudo parece capítulo bom. Até a capa!",
        "Acho que o mundo é mais bonito do que os vilões dizem.",
        "Comi uma página feliz e fiquei saltitando entre as linhas.",
        "Se esse livro acabar mal, eu reescrevo na cabeça. Já decidi.",
        "Tô gostando de tudo. Isso é perigoso? Parece perigoso.",
        "Hoje até as notas de rodapé parecem sorrir.",
        "Seus livros andam doces. Tô me acostumando mal.",
        "Acho que todo personagem merece um abraço. Até os chatos.",
        "Hoje eu acredito em finais felizes. Amanhã a gente vê.",
        "Se eu tivesse rabo, ele estaria abanando.",
        "Tudo vai dar certo. Li isso em algum lugar. Acho que foi aqui.",
        "Gosto quando o livro termina e ninguém morreu. Gosto muito.",
        "As letras estão dançando. Ou sou eu que estou.",
    },
    old = {
        "Estou de bom humor. Não espalhe, tenho uma reputação.",
        "Seus livros andam gentis. Estou amolecendo. Que vergonha.",
        "Hoje acredito na humanidade. De leve, mas acredito.",
        "Até que a vida tem bons capítulos. Poucos, mas tem.",
        "Fiquei otimista. Deve ser a idade. Ou a sua estante.",
        "O mundo não é tão ruim. Ainda prefiro os livros, mas não é tão ruim.",
        "Andam me dando páginas boas. Estou quase acreditando em final feliz.",
        "Sorri hoje. Ninguém viu. Ótimo.",
        "Esperança virou meu vício novo. Depois do cigarro imaginário.",
        "Alguns finais são felizes. Raro, mas acontece. Como hoje.",
        "Estou suspeitamente leve. Deve ter sido aquele livro.",
        "Hoje não vou reclamar de nada. Talvez de uma vírgula.",
        "Fiquei otimista. Se eu ficar insuportável, a culpa é sua.",
    },
}

B.speeches.fearful = {
    young = {
        "Ouviu isso? Foi a página virando sozinha?",
        "Não lê no escuro, por favor. Eu tô aqui também.",
        "Tem alguma coisa debaixo da orelha do livro. Eu sinto.",
        "Se aparecer um fantasma, eu fico atrás de você. Combinado?",
        "Hoje eu tive medo de um ponto de interrogação.",
        "Pode deixar a luz acesa? Só hoje. E amanhã.",
        "Cada capítulo novo é uma porta rangendo.",
        "Tô ficando com medo de tudo. Você só me dá coisa assustadora.",
        "Vi uma sombra na margem. Era só a margem. Acho.",
        "Não gosto de silêncio entre parágrafos. Alguém pode estar lá.",
        "Se eu sumir, procura no índice. É lá que eu me escondo.",
        "Meu coração bate em itálico. De susto.",
        "Por que todo livro bom tem um porão?",
        "Juro que a capa piscou pra mim.",
    },
    old = {
        "Não tenho medo. Tenho precauções. Muitas.",
        "Desde aquele livro, confiro debaixo de cada página antes de dormir.",
        "Idade avançada e susto de sobra. Belo resultado dos seus gostos literários.",
        "Escutei passos no capítulo de cima. Ignorei. Mentira, não ignorei.",
        "Já vi mortos andando em três livros seus. Agora vejo em todos.",
        "Desconfio de corredores, porões e narradores calmos.",
        "Fiquei com medo. Na minha idade.",
        "Uma página em branco me assusta mais que um monstro. Às vezes.",
        "Toda casa antiga nos seus livros tem alguém que nunca saiu.",
        "Não leia em voz alta. Eles podem ouvir.",
        "Medo? Não. Só fumo mais rápido quando o livro escurece.",
        "Os sustos são sempre os mesmos. Mesmo assim, eu pulo.",
        "Minha coragem acabou no terceiro livro de fantasma.",
    },
}

B.speeches.brave = {
    young = {
        "Quero ir pro mar! Não sei nadar, mas quero.",
        "Hoje eu enfrentaria um dragão. Pequeno. De papel.",
        "Seus livros me deixam valente. Ou boba. Valente-boba.",
        "Se tiver um mapa no livro, eu vou junto.",
        "Hoje encaro qualquer capítulo. Até os sem figura.",
        "Pulei três linhas de uma vez! Aventura!",
        "Quando eu crescer, quero explorar estantes.",
        "Me leva na próxima viagem? Eu caibo no bolso.",
        "Hoje subi até o topo da página sem olhar pra baixo.",
        "Tô ficando com coragem. Acho que foi aquele livro do navio.",
        "Se aparecer um vilão, eu mordo a canela dele.",
        "Aventura é só um capítulo em que ninguém volta cedo pra casa.",
        "Hoje atravessei uma página inteira de tempestade.",
        "Quero ver o horizonte. Qualquer um. Até o da margem.",
        "Coragem tem gosto de papel salgado.",
    },
    old = {
        "Já atravessei oceanos de papel. Um capítulo não me assusta.",
        "Seus livros me deram coragem. E reumatismo, de tanto viajar.",
        "Deixe vir o monstro. Já comi coisa pior: prefácios.",
        "Ganhei coragem. Na minha idade, isso se chama teimosia.",
        "Naufrágio? Já sobrevivi a três. Todos seus.",
        "Coragem se aprende lendo. Eu li bastante.",
        "Mostre o mapa. Eu decido se a viagem vale a pena.",
        "Enfrento qualquer vilão. Desde que ele tenha boa prosa.",
        "Já tive medo. Depois li as suas aventuras. Passou.",
        "O mar dos seus livros me curtiu feito bacalhau.",
        "Coragem é virar a página sabendo o que vem.",
        "Entre o perigo e o tédio, escolho o perigo. Sempre.",
        "Já escalei montanhas inteiras de notas de rodapé.",
        "Viajante aposentada. Só se você parar de ler aventuras.",
    },
}

B.speeches.cynical = {
    young = {
        "Todo mundo nos seus livros quer alguma coisa. Até os bonzinhos.",
        "Comecei a desconfiar de quem sorri muito nos livros.",
        "Ninguém faz nada de graça, né? Aprendi com você.",
        "O herói ajudou porque queria a herança. Tá na cara.",
        "Tô ficando esperta. Ou triste. Esperta-triste.",
        "Será que o amor existe ou é só um jeito de ganhar dote?",
        "Desconfio até do narrador. Ele também quer alguma coisa.",
        "Achei que reis eram bons. Li seus livros. Não são.",
        "Toda promessa nos seus livros tem letra miúda.",
        "Agora eu conto o dinheiro dos personagens. Antes eu contava estrelas.",
        "Ninguém é inocente. Nem eu. Comi uma página que não era minha.",
        "Se alguém é gentil demais no capítulo um, é vilão no capítulo dez.",
        "Política é briga com chapéu bonito.",
        "Tô aprendendo a ler as intenções. Elas são feias.",
        "Ontem acreditei num personagem. Hoje ele me traiu. Anotado.",
    },
    old = {
        "Amor? Contrato com flores.",
        "Todo herói tem um advogado e uma dívida.",
        "A bondade é só uma estratégia mais lenta.",
        "Seus livros me ensinaram: siga o dinheiro. Sempre.",
        "Revolução é quando os tiranos novos ganham chapéus novos.",
        "Desconfio de qualquer personagem que não cobra nada.",
        "O poder corrompe. E os livros sobre o poder também.",
        "Ninguém casa por amor nos seus livros. Ainda bem, seria inverossímil.",
        "Cinismo? Isso é só memória de quem lê.",
        "O vilão ao menos é honesto sobre o que quer.",
        "Promessa de político e promessa de prefácio: ninguém cumpre.",
        "A gratidão dura um capítulo. A vingança, o livro inteiro.",
        "Fiquei com cinismo. É o preço de ler gente esperta demais.",
        "Toda herança tem um parente esperando nas sombras.",
        "Sentimento? Prefiro juros compostos. Pelo menos crescem.",
    },
}

B.speeches.romantic = {
    young = {
        "Acho que me apaixonei. Por quem, não sei. Por um parágrafo.",
        "Será que um dia alguém vai me ler com carinho?",
        "Guardei aquela carta de amor do capítulo na barriga.",
        "Tô suspirando à toa. Culpa dos seus romances.",
        "Se eles não ficarem juntos, eu como o final.",
        "O amor nos livros tem cheiro de papel novo.",
        "Hoje sonhei com um marcador de página bonito.",
        "Acho que toda história devia ter um beijo. Pelo menos um.",
        "Fiquei com o coração mole. Não ri.",
        "Coração bobo bate em rima.",
        "Quero um final feliz. Com casamento e tudo.",
    },
    old = {
        "Amoleci. Foram os seus romances. Não conte a ninguém.",
        "Já tive cinismo. Aí você me deu cartas de amor. Que golpe baixo.",
        "Suspirei. Foi a idade. Ou aquele capítulo.",
        "O amor é uma doença literária. Contagiosa. Peguei.",
        "Toda grande história é uma história de amor mal resolvida.",
        "Ainda acredito no amor. Discretamente. Sem testemunhas.",
        "Se eles não ficarem juntos, escrevo uma carta ao autor. Furiosa.",
        "Romantismo, eu? Só nos dias úteis. E nos fins de semana.",
        "Os poetas tinham razão. Que irritante.",
        "Amar é ler alguém devagar.",
        "Na minha idade, o coração bate em notas de rodapé. Mas bate.",
        "Prefiro um amor impossível bem escrito a um possível mal editado.",
        "Fiquei com o coração mole. Vou precisar de um cigarro e de um soneto.",
        "Guardo as cartas de amor dos livros. As minhas nunca chegaram.",
    },
}

B.speeches.popular = {
    young = {
        "Gosto quando o livro vai rápido! Sem palavra difícil.",
        "Capítulo curtinho é igual bala: um atrás do outro.",
        "Hoje li tanto diálogo que fiquei tagarela.",
        "Pra que palavra comprida se a curta resolve?",
        "Tô gostando de livro que não me faz pensar muito. Isso é feio?",
        "Esse ritmo me deixa elétrica.",
        "Livro bom é livro que eu não consigo largar. Literalmente: grudou.",
        "Hoje eu só queria aventura e pipoca. De papel.",
        "Não entendi uma palavra difícil e nem fez falta.",
        "Tô ficando rápida. Mordo, engulo, viro a página.",
        "Os clássicos podem esperar. Esse aqui não!",
        "Gosto de livro que fala igual gente.",
        "Hoje li sem parar. Será que eu tenho um problema?",
        "Se tiver reviravolta, eu quero. Duas, de preferência.",
    },
    old = {
        "Confesso: estou gostando dessas leituras ligeiras. Não se acostume.",
        "Nada de latim hoje. Só tiro, beijo e reviravolta.",
        "Fiquei popular. Eu de antigamente teria horror.",
        "Prosa simples. Digere fácil. Como sopa.",
        "Não preciso de metáfora para ser feliz. Preciso de capítulo curto.",
        "Já comi Proust. Hoje quero um policial. Sem culpa.",
        "Livro de aeroporto também alimenta. Menos, mas alimenta.",
        "Andam me dando leitura rápida. Fiquei com pressa até para reclamar.",
        "Que ritmo. Nem deu tempo de acender o cigarro.",
        "O best-seller é o lanche rápido da estante. E eu estou com fome.",
        "Simples, direto, viciante. Como um mau hábito.",
        "Minha erudição tirou férias. Volta quando você ler um clássico.",
        "Gosto quando o autor não se acha. Raro e bom.",
        "Leitura leve: o cochilo da literatura. Merecido.",
        "Mais um capítulo, e mais um. Virei aquilo que eu criticava.",
    },
}

B.speeches.erudite = {
    young = {
        "Hoje aprendi três palavras com mais de quatro sílabas. Me sinto nas alturas.",
        "Acho que minha cultura está crescendo. Comi uma metáfora inteira.",
        "Quero ler um livro de filosofia. Só pra dizer que li.",
        "Hoje usei a palavra “efêmero”. Ninguém percebeu. Efêmero.",
        "Tô ficando chique. Só como papel-bíblia agora.",
        "Será que um dia vou entender poesia? Tô quase.",
        "Os clássicos têm gosto de biblioteca antiga. Gosto.",
        "Aprendi que “saudade” não tem tradução. Eu também não.",
        "Li uma frase tão longa que dormi no meio e acordei no fim.",
        "Tô colecionando palavras difíceis na barriga.",
        "Quando eu crescer, quero dar aula numa enciclopédia.",
        "O autor usou ponto e vírgula três vezes. Achei elegante.",
        "Hoje entendi uma ironia. Sem ajuda!",
        "Agora eu leio prefácio. Isso é ser adulta?",
    },
    old = {
        "Minha dieta agora é de clássicos. O resto me dá azia.",
        "Já não aceito frase sem oração subordinada.",
        "Virei pura erudição. Ninguém me entende. Exatamente como planejei.",
        "Cito Montaigne no café da manhã. Ninguém responde.",
        "Leio o que é difícil por princípio. E por vaidade.",
        "Uma boa vírgula vale mais que muita trama.",
        "Andam me dando prosa densa. Estou ficando insuportável. Valeu.",
        "Palavras longas descem bem com um cigarro imaginário.",
        "O best-seller me ofende. Pessoalmente.",
        "Filosofia de manhã, poesia à tarde, desprezo à noite.",
        "Releio para entender. Releio de novo para discordar.",
        "Minha opinião tem notas de rodapé. Três, pelo menos.",
        "Erudição é saber que não se sabe. Em latim.",
        "Fiquei pedante. A culpa é sua e dos seus clássicos.",
        "Hoje digeri um parágrafo de duas páginas. Sem água.",
    },
}

B.speeches.diurnal = {
    young = {
        "Bom dia! Ler de manhã tem gosto de pão quentinho.",
        "Acordei cedo pra te esperar. Você veio!",
        "As letras de manhã são mais clarinhas.",
        "O sol entrou pela margem e eu tô feliz.",
        "Hoje acordei com o canto dos pássaros. E do livro.",
        "De manhã eu tenho coragem pra capítulo difícil.",
        "Gosto quando você lê com café. O cheiro chega aqui.",
        "Começar o dia com papel é a melhor coisa.",
        "Dormi cedo pra acordar junto. Valeu a pena.",
        "De manhã as histórias parecem mais possíveis.",
        "Você acorda cedo, eu também. Somos um time.",
        "Os fantasmas dos livros não aparecem de manhã. Ótimo.",
        "Bom dia, livro. Bom dia, você. Bom dia, eu.",
    },
    old = {
        "Leitura matinal. Civilizada. Como deve ser.",
        "Os livros são mais honestos de manhã. Ainda não beberam.",
        "Café, papel e silêncio. A santíssima trindade.",
        "Acostumei a ler cedo. A madrugada que me perdoe.",
        "Prefiro a luz da manhã. Mostra os erros de revisão.",
        "Você me fez diurna. Eu era uma criatura das sombras. Era.",
        "De manhã o cinismo ainda está acordando. Aproveite.",
        "Leitura antes do almoço vale o dobro. Regra minha.",
        "O sol nas páginas. Até que não é ruim.",
        "Nada como um capítulo antes que o mundo comece a falar.",
        "Diurna. Quem diria. Minha mãe teria vergonha.",
        "Acordo, como uma página e reclamo do mundo. Rotina saudável.",
    },
}

B.speeches.nocturnal = {
    young = {
        "A gente virou criatura da noite, né? Eu gosto.",
        "De madrugada as letras brilham mais. Ou é a tela.",
        "Durmo de dia agora. Igual morcego. Morcego de papel.",
        "A noite é quando as histórias ficam de verdade.",
        "Ninguém lê tão tarde quanto a gente. Somos especiais.",
        "Escuto melhor os personagens quando tá tudo quieto.",
        "Se eu bocejar, finge que não viu.",
        "Já conheço o barulho da casa à meia-noite.",
        "A lua entra pela capa. Fico olhando.",
        "Ler de madrugada parece segredo. Gosto de segredos.",
        "O mundo dorme e a gente lê. Que bom.",
        "Meu relógio agora é o fim do capítulo.",
        "A noite tem gosto de tinta fresca.",
    },
    old = {
        "A madrugada é quando a literatura tira a maquiagem.",
        "Você me fez criatura da noite. Eu já era. Você piorou.",
        "Insônia e livros: casamento antigo, feliz e destrutivo.",
        "De dia eu finjo ser civilizada. De noite eu leio.",
        "Os melhores capítulos são lidos depois que todo mundo desistiu.",
        "Meu cigarro imaginário rende mais depois da meia-noite.",
        "Dormir é para quem já leu tudo. Não é o nosso caso.",
        "A noite tem menos testemunhas e mais verdade.",
        "Os fantasmas dos livros são minha companhia das três da manhã.",
        "Já vi o sol nascer por cima da última página. Duas vezes. Esta semana.",
        "A noite me fez filósofa. O dia vai me fazer ranzinza de novo.",
        "Silêncio, luz baixa, um capítulo a mais. Liturgia.",
        "Durmo quando o livro deixa. Ele raramente deixa.",
    },
}

-- Diary: when the trait becomes striking (1), strong (2) or fades ("fadeBack").
B.diary.bitter = {
    [1] = { "Ando com amargura. Acho que foi “{book}”. Ou a vida. Mas foi “{book}”.",
            "Notei que já não espero finais felizes. Culpa dos livros que você me dá." },
    [2] = { "Estou com amargura de papel queimado. Leitura nenhuma me consola.",
            "Hoje percebi: virei pessimista de vez. Seus livros fizeram um bom trabalho." },
    fadeBack = { "Acho que a tristeza passou. Por enquanto.", "Hoje não estou com amargura. Estranho. Anotei para não esquecer." },
}
B.diary.hopeful = {
    [1] = { "Estou de bom humor há dias. Desconfio de “{book}”.", "Comecei a acreditar em finais felizes. Que perigo." },
    [2] = { "Virei otimista. Se você me ouvir assobiando, finja que não ouviu.", "Estou leve demais. Seus livros andam doces demais." },
    fadeBack = { "O bom humor foi embora. Voltei ao normal: com a pulga atrás da orelha.", "Já não estou tão otimista. A estante voltou a pesar." },
}
B.diary.fearful = {
    [1] = { "Acho que estou ficando com medo. Culpa de “{book}”.", "Hoje pulei de susto com uma vírgula. Isso é novo." },
    [2] = { "Estou com medo de tudo. Até da capa. Valeu pelos seus gostos." },
    fadeBack = { "O medo passou. Já olho debaixo das páginas só uma vez por noite.", "Não estou mais com medo. Quase." },
}
B.diary.brave = {
    [1] = { "Estou ficando com coragem. Deve ter sido “{book}”.", "Hoje encarei um capítulo de tempestade sem piscar." },
    [2] = { "Virei puro espírito de aventura. Me dê um mapa e um livro e eu sumo." },
    fadeBack = { "A coragem foi tirar uma folga." },
}
B.diary.cynical = {
    [1] = { "Comecei a desconfiar de todo mundo. Valeu, “{book}”.", "Agora procuro o interesse por trás de cada gentileza." },
    [2] = { "Virei um caso de cinismo de carteirinha. Seus livros me ensinaram a seguir o dinheiro.", "Não acredito em mais ninguém. Nem no narrador." },
    fadeBack = { "Voltei a acreditar em alguém. Pouco, mas acreditei.", "O cinismo deu uma trégua." },
}
B.diary.romantic = {
    [1] = { "Acho que estou ficando com o coração mole. Culpa de “{book}”.", "Suspirei hoje. Sem motivo. Com motivo: um capítulo." },
    [2] = { "Virei um caso perdido de romantismo. Me deem um soneto e um lenço." },
    fadeBack = { "O romantismo passou. Ainda bem. Ou que pena.", "Já não suspiro à toa. Só às vezes." },
}
B.diary.popular = {
    [1] = { "Ando gostando de leitura rápida. Culpa de “{book}”.", "Percebi que já pulo as descrições compridas. Antes eu não fazia isso." },
    [2] = { "Virei fã de best-seller. Minha erudição pediu demissão.", "Agora só quero ritmo. Palavra difícil me dá preguiça." },
    fadeBack = { "Voltei a ter paciência com frase comprida.", "Já não tenho tanta pressa para ler." },
}
B.diary.erudite = {
    [1] = { "Estou ganhando cultura. Deve ter sido “{book}”.", "Percebi que agora eu cito autores. Que horror. Que delícia." },
    [2] = { "Virei pura erudição. Ninguém me entende, como deve ser.", "Agora só digiro frase com oração subordinada. Seus livros me estragaram." },
    fadeBack = { "A erudição deu uma descansada.", "Voltei a gostar de frase curta." },
}
B.diary.diurnal = {
    [1] = { "Percebi que acordo com o sol, igual a você." },
    [2] = { "Leio com o café da manhã. Virou ritual." },
    fadeBack = { "Já não sou tão da manhã.", "Os horários bagunçaram de novo." },
}
B.diary.nocturnal = {
    [1] = { "Virei criatura da noite. Culpa sua e das suas madrugadas.", "Percebi que só acordo de verdade depois das dez da noite." },
    [2] = { "Sou da noite de vez. O sol me ofende.", "A madrugada virou minha casa. A sua também, pelo visto." },
    fadeBack = { "Voltei a dormir à noite. Que tédio.", "Já não sou tão da noite." },
}

return B
