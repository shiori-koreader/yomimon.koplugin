--[[--
Sprites downloaded on the device: fetches the PNG of a species, converts it to the 64x64 grid and caches it in
koreader/yomimon/sprites/<dex>.txt, outside the plugin folder so a plugin update keeps it. No artwork ships with
the plugin: the cache is built on the device.
]]

local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")

local Sprite = require("yomimon_sprite")

local Download = {}

-- Pinned PokeAPI/sprites commit: the URL never changes content.
local URL = "https://raw.githubusercontent.com/PokeAPI/sprites/1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64"
    .. "/sprites/pokemon/versions/generation-v/black-white/%d.png"

local loaded = {}

local PLUGIN_FOLDER = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "plugins/yomimon.koplugin"
local FOLDER = require("datastorage"):getDataDir() .. "/yomimon/sprites"

-- Versions up to 0.1.1 cached inside the plugin folder, which an update wipes: bring those files over once.
local migrated = false
local function migrateOldCache()
    local oldFolder = PLUGIN_FOLDER .. "/sprites"
    if lfs.attributes(oldFolder, "mode") ~= "directory" then return end
    require("util").makePath(FOLDER)
    for nameText in lfs.dir(oldFolder) do
        if nameText:match("%.txt$") then os.rename(oldFolder .. "/" .. nameText, FOLDER .. "/" .. nameText) end
    end
    lfs.rmdir(oldFolder)
end

function Download.folder()
    if not migrated then
        migrated = true
        pcall(migrateOldCache)
    end
    return FOLDER
end

local function path(dex)
    return string.format("%s/%d.txt", Download.folder(), dex)
end

--- Lines of the sprite already stored, or nil.
function Download.loadFile(dex)
    if loaded[dex] then return loaded[dex] end
    local file_handle = io.open(path(dex), "rb")
    if not file_handle then return nil end
    local lines = Sprite.readFile(file_handle:read("*a"))
    file_handle:close()
    loaded[dex] = lines
    return lines
end

function Download.has(dex)
    return Download.loadFile(dex) ~= nil
end

local SPECIES_URL = "https://pokeapi.co/api/v2/pokemon-species/%d"

local function fetch(dex, url)
    local https = require("ssl.https")
    local ltn12 = require("ltn12")
    local socketutil = require("socketutil")
    local parts = {}
    socketutil:set_timeout(10, 30)
    local ok, status = https.request{ url = string.format(url or URL, dex), sink = ltn12.sink.table(parts) }
    socketutil:reset_timeout()
    if not ok or status ~= 200 then return nil, "HTTP " .. tostring(status) end
    return table.concat(parts)
end

local function decode(data)
    local RenderImage = require("ui/renderimage")
    local bb = RenderImage:renderImageData(data, #data)
    if not bb then return nil, "unreadable PNG" end
    local function pixel(x, y)
        local c = bb:getPixel(x, y):getColorRGB32()
        return c.r, c.g, c.b, c.alpha
    end
    local lines, err = Sprite.convert(bb:getWidth(), bb:getHeight(), pixel)
    bb:free()
    return lines, err
end

local function descriptionPath(dex)
    return string.format("%s/%d.desc.txt", Download.folder(), dex)
end

--- Pokédex description in English (PokeAPI has no Portuguese), already stored, or nil.
function Download.description(dex)
    local file_handle = io.open(descriptionPath(dex), "rb")
    if not file_handle then return nil end
    local textValue = file_handle:read("*a")
    file_handle:close()
    return textValue ~= "" and textValue or nil
end

-- The PokeAPI answer carries dozens of texts; keep only the latest English one, on a single line and without
-- accents (the screen's pixel font has no "é" for "Pokémon").
function Download.extractDescription(data)
    local entries = require("json").decode(data).flavor_text_entries or {}
    for i = #entries, 1, -1 do
        local e = entries[i]
        if e.language and e.language.name == "en" then
            local t = e.flavor_text:gsub("94{", ""):gsub("é", "e"):gsub("—", "-"):gsub("[’‘]", "'"):gsub("[“”]", '"'):gsub("[%c]+", " "):gsub("%s+", " ")
            return (t:gsub("^ ", ""):gsub(" $", ""))
        end
    end
end

function Download.downloadDescription(dex)
    if Download.description(dex) then return true end
    local ok, data = pcall(fetch, dex, SPECIES_URL)
    if not ok or not data then return nil end
    local okText, textValue = pcall(Download.extractDescription, data)
    if not okText or not textValue or textValue == "" then return nil end
    require("util").makePath(Download.folder())
    local file_handle = io.open(descriptionPath(dex), "wb")
    if not file_handle then return nil end
    file_handle:write(textValue)
    file_handle:close()
    return true
end

--- Downloads, converts and stores the sprite. Blocks until done (files of ~1 KB). Returns true or nil, reason.
local function downloadSprite(dex)
    if Download.has(dex) then return true end
    local ok, data, err = pcall(fetch, dex)
    if not ok then data, err = nil, data end
    if not data then
        logger.warn("Yomimon: could not download the sprite", dex, err)
        return nil, err
    end
    local okText, lines, errd = pcall(decode, data)
    if not okText then lines, errd = nil, lines end
    if not lines then
        logger.warn("Yomimon: could not convert the sprite", dex, errd)
        return nil, errd
    end
    require("util").makePath(Download.folder())
    local file_handle, errorText = io.open(path(dex), "wb")
    if not file_handle then return nil, errorText end
    file_handle:write(Sprite.store(lines))
    file_handle:close()
    loaded[dex] = lines
    return true
end

--- Downloads the sprite and the description. The description is an extra: it does not count in the result.
function Download.download(dex)
    local ok, err = downloadSprite(dex)
    if ok then pcall(Download.downloadDescription, dex) end
    return ok, err
end

--- Downloads every form of a line ({ dex, dex, … }). Returns true if all are stored.
function Download.line(dexes)
    local everything = true
    for _, dex in ipairs(dexes) do
        if not Download.download(dex) then everything = false end
    end
    return everything
end

return Download
