--[[--
Caixa de cartões: falas escritas por você para momentos certos (locales/<code>/data/cards.lua).

Quando um capítulo fala de um assunto (yomimon_memory.lua, M.cartaoDoCapitulo), o primeiro cartão que serve
fica guardado em s.cartao_pendente. Ele vira a próxima fala da Home por até 24 horas (Estado.fala). Se não
couber nas 2 linhas da Home, espera a tela da Yomimon (Estado.falaQueCabe marca `nao_coube`). Quando ela diz a
fala, o cartão grava o que tiver de gravar (s.gravado) e, se for de uma vez só, entra em s.cartoes_ditos.
Os dois vivem a vida dela: o ovo novo começa sem eles.
]]

local Lingua = require("yomimon_language")

local Cartoes = {}

Cartoes.VALIDADE = 24 * 3600  -- quanto tempo o cartão guardado espera para ser dito

local caixa
--- Os cartões no idioma atual (lista, na ordem do arquivo).
function Cartoes.caixa()
    if caixa == nil then
        local ok, b = pcall(Lingua.data, "cards")
        caixa = ok and type(b) == "table" and b or false
    end
    return caixa or {}
end

--- Troca a caixa (para testes); nil volta a ler o arquivo.
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

--- Um capítulo falou de `assuntos` ({ pressagio = true, … }): guarda o primeiro cartão que serve.
-- dados: { personagem = nome de quem mais aparece no capítulo (ou nil), fase = "jovem"… }. Cartão com
-- {personagem} sem personagem não serve. Enquanto um cartão guardado não foi dito, não entra outro.
-- Devolve true se guardou.
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

--- O cartão guardado que pode ser dito agora nesta tela, ou nil: na Home; na tela da Yomimon só depois de
-- não caber na Home.
function Cartoes.pendente(s, agora, tela)
    local p = s.cartao_pendente
    if not p or p.usado or agora - (p.t or 0) >= Cartoes.VALIDADE then return nil end
    if tela == "home" or (tela == "traca" and p.nao_coube) then return p end
    return nil
end

--- Ela disse o cartão guardado: grava o que ele grava e, se for de uma vez só, guarda o id.
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
