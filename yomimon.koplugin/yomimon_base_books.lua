-- Como é um livro médio (gerado por ferramentas/validacao/calcular_base_livros.lua).
-- Corpus: os 30 livros de domínio público da simulação; cada livro é uma amostra.
-- clima: sentimento médio por página, por língua. dialogo: marcas de diálogo por página; eventos: eventos
-- por página; frase: palavras por frase (as três sem as peças de teatro).
return {
    clima = { en = { media = 0.063, desvio = 0.614, n = 24 }, pt = { media = -0.064, desvio = 0.317, n = 6 } },
    dialogo = { media = 4.443, desvio = 2.123, n = 27 },
    eventos = { media = 0.382, desvio = 0.195, n = 27 },
    frase = { media = 14.166, desvio = 2.548, n = 27 },
}
