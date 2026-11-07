std = "luajit"
max_line_length = false
ignore = { "212", "213", "311" }
globals = { "G_reader_settings" }
exclude_files = { ".lua", ".luarocks", "dist", "yomimon.koplugin/yomimon_locales", "yomimon.koplugin/yomimon_cities.lua", "yomimon.koplugin/yomimon_common_words.lua",
                  "yomimon.koplugin/yomimon_lexicon_en.lua", "yomimon.koplugin/yomimon_lexicon_pt.lua", "yomimon.koplugin/yomimon_species.lua" }
files["tests/yomimon_test.lua"] = { ignore = { "121", "143" } }
files["tests/yomimon_screens_test.lua"] = { ignore = { "121", "122", "143" } }
