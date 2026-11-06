--[[--
Card box: phrases written by you for the right moments (yomimon_locales/<code>/data/cards.lua).

When a chapter talks about a subject (yomimon_memory.lua, M.cartaoDoCapitulo), the first card that fits
is stored in s.cartao_pendente. It becomes the next Home phrase for up to 24 hours (Estado.fala). If it does
not fit in the Home's 2 lines, it waits for the Yomimon screen (Estado.falaQueCabe marks `nao_coube`). When it says the
phrase, the card records what it has to record (s.gravado) and, if it is one-time, enters s.cartoes_ditos.
Both live its life: a fresh start begins without them.
]]

local Lingua = require("yomimon_language")

local Cartoes = {}

Cartoes.VALIDADE = 24 * 3600  -- how long the stored card waits to be said

local caixa
--- The cards in the current language (list, in the file's order).
function Cartoes.caixa()
    if caixa == nil then
        local ok, b = pcall(Lingua.data, "cards")
        caixa = ok and type(b) == "table" and b or false
    end
    return caixa or {}
end

--- Swaps the box (for tests); nil goes back to reading the file.
function Cartoes.usarCaixa(b) caixa = b end

local function serve(s, c, assuntos, dados)
    local q = c.quando or {}
    if c.desligado or type(c.fala) ~= "string" or c.fala == "" then return false end
    if q.assunto and not assuntos[q.assunto] then return false end
    if q.fase and dados.fase ~= q.fase then return false end
    if q.gravado and not (s.gravado or {})[q.gravado] then return false end
    if c.uma_vez and (s.cartoes_ditos or {})[c.id] then return false end
    return true
end

--- A chapter talked about `assuntos` ({ pressagio = true, … }): stores the first card that fits.
-- dados: { personagem = name of who appears most in the chapter (or nil), fase = "jovem"… }. A card with
-- {personagem} without a character does not fit. While a stored card has not been said, no other enters.
-- Returns true if it stored one.
function Cartoes.capitulo(s, assuntos, dados, agora, livro)
    local p = s.cartao_pendente
    if p and not p.usado and agora - (p.t or 0) < Cartoes.VALIDADE then return false end
    for _, c in ipairs(Cartoes.caixa()) do
        if serve(s, c, assuntos, dados) then
            local texto = c.fala
            if texto:find("{personagem}", 1, true) then
                texto = dados.personagem and texto:gsub("{personagem}", (dados.personagem:gsub("%%", "%%%%"))) or nil
            end
            if texto then
                local okV, Voz = pcall(require, "yomimon_voice")
                if okV then texto = (Voz.resolver(texto, s)) end
                s.cartao_pendente = { id = c.id, texto = texto, t = agora, livro = livro, grava = c.grava,
                                      uma_vez = c.uma_vez or nil }
                return true
            end
        end
    end
    return false
end

--- The stored card that can be said now on this screen, or nil: on the Home; on the Yomimon screen only after
-- not fitting on the Home.
function Cartoes.pendente(s, agora, tela)
    local p = s.cartao_pendente
    if not p or p.usado or agora - (p.t or 0) >= Cartoes.VALIDADE then return nil end
    if tela == "home" or (tela == "traca" and p.nao_coube) then return p end
    return nil
end

--- It said the stored card: records what it records and, if it is one-time, stores the id.
function Cartoes.dito(s, p, agora)
    p.usado = true
    if p.grava then
        s.gravado = s.gravado or {}
        s.gravado[p.grava] = s.gravado[p.grava] or agora
    end
    if p.uma_vez then
        s.cartoes_ditos = s.cartoes_ditos or {}
        s.cartoes_ditos[p.id] = agora
    end
end

return Cartoes
