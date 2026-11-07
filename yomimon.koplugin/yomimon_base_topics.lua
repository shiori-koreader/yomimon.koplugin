-- How much of each theme an average page has (generated offline from the simulation corpus).
-- Corpus: the 30 public-domain books of the simulation (7064 pages in English, 1024 in Portuguese).
-- Theme count × specificity weight, as in L.themes. The book's domain is the theme above this average.
return {
    en = { love = 0.220, animals = 0.199, art = 0.115, city = 0.119, science = 0.107, food = 0.125, money = 0.173, family = 0.297, faith = 0.183, war = 0.101, childhood = 0.160, freedom = 0.094, madness = 0.123, sea = 0.275, fear = 0.200, death = 0.233, nature = 0.199, night = 0.196, politics = 0.129, knowledge = 0.145, solitude = 0.123, time = 0.304, travel = 0.121, revenge = 0.077 },
    pt = { love = 0.520, animals = 0.242, art = 0.234, city = 0.294, science = 0.119, food = 0.211, money = 0.319, family = 0.701, faith = 0.383, war = 0.368, childhood = 0.120, freedom = 0.180, madness = 0.165, sea = 0.252, fear = 0.211, death = 0.362, nature = 0.299, night = 0.215, politics = 0.332, knowledge = 0.343, solitude = 0.168, time = 0.508, travel = 0.201, revenge = 0.129 },
}
