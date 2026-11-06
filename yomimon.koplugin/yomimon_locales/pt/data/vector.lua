--[[--
Palavras do nome composto dos livros (português), usadas por yomimon_vector.lua (PLANO-VOZ.md, Etapa 3).
nomes[tema] = { texto, gênero do substantivo ("m"/"f") }: o começo do nome, pelo tema mais forte.
Os adjetivos concordam com o gênero. Nunca falar do leitor com adjetivo de gênero (aqui é o livro).
]]

return {
    nomes = {
        amor = { "um romance", "m" },
        mar = { "uma história de mar", "f" },
        viagem = { "um livro de estrada", "m" },
        medo = { "uma história de medo", "f" },
        morte = { "um livro sobre a morte", "m" },
        guerra = { "uma história de guerra", "f" },
        familia = { "um drama de família", "m" },
        dinheiro = { "uma história de dinheiro", "f" },
        politica = { "uma intriga política", "f" },
        loucura = { "um livro sobre a loucura", "m" },
        vinganca = { "uma história de vingança", "f" },
        ciencia = { "uma aventura de ciência", "f" },
        fe = { "um livro sobre fé e dúvida", "m" },
        infancia = { "uma história de infância", "f" },
        natureza = { "um livro de mato e bicho", "m" },
        animais = { "uma história de bichos", "f" },
        noite = { "um livro de noites", "m" },
        cidade = { "uma história de cidade", "f" },
        comida = { "um livro de mesa farta", "m" },
        solidao = { "um livro sobre a solidão", "m" },
        arte = { "um livro sobre arte", "m" },
        liberdade = { "uma história de liberdade", "f" },
        saber = { "um livro de ideias", "m" },
        tempo = { "um livro sobre o tempo", "m" },
    },
    -- teatro: "uma peça de política"
    peca = { "uma peça de %s", "f" },
    -- o tema sem artigo, para "com cheiro de …" e "uma peça de …"
    tema_curto = {
        morte = "morte", amor = "amor", guerra = "guerra", mar = "mar", fe = "fé", dinheiro = "dinheiro",
        loucura = "loucura", tempo = "tempo", cidade = "cidade", natureza = "mato", comida = "comida",
        familia = "família", infancia = "infância", politica = "política", ciencia = "ciência", solidao = "solidão",
        arte = "arte", animais = "bichos", noite = "noite", viagem = "estrada", vinganca = "vingança",
        liberdade = "liberdade", saber = "saber", medo = "medo",
    },
    adjetivos = {
        sombrio = { m = "sombrio", f = "sombria" },
        luminoso = { m = "luminoso", f = "luminosa" },
        falante = { m = "falante", f = "falante" },
        calado = { m = "calado", f = "calada" },
        agitado = { m = "agitado", f = "agitada" },
        parado = { m = "parado", f = "parada" },
    },
    e = " e ",
    cheiro = "com cheiro de %s",
    frases = { longas = "de frases longas", curtas = "de frases curtas" },
    primeira = { m = "contado em primeira pessoa", f = "contada em primeira pessoa" },
}
