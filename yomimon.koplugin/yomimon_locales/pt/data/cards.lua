--[[--
Card box (Portuguese). Phrases written by you; nothing enters here without approval.
Source: the document "Yomimon — Batch 1" (2026-10-28).

Each card:
  id      short, fixed name (the state stores the cards already said by it)
  speech  the text; {character} is who appears most in the chapter
  when    screen: "home" (shows on the Home if it fits in 2 lines; otherwise on the Yomimon screen)
          subject: the chapter talks about it (yomimon_data/topics.lua)
          stage: only in that stage ("young", "adult", "elder")
          stored: only after it has already said a card that records this
  records what is stored when it says the phrase
  once true: only once in its life
  turned_off true: the card does not come out (kept to come back later)
Order matters: in the same chapter, the first card that fits wins.

Turned off for the beta (2026-10-29): omen and father. Their word lists light up in chapters
wrong ("deck" is a ship deck, "fortune" is money, "cartas" is sometimes mail, "filho" lights up the father) and the phrase
states what the chapter does not have. They come back when the lists have strong and supporting words.
]]

return {
    {
        id = "pressagio",
        speech = "Cartas na mesa, sorte de {character}. A minha? Ninguém lê e todo mundo sabe.",
        when = { screen = "home", subject = "pressagio" },
        turned_off = true,
    },
    {
        id = "alexandria_ancia",
        speech = "Já te contei de Alexandria? A família inteira. Num dia só.",
        when = { screen = "home", subject = "antepassados", stored = "contou de Alexandria", stage = "elder" },
    },
    {
        id = "alexandria",
        speech = "Falaram de antepassados. Os meus morreram no incêndio em Alexandria. Minha avó contou.",
        when = { screen = "home", subject = "antepassados" },
        records = "contou de Alexandria",
        once = true,
    },
    {
        id = "pai",
        speech = "Pai dando conselho. Meu pai? Não conheci. Morreu atropelado por uma enciclopédia Barsa. "
            .. "Morreu fazendo o que amava: tentando chegar à letra M.",
        when = { screen = "home", subject = "pai" },
        records = "contou do pai",
        once = true,
        turned_off = true,
    },
}
