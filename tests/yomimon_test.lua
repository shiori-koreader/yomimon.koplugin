-- Run from the repository root: lua tests/yomimon_test.lua
package.path = "yomimon.koplugin/?.lua;" .. package.path
unpack = unpack or table.unpack

local State = require("yomimon_state")
local Sprite = require("yomimon_sprite")

local t0 = 1000000

local s = State.normalize(nil, t0)
assert(State.stage(s).nameText == "ball", "no species yet: a ball")

s.species = 1
local forms = State.forms(s)
assert(#forms == 3 and forms[1].titleText == "Bulbasaur" and forms[3].titleText == "Venusaur")
local occurred = State.eat(s, 160000, "x", t0 + 10)
assert(occurred.evolved and occurred.evolved.titleText == "Ivysaur")
State.eat(s, 700000, "x", t0 + 20)
local pf = State.stageProgress(s)
assert(not pf.nextForm and pf.fraction == 1 and pf.pages == 0, "final form has no next step")
assert(State.stage(s).titleText == "Venusaur")

s.species = 54
assert(#State.forms(s) == 2 and State.forms(s)[2].titleText == "Golduck")

s.hibernating = true
assert(State.sprite(s, t0 + 30):match("^ball_cocoon"), "hibernating shows the ball")

local function quadrado(x, y)
    if x >= 8 and x < 24 and y >= 8 and y < 24 then return 0, 0, 0, 255 end
    return 0, 0, 0, 0
end
local lines = assert(Sprite.convert(32, 32, quadrado))
assert(#lines == 64 and #lines[1] == 64)
assert(Sprite.readFile(Sprite.store(lines)), "round trip")
assert(lines[62]:find("#", 1, true), "sprite sits on the bottom margin")
assert(not Sprite.convert(4, 4, function() return 0, 0, 0, 0 end), "empty image is rejected")
assert(#Sprite.ball() == 64)

local t = State.normalize(nil, t0)
State.switchSpecies(t, 1)
State.eat(t, 200000, "x", t0 + 5)
State.switchSpecies(t, 54)
assert(t.letters == 0 and t.collection[1] >= 200000, "switching keeps the old progress")
State.eat(t, 5000, "x", t0 + 10)
State.switchSpecies(t, 1)
assert(t.letters >= 200000 and State.stage(t).titleText == "Ivysaur", "progress comes back")
local c = State.collection(t)
assert(#c == 2 and c[1].current and c[1].base == 1)

print("ok")

-- Languages: each locale loads, falls back to English and formats its own clock.
local Language = require("yomimon_language")
Language.force("en")
assert(Language.t("BACK") == "BACK")
assert(Language.format().clock({ hour = 14, min = 5 }) == "2:05 p.m.")
assert(Language.content("state").SPEECHES)
Language.force("pt")
assert(Language.t("BACK") ~= "BACK")
assert(Language.t("Untranslated text") == "Untranslated text")
assert(Language.format().clock({ hour = 14, min = 0 }) == "14h")
assert(Language.data("cards"))
Language.force("xx")
assert(Language.t("BACK") == "BACK", "unknown locale falls back to English")
assert(Language.content("state") and Language.format().thousands == ",")
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
    local codes = Language.codes()
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
local Download = require("yomimon_download")
assert(Download.extractDescription("{}") == "Spends 18 hours sleeping. The Pokemon-teleports.", Download.extractDescription("{}"))
print("ok description")
