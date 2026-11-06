-- Book genre tags → influences (yomimon_data/influences.lua).
-- The tags are the EPUB subject (dc:subject), which KOReader keeps as "keywords" in the book information:
-- on Gutenberg, the Library of Congress subjects ("Detective and mystery stories"); in shops,
-- the BISAC ones ("FICTION / Mystery & Detective"). A book without tags (MOBI, PDF, almost everything downloaded
-- around) follows only the text.
-- They only serve as a map: they say which genre the book is (yomimon_influences.lua, Infl.perfil). The influence still
-- moves page by page, by what was really read.
-- Each line: a fragment (lowercase, no accents) and the influences it indicates. In Portuguese, "romance" is
-- the book's genre, not love: it stays out.
return {
    -- mystery and investigation
    { "detective", "misterio" }, { "mystery", "misterio" }, { "private investigator", "misterio" },
    -- (without "murder" or "theft": "Murder victims' families" is Hamlet, "Pet theft" is The Call of the Wild)
    { "police", "misterio" }, { "suspense", "misterio" },
    { "thriller", "misterio" }, { "policial", "misterio" }, { "investigac", "misterio" }, { "misterio", "misterio" },
    -- horror and gothic
    { "horror", "horror" }, { "ghost", "horror" }, { "vampire", "horror" }, { "gothic", "horror" },
    { "supernatural", "horror" }, { "paranormal", "horror" }, { "haunted", "horror" }, { "terror", "horror" },
    { "fantasma", "horror" }, { "vampir", "horror" }, { "gotic", "horror" }, { "sobrenatural", "horror" },
    -- adventure and exploration
    { "adventure", "aventura" }, { "sea stories", "aventura" }, { "voyages", "aventura" }, { "travelers", "aventura" },
    { "shipwreck", "aventura" }, { "pirates", "aventura" }, { "explor", "aventura" }, { "aventura", "aventura" },
    { "viagens", "aventura" }, { "pirata", "aventura" }, { "naufragio", "aventura" },
    -- epic fantasy
    { "fantasy", "epica" }, { "epic", "epica" }, { "imaginary wars", "epica" }, { "knights", "epica" },
    { "fantasia", "epica" }, { "epopeia", "epica" }, { "cavalaria", "epica" },
    -- myth and folklore
    { "mytholog", "mito" }, { "legends", "mito" },  -- "legends", não "legend": "(Legendary character)" é Hamlet, Lear { "folklore", "mito" }, { "fairy tales", "mito" },
    { "mitolog", "mito" }, { "lenda", "mito" }, { "folclore", "mito" }, { "contos de fada", "mito" },
    -- magical and fantastic realism
    { "magic realism", "magico" }, { "magical realism", "magico" }, { "fantastic fiction", "magico" },
    { "realismo magico", "magico" }, { "fantastico", "magico" },
    -- science fiction and dystopia
    { "science fiction", "ficcao" }, { "dystopia", "ficcao" }, { "utopia", "ficcao" }, { "time travel", "ficcao" },
    { "interplanetary", "ficcao" }, { "ficcao cientifica", "ficcao" }, { "distopia", "ficcao" },
    -- romance and emotional drama
    { "love stories", "romance" }, { "romance fiction", "romance" }, { "courtship", "romance" },
    { "first loves", "romance" }, { "man-woman relationships", "romance" }, { "historia de amor", "romance" },
    { "romantic", "romance" }, { "romantico", "romance" },
    -- satire and comedy
    { "satire", "satira" }, { "humorous", "satira" }, { "humor", "satira" }, { "comed", "satira" },
    { "satira", "satira" }, { "comedia", "satira" },
    -- tragedy
    { "traged", "tragedia" }, { "tragedia", "tragedia" },
    -- psychology and introspection
    { "psychological", "psicologia" }, { "psicologic", "psicologia" },
    -- social realism
    { "social classes", "social" }, { "social conditions", "social" }, { "social problems", "social" },
    { "working class", "social" }, { "slums", "social" }, { "poor", "social" }, { "immigrants", "social" },
    { "pobreza", "social" }, { "operari", "social" },
    -- poetry and lyricism
    { "poetry", "poesia" }, { "poems", "poesia" }, { "sonnets", "poesia" }, { "poesia", "poesia" },
    { "poema", "poesia" }, { "soneto", "poesia" },
    -- philosophy and metaphysics
    { "philosophy", "filosofia" }, { "ethics", "filosofia" }, { "metaphysics", "filosofia" },
    { "filosofia", "filosofia" }, { "metafisica", "filosofia" },
    -- existentialism and the absurd
    { "existential", "existencial" }, { "absurd", "existencial" }, { "existencial", "existencial" },
    -- nihilism and scepticism
    { "nihilism", "niilismo" }, { "pessimism", "niilismo" }, { "niilismo", "niilismo" }, { "pessimismo", "niilismo" },
}
