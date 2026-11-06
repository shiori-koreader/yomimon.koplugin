--[[--
Banco de frases do diário (português). Brechas: {n} páginas, {livro}, {livro2}, {nome}, {nome2},
{fala}, {tema} ("o mar"), {de_tema} ("do mar"), {autor}, {anterior}, {outro}, {ordinal}.
Nunca falar do leitor com adjetivo de gênero.
]]

local B = { dia = {}, inicio = {}, fim = {}, obsessao = {}, lembranca = {} }

-- Dia de leitura ------------------------------------------------------------------------
B.dia.magro = {
    "Dia magro: {n} páginas de “{livro}”.",
    "Só {n} páginas hoje. Belisquei “{livro}”.",
    "{n} páginas de “{livro}”. Um aperitivo.",
    "Hoje foi pouco: {n} páginas de “{livro}”. Lambi os dedos.",
    "Umas migalhas de “{livro}”: {n} páginas.",
    "{n} páginas. “{livro}” mal encostou na minha boca.",
}
B.dia.normal = {
    "{n} páginas de “{livro}”.",
    "Comi {n} páginas de “{livro}”.",
    "Mais {n} páginas de “{livro}” na barriga.",
    "Hoje: “{livro}”, {n} páginas.",
    "Avancei {n} páginas em “{livro}”.",
    "“{livro}” rendeu {n} páginas hoje.",
    "{n} páginas. “{livro}” continua no meu prato.",
}
B.dia.banquete = {
    "{n} páginas de “{livro}”. Banquete.",
    "Hoje teve festa: {n} páginas de “{livro}”.",
    "{n} páginas de “{livro}” de uma vez. Estou cheia.",
    "Comi {n} páginas de “{livro}”. Nem lembro de respirar.",
    "Um dia gordo: {n} páginas de “{livro}”.",
    "{n} páginas de “{livro}”. Minha barriga pediu arrego.",
}
B.dia.enorme = {
    "{n} páginas de “{livro}” num dia só. Estou redonda.",
    "{n} páginas. Você não leu “{livro}”, você atravessou.",
    "Maratona: {n} páginas de “{livro}”. Preciso me deitar.",
}
B.dia.dois_livros = {
    "{n} páginas, divididas entre “{livro}” e “{livro2}”.",
    "Dia de dois pratos: “{livro}” e um pouco de “{livro2}”. {n} páginas.",
    "{n} páginas. Fiquei entre “{livro}” e “{livro2}”, como quem não decide a sobremesa.",
    "Traí “{livro2}” com “{livro}”. {n} páginas no total.",
}
B.dia.horario = {
    madrugada = { "Quase tudo de madrugada.", "Lido depois da meia-noite, como os segredos.", "Mais uma madrugada em claro.<noturna: Adoro.|medrosa: Com a luz acesa.|>",
                  "Lemos enquanto a casa dormia.<medrosa: Ouvi cada estalo.|>" },
    manha = { "Tudo antes do almoço.", "Lido de manhã, com cheiro de café.<diurna: Meu horário.|>", "Começamos cedo." },
    noite = { "Lido tarde da noite.", "Quase tudo depois das dez.", "Noite adentro.<noturna: Do jeito que eu gosto.|>" },
}
B.dia.fala = {
    jovem = { "{nome} disse “{fala}”. Repeti baixinho.", "{nome} falou “{fala}”. Fiquei pensando nisso.",
              "Guardei uma fala de {nome}: “{fala}”.", "“{fala}”, disse {nome}. Eu nunca teria coragem." },
    velha = { "{nome} disse “{fala}”. Anotei para nunca perdoar.", "“{fala}”, disse {nome}. Eu teria dito melhor.",
              "Frase do dia, de {nome}: “{fala}”. Merecia um cigarro.", "{nome}: “{fala}”. Guardei. <romantica:Vou usar numa carta.|Vou usar contra alguém.>" },
}
B.dia.novo = {
    "Conheci {nome}.", "Apareceu {nome}. Ainda não sei o que acho.", "Entrou em cena {nome}.",
    "Fui apresentada a {nome}. Sem muito entusiasmo.", "Um tal de {nome} chegou. <romantica:Gostei logo.|medrosa:Me escondi.|Vou ficar de olho.>",
    "{nome} apareceu. Vai dar trabalho.",
}
B.dia.novos2 = {
    "Conheci {nome} e {nome2}.", "Apareceram {nome} e {nome2}. Gente demais.",
    "{nome} e {nome2} entraram em cena. Um dos dois vai me irritar.", "Fui apresentada a {nome} e {nome2}. Anotei os dois.",
}
B.dia.evento = {
    morte = { "Alguém morreu.", "Teve morte. <romantica:Chorei de verdade.|medrosa:Dormi de luz acesa.|Fiquei de luto por educação.>", "Enterraram alguém. Cheiro de vela." },
    casamento = { "Teve casamento.", "Alguém casou. <romantica:Chorei no altar.|otimista:Desta vez vai durar.|Dou três capítulos.>", "Noiva, altar, promessa. Anotei pra cobrar." },
    viagem = { "Alguém pegou a estrada.", "Teve viagem. <corajosa:Fui junto, de carona na mala.|Eu fiquei.>", "Gente partindo e chegando o dia todo." },
    carta = { "Chegou uma carta.", "Teve carta. <romantica:Li duas vezes.|otimista:Era boa notícia, pra variar.|Nunca é boa notícia.>", "Alguém escreveu o que não devia." },
    tempestade = { "Choveu no livro.", "Teve tempestade." },
    doenca = { "Alguém adoeceu.", "Teve febre e médico.", "Gente de cama. Mau sinal." },
    festa = { "Teve festa.", "Teve baile. <romantica:Dancei sozinha na margem.|Ninguém me chamou.>", "Música e vinho. Para eles." },
    briga = { "Teve briga.", "Alguém finalmente disse o que pensava." },
    fuga = { "Alguém fugiu.", "Teve fuga.", "Gente correndo do próprio destino." },
    crime = { "Teve crime.", "Sangue e polícia." },
}
B.dia.tema = {
    "O assunto foi {tema}.", "Só se falou {de_tema}.", "Muito {de_tema} hoje. Demais.",
    "O dia teve gosto {de_tema}.", "Tudo girou em torno {de_tema}.",
}
B.dia.pesado = { "Páginas pesadas.", "Dia escuro de papel.", "Muita sombra, pouca luz.", "Leitura que deixa marca." }
B.dia.leve = { "Páginas leves, para variar.", "Um dia doce de papel.", "Leitura que não machuca. Rara." }
B.dia.fecho = {
    jovem = { "Amanhã tem mais.", "Ainda digerindo.", "Tô gostando.", "Dormi pensando nisso.", "Quero mais.", "" },
    velha = { "Anotado.", "Que cansaço.", "Acendi um cigarro imaginário.", "Sigamos.", "Nada de novo. Ou quase.", "" },
}
B.dia.fecho_escuro = {
    jovem = { "Dormi mal.", "Fiquei com medo do escuro.", "Deixei a luz acesa." },
    velha = { "Dormi mal. Como sempre.", "Mais um peso na estante.", "Precisei de dois cigarros imaginários.", "Previsível. Doeu mesmo assim." },
}
B.dia.fecho_leve = {
    jovem = { "Sonhei bonito.", "Fiquei feliz à toa.", "Dormi sorrindo." },
    velha = { "Quase sorri.", "Desconfio de tanta leveza.", "Não se acostume." },
}

-- Começo de livro ------------------------------------------------------------------------
B.inicio.generico = {
    "Comecei a roer “{livro}”. A capa prometia muito. Capas sempre prometem.",
    "Livro novo: “{livro}”. Cheiro de papel que ainda não sabe o que o espera.",
    "“{livro}” chegou ao meu prato. Vamos ver se aguenta.",
    "Abri “{livro}”. A primeira página sempre jura que vai valer a pena.",
    "Começamos “{livro}”. Eu com fome, você com esperança.",
    "Outro livro: “{livro}”. Minha barriga agradece, meu humor aguarda.",
    "“{livro}”. Novo endereço. Ainda estou desfazendo as malas.",
}
B.inicio.autor = {
    "“{livro}”, de {autor}. Vamos ver se {autor} merece a minha fome.",
    "Comecei “{livro}”. Nunca comi nada de {autor}. Primeira vez é sempre estranha.",
    "{autor}, prazer. Vim comer o seu “{livro}”.",
}
B.inicio.mesmo_autor = {
    "Mais um de {autor}: “{livro}”. Fidelidade ou preguiça?",
    "{autor} de novo. “{livro}” agora. Estamos namorando?",
    "Voltamos a {autor}. “{livro}” é o próximo prato.",
    "Outro {autor}. Você não larga esse autor, hein.",
}
B.inicio.largou = {
    "Larguei “{anterior}” no meio do caminho. Agora é “{livro}”. Não comento. Comento: covardia.",
    "“{anterior}” ficou para trás, sem fim. Trocamos por “{livro}”. Eu vi.",
    "Abandonamos “{anterior}”. Que descanse em paz. Agora: “{livro}”.",
    "Pulamos para “{livro}”. “{anterior}” vai ficar me olhando da estante.",
}
B.inicio.relendo = {
    "Relendo “{livro}”. Já sei o fim. Como devagar.",
    "“{livro}” outra vez. Ou você esqueceu, ou se apaixonou.",
    "Releitura de “{livro}”. Agora eu presto atenção nos detalhes. E nas vírgulas.",
}

-- Fim de livro -------------------------------------------------------------------------
B.fim.abertura = {
    "Terminei “{livro}”.", "Fim de “{livro}”.", "Acabou “{livro}”.", "Última página de “{livro}”.",
    "“{livro}”: digerido.", "Comi a última linha de “{livro}”.",
}
-- {nome}: o nome composto do livro (yomimon_vector.lua), ex.: "uma história de mar, agitada"
B.fim.nome = { "Foi {nome}.", "No fundo, {nome}.", "Resumindo: {nome}.", "Se me perguntarem: {nome}." }
B.fim.protagonista = {
    jovem = { "Vou sentir falta de {nome}.", "Fiquei com {nome} na cabeça.", "{nome} vai morar no meu coração. Pequeno, mas cabe." },
    velha = { "Fiquei com {nome} na cabeça. Contra a minha vontade.", "{nome} vai me assombrar por uns dias.",
              "Sobrevivi a {nome}. Por pouco." },
}
B.fim.mais_escuro = { "Mais sombrio que “{outro}”.", "Pesou mais que “{outro}”.", "Deixou “{outro}” parecendo comédia." }
B.fim.mais_leve = { "Mais leve que “{outro}”.", "Depois de “{outro}”, um respiro.", "Doeu menos que “{outro}”." }
B.fim.serie = {
    "{ordinal} livro seguido sobre {tema}. Você está fugindo de alguma coisa?",
    "{ordinal} livro {de_tema} em sequência. Estou vendo um padrão.",
    "{ordinal} vez que um livro seu me fala {de_tema}. Anotado.",
}
B.fim.traco = {
    amarga = { "Saí mais amarga do que entrei.", "Esse livro me tirou um pouco de esperança." },
    otimista = { "Saí mais leve do que entrei.", "Esse livro me devolveu um pouco de fé." },
    medrosa = { "Saí mais medrosa do que entrei.", "Esse livro me ensinou a olhar debaixo das páginas." },
    corajosa = { "Saí mais corajosa do que entrei." },
    cinica = { "Saí mais desconfiada do que entrei.", "Esse livro me ensinou a seguir o dinheiro." },
    romantica = { "Saí mais romântica do que entrei.", "Esse livro me amoleceu. Que vergonha." },
    popular = { "Saí com pressa de ler. Mau sinal.", "Esse livro me acostumou mal com o ritmo." },
    erudita = { "Saí mais culta do que entrei. Insuportável.", "Esse livro me deixou citando autores." },
}
B.fim.nota = {
    jovem = { "Nota: {n} estrelinhas.", "Dou {n} estrelinhas.", "{n} estrelinhas de 5." },
    velha = { "Nota: {n} cigarros imaginários.", "{n} cigarros imaginários de 5.", "Vale {n} cigarros imaginários." },
}
B.fim.veredito = {
    jovem = {
        { "Comi por educação. Desculpa, autor.", "Não era pra mim. Acho." },
        { "Tinha coisa boa, mas demorou a aparecer.", "Meio morno. Igual papel esquecido no sol." },
        { "Gostei! Não muito. Mas gostei." },
        { "Que livro! Vou sonhar com ele.", "Fiquei triste quando acabou. Isso é bom, né?" },
        { "O melhor que eu já comi. Até agora. Acho. Sim.", "Quero ler de novo. Agora. Já." },
    },
    velha = {
        { "Um livro que existe. Só isso." },
        { "Teve seus momentos. Poucos.", "Morno. Como chá esquecido." },
        { "Decente. Raro, hoje em dia.", "Não mudou minha vida. Mas também não a piorou." },
        { "Bom livro. Vou sentir falta de odiá-lo.", "Esse autor sabia o que fazia. Odeio quando acontece." },
        { "Raro. Um livro que eu não consegui odiar.", "Fecho a capa com respeito. E com um cigarro." },
    },
}

-- Obsessões (tema dominante) ---------------------------------------------------------------
B.obsessao.nova = {
    "Percebi que penso muito {tema}. Não pedi por isso.",
    "Ando pensando {tema}. Culpa dos seus livros.",
    "Não consigo parar de pensar {tema}. Vou precisar de outro livro. Ou de terapia.",
}
B.obsessao.troca = {
    "Antes eu pensava {antes}. Agora só penso {agora}. Culpa sua e dos seus livros.",
    "Troquei de obsessão: saiu {antes_s}, entrou {agora_s}.",
    "{agora_s} tomou o lugar de {antes_s} na minha cabeça.",
    "Já não penso tanto {antes}. Agora é {agora_s}, o tempo todo.",
}

-- Lembranças (yomimon_memories.lua): {autor} {n} {livro} {mes} {nome} {tema} {de_tema} --------------
B.lembranca.autor = {
    "{autor} de novo. É o {n}º livro de {autor} que a gente lê. Isso já é um relacionamento.",
    "Voltamos a {autor}: {n}º livro. Eu já reconheço o tempero.",
    "{n}º de {autor}. Tem gente que coleciona selos.",
    "Mais {autor}. O {n}º. Você não cansa, e eu confesso que também não.",
    "{autor} outra vez, pela {n}ª vez. Já sei onde ficam os ossos.",
}
B.lembranca.aniversario = {
    "Faz um ano que a gente terminou “{livro}”. Ainda sinto o gosto.",
    "Um ano hoje desde o fim de “{livro}”. Você lembra? Eu lembro de tudo.",
    "Aniversário: há exatamente um ano, a última página de “{livro}”.",
}
B.lembranca.personagem = {
    "{nome} de novo… a gente se conhece de “{livro}”.",
    "Olha quem voltou: {nome}. Desde “{livro}” eu não via essa figura.",
    "{nome}! Achei que tinha ficado em “{livro}”.",
    "{nome} outra vez. “{livro}” não foi suficiente, pelo visto.",
}
B.lembranca.recorde_longo = {
    "“{livro}”: {n} páginas. O mais longo que você já leu comigo. Estou estufada.",
    "Recorde: “{livro}” foi o livro mais comprido que a gente comeu junto.",
    "Nunca comemos nada tão grande quanto “{livro}”. Preciso deitar.",
}
B.lembranca.recorde_rapido = {
    "Nenhum livro desceu tão rápido quanto “{livro}”. Ou era bom, ou era fome.",
    "Recorde de velocidade: “{livro}”. Me deu soluço.",
}
B.lembranca.serie_tema = {
    "{n}º livro seguido sobre {tema}. Estou vendo um padrão. E você?",
    "Mais um livro {de_tema}. É o {n}º seguido. Você está procurando alguma coisa?",
    "{n} livros seguidos em que {tema} manda. Anotado no meu caderninho.",
}
B.lembranca.sombrio_desde = {
    "Você não lia nada tão sombrio desde “{livro}”, em {mes}.",
    "Desde “{livro}”, lá em {mes}, eu não comia páginas tão escuras.",
    "Isso aqui está tão pesado quanto “{livro}”. E isso foi em {mes}.",
}
B.lembranca.mais_sombrio = {
    "Este é o livro mais sombrio que a gente já leu junto. Estou de luto e nem sei por quê.",
    "Nunca comi páginas tão escuras com você. Recorde que ninguém queria.",
}
B.lembranca.leve_desde = {
    "Nada tão leve desde “{livro}”, em {mes}. Que alívio.",
    "Desde “{livro}”, em {mes}, eu não comia páginas tão doces.",
}
B.lembranca.mais_leve = {
    "O livro mais leve que a gente já leu junto. Desconfio.",
    "Nunca comi páginas tão doces com você. Vou ter cárie.",
}

return B
