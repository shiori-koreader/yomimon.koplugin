-- Quanto de cada tema tem uma página média (gerado por ferramentas/validacao/calcular_base_temas.lua).
-- Corpus: os 30 livros de domínio público da simulação (7064 páginas em inglês, 1024 em português).
-- Contagem do tema × peso de especificidade, como em L.temas. O domínio do livro é o tema acima desta média.
return {
    en = { amor = 0.220, animais = 0.199, arte = 0.115, cidade = 0.119, ciencia = 0.107, comida = 0.125, dinheiro = 0.173, familia = 0.297, fe = 0.183, guerra = 0.101, infancia = 0.160, liberdade = 0.094, loucura = 0.123, mar = 0.275, medo = 0.200, morte = 0.233, natureza = 0.199, noite = 0.196, politica = 0.129, saber = 0.145, solidao = 0.123, tempo = 0.304, viagem = 0.121, vinganca = 0.077 },
    pt = { amor = 0.520, animais = 0.242, arte = 0.234, cidade = 0.294, ciencia = 0.119, comida = 0.211, dinheiro = 0.319, familia = 0.701, fe = 0.383, guerra = 0.368, infancia = 0.120, liberdade = 0.180, loucura = 0.165, mar = 0.252, medo = 0.211, morte = 0.362, natureza = 0.299, noite = 0.215, politica = 0.332, saber = 0.343, solidao = 0.168, tempo = 0.508, viagem = 0.201, vinganca = 0.129 },
}
