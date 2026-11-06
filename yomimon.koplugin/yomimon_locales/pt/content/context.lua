-- Phrases with reading data.
return {
    small_hours = {
        young = {
            "São {hour}. A gente não devia estar dormindo? <nocturnal:Eu adoro essa hora.|Eu tô com medo do escuro e você lendo.>",
            "{hour} e você aqui. Tá tudo bem? Eu tô bem. Acho. Tô com sono.",
            "Ler às {hour} parece proibido. <fearful:Fiquei com medo.|nocturnal:Nosso horário favorito.|Gostei.>",
            "Às {hour} as letras ficam maiores. Ou meus olhos ficam menores.",
            "{hour}! Se alguém perguntar, a gente estava dormindo.<domain: Sonhando {place}.|>",
        },
        old = {
            "{hour}. Nada de bom foi lido depois da meia-noite. Exceto tudo o que presta.",
            "Lendo às {hour}. <nocturnal:A melhor hora, eu sempre disse.|diurnal:Isso não é hora de gente.|Amanhã você culpa o livro. Eu culpo você.>",
            "{hour} da madrugada. Eu com meu cigarro imaginário, você com a luz do Kindle. Dois vícios.",
            "{hour}. A hora em que toda frase parece verdade. Cuidado com o que sublinha.",
        },
    },
    record = {
        young = {
            "Nunca comi tanto num dia: {n} páginas. Minha barriga tá orgulhosa e assustada.",
            "Recorde de {n} páginas. Acho que cresci um milímetro.",
        },
        old = {
            "Novo recorde: {n} páginas num dia. Você está fugindo de alguma coisa?",
            "{n} páginas. Nunca comi tanto. Anote a data, que eu vou reclamar dela depois.",
        },
    },
    marathon = {
        young = {
            "{n} páginas hoje. <brave:Aguento mais cem.|Minha barriga tá redondinha.>",
            "Já foram {n} páginas! Eu não ando mais, só rolo.",
        },
        old = {
            "{n} páginas hoje. Minha barriga agradece; minha dignidade, nem tanto.",
            "{n} páginas. <erudite:Proust aprovaria. Talvez.|Isso não é leitura, é mudança de endereço.>",
            "Já são {n} páginas. Pisque. Beba água. Depois volte, claro.",
        },
    },
    vanished = {
        young = {
            "{n} dias sem papel. Contei cada hora. <fearful:Com medo de você não voltar.|Foram muitas.>",
            "{n} dias! De fome, quase comi minha própria sombra. <fearful:Ela me assustou.|brave:Lutei com ela.|domain:Tinha gosto de {taste}.|>",
        },
        old = {
            "{n} dias sem ler. <hopeful:Tudo bem, a gente recomeça.|A civilização caiu e ninguém me avisou?>",
            "{n} dias. Fiquei aqui, ruminando a orelha do livro<erudite: e uma tese|domain: e sonhando com {thing}|>.",
            "{n} dias sem você. <romantic:Senti sua falta. Pronto, falei.|Não vou perguntar onde estava. Estava sem ler, é o que importa.>",
        },
    },
    afternoon = {
        young = {
            "Já são {hour}. Só mais um capítulo, né? Eu sei como isso termina.",
            "<nocturnal:{hour}… tô de olhos bem abertos. Continua.|{hour}… meus olhinhos tão pesando, mas continua.>",
            "Ler às {hour} é tipo contar segredo. Baixinho.",
        },
        old = {
            "{hour}. A hora em que todo leitor jura que dorme depois deste capítulo.",
            "São {hour}. O livro não vai fugir. Você vai, de sono.",
            "{hour}. Ainda de olhos abertos <nocturnal:por gosto. A noite é minha|por sua causa. Não que eu me importe>.",
        },
    },
    early = {
        young = {
            "Lendo às {hour}? Antes do café? <diurnal:Adoro a manhã!|nocturnal:Eu nem dormi ainda.|Que coragem.>",
            "{hour} e já me dando comida. Que bom dia!",
            "Acordou cedo pra ler? Eu acordei cedo pra comer. Somos uma equipe.",
        },
        old = {
            "{hour}. Ler antes do café. <diurnal:A única ordem natural das coisas.|Não entendo, mas respeito.>",
            "São {hour}. Os pássaros cantam, você lê, eu como. A única ordem natural que aprovo.",
            "Leitura às {hour}. O dia nem começou e já está melhor que ontem.",
        },
    },
    session = {
        young = {
            "{n} páginas sem parar! Posso respirar?",
            "Você leu {n} páginas de uma vez. Tá tudo bem aí fora?",
            "{n} páginas seguidas. Esse livro te pegou. Me pegou também.",
        },
        old = {
            "{n} páginas seguidas. Ou o livro é bom, ou sua vida está pior.",
            "Uma sessão de {n} páginas. Os monges copistas aprovariam.",
        },
    },
    sequence = {
        young = {
            "{n} dias seguidos lendo! Tô me acostumando mal.",
            "Dia {n} seguido de comida. Acho que você gosta de mim.<domain: Hoje teve {taste}.|>",
            "{n} dias sem falhar. <romantic:Isso já é namoro.|hopeful:Vai virar cem.|Não para agora, tá?>",
        },
        old = {
            "{n} dias seguidos. Constância: a virtude mais chata e mais rara.",
            "{n} dias lendo sem falta. <hopeful:Acredito em você.|cynical:Vamos ver quanto dura.|Estou quase acreditando em você.>",
            "Dia {n} seguido. Não vou elogiar. Pronto, elogiei.",
        },
    },
    good_morning = {
        young = {
            "{n} páginas hoje. Tô ficando com a barriga cheinha.",
            "{n} páginas hoje. <bitter:Pelo menos isso.|Tá sendo um bom dia, né?>",
        },
        old = {
            "{n} páginas hoje. Respeitável. Não espetacular, mas respeitável.<domain: Com gosto de {taste}.|>",
            "{n} páginas hoje. Já dá pra chamar de leitura.",
            "{n} páginas. Um dia decente. <hopeful:Andam aparecendo mais.|Raros, os dias decentes.>",
        },
    },
    nothing_today = {
        young = {
            "Nenhuma página hoje… tudo bem, eu espero. Espero muito.",
            "Hoje ainda não comi nada. Nem uma vírgula.",
            "O dia tá acabando e o livro fechado. Fiquei olhando a capa.",
        },
        old = {
            "Nenhuma página hoje. O dia ainda não acabou. Mas está tentando.",
            "Hoje: zero páginas. Anotado no meu diário de decepções.",
            "O livro passou o dia fechado. Eu também, por dentro.",
        },
    },
    final_stretch = {
        young = {
            "{pct} de “{book}”. Tá acabando! Não quero que acabe!",
            "Reta final de “{book}”. <brave:Vou até o fim sem piscar.|fearful:Vou comer de olhos fechados.|Vou comer devagar pra durar.>",
            "Falta pouco pra acabar “{book}”. E depois, o que eu vou comer?",
        },
        old = {
            "{pct} de “{book}”. A reta final. <hopeful:É aqui que os bons autores brilham.|É aqui que os autores estragam tudo.>",
            "Quase no fim de “{book}”. Não me conte. Eu vou comer o final de qualquer jeito.",
            "Últimas páginas de “{book}”. Prepare-se para o vazio pós-livro. Eu já moro nele.",
        },
    },
    half = {
        young = {
            "Metade de “{book}”! Tá ficando bom. Ou ruim. Ainda não sei.",
            "Já comi metade de “{book}”. A outra metade tá me olhando.",
        },
        old = {
            "Metade de “{book}”. Daqui pra frente, ladeira abaixo.",
            "Meio de “{book}”. O ponto em que os autores costumam se perder.",
        },
    },
    start = {
        young = {
            "Começando “{book}”… cheira a {smell|papel novo}. Ou a problema.",
            "Primeiras páginas de “{book}”. <brave:Já tô com energia.|Já tô com frio na barriga.>",
        },
        old = {
            "Começo de “{book}”. Toda capa promete. Vamos ver o que cumpre.",
        },
    },
    weekend = {
        young = {
            "Fim de semana lendo! O melhor tipo de fim de semana.",
            "Fim de semana é dia de papel. Oba.",
        },
        old = {
            "Fim de semana e você lendo. Nada de festa? Ótimo. Festas são superestimadas.",
            "Fim de semana. O mundo sai, você lê. Escolha certa.",
        },
    },
}
