--[[--
Caixa de cartões (inglês). Mesmo formato e mesma ordem de cartoes_pt.lua; os mesmos ids e o mesmo `grava`
(o estado guarda os cartões pelo id, nas duas línguas). Adaptado, não traduzido palavra por palavra: no
cartão do pai, a Barsa vira a Britannica (29/10/2026).

Desligados como em português: presságio e pai (as listas de palavras acendem em capítulos errados).
]]

return {
    {
        id = "pressagio",
        fala = "Cards on the table, {personagem}'s fortune. Mine? Nobody reads it and everybody knows.",
        quando = { tela = "home", assunto = "pressagio" },
        desligado = true,
    },
    {
        id = "alexandria_ancia",
        fala = "Did I mention Alexandria? The whole family. One day.",
        quando = { tela = "home", assunto = "antepassados", gravado = "contou de Alexandria", fase = "ancia" },
    },
    {
        id = "alexandria",
        fala = "Ancestors came up. Mine died in the fire at Alexandria. My grandmother told me.",
        quando = { tela = "home", assunto = "antepassados" },
        grava = "contou de Alexandria",
        uma_vez = true,
    },
    {
        id = "pai",
        fala = "A father giving advice. My father? Never met him. Crushed by an Encyclopaedia Britannica. "
            .. "He died doing what he loved: trying to reach the letter M.",
        quando = { tela = "home", assunto = "pai" },
        grava = "contou do pai",
        uma_vez = true,
        desligado = true,
    },
}
