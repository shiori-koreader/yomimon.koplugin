--[[--
Assuntos do capítulo, para os cartões (Lote 1, 28/10/2026). As listas são as do lote, nas duas línguas
juntas: quem decide a palavra é a língua do livro, não a da Yomimon.

A página conta como os eventos (yomimon_memory.lua): 2+ palavras diferentes do assunto, ou 3+ da mesma.
O capítulo "fala de" um assunto quando ele aparece bem mais que no resto do livro (o dobro, como os
eventos) ou quando o título do capítulo tem uma palavra da lista. O plural com -s ou -es entra sozinho;
expressão de várias palavras ("coat of arms") conta como sequência, e a que contém uma palavra da própria
lista ("great-grandfather") conta como essa palavra.
]]

return {
    pressagio = {
        "cartas", "baralho", "sorte", "destino", "profecia", "presságio", "agouro", "cartomante", "vidente", "sina",
        "previsão",
        "cards", "deck", "fortune", "fate", "prophecy", "omen", "foretell", "fortune-teller", "seer", "destiny",
    },
    antepassados = {
        "antepassado", "avô", "bisavô", "linhagem", "genealogia", "descendência", "herança", "sobrenome", "brasão",
        "ancestral",
        "ancestor", "grandfather", "great-grandfather", "lineage", "genealogy", "descent", "heritage", "surname",
        "coat of arms", "forefather",
    },
    pai = {
        "pai", "papai", "filho", "conselho", "herdeiro", "paterno", "bênção",
        "father", "dad", "son", "advice", "heir", "paternal", "blessing",
    },
}
