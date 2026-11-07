--[[--
Yomimon: a virtual pet that feeds on the letters you read.

Each page read (with at least a few seconds of reading) becomes food.
The state lives in settings/yomimon.lua; the sleep-screen image in koreader/yomimon/.
]]

local DataStorage = require("datastorage")
local Dispatcher = require("dispatcher")
local InfoMessage = require("ui/widget/infomessage")
local LuaSettings = require("luasettings")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")

local Download = require("yomimon_download")
local Drawing = require("yomimon_drawing")
local Guard = require("yomimon_guard")
local T = require("yomimon_language").t
local State = require("yomimon_state")
local Counting = require("yomimon_counting")
local Memory = require("yomimon_memory")
local Diary = require("yomimon_diary")
local YomimonScreen = require("yomimon_screen")
local Screensaver = require("ui/screensaver")

-- No Yomimon error interrupts reading: it goes to the log; after 3 in a row it stays quiet
-- until KOReader restarts and warns once (see yomimon_guard.lua and the end of this file).
Guard.default:configure(
    function(nameText, err) logger.warn("Yomimon: error in " .. tostring(nameText) .. " (reading continues):", err) end,
    function()
        UIManager:nextTick(function()
            UIManager:show(InfoMessage:new{
                text = T"Yomimon ran into a problem and will stay quiet until you restart KOReader. Your reading wasn't affected.",
            })
        end)
    end)

local LETTERS_PER_SECOND = 60    -- reading speed ceiling
local ESTIMATED_LETTERS = 1200    -- used when the page text cannot be extracted
local PAGES_BETWEEN_IMAGES = 10 -- how many pages between sleep-screen redraws

local Yomimon = WidgetContainer:extend{
    name = "yomimon",
    is_doc_only = false,
}

-- KOReader shows the sleep screen before telling plugins it is going to sleep (Screensaver:setup and show,
-- then the Suspend event). So that the phrase is chosen when the Kindle goes to sleep, Yomimon draws the image
-- here, right before KOReader picks the image up from the folder. Wrapped once, even if the plugin reloads.
if not Screensaver.yomimon_original_setup then
    Screensaver.yomimon_original_setup = Screensaver.setup
    Screensaver.setup = function(...)
        local plugin = Screensaver.yomimon_instance
        if plugin then pcall(plugin.onSleep, plugin) end
        return Screensaver.yomimon_original_setup(...)
    end
end

function Yomimon:init()
    Screensaver.yomimon_instance = self  -- the Yomimon open right now (library or reader)
    self.folder = DataStorage:getDataDir() .. "/yomimon"
    self.image = self.folder .. "/yomimon.png"
    self.db = LuaSettings:open(DataStorage:getSettingsDir() .. "/yomimon.lua")
    local now = os.time()
    self.state = State.normalize(self.db:readSetting("state"), now)
    State.passTime(self.state, now)
    self.pages_without_image = 0
    -- dev mode: with the file koreader/yomimon/force_failure, page digestion fails on purpose (never in the community
    -- version)
    local okVersion, Version = pcall(require, "yomimon_version")
    local public = okVersion and type(Version) == "table" and Version.public
    self.test_failure = not public and lfs.attributes(self.folder .. "/force_failure", "mode") == "file"
    self.ui.menu:registerToMainMenu(self)
    self:onDispatcherRegisterActions()
    self:applyGesture()
    UIManager:nextTick(function() self:onStart() end)
    UIManager:nextTick(function() Guard.default:call("ensureSprites", self.ensureSprites, self) end)
    -- card on the home screen and button in Simple UI, if it is installed
    local ok, Integration = pcall(require, "yomimon_simpleui")
    if ok then
        Integration.registrar(self)
    else
        logger.warn("Yomimon: Simple UI integration unavailable:", Integration)
    end
end

function Yomimon:onDispatcherRegisterActions()
    Dispatcher:registerAction("yomimon_show", {
        category = "none", event = "ShowYomimon", title = T"Yomimon: show the creature", general = true,
    })
end

function Yomimon:addToMainMenu(menu_items)
    menu_items.yomimon = {
        text = T"Yomimon",
        sorting_hint = "tools",
        sub_item_table = {
            { text = T"Open Yomimon", callback = function() self:onShowYomimon() end },
            {
                text = T"Language",
                sub_item_table_func = function() return self:languageItems() end,
            },
            { text = T"About and disclaimer", callback = function() self:showAbout() end },
        },
    }
end

function Yomimon:languageItems()
    local Language = require("yomimon_language")
    local function item(textValue, val)
        return {
            text = textValue,
            radio = true,
            checked_func = function() return Language.choice() == val end,
            callback = function()
                Language.saveChoice(val)
                UIManager:show(require("ui/widget/infomessage"):new{ text = T"Restart KOReader to change the language." })
            end,
        }
    end
    local items = { item(T"Automatic (KOReader language)", "auto") }
    local ok, languages = pcall(Language.available)
    if not ok or #languages == 0 then languages = { { code = "en", name = "English" }, { code = "pt", name = "Português (Brasil)" } } end
    for _, language in ipairs(languages) do items[#items + 1] = item(language.name, language.code) end
    return items
end

function Yomimon:showAbout()
    UIManager:show(require("ui/widget/infomessage"):new{
        text = T"Yomimon is an unofficial fan project. It is not affiliated with or endorsed by Nintendo, Game Freak, Creatures or The Pokémon Company. Pokémon names and sprites belong to their owners: the sprites are downloaded on your device from PokeAPI and are not part of this plugin.\n\nBased on Silverfish by Matheus Oliveira. Code under GPL-3.0; phrases under CC BY-NC-SA 4.0.",
    })
end

-- Yomimon screens that are open (the main one and the welcome), from any plugin instance. Only one at a time,
-- and it closes with the library or book that opened it. Without this, a screen covered by another window (for
-- example Simple UI opening the Home over it when the Kindle wakes up) was forgotten underneath; when leaving
-- KOReader, which only closes once no window is left, the forgotten screens showed up piled together.
local screens = setmetatable({}, { __mode = "k" })

local function closeScreens(owner)
    for screen in pairs(screens) do
        if not owner or screen.plugin == owner then
            screens[screen] = nil
            if not UIManager.isWidgetShown or UIManager:isWidgetShown(screen) then UIManager:close(screen) end
        end
    end
end

function Yomimon:showScreen(screen)
    closeScreens()
    screens[screen] = true
    UIManager:show(screen)
end

function Yomimon:onCloseWidget()
    closeScreens(self)
end

function Yomimon:onShowYomimon()
    State.passTime(self.state, os.time())
    local s = self.state
    -- no Pokémon chosen yet: the welcome comes first
    if not s.welcome or not s.species then
        return self:showWelcome()
    end
    self:showScreen(YomimonScreen:new{ plugin = self })
    return true
end

--- pick_only: opens only the Pokémon list (to switch), without the install questions.
function Yomimon:showWelcome(pick_only)
    local Welcome = require("yomimon_welcome")
    self:showScreen(Welcome:new{
        plugin = self,
        pick_only = pick_only == true,
        on_finish = function()
            self:showScreen(YomimonScreen:new{ plugin = self })
            if not G_reader_settings:isTrue("yomimon_about_seen") then
                G_reader_settings:saveSetting("yomimon_about_seen", true)
                self:showAbout()
            end
        end,
    })
    return true
end

-- First opening and "open at startup" (once per KOReader session, in the library)
local opened_this_session = false

function Yomimon:onStart()
    if opened_this_session or self.ui.document then return end
    opened_this_session = true
    local s = self.state
    if not s.welcome or not s.species then
        UIManager:scheduleIn(1, function() self:showWelcome() end)
    elseif G_reader_settings:isTrue("yomimon_open_at_startup") then
        UIManager:scheduleIn(1, function() self:onShowYomimon() end)
    end
end

-- Gesture shortcut: holding a finger on the top right corner opens Yomimon.
function Yomimon:applyGesture()
    if not (self.ui and self.ui.registerTouchZones) then return end
    if self.ui.unregisterTouchZones then
        pcall(self.ui.unregisterTouchZones, self.ui, { { id = "yomimon_gesture" } })
    end
    if G_reader_settings:isTrue("yomimon_gesture") then
        self.ui:registerTouchZones({{
            id = "yomimon_gesture",
            ges = "hold",
            screen_zone = { ratio_x = 0.85, ratio_y = 0, ratio_w = 0.15, ratio_h = 0.1 },
            handler = function() return self:onShowYomimon() end,
        }})
    end
end

-- Simple UI: is it installed? And is the Yomimon card on the Home?
function Yomimon:hasSimpleUI()
    local ok = pcall(require, "modules/moduleregistry")
    return ok
end

function Yomimon:simpleUICard(turn_on)
    local ok, SUISettings = pcall(require, "infra/sui_store")
    if not ok or not SUISettings then return false end
    local lookupKey = "simpleui_hs_yomimon_card_enabled"
    if turn_on ~= nil then
        pcall(SUISettings.saveSetting, SUISettings, lookupKey, turn_on and true or false)
        G_reader_settings:saveSetting("yomimon_critter", turn_on and true or nil)
        if turn_on then pcall(function() require("yomimon_simpleui").syncCritter(self, true) end) end
    end
    local okRead, v = pcall(SUISettings.readSetting, SUISettings, lookupKey)
    if not okRead or v == nil then return true end
    return v == true
end

-- Reading ------------------------------------------------------------------

function Yomimon:onPageUpdate(pageno)
    if not self.ui.document or type(pageno) ~= "number" then return end
    self:countCurrentPage()
    self.page = pageno
    self.page_since = os.time()
end

--- Gives the page that was open to Yomimon to eat.
-- It counts like KOReader's statistics (once per book, their minimum time); it only shapes Yomimon
-- (themes, characters, traits, memories) if it was really read (yomimon_counting.lua).
function Yomimon:countCurrentPage()
    local p, since = self.page, self.page_since
    if not p or not since then return end
    local elapsed = os.time() - since
    if elapsed < Counting.minimumSeconds(G_reader_settings:readSetting("statistics")) then return end
    local where = self:whereAmI(p)
    local book = where.book or "?"
    local total = self.ui.document and self.ui.document:getPageCount()
    local new = Counting.firstTime(self.state, book, p, total, os.time())
    local textValue = self:pageText(p)
    local real_ones = textValue and State.countLetters(textValue) or ESTIMATED_LETTERS
    -- shapes Yomimon on the first pass that is real reading (it may come after flipping through)
    local read_f = not Counting.alreadyRead(self.state, book, p)
        and Counting.reallyRead(self.state, elapsed, real_ones, where.chapter, textValue)
    if not new and not read_f then return end
    if read_f then Counting.markRead(self.state, book, p) end
    local letters = new and math.min(real_ones, elapsed * LETTERS_PER_SECOND) or 0
    self:feed(letters, State.longestWord(textValue), where, read_f and textValue or nil, new)
end

--- Book and chapter of the page (for the "last meal").
function Yomimon:whereAmI(p)
    local where = {}
    pcall(function()
        local props = self.ui.doc_props
        where.book = props and (props.display_title or props.title)
        where.author = props and props.authors and props.authors:gsub("\n.*", "")
        where.tags = props and props.keywords  -- the EPUB subject, one tag per line (yomimon_data/genres.lua)
        where.file_path = self.ui.document and self.ui.document.file
        if self.ui.toc then where.chapter = self.ui.toc:getTocTitleByPage(p) end
        local total = self.ui.document and self.ui.document:getPageCount()
        if total and total > 0 then
            where.progress = math.min(1, p / total)
            where.story_end = self:storyEnd(total)
        end
    end)
    if where.chapter == "" then where.chapter = nil end
    return where
end

--- Progress (0 to 1) where the story ends, from the table of contents (Diary.storyEnd): notes, timeline,
-- afterword and ads after it do not count towards finishing the book. Redone when the total of pages
-- changes (font, margins); nil when the table of contents does not help (then the file's 98% applies).
function Yomimon:storyEnd(total)
    if self.story_end_total ~= total then
        self.story_end_total, self.story_end = total, nil
        local toc = self.ui.toc
        if toc and toc.fillToc then toc:fillToc() end
        local items = {}
        for _, item in ipairs(toc and toc.toc or {}) do
            local page = item.fixed_page or item.page  -- fixed_page: an out-of-order item corrected by KOReader
            if type(page) == "number" then
                items[#items + 1] = { titleText = item.title, page = page, level = item.depth }
            end
        end
        local ending = Diary.storyEnd(items, total)
        if ending then self.story_end = ending / total end
    end
    return self.story_end
end

--- Fallback for the end of the book: you marked the book as finished in KOReader (Diary.koreaderStatus).
-- Returns true when that finished the book just now.
function Yomimon:checkFinished()
    if not self.ui.document or self.state.dev_simulation then return false end
    local summary = self.ui.doc_settings and self.ui.doc_settings:readSetting("summary")
    local book = self:whereAmI(self.page or 1).book
    return Diary.koreaderStatus(self.state, Memory, book, type(summary) == "table" and summary.status or nil,
        os.time()) == true
end

function Yomimon:onReaderReady()
    if self:checkFinished() then self:save(true) end
end

function Yomimon:pageText(p)
    local doc = self.ui.document
    local ok, textValue = pcall(function()
        if self.ui.rolling then
            if p >= doc:getPageCount() then return end
            local xp0, xp1 = doc:getPageXPointer(p), doc:getPageXPointer(p + 1)
            if not (xp0 and xp1) then return end
            local r = doc:getTextFromXPointers(xp0, xp1)
            return type(r) == "table" and r.text or r
        elseif doc.getPageTextBoxes then
            local boxes = doc:getPageTextBoxes(p)
            if not boxes then return end
            local parts = {}
            for _, line in ipairs(boxes) do
                for _, word in ipairs(line) do
                    if word.word then parts[#parts + 1] = word.word end
                end
            end
            return table.concat(parts, " ")
        end
    end)
    if ok and type(textValue) == "string" and textValue ~= "" then return textValue end
    if not ok then logger.dbg("Yomimon: no text for the page", p, textValue) end
end

-- count: false when the page was already counted and is now only being digested (not counted again).
function Yomimon:feed(letters, word, where, textValue, count)
    if self.test_failure then error("injected test failure (dev mode: koreader/yomimon/force_failure)") end
    if self.state.dev_simulation then return end  -- demo simulation: frozen, real reading does not enter
    local now = os.time()
    local occurred = count ~= false and State.eat(self.state, letters, word, now, where) or {}
    pcall(Memory.digest, self.state, textValue, where, now, count)
    self.pages_without_image = self.pages_without_image + 1
    local notice
    if occurred.evolved then
        notice = occurred.evolved.notice or string.format(T"Yomimon is now %s!", occurred.evolved.titleText)
    elseif occurred.woke then
        notice = T"Yomimon came out of its ball. Hungry, of course."
    end
    if notice then
        if occurred.evolved then pcall(function() require("yomimon_simpleui").syncCritter(self) end) end
        Memory.note(self.state, now, notice)
        UIManager:show(InfoMessage:new{ text = notice, timeout = 4 })
        self:save(true)
    elseif self.pages_without_image >= PAGES_BETWEEN_IMAGES then
        self:save(true)
    end
end

--- Downloads the missing sprites of the chosen species and of every registered one (only with Wi-Fi already on: it never asks to turn it on).
function Yomimon:ensureSprites()
    if self.ui.document then return end
    local missing = {}
    local speciesIds = { self.state.species }
    for base in pairs(self.state.collection or {}) do speciesIds[#speciesIds + 1] = base end
    for _, base in ipairs(speciesIds) do
        for _, f in ipairs(State.forms({ species = base })) do
            if f.dex and not Download.has(f.dex) then missing[#missing + 1] = f.dex end
        end
    end
    if #missing > 0 and require("ui/network/manager"):isOnline() then Download.line(missing) end
    pcall(function() require("yomimon_simpleui").syncCritter(self) end)
end

-- The critter image depends on night mode, so it is rewritten whenever the mode flips.
function Yomimon:onNightModeChanged()
    pcall(function() require("yomimon_simpleui").syncCritter(self) end)
end

-- Dev mode: endgame simulation ---------------------------------------------------
-- The simulated state (koreader/yomimon/simulation.lua, generated by tools/simulate_endgame.lua)
-- takes the place of the real one, which stays saved in settings/yomimon.lua ("real_state") until it comes back.

function Yomimon:inSimulation()
    return self.db:readSetting("real_state") ~= nil
end

function Yomimon:loadSimulation()
    local file_path = self.folder .. "/simulation.lua"
    if lfs.attributes(file_path, "mode") ~= "file" then return false end
    local ok, sim = pcall(function() return LuaSettings:open(file_path):readSetting("state") end)
    if not ok or type(sim) ~= "table" then return false end
    if not self:inSimulation() then self.db:saveSetting("real_state", self.state) end
    self.state = State.normalize(sim, os.time())
    self.state.dev_simulation = true
    State.passTime(self.state, os.time())
    self:save(true)
    return true
end

function Yomimon:restoreRealState()
    local real = self.db:readSetting("real_state")
    if not real then return false end
    self.state = State.normalize(real, os.time())
    self.db:delSetting("real_state")
    self:save(true)
    return true
end

function Yomimon:pet()
    local ok = State.pet(self.state, os.time())
    if ok then self:save(true) end
    return ok
end

-- Persistence -------------------------------------------------------------

function Yomimon:save(with_image)
    self.db:saveSetting("state", self.state)
    self.db:flush()
    if with_image then self:generateImage() end
end

-- pick = true only when the Kindle goes to sleep (onSleep): in the other redraws, which nobody sees, the
-- phrase is the last one chosen and nothing is spent (State.restSpeech).
function Yomimon:generateImage(force, pick)
    if not force and not self:sleepScreenActive() then return end
    if lfs.attributes(self.folder, "mode") ~= "directory" then lfs.mkdir(self.folder) end
    local ok, err = Drawing.writeRecord(YomimonScreen.generateSleepScreen, self.state, self.image, os.time(), pick)
    if not ok then logger.warn("Yomimon: failed to generate the sleep screen:", err) end
    self.pages_without_image = 0
end

--- The Kindle is going to sleep (called before KOReader shows the sleep screen): picks the phrase and draws the image.
function Yomimon:onSleep()
    if not self:sleepScreenActive() then return end
    State.passTime(self.state, os.time())
    self:generateImage(false, true)
end

function Yomimon:onCloseDocument()
    self:countCurrentPage()
    self:checkFinished()
    self:save(true)
end

function Yomimon:onSuspend()
    self:countCurrentPage()
    self:checkFinished()
    State.passTime(self.state, os.time())
    self:save(true)
end

function Yomimon:onResume()
    if self.page then self.page_since = os.time() end
    State.passTime(self.state, os.time())
    self:generateImage() -- leaves the image ready for the next time the Kindle sleeps
end

function Yomimon:onFlushSettings()
    self:save(false)
end

-- Sleep screen -----------------------------------------------------------

function Yomimon:sleepScreenActive()
    return G_reader_settings:readSetting("screensaver_type") == "random_image"
        and G_reader_settings:readSetting("screensaver_dir") == self.folder
end

--- Turns Yomimon on or off as the sleep screen, keeping the previous setting.
function Yomimon:toggleSleepScreen()
    if self:sleepScreenActive() then
        local saved = self.db:readSetting("previous_screen") or {}
        G_reader_settings:saveSetting("screensaver_type", saved.kind or "disable")
        if saved.folder then
            G_reader_settings:saveSetting("screensaver_dir", saved.folder)
        else
            G_reader_settings:delSetting("screensaver_dir")
        end
        if saved.message ~= nil then
            G_reader_settings:saveSetting("screensaver_show_message", saved.message)
        end
        self.db:delSetting("previous_screen")
    else
        self.db:saveSetting("previous_screen", {
            kind = G_reader_settings:readSetting("screensaver_type"),
            folder = G_reader_settings:readSetting("screensaver_dir"),
            message = G_reader_settings:readSetting("screensaver_show_message"),
        })
        self:generateImage(true)
        G_reader_settings:saveSetting("screensaver_type", "random_image")
        G_reader_settings:saveSetting("screensaver_dir", self.folder)
        G_reader_settings:saveSetting("screensaver_show_message", false)
    end
    self:save(false)
end

--- Dev mode: turns the test failure on or off in reading (creates or deletes koreader/yomimon/force_failure).
function Yomimon:toggleTestFailure()
    local file_path = self.folder .. "/force_failure"
    if self.test_failure then
        os.remove(file_path)
        self.test_failure = false
    else
        if lfs.attributes(self.folder, "mode") ~= "directory" then lfs.mkdir(self.folder) end
        local f = io.open(file_path, "w")
        if f then f:write("teste\n"); f:close() end
        self.test_failure = true
    end
    return self.test_failure
end

-- Every point where KOReader calls Yomimon goes through the guard.
Guard.default:wrap(Yomimon, { "onPageUpdate", "onCloseDocument", "onSuspend", "onResume", "onFlushSettings",
    "onShowYomimon", "onStart", "showWelcome", "onReaderReady", "onSleep", "onCloseWidget" })

return Yomimon
