-- Run from the repository root: lua tests/yomimon_screens_test.lua
-- The picker, the Pokédex and the sprite download, with the KOReader side faked.
package.path = "yomimon.koplugin/?.lua;" .. package.path
unpack = unpack or table.unpack

local files = {}
local real_open = io.open
io.open = function(path, mode)
    if path:sub(1, 6) ~= "/data/" then return real_open(path, mode) end
    if mode:find("w", 1, true) then
        local buffer = {}
        return {
            write = function(_, chunk) buffer[#buffer + 1] = chunk end,
            close = function() files[path] = table.concat(buffer) end,
        }
    end
    if files[path] == nil then return nil end
    return { read = function() return files[path] end, close = function() end }
end

package.loaded["libs/libkoreader-lfs"] = { attributes = function() return nil end }
package.loaded["logger"] = { warn = function() end }
package.loaded["datastorage"] = { getDataDir = function() return "/data" end }
package.loaded["util"] = { makePath = function() end }
package.loaded["json"] = { decode = function()
    return { flavor_text_entries = { { language = { name = "en" }, flavor_text = "Stores energy\nin its cheeks." } } }
end }

local requests, status_of = {}, {}
package.loaded["ssl.https"] = { request = function(req)
    local sprite = req.url:match("/(%d+)%.png$")
    local species = req.url:match("pokemon%-species/(%d+)$")
    local dex = tonumber(sprite or species)
    requests[#requests + 1] = req.url
    local status = status_of[dex] or 200
    if status == 200 then req.sink("png-or-json-bytes") end
    return 1, status
end }
package.loaded["ltn12"] = { sink = { table = function(parts)
    return function(chunk) if chunk then parts[#parts + 1] = chunk end return 1 end
end } }
package.loaded["socketutil"] = { set_timeout = function() end, reset_timeout = function() end }

local unreadable = false
package.loaded["ui/renderimage"] = { renderImageData = function()
    if unreadable then return nil end
    return {
        getWidth = function() return 32 end, getHeight = function() return 32 end, free = function() end,
        getPixel = function(_, x, y)
            local inside = x >= 8 and x < 24 and y >= 8 and y < 24
            return { getColorRGB32 = function() return { r = 0, g = 0, b = 0, alpha = inside and 255 or 0 } end }
        end,
    }
end }

local State = require("yomimon_state")
local Download = require("yomimon_download")
local t0 = 1000000

-- Pokédex: every Pokémon keeps its own progress and comes back when picked again.
do
    local s = State.normalize(nil, t0)
    State.switchSpecies(s, 1)
    s.letters = 160000
    State.switchSpecies(s, 54)
    assert(s.letters == 0 and s.species == 54, "a new Pokémon starts from zero")
    s.letters = 5000
    State.switchSpecies(s, 1)
    assert(s.letters == 160000, "the first Pokémon got its progress back")
    local list = State.collection(s)
    assert(#list == 2 and list[1].base == 1 and list[1].current, "the current one comes first")
    assert(list[1].formIndex == 2 and list[1].form.titleText == "Ivysaur", "form follows the letters read")
    assert(list[2].base == 54 and list[2].letters == 5000 and list[2].formIndex == 1 and not list[2].current)
    State.switchSpecies(s, 1)
    assert(#State.collection(s) == 2, "picking the same Pokémon again adds nothing")
end
print("ok pokedex")

-- Download: sprite, description, failures and the cache.
do
    assert(not Download.has(25))
    assert(Download.download(25), "sprite stored")
    assert(Download.has(25) and #Download.loadFile(25) == 64, "stored sprite reads back as 64 lines")
    assert(Download.description(25) == "Stores energy in its cheeks.", "description stored with the sprite")
    local before = #requests
    assert(Download.download(25) and #requests == before, "a stored sprite is not fetched again")

    status_of[26] = 404
    local ok, err = Download.download(26)
    assert(not ok and err == "HTTP 404" and not Download.has(26), "HTTP errors are reported and nothing is stored")

    unreadable = true
    ok, err = Download.download(27)
    assert(not ok and err == "unreadable PNG" and not Download.has(27), "an unreadable PNG is reported")
    unreadable = false

    assert(not Download.line({ 25, 26 }), "a line fails when one form fails")
    status_of[26] = nil
    assert(Download.line({ 25, 26 }) and Download.has(26), "and succeeds once every form downloads")
end
print("ok download")

-- Picker, with the KOReader widgets faked.
do
    local closed, shown, online, saved = {}, {}, true, nil
    package.loaded["device"] = { screen = { scaleBySize = function(_, n) return n end, getSize = function() return { w = 600, h = 800 } end } }
    package.loaded["ui/geometry"] = { new = function(_, t) return t end }
    package.loaded["ui/gesturerange"] = { new = function(_, t) return t end }
    package.loaded["ui/widget/infomessage"] = { new = function(_, t) return t end }
    package.loaded["ui/network/manager"] = {
        isOnline = function() return online end,
        runWhenOnline = function(_, fn) fn() end,
    }
    package.loaded["ui/widget/container/inputcontainer"] = { extend = function(_, t) return t end }
    package.loaded["ui/uimanager"] = {
        show = function(_, w) shown[#shown + 1] = w end,
        close = function(_, w) closed[#closed + 1] = w end,
        forceRePaint = function() end, setDirty = function() end,
    }
    package.loaded["ffi/blitbuffer"] = setmetatable({ Color8 = function(v) return v end }, { __index = function() return 0 end })
    package.loaded["yomimon_drawing"] = {}
    package.loaded["yomimon_screen"] = {}
    local Welcome = require("yomimon_welcome")

    local function picker(extra)
        local self = setmetatable({
            items = {}, letters_with = {}, page = 1,
            plugin = { state = State.normalize(nil, t0), save = function(_, flag) saved = flag end },
            textWidth = function(_, text) return #text * 6 end,
            card = function() end, textValue = function() end,
        }, { __index = Welcome })
        for k, v in pairs(extra or {}) do self[k] = v end
        return self
    end

    -- A–Z filter: tapping a letter shows only it, tapping again shows everything, either way back to page 1.
    local self = picker()
    for i = 1, 19 do self.items[i] = { nameText = (i <= 12 and "A" or "B") .. i } end
    assert(#self:visible_ones() == 19 and self:totalPages() == 3)
    self.page = 3
    self:filterLetter("A")
    assert(self.letter == "A" and self.page == 1 and #self:visible_ones() == 12 and self:totalPages() == 2)
    self:filterLetter("B")
    assert(#self:visible_ones() == 7 and self:totalPages() == 1)
    self:filterLetter("B")
    assert(self.letter == nil and #self:visible_ones() == 19, "tapping the same letter clears the filter")
    self.letter = "Z"
    assert(#self:visible_ones() == 0 and self:totalPages() == 1, "an empty letter still has one page")

    -- Every species must be reachable from the A–Z shortcut.
    local Species = require("yomimon_species")
    for _, line in ipairs(Species.lines) do
        local name = Species.names[line[1]]
        assert(name and name:upper():sub(1, 1):match("%u"), "species " .. tostring(line[1]) .. " has no A-Z initial")
    end

    -- Description card: at most 4 lines, the last one ending in "...".
    local drawn = {}
    local card = picker({ textValue = function(_, _, text) drawn[#drawn + 1] = text end })
    card:paintDescription(nil, "short text", 0)
    assert(#drawn == 1 and drawn[1] == "short text")
    drawn = {}
    local long = {}
    for i = 1, 120 do long[i] = "word" .. i end
    card:paintDescription(nil, table.concat(long, " "), 0)
    assert(#drawn == 4 and drawn[4]:sub(-3) == "...", "long descriptions are cut at 4 lines")

    -- Picking: switches the Pokémon, downloads what is missing and, in switch-only mode, closes the screen.
    local pick = picker({ choice = { base = 133, line = { 133 } }, step = 2, pick_only = false })
    assert(not pick:spriteDownloaded(pick.choice))
    pick:pick()
    assert(pick.plugin.state.species == 133 and Download.has(133) and Download.description(133))
    assert(pick.step == 3, "the install questions come next")
    assert(pick:spriteDownloaded(pick.choice))

    online = false
    local offline = picker({ choice = { base = 134, line = { 134 } }, step = 2 })
    status_of[134] = 404
    offline:pick()
    assert(offline.plugin.state.species == 134 and not Download.has(134), "offline: picks anyway, downloads nothing")

    online = true
    local switch = picker({ choice = { base = 133, line = { 133 } }, pick_only = true, on_finish = function() saved = "finished" end })
    switch:pick()
    assert(closed[#closed] == switch and saved == "finished", "switch-only mode closes the screen and reports back")
end
print("ok picker")
