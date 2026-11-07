--[[--
Chapter subjects, for the cards (Batch 1, 28/10/2026). The lists are those of the batch, both languages
together: what decides the word is the book's language, not Yomimon's.

The page counts like the events (yomimon_memory.lua): 2+ different words of the subject, or 3+ of the same one.
The chapter "talks about" a subject when it appears much more than in the rest of the book (double, like the
events) or when the chapter title has a word of the list. The plural with -s or -es enters on its own;
a multi-word expression ("coat of arms") counts as a sequence, and one that contains a word of the list
itself ("great-grandfather") counts as that word.
]]

return {
    omen = {
        "cartas", "baralho", "sorte", "destino", "profecia", "presságio", "agouro", "cartomante", "vidente", "sina",
        "previsão",
        "cards", "deck", "fortune", "fate", "prophecy", "omen", "foretell", "fortune-teller", "seer", "destiny",
    },
    ancestors = {
        "antepassado", "avô", "bisavô", "linhagem", "genealogia", "descendência", "herança", "sobrenome", "brasão",
        "ancestral",
        "ancestor", "grandfather", "great-grandfather", "lineage", "genealogy", "descent", "heritage", "surname",
        "coat of arms", "forefather",
    },
    father = {
        "pai", "papai", "filho", "conselho", "herdeiro", "paterno", "bênção",
        "father", "dad", "son", "advice", "heir", "paternal", "blessing",
    },
}
