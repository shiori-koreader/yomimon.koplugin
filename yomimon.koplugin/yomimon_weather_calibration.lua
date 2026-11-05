-- Calibração do clima por dicionário (gerado por ferramentas/dicionarios/calibrar_clima.lua).
-- Corpus: os 30 livros da simulação, sem gabarito. clima = (nota - mediana) / meia_faixa.
-- azedou/adocou: capítulo cuja média fica tanto abaixo/acima da média do livro até ali (10% dos capítulos
-- cada, com os capítulos das duas línguas juntos).
return {
    en = { mediana = 1.586, meia_faixa = 2.180, azedou = -1.548, adocou = 1.025 },  -- 7064 páginas, 435 capítulos
    pt = { mediana = -0.697, meia_faixa = 1.047, azedou = -1.548, adocou = 1.025 },  -- 1024 páginas, 435 capítulos
    -- média do livro inteiro: os 25% de livros mais sombrios / mais leves do corpus (30 livros)
    livros = { sombrio = -0.224, leve = 0.313 },
}
