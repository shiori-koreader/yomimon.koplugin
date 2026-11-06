# Changelog

## 0.1.1 (2026-11-05)

- The A-Z bar in the picker now shows only the species of the chosen letter (tap it again for the full list);
  letters without species are greyed out.
- Removed the three non-interactive squares at the bottom of the picker.
- Sprites of every registered species are downloaded again when missing, not only the current one.
- The Pokémon you just picked now shows up in the Pokédex right away.
- The picker's confirmation screen shows the Pokédex description (English only: PokeAPI has no Portuguese text)
  under the ball, downloaded on the device with the sprites.
- Clearer menu captions, and "pages read with you" in the Pokédex.
- The critter image has one fixed height, so the Simple UI decorations keep the same size for every species; its
  background is white in light mode and transparent in night mode.
- The Simple UI and Bookshelf cards use the UI font.
- The sprite cache moved to `koreader/yomimon/sprites/`, so a plugin update no longer wipes it; sprites cached
  inside the plugin folder by earlier versions are moved there on first use.
- Module and data files renamed to English; the UI defaults to Portuguese unless English is chosen in the menu.

## 0.1.0 (2026-11-05)

- Fork of Silverfish 1.1.0, renamed to Yomimon: plugin folder `yomimon.koplugin`, state in `settings/yomimon.lua`,
  data in `koreader/yomimon/`, settings keys `yomimon_*`. Existing Silverfish progress is not migrated.
- README, CREDITS and art license updated with the modification notice, attribution and disclaimers.
- The first screen is now a creature picker (329 evolution families, Pokédex 1-649, A-Z shortcut). Each species
  evolves through its own line (1 to 3 forms) by pages read.
- No egg, death or lineage: the final form stays for good. Hunger stays; after days without reading the creature
  goes back to a ball.
- Sprites are downloaded on the device from PokeAPI/sprites (pinned commit), converted to the 64x64 grayscale
  grid and cached in `yomimon.koplugin/sprites/` (so they are lost if you replace the plugin folder; they download again). A generated ball is shown until then. The Silverfish sprites,
  icons and screenshots were removed.
- Text banks: lines about the old creature (egg, spine, antennae, molting...) were removed and 32 new base lines
  about Pokémon life were added, in Portuguese and English. More adaptation is still needed.

- Pokédex screen (ARCHIVE menu): every creature you picked keeps its own progress; tap one to switch back, or
  pick another. Fixed a crash on the achievements screen. Files and folders renamed to English (`yomimon_*`,
  `fonts/`, `icons/`, `yomimon_data/`); the Bookshelf module key is now `yomimon`, with a shelf option in setup.

## Silverfish history (upstream)

## 1.1.0 (2026-10-31)

- New: a Silverfish card for the [Bookshelf](https://github.com/AndyHazz/bookshelf.koplugin) plugin. Put it in
  the top panel or stand it on a shelf among your books. Narrow, it's just the silverfish; wider, it gets a
  speech bubble with what it's thinking. Tap it to open its screen. Tested with Bookshelf 6.0.4.

Your silverfish keeps its progress: to update, replace the `silverfish.koplugin` folder (see "Updating and
backups" in the README), or update from Storefront.

## 1.0.0 (2026-10-30)

First public release.

- A silverfish that hatches, eats the pages you read and grows through four stages (nymph, young, adult, elder),
  with generations and a family lineage.
- A personality shaped by your reading: 16 literary influences, picked up from the text of your books and from
  their EPUB genre tags, about 70 lines each, plus traits from your habits (night owl, bitter, bold, romantic…).
- It notices characters, words, places and events; comments on chapters; reviews finished books.
- Diary, notebook of your highlights, achievements, bookshelf and lineage.
- Sleep screen with dreams about your reading, and a sleeping drawing for each stage.
- Optional card and button for the Simple UI plugin.
- Portuguese and English.

Changes since the beta (2026-10-29):

- The plugin folder is now `silverfish.koplugin`. Delete the old `traca.koplugin` before installing; your
  silverfish keeps its progress.
- Literary influences speak more often and with much more variety (about 70 lines each, up from 12).
- The sleep screen shows only dreams, with a sleeping drawing for each stage, centred, without cards.
- New egg drawing.
- Fixed: after the silverfish screen was covered by another window (for example, Simple UI's home screen after
  waking up), leftover silverfish screens could pile up and show up when leaving KOReader.
- No developer mode in this version.
