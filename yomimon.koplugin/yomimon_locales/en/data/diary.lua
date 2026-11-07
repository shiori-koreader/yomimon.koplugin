--[[--
Diary phrase bank (English). Same structure as the Portuguese diary; {theme} and {of_theme} already come
with an article ("the sea"), and the prepositions stay in the phrases.
]]

local B = { day = {}, beginning = {}, ending = {}, obsession = {}, recollection = {} }

B.day.thin = {
    "A thin day: {n} pages of “{book}”.",
    "Only {n} pages today. I nibbled at “{book}”.",
    "{n} pages of “{book}”. An appetiser.",
    "Not much today: {n} pages of “{book}”. I licked my fingers.",
    "A few crumbs of “{book}”: {n} pages.",
    "{n} pages. “{book}” barely touched my mouth.",
}
B.day.normal = {
    "{n} pages of “{book}”.",
    "Ate {n} pages of “{book}”.",
    "Another {n} pages of “{book}” in my belly.",
    "Today: “{book}”, {n} pages.",
    "Moved {n} pages further into “{book}”.",
    "“{book}” gave me {n} pages today.",
    "{n} pages. “{book}” is still on my plate.",
}
B.day.feast = {
    "{n} pages of “{book}”. A banquet.",
    "A feast today: {n} pages of “{book}”.",
    "{n} pages of “{book}” in one go. I'm full.",
    "Ate {n} pages of “{book}”. I forgot to breathe.",
    "A fat day: {n} pages of “{book}”.",
    "{n} pages of “{book}”. My belly begged for mercy.",
}
B.day.huge_one = {
    "{n} pages of “{book}” in a single day. I'm round.",
    "{n} pages. You didn't read “{book}”, you crossed it.",
    "Marathon: {n} pages of “{book}”. I need to lie down.",
}
B.day.two_books = {
    "{n} pages, split between “{book}” and “{book2}”.",
    "Two dishes today: “{book}” and a little “{book2}”. {n} pages.",
    "{n} pages. Torn between “{book}” and “{book2}”, like someone who can't pick dessert.",
    "Cheated on “{book2}” with “{book}”. {n} pages in total.",
}
B.day.time_of_day = {
    small_hours = { "Almost all of it in the small hours.", "Read after midnight, like secrets are.", "Another sleepless night.<nocturnal: I love it.|fearful: With the light on.|>",
                  "We read while the house slept.<fearful: I heard every creak.|>" },
    morning = { "All of it before lunch.", "Read in the morning, smelling of coffee.<diurnal: My hour.|>", "We started early." },
    night = { "Read late at night.", "Mostly after ten.", "Deep into the night.<nocturnal: Just how I like it.|>" },
}
B.day.speech = {
    young = { "{nameText} said “{speech}”. I repeated it quietly.", "{nameText} said “{speech}”. I keep thinking about it.",
              "I saved a line from {nameText}: “{speech}”.", "“{speech}”, said {nameText}. I'd never be that brave." },
    old = { "{nameText} said “{speech}”. Noted, never to be forgiven.", "“{speech}”, said {nameText}. I'd have said it better.",
              "Line of the day, by {nameText}: “{speech}”. It deserved a cigarette.", "{nameText}: “{speech}”. Saved. <romantic:I'll use it in a letter.|I'll use it against someone.>" },
}
B.day.new = {
    "I met {nameText}.", "{nameText} showed up. Not sure what I think yet.", "Enter {nameText}.",
    "I was introduced to {nameText}. Without much enthusiasm.", "Someone called {nameText} arrived. <romantic:I liked them at once.|fearful:I hid.|I'm keeping an eye on them.>",
    "{nameText} appeared. Trouble.",
}
B.day.newOnes2 = {
    "I met {nameText} and {name2}.", "{nameText} and {name2} showed up. Too many people.",
    "{nameText} and {name2} entered the scene. One of them will annoy me.", "Introduced to {nameText} and {name2}. Noted both.",
}
B.day.event = {
    death = { "Someone died.", "A death. <romantic:I really cried.|fearful:I slept with the light on.|I mourned out of politeness.>", "They buried someone. Smell of candles." },
    wedding = { "A wedding.", "Someone got married. <romantic:I cried at the altar.|hopeful:This one will last.|I give it three chapters.>", "Bride, altar, vow. Noted, for later." },
    travel = { "Someone hit the road.", "A journey. <brave:I went along, stowed in a suitcase.|I stayed home.>", "People leaving and arriving all day." },
    letter = { "A letter arrived.", "A letter. <romantic:I read it twice.|hopeful:Good news, for a change.|Never good news.>", "Someone wrote what they shouldn't have." },
    storm = { "It rained in the book.", "A storm." },
    illness = { "Someone fell ill.", "Fever and a doctor.", "Someone bedridden. Bad sign." },
    party = { "A party.", "A ball. <romantic:I danced alone in the margin.|Nobody invited me.>", "Music and wine. For them." },
    quarrel = { "A fight.", "Someone finally said what they thought." },
    escape = { "Someone ran away.", "An escape.", "People running from their own fate." },
    crime = { "A crime.", "Blood and police." },
}
B.day.theme = {
    "It was all about {theme}.", "Nothing but {theme} today.", "Too much of {theme} today.",
    "The day tasted of {theme}.", "Everything revolved around {theme}.",
}
B.day.heavy = { "Heavy pages.", "A dark day of paper.", "Lots of shadow, little light.", "Reading that leaves a mark." }
B.day.light = { "Light pages, for a change.", "A sweet day of paper.", "Reading that doesn't hurt. Rare." }
B.day.closing = {
    young = { "More tomorrow.", "I'm liking it.", "Fell asleep thinking about it.", "I want more.", "" },
    old = { "Noted.", "How tiresome.", "Lit an imaginary cigarette.", "Onwards.", "Nothing new. Almost.", "" },
}
B.day.closing_dark = {
    young = { "Slept badly.", "Got scared of the dark.", "Left the light on." },
    old = { "Slept badly. As usual.", "One more weight on the shelf.", "Needed two imaginary cigarettes.", "Predictable. Hurt anyway." },
}
B.day.closing_light = {
    young = { "Had a lovely dream.", "Happy for no reason.", "Fell asleep smiling." },
    old = { "Almost smiled.", "I distrust so much lightness.", "Don't get used to it." },
}

B.beginning.generic_one = {
    "Started gnawing on “{book}”. The cover promised a lot. Covers always do.",
    "New book: “{book}”. Paper that doesn't know what's coming.",
    "“{book}” has reached my plate. Let's see if it holds up.",
    "Opened “{book}”. First pages always swear it'll be worth it.",
    "We've started “{book}”. Me hungry, you hopeful.",
    "Another book: “{book}”. My belly thanks you, my mood reserves judgement.",
    "“{book}”. New address. Still unpacking.",
}
B.beginning.author = {
    "“{book}”, by {author}. Let's see if {author} deserves my appetite.",
    "Started “{book}”. I've never eaten any {author}. First times are always strange.",
    "{author}, a pleasure. I've come to eat your “{book}”.",
}
B.beginning.same_author = {
    "Another {author}: “{book}”. Loyalty or laziness?",
    "{author} again. “{book}” now. Are we dating?",
    "Back to {author}. “{book}” is the next course.",
    "Another {author}. You really can't let go of this author.",
}
B.beginning.dropped = {
    "Dropped “{previous}” halfway. Now it's “{book}”. No comment. Comment: cowardice.",
    "“{previous}” was left behind, unfinished. Swapped for “{book}”. I saw that.",
    "We abandoned “{previous}”. May it rest in peace. Now: “{book}”.",
    "We jumped to “{book}”. “{previous}” will be glaring at me from the shelf.",
}
B.beginning.rereading = {
    "Rereading “{book}”. I know the ending. Eating slowly.",
    "“{book}” again. Either you forgot it or you fell in love.",
    "Rereading “{book}”. This time I'm watching the details. And the commas.",
}

B.ending.opening = {
    "Finished “{book}”.", "The end of “{book}”.", "“{book}” is over.", "Last page of “{book}”.",
    "Ate the last line of “{book}”.",
}
-- {nameText}: the book's composite name (yomimon_vector.lua), e.g. "a sea story, restless"
B.ending.nameText = { "It was {nameText}.", "Deep down, {nameText}.", "In short: {nameText}.", "If anyone asks: {nameText}." }
B.ending.protagonist = {
    young = { "I'll miss {nameText}.", "{nameText} is stuck in my head.", "{nameText} will live in my heart. It's small, but there's room." },
    old = { "{nameText} is stuck in my head. Against my will.", "{nameText} will haunt me for a few days.", "I survived {nameText}. Barely." },
}
B.ending.darker = { "Darker than “{other}”.", "Heavier than “{other}”.", "Made “{other}” look like a comedy." }
B.ending.lighter = { "Lighter than “{other}”.", "After “{other}”, a breather.", "Hurt less than “{other}”." }
B.ending.series = {
    "{ordinal} book in a row about {theme}. Are you running from something?",
    "{ordinal} book in a row about {theme}. I see a pattern.",
    "{ordinal} time one of your books feeds me {theme}. Noted.",
}
B.ending.trait = {
    bitter = { "I came out bitterer than I went in.", "This book took away a little hope." },
    hopeful = { "I came out lighter than I went in.", "This book gave me back a little faith." },
    fearful = { "I came out jumpier than I went in.", "This book taught me to check under the pages." },
    brave = { "I came out braver than I went in." },
    cynical = { "I came out more suspicious than I went in.", "This book taught me to follow the money." },
    romantic = { "I came out more romantic than I went in.", "This book softened me. How embarrassing." },
    popular = { "I came out in a hurry to read. Bad sign.", "This book spoiled me with its pace." },
    erudite = { "I came out more cultured than I went in. Insufferable.", "This book has me quoting authors." },
}
B.ending.grade = {
    young = { "Rating: {n} little stars.", "I give it {n} little stars.", "{n} little stars out of 5." },
    old = { "Rating: {n} imaginary cigarettes.", "{n} imaginary cigarettes out of 5.", "Worth {n} imaginary cigarettes." },
}
B.ending.verdict = {
    young = {
        { "I ate it to be polite. Sorry, author.", "It wasn't for me. I think." },
        { "There was good stuff, but it took its time.", "Lukewarm. Like paper left in the sun." },
        { "I liked it! Not a lot. But I liked it." },
        { "What a book! I'll dream about it.", "I was sad when it ended. That's good, right?" },
        { "The best thing I've ever eaten. So far. I think. Yes.", "I want to read it again. Now. Right now." },
    },
    old = {
        { "A book that exists. That's all." },
        { "It had its moments. Few.", "Lukewarm. Like forgotten tea." },
        { "Decent. Rare, these days.", "It didn't change my life. Didn't ruin it either." },
        { "A good book. I'll miss hating it.", "This author knew what they were doing. I hate when that happens." },
        { "Rare. A book I couldn't manage to hate.", "I close the cover with respect. And a cigarette." },
    },
}

B.obsession.new = {
    "I noticed I think a lot about {theme}. I didn't ask for this.",
    "I keep thinking about {theme}. Blame your books.",
    "I can't stop thinking about {theme}. I'll need another book. Or therapy.",
}
B.obsession.swap = {
    "I used to think about {before}. Now all I think about is {now}. Blame you and your books.",
    "Swapped obsessions: out goes {before_s}, in comes {now_s}.",
    "{now_s} has taken the place of {before_s} in my head.",
    "I don't think about {before} so much anymore. Now it's {now_s}, all the time.",
}

-- Memories (yomimon_memories.lua): {author} {n} {book} {month} {nameText} {theme} {of_theme} ----------------
B.recollection.author = {
    "{author} again. That's book number {n} by {author} for us. This is a relationship now.",
    "Back to {author}: book {n}. I can taste the seasoning already.",
    "Number {n} by {author}. Some people collect stamps.",
    "More {author}. Number {n}. You don't get tired, and honestly, neither do I.",
}
B.recollection.anniversary = {
    "One year ago today we finished “{book}”. I can still taste it.",
    "A year since the end of “{book}”. Do you remember? I remember everything.",
    "Anniversary: exactly one year since the last page of “{book}”.",
}
B.recollection.character = {
    "{nameText} again… we know each other from “{book}”.",
    "Look who's back: {nameText}. Haven't seen that one since “{book}”.",
    "{nameText}! I thought they stayed behind in “{book}”.",
    "{nameText} once more. “{book}” wasn't enough, apparently.",
}
B.recollection.longest_record = {
    "“{book}”: {n} pages. The longest book you've ever read with me. I'm stuffed.",
    "Record: “{book}” was the longest thing we've ever eaten together.",
    "We've never eaten anything as big as “{book}”. I need to lie down.",
}
B.recollection.fastest_record = {
    "No book ever went down as fast as “{book}”. Either it was good or you were starving.",
    "Speed record: “{book}”. It gave me hiccups.",
}
B.recollection.theme_series = {
    "Book number {n} in a row about {theme}. I see a pattern. Do you?",
    "Another book about {theme}. That's {n} in a row. Are you looking for something?",
    "{n} books in a row where {theme} rules. Noted in my little notebook.",
}
B.recollection.gloomy_since = {
    "You haven't read anything this dark since “{book}”, back in {month}.",
    "Not since “{book}”, in {month}, have I eaten pages this dark.",
    "This is as heavy as “{book}”. And that was in {month}.",
}
B.recollection.gloomiest = {
    "This is the darkest book we've ever read together. I'm in mourning and I don't know why.",
    "I've never eaten pages this dark with you. A record nobody wanted.",
}
B.recollection.light_since = {
    "Nothing this light since “{book}”, in {month}. What a relief.",
    "Not since “{book}”, in {month}, have I eaten pages this sweet.",
}
B.recollection.lighter = {
    "The lightest book we've ever read together. Suspicious.",
    "I've never eaten pages this sweet with you. I'll get cavities.",
}

return B
