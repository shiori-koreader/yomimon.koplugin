--[[--
Palavras do nome composto dos livros (inglês, Yomimon), usadas por yomimon_vector.lua. Mesma estrutura de
vetor_pt.lua; em inglês os adjetivos não têm gênero (m e f iguais).
]]

return {
    nomes = {
        amor = { "a love story", "m" },
        mar = { "a sea story", "m" },
        viagem = { "a book of the road", "m" },
        medo = { "a tale of fear", "m" },
        morte = { "a book about death", "m" },
        guerra = { "a war story", "m" },
        familia = { "a family drama", "m" },
        dinheiro = { "a story about money", "m" },
        politica = { "a political intrigue", "m" },
        loucura = { "a book about madness", "m" },
        vinganca = { "a revenge story", "m" },
        ciencia = { "a science adventure", "m" },
        fe = { "a book about faith and doubt", "m" },
        infancia = { "a childhood story", "m" },
        natureza = { "a book of woods and beasts", "m" },
        animais = { "an animal story", "m" },
        noite = { "a book of nights", "m" },
        cidade = { "a city story", "m" },
        comida = { "a book of full tables", "m" },
        solidao = { "a book about solitude", "m" },
        arte = { "a book about art", "m" },
        liberdade = { "a story of freedom", "m" },
        saber = { "a book of ideas", "m" },
        tempo = { "a book about time", "m" },
    },
    peca = { "a play about %s", "m" },
    tema_curto = {
        morte = "death", amor = "love", guerra = "war", mar = "the sea", fe = "God", dinheiro = "money",
        loucura = "madness", tempo = "time", cidade = "the city", natureza = "the woods", comida = "food",
        familia = "family", infancia = "childhood", politica = "politics", ciencia = "science", solidao = "solitude",
        arte = "art", animais = "animals", noite = "the night", viagem = "the road", vinganca = "revenge",
        liberdade = "freedom", saber = "knowledge", medo = "fear",
    },
    adjetivos = {
        sombrio = { m = "dark", f = "dark" },
        luminoso = { m = "bright", f = "bright" },
        falante = { m = "talkative", f = "talkative" },
        calado = { m = "quiet", f = "quiet" },
        agitado = { m = "restless", f = "restless" },
        parado = { m = "still", f = "still" },
    },
    e = " and ",
    cheiro = "with a whiff of %s",
    frases = { longas = "in long sentences", curtas = "in short sentences" },
    primeira = { m = "told in the first person", f = "told in the first person" },
}
