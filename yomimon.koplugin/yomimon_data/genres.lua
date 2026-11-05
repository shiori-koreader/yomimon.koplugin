-- Etiquetas de gênero do livro → influências (yomimon_data/influences.lua).
-- As etiquetas são o assunto do EPUB (dc:subject), que o KOReader guarda como "keywords" na informação do
-- livro: no Gutenberg, os assuntos da Biblioteca do Congresso ("Detective and mystery stories"); nas lojas,
-- os da BISAC ("FICTION / Mystery & Detective"). Livro sem etiqueta (MOBI, PDF, quase tudo baixado por aí)
-- segue só pelo texto.
-- Servem só de mapa: dizem de que gênero o livro é (yomimon_influences.lua, Infl.perfil). A influência continua
-- andando página a página, pelo que foi lido de verdade.
-- Cada linha: um trecho (minúsculas, sem acento) e as influências que ele indica. Em português, "romance" é
-- o gênero do livro, não o amor: fica de fora.
return {
    -- mistério e investigação
    { "detective", "misterio" }, { "mystery", "misterio" }, { "private investigator", "misterio" },
    -- (sem "murder" nem "theft": "Murder victims' families" é Hamlet, "Pet theft" é The Call of the Wild)
    { "police", "misterio" }, { "suspense", "misterio" },
    { "thriller", "misterio" }, { "policial", "misterio" }, { "investigac", "misterio" }, { "misterio", "misterio" },
    -- horror e gótico
    { "horror", "horror" }, { "ghost", "horror" }, { "vampire", "horror" }, { "gothic", "horror" },
    { "supernatural", "horror" }, { "paranormal", "horror" }, { "haunted", "horror" }, { "terror", "horror" },
    { "fantasma", "horror" }, { "vampir", "horror" }, { "gotic", "horror" }, { "sobrenatural", "horror" },
    -- aventura e exploração
    { "adventure", "aventura" }, { "sea stories", "aventura" }, { "voyages", "aventura" }, { "travelers", "aventura" },
    { "shipwreck", "aventura" }, { "pirates", "aventura" }, { "explor", "aventura" }, { "aventura", "aventura" },
    { "viagens", "aventura" }, { "pirata", "aventura" }, { "naufragio", "aventura" },
    -- fantasia épica
    { "fantasy", "epica" }, { "epic", "epica" }, { "imaginary wars", "epica" }, { "knights", "epica" },
    { "fantasia", "epica" }, { "epopeia", "epica" }, { "cavalaria", "epica" },
    -- mito e folclore
    { "mytholog", "mito" }, { "legends", "mito" },  -- "legends", não "legend": "(Legendary character)" é Hamlet, Lear { "folklore", "mito" }, { "fairy tales", "mito" },
    { "mitolog", "mito" }, { "lenda", "mito" }, { "folclore", "mito" }, { "contos de fada", "mito" },
    -- realismo mágico e fantástico
    { "magic realism", "magico" }, { "magical realism", "magico" }, { "fantastic fiction", "magico" },
    { "realismo magico", "magico" }, { "fantastico", "magico" },
    -- ficção científica e distopia
    { "science fiction", "ficcao" }, { "dystopia", "ficcao" }, { "utopia", "ficcao" }, { "time travel", "ficcao" },
    { "interplanetary", "ficcao" }, { "ficcao cientifica", "ficcao" }, { "distopia", "ficcao" },
    -- romance e drama afetivo
    { "love stories", "romance" }, { "romance fiction", "romance" }, { "courtship", "romance" },
    { "first loves", "romance" }, { "man-woman relationships", "romance" }, { "historia de amor", "romance" },
    { "romantic", "romance" }, { "romantico", "romance" },
    -- sátira e comédia
    { "satire", "satira" }, { "humorous", "satira" }, { "humor", "satira" }, { "comed", "satira" },
    { "satira", "satira" }, { "comedia", "satira" },
    -- tragédia
    { "traged", "tragedia" }, { "tragedia", "tragedia" },
    -- psicologia e introspecção
    { "psychological", "psicologia" }, { "psicologic", "psicologia" },
    -- realismo social
    { "social classes", "social" }, { "social conditions", "social" }, { "social problems", "social" },
    { "working class", "social" }, { "slums", "social" }, { "poor", "social" }, { "immigrants", "social" },
    { "pobreza", "social" }, { "operari", "social" },
    -- poesia e lirismo
    { "poetry", "poesia" }, { "poems", "poesia" }, { "sonnets", "poesia" }, { "poesia", "poesia" },
    { "poema", "poesia" }, { "soneto", "poesia" },
    -- filosofia e metafísica
    { "philosophy", "filosofia" }, { "ethics", "filosofia" }, { "metaphysics", "filosofia" },
    { "filosofia", "filosofia" }, { "metafisica", "filosofia" },
    -- existencialismo e absurdo
    { "existential", "existencial" }, { "absurd", "existencial" }, { "existencial", "existencial" },
    -- niilismo e ceticismo
    { "nihilism", "niilismo" }, { "pessimism", "niilismo" }, { "niilismo", "niilismo" }, { "pessimismo", "niilismo" },
}
