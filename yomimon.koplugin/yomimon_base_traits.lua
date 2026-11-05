-- Empurrão médio de uma página em cada traço (gerado por ferramentas/validacao/calcular_base_tracos.lua).
-- Corpus: os 30 livros de domínio público da simulação (7064 páginas em inglês, 1024 em português).
-- Os traços se movem pela diferença entre a página e esta média.
return {
    en = { humor = -0.079, coragem = 0.037, coracao = 0.148, gosto = 0.167 },
    pt = { humor = 0.040, coragem = 0.127, coracao = 0.391, gosto = 0.336 },
}
