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
