-- Run from the repository root: lua tests/yomimon_test.lua
package.path = "yomimon.koplugin/?.lua;" .. package.path
unpack = unpack or table.unpack

local Estado = require("yomimon_state")
local Sprite = require("yomimon_sprite")

local t0 = 1000000

local s = Estado.normalizar(nil, t0)
assert(Estado.fase(s).nome == "bola", "no species yet: a ball")

s.especie = 1
local formas = Estado.formas(s)
assert(#formas == 3 and formas[1].titulo == "Bulbasaur" and formas[3].titulo == "Venusaur")
local ocorreu = Estado.comer(s, 160000, "x", t0 + 10)
assert(ocorreu.evoluiu and ocorreu.evoluiu.titulo == "Ivysaur")
Estado.comer(s, 700000, "x", t0 + 20)
local pf = Estado.progressoFase(s)
assert(not pf.proxima and pf.fracao == 1 and pf.paginas == 0, "final form has no next step")
assert(Estado.fase(s).titulo == "Venusaur")

s.especie = 54
assert(#Estado.formas(s) == 2 and Estado.formas(s)[2].titulo == "Golduck")

s.hibernando = true
assert(Estado.sprite(s, t0 + 30):match("^bola_casulo"), "hibernating shows the ball")

local function quadrado(x, y)
    if x >= 8 and x < 24 and y >= 8 and y < 24 then return 0, 0, 0, 255 end
    return 0, 0, 0, 0
end
local linhas = assert(Sprite.converter(32, 32, quadrado))
assert(#linhas == 64 and #linhas[1] == 64)
assert(Sprite.ler(Sprite.guardar(linhas)), "round trip")
assert(linhas[62]:find("#", 1, true), "sprite sits on the bottom margin")
assert(not Sprite.converter(4, 4, function() return 0, 0, 0, 0 end), "empty image is rejected")
assert(#Sprite.bola() == 64)

local t = Estado.normalizar(nil, t0)
Estado.trocarEspecie(t, 1)
Estado.comer(t, 200000, "x", t0 + 5)
Estado.trocarEspecie(t, 54)
assert(t.letras == 0 and t.colecao[1] >= 200000, "switching keeps the old progress")
Estado.comer(t, 5000, "x", t0 + 10)
Estado.trocarEspecie(t, 1)
assert(t.letras >= 200000 and Estado.fase(t).titulo == "Ivysaur", "progress comes back")
local c = Estado.colecao(t)
assert(#c == 2 and c[1].atual and c[1].base == 1)

print("ok")

-- Languages: each locale loads, falls back to English and formats its own clock.
local Lingua = require("yomimon_language")
Lingua.force("en")
assert(Lingua.t("BACK") == "BACK")
assert(Lingua.format().clock({ hour = 14, min = 5 }) == "2:05 p.m.")
assert(Lingua.content("state").FALAS)
Lingua.force("pt")
assert(Lingua.t("BACK") ~= "BACK")
assert(Lingua.t("Untranslated text") == "Untranslated text")
assert(Lingua.format().clock({ hour = 14, min = 0 }) == "14h")
assert(Lingua.data("cards"))
Lingua.force("xx")
assert(Lingua.t("BACK") == "BACK", "unknown locale falls back to English")
assert(Lingua.content("state") and Lingua.format().thousands == ",")
print("ok languages")

-- lfs.dir returns the iterator and the directory object it needs as state; the language scan must pass both.
do
    local real = package.loaded["libs/libkoreader-lfs"]
    package.loaded["libs/libkoreader-lfs"] = {
        dir = function()
            local list, i = { ".", "..", "en", "pt", "README.md" }, 0
            return function(state)
                assert(state == "dir object", "the iterator lost its state")
                i = i + 1
                return list[i]
            end, "dir object"
        end,
        attributes = function(path) return not path:find("README") and "file" or nil end,
    }
    local codes = Lingua.codes()
    assert(#codes == 2 and codes[1] == "en" and codes[2] == "pt", table.concat(codes, ","))
    package.loaded["libs/libkoreader-lfs"] = real
end
print("ok language scan")

-- Pokédex description: keeps the latest English entry on one line, without characters the pixel font lacks.
package.loaded["libs/libkoreader-lfs"] = {}
package.loaded["logger"] = { warn = function() end }
package.loaded["datastorage"] = { getDataDir = function() return "." end }
package.loaded["json"] = { decode = function()
    return { flavor_text_entries = {
        { language = { name = "es" }, flavor_text = "Hola" },
        { language = { name = "en" }, flavor_text = "Old text." },
        { language = { name = "en" }, flavor_text = "Spends 18 hours\nsleeping.\f  The Pok\195\169mon\226\128\148teleports." },
        { language = { name = "fr" }, flavor_text = "Salut" },
    } }
end }
local Baixar = require("yomimon_download")
assert(Baixar.extrairDescricao("{}") == "Spends 18 hours sleeping. The Pokemon-teleports.", Baixar.extrairDescricao("{}"))
print("ok description")
