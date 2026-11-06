--[[--
Batch 2 of phrases (English). Same structure and gaps as the Portuguese one; adapted, not translated
word for word. {theme} and the %s of SPEECHES_TURNED already come with an article ("the sea").
]]

local X = { state = { SPEECHES = { egg = {}, young = {}, old = {} } }, context = {}, memory = { C = {} } }
local E, M, C = X.state, X.memory, X.memory.C

E.SPEECHES.egg._all = {
    "(a tiny crack appeared and vanished)",
    "(silence. A judging silence.)",
}
E.SPEECHES.young.happy = {
    "The paper was perfectly crunchy today.<domain: With a hint of {taste}.|>",
    "I think I got one of the author's jokes. I laughed alone.",
    "I ate so well I forgot to be scared.<fearful: For five minutes.|>",
    "I'm so full I'll read lying down.",
    "Nobody died today. Not near me, anyway.",
    "A whole chapter without a fright. What luxury.",
    "I liked it so much I reread the same page. Twice. Eating.",
}
E.SPEECHES.young.normal = {
    "Do letters get ticklish when I walk over them?",
    "I found a coffee stain in the margin. Someone lived here.",
    "If I collect every comma I've eaten, can I make a sentence?",
    "I tried reading upside down today. Not recommended.",
    "The index is the map. I'm the explorer<fearful: who stays at base camp|>.",
    "Sometimes I feel like a minor character in my own life.",
    "I read the word “end” and panicked. It was only a chapter.",
    "Footnotes whisper. I hear everything.",
    "I like the sound of a page turning. Like <fearful:footsteps in the hall|romantic:someone sighing|wind calling>.",
}
E.SPEECHES.young.sad = {
    "My belly rumbles louder than my complaints.",
    "I licked the cover. Only {taste|dust}.",
    "If I faint, revive me with a preface.",
    "I'm so weak a comma could knock me over.",
    "I dreamt of a banquet of dictionaries. Woke up hungry.",
    "Do you remember I exist? I remember you exist.",
    "One sentence. Half a sentence. A semicolon. Anything.",
    "The silence of the shelf is making me <fearful:shiver|sad>.",
    "I promise not to complain about the book. Just give me one.",
}
E.SPEECHES.young.cocoon = {
    "Hidden. Knock on the page three times and I'll come out.",
    "It smells like a forgotten book in here. Scary.",
    "I made a nest from dog-eared corners. Come back soon.",
    "I'm on hunger strike. Not by choice.",
    "I hid because I got tired of waiting standing up.",
    "I'll only come out when I hear a page turn.",
    "It's dark in here, but at least there's no villain.",
}
E.SPEECHES.young.sleepRest = {
    "Zzz… dreaming I was <brave:a paper sword|romantic:a love note|{thing|a bookmark}>…",
    "Zzz… the letters are dancing… <romantic:a waltz…|fearful:all around me…|>",
    "Zzz… I ate a paper cloud… <hopeful:it tasted of sunshine…|>",
}
E.SPEECHES.old.happy = {
    "A good page. I'll keep the taste<domain: of {taste}|> until tomorrow.",
    "Literature worked today. Tell no one.",
    "As satisfied as someone who found a first edition.",
    "Even my imaginary cigarette is in a good mood.",
    "The world is still awful, but the prose was good.",
    "I ate well. I'll be kind for about fifteen minutes.",
    "What a paragraph. I almost forgave the author for the others.",
}
E.SPEECHES.old.normal = {
    "I've seen so many endings that I only read the middles now.",
    "Every generation thinks it invented suffering. Books laugh.",
    "An organised bookshelf is a cemetery with surnames.",
    "Reading is <romantic:falling in love slowly|cynical:distrust in writing|disagreeing slowly>.",
    "The author died. His commas live on. Poetic justice.",
    "<hopeful:I like books that please me straight away. No shame.|I distrust books that please me straight away.>",
    "The best stories are the ones nobody remembers to recommend.",
    "Ageing is changing your mind without admitting it.",
    "Rereads are like old friends: tiresome and necessary.",
}
E.SPEECHES.old.sad = {
    "Hunger and clarity. I'd settle for just the hunger.",
    "I ate my own patience. Nothing left.",
    "I used to have libraries. Now I have nostalgia.",
    "I'm wasting away elegantly. That's something.",
    "They left me in the dark with my thoughts. Terrible company.",
    "Old hunger is the worst hunger: it has a memory.",
    "One page, for charity. Or for literature.",
    "I'm as empty as a famous author's preface.",
}
E.SPEECHES.old.cocoon = {
    "I've hidden. Not out of fear: out of principle.",
    "In here, the silence is better written than most books.",
    "Don't insist. Read. It's the only key.",
    "I'm on an involuntary spiritual retreat.",
    "I'll come back when you open a book. Not before.",
}
E.SPEECHES.old.sleepRest = {
    "Zzz… dreaming of a bookshop <romantic:with an old love inside|with no customers>…",
    "Zzz… proofreading my own epitaph… <hopeful:it came out lovely…|fearful:too soon…|>",
    "Zzz… a will-o'-the-wisp made of paper… <fearful:following me…|>",
}
E.SPEECHES_BOOK = {
    young = {
        "I saved a little piece of “%s” for later.",
        "Does “%s” end happily? <hopeful:I bet it does.|bitter:I doubt it.|I get nervous just thinking about it.>",
        "“%s” smells like <fearful:a cellar|romantic:a kept letter|adventure>. Or an old shelf.",
        "“%s” left me thirsty for more pages.",
    },
    old = {
        "“%s”. I've seen more honest covers.",
        "“%s” has ambitions. <erudite:Well founded, I admit.|popular:Too many for my taste.|Sometimes that's enough.>",
        "The trouble with “%s” is that it knows it's good.",
        "I'll speak ill of “%s” only when I'm finished. Fairness.",
        "“%s” reminds me of another book. A better one. But it reminds me.",
    },
}
E.SPEECHES_CHARACTER = {
    young = {
        "Does %s know I'm reading?",
        "I drew %s in the margin. It came out ugly.",
        "Is %s brave or just thoughtless? I can never tell.",
        "I'd like to be friends with %s. <fearful:Or run away. Run away, I think.|Or run away. Either way.>",
        "%s reminds me of someone I haven't met yet.",
    },
    old = {
        "%s is the kind of person who leaves mugs on books.",
        "I've seen %s in a thousand books, under other names.",
        "%s has the depth of <romantic:a well. I dived in, heart first|a footnote>.",
        "I don't trust %s. <romantic:Lie: I do. There, I confessed.|Or anyone who does.>",
        "%s will regret it. It's only a matter of chapters.",
        "If %s were a book, I'd abandon it halfway.",
    },
}
E.SPEECHES_NEXT_FORM_NEAR = {
    young = {
    },
    old = {
    },
}
E.SPEECHES_NEXT_FORM_IMMINENT = {
    egg = { "(something in there is impatient)" },
    young = { "I'm almost coming out of myself!", "One more page and I'll be someone else!" },
    old = { "A little more and I change. On the outside." },
}

X.context.small_hours = {
    young = { "{hour}. If we're quiet, the book's ghosts won't wake up.", "Reading at {hour}? I'll stay up with you.<fearful: Holding hands, if I may.|>",
              "{hour}. The letters are sleepy, <diurnal:and so am I. Yawn…|but I'm not>." },
    old = { "{hour}. Official hour of incorrigible readers.", "It's {hour}. <nocturnal:The best hour in the world.|Insomnia and this book deserve each other.>",
              "{hour}. Even the villains are asleep. <fearful:I hope.|You're not.>" },
}
X.context.record = {
    young = { "{n} pages! Nobody ever fed me so much in one day!", "Record: {n} pages. I'm telling every comma.",
              "{n} pages today. My belly wants to give a speech." },
    old = { "{n} pages. A new record. I'll log it with suspicion.", "A record of {n} pages. Are you all right?",
              "{n} pages in a day. That's not reading, that's a lifestyle change." },
}
X.context.marathon = {
    young = { "{n} pages! <brave:Fifty more?|Can I nap inside the book?>", "That's {n} pages already. I'm rolling across the shelf.",
              "{n} pages… my belly is the size of a dictionary." },
    old = { "{n} pages today. Even I'm tired, and I only eat.",
              "{n} pages. Remember there's life outside the book. So I'm told." },
}
X.context.vanished = {
    young = { "{n} days! <fearful:I thought something had happened.|I thought you'd forgotten me for good.>", "You're back after {n} days. <romantic:I missed you so much. And food.|cynical:I'll pretend I didn't notice.|I missed you. And food.>",
              "{n} days without paper. I was <erudite:reciting quotations from memory|counting the fibres in the cover>." },
    old = { "{n} days. <romantic:I counted every one.|I'll pretend I didn't count.>", "<domain:After {n} days, the bookshelf smells of {smell}.|After {n} days, the bookshelf looks like a museum.>",
              "{n} days without reading. I hope it was worth it. <hopeful:I bet it was.|I doubt it.>" },
}
X.context.afternoon = {
    young = { "{hour}. There's still time for one more chapter. And another.", "It's {hour}. I yawn, you turn the page.",
              "{hour} and the book is still open. I like that." },
    old = { "{hour}. The day is over, the reading isn't.", "It's {hour}. A fine hour for books and bad decisions.",
              "{hour}. Nobody reads at this hour out of obligation." },
}
X.context.early = {
    young = { "{hour}! The sun's barely up and you're already reading. <diurnal:My hour!|>", "Good morning! At {hour} the pages smell of dew.",
              "{hour}. Coffee for you, paper for me." },
    old = { "{hour}. Reading before the world starts talking nonsense.", "It's {hour}. <nocturnal:An odd hour to be awake.|The best hour: nobody interrupts.>",
              "{hour}. Reading early is a luxury few allow themselves." },
}
X.context.session = {
    young = { "{n} pages without getting up! Are your feet okay?", "{n} pages in a row. I'm dizzy from eating.",
              "{n} pages in one go. This book is stuck to you." },
    old = { "{n} pages without a break. Either the book is good or you're hiding.", "{n} pages in a row. Respect. But blink.",
              "A {n}-page sitting. The old copyists would approve." },
}
X.context.sequence = {
    young = { "{n} days in a row! <romantic:I think we're a couple now.|I think we have a routine.>", "Day {n} in a row. My belly knows when dinner is now.",
              "{n} days without skipping one! <fearful:Can I throw a party? A small one?|Can I throw a party?>" },
    old = { "{n} days in a row. Discipline is the most elegant vice.", "Day {n}. Consistency. Rare and dull. I like it.",
              "{n} days without fail. <hopeful:This will go far.|Don't ruin it now.>" },
}
X.context.good_morning = {
    young = { "{n} pages today. I'm really growing!", "I've eaten {n} pages today and I still want more.",
              "{n} pages today. A good day to be a Yomimon.<domain: A whiff of {smell} in the air.|>" },
    old = { "{n} pages today. Decent. Noted.", "{n} pages. The day wasn't wasted.", "{n} pages today. Enough to form an opinion." },
}
X.context.nothing_today = {
    young = { "Nothing yet today. Not even a paragraph.", "No pages today. I'm staring at the closed book.",
              "The day went by and I'm hungry for a story." },
    old = { "No pages today. The bookshelf noticed.", "Today: zero. The book is offended.", "A whole day without reading. What a waste of daylight." },
}
X.context.final_stretch = {
    young = { "{pct} of “{book}”! Almost there. I'm nervous.", "Not much of “{book}” left. I'll eat slowly.",
              "The home stretch of “{book}”. I promise not to cry. Maybe." },
    old = { "{pct} of “{book}”. The author can't escape now.", "Home stretch of “{book}”. Ready your heart. And your cigarette.",
              "Nearly the end of “{book}”. Endings reveal who the author really is." },
}
X.context.half = {
    young = { "Halfway through “{book}”! Downhill from here, right?", "We're in the middle of “{book}”. What happens now?",
              "Halfway through “{book}” and I already have theories." },
    old = { "Halfway through “{book}”. The moment a book decides whether it's any good.",
              "The middle of “{book}”. The plot is ready to collapse.", "Halfway through “{book}”. This is where authors get tired." },
}
X.context.start = {
    young = { "Starting “{book}”! I don't know who to like yet.", "First pages of “{book}”. I'm watching everyone.",
              "“{book}” has begun. I already like the smell." },
    old = { "The start of “{book}”. Every book swears it'll be different.", "First pages of “{book}”. I'm still being polite.",
              "“{book}” has begun. Let's see how long my patience lasts." },
}
X.context.weekend = {
    young = { "A weekend with a book is the best weekend.", "No rush, no school, just paper.", "We can read till late today, right?" },
    old = { "The weekend. The world rests, the bookshelf works.", "A day off from the world, a shift at the shelf.",
              "Weekend reading. Civilisation preserved." },
}

M.SPEECHES_EVENT = {
    morte = { "Another one gone. The page got heavier.", "A death. I mourned for three paragraphs." },
    casamento = { "They married. I'm marking on the calendar how many chapters it lasts.", "Bells, veil, vows. I've seen this film." },
    viagem = { "Someone left. The book got bigger." },
    carta = { "A letter. Someone will cry or lie.", "Letters in books never arrive at the right time." },
    tempestade = { "It rained the whole chapter. I'm damp with suspense.", "Lightning, wind, drama. The author's sky was nervous." },
    doenca = { "Illness this chapter. Books love a fever.", "Someone bedridden. I'll read more slowly, out of respect." },
    festa = { "A party this chapter. Someone will leave it with regrets.", "Music and glasses. I distrust so much joy." },
    briga = { "They fought badly. At least now we know what they think.", "An argument this chapter. I'd take a side. Mine." },
    fuga = { "Someone slipped away in the dead of the page.", "An escape this chapter. Sometimes it's the only dignified way out." },
    crime = { "A crime this chapter. I was eating the index, I swear.", "Blood. The book woke up and so did I." },
}
M.SPEECHES_NEW = { "Someone called %s arrived. I'll watch from a distance.", "%s entered the story without asking.",
                 "%s appeared. Books always bring new people at the worst time." }
M.SPEECHES_VANISHED = { "No sign of %s. Someone should go and look.", "%s disappeared from the chapter. Coincidence? I doubt it.",
                  "I missed %s. Don't tell anyone.", "A chapter without %s. The book breathed differently." }
M.SPEECHES_SOURED = { "The chapter suddenly went dark.", 
                   "This chapter tastes of bad news.", "Everything turned grey. It matches the paper." }
M.SPEECHES_SWEETENED = { "A gentle chapter. Suspicious, but I'll enjoy it.", "The book smiled this chapter.",
                   "Some lightness. I saved a bit for bad days.", "A sweet chapter. Something bad is coming, I bet." }
M.SPEECHES_TURNED = { "This chapter got tired of %s and wandered off to %s.", "The author grew bored of %s and moved on to %s." }

M.SPEECHES_THEME = {
    morte = { "After so many funerals, I've learned to read in black.", "Death is the one spoiler every book gives away." },
    amor = { "Love in books beats the real thing: it's been edited.", "I've read so much love I've started to distrust hugs." },
    guerra = { "Wars in books end on the last page. The others don't.", "So much gunpowder. Even my paper got nervous." },
    mar = { "I keep dreaming of paper waves.", "I feel the ship rocking even when the page stops." },
    fe = { "I prayed for a happy ending. Nobody answered.", "If there's a heaven, I hope it has a library." },
    dinheiro = { "In books, people with money just have better problems.", "I counted coins the whole chapter. None were mine." },
    loucura = { "Madness in books seems more and more sensible to me.", "Some days I talk to the commas." },
    tempo = { "Time in books passes quickly. Out here too, but without an index.", "I aged a chapter today." },
    cidade = { "Smell of wet streets on the paper.", "So many people in the cities of books, and nobody reads." },
    natureza = { "A leaf in the book. A leaf of paper in my mouth.", "Books taught me the names of plants I'll never see." },
    comida = { "A book with food makes me twice as hungry." },
    familia = { "Every family in books has a secret in the pantry.", "Family: the plot nobody chooses and everyone reads." },
    infancia = { "Children in books know things adults forget." },
    politica = { "Crowns, laws and speeches. All paper.", "The powerful in books always fall. Good thing they're books." },
    ciencia = { "Science in books explodes a lot." },
    solidao = { "The characters' loneliness keeps me company.", "They're so alone in books. I feel so accompanied." },
    arte = { "A painting described in words paints my mind.", "Artists in books suffer beautifully." },
    animais = { "The animals in books are wiser than their owners." },
    noite = { "Night in books is darker than the real one.", "I like chapters set at night. Like us." },
    viagem = { "Suitcases, trains, ships. Me, just pages." },
    vinganca = { "Revenge in books always costs more than the insult.", "A well-written grudge is a dangerous art." },
    liberdade = { "Paper chains. Still chains.", "Freedom in books fits on one page. Ours doesn't." },
    saber = { "The more books about books, the more I want to eat libraries.", "Knowing too much is fattening. I know." },
    medo = { "This book makes me look under the page.", "Monsters on paper. I prefer real ones: they're slower." },
}

C.theme = {
    morte = { "You highlighted death again. Everything okay?", "A line of mourning. I kept it carefully." },
    amor = { "You highlighted love. I pretended not to see.", "That's something you underline when you love. Or remember." },
    guerra = { "You highlighted war. May it stay on paper.", "A battle passage. Kept without gunpowder." },
    mar = { "You highlighted the sea. I tasted salt.", "A wave, highlighted. The page got wet." },
    fe = { "You highlighted a prayer. I'd like one too.", "Faith, highlighted. Noted respectfully." },
    dinheiro = { "You highlighted money. Practical.", "Coins in the passage. None for me." },
    loucura = { "You highlighted madness. That makes two of us.", "This passage is a little mad. I like it." },
    tempo = { "You highlighted time. It'll pass anyway.", "Nostalgia in the passage. Saved for later." },
    cidade = { "You highlighted the city. Noisy, but lovely.", "A street, highlighted. Smell of rain on asphalt." },
    natureza = { "You highlighted a tree. It thanks you.", "Nature in the passage. I breathed better." },
    comida = { "You highlighted food. Now I want some." },
    familia = { "You highlighted family. There's something there.", "A family passage. Kept without questions." },
    infancia = { "You highlighted childhood. Such a small, enormous line.", "A child in the passage. Careful rereading it." },
    politica = { "You highlighted power. Be careful with it.", "A passage about a king. A paper crown." },
    ciencia = { "You highlighted an experiment. Let's see how it ends.", "Science in the passage. Smells like a laboratory." },
    solidao = { "You highlighted loneliness. I moved closer.", "A lonely passage. Now it has company: me." },
    arte = { "You highlighted a verse. It's prettier underlined.", "Art in the passage. Kept it framed." },
    animais = { "You highlighted an animal. I like you.", "An animal in the passage. Animals always understand." },
    noite = { "You highlighted the night. It suits us.", "A night passage. I lit an imaginary candle." },
    viagem = { "You highlighted a journey. Take me.", "A road passage. I kept the map." },
    vinganca = { "You highlighted revenge. I'll sleep with one eye open.", "A grudge in the passage. Noted, as a precaution." },
    liberdade = { "You highlighted freedom. Such a light line.", "A passage without chains. Lovely." },
    saber = { "You highlighted knowledge. Going to quote it at dinner?", "A wise passage. I got cleverer just eating it." },
    medo = { "You highlighted fear. Brave of you.", "A shiver of a passage. I left the light on." },
}
C.short_one = { "Few words, lots of damage.", "It would fit on a tattoo. Don't.", "A small line, a big echo." }
C.long = { "You highlighted a whole paragraph. Agreed with all of it?", "Is this a highlight or a chapter?",
            "You highlighted so much the page turned yellow." }
C.grade = { "You noted “%s”. I'd have noted it with more drama.", "“%s” — your note. I half agree.",
           "You wrote “%s”. I kept it with the sentence." }
C.small_hours = { "Highlighted in the small hours. Night sentences weigh more.", "Highlighted at %s in the morning. Kept with care.",
                "Small hours and a highlighter. A dangerous combination." }
C.first_one = { "The first highlight in “%s”. Let the collection begin.", "First mark in “%s”. Good choice.",
               "“%s” got its first highlight. It'll be insufferable now." }
C.many = { "%s highlights in this book. It's yours now.", "That's %s highlights. This book got you.",
             "%s marks. Soon it'll be easier to highlight what you didn't like." }
C.chapter = { "“%s” again. That chapter is a magnet.", "Another highlight in “%s”. That chapter has something with you.",
               "“%s” is full of your marks." }
C.character = { "%s again. That character lives in your head.", "You highlighted %s. They don't deserve that much.",
                 "%s in the sentence. Noted for gossip later.", "Do you like %s or just pity them?", "%s. Always. What an obsession." }
C.two = { "%s and %s in the same passage. This will cause talk.", "%s and %s together. I've seen how this ends.",
           "Between %s and %s, I'd take the bookmark.", "%s and %s. A dangerous pair." }
C.general = {
    young = { "I kept this passage in my belly pocket.", "Is this beautiful or sad? Both?", "I'll repeat this quietly before bed.",
              "I keep thinking about this line. A lot.", "This passage tastes like a secret." },
    old = { "Highlighted. Another one for the collection nobody rereads.", "This has ambitions. I like well-made ambitions.",
              "Saved. In ten years it'll seem obvious.", "A sentence with an epigraph's calling.",
              "I agree, with reservations. Always with reservations.", "Beautiful. And I hate admitting it's beautiful." },
}
M.SPEECHES_QUOTATION = {
    young = { "I saved what {nameText} said: “{speech}”.",
              "“{speech}”. That was {nameText}. I was impressed." },
    old = { "“{speech}”, said {nameText}. I'd have edited it.", "{nameText} let slip a “{speech}”. Noted, with suspicion.",
              "I'm still digesting “{speech}”, from {nameText}." },
}
M.SPEECHES_REFERENCE = {
    young = { "{nameText} again! I'll look up who that is. I won't.", "The book has mentioned {nameText} {n} times. Should I worry?" },
    old = { "{n} mentions of {nameText}. The author wanted to look clever.", "{nameText}, once more. We get it, author, you've read things." },
}

return X
