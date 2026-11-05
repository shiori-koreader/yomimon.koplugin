-- Bookshelf scans bookshelf_modules/ in every installed plugin; the card itself lives in yomimon_bookshelf.lua.

-- Bookshelf passes this file's folder; the plugin folder is one level up. Adding it to package.path keeps the
-- plugin modules findable if Bookshelf loads this before KOReader has put the plugin on the path.
local pasta = ...
if type(pasta) == "string" then
    local raiz = (pasta:gsub("/bookshelf_modules/?$", ""))
    if not package.path:find(raiz .. "/?.lua", 1, true) then
        package.path = package.path .. ";" .. raiz .. "/?.lua"
    end
end

local ok, Bookshelf = pcall(require, "yomimon_bookshelf")
if not ok then
    require("logger").warn("Yomimon: Bookshelf card unavailable:", Bookshelf)
    return {}
end
return Bookshelf.modulo(pasta)
