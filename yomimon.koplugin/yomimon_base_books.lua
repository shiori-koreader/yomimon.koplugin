-- What an average book is like (generated offline from the simulation corpus).
-- Corpus: the 30 public-domain books of the simulation; each book is a sample.
-- weather: average sentiment per page, by language. dialogue: dialogue marks per page; events: events
-- per page; sentence: words per sentence (the last three without the plays).
return {
    weather = { en = { media = 0.063, deviation = 0.614, n = 24 }, pt = { media = -0.064, deviation = 0.317, n = 6 } },
    dialogue = { media = 4.443, deviation = 2.123, n = 27 },
    events = { media = 0.382, deviation = 0.195, n = 27 },
    sentence = { media = 14.166, deviation = 2.548, n = 27 },
}
