--[[--
Sprites baixados no aparelho: busca o PNG de uma espécie, converte para a grade de 64x64 e guarda em
<pasta do plugin>/sprites/<dex>.txt. Nenhuma arte vem no plugin: o cache é criado no aparelho.
]]

local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")

local Sprite = require("yomimon_sprite")

local Baixar = {}

-- Commit fixo do PokeAPI/sprites: a URL nunca muda de conteúdo.
local URL = "https://raw.githubusercontent.com/PokeAPI/sprites/1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64"
    .. "/sprites/pokemon/versions/generation-v/black-white/%d.png"

local carregados = {}

-- Pasta do plugin, tirada do próprio arquivo (como em yomimon_drawing.lua).
local PASTA_PLUGIN = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "plugins/yomimon.koplugin"

function Baixar.pasta()
    return PASTA_PLUGIN .. "/sprites"
end

local function caminho(dex)
    return string.format("%s/%d.txt", Baixar.pasta(), dex)
end

--- Linhas do sprite já guardado, ou nil.
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
    if not bb then return nil, "PNG ilegível" end
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

--- Descrição da Pokédex em inglês (o PokeAPI não tem português), já guardada, ou nil.
function Baixar.descricao(dex)
    local arq = io.open(caminhoDescricao(dex), "rb")
    if not arq then return nil end
    local texto = arq:read("*a")
    arq:close()
    return texto ~= "" and texto or nil
end

-- A resposta do PokeAPI traz dezenas de textos; guarda só o inglês mais recente, numa linha só e sem acento
-- (a fonte pixel da tela não tem o "é" de "Pokémon").
local function extrairDescricao(dados)
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
    local okd, texto = pcall(extrairDescricao, dados)
    if not okd or not texto or texto == "" then return nil end
    lfs.mkdir(Baixar.pasta())
    local arq = io.open(caminhoDescricao(dex), "wb")
    if not arq then return nil end
    arq:write(texto)
    arq:close()
    return true
end

--- Baixa, converte e guarda o sprite. Bloqueia até terminar (arquivos de ~1 KB). Devolve true ou nil, motivo.
local function baixarSprite(dex)
    if Baixar.tem(dex) then return true end
    local ok, dados, err = pcall(buscar, dex)
    if not ok then dados, err = nil, dados end
    if not dados then
        logger.warn("Yomimon: não baixou o sprite", dex, err)
        return nil, err
    end
    local okd, linhas, errd = pcall(decodificar, dados)
    if not okd then linhas, errd = nil, linhas end
    if not linhas then
        logger.warn("Yomimon: não converteu o sprite", dex, errd)
        return nil, errd
    end
    lfs.mkdir(Baixar.pasta())
    local arq, erro = io.open(caminho(dex), "wb")
    if not arq then return nil, erro end
    arq:write(Sprite.guardar(linhas))
    arq:close()
    carregados[dex] = linhas
    return true
end

--- Baixa o sprite e a descrição. A descrição é um extra: não conta no resultado.
function Baixar.baixar(dex)
    local ok, err = baixarSprite(dex)
    if ok then pcall(Baixar.baixarDescricao, dex) end
    return ok, err
end

--- Baixa todas as formas de uma linha ({ dex, dex, … }). Devolve true se todas estão guardadas.
function Baixar.linha(dexes)
    local tudo = true
    for _, dex in ipairs(dexes) do
        if not Baixar.baixar(dex) then tudo = false end
    end
    return tudo
end

return Baixar
