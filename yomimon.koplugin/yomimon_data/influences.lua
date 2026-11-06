--[[--
The 16 literary influences (since 28/10/2026). A single structure for all: each influence is a recipe
over what the book vector already measures (yomimon_vector.lua). Nothing here detects anything new.

Ingredients of the recipe (each becomes a number from 0 to 1 for the current book):
  <tema>        one of the 24 themes, how much the book has ABOVE the average page ("medo", "amor", "ciencia"…)
  ev_<evento>   happenings per page ("ev_crime", "ev_casamento"…)
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
    { id = "epica", nameText = "fantasia épica", group = "narrativa",
      recipe = { guerra = 0.5, vinganca = 0.2, viagem = 0.15, fe = 0.15 } },
    { id = "misterio", nameText = "mistério e investigação", group = "narrativa",
      recipe = { ev_crime = 0.5, cidade = 0.15, noite = 0.15, medo = 0.1, morte = 0.1 } },
    { id = "horror", nameText = "horror e gótico", group = "narrativa",
      recipe = { medo = 0.4, noite = 0.25, loucura = 0.15, morte = 0.1, _gloomy = 0.1 } },
    { id = "romance", nameText = "romance e drama afetivo", group = "narrativa",
      recipe = { amor = 0.5, ev_casamento = 0.25, ev_carta = 0.15, familia = 0.1 } },
    { id = "aventura", nameText = "aventura e exploração", group = "narrativa",
      recipe = { viagem = 0.35, mar = 0.3, natureza = 0.15, ev_viagem = 0.1, ev_fuga = 0.1 } },
    { id = "ficcao", nameText = "ficção científica e distopia", group = "narrativa",
      recipe = { ciencia = 0.55, tempo = 0.15, politica = 0.1, cidade = 0.1, saber = 0.1 } },
    { id = "magico", nameText = "realismo mágico e fantástico", group = "narrativa",
      recipe = { infancia = 0.1, familia = 0.1, tempo = 0.1, fe = 0.1, natureza = 0.1 } },
    { id = "satira", nameText = "sátira e comédia", group = "narrativa",
      recipe = { _light = 0.25, politica = 0.25, dinheiro = 0.15, cidade = 0.1, ev_festa = 0.1 } },
    -- stylistic and dramatic
    { id = "poesia", nameText = "poesia e lirismo", group = "estilistica",
      recipe = { arte = 0.35, natureza = 0.2, _short_sentence = 0.15, noite = 0.1 } },
    { id = "tragedia", nameText = "tragédia", group = "estilistica",
      recipe = { morte = 0.25, ev_morte = 0.2, _theatre = 0.2, vinganca = 0.15, _gloomy = 0.1, loucura = 0.1 } },
    { id = "social", nameText = "realismo social", group = "estilistica",
      recipe = { dinheiro = 0.35, cidade = 0.25, politica = 0.15, comida = 0.1, _gloomy = 0.15 } },
    { id = "existencial", nameText = "existencialismo e absurdo", group = "estilistica",
      recipe = { solidao = 0.3, liberdade = 0.25, _gloomy = 0.15, morte = 0.1, loucura = 0.1, _first_person = 0.1 } },
    -- interpretative
    { id = "filosofia", nameText = "filosofia e metafísica", group = "interpretativa",
      recipe = { saber = 0.4, fe = 0.2, liberdade = 0.15, tempo = 0.15, ciencia = 0.1 } },
    { id = "niilismo", nameText = "niilismo e ceticismo", group = "interpretativa",
      recipe = { _gloomy = 0.25, morte = 0.15, solidao = 0.1 } },
    { id = "mito", nameText = "mito e folclore", group = "interpretativa",
      recipe = { fe = 0.25, animais = 0.2, natureza = 0.2, infancia = 0.1, noite = 0.05 } },
    { id = "psicologia", nameText = "psicologia e introspecção", group = "interpretativa",
      recipe = { loucura = 0.3, _first_person = 0.15, solidao = 0.15, medo = 0.1, familia = 0.1, _long_sentence = 0.1 } },
}
