--[[--
Card box (English). Same format and order as the Portuguese one; the same ids and the same `records`
(the state stores the cards by id, in both languages). Adapted, not translated word for word: in
the father card, the Barsa becomes the Britannica (2026-10-29).

Turned off as in Portuguese: omen and father (the word lists light up in the wrong chapters).
]]

return {
    {
        id = "pressagio",
        speech = "Cards on the table, {character}'s fortune. Mine? Nobody reads it and everybody knows.",
        when = { screen = "home", subject = "pressagio" },
        turned_off = true,
    },
    {
        id = "alexandria_ancia",
        speech = "Did I mention Alexandria? The whole family. One day.",
        when = { screen = "home", subject = "antepassados", stored = "contou de Alexandria", stage = "elder" },
    },
    {
        id = "alexandria",
        speech = "Ancestors came up. Mine died in the fire at Alexandria. My grandmother told me.",
        when = { screen = "home", subject = "antepassados" },
        records = "contou de Alexandria",
        once = true,
    },
    {
        id = "pai",
        speech = "A father giving advice. My father? Never met him. Crushed by an Encyclopaedia Britannica. "
            .. "He died doing what he loved: trying to reach the letter M.",
        when = { screen = "home", subject = "pai" },
        records = "contou do pai",
        once = true,
        turned_off = true,
    },
}
