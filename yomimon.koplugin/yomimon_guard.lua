--[[--
Guard: no Yomimon error may interrupt reading.

Every point where KOReader calls Yomimon (page events, sleep/wake, opening the screen,
painting, taps, animation, the Home card) goes through here. An error becomes a log line and
the call simply does not happen. After LIMITE errors AT THE SAME entry point during the
session (e.g. 3 failing pages), the whole Yomimon goes quiet until KOReader restarts and warns once.
Successes in between do not reset the count: a real bug usually fails only sometimes (e.g. only on pages
that count as read), and quick page turns work between one failure and the next.

Pure logic (no KOReader): main.lua configures how to log and how to warn.
]]

local Guarda = {}
Guarda.__index = Guarda

Guarda.LIMITE = 3

local function empacotar(...) return { n = select("#", ...), ... } end

function Guarda.novo(opcoes)
    opcoes = opcoes or {}
    return setmetatable({
        limite = opcoes.limite or Guarda.LIMITE,
        falhas = {}, total = 0, desligada = false,
        registrar = opcoes.registrar, ao_desligar = opcoes.ao_desligar,
    }, Guarda)
end

--- Defines how to log errors and how to warn when shutting down (main.lua calls it at startup).
function Guarda:configurar(registrar, ao_desligar)
    self.registrar, self.ao_desligar = registrar, ao_desligar
end

--- Calls fn(...) protected. Returns true and the results, or false if it failed or is switched off.
function Guarda:chamar(nome, fn, ...)
    if self.desligada then return false end
    local args = empacotar(...)
    local r = empacotar(xpcall(function() return fn(unpack(args, 1, args.n)) end, debug.traceback))
    if r[1] then return true, unpack(r, 2, r.n) end
    self.falhas[nome], self.total = (self.falhas[nome] or 0) + 1, self.total + 1
    if self.registrar then pcall(self.registrar, nome, r[2]) end
    if self.falhas[nome] >= self.limite and not self.desligada then
        self.desligada = true
        if self.ao_desligar then pcall(self.ao_desligar, nome, r[2]) end
    end
    return false
end

--- Replaces methods of `tabela` with protected versions. If one fails (or is switched off) and there is an
-- `alternativa`, it runs instead with the same arguments (e.g. drawing a simple screen).
function Guarda:envolver(tabela, nomes, alternativa)
    for _, nome in ipairs(nomes) do
        local original = rawget(tabela, nome)
        if original then
            tabela[nome] = function(...)
                local r = empacotar(self:chamar(nome, original, ...))
                if r[1] then return unpack(r, 2, r.n) end
                if alternativa then
                    local ok, res = pcall(alternativa, nome, ...)
                    if ok then return res end
                end
            end
        end
    end
end

-- One guard for the whole KOReader session (all modules share it).
Guarda.padrao = Guarda.novo()

return Guarda
