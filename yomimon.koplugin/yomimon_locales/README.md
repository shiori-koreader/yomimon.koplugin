# Adding a language

A language is a folder here, named with the short code the KOReader language starts with (`pt`, `es`, `de`...).
The plugin finds it by itself and lists it in *Yomimon > Language*. Whatever the folder does not provide falls back
to English, so a language can ship incomplete and grow.

```
yomimon_locales/<code>/
  locale.lua        required: name and formats
  ui.lua            menu and screen texts
  content/          phrase banks of the modules: state.lua, context.lua, speech.lua, memory.lua
  data/             cards.lua, diary.lua, domains.lua, extra.lua, influences.lua, traits.lua, vector.lua
```

Start by copying `locales/en/` to `yomimon_locales/<code>/` and translating in place.

- **locale.lua** returns `{ name = "Español", format = { clock, months, ordinals, thousands } }`.
- **ui.lua** returns `{ ["English text"] = "translation" }`. The keys are the English texts used by the code
  (`T"Back"`), so a missing key shows the English text. `lua scripts/check_locales.lua` lists what is untranslated.
- **content/** and **data/** keep the structure of the English files: only the phrases change. Keep the `%s` and
  `{name}` gaps and the `<trait:text|other>` choices as they are.
- `content/memory.lua` may define `NOMES` (each theme with its article, as English does) when the language does
  not use the built-in Portuguese article-plus-preposition grammar.

Language-neutral data (`yomimon_data/`, the sentiment lexicons) is not part of a locale.
