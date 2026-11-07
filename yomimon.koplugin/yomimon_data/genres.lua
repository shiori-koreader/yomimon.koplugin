-- Book genre tags → influences (yomimon_data/influences.lua).
-- The tags are the EPUB subject (dc:subject), which KOReader keeps as "keywords" in the book information:
-- on Gutenberg, the Library of Congress subjects ("Detective and mystery stories"); in shops,
-- the BISAC ones ("FICTION / Mystery & Detective"). A book without tags (MOBI, PDF, almost everything downloaded
-- around) follows only the text.
-- They only serve as a map: they say which genre the book is (yomimon_influences.lua, Infl.profile). The influence still
-- moves page by page, by what was really read.
-- Each line: a fragment (lowercase, no accents) and the influences it indicates. In Portuguese, "romance" is
-- the book's genre, not love: it stays out.
return {
    -- mystery and investigation
    { "detective", "mystery" }, { "mystery", "mystery" }, { "private investigator", "mystery" },
    -- (without "murder" or "theft": "Murder victims' families" is Hamlet, "Pet theft" is The Call of the Wild)
    { "police", "mystery" }, { "suspense", "mystery" },
    { "thriller", "mystery" }, { "policial", "mystery" }, { "investigac", "mystery" }, { "misterio", "mystery" },
    -- horror and gothic
    { "horror", "horror" }, { "ghost", "horror" }, { "vampire", "horror" }, { "gothic", "horror" },
    { "supernatural", "horror" }, { "paranormal", "horror" }, { "haunted", "horror" }, { "terror", "horror" },
    { "fantasma", "horror" }, { "vampir", "horror" }, { "gotic", "horror" }, { "sobrenatural", "horror" },
    -- adventure and exploration
    { "adventure", "adventure" }, { "sea stories", "adventure" }, { "voyages", "adventure" }, { "travelers", "adventure" },
    { "shipwreck", "adventure" }, { "pirates", "adventure" }, { "explor", "adventure" }, { "aventura", "adventure" },
    { "viagens", "adventure" }, { "pirata", "adventure" }, { "naufragio", "adventure" },
    -- epic fantasy
    { "fantasy", "epic" }, { "epic", "epic" }, { "imaginary wars", "epic" }, { "knights", "epic" },
    { "fantasia", "epic" }, { "epopeia", "epic" }, { "cavalaria", "epic" },
    -- myth and folklore
    -- "legends", not "legend": "(Legendary character)" is Hamlet, Lear
    { "mytholog", "myth" }, { "legends", "myth" }, { "folklore", "myth" }, { "fairy tales", "myth" },
    { "mitolog", "myth" }, { "lenda", "myth" }, { "folclore", "myth" }, { "contos de fada", "myth" },
    -- magical and fantastic realism
    { "magic realism", "magical" }, { "magical realism", "magical" }, { "fantastic fiction", "magical" },
    { "realismo magico", "magical" }, { "fantastico", "magical" },
    -- science fiction and dystopia
    { "science fiction", "science_fiction" }, { "dystopia", "science_fiction" }, { "utopia", "science_fiction" }, { "time travel", "science_fiction" },
    { "interplanetary", "science_fiction" }, { "ficcao cientifica", "science_fiction" }, { "distopia", "science_fiction" },
    -- romance and emotional drama
    { "love stories", "romance" }, { "romance fiction", "romance" }, { "courtship", "romance" },
    { "first loves", "romance" }, { "man-woman relationships", "romance" }, { "historia de amor", "romance" },
    { "romantic", "romance" }, { "romantico", "romance" },
    -- satire and comedy
    { "satire", "satire" }, { "humorous", "satire" }, { "humor", "satire" }, { "comed", "satire" },
    { "satira", "satire" }, { "comedia", "satire" },
    -- tragedy
    { "traged", "tragedy" }, { "tragedia", "tragedy" },
    -- psychology and introspection
    { "psychological", "psychology" }, { "psicologic", "psychology" },
    -- social realism
    { "social classes", "social" }, { "social conditions", "social" }, { "social problems", "social" },
    { "working class", "social" }, { "slums", "social" }, { "poor", "social" }, { "immigrants", "social" },
    { "pobreza", "social" }, { "operari", "social" },
    -- poetry and lyricism
    { "poetry", "poetry" }, { "poems", "poetry" }, { "sonnets", "poetry" }, { "poesia", "poetry" },
    { "poema", "poetry" }, { "soneto", "poetry" },
    -- philosophy and metaphysics
    { "philosophy", "philosophy" }, { "ethics", "philosophy" }, { "metaphysics", "philosophy" },
    { "filosofia", "philosophy" }, { "metafisica", "philosophy" },
    -- existentialism and the absurd
    { "existential", "existential" }, { "absurd", "existential" }, { "existencial", "existential" },
    -- nihilism and scepticism
    { "nihilism", "nihilism" }, { "pessimism", "nihilism" }, { "niilismo", "nihilism" }, { "pessimismo", "nihilism" },
}
