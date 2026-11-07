--[[--
Words of the books' compound name (Portuguese), used by yomimon_vector.lua.
names[theme] = { text, noun gender ("m"/"f") }: the start of the name, by the strongest theme.
The adjectives agree with the gender. Never describe the reader with a gendered adjective (here it is the book).
]]

return {
    names = {
        love = { "um romance", "m" },
        sea = { "uma história de mar", "f" },
        travel = { "um livro de estrada", "m" },
        fear = { "uma história de medo", "f" },
        death = { "um livro sobre a morte", "m" },
        war = { "uma história de guerra", "f" },
        family = { "um drama de família", "m" },
        money = { "uma história de dinheiro", "f" },
        politics = { "uma intriga política", "f" },
        madness = { "um livro sobre a loucura", "m" },
        revenge = { "uma história de vingança", "f" },
        science = { "uma aventura de ciência", "f" },
        faith = { "um livro sobre fé e dúvida", "m" },
        childhood = { "uma história de infância", "f" },
        nature = { "um livro de mato e bicho", "m" },
        animals = { "uma história de bichos", "f" },
        night = { "um livro de noites", "m" },
        city = { "uma história de cidade", "f" },
        food = { "um livro de mesa farta", "m" },
        solitude = { "um livro sobre a solidão", "m" },
        art = { "um livro sobre arte", "m" },
        freedom = { "uma história de liberdade", "f" },
        knowledge = { "um livro de ideias", "m" },
        time = { "um livro sobre o tempo", "m" },
    },
    -- theatre: "uma peça de política"
    play = { "uma peça de %s", "f" },
    -- the theme without an article, for "com cheiro de …" and "uma peça de …"
    short_theme = {
        death = "morte", love = "amor", war = "guerra", sea = "mar", faith = "fé", money = "dinheiro",
        madness = "loucura", time = "tempo", city = "cidade", nature = "mato", food = "comida",
        family = "família", childhood = "infância", politics = "política", science = "ciência", solitude = "solidão",
        art = "arte", animals = "bichos", night = "noite", travel = "estrada", revenge = "vingança",
        freedom = "liberdade", knowledge = "saber", fear = "medo",
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
