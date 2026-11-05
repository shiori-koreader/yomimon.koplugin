--[[--
Converte uma imagem RGBA em um sprite de 64x64 no formato de texto do desenho (' ', '4', '3', '2', '1', '#').

Lógica pura (sem dependências do KOReader), para rodar também no PC.
]]

local Sprite = {}

Sprite.LADO = 64
local MARGEM = 2
local CABE = Sprite.LADO - 2 * MARGEM

-- parte da média no tom da célula; o resto vem do pixel mais escuro, que mantém o contorno do desenho
local MEDIA = 0.5

-- limiares de luminância (0-255) para os tons EE, BB, 88, 55 e preto
local TONS = { { 0xF6, "4" }, { 0xB8, "3" }, { 0x78, "2" }, { 0x3C, "1" } }

local function tom(lum)
    for _, t in ipairs(TONS) do
        if lum >= t[1] then return t[2] end
    end
    return "#"
end

--- pixel(x, y) com x e y a partir de 0 devolve r, g, b, alfa (0-255). Devolve 64 linhas de 64 caracteres.
-- Sem canal alfa útil (tudo opaco), o fundo é a cor do canto superior esquerdo.
function Sprite.converter(w, h, pixel)
    if not w or not h or w < 1 or h < 1 then return nil, "imagem vazia" end
    local lum, alfa = {}, {}
    local opaco = true
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = pixel(x, y)
            local i = y * w + x + 1
            -- cor pré-multiplicada: soma o branco que falta para compor sobre o papel
            local c = (0.299 * r + 0.587 * g + 0.114 * b)
            if a < 255 then
                opaco = false
                c = math.min(255, c + (255 - a))
            end
            lum[i], alfa[i] = c, a
        end
    end
    if opaco then
        local r0, g0, b0 = pixel(0, 0)
        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local r, g, b = pixel(x, y)
                if math.abs(r - r0) + math.abs(g - g0) + math.abs(b - b0) < 24 then alfa[y * w + x + 1] = 0 end
            end
        end
    end
    local x0, y0, x1, y1 = w, h, -1, -1
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            if alfa[y * w + x + 1] >= 128 then
                if x < x0 then x0 = x end
                if x > x1 then x1 = x end
                if y < y0 then y0 = y end
                if y > y1 then y1 = y end
            end
        end
    end
    if x1 < 0 then return nil, "sem pixels visíveis" end
    local bw, bh = x1 - x0 + 1, y1 - y0 + 1
    local escala = math.min(CABE / bw, CABE / bh, 1)
    local tw, th = math.max(1, math.floor(bw * escala + 0.5)), math.max(1, math.floor(bh * escala + 0.5))
    local ox, oy = math.floor((Sprite.LADO - tw) / 2), Sprite.LADO - MARGEM - th
    local passo_x, passo_y = bw / tw, bh / th
    local linhas = {}
    for j = 0, Sprite.LADO - 1 do
        local linha = {}
        for i = 0, Sprite.LADO - 1 do
            local c = " "
            local ti, tj = i - ox, j - oy
            if ti >= 0 and ti < tw and tj >= 0 and tj < th then
                local sx0, sx1 = x0 + ti * passo_x, x0 + (ti + 1) * passo_x
                local sy0, sy1 = y0 + tj * passo_y, y0 + (tj + 1) * passo_y
                local peso, cob, soma, minimo = 0, 0, 0, 255
                for sy = math.floor(sy0), math.ceil(sy1) - 1 do
                    local wy = math.min(sy + 1, sy1) - math.max(sy, sy0)
                    for sx = math.floor(sx0), math.ceil(sx1) - 1 do
                        local wx = math.min(sx + 1, sx1) - math.max(sx, sx0)
                        local wgt = wx * wy
                        peso = peso + wgt
                        if sx >= 0 and sx < w and sy >= 0 and sy < h then
                            local k = sy * w + sx + 1
                            local a = alfa[k] / 255
                            cob = cob + wgt * a
                            soma = soma + wgt * a * lum[k]
                            if alfa[k] >= 128 and lum[k] < minimo then minimo = lum[k] end
                        end
                    end
                end
                if peso > 0 and cob / peso >= 0.45 then c = tom(MEDIA * soma / cob + (1 - MEDIA) * minimo) end
            end
            linha[#linha + 1] = c
        end
        linhas[#linhas + 1] = table.concat(linha)
    end
    return linhas
end

--- Lê um sprite guardado (uma linha por linha do desenho). Devolve nil se não tiver 64 linhas de 64 caracteres.
function Sprite.ler(texto)
    if type(texto) ~= "string" then return nil end
    local linhas = {}
    for l in texto:gmatch("([^\r\n]*)\r?\n?") do
        if l ~= "" or #linhas < Sprite.LADO then linhas[#linhas + 1] = l end
        if #linhas == Sprite.LADO then break end
    end
    if #linhas ~= Sprite.LADO then return nil end
    for _, l in ipairs(linhas) do
        if #l ~= Sprite.LADO or l:find("[^ 1234#]") then return nil end
    end
    return linhas
end

function Sprite.guardar(linhas)
    return table.concat(linhas, "\n") .. "\n"
end

--- Bola de reserva: usada enquanto o sprite do bichinho não foi baixado (ou sem internet).
function Sprite.bola()
    local lado, c = Sprite.LADO, (Sprite.LADO - 1) / 2
    local raio = 26
    local cy = lado - MARGEM - raio - 0.5
    local linhas = {}
    for j = 0, lado - 1 do
        local linha = {}
        for i = 0, lado - 1 do
            local dx, dy = i - c, j - cy
            local d = math.sqrt(dx * dx + dy * dy)
            local ch = " "
            if d <= raio then
                if d > raio - 2 or math.abs(dy) < 2 then
                    ch = "#"
                elseif d < 7 then
                    ch = d > 5 and "#" or "4"
                elseif dy < 0 then
                    ch = "2"
                else
                    ch = "4"
                end
            end
            linha[#linha + 1] = ch
        end
        linhas[#linhas + 1] = table.concat(linha)
    end
    return linhas
end

local GRIS = { ["#"] = 0, ["1"] = 0x55, ["2"] = 0x88, ["3"] = 0xBB, ["4"] = 0xEE }

--- Menor retângulo que contém o desenho: x, y (a partir de 0), largura e altura; nil se estiver vazio.
function Sprite.caixa(linhas)
    local x0, y0, x1, y1 = Sprite.LADO, Sprite.LADO, -1, -1
    for j, l in ipairs(linhas) do
        for i = 1, #l do
            if GRIS[l:sub(i, i)] then
                x0, x1 = math.min(x0, i - 1), math.max(x1, i - 1)
                y0, y1 = math.min(y0, j - 1), math.max(y1, j - 1)
            end
        end
    end
    if x1 < 0 then return nil end
    return x0, y0, x1 - x0 + 1, y1 - y0 + 1
end

--- Tom de cinza (0-255) de um caractere do desenho, ou nil se for fundo.
function Sprite.cinza(c)
    return GRIS[c]
end

return Sprite
