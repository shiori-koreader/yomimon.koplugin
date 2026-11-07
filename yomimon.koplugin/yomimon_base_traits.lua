-- Average push of a page on each trait (generated offline from the simulation corpus).
-- Corpus: the 30 public-domain books of the simulation (7064 pages in English, 1024 in Portuguese).
-- The traits move by the difference between the page and this average.
return {
    en = { mood = -0.079, courage = 0.037, heart = 0.148, taste = 0.167 },
    pt = { mood = 0.040, courage = 0.127, heart = 0.391, taste = 0.336 },
}
