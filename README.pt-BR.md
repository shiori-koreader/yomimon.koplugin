<p align="center">
  <img alt="Yomimon" src="media/yomimon-logo.svg" width="320">
</p>

# Yomimon

**Um bichinho que mora no KOReader e comenta o que você lê.**

*In English: [README.md](README.md).*

O Yomimon (*yomi* 読み, "leitura", mais "-mon") acompanha as páginas que você realmente lê e reage a elas: livros
terminados, hábitos de leitura, o horário em que você lê. Roda no seu leitor **sem IA**, e sua leitura nunca sai do aparelho. O único uso da internet é o download do sprite
(e da descrição) do bichinho escolhido.

## Como funciona

- Você escolhe o bichinho na primeira vez que abrir. Cada espécie evolui pela própria linha.
- Sem ovo, sem morte e sem linhagem: ao chegar na forma final, ele fica para sempre.
- Ele continua com fome quando você para de ler.
- Os sprites são baixados no aparelho, só do bichinho escolhido e das evoluções dele, convertidos e guardados em
  cache. Nenhuma arte de terceiros fica neste repositório.

## Idiomas

A interface e as frases existem em inglês e em português do Brasil. Em *Yomimon > Idioma* você escolhe um ou segue o
idioma do KOReader. Cada idioma é uma pasta em `yomimon.koplugin/yomimon_locales/`, e o que a pasta não tiver cai para o
inglês: acrescentar um idioma é acrescentar uma pasta (veja [yomimon_locales/README.md](yomimon.koplugin/yomimon_locales/README.md)).

## Instalação

- **Pelo Storefront** (recomendado): instale o Yomimon na loja de plugins do Storefront. As atualizações aparecem
  lá quando uma nova versão é publicada no GitHub. Os sprites baixados ficam em `koreader/yomimon/sprites/`, então uma atualização não os apaga.
- **À mão**: baixe `yomimon.koplugin-v<versão>.zip` na
  [última versão](https://github.com/shiori-koreader/yomimon.koplugin/releases/latest) e descompacte em
  `koreader/plugins/`. Reinicie o KOReader.

Apague antes qualquer pasta `silverfish.koplugin` ou `traca.koplugin`: elas usam os mesmos nomes de módulos e não
podem ficar juntas.

## Baseado no Silverfish

O Yomimon é uma versão modificada do [Silverfish](https://github.com/theusmaoliveiras/silverfish-koreader), de
Matheus Oliveira (v1.1.0). Não tem afiliação com o autor original nem é endossado por ele. Houve mudanças: o nome, os
caminhos de armazenamento e, nas próximas versões, o bichinho, os textos e o ciclo de vida.

## Aviso legal

O Yomimon é um projeto de fã, não oficial e sem fins lucrativos. Não tem afiliação, endosso ou patrocínio da
Nintendo, Game Freak, Creatures Inc. ou The Pokémon Company. Pokémon e os nomes das espécies são marcas de seus
respectivos donos. Nenhuma arte de Pokémon, oficial ou de fãs, é distribuída neste repositório.

## Licenças

- Código: **GPL-3.0** (veja [LICENSE](LICENSE)). Os avisos de copyright originais foram mantidos.
- Frases e qualquer arte derivada do Silverfish: **CC BY-NC-SA 4.0**, com crédito a Matheus Oliveira e indicação das
  mudanças. Sem uso comercial. Veja [LICENSE-ART.md](LICENSE-ART.md).
- Componentes de terceiros: veja [CREDITS.md](CREDITS.md).
