--[[--
Sprites downloaded on the device: fetches the PNG of a species, converts it to the 64x64 grid and caches it in
koreader/yomimon/sprites/<dex>.txt, outside the plugin folder so a plugin update keeps it. No artwork ships with
the plugin: the cache is built on the device.
]]

local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")

local Sprite = require("yomimon_sprite")

local Baixar = {}

-- Pinned PokeAPI/sprites commit: the URL never changes content.
local URL = "https://raw.githubusercontent.com/PokeAPI/sprites/1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64"
    .. "/sprites/pokemon/versions/generation-v/black-white/%d.png"

local carregados = {}

local PASTA_PLUGIN = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "plugins/yomimon.koplugin"
local PASTA = require("datastorage"):getDataDir() .. "/yomimon/sprites"

-- Versions up to 0.1.1 cached inside the plugin folder, which an update wipes: bring those files over once.
local migrado = false
local function migrarCacheAntigo()
    local antiga = PASTA_PLUGIN .. "/sprites"
    if lfs.attributes(antiga, "mode") ~= "directory" then return end
    require("util").makePath(PASTA)
    for nome in lfs.dir(antiga) do
        if nome:match("%.txt$") then os.rename(antiga .. "/" .. nome, PASTA .. "/" .. nome) end
    end
    lfs.rmdir(antiga)
end

function Baixar.pasta()
    if not migrado then
        migrado = true
        pcall(migrarCacheAntigo)
    end
    return PASTA
end

local function caminho(dex)
    return string.format("%s/%d.txt", Baixar.pasta(), dex)
end

--- Lines of the sprite already stored, or nil.
function Baixar.carregar(dex)
    if carregados[dex] then return carregados[dex] end
    local arq = io.open(caminho(dex), "rb")
    if not arq then return nil end
    local linhas = Sprite.ler(arq:read("*a"))
    arq:close()
    carregados[dex] = linhas
    return linhas
end

function Baixar.tem(dex)
    return Baixar.carregar(dex) ~= nil
end

local URL_ESPECIE = "https://pokeapi.co/api/v2/pokemon-species/%d"

local function buscar(dex, url)
    local https = require("ssl.https")
    local ltn12 = require("ltn12")
    local socketutil = require("socketutil")
    local partes = {}
    socketutil:set_timeout(10, 30)
    local ok, status = https.request{ url = string.format(url or URL, dex), sink = ltn12.sink.table(partes) }
    socketutil:reset_timeout()
    if not ok or status ~= 200 then return nil, "HTTP " .. tostring(status) end
    return table.concat(partes)
end

local function decodificar(dados)
    local RenderImage = require("ui/renderimage")
    local bb = RenderImage:renderImageData(dados, #dados)
    if not bb then return nil, "unreadable PNG" end
    local function pixel(x, y)
        local c = bb:getPixel(x, y):getColorRGB32()
        return c.r, c.g, c.b, c.alpha
    end
    local linhas, err = Sprite.converter(bb:getWidth(), bb:getHeight(), pixel)
    bb:free()
    return linhas, err
end

local function caminhoDescricao(dex)
    return string.format("%s/%d.desc.txt", Baixar.pasta(), dex)
end

--- Pokédex description in English (PokeAPI has no Portuguese), already stored, or nil.
function Baixar.descricao(dex)
    local arq = io.open(caminhoDescricao(dex), "rb")
    if not arq then return nil end
    local texto = arq:read("*a")
    arq:close()
    return texto ~= "" and texto or nil
end

-- The PokeAPI answer carries dozens of texts; keep only the latest English one, on a single line and without
-- accents (the screen's pixel font has no "é" for "Pokémon").
function Baixar.extrairDescricao(dados)
    local entradas = require("json").decode(dados).flavor_text_entries or {}
    for i = #entradas, 1, -1 do
        local e = entradas[i]
        if e.language and e.language.name == "en" then
            local t = e.flavor_text:gsub("94{", ""):gsub("é", "e"):gsub("—", "-"):gsub("[’‘]", "'"):gsub("[“”]", '"'):gsub("[%c]+", " "):gsub("%s+", " ")
            return (t:gsub("^ ", ""):gsub(" $", ""))
        end
    end
end

function Baixar.baixarDescricao(dex)
    if Baixar.descricao(dex) then return true end
    local ok, dados = pcall(buscar, dex, URL_ESPECIE)
    if not ok or not dados then return nil end
    local okd, texto = pcall(Baixar.extrairDescricao, dados)
    if not okd or not texto or texto == "" then return nil end
    require("util").makePath(Baixar.pasta())
    local arq = io.open(caminhoDescricao(dex), "wb")
    if not arq then return nil end
    arq:write(texto)
    arq:close()
    return true
end

--- Downloads, converts and stores the sprite. Blocks until done (files of ~1 KB). Returns true or nil, reason.
local function baixarSprite(dex)
    if Baixar.tem(dex) then return true end
    local ok, dados, err = pcall(buscar, dex)
    if not ok then dados, err = nil, dados end
    if not dados then
        logger.warn("Yomimon: could not download the sprite", dex, err)
        return nil, err
    end
    local okd, linhas, errd = pcall(decodificar, dados)
    if not okd then linhas, errd = nil, linhas end
    if not linhas then
        logger.warn("Yomimon: could not convert the sprite", dex, errd)
        return nil, errd
    end
    require("util").makePath(Baixar.pasta())
    local arq, erro = io.open(caminho(dex), "wb")
    if not arq then return nil, erro end
    arq:write(Sprite.guardar(linhas))
    arq:close()
    carregados[dex] = linhas
    return true
end

--- Downloads the sprite and the description. The description is an extra: it does not count in the result.
function Baixar.baixar(dex)
    local ok, err = baixarSprite(dex)
    if ok then pcall(Baixar.baixarDescricao, dex) end
    return ok, err
end

--- Downloads every form of a line ({ dex, dex, … }). Returns true if all are stored.
function Baixar.linha(dexes)
    local tudo = true
    for _, dex in ipairs(dexes) do
        if not Baixar.baixar(dex) then tudo = false end
    end
    return tudo
end

return Baixar
