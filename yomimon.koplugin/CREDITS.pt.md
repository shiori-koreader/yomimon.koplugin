# Créditos

## Dicionários de sentimento (clima das páginas)

- **VADER** (inglês) — C.J. Hutto & E.E. Gilbert. *VADER: A Parsimonious Rule-based Model for Sentiment
  Analysis of Social Media Text*. ICWSM-14, 2014. Licença MIT. Copyright (c) 2016 C.J. Hutto.
  https://github.com/cjhutto/vaderSentiment — usado em `yomimon_lexicon_en.lua`.
- **SentiLex-PT 02** (português) — Paula Carvalho & Mário J. Silva. Licença Creative Commons Atribuição 4.0
  (CC-BY 4.0). https://doi.org/10.23728/b2share.93ab120efdaa4662baec6adee8e7585f — usado em
  `yomimon_lexicon_pt.lua`, convertido (formas na grafia modernizada, só polaridade −1/+1) por
  `ferramentas/dicionarios/gerar_lexicos.py`.

## Cidades (lugares que não são personagens)

- **GeoNames** — geonames.org, licença Creative Commons Atribuição 4.0 (CC-BY 4.0). Usado em
  `yomimon_cities.lua` (nomes de uma palavra de cidades com 50 mil+ habitantes), gerado por
  `ferramentas/dicionarios/gerar_cidades.py` a partir de `cities15000.zip`.
