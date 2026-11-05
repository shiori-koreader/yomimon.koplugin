-- Peso de especificidade de cada tema (gerado por ferramentas/validacao/calcular_pesos_temas.lua).
-- Corpus: os 30 livros de domínio público da simulação (24 em inglês, 6 em português), alfa 0.50.
-- Tema comum em quase todo livro (família, tempo) pesa menos; tema raro pesa mais.
return {
    en = { amor = 0.86, animais = 0.96, arte = 1.66, cidade = 1.61, ciencia = 1.80, comida = 1.53, dinheiro = 1.10, familia = 0.65, fe = 1.05, guerra = 1.88, infancia = 1.19, liberdade = 2.03, loucura = 1.54, mar = 0.69, medo = 0.95, morte = 0.83, natureza = 0.96, noite = 0.98, politica = 1.49, saber = 1.32, solidao = 1.56, tempo = 0.62, viagem = 1.58, vinganca = 2.48 },
    pt = { amor = 0.68, animais = 1.44, arte = 1.50, cidade = 1.20, ciencia = 2.90, comida = 1.66, dinheiro = 1.11, familia = 0.51, fe = 0.92, guerra = 0.95, infancia = 2.86, liberdade = 1.94, loucura = 2.11, mar = 1.39, medo = 1.65, morte = 0.97, natureza = 1.17, noite = 1.64, politica = 1.06, saber = 1.03, solidao = 2.07, tempo = 0.70, viagem = 1.74, vinganca = 2.69 },
}
