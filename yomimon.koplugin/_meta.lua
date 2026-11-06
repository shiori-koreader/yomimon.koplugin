local g = rawget(_G, "G_reader_settings")
local choice = g and g:readSetting("yomimon_language") or "auto"
local language = choice ~= "auto" and choice or tostring(g and g:readSetting("language") or "en")
local portuguese = language:lower():match("^pt")

return {
    version = "1.0.1",
    fullname = "Yomimon",
    description = portuguese and [[Um bichinho virtual que mora no KOReader e comenta o que você lê.]]
        or [[A virtual pet that lives in KOReader and comments on what you read.]],
}
