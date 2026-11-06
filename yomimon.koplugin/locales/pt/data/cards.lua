--[[--
Caixa de cartões (português). Falas escritas por você; nada entra aqui sem aprovação.
Fonte: o documento "Yomimon — Lote 1" (28/10/2026).

Cada cartão:
  id      nome curto e fixo (o estado guarda os cartões já ditos por ele)
  fala    o texto; {personagem} é quem mais aparece no capítulo
  quando  tela: "home" (aparece na Home se couber em 2 linhas; senão, na tela da Yomimon)
          assunto: o capítulo fala disso (yomimon_data/topics.lua)
          fase: só nessa fase ("jovem", "adulta", "ancia")
          gravado: só depois que ela já disse um cartão que grava isso
  grava   o que fica guardado quando ela diz a fala
  uma_vez true: uma vez só na vida dela
  desligado true: o cartão não sai (guardado para voltar depois)
A ordem conta: no mesmo capítulo, vale o primeiro cartão que serve.

Desligados para o beta (29/10/2026): presságio e pai. As listas de palavras deles acendem em capítulos
errados ("deck" é convés, "fortune" é dinheiro, "cartas" às vezes é correio, "filho" acende o pai) e a fala
afirma o que o capítulo não tem. Voltam quando as listas tiverem palavras fortes e de apoio.
]]

return {
    {
        id = "pressagio",
        fala = "Cartas na mesa, sorte de {personagem}. A minha? Ninguém lê e todo mundo sabe.",
        quando = { tela = "home", assunto = "pressagio" },
        desligado = true,
    },
    {
        id = "alexandria_ancia",
        fala = "Já te contei de Alexandria? A família inteira. Num dia só.",
        quando = { tela = "home", assunto = "antepassados", gravado = "contou de Alexandria", fase = "ancia" },
    },
    {
        id = "alexandria",
        fala = "Falaram de antepassados. Os meus morreram no incêndio em Alexandria. Minha avó contou.",
        quando = { tela = "home", assunto = "antepassados" },
        grava = "contou de Alexandria",
        uma_vez = true,
    },
    {
        id = "pai",
        fala = "Pai dando conselho. Meu pai? Não conheci. Morreu atropelado por uma enciclopédia Barsa. "
            .. "Morreu fazendo o que amava: tentando chegar à letra M.",
        quando = { tela = "home", assunto = "pai" },
        grava = "contou do pai",
        uma_vez = true,
        desligado = true,
    },
}
