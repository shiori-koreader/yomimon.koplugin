--[[--
Words of the books' compound name (English, Yomimon), used by yomimon_vector.lua. Same structure as
the Portuguese one; in English the adjectives have no gender (m and f are equal).
]]

return {
    names = {
        love = { "a love story", "m" },
        sea = { "a sea story", "m" },
        travel = { "a book of the road", "m" },
        fear = { "a tale of fear", "m" },
        death = { "a book about death", "m" },
        war = { "a war story", "m" },
        family = { "a family drama", "m" },
        money = { "a story about money", "m" },
        politics = { "a political intrigue", "m" },
        madness = { "a book about madness", "m" },
        revenge = { "a revenge story", "m" },
        science = { "a science adventure", "m" },
        faith = { "a book about faith and doubt", "m" },
        childhood = { "a childhood story", "m" },
        nature = { "a book of woods and beasts", "m" },
        animals = { "an animal story", "m" },
        night = { "a book of nights", "m" },
        city = { "a city story", "m" },
        food = { "a book of full tables", "m" },
        solitude = { "a book about solitude", "m" },
        art = { "a book about art", "m" },
        freedom = { "a story of freedom", "m" },
        knowledge = { "a book of ideas", "m" },
        time = { "a book about time", "m" },
    },
    play = { "a play about %s", "m" },
    short_theme = {
        death = "death", love = "love", war = "war", sea = "the sea", faith = "God", money = "money",
        madness = "madness", time = "time", city = "the city", nature = "the woods", food = "food",
        family = "family", childhood = "childhood", politics = "politics", science = "science", solitude = "solitude",
        art = "art", animals = "animals", night = "the night", travel = "the road", revenge = "revenge",
        freedom = "freedom", knowledge = "knowledge", fear = "fear",
    },
    adjectives = {
        gloomy = { m = "dark", f = "dark" },
        bright = { m = "bright", f = "bright" },
        speaker = { m = "talkative", f = "talkative" },
        quiet = { m = "quiet", f = "quiet" },
        restless = { m = "restless", f = "restless" },
        still = { m = "still", f = "still" },
    },
    e = " and ",
    smell = "with a whiff of %s",
    sentences = { long_ones = "in long sentences", shorts = "in short sentences" },
    first = { m = "told in the first person", f = "told in the first person" },
}
