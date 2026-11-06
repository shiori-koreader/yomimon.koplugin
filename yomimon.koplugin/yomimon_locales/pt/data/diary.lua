--[[--
Diary phrase bank (Portuguese). Gaps: {n} pages, {book}, {book2}, {nameText}, {name2},
{fala}, {tema} ("o mar"), {of_theme} ("do mar"), {autor}, {anterior}, {outro}, {ordinal}.
Never describe the reader with a gendered adjective.
]]

local B = { day = {}, beginning = {}, ending = {}, obsession = {}, recollection = {} }

-- Reading day ------------------------------------------------------------------------
B.day.thin = {
    "Dia magro: {n} páginas de “{book}”.",
    "Só {n} páginas hoje. Belisquei “{book}”.",
    "{n} páginas de “{book}”. Um aperitivo.",
    "Hoje foi pouco: {n} páginas de “{book}”. Lambi os dedos.",
    "Umas migalhas de “{book}”: {n} páginas.",
    "{n} páginas. “{book}” mal encostou na minha boca.",
}
B.day.normal = {
    "{n} páginas de “{book}”.",
    "Comi {n} páginas de “{book}”.",
    "Mais {n} páginas de “{book}” na barriga.",
    "Hoje: “{book}”, {n} páginas.",
    "Avancei {n} páginas em “{book}”.",
    "“{book}” rendeu {n} páginas hoje.",
    "{n} páginas. “{book}” continua no meu prato.",
}
B.day.banquete = {
    "{n} páginas de “{book}”. Banquete.",
    "Hoje teve festa: {n} páginas de “{book}”.",
    "{n} páginas de “{book}” de uma vez. Tô de barriga cheia.",
    "Comi {n} páginas de “{book}”. Nem lembro de respirar.",
    "Um dia gordo: {n} páginas de “{book}”.",
    "{n} páginas de “{book}”. Minha barriga pediu arrego.",
}
B.day.huge_one = {
    "{n} páginas de “{book}” num dia só. Estou redonda.",
    "{n} páginas. Você não leu “{book}”, você atravessou.",
    "Maratona: {n} páginas de “{book}”. Preciso me deitar.",
}
B.day.two_books = {
    "{n} páginas, divididas entre “{book}” e “{book2}”.",
    "Dia de dois pratos: “{book}” e um pouco de “{book2}”. {n} páginas.",
    "{n} páginas. Fiquei entre “{book}” e “{book2}”, como quem não decide a sobremesa.",
    "Traí “{book2}” com “{book}”. {n} páginas no total.",
}
B.day.time_of_day = {
    small_hours = { "Quase tudo de madrugada.", "Lido depois da meia-noite, como os segredos.", "Mais uma madrugada em claro.<nocturnal: Adoro.|fearful: Com a luz acesa.|>",
                  "Lemos enquanto a casa dormia.<fearful: Ouvi cada estalo.|>" },
    morning = { "Tudo antes do almoço.", "Lido de manhã, com cheiro de café.<diurnal: Meu horário.|>", "Começamos cedo." },
    noite = { "Lido tarde da noite.", "Quase tudo depois das dez.", "Noite adentro.<nocturnal: Do jeito que eu gosto.|>" },
}
B.day.speech = {
    young = { "{nameText} disse “{speech}”. Repeti baixinho.", "{nameText} falou “{speech}”. Fiquei pensando nisso.",
              "Guardei uma fala de {nameText}: “{speech}”.", "“{speech}”, disse {nameText}. Eu nunca teria coragem." },
    old = { "{nameText} disse “{speech}”. Anotei para nunca perdoar.", "“{speech}”, disse {nameText}. Eu teria dito melhor.",
              "Frase do dia, de {nameText}: “{speech}”. Merecia um cigarro.", "{nameText}: “{speech}”. Guardei. <romantic:Vou usar numa carta.|Vou usar contra alguém.>" },
}
B.day.new = {
    "Conheci {nameText}.", "Apareceu {nameText}. Ainda não sei o que acho.", "Entrou em cena {nameText}.",
    "Me apresentaram {nameText}. Sem muito entusiasmo.", "Um tal de {nameText} chegou. <romantic:Gostei logo.|fearful:Me escondi.|Vou ficar de olho.>",
    "{nameText} apareceu. Vai dar trabalho.",
}
B.day.newOnes2 = {
    "Conheci {nameText} e {name2}.", "Apareceram {nameText} e {name2}. Gente demais.",
    "{nameText} e {name2} entraram em cena. Um dos dois vai me irritar.", "Me apresentaram {nameText} e {name2}. Anotei os dois.",
}
B.day.event = {
    morte = { "Alguém morreu.", "Teve morte. <romantic:Chorei de verdade.|fearful:Dormi de luz acesa.|Fiquei de luto por educação.>", "Enterraram alguém. Cheiro de vela." },
    casamento = { "Teve casamento.", "Alguém casou. <romantic:Chorei no altar.|hopeful:Desta vez vai durar.|Dou três capítulos.>", "Noiva, altar, promessa. Anotei pra cobrar." },
    viagem = { "Alguém pegou a estrada.", "Teve viagem. <brave:Fui junto, de carona na mala.|Eu fiquei.>", "Gente partindo e chegando o dia todo." },
    carta = { "Chegou uma carta.", "Teve carta. <romantic:Li duas vezes.|hopeful:Era boa notícia, pra variar.|Nunca é boa notícia.>", "Alguém escreveu o que não devia." },
    tempestade = { "Choveu no livro.", "Teve tempestade." },
    doenca = { "Alguém adoeceu.", "Teve febre e médico.", "Gente de cama. Mau sinal." },
    festa = { "Teve festa.", "Teve baile. <romantic:Dancei na margem, sem par.|Ninguém me chamou.>", "Música e vinho. Para eles." },
    briga = { "Teve briga.", "Alguém finalmente disse o que pensava." },
    fuga = { "Alguém fugiu.", "Teve fuga.", "Gente correndo do próprio destino." },
    crime = { "Teve crime.", "Sangue e polícia." },
}
B.day.theme = {
    "O assunto foi {theme}.", "Só se falou {of_theme}.", "Muito {of_theme} hoje. Demais.",
    "O dia teve gosto {of_theme}.", "Tudo girou em torno {of_theme}.",
}
B.day.heavy = { "Páginas pesadas.", "Dia escuro de papel.", "Muita sombra, pouca luz.", "Leitura que deixa marca." }
B.day.light = { "Páginas leves, para variar.", "Um dia doce de papel.", "Leitura que não machuca. Rara." }
B.day.closing = {
    young = { "Amanhã tem mais.", "Ainda digerindo.", "Tô gostando.", "Dormi pensando nisso.", "Quero mais.", "" },
    old = { "Anotado.", "Que cansaço.", "Acendi um cigarro imaginário.", "Sigamos.", "Nada de novo. Ou quase.", "" },
}
B.day.closing_dark = {
    young = { "Dormi mal.", "Fiquei com medo do escuro.", "Deixei a luz acesa." },
    old = { "Dormi mal. Como sempre.", "Mais um peso na estante.", "Precisei de dois cigarros imaginários.", "Previsível. Doeu mesmo assim." },
}
B.day.closing_light = {
    young = { "Sonhei bonito.", "Fiquei feliz à toa.", "Dormi sorrindo." },
    old = { "Quase sorri.", "Desconfio de tanta leveza.", "Não se acostume." },
}

-- Start of a book ------------------------------------------------------------------------
B.beginning.generic_one = {
    "Comecei a roer “{book}”. A capa prometia muito. Capas sempre prometem.",
    "Livro novo: “{book}”. Cheiro de papel que ainda não sabe o que o espera.",
    "“{book}” chegou ao meu prato. Vamos ver se aguenta.",
    "Abri “{book}”. A primeira página sempre jura que vai valer a pena.",
    "Começamos “{book}”. Eu com fome, você com esperança.",
    "Outro livro: “{book}”. Minha barriga agradece, meu humor aguarda.",
    "“{book}”. Novo endereço. Ainda estou desfazendo as malas.",
}
B.beginning.author = {
    "“{book}”, de {author}. Vamos ver se {author} merece a minha fome.",
    "Comecei “{book}”. Nunca comi nada de {author}. Primeira vez é sempre estranha.",
    "{author}, prazer. Vim comer o seu “{book}”.",
}
B.beginning.same_author = {
    "Mais um de {author}: “{book}”. Fidelidade ou preguiça?",
    "{author} de novo. “{book}” agora. Estamos namorando?",
    "Voltamos a {author}. “{book}” é o próximo prato.",
    "Outro {author}. Você não larga esse autor, hein.",
}
B.beginning.dropped = {
    "Larguei “{previous}” no meio do caminho. Agora é “{book}”. Não comento. Comento: covardia.",
    "“{previous}” ficou para trás, sem fim. Trocamos por “{book}”. Eu vi.",
    "Abandonamos “{previous}”. Que descanse em paz. Agora: “{book}”.",
    "Pulamos para “{book}”. “{previous}” vai ficar me olhando da estante.",
}
B.beginning.rereading = {
    "Relendo “{book}”. Já sei o fim. Como devagar.",
    "“{book}” outra vez. Ou você esqueceu, ou se apaixonou.",
    "Releitura de “{book}”. Agora eu presto atenção nos detalhes. E nas vírgulas.",
}

-- End of a book -------------------------------------------------------------------------
B.ending.opening = {
    "Terminei “{book}”.", "Fim de “{book}”.", "Acabou “{book}”.", "Última página de “{book}”.",
    "“{book}”: digerido.", "Comi a última linha de “{book}”.",
}
-- {nameText}: the book's compound name (yomimon_vector.lua), e.g. "uma história de mar, agitada"
B.ending.nameText = { "Foi {nameText}.", "No fundo, {nameText}.", "Resumindo: {nameText}.", "Se me perguntarem: {nameText}." }
B.ending.protagonist = {
    young = { "Vou sentir falta de {nameText}.", "Fiquei com {nameText} na cabeça.", "{nameText} vai morar no meu coração. Pequeno, mas cabe." },
    old = { "Fiquei com {nameText} na cabeça. Contra a minha vontade.", "{nameText} vai me assombrar por uns dias.",
              "Sobrevivi a {nameText}. Por pouco." },
}
B.ending.darker = { "Mais sombrio que “{other}”.", "Pesou mais que “{other}”.", "Deixou “{other}” parecendo comédia." }
B.ending.lighter = { "Mais leve que “{other}”.", "Depois de “{other}”, um respiro.", "Doeu menos que “{other}”." }
B.ending.series = {
    "{ordinal} livro seguido sobre {theme}. Você está fugindo de alguma coisa?",
    "{ordinal} livro {of_theme} em sequência. Estou vendo um padrão.",
    "{ordinal} vez que um livro seu me fala {of_theme}. Anotado.",
}
B.ending.trait = {
    bitter = { "Saí com mais amargura do que entrei.", "Esse livro me tirou um pouco de esperança." },
    hopeful = { "Saí mais leve do que entrei.", "Esse livro me devolveu um pouco de fé." },
    fearful = { "Saí com mais medo do que entrei.", "Esse livro me ensinou a olhar debaixo das páginas." },
    brave = { "Saí com mais coragem do que entrei." },
    cynical = { "Saí com mais desconfiança do que entrei.", "Esse livro me ensinou a seguir o dinheiro." },
    romantic = { "Saí com mais romantismo do que entrei.", "Esse livro me amoleceu. Que vergonha." },
    popular = { "Saí com pressa de ler. Mau sinal.", "Esse livro me acostumou mal com o ritmo." },
    erudite = { "Saí mais culta do que entrei. Insuportável.", "Esse livro me deixou citando autores." },
}
B.ending.grade = {
    young = { "Nota: {n} estrelinhas.", "Dou {n} estrelinhas.", "{n} estrelinhas de 5." },
    old = { "Nota: {n} cigarros imaginários.", "{n} cigarros imaginários de 5.", "Vale {n} cigarros imaginários." },
}
B.ending.verdict = {
    young = {
        { "Comi por educação. Desculpa, autor.", "Não era pra mim. Acho." },
        { "Tinha coisa boa, mas demorou a aparecer.", "Meio morno. Igual papel esquecido no sol." },
        { "Gostei! Não muito. Mas gostei." },
        { "Que livro! Vou sonhar com ele.", "Fiquei triste quando acabou. Isso é bom, né?" },
        { "O melhor que eu já comi. Até agora. Acho. Sim.", "Quero ler de novo. Agora. Já." },
    },
    old = {
        { "Um livro que existe. Só isso." },
        { "Teve seus momentos. Poucos.", "Morno. Como chá esquecido." },
        { "Decente. Raro, hoje em dia.", "Não mudou minha vida. Mas também não a piorou." },
        { "Bom livro. Vou sentir falta de odiá-lo.", "Esse autor sabia o que fazia. Odeio quando acontece." },
        { "Raro. Um livro que eu não consegui odiar.", "Fecho a capa com respeito. E com um cigarro." },
    },
}

-- Obsessions (dominant theme) ---------------------------------------------------------------
B.obsession.new = {
    "Percebi que penso muito {theme}. Não pedi por isso.",
    "Ando pensando {theme}. Culpa dos seus livros.",
    "Não consigo parar de pensar {theme}. Vou precisar de outro livro. Ou de terapia.",
}
B.obsession.swap = {
    "Antes eu pensava {before}. Agora só penso {now}. Culpa sua e dos seus livros.",
    "Troquei de obsessão: saiu {before_s}, entrou {now_s}.",
    "{now_s} tomou o lugar de {before_s} na minha cabeça.",
    "Já não penso tanto {before}. Agora é {now_s}, o tempo todo.",
}

-- Memories (yomimon_memories.lua): {author} {n} {book} {monthName} {nameText} {theme} {of_theme} --------------
B.recollection.author = {
    "{author} de novo. É o {n}º livro de {author} que a gente lê. Isso já é um relacionamento.",
    "Voltamos a {author}: {n}º livro. Eu já reconheço o tempero.",
    "{n}º de {author}. Tem gente que coleciona selos.",
    "Mais {author}. O {n}º. Você não cansa, e eu confesso que também não.",
    "{author} outra vez, pela {n}ª vez. Já sei onde ficam os ossos.",
}
B.recollection.anniversary = {
    "Faz um ano que a gente terminou “{book}”. Ainda sinto o gosto.",
    "Um ano hoje desde o fim de “{book}”. Você lembra? Eu lembro de tudo.",
    "Aniversário: há exatamente um ano, a última página de “{book}”.",
}
B.recollection.character = {
    "{nameText} de novo… a gente se conhece de “{book}”.",
    "Olha quem voltou: {nameText}. Desde “{book}” eu não via essa figura.",
    "{nameText}! Achei que tinha ficado em “{book}”.",
    "{nameText} outra vez. “{book}” não foi suficiente, pelo visto.",
}
B.recollection.longest_record = {
    "“{book}”: {n} páginas. O mais longo que você já leu comigo. Tô de barriga estufada.",
    "Recorde: “{book}” foi o livro mais comprido que a gente comeu junto.",
    "Nunca comemos nada tão grande quanto “{book}”. Preciso deitar.",
}
B.recollection.fastest_record = {
    "Nenhum livro desceu tão rápido quanto “{book}”. Ou era bom, ou era fome.",
    "Recorde de velocidade: “{book}”. Me deu soluço.",
}
B.recollection.theme_series = {
    "{n}º livro seguido sobre {theme}. Estou vendo um padrão. E você?",
    "Mais um livro {of_theme}. É o {n}º seguido. Você está procurando alguma coisa?",
    "{n} livros seguidos em que {theme} manda. Anotado no meu caderninho.",
}
B.recollection.gloomy_since = {
    "Você não lia nada tão sombrio desde “{book}”, em {month}.",
    "Desde “{book}”, lá em {month}, eu não comia páginas tão escuras.",
    "Isso aqui está tão pesado quanto “{book}”. E isso foi em {month}.",
}
B.recollection.gloomiest = {
    "Este é o livro mais sombrio que a gente já leu junto. Estou de luto e nem sei por quê.",
    "Nunca comi páginas tão escuras com você. Recorde que ninguém queria.",
}
B.recollection.light_since = {
    "Nada tão leve desde “{book}”, em {month}. Que alívio.",
    "Desde “{book}”, em {month}, eu não comia páginas tão doces.",
}
B.recollection.lighter = {
    "O livro mais leve que a gente já leu junto. Desconfio.",
    "Nunca comi páginas tão doces com você. Vou ter cárie.",
}

return B
