--[[--
The 16 literary influences (since 28/10/2026). A single structure for all: each influence is a recipe
over what the book vector already measures (yomimon_vector.lua). Nothing here detects anything new.

Ingredients of the recipe (each becomes a number from 0 to 1 for the current book):
  <tema>        one of the 24 themes, how much the book has ABOVE the average page ("medo", "amor", "ciencia"…)
  ev_<evento>   happenings per page ("ev_crime", "ev_casamento"…)
  _sombrio      tone well below the average book      _leve        tone well above
  _frase_longa  sentences much longer than average    _frase_curta sentences much shorter
  _teatro       the book is a play                    _primeira    narrated by an "I"
Intensity of the influence in the book = 100 x sum(weight x ingredient), at most 100. Weights that add up to
less than 1 leave the influence conservative: it never reaches the top with weak clues alone.

Magical realism, satire, nihilism and myth have no clue of their own in what the plugin measures; their recipes
are weak on purpose (they add up to 0.5 to 0.85) and use only indirect hints.
]]

return {
    -- narrative
    { id = "epica", nome = "fantasia épica", grupo = "narrativa",
      receita = { guerra = 0.5, vinganca = 0.2, viagem = 0.15, fe = 0.15 } },
    { id = "misterio", nome = "mistério e investigação", grupo = "narrativa",
      receita = { ev_crime = 0.5, cidade = 0.15, noite = 0.15, medo = 0.1, morte = 0.1 } },
    { id = "horror", nome = "horror e gótico", grupo = "narrativa",
      receita = { medo = 0.4, noite = 0.25, loucura = 0.15, morte = 0.1, _sombrio = 0.1 } },
    { id = "romance", nome = "romance e drama afetivo", grupo = "narrativa",
      receita = { amor = 0.5, ev_casamento = 0.25, ev_carta = 0.15, familia = 0.1 } },
    { id = "aventura", nome = "aventura e exploração", grupo = "narrativa",
      receita = { viagem = 0.35, mar = 0.3, natureza = 0.15, ev_viagem = 0.1, ev_fuga = 0.1 } },
    { id = "ficcao", nome = "ficção científica e distopia", grupo = "narrativa",
      receita = { ciencia = 0.55, tempo = 0.15, politica = 0.1, cidade = 0.1, saber = 0.1 } },
    { id = "magico", nome = "realismo mágico e fantástico", grupo = "narrativa",
      receita = { infancia = 0.1, familia = 0.1, tempo = 0.1, fe = 0.1, natureza = 0.1 } },
    { id = "satira", nome = "sátira e comédia", grupo = "narrativa",
      receita = { _leve = 0.25, politica = 0.25, dinheiro = 0.15, cidade = 0.1, ev_festa = 0.1 } },
    -- stylistic and dramatic
    { id = "poesia", nome = "poesia e lirismo", grupo = "estilistica",
      receita = { arte = 0.35, natureza = 0.2, _frase_curta = 0.15, noite = 0.1 } },
    { id = "tragedia", nome = "tragédia", grupo = "estilistica",
      receita = { morte = 0.25, ev_morte = 0.2, _teatro = 0.2, vinganca = 0.15, _sombrio = 0.1, loucura = 0.1 } },
    { id = "social", nome = "realismo social", grupo = "estilistica",
      receita = { dinheiro = 0.35, cidade = 0.25, politica = 0.15, comida = 0.1, _sombrio = 0.15 } },
    { id = "existencial", nome = "existencialismo e absurdo", grupo = "estilistica",
      receita = { solidao = 0.3, liberdade = 0.25, _sombrio = 0.15, morte = 0.1, loucura = 0.1, _primeira = 0.1 } },
    -- interpretative
    { id = "filosofia", nome = "filosofia e metafísica", grupo = "interpretativa",
      receita = { saber = 0.4, fe = 0.2, liberdade = 0.15, tempo = 0.15, ciencia = 0.1 } },
    { id = "niilismo", nome = "niilismo e ceticismo", grupo = "interpretativa",
      receita = { _sombrio = 0.25, morte = 0.15, solidao = 0.1 } },
    { id = "mito", nome = "mito e folclore", grupo = "interpretativa",
      receita = { fe = 0.25, animais = 0.2, natureza = 0.2, infancia = 0.1, noite = 0.05 } },
    { id = "psicologia", nome = "psicologia e introspecção", grupo = "interpretativa",
      receita = { loucura = 0.3, _primeira = 0.15, solidao = 0.15, medo = 0.1, familia = 0.1, _frase_longa = 0.1 } },
}
