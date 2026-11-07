-- Day-to-day phrases.
local T = {}

T.SPEECHES = {
    egg = {
        _all = {
            "…",
            "Toc, toc. Lê mais um pouco que eu saio.",
            "(algo lá dentro resmungou)",
        },
    },
    young = {
        happy = {
            "Comi uma página inteira e nada de ruim aconteceu. <fearful:Ainda. Tô de olho.|hopeful:E nem vai acontecer.|Ainda.>",
            "Tá… isso foi gostoso. Vai dar errado depois?",
            "Hoje eu entendi uma metáfora. Sem ajuda. Acho.",
            "{exclamation|} Comi um parágrafo inteiro sem engasgar. Estou crescendo.",
            "Esse livro é bom ou eu que estou com fome?",
            "Se eu soubesse ler tão rápido quanto como…",
            "Feliz. Não conta pra ninguém. Tenho uma reputação.",
            "Hoje li uma palavra com cinco sílabas. Ela me leu de volta.",
            "Esse livro me abraçou. <romantic:Deixei.|fearful:Ou me esmagou. Não sei.|Ou me esmagou. Foi bom.>",
            "Comi uma vírgula sem querer. Agora tudo tem uma pausa.",
        },
        normal = {
            "Será que esse livro acaba bem? Livros nunca acabam bem.",
            "Tô aqui. <brave:Firme e a postos.|fearful:Tremendo, mas tô.|Com um friozinho, mas tô.>",
            "Se você parar de ler, eu… tudo bem. Acho.",
            "Ouvi dizer que os livros grossos têm mais recheio.<domain: Esse tem recheio de {taste}.|>",
            "Quando eu crescer, quero ler o dicionário. Inteiro.",
            "Você lê com tanta pressa. Tem alguém te esperando?",
            "Às vezes acho que os personagens me veem. <fearful:Por isso me escondo.|romantic:E sorriem.|>",
            "Por que os livros têm cheiro de {smell|chuva velha}?",
            "<brave:Antes eu tinha medo do fim dos livros. Agora corro até ele.|bitter:Tenho medo do fim dos livros. Com razão.|Tenho medo do fim dos livros. E do começo. E do meio.>",
            "Se eu morder o nome do autor, ele sente?",
            "<brave:Hoje tenho coragem. Amanhã também.|Hoje decidi ter coragem. Amanhã a gente vê.>",
            "Às vezes leio a mesma linha três vezes. Para ter certeza que ela existe.",
        },
        sad = {
            "Tô com fome. E com <romantic:saudade|medo>. Mais fome.",
            "Você esqueceu de mim? Tudo bem, todo mundo esquece.",
            "Uma pagininha só… por favor?",
            "Barriga roncando. Parece {comparison|um capítulo de suspense}.",
            "Se eu sumir, procure {place|entre as páginas 40 e 41}.",
            "Contei as letras da capa. Todas. Duas vezes. É o que sobrou.",
            "Fome de história. Qualquer história.",
            "Até o índice parece um banquete agora.",
        },
        sleeping = {
            "Zzz… sonhando que a estante desabou… <brave:e eu segurei sem ajuda…|>",
            "Zzz… não apaga a luz… <fearful:deixa acesa…|quer dizer, apaga…>",
            "Zzz… um bibliotecário… com spray… não…",
            "Zzz… mais uma página… só mais uma… <nocturnal:a noite é nossa…|>",
        },
        cocoon = {
            "Tô aqui dentro. Escuro, quentinho e sem letras. Horrível.",
        },
        sleepRest = {
            "Zzz… sonhando com <romantic:papel de carta|erudite:pergaminho|{thing|papel de arroz}>…",
            "Zzz… quem apagou a luz do mundo? <fearful:Acende…|>",
            "Zzz… sonhando com uma biblioteca sem fim… <fearful:e sem saída…|brave:e eu explorando tudo…|>",
            "Zzz… a capa é tão quentinha… <romantic:parece um abraço…|>",
        },
        word = "Comi a palavra “%s”. <hopeful:Tinha gosto de domingo.|fearful:Acho que tinha assombração.|erudite:Vou guardar pra um soneto.|Acho que me fez mal.>",
    },
    old = {
        happy = {
            "Hm. Até que não era um livro ruim.",
            "Comi. Barriga satisfeita. Não se acostume.",
            "{exclamation|} Uma página decente. Raro, hoje em dia.",
            "Esse parágrafo merecia um cigarro depois.",
            "Bom livro. Vou sentir falta de odiá-lo.",
            "Hoje a literatura me poupou. Amanhã veremos.",
            "Barriga satisfeita. <hopeful:É assim que começam as comédias.|É assim que começam as tragédias.>",
            "Que prosa. <hopeful:Me faz acreditar na humanidade. Sem quase.|Quase me faz acreditar na humanidade. Quase.>",
            "Um livro decente. Vou anotar a data, para lembrar quando o mundo valia a pena.",
            "Esse autor sabia o que fazia. Odeio quando acontece.",
            "Bom capítulo. <romantic:Me emocionei e não vou fingir.|Me dê licença enquanto finjo que não me emocionei.>",
        },
        normal = {
            "Já li coisa demais pra <hopeful:perder a esperança|ter esperança>.",
            "Todo livro termina. Como tudo.",
            "Quanto mais eu leio, menos eu entendo o mundo.",
            "Leia. Ou não. O fim é o mesmo.",
            "Acendi um cigarro. Metafórico. Papel e fogo não combinam.",
            "Toda biblioteca é um cemitério com boa iluminação.",
            "Os clássicos são livros que todo mundo cita e ninguém come.",
            "Prefácio é onde o autor pede desculpas antes da hora.",
            "Já fui jovem e otimista. <hopeful:Continuo.|Durou um capítulo.>",
            "Notas de rodapé: onde a verdade vai se esconder.",
            "Ninguém lê mais. Por isso eu como.<domain: Hoje o cardápio foi {taste}.|>",
            "A vida é um romance mal editado.",
            "O best-seller de hoje é o papel de embrulho de amanhã.",
            "Li tantos finais felizes que <romantic:ainda choro em todos|perdi a fé em finais>.",
            "Todo narrador mente. Os honestos mentem melhor.",
            "Cultura é o que sobra quando você esquece o que leu. Eu lembro de tudo. Que azar.",
            "A juventude lê pra se encontrar. A velhice lê pra se esconder.",
            "Eu não odeio as pessoas. Só as que dobram a ponta da página.",
            "Minha opinião sobre o mundo cabe numa nota de rodapé. Pequena e ignorada.",
        },
        sad = {
            "Fome. Como sempre. Como todos.<domain: Saudade de {taste}.|>",
            "Sabe o que é pior que um livro ruim? Livro nenhum.",
            "Estou definhando entre duas capas. Que poético. Que inútil.",
            "Me deixa aqui com meu cigarro imaginário e minha fome real.",
            "Estante vazia, alma vazia. Barriga também.",
            "Fome e lucidez. <hopeful:Pelo menos a lucidez.|A pior combinação.>",
            "Ninguém lê. Ninguém me alimenta. A civilização acabou.",
            "Estou com tanta fome que consideraria <erudite:um manual de instruções. Em alemão|popular:uma revista de fofoca. Com prazer|um manual de instruções>.",
        },
        sleeping = {
            "Zzz… resmungando sobre <domain:{thing}|o estado da literatura>…",
            "Zzz… nenhum best-seller… por favor…",
            "Zzz… sonhando com um sebo fechado só pra mim…",
        },
        cocoon = {
            "Não estou aqui. Estou entre as páginas, onde é mais honesto.",
        },
        sleepRest = {
            "Zzz… fumando um cigarro em sonho… <erudite:e citando Baudelaire…|>",
            "Zzz… a última página <hopeful:às vezes surpreende|sempre decepciona>…",
            "Zzz… resmungando em <popular:português claro|latim>…",
            "Zzz… revisando o mundo… <hopeful:menos erros do que eu esperava…|muitos erros…>",
        },
        word = "“%s”. Comi. <erudite:Palavra nobre; o século não a merece.|popular:Palavra de dicionário. Sem sal.|Ninguém mais usa essa palavra.>",
    },
}

T.SPEECHES_BOOK = {
    young = {
        "Será que “%s” acaba bem? Me conta sem me contar.",
        "Sonhei com “%s” ontem. <brave:Eu salvava o dia.|romantic:Foi um sonho bonito.|Fiquei com medo.>",
    },
    old = {
        "“%s”? Já comi piores. Já comi melhores. Continuo com fome.<domain: Este cheirava a {smell}.|>",
        "Ainda digerindo “%s”. <hopeful:Leve. Como a vida devia ser.|Pesado. Como a vida.>",
        "Depois de “%s”, preciso de <romantic:um lenço|fearful:uma luz acesa|um cigarro> e de um silêncio.",
        "“%s” não muda o mundo. Mas me mudou um pouco. Pior.",
    },
}

T.SPEECHES_CHARACTER = {
    young = { "Gosto de %s. <romantic:Gosto muito.|cynical:Por enquanto.|Isso é perigoso?>", "%s apareceu de novo. Me deu um nervoso." },
    old = { "%s de novo. Esse livro não tem mais ninguém?", "Já conheço o tipo de %s. <hopeful:Termina bem, por incrível que pareça.|Termina mal.>",
              "%s fala como quem nunca leu um livro." },
}

T.SPEECHES_NEXT_FORM_NEAR = {  -- up to ~60 pages: sometimes
    young = {
        "Mais %d páginas e eu cresço. E se eu mudar pra pior?",
        "Daqui a %d páginas eu viro outra. Promete que me reconhece?",
    },
    old = {
        "Em %d páginas eu mudo. O mundo continua igual. Como sempre.",
    },
}

T.SPEECHES_NEXT_FORM_IMMINENT = {  -- up to ~10 pages: always
    egg = { "Toc. Toc. TOC. Lê mais um pouquinho!" },
    young = {
        "Minhas costas estão estalando. É agora? É agora!",
    },
    old = {
        "Estou prestes a mudar. Duvido que melhore alguma coisa.",
    },
}

return T
