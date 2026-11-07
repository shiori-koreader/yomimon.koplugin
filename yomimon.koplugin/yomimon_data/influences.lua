--[[--
The 16 literary influences (since 28/10/2026). A single structure for all: each influence is a recipe
over what the book vector already measures (yomimon_vector.lua). Nothing here detects anything new.

Ingredients of the recipe (each becomes a number from 0 to 1 for the current book):
  <theme>        one of the 24 themes, how much the book has ABOVE the average page ("fear", "love", "science"…)
  ev_<event>   happenings per page ("ev_crime", "ev_wedding"…)
  _gloomy      tone well below the average book      _light        tone well above
  _long_sentence  sentences much longer than average    _short_sentence sentences much shorter
  _theatre       the book is a play                    _first_person    narrated by an "I"
Intensity of the influence in the book = 100 x sum(weight x ingredient), at most 100. Weights that add up to
less than 1 leave the influence conservative: it never reaches the top with weak clues alone.

Magical realism, satire, nihilism and myth have no clue of their own in what the plugin measures; their recipes
are weak on purpose (they add up to 0.5 to 0.85) and use only indirect hints.
]]

return {
    -- narrative
    { id = "epic", nameText = "epic fantasy", group = "narrative",
      recipe = { war = 0.5, revenge = 0.2, travel = 0.15, faith = 0.15 } },
    { id = "mystery", nameText = "mystery and investigation", group = "narrative",
      recipe = { ev_crime = 0.5, city = 0.15, night = 0.15, fear = 0.1, death = 0.1 } },
    { id = "horror", nameText = "horror and gothic", group = "narrative",
      recipe = { fear = 0.4, night = 0.25, madness = 0.15, death = 0.1, _gloomy = 0.1 } },
    { id = "romance", nameText = "romance and emotional drama", group = "narrative",
      recipe = { love = 0.5, ev_wedding = 0.25, ev_letter = 0.15, family = 0.1 } },
    { id = "adventure", nameText = "adventure and exploration", group = "narrative",
      recipe = { travel = 0.35, sea = 0.3, nature = 0.15, ev_travel = 0.1, ev_escape = 0.1 } },
    { id = "science_fiction", nameText = "science fiction and dystopia", group = "narrative",
      recipe = { science = 0.55, time = 0.15, politics = 0.1, city = 0.1, knowledge = 0.1 } },
    { id = "magical", nameText = "magical realism and the fantastic", group = "narrative",
      recipe = { childhood = 0.1, family = 0.1, time = 0.1, faith = 0.1, nature = 0.1 } },
    { id = "satire", nameText = "satire and comedy", group = "narrative",
      recipe = { _light = 0.25, politics = 0.25, money = 0.15, city = 0.1, ev_party = 0.1 } },
    -- stylistic and dramatic
    { id = "poetry", nameText = "poetry and lyricism", group = "stylistic",
      recipe = { art = 0.35, nature = 0.2, _short_sentence = 0.15, night = 0.1 } },
    { id = "tragedy", nameText = "tragedy", group = "stylistic",
      recipe = { death = 0.25, ev_death = 0.2, _theatre = 0.2, revenge = 0.15, _gloomy = 0.1, madness = 0.1 } },
    { id = "social", nameText = "social realism", group = "stylistic",
      recipe = { money = 0.35, city = 0.25, politics = 0.15, food = 0.1, _gloomy = 0.15 } },
    { id = "existential", nameText = "existentialism and the absurd", group = "stylistic",
      recipe = { solitude = 0.3, freedom = 0.25, _gloomy = 0.15, death = 0.1, madness = 0.1, _first_person = 0.1 } },
    -- interpretative
    { id = "philosophy", nameText = "philosophy and metaphysics", group = "interpretive",
      recipe = { knowledge = 0.4, faith = 0.2, freedom = 0.15, time = 0.15, science = 0.1 } },
    { id = "nihilism", nameText = "nihilism and skepticism", group = "interpretive",
      recipe = { _gloomy = 0.25, death = 0.15, solitude = 0.1 } },
    { id = "myth", nameText = "myth and folklore", group = "interpretive",
      recipe = { faith = 0.25, animals = 0.2, nature = 0.2, childhood = 0.1, night = 0.05 } },
    { id = "psychology", nameText = "psychology and introspection", group = "interpretive",
      recipe = { madness = 0.3, _first_person = 0.15, solitude = 0.15, fear = 0.1, family = 0.1, _long_sentence = 0.1 } },
}
