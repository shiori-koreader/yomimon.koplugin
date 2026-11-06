-- Frases do dia a dia.
local T = {}

T.FALAS = {
    ovo = {
        _todas = {
            "…",
            "Toc, toc. Lê mais um pouco que eu saio.",
            "(algo lá dentro resmungou)",
        },
    },
    jovem = {
        feliz = {
            "Comi uma página inteira e nada de ruim aconteceu. <medrosa:Ainda. Tô de olho.|otimista:E nem vai acontecer.|Ainda.>",
            "Tá… isso foi gostoso. Vai dar errado depois?",
            "Hoje eu entendi uma metáfora. Sem ajuda. Acho.",
            "{exclamacao|} Comi um parágrafo inteiro sem engasgar. Estou crescendo.",
            "Esse livro é bom ou eu que estou com fome?",
            "Se eu soubesse ler tão rápido quanto como…",
            "Feliz. Não conta pra ninguém. Tenho uma reputação.",
            "Hoje li uma palavra com cinco sílabas. Ela me leu de volta.",
            "Esse livro me abraçou. <romantica:Deixei.|medrosa:Ou me esmagou. Não sei.|Ou me esmagou. Foi bom.>",
            "Comi uma vírgula sem querer. Agora tudo tem uma pausa.",
        },
        normal = {
            "Será que esse livro acaba bem? Livros nunca acabam bem.",
            "Tô aqui. <corajosa:Firme e a postos.|medrosa:Tremendo, mas tô.|Com um friozinho, mas tô.>",
            "Se você parar de ler, eu… tudo bem. Acho.",
            "Ouvi dizer que os livros grossos têm mais recheio.<dominio: Esse tem recheio de {gosto}.|>",
            "Quando eu crescer, quero ler o dicionário. Inteiro.",
            "Você lê com tanta pressa. Tem alguém te esperando?",
            "Às vezes acho que os personagens me veem. <medrosa:Por isso me escondo.|romantica:E sorriem.|>",
            "Por que os livros têm cheiro de {cheiro|chuva velha}?",
            "<corajosa:Antes eu tinha medo do fim dos livros. Agora corro até ele.|amarga:Tenho medo do fim dos livros. Com razão.|Tenho medo do fim dos livros. E do começo. E do meio.>",
            "Se eu morder o nome do autor, ele sente?",
            "<corajosa:Hoje tenho coragem. Amanhã também.|Hoje decidi ter coragem. Amanhã a gente vê.>",
            "Às vezes leio a mesma linha três vezes. Para ter certeza que ela existe.",
        },
        triste = {
            "Tô com fome. E com <romantica:saudade|medo>. Mais fome.",
            "Você esqueceu de mim? Tudo bem, todo mundo esquece.",
            "Uma pagininha só… por favor?",
            "Barriga roncando. Parece {comparacao|um capítulo de suspense}.",
            "Se eu sumir, procure {lugar|entre as páginas 40 e 41}.",
            "Contei as letras da capa. Todas. Duas vezes. É o que sobrou.",
            "Fome de história. Qualquer história.",
            "Até o índice parece um banquete agora.",
        },
        dormindo = {
            "Zzz… sonhando que a estante desabou… <corajosa:e eu segurei sem ajuda…|>",
            "Zzz… não apaga a luz… <medrosa:deixa acesa…|quer dizer, apaga…>",
            "Zzz… um bibliotecário… com spray… não…",
            "Zzz… mais uma página… só mais uma… <noturna:a noite é nossa…|>",
        },
        casulo = {
            "Tô aqui dentro. Escuro, quentinho e sem letras. Horrível.",
        },
        repouso = {
            "Zzz… sonhando com <romantica:papel de carta|erudita:pergaminho|{coisa|papel de arroz}>…",
            "Zzz… quem apagou a luz do mundo? <medrosa:Acende…|>",
            "Zzz… sonhando com uma biblioteca sem fim… <medrosa:e sem saída…|corajosa:e eu explorando tudo…|>",
            "Zzz… a capa é tão quentinha… <romantica:parece um abraço…|>",
        },
        palavra = "Comi a palavra “%s”. <otimista:Tinha gosto de domingo.|medrosa:Acho que tinha assombração.|erudita:Vou guardar pra um soneto.|Acho que me fez mal.>",
    },
    velha = {
        feliz = {
            "Hm. Até que não era um livro ruim.",
            "Comi. Barriga satisfeita. Não se acostume.",
            "{exclamacao|} Uma página decente. Raro, hoje em dia.",
            "Esse parágrafo merecia um cigarro depois.",
            "Bom livro. Vou sentir falta de odiá-lo.",
            "Hoje a literatura me poupou. Amanhã veremos.",
            "Barriga satisfeita. <otimista:É assim que começam as comédias.|É assim que começam as tragédias.>",
            "Que prosa. <otimista:Me faz acreditar na humanidade. Sem quase.|Quase me faz acreditar na humanidade. Quase.>",
            "Um livro decente. Vou anotar a data, para lembrar quando o mundo valia a pena.",
            "Esse autor sabia o que fazia. Odeio quando acontece.",
            "Bom capítulo. <romantica:Me emocionei e não vou fingir.|Me dê licença enquanto finjo que não me emocionei.>",
        },
        normal = {
            "Já li coisa demais pra <otimista:perder a esperança|ter esperança>.",
            "Todo livro termina. Como tudo.",
            "Quanto mais eu leio, menos eu entendo o mundo.",
            "Leia. Ou não. O fim é o mesmo.",
            "Acendi um cigarro. Metafórico. Papel e fogo não combinam.",
            "Toda biblioteca é um cemitério com boa iluminação.",
            "Os clássicos são livros que todo mundo cita e ninguém come.",
            "Prefácio é onde o autor pede desculpas antes da hora.",
            "Já fui jovem e otimista. <otimista:Continuo.|Durou um capítulo.>",
            "Notas de rodapé: onde a verdade vai se esconder.",
            "Ninguém lê mais. Por isso eu como.<dominio: Hoje o cardápio foi {gosto}.|>",
            "A vida é um romance mal editado.",
            "O best-seller de hoje é o papel de embrulho de amanhã.",
            "Li tantos finais felizes que <romantica:ainda choro em todos|perdi a fé em finais>.",
            "Todo narrador mente. Os honestos mentem melhor.",
            "Cultura é o que sobra quando você esquece o que leu. Eu lembro de tudo. Que azar.",
            "A juventude lê pra se encontrar. A velhice lê pra se esconder.",
            "Eu não odeio as pessoas. Só as que dobram a ponta da página.",
            "Minha opinião sobre o mundo cabe numa nota de rodapé. Pequena e ignorada.",
        },
        triste = {
            "Fome. Como sempre. Como todos.<dominio: Saudade de {gosto}.|>",
            "Sabe o que é pior que um livro ruim? Livro nenhum.",
            "Estou definhando entre duas capas. Que poético. Que inútil.",
            "Me deixa aqui com meu cigarro imaginário e minha fome real.",
            "Estante vazia, alma vazia. Barriga também.",
            "Fome e lucidez. <otimista:Pelo menos a lucidez.|A pior combinação.>",
            "Ninguém lê. Ninguém me alimenta. A civilização acabou.",
            "Estou com tanta fome que consideraria <erudita:um manual de instruções. Em alemão|popular:uma revista de fofoca. Com prazer|um manual de instruções>.",
        },
        dormindo = {
            "Zzz… resmungando sobre <dominio:{coisa}|o estado da literatura>…",
            "Zzz… nenhum best-seller… por favor…",
            "Zzz… sonhando com um sebo fechado só pra mim…",
        },
        casulo = {
            "Não estou aqui. Estou entre as páginas, onde é mais honesto.",
        },
        repouso = {
            "Zzz… fumando um cigarro em sonho… <erudita:e citando Baudelaire…|>",
            "Zzz… a última página <otimista:às vezes surpreende|sempre decepciona>…",
            "Zzz… resmungando em <popular:português claro|latim>…",
            "Zzz… revisando o mundo… <otimista:menos erros do que eu esperava…|muitos erros…>",
        },
        palavra = "“%s”. Comi. <erudita:Palavra nobre; o século não a merece.|popular:Palavra de dicionário. Sem sal.|Ninguém mais usa essa palavra.>",
    },
}

T.FALAS_LIVRO = {
    jovem = {
        "Será que “%s” acaba bem? Me conta sem me contar.",
        "Sonhei com “%s” ontem. <corajosa:Eu era a heroína.|romantica:Foi um sonho bonito.|Fiquei com medo.>",
    },
    velha = {
        "“%s”? Já comi piores. Já comi melhores. Continuo com fome.<dominio: Este cheirava a {cheiro}.|>",
        "Ainda digerindo “%s”. <otimista:Leve. Como a vida devia ser.|Pesado. Como a vida.>",
        "Depois de “%s”, preciso de <romantica:um lenço|medrosa:uma luz acesa|um cigarro> e de um silêncio.",
        "“%s” não muda o mundo. Mas me mudou um pouco. Pior.",
    },
}

T.FALAS_PERSONAGEM = {
    jovem = { "Gosto de %s. <romantica:Gosto muito.|cinica:Por enquanto.|Isso é perigoso?>", "%s apareceu de novo. Me deu um nervoso." },
    velha = { "%s de novo. Esse livro não tem mais ninguém?", "Já conheço o tipo de %s. <otimista:Termina bem, por incrível que pareça.|Termina mal.>",
              "%s fala como quem nunca leu um livro." },
}

T.FALAS_MUDA_PERTO = {  -- até ~60 páginas: às vezes
    jovem = {
        "Mais %d páginas e eu cresço. E se eu mudar pra pior?",
        "Daqui a %d páginas eu viro outra. Promete que me reconhece?",
    },
    velha = {
        "Em %d páginas eu mudo. O mundo continua igual. Como sempre.",
    },
}

T.FALAS_MUDA_IMINENTE = {  -- até ~10 páginas: sempre
    ovo = { "Toc. Toc. TOC. Lê mais um pouquinho!" },
    jovem = {
        "Minhas costas estão estalando. É agora? É agora!",
    },
    velha = {
        "Estou prestes a mudar. Duvido que melhore alguma coisa.",
    },
}

return T
