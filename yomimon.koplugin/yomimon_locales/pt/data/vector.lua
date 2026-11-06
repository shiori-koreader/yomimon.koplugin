--[[--
Words of the books' compound name (Portuguese), used by yomimon_vector.lua (PLANO-VOZ.md, step 3).
names[theme] = { text, noun gender ("m"/"f") }: the start of the name, by the strongest theme.
The adjectives agree with the gender. Never describe the reader with a gendered adjective (here it is the book).
]]

return {
    names = {
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
    -- theatre: "uma peça de política"
    play = { "uma peça de %s", "f" },
    -- the theme without an article, for "com cheiro de …" and "uma peça de …"
    short_theme = {
        morte = "morte", amor = "amor", guerra = "guerra", mar = "mar", fe = "fé", dinheiro = "dinheiro",
        loucura = "loucura", tempo = "tempo", cidade = "cidade", natureza = "mato", comida = "comida",
        familia = "família", infancia = "infância", politica = "política", ciencia = "ciência", solidao = "solidão",
        arte = "arte", animais = "bichos", noite = "noite", viagem = "estrada", vinganca = "vingança",
        liberdade = "liberdade", saber = "saber", medo = "medo",
    },
    adjectives = {
        gloomy = { m = "gloomy", f = "sombria" },
        bright = { m = "bright", f = "luminosa" },
        speaker = { m = "speaker", f = "speaker" },
        quiet = { m = "quiet", f = "calada" },
        restless = { m = "restless", f = "agitada" },
        still = { m = "still", f = "parada" },
    },
    e = " e ",
    smell = "com cheiro de %s",
    sentences = { long_ones = "de frases longas", shorts = "de frases curtas" },
    first = { m = "contado em primeira pessoa", f = "contada em primeira pessoa" },
}
