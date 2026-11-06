--[[--
Yomimon's life: hunger, mood, evolution and hibernation.

Pure logic (no KOReader dependencies), so it can be tested outside it.
All times are in seconds since the epoch (os.time()).
]]

local Language = require("yomimon_language")
local Voice = require("yomimon_voice")
local Species = require("yomimon_species")
local T = Language.t

local State = {}

State.HUNGER_PER_HOUR = 100 / 48     -- a full belly empties in 2 days
State.MOOD_PER_HOUR = 100 / 72    -- a full mood fades in 3 days
State.LETTERS_PER_POINT = 300       -- 300 letters = +1 belly (a page ≈ +5)
State.HIBERNATE_AFTER = 3 * 24 * 3600 -- empty belly for 3 days: it hides in the ball
State.PET_INTERVAL = 3600     -- one pet per hour counts
State.RECENT_MEAL = 120       -- stays "happy" for up to 2 min after eating
State.READING_NOW = 30 * 60        -- read in the last 30 min: it is reading (at night, it stays awake)
State.SESSION_PAUSE = 30 * 60       -- a pause longer than this starts another reading session
State.RECENT_SPEECHES = 80          -- how many recent phrases it avoids repeating (80 since step 4 of the voice: with the weighted
                                    -- draw, the few phrases that match it came back every 40)

-- Each species has a line of 1 to 3 forms (yomimon_species.lua); the chosen one is kept in s.especie (the
-- Pokédex number of the first form). Without a chosen species (still in the welcome) it is a ball.
-- temperamento: "jovem" (anxious, insecure) or "velha" (grumpy, knows too much), in the final forms.
local FORM_MIN_LETTERS = { { 0 }, { 0, 300000 }, { 0, 150000, 600000 } }  -- 150000 letters ~ 100 pages
-- The phrase banks are still organised by Yomimon's old stages (ninfa, jovem, adulta, anciã): each form uses one.
local SPEECH_STAGE = { { "young" }, { "nymph", "adult" }, { "nymph", "young", "elder" } }
local forms_per_species = {}

local function lineOf(base)
    for _, l in ipairs(Species.lines) do
        if l[1] == base then return l end
    end
end

--- Forms of the species of `s`, from first to final: { nome = "p<dex>", dex, titulo, min, temperamento, aviso }.
function State.forms(s)
    local base = s and s.species
    local line = base and lineOf(base)
    if not line then
        return { { nameText = "ball", titleText = T"ball", min = 0, temperament = "young", speech_stage = "nymph" } }
    end
    if forms_per_species[base] then return forms_per_species[base] end
    local list = {}
    for i, dex in ipairs(line) do
        local nameText = Species.names[dex]
        list[i] = {
            nameText = "p" .. dex, dex = dex, titleText = nameText, min = FORM_MIN_LETTERS[#line][i], speech_stage = SPEECH_STAGE[#line][i],
            temperament = (i == #line and #line > 1) and "old" or "young",
            notice = i > 1 and string.format(T"%s evolved into %s!", Species.names[line[i - 1]], nameText) or nil,
        }
    end
    forms_per_species[base] = list
    return list
end

local function limitTo(v)
    return math.max(0, math.min(100, v))
end

function State.new(now)
    return {
        birth = now,
        updated = now,
        belly = 60,
        mood = 70,
        letters = 0,
        pages = 0,
        pet_at = 0,
        hibernating = false,
    }
end

-- Fields that, when present, must be tables.
local TABLE_FIELDS = { "themes", "books", "diary", "collection", "reviews", "traits", "traits_level",
                        "recent_speeches", "day", "pending_comment", "sim_finished", "sim_highlights",
                        "memories", "pending_memory", "seenList", "pace", "pending_card", "stored",
                        "said_cards", "influences" }

--- Makes sure a state read from disk has all the fields, with the right types.
-- A missing, wrong-typed or NaN basic field goes back to its initial value; a wrong-typed table is dropped;
-- belly and mood stay between 0 and 100.
function State.normalize(s, now)
    local base = State.new(now)
    if type(s) ~= "table" then return base end
    for k, v in pairs(base) do
        if type(s[k]) ~= type(v) or s[k] ~= s[k] then s[k] = v end
    end
    for _, k in ipairs(TABLE_FIELDS) do
        if s[k] ~= nil and type(s[k]) ~= "table" then s[k] = nil end
    end
    s.belly, s.mood = limitTo(s.belly), limitTo(s.mood)
    if s.letters < 0 then s.letters = 0 end
    if s.pages < 0 then s.pages = 0 end
    return s
end

--- Applies the passing of time since the last update.
function State.passTime(s, now)
    local dt = now - s.updated
    if dt <= 0 then -- clock went back (or nothing passed): no punishment
        s.updated = math.max(s.updated, now)
        return
    end
    local hours = dt / 3600
    local belly_before = s.belly
    s.belly = limitTo(s.belly - hours * State.HUNGER_PER_HOUR)
    local factor = s.belly < 20 and 2 or 1 -- when hungry, the mood drops faster
    s.mood = limitTo(s.mood - hours * State.MOOD_PER_HOUR * factor)
    if s.belly <= 0 then
        if not s.empty_since then
            local hours_to_zero = belly_before / State.HUNGER_PER_HOUR
            s.empty_since = s.updated + math.floor(hours_to_zero * 3600)
        end
        if now - s.empty_since >= State.HIBERNATE_AFTER then
            s.hibernating = true
        end
    end
    s.updated = now
end

function State.stage(s)
    local forms = State.forms(s)
    if s.dev_stage then  -- dev mode: stage forced just for testing
        for _, f in ipairs(forms) do if f.nameText == s.dev_stage then return f end end
    end
    local current = forms[1]
    for _, f in ipairs(forms) do
        if s.letters >= f.min then current = f end
    end
    return current
end

--- Switches (or picks) the Pokémon. Each one's progress is kept in s.colecao[base] (letters read
-- with it) and comes back when it is picked again. The first pick inherits the letters already read.
function State.switchSpecies(s, base)
    s.collection = s.collection or {}
    if s.species then
        s.collection[s.species] = s.letters
        s.letters = s.collection[base] or 0
    end
    s.collection[base] = s.letters
    s.species, s.dev_stage = base, nil
end

--- The Pokémon already chosen: { base, forma, estagio, total, letras, atual }, the current one first.
function State.collection(s)
    local list = {}
    for base, letters in pairs(s.collection or {}) do
        local current = base == s.species
        if current then letters = s.letters end
        local forms = State.forms({ species = base })
        local formIndex = 1
        for i, f in ipairs(forms) do if letters >= f.min then formIndex = i end end
        list[#list + 1] = { base = base, form = forms[formIndex], formIndex = formIndex, total = #forms,
                              letters = letters, current = current }
    end
    table.sort(list, function(a, b)
        if a.current ~= b.current then return a.current end
        return a.letters > b.letters
    end)
    return list
end

--- Next form and how many letters are missing (nil if it is already the final one).
function State.nextStage(s)
    for _, f in ipairs(State.forms(s)) do
        if s.letters < f.min then return f, f.min - s.letters end
    end
end

--- Letters per page of this reader (the average of what it ate), or 1,500 before having a base.
function State.lettersPerPage(s)
    local p = s.pages or 0
    if p < 20 then return 1500 end
    return math.max(500, math.min(4000, (s.life_letters or s.letters or 0) / p))
end

--- Progress to the next form.
-- Returns { fase, proxima (nil in the final form), fracao 0..1, paginas left }.
function State.stageProgress(s)
    local stage = State.stage(s)
    local nextItem, missing = State.nextStage(s)
    if not nextItem then return { stage = stage, fraction = 1, pages = 0 } end
    local fraction = math.max(0, math.min(1, (s.letters - stage.min) / math.max(1, nextItem.min - stage.min)))
    local pages = missing > 0 and math.max(1, math.ceil(missing / State.lettersPerPage(s))) or 0
    return { stage = stage, nextForm = nextItem, fraction = fraction, pages = pages }
end

--- Feeds with letters read. Returns what happened: {evoluiu = fase, acordou = true}.
-- onde (optional): { livro = "Title", capitulo = "Ch. VII" } of the page eaten.
function State.eat(s, letters, word, now, where)
    State.passTime(s, now)
    local occurred = {}
    if not letters or letters <= 0 then return occurred end
    local stage_before = State.stage(s)
    s.letters = s.letters + letters
    s.life_letters = (s.life_letters or s.letters - letters) + letters
    s.pages = s.pages + 1
    local points = letters / State.LETTERS_PER_POINT
    s.belly = limitTo(s.belly + points)
    s.mood = limitTo(s.mood + points * 0.5)
    s.empty_since = nil
    -- session: a long pause starts another
    if not s.last_meal or now - s.last_meal > State.SESSION_PAUSE then
        s.session_start, s.session_pages = now, 0
    end
    s.session_pages = (s.session_pages or 0) + 1
    s.last_meal = now
    if word then s.last_word = word end
    if where then
        s.last_book = where.book or s.last_book
        s.last_chapter = where.chapter
        s.last_file = where.file_path or s.last_file
        s.last_progress = where.progress
    end
    local day = os.date("%Y-%m-%d", now)
    if s.today ~= day then
        -- streak of days reading in a row (s.hoje is still the last day it ate)
        local yesterday = os.date("%Y-%m-%d", now - 86400)
        s.sequence = s.today == yesterday and (s.sequence or 1) + 1 or 1
        s.today, s.pages_today = day, 0
        s.days_read = (s.days_read or 0) + 1
    end
    s.pages_today = (s.pages_today or 0) + 1
    if s.pages_today > (s.day_record or 0) and (s.day_record or 0) >= 10 then s.record_at = day end
    s.day_record = math.max(s.day_record or 0, s.pages_today)
    if tonumber(os.date("%H", now)) < 5 then s.small_hours = true end
    if s.hibernating then
        s.hibernating = false
        occurred.woke = true
    end
    local stage_after = State.stage(s)
    if stage_after ~= stage_before then occurred.evolved = stage_after end
    return occurred
end

function State.totals(s)
    return s.pages or 0, s.days_read or 0
end

-- Milestones (achievements) ----------------------------------------------------------------
-- Each milestone: { titulo, descricao, atual, meta }. "atual >= meta" = achieved.
function State.milestones(s, extras)
    extras = extras or {}
    local pages, books = State.totals(s), extras.finished_books or 0
    local forms, stage = State.forms(s), State.stage(s)
    local formIndex
    for i, f in ipairs(forms) do if f == stage then formIndex = i end end
    local list = {
        { "FIRST PAGE", "READ THE 1ST PAGE", pages, 1 },
        { "A HUNDRED PAGES", "100 PAGES READ", pages, 100 },
        { "A THOUSAND PAGES", "1,000 PAGES READ", pages, 1000 },
        { "FIVE THOUSAND", "5,000 PAGES READ", pages, 5000 },
        { "TEN THOUSAND", "10,000 PAGES READ", pages, 10000 },
        { "EVOLVED", "REACHED THE SECOND FORM", formIndex >= 2 and 1 or 0, 1 },
        { "FINAL FORM", "REACHED THE LAST FORM", (#forms > 1 and formIndex == #forms) and 1 or 0, 1 },
        { "FIRST BOOK", "FINISHED 1 BOOK", books, 1 },
        { "BOOKCASE", "FINISHED 5 BOOKS", books, 5 },
        { "FULL SHELF", "FINISHED 10 BOOKS", books, 10 },
        { "BIBLIOPHAGE", "FINISHED 25 BOOKS", books, 25 },
        { "LIBRARY", "FINISHED 50 BOOKS", books, 50 },
        { "MARATHON", "50 PAGES IN A DAY", s.day_record or 0, 50 },
        { "SMALL HOURS", "READ PAST 2 AM", s.small_hours and 1 or 0, 1 },
        { "OBSESSION", "ONE THEME TOOK OVER", s.dominant_theme and 1 or 0, 1 },
        { "TORN", "TWO OPPOSITE THEMES", extras.ambivalent and 1 or 0, 1 },
        { "COLLECTOR", "50 HIGHLIGHTS", extras.highlights or 0, 50 },
    }
    local out = {}
    for _, m in ipairs(list) do
        out[#out + 1] = { titleText = T(m[1]), description = T(m[2]), current = m[3], meta = m[4], done = m[3] >= m[4] }
    end
    return out
end

--- Pets it. Returns false if it already got a pet in the last hour.
function State.pet(s, now)
    State.passTime(s, now)
    if s.hibernating or now - s.pet_at < State.PET_INTERVAL then
        return false
    end
    s.mood = limitTo(s.mood + 15)
    s.pet_at = now
    return true
end

--- Did you read in the last few minutes?
function State.readingNow(s, now)
    return s.last_meal ~= nil and now - s.last_meal < State.READING_NOW
end

--- "normal", "feliz", "triste" or "dormindo" ("casulo" when hibernating).
-- dormir = true forces sleep when it is well (used on the sleep screen).
function State.expression(s, now, sleep)
    if s.hibernating then return "cocoon" end
    if s.belly < 25 or s.mood < 25 then return "sad" end
    local hour = s.dev_night and 2 or tonumber(os.date("%H", now))
    -- at night it sleeps, unless you are reading right now
    if sleep or ((hour >= 23 or hour < 6) and not State.readingNow(s, now)) then return "sleeping" end
    if (s.last_meal and now - s.last_meal < State.RECENT_MEAL) or s.mood >= 75 then
        return "happy"
    end
    return "normal"
end

-- Sleeping poses drawn on the sleep screen.
State.POSES = { "", "_cobertor", "_estrelas" }

--- Sprite name (stage_expression). pose (optional, from State.POSES) decorates the sleeper.
-- When the drawing of that variation does not exist, the drawing falls back to the stage's.
function State.sprite(s, now, sleep, pose)
    local e = State.expression(s, now, sleep)
    local nameText = (e == "cocoon" and "ball" or State.stage(s).nameText) .. "_" .. e
    if e == "sleeping" and pose then nameText = nameText .. pose end
    return nameText
end

--- Animation frames: asleep it breathes and lets out Zzz; awake it only breathes,
-- and now and then blinks (when it is normal).
function State.frames(s, now, sleep)
    local e = State.expression(s, now, sleep)
    local stage = e == "cocoon" and "ball" or State.stage(s).nameText
    if e == "cocoon" or e == "sleeping" then
        local base = stage .. "_" .. e
        return { base .. "_1", base .. "_2", base .. "_3", base .. "_4" }
    end
    local a, b = stage .. "_" .. e .. "_1", stage .. "_" .. e .. "_2"
    if e == "normal" then
        return { a, b, a, b, a, stage .. "_piscar" }
    end
    return { a, b }
end

-- Phrases by temperament and mood. "casulo" = hidden in the ball (hibernating).
-- "repouso" = sleep screen (the Kindle sleeping).
local Content = Language.content("state")
local SPEECHES, SPEECHES_BOOK, SPEECHES_CHARACTER = Content.SPEECHES, Content.SPEECHES_BOOK, Content.SPEECHES_CHARACTER
local SPEECHES_NEXT_FORM_NEAR, SPEECHES_NEXT_FORM_IMMINENT = Content.SPEECHES_NEXT_FORM_NEAR, Content.SPEECHES_NEXT_FORM_IMMINENT

-- Phrases about what you are reading (%s = book, character or number).

-- Close to the next form (growing a stage). %d = pages left.

-- New batches of phrases (yomimon_locales/<code>/data/extra.lua) add to the lists above.
Language.append({ SPEECHES = SPEECHES, SPEECHES_BOOK = SPEECHES_BOOK, SPEECHES_CHARACTER = SPEECHES_CHARACTER,
    SPEECHES_NEXT_FORM_NEAR = SPEECHES_NEXT_FORM_NEAR, SPEECHES_NEXT_FORM_IMMINENT = SPEECHES_NEXT_FORM_IMMINENT }, Language.extra("state"))

-- s (optional): the phrase that matches it weighs more (yomimon_voice.lua, PLANO-VOZ.md step 4)
local function drawFromList(list, draw, s)
    return Voice.pick(list, s, draw)
end

-- Gaps of the generated phrases: book, word, theme and a character of the current book. With a domain
-- (yomimon_voice.lua), cores with {gosto}, {cheiro}… are also valid (the resolver swaps the words).
local function speechData(s, draw, Memory)
    local data = { book = s.last_book, word = s.last_word,
                    voice = function(t, no_domain) return Voice.resolver(t, s, draw, no_domain) end,
                    pick = function(list, no_domain) return Voice.pick(list, s, draw, no_domain) end }
    if Voice.domainAvailable(s) then
        for slot in pairs(Voice.SLOTS) do data[slot] = "{" .. slot .. "}" end
    end
    if Memory then
        -- words of the book itself (step 5): {palavra} and {marcante} draw among the striking ones of the
        -- current book; without them yet, {palavra} is the last long word eaten and {marcante} has no data
        local marking = s.last_book and Memory.strikings and Memory.strikings(s, s.last_book, 10) or {}
        if #marking > 0 then
            data.striking = marking[draw(#marking)]
            data.word = data.striking
        end
        if s.dominant_theme then data.theme = Memory.THEME_NAMES[s.dominant_theme] end
        local names = s.last_book and Memory.characters(s, s.last_book, 5) or {}
        if #names > 0 then data.character = names[draw(#names)] end
    end
    return data
end

local function shortKey(t)
    local h = 0
    for i = 1, #t do h = (h * 31 + t:byte(i)) % 2147483647 end
    return h
end

--- Draws a phrase. Returns the phrase and the key to avoid repetition (the core, in the generated ones).
local function drawSpeech(s, now, draw, sleep, screen)
    local e = State.expression(s, now, sleep)
    local temp = State.stage(s).temperament
    local group = SPEECHES[temp]
    -- sleep screen: only dreams, even when hungry, sad, close to the next form or hidden in the ball (an awake
    -- phrase breaks the scene)

    if sleep then
        if group._all then
            local cracking = State.nextStage(s) and State.stageProgress(s).pages <= 10
            local quiet_ones = {}
            for _, f in ipairs(cracking and SPEECHES_NEXT_FORM_IMMINENT.egg or group._all) do
                if f:sub(1, 1) == "(" or f == "…" then quiet_ones[#quiet_ones + 1] = f end
            end
            return drawFromList(quiet_ones, draw)
        end
        local okF, Speeches = pcall(require, "yomimon_speech")
        local okM, Memory = pcall(require, "yomimon_memory")
        local data = speechData(s, draw, okM and Memory)
        if okF and draw(2) ~= 2 then
            local f, lookupKey = Speeches.dream(temp, data, draw)
            if f then return f, lookupKey end
        end
        return drawFromList(group.sleepRest, draw, s)
    end
    -- a card from the box (yomimon_cards.lua): on the Home; on the Yomimon screen, if it did not fit on the Home. It comes before
    -- any draw, so trying a card that does not fit on the Home does not change the following phrases.
    if e ~= "sleeping" and e ~= "cocoon" and not group._all then
        local okCar, Cards = pcall(require, "yomimon_cards")
        local car = okCar and Cards.pending(s, now, screen)
        if car then
            car.used = true
            return car.textValue
        end
    end
    -- next form coming: how many pages are left (the same count as the stage card)
    local nextItem = State.nextStage(s)
    if nextItem and e ~= "cocoon" then
        local pages = State.stageProgress(s).pages
        if pages <= 10 then
            return drawFromList(SPEECHES_NEXT_FORM_IMMINENT[temp], draw)
        elseif pages <= 60 and temp ~= "egg" and draw(4) == 1 then
            return (drawFromList(SPEECHES_NEXT_FORM_NEAR[temp], draw):gsub("%%d", tostring(pages)))
        end
    end
    if group._all then
        return drawFromList(group._all, draw)
    end
    if e == "cocoon" then return drawFromList(group.cocoon, draw) end

    local okF, Speeches = pcall(require, "yomimon_speech")
    local okM, Memory = pcall(require, "yomimon_memory")
    local data = speechData(s, draw, okM and Memory)
    -- asleep at night: almost always a generated dream (with the book, the theme and its characters)
    if e == "sleeping" then
        if okF and draw(4) ~= 4 then
            local f, lookupKey = Speeches.dream(temp, data, draw)
            if f then return f, lookupKey end
        end
        return drawFromList(group.sleeping, draw, s)
    end
    -- a new memory (author who returns, anniversary, nothing so gloomy since…): the first phrase, once,
    -- for up to 24h
    local mem = s.pending_memory
    if mem and not mem.used and now - (mem.t or 0) < 24 * 3600 then
        mem.used = true
        return mem.textValue
    end
    -- a chapter just ended: the first phrase after that is about it (once only, for up to 12h)
    local p = s.pending_comment
    if p and not p.used and now - (p.t or 0) < 12 * 3600 then
        p.used = true
        return p.textValue  -- if it said this a moment ago, the no-repeat rule picks another
    end
    -- your reading data: hour, pages today, record, streak, session, part of the book. The strong ones
    -- (small hours, record, marathon, days away) come before the influences; the others, after.
    local okC, Context = pcall(require, "yomimon_context")
    local fc, strong
    if okC then fc, strong = Context.speech(s, now, temp, draw) end
    if fc and strong and draw(10) <= 6 then return fc end
    -- literary influences and base personality (yomimon_influences.lua), the main repertoire: the strongest
    -- picks the phrase, the second may enter the same phrase; without influence, the base personality
    local okI, Influences = pcall(require, "yomimon_influences")
    if okI then
        local hour = tonumber(os.date("%H", now))
        local sit = { sad = e == "sad", happy = e == "happy", hunger = s.belly < 40, full = s.belly >= 85,
                       noite = hour >= 22 or hour < 5,
                       formChange = (nextItem and State.stageProgress(s).pages <= 60) and true or false,
                       stage = State.stage(s).speech_stage, screen = screen }
        -- phrases said a moment ago stay out; if none is left, the turn passes to the rest
        local recents = {}
        for _, h in ipairs(s.recent_speeches or {}) do recents[h] = true end
        local function said_f(lookupKey) return recents[shortKey(lookupKey)] == true end
        local f, lookupKey = Influences.speech(s, data, draw, sit, said_f)
        if f then return f, lookupKey end
    end
    if fc and not strong and draw(10) <= 3 then return fc end
    -- the way it ended up with your readings (bitter, fearful, romantic, nocturnal…)
    local okT, Traits = pcall(require, "yomimon_traits")
    if okT then
        local f = Traits.speech(s, temp, draw)
        if f then return f end
    end
    -- sometimes it talks about what you read or what the books did to it
    local sorte = draw(10)
    if sorte == 1 then
        local f = okM and Memory.speech(s, draw, temp)
        if f then return f end
    elseif sorte == 2 and s.last_book then
        return string.format(drawFromList(SPEECHES_BOOK[temp], draw, s), s.last_book)
    elseif sorte == 3 and data.character then
        return string.format(drawFromList(SPEECHES_CHARACTER[temp], draw, s), data.character)
    elseif sorte == 4 and data.word then
        return string.format(group.word, data.word)
    end
    -- in a bad mood, sometimes it blames something that happened in the book (a cause invented afterwards)
    if e == "sad" and s.mood < 25 and draw(3) == 1 then
        local f = Voice.cause(s, temp, draw)
        if f then return f end
    end
    -- most of the time, a phrase generated for the stage
    if (e == "normal" or e == "happy") and okF and draw(3) ~= 1 then
        local f, lookupKey = Speeches.generate(State.stage(s).speech_stage, data, draw)
        if f then return f, lookupKey end
    end
    return drawFromList(group[e], draw, s)
end


--- A phrase for the current state. sorteio(n) must return an integer from 1 to n.
-- dormir = true is the sleep screen (uses the rest phrases and the dreams).
-- Avoids repeating the last phrases (stores only a number per phrase, in s.recent_speeches; the key is the phrase
-- before choosing the trait variant, so the variants of one phrase count as one).
-- tela: "home" (only by State.speechThatFits), "traca" or nil; decides whether a card from the box may come out.
function State.speech(s, now, draw, sleep, screen)
    draw = draw or math.random
    local recents = s.recent_speeches or {}
    local used_ones = {}
    for _, h in ipairs(recents) do used_ones[h] = true end
    local car = s.pending_card
    local card_used = car and car.used
    local textValue, lookupKey
    for _ = 1, 8 do
        textValue, lookupKey = drawSpeech(s, now, draw, sleep, screen)
        if not used_ones[shortKey(lookupKey or textValue)] then break end
    end
    recents[#recents + 1] = shortKey(lookupKey or textValue)
    while #recents > State.RECENT_SPEECHES do table.remove(recents, 1) end
    s.recent_speeches = recents
    local final = (Voice.resolver(textValue, s, draw))
    -- the card came out in this phrase: on the Yomimon screen, it is said; on the Home, speechThatFits decides (if it fit)
    if car and car.used and not card_used then
        if final ~= car.textValue then
            car.used = card_used  -- the no-repeat rule picked another
        elseif screen ~= "home" then
            local okCar, Cards = pcall(require, "yomimon_cards")
            if okCar then Cards.said(s, car, now) end
        end
    end
    return final
end

--- The sleep-screen phrase. Only chosen when the Kindle goes to sleep (escolher = true): then it enters the
-- recent ones and may use the memory or the chapter comment. Redraws nobody sees (every 10
-- pages, on waking, on closing the book) repeat the last one chosen, spending nothing; if there was
-- none yet, they draw one and return the state as it was.
function State.restSpeech(s, now, pick, draw)
    if pick then
        s.rest_speech = State.speech(s, now, draw, true)
        return s.rest_speech
    end
    if type(s.rest_speech) == "string" then return s.rest_speech end
    local recents = {}
    for i, v in ipairs(s.recent_speeches or {}) do recents[i] = v end
    local mem, with = s.pending_memory, s.pending_comment
    local mem_used, with_used = mem and mem.used, with and with.used
    local textValue = State.speech(s, now, draw, true)
    s.recent_speeches = recents
    if mem then mem.used = mem_used end
    if with then with.used = with_used end
    return textValue
end

--- A phrase that fits a small space (the Home card): linhas(texto) says how many lines it takes.
-- Draws again (up to `attempts`) when it exceeds `max_lines`, without side effects from the attempts:
-- only the chosen phrase enters the recent ones, and a memory or chapter comment that does not fit stays
-- stored for the main screen (where there is room). Returns the text and how many lines it takes; if nothing
-- fits, the shortest of the attempts. It is the Home phrase: the box card comes out here first; if it does not
-- fit, it is marked (did_not_fit) and waits for the Yomimon screen.
function State.speechThatFits(s, now, lines, max_lines, attempts, draw)
    local function copy(t) local o = {} for i, v in ipairs(t or {}) do o[i] = v end return o end
    local mem, with, car = s.pending_memory, s.pending_comment, s.pending_card
    local orig = { recents = copy(s.recent_speeches), mem = mem and mem.used, with = with and with.used,
                   car = car and car.used }
    local picked_one, n_esc, best, n_best
    for _ = 1, attempts or 8 do
        s.recent_speeches = copy(orig.recents)
        local textValue = State.speech(s, now, draw, nil, "home")
        if textValue then
            local n = lines(textValue)
            if n <= (max_lines or 2) then picked_one, n_esc = textValue, n; break end
            if not best or n < n_best then best, n_best = textValue, n end
        end
    end
    -- memory/comment that showed up in an attempt and did not fit: stays stored
    if mem and mem.textValue ~= picked_one then mem.used = orig.mem end
    if with and with.textValue ~= picked_one then with.used = orig.with end
    if car and not orig.car then
        if car.textValue == (picked_one or best) then
            local okCar, Cards = pcall(require, "yomimon_cards")
            if okCar then Cards.said(s, car, now) end
        else
            if car.used then car.did_not_fit = true end  -- showed up in an attempt and did not fit
            car.used = orig.car
        end
    end
    if not picked_one then
        s.recent_speeches = orig.recents
        return best, n_best
    end
    return picked_one, n_esc
end

--- Pages eaten today (resets at midnight).
function State.pagesToday(s, now)
    if s.today ~= os.date("%Y-%m-%d", now) then return 0 end
    return s.pages_today or 0
end

--- How many of the 4 little dots are full for a value from 0 to 100.
function State.dots(val)
    return math.max(0, math.min(4, math.ceil((val or 0) / 25 - 1e-9)))
end

local BELLY_LABEL = { { 75, "FULL" }, { 50, "SATED" }, { 25, "PECKISH" }, { 0.5, "HUNGRY" }, { -1, "STARVING" } }
local MOOD_LABEL = {
    young = { { 75, "PERKY" }, { 50, "CALM" }, { 25, "ANXIOUS" }, { -1, "TERRIFIED" } },
    old = { { 75, "ALMOST CONTENT" }, { 50, "RESIGNED" }, { 25, "GRUMPY" }, { -1, "UNBEARABLE" } },
}

local function label(tbl, val)
    for _, r in ipairs(tbl) do
        if val >= r[1] then return T(r[2]) end
    end
    return T(tbl[#tbl][2])
end

function State.bellyLabel(s)
    return label(BELLY_LABEL, s.belly)
end

function State.moodLabel(s)
    return label(MOOD_LABEL[State.stage(s).temperament], s.mood)
end

--- Counts letters in a UTF-8 text (ASCII letters + one per accented character).
function State.countLetters(textValue)
    if type(textValue) ~= "string" then return 0 end
    local _, ascii = textValue:gsub("%a", "")
    local _, multibyte = textValue:gsub("[\194-\244]", "")
    return ascii + multibyte
end

--- The longest word (up to 20 bytes) of the text, or nil.
function State.longestWord(textValue)
    if type(textValue) ~= "string" then return nil end
    -- dashes, curly quotes, ellipses and « » are not part of words
    textValue = textValue:gsub("\226\128[\128-\191]", " "):gsub("\194[\160-\191]", " ")
    local best
    for p in textValue:gmatch("[%a\128-\255]+") do
        if #p <= 20 and (not best or #p > #best) then best = p end
    end
    if best and #best >= 6 then return best:lower() end
end

return State
