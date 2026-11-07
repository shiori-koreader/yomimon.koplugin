-- Specificity weight of each theme (generated offline from the simulation corpus).
-- Corpus: the 30 public-domain books of the simulation (24 in English, 6 in Portuguese), alpha 0.50.
-- A theme common in almost every book (family, time) weighs less; a rare theme weighs more.
return {
    en = { love = 0.86, animals = 0.96, art = 1.66, city = 1.61, science = 1.80, food = 1.53, money = 1.10, family = 0.65, faith = 1.05, war = 1.88, childhood = 1.19, freedom = 2.03, madness = 1.54, sea = 0.69, fear = 0.95, death = 0.83, nature = 0.96, night = 0.98, politics = 1.49, knowledge = 1.32, solitude = 1.56, time = 0.62, travel = 1.58, revenge = 2.48 },
    pt = { love = 0.68, animals = 1.44, art = 1.50, city = 1.20, science = 2.90, food = 1.66, money = 1.11, family = 0.51, faith = 0.92, war = 0.95, childhood = 2.86, freedom = 1.94, madness = 2.11, sea = 1.39, fear = 1.65, death = 0.97, nature = 1.17, night = 1.64, politics = 1.06, knowledge = 1.03, solitude = 2.07, time = 0.70, travel = 1.74, revenge = 2.69 },
}
