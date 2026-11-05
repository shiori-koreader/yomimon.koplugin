--[[--
Guarda: nenhum erro da Yomimon pode interromper a leitura.

Todo ponto em que o KOReader chama a Yomimon (eventos de página, dormir/acordar, abrir a tela,
desenhar, toques, animação, cartão da Home) passa por aqui. Um erro vira uma linha no log e
a chamada simplesmente não acontece. Depois de LIMITE erros NO MESMO ponto de entrada durante a
sessão (ex.: 3 páginas falhando), a Yomimon inteira se cala até o KOReader reiniciar e avisa uma vez.
Acertos no meio não zeram a conta: um bug real costuma falhar só às vezes (ex.: só nas páginas que
contam como lidas), e virar páginas rápidas dá certo entre uma falha e outra.

Lógica pura (sem KOReader): main.lua configura como registrar e como avisar.
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

--- Define como registrar erros e como avisar quando desligar (main.lua chama ao iniciar).
function Guarda:configurar(registrar, ao_desligar)
    self.registrar, self.ao_desligar = registrar, ao_desligar
end

--- Chama fn(...) protegida. Devolve true e os resultados, ou false se falhou ou está desligada.
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

--- Troca métodos de `tabela` por versões protegidas. Se falhar (ou estiver desligada) e houver
-- `alternativa`, ela roda no lugar com os mesmos argumentos (ex.: desenhar uma tela simples).
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

-- Um guarda para a sessão inteira do KOReader (todos os módulos usam o mesmo).
Guarda.padrao = Guarda.novo()

return Guarda
