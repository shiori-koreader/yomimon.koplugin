-- Run from the repository root: lua scripts/check_locales.lua
-- Fails when a locale is malformed or when its ui.lua has keys the code no longer uses; warns about untranslated text.
package.path = "yomimon.koplugin/?.lua;" .. package.path

local PLUGIN = "yomimon.koplugin"
local errors, warnings = 0, 0

local function listing(cmd)
    local p = io.popen(cmd)
    if not p then return {} end
    local out = {}
    for line in p:lines() do out[#out + 1] = line end
    p:close()
    return out
end

local function read(path)
    local f = assert(io.open(path, "rb"))
    local s = f:read("*a")
    f:close()
    return s
end

local sources = {}
for _, file in ipairs(listing("ls " .. PLUGIN .. "/*.lua")) do sources[#sources + 1] = read(file) end
local all_text = table.concat(sources, "\n")

local used = {}
local function unescape(literal)
    local chunk = (loadstring or load)('return "' .. literal .. '"')
    return chunk and chunk() or literal
end

local function escape(text)
    return (text:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub('"', '\\"'))
end

for key in all_text:gmatch('[^%w_]T%s*%(?%s*"([^"]*)"') do used[unescape(key)] = true end

local codes = listing("ls " .. PLUGIN .. "/locales")
for _, code in ipairs(codes) do
    local base = PLUGIN .. "/locales/" .. code
    local ok, locale = pcall(dofile, base .. "/locale.lua")
    if not ok or type(locale) ~= "table" or type(locale.name) ~= "string" or type(locale.format) ~= "table" then
        print("ERROR " .. code .. ": locale.lua must return { name = ..., format = {...} }")
        errors = errors + 1
    elseif code ~= "en" then
        local okui, ui = pcall(dofile, base .. "/ui.lua")
        if not okui or type(ui) ~= "table" then
            print("ERROR " .. code .. ": ui.lua missing or invalid")
            errors = errors + 1
        else
            for key in pairs(ui) do
                if not all_text:find(escape(key), 1, true) then
                    print("ERROR " .. code .. ": ui.lua key not used by the code: " .. key)
                    errors = errors + 1
                end
            end
            for key in pairs(used) do
                if ui[key] == nil and key:find("%a") then
                    print("warning " .. code .. ": untranslated: " .. key)
                    warnings = warnings + 1
                end
            end
        end
    end
end

print(string.format("%d locales, %d errors, %d warnings", #codes, errors, warnings))
os.exit(errors == 0 and 0 or 1)
