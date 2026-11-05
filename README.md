<p align="center">
  <img alt="Yomimon" src="media/yomimon-logo.svg" width="320">
</p>

# Yomimon

**A little creature that lives in KOReader and comments on what you read.**

*Em português: [README.pt-BR.md](README.pt-BR.md).*

> **Status: early version (0.1.0), not yet tested on a real device.** The creature picker, evolution lines and sprite download are in; the text
> banks are still being adapted from the original (some lines may still sound like the old creature). See the
> [CHANGELOG](CHANGELOG.md).

Yomimon (*yomi* 読み, "reading", plus "-mon") keeps track of the pages you really read and reacts to them: finished
books, reading habits, the time of day you read. It runs on your e-reader with **no AI**, and your reading never
leaves the device. The only network use is a one-time download of the sprite of the creature you choose.

## How it works

- The first time you open it, you pick your creature (329 evolution families, Pokédex 1-649). Each species
  grows through its own evolution line, by the pages you read.
- No egg, no death and no lineage: once it reaches its final form it stays with you for good.
- It still gets hungry when you stop reading, and goes back into its ball if you stay away for days.
- The sprite is downloaded on the device (only for the chosen creature and its evolutions), converted to a small
  grayscale grid and cached in `yomimon.koplugin/sprites/` (so they are lost if you replace the plugin folder; they download again). No creature artwork is stored in this repository.
  Until the download works, a plain ball is shown.

## Install

- **With Storefront** (recommended): install Yomimon from the Storefront plugin store. Updates appear there when a
  new GitHub release is published. The downloaded sprites live inside the plugin folder, so they are fetched again
  after an update (Wi-Fi needed once).
- **By hand**: download `yomimon.koplugin-v<version>.zip` from the
  [latest release](https://github.com/shiori-koreader/yomimon.koplugin/releases/latest) and unzip it into
  `koreader/plugins/`. Restart KOReader.

Delete any `silverfish.koplugin` or `traca.koplugin` folder first: they share module names with this plugin and
cannot be installed side by side.

## Based on Silverfish

Yomimon is a modified version of [Silverfish](https://github.com/theusmaoliveiras/silverfish-koreader) by Matheus
Oliveira (v1.1.0). It is not affiliated with, or endorsed by, the original author. Changes were made: the rename,
new storage paths, species and evolution lines in place of the silverfish, no life cycle (egg, death, lineage),
downloaded sprites, and adapted text banks.

## Disclaimer

Yomimon is an unofficial, non-commercial fan project. It is not affiliated with, endorsed by or sponsored by
Nintendo, Game Freak, Creatures Inc. or The Pokémon Company. Pokémon and the names of Pokémon species are
trademarks of their respective owners. No Pokémon artwork is distributed in this repository: the device downloads
sprites from the public [PokeAPI/sprites](https://github.com/PokeAPI/sprites) repository, pinned to one commit.

## Licenses

- Code: **GPL-3.0** (see [LICENSE](LICENSE)). The original copyright notices are kept.
- Phrases and any art derived from Silverfish: **CC BY-NC-SA 4.0**, credited to Matheus Oliveira, with the changes
  indicated. No commercial use. See [LICENSE-ART.md](LICENSE-ART.md).
- Third-party components: see [CREDITS.md](CREDITS.md).
