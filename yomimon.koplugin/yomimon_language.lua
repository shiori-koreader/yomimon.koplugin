--[[--
Language support. Every language is a folder, yomimon_locales/<code>/, found by scanning that folder, so adding a
language is adding a folder (see yomimon_locales/README.md). The code is the English UI text itself: Language.t"Back"
returns the translation of "Back" from yomimon_locales/<code>/ui.lua, or the English text when there is none.

A locale folder holds:
  locale.lua        name and formats (clock, months, ordinals, thousands separator)
  ui.lua            { ["English text"] = "translation" }; English needs none
  content/<m>.lua   the phrase banks of module <m> (state, context, speech, memory)
  data/<bank>.lua   cards, diary, domains, extra, influences, traits, vector

Whatever a locale does not provide falls back to English.

Choice: the "yomimon_language" setting ("auto" or a code). "auto" follows the KOReader language when a locale
for it exists (pt_BR uses "pt"), English otherwise. The language is decided when the modules load, so changing
it asks for a restart.
]]

local Language = {}

local FALLBACK = "en"
local PLUGIN_DIR = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "plugins/yomimon.koplugin"

local current, translations
local manifests = {}

local function settings()
    return rawget(_G, "G_reader_settings")
end

local function load(name)
    local ok, mod = pcall(require, name)
    return ok and type(mod) == "table" and mod or nil
end

local function manifest(code)
    if manifests[code] == nil then
        manifests[code] = load("yomimon_locales." .. code .. ".locale") or false
    end
    return manifests[code] or nil
end

--- The locale codes found in yomimon_locales/, sorted. Without lfs (unit tests) only English and Portuguese are known.
function Language.codes()
    local ok, lfs = pcall(require, "libs/libkoreader-lfs")
    if not ok then return { "en", "pt" } end
    local codes = {}
    local listing, iter, state = pcall(lfs.dir, PLUGIN_DIR .. "/yomimon_locales")
    if not listing then return { FALLBACK } end
    -- lfs.dir returns the iterator and the directory object it needs as its state: both must reach the loop.
    for entry in iter, state do
        if entry:sub(1, 1) ~= "." and lfs.attributes(string.format("%s/yomimon_locales/%s/locale.lua", PLUGIN_DIR, entry), "mode") == "file" then
            codes[#codes + 1] = entry
        end
    end
    table.sort(codes)
    return codes
end

--- { code, name } of every available language, sorted by name.
function Language.available()
    local list = {}
    for _, code in ipairs(Language.codes()) do
        local m = manifest(code)
        if m then list[#list + 1] = { code = code, name = m.name or code } end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

--- "auto" or a locale code, as saved.
function Language.choice()
    local g = settings()
    return g and g:readSetting("yomimon_language") or "auto"
end

function Language.saveChoice(value)
    local g = settings()
    if not g then return end
    if value == "auto" then g:delSetting("yomimon_language") else g:saveSetting("yomimon_language", value) end
end

local function fromKOReader()
    local g = settings()
    local lang = g and g:readSetting("language")
    if not lang then return nil end
    lang = tostring(lang):lower()
    for _, candidate in ipairs({ lang, lang:match("^(%a+)") }) do
        if manifest(candidate) then return candidate end
    end
end

--- The language in use.
function Language.code()
    if current then return current end
    local choice = Language.choice()
    if choice ~= "auto" and manifest(choice) then
        current = choice
    elseif not settings() then
        current = "pt"
    else
        current = fromKOReader() or FALLBACK
    end
    return current
end

--- Tests only: forces a language (the modules must be reloaded afterwards).
function Language.force(code)
    current, translations = code, nil
end

--- Translated UI text, or the English text itself.
function Language.t(text)
    if Language.code() == FALLBACK then return text end
    translations = translations or load("yomimon_locales." .. Language.code() .. ".ui") or {}
    return translations[text] or text
end

local function pick(code, name)
    return load(string.format("yomimon_locales.%s.%s", code, name))
end

--- The phrase banks of a module ("state", "context", "speech", "memory") in the current language, falling back
-- to English.
function Language.content(name)
    return pick(Language.code(), "content." .. name) or pick(FALLBACK, "content." .. name)
end

--- A data bank ("cards", "diary", ...) in the current language, falling back to English; nil when neither has it.
function Language.data(name)
    return pick(Language.code(), "data." .. name) or pick(FALLBACK, "data." .. name)
end

--- Formats of the current language (see locale.lua), falling back to English.
function Language.format()
    local own = manifest(Language.code())
    local base = manifest(FALLBACK)
    return setmetatable(own and own.format or {}, { __index = base and base.format })
end

--- Appends the extra phrases of a module (yomimon_locales/<code>/data/extra.lua) to its lists: where `extra` has a list it
-- is added to the list of the same name in `base`, and nested tables are followed.
function Language.append(base, extra)
    if type(base) ~= "table" or type(extra) ~= "table" then return end
    for k, v in pairs(extra) do
        if type(v) == "table" and v[1] ~= nil then
            base[k] = base[k] or {}
            for _, item in ipairs(v) do table.insert(base[k], item) end
        elseif type(v) == "table" then
            base[k] = base[k] or {}
            Language.append(base[k], v)
        end
    end
end

--- The extra phrases of a module in the current language, or nil.
function Language.extra(name)
    local bank = Language.data("extra")
    return bank and bank[name] or nil
end

return Language
