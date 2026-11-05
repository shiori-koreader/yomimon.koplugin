--[[--
Idioma do Yomimon: português ou inglês.

Escolha: a opção "yomimon_language" ("auto", "pt" ou "en"). Em "auto", segue o idioma do
KOReader (pt* = português, qualquer outro = inglês). Fora do KOReader (testes), português.

O idioma é decidido quando os módulos carregam: trocar pede reiniciar o KOReader.

Textos da interface: a frase em português é a chave (Lingua.t"BARRIGA"); a tradução fica
em yomimon_en.lua. Falas e comentários: cada módulo troca suas listas pelas de
Lingua.conteudo(nome).
]]

local Lingua = {}

local codigo, ui

local function config()
    return rawget(_G, "G_reader_settings")
end

--- "auto", "pt" ou "en", como está salvo.
function Lingua.escolha()
    local g = config()
    return g and g:readSetting("yomimon_language") or "auto"
end

function Lingua.salvarEscolha(e)
    local g = config()
    if not g then return end
    if e == "auto" then g:delSetting("yomimon_language") else g:saveSetting("yomimon_language", e) end
end

--- "pt" ou "en".
function Lingua.codigo()
    if codigo then return codigo end
    local e, g = Lingua.escolha(), config()
    if e == "pt" or e == "en" then
        codigo = e
    else
        codigo = "pt"
    end
    return codigo
end

function Lingua.ingles()
    return Lingua.codigo() == "en"
end

--- Só para testes: força um idioma (os módulos precisam ser recarregados depois).
function Lingua.forcar(c)
    codigo, ui = c, nil
end

--- Texto da interface traduzido (ou o próprio texto, em português ou sem tradução).
function Lingua.t(s)
    if not Lingua.ingles() then return s end
    ui = ui or require("yomimon_en").ui
    return ui[s] or s
end

--- Conteúdo traduzido de um módulo (listas de falas etc.), ou nil em português.
function Lingua.conteudo(nome)
    if not Lingua.ingles() then return nil end
    local arquivo = (nome == "falas" or nome == "memoria") and "yomimon_en_books" or "yomimon_en"
    return require(arquivo)[nome]
end

--- Soma listas de frases extras às de um módulo: onde `extra` tem uma lista, ela é anexada
-- à lista de mesmo nome em `base` (criando se faltar); onde tem uma tabela, desce nela.
function Lingua.anexar(base, extra)
    if type(base) ~= "table" or type(extra) ~= "table" then return end
    for k, v in pairs(extra) do
        if type(v) == "table" and v[1] ~= nil then
            base[k] = base[k] or {}
            for _, item in ipairs(v) do table.insert(base[k], item) end
        elseif type(v) == "table" then
            base[k] = base[k] or {}
            Lingua.anexar(base[k], v)
        end
    end
end

--- Frases extras (lotes novos) de um módulo, no idioma atual, ou nil.
function Lingua.extra(nome)
    local ok, banco = pcall(require, "yomimon_data.extra_" .. Lingua.codigo())
    return ok and banco[nome] or nil
end

return Lingua
