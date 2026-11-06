--[[--
Welcome: appears the first time Yomimon opens (or through dev mode).

Screen 1 · pick         — list of Pokémon in alphabetical order, with a letter filter
Screen 2 · confirmation — its sprite (downloaded on the device) + PICK THIS ONE
Screen 3 · where to find me — 3 options (open at startup, gesture, Simple UI card) + DONE

Reuses the main screen's components (balloon, cards, Figma font and scale).
]]

local Device = require("device")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local InfoMessage = require("ui/widget/infomessage")
local NetworkMgr = require("ui/network/manager")
local InputContainer = require("ui/widget/container/inputcontainer")
local UIManager = require("ui/uimanager")
local Blitbuffer = require("ffi/blitbuffer")
local Screen = Device.screen

local Drawing = require("yomimon_drawing")
local T = require("yomimon_language").t
local State = require("yomimon_state")
local Species = require("yomimon_species")
local Download = require("yomimon_download")
local YomimonScreen = require("yomimon_screen")

local okKit, Kit = pcall(require, "lib/bookshelf_module_kit")
local has_bookshelf = okKit and type(Kit) == "table" and Kit.setOnHomeShelf ~= nil
local MODULO_BOOKSHELF = "yomimon"

local WIDE, ALT = 618, 824
local BLACK, WHITE = Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
local GREY_55, GREY_BB = Blitbuffer.Color8(0x55), Blitbuffer.Color8(0xBB)

local PER_PAGE = 8
local LETTERS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                 "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }

-- Silkscreen has no ♀, ♂ or ’.
local function label(nameText)
    return (nameText:gsub("♀", " F"):gsub("♂", " M"):gsub("’", "'"):upper())
end

local function sortedList()
    local items = {}
    for _, line in ipairs(Species.lines) do
        local last = line[#line]
        items[#items + 1] = {
            base = line[1], line = line,
            nameText = label(Species.names[line[1]]),
            final = last ~= line[1] and label(Species.names[last]) or nil,
        }
    end
    table.sort(items, function(a, b) return a.nameText < b.nameText end)
    return items
end

local Welcome = InputContainer:extend{
    plugin = nil,
    passo = 1,
    page = 1,
    choice = nil,      -- list item picked (screen 2)
    pick_only = false, -- only switch Pokémon: ends on screen 2, without the install questions
    on_finish = nil,  -- function called at the end
}

-- components borrowed from the Yomimon screen
for _, nameText in ipairs({ "px", "face", "ret", "textValue", "textWidth", "card", "measureBalloon", "balloon", "target" }) do
    Welcome[nameText] = YomimonScreen[nameText]
end

function Welcome:init()
    if Device:isTouchDevice() then
        self.ges_events.Tap = { GestureRange:new{ ges = "tap", range = function() return self.dimen end } }
    end
    if Device:hasKeys() then
        self.key_events.Close = { { Device.input.group.Back } }
    end
    self.covers_fullscreen = true
    local tam = Screen:getSize()
    self.dimen = Geom:new{ x = 0, y = 0, w = tam.w, h = tam.h }
    self.k = math.min(tam.w / WIDE, tam.h / ALT)
    self.ox = math.floor((tam.w - WIDE * self.k) / 2)
    self.oy = math.floor((tam.h - ALT * self.k) / 2)
    self.font_factor = Screen:scaleBySize(1000) / 1000
    self.faces = {}
    self.items = sortedList()
    self.letters_with = {}
    for _, it in ipairs(self.items) do self.letters_with[it.nameText:sub(1, 1)] = true end
    self.op = {
        begin = G_reader_settings:isTrue("yomimon_open_at_startup"),
        gesture = G_reader_settings:isTrue("yomimon_gesture"),
        card = self.plugin:simpleUICard(),
        shelf = has_bookshelf and Kit.onHomeShelf and Kit.onHomeShelf(MODULO_BOOKSHELF) or false,
    }
end

--- Centred sprite, with the balloon right above the real head (as on the main screen).
function Welcome:sprite(bb, nameText, speech, center_y, size)
    local scale = math.max(1, math.floor(size * self.k / Drawing.WIDTH))
    local side = scale * Drawing.WIDTH
    local x = self.ox + self:px(WIDE / 2) - math.floor(side / 2)
    local y = self.oy + self:px(center_y) - math.floor(side / 2)
    Drawing.paintSprite(bb, nameText, x, y, scale)
    local head = (y - self.oy) / self.k + Drawing.realTop(nameText) * scale / self.k
    local m = self:measureBalloon(speech)
    self:balloon(bb, speech, nil, math.max(24, head - 30 - (m.H + 15)), m)
end

--- Big button (card with shadow) with centred text.
function Welcome:button(bb, textValue, y, action)
    self:card(bb, 20, y, 578, 80, true)
    self:textValue(bb, textValue, 0, y + 24, true, 24, BLACK, WIDE / 2)
    self:target(14, y - 6, 590, 92, action)
end

--- Option with a check box (pixel square, filled when on).
function Welcome:option(bb, y, titleText, detail, switched_on, action, disabled)
    self:card(bb, 20, y, 578, 74, true)
    local cx, cy = 40, y + 24
    if switched_on then
        self:ret(bb, cx + 3, cy, 20, 26, BLACK)
        self:ret(bb, cx, cy + 3, 26, 20, BLACK)
        self:ret(bb, cx + 6, cy + 6, 3, 3, WHITE)
    else
        local cor = disabled and GREY_BB or BLACK
        self:ret(bb, cx + 3, cy, 20, 3, cor); self:ret(bb, cx + 3, cy + 23, 20, 3, cor)
        self:ret(bb, cx, cy + 3, 3, 20, cor); self:ret(bb, cx + 23, cy + 3, 3, 20, cor)
    end
    self:textValue(bb, titleText, 86, y + 16, true, 15, disabled and GREY_BB or BLACK)
    self:textValue(bb, detail, 86, y + 42, false, 10, disabled and GREY_BB or GREY_55)
    if not disabled then self:target(14, y - 4, 590, 82, action) end
end

--- The species of the chosen letter (all of them when none is chosen).
function Welcome:visible_ones()
    if not self.letter then return self.items end
    local list = {}
    for _, it in ipairs(self.items) do
        if it.nameText:sub(1, 1) == self.letter then list[#list + 1] = it end
    end
    return list
end

function Welcome:totalPages()
    return math.max(1, math.ceil(#self:visible_ones() / PER_PAGE))
end

--- Shows only the tapped letter; tapping it again goes back to the whole list.
function Welcome:filterLetter(letter)
    self.letter = self.letter ~= letter and letter or nil
    self.page = 1
end

function Welcome:paintList(bb)
    self:textValue(bb, T"PICK YOUR POKÉMON", 0, 22, true, 24, BLACK, WIDE / 2)
    for i, letter in ipairs(LETTERS) do
        local col, lin = (i - 1) % 13, math.floor((i - 1) / 13)
        local lx, ly = 21 + col * 44, 70 + lin * 44
        local has = self.letters_with[letter]
        local picked = self.letter == letter
        self:card(bb, lx, ly, 40, 38, false)
        if picked then self:ret(bb, lx + 2, ly + 2, 36, 34, BLACK) end
        self:textValue(bb, letter, 0, ly + 8, true, 18, picked and WHITE or (has and BLACK or GREY_BB), lx + 20)
        if has then self:target(lx - 2, ly - 2, 44, 42, function() self:filterLetter(letter) end) end
    end
    local items = self:visible_ones()
    local first_one = (self.page - 1) * PER_PAGE
    for n = 1, PER_PAGE do
        local it = items[first_one + n]
        if not it then break end
        local y = 170 + (n - 1) * 68
        self:card(bb, 20, y, 578, 58, true)
        self:textValue(bb, it.nameText, 40, y + 16, true, 20)
        if it.final then
            self:textValue(bb, "> " .. it.final, 590 - self:textWidth("> " .. it.final, false, 12), y + 22, false, 12, GREY_55)
        end
        self:target(14, y - 4, 590, 66, function() self.choice, self.passo = it, 2 end)
    end
    local ny = 730
    if self.pick_only then
        self:card(bb, 250, ny, 118, 52, true)
        self:textValue(bb, T"EXIT", 0, ny + 14, true, 16, BLACK, 309)
        self:target(244, ny - 6, 130, 64, function() self:onClose(); if self.on_finish then self.on_finish() end end)
    end
    self:card(bb, 20, ny, 90, 52, true)
    self:textValue(bb, "<", 0, ny + 10, true, 28, BLACK, 65)
    self:target(14, ny - 6, 102, 64, function() self.page = math.max(1, self.page - 1) end)
    self:card(bb, 508, ny, 90, 52, true)
    self:textValue(bb, ">", 0, ny + 10, true, 28, BLACK, 553)
    self:target(502, ny - 6, 102, 64, function() self.page = math.min(self:totalPages(), self.page + 1) end)
    self:textValue(bb, string.format("%d/%d", self.page, self:totalPages()), 0, self.pick_only and ny + 62 or ny + 16, false, 16, BLACK, WIDE / 2)
end

--- Pokédex description in a card, wrapped to at most 4 lines (the last ends in "..." if it does not fit).
function Welcome:paintDescription(bb, textValue, y)
    local widthPx, lines, current = 510, {}, ""
    for word in textValue:gmatch("%S+") do
        local candidate = current == "" and word or current .. " " .. word
        if current ~= "" and self:textWidth(candidate, false, 11) > widthPx then
            lines[#lines + 1], current = current, word
        else
            current = candidate
        end
    end
    if current ~= "" then lines[#lines + 1] = current end
    if #lines > 4 then
        lines[4] = lines[4]:gsub("%s*%S+$", "") .. "..."
        for i = #lines, 5, -1 do lines[i] = nil end
    end
    self:card(bb, 20, y, 578, 20 + #lines * 16, false)
    for i, line in ipairs(lines) do
        self:textValue(bb, line, 40, y + 10 + (i - 1) * 16, false, 11, BLACK)
    end
end

function Welcome:paintConfirmation(bb)
    local it = self.choice
    local form = Species.names[it.base]
    local downloaded = self:spriteDownloaded(it)
    local nameText = downloaded and "p" .. it.base or "ball"
    local speech = downloaded and string.format(T"%s! Good pick. I'll keep an eye on your reading.", form)
        or string.format(T"(%s hasn't arrived yet: the picture downloads when Wi-Fi is on)", form)
    local description = Download.description(it.base)
    if description then
        self:sprite(bb, nameText, speech, 375, 230)
        self:paintDescription(bb, description, 500)
    else
        self:sprite(bb, nameText, speech, 430, 295)
    end
    if not downloaded then
        self:button(bb, T"DOWNLOAD (WI-FI)", 590, function() self:downloadSprites() end)
    end
    self:button(bb, T"PICK THIS ONE", 690, function() self:pick() end)
    self:card(bb, 20, 760, 120, 40, true)
    self:textValue(bb, T"BACK", 0, 770, true, 14, BLACK, 80)
    self:target(14, 754, 132, 52, function() self.passo = 1 end)
end

function Welcome:spriteDownloaded(it)
    for _, dex in ipairs(it.line) do
        if not Download.has(dex) then return false end
    end
    return true
end

-- Shows "Downloading…" before blocking the screen with the download (files of ~1 KB, but the connection may take a while).
function Welcome:download(line)
    local notice = InfoMessage:new{ text = T"Downloading the picture…" }
    UIManager:show(notice)
    UIManager:forceRePaint()
    pcall(Download.line, line)
    UIManager:close(notice)
end

function Welcome:downloadSprites()
    local it = self.choice
    NetworkMgr:runWhenOnline(function()
        self:download(it.line)
        UIManager:setDirty(self, "ui")
    end)
end

function Welcome:pick()
    local it = self.choice
    State.switchSpecies(self.plugin.state, it.base)
    if not self:spriteDownloaded(it) and NetworkMgr:isOnline() then self:download(it.line) end
    if NetworkMgr:isOnline() then pcall(Download.downloadDescription, it.base) end
    pcall(function() require("yomimon_simpleui").syncCritter(self.plugin) end)
    if self.pick_only then
        self.plugin:save(true)
        UIManager:close(self)
        if self.on_finish then self.on_finish() end
        return
    end
    self.passo = 3
end

function Welcome:paintTo(bb, x, y)
    self.dimen.x, self.dimen.y = x, y
    bb:paintRect(x, y, self.dimen.w, self.dimen.h, WHITE)
    self.targets = {}
    self.layer = "conteudo"
    if self.passo == 1 then
        self:paintList(bb)

    elseif self.passo == 2 then
        self:paintConfirmation(bb)

    else
        local s = self.plugin.state
        local f = State.stage(s)
        self:sprite(bb, self:spriteDownloaded({ line = { f.dex or 0 } }) and f.nameText or "ball",
            T"Where will you find me? Choose. I'll wait.", 245, 170)
        self:option(bb, 360, T"OPEN AT STARTUP", T"YOMIMON APPEARS WHEN KOREADER OPENS",
            self.op.begin, function() self.op.begin = not self.op.begin end)
        self:option(bb, 440, T"GESTURE SHORTCUT", T"HOLD YOUR FINGER ON THE TOP RIGHT CORNER",
            self.op.gesture, function() self.op.gesture = not self.op.gesture end)
        local has_sui = self.plugin:hasSimpleUI()
        self:option(bb, 520, T"HOME SCREEN CARD", has_sui and T"IN PLACE OF SIMPLE UI'S CRITTER" or T"SIMPLE UI NOT INSTALLED",
            has_sui and self.op.card, function() self.op.card = not self.op.card end, not has_sui)
        self:option(bb, 600, T"BOOKSHELF CARD", has_bookshelf and T"ON THE FIRST SHELF WITH BOOKS" or T"BOOKSHELF NOT INSTALLED",
            has_bookshelf and self.op.shelf, function() self.op.shelf = not self.op.shelf end, not has_bookshelf)
        self:button(bb, T"DONE", 696, function() self:finish() end)
    end
end

function Welcome:finish()
    local s = self.plugin.state
    s.welcome = true
    G_reader_settings:saveSetting("yomimon_open_at_startup", self.op.begin or nil)
    G_reader_settings:saveSetting("yomimon_gesture", self.op.gesture or nil)
    self.plugin:applyGesture()
    if self.plugin:hasSimpleUI() then self.plugin:simpleUICard(self.op.card) end
    if has_bookshelf then pcall(Kit.setOnHomeShelf, MODULO_BOOKSHELF, self.op.shelf) end
    self.plugin:save(false)
    self.targets = nil
    UIManager:close(self)
    if self.on_finish then self.on_finish() end
end

function Welcome:onTap(_, ges)
    local pos = ges and ges.pos
    if not pos then return end
    for i = #(self.targets or {}), 1, -1 do
        local a = self.targets[i]
        if pos:intersectWith(a.rect) then
            a.action()
            if self.targets then UIManager:setDirty(self, "ui") end
            return true
        end
    end
    return true
end

function Welcome:onClose()
    UIManager:close(self)  -- closing midway: no Pokémon chosen; the questions come back later
    return true
end

-- Protection (as on the Yomimon screen): if it fails, a tap closes it.
require("yomimon_guard").default:wrap(Welcome, { "paintTo", "onTap" }, function(nameText, self, bb, x, y)
    if nameText == "paintTo" then
        bb:paintRect(x, y, self.dimen.w, self.dimen.h, WHITE)
    elseif nameText == "onTap" then
        UIManager:close(self)
        return true
    end
end)

return Welcome
