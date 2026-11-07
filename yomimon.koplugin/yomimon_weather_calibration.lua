-- Dictionary weather calibration (generated offline from the simulation corpus).
-- Corpus: the 30 books of the simulation, without an answer key. weather = (score - median) / half_range.
-- soured/sweetened: a chapter whose average is this far below/above the book's average up to there (10% of the chapters
-- each, with the chapters of both languages together).
return {
    en = { median = 1.586, half_range = 2.180, soured = -1.548, sweetened = 1.025 },  -- 7064 pages, 435 chapters
    pt = { median = -0.697, half_range = 1.047, soured = -1.548, sweetened = 1.025 },  -- 1024 pages, 435 chapters
    -- average of a whole book: the 25% gloomiest / lightest books of the corpus (30 books)
    books = { gloomy = -0.224, light = 0.313 },
}
