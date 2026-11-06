local g = rawget(_G, "G_reader_settings")
local escolha = g and g:readSetting("yomimon_language")
local ingles = escolha == "en"

return {
    version = "0.1.1",
    fullname = "Yomimon",
    description = ingles and [[A virtual pet that lives in KOReader and comments on what you read.]]
        or [[Um bichinho virtual que mora no KOReader e comenta o que você lê.]],
}
