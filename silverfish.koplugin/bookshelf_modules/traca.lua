-- Cartão da Traça para o Bookshelf. O Bookshelf procura a pasta bookshelf_modules em cada plugin instalado e
-- carrega os arquivos dela; o desenho do cartão está em traca_bookshelf.lua, na pasta do plugin.

-- O Bookshelf passa a pasta deste arquivo; a do plugin fica um nível acima. Garante que os módulos da Traça
-- sejam achados mesmo se o Bookshelf carregar isto antes de o KOReader pôr a pasta do plugin no caminho.
local pasta = ...
if type(pasta) == "string" then
    local raiz = (pasta:gsub("/bookshelf_modules/?$", ""))
    if not package.path:find(raiz .. "/?.lua", 1, true) then
        package.path = package.path .. ";" .. raiz .. "/?.lua"
    end
end

local ok, Bookshelf = pcall(require, "traca_bookshelf")
if not ok then
    require("logger").warn("Traça: cartão do Bookshelf indisponível:", Bookshelf)
    return {}
end
return Bookshelf.modulo(pasta)
