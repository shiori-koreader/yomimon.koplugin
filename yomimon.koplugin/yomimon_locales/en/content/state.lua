-- Day-to-day phrases (same structure as the Portuguese bank).
local S = {}


S.SPEECHES = {
    egg = {
        _all = {
            "…",
            "Knock, knock. Read a bit more and I'll come out.",
            "(something inside grumbled)",
        },
    },
    young = {
        happy = {
            "Ate a whole page and nothing bad happened. <fearful:Yet. I'm watching.|hopeful:And nothing will.|Yet.>",
            "Okay… that was tasty. Will it go wrong later?",
            "Today I understood a metaphor. By myself. I think.",
            "{exclamation|} Ate a whole paragraph without choking. I'm growing.",
            "Is this book good, or am I just hungry?",
            "If only I could read as fast as I eat…",
            "Happy. Don't tell anyone. I have a reputation.",
            "Today I read a five-syllable word. It read me back.",
            "This book hugged me. <romantic:I let it.|fearful:Or squashed me. Not sure.|Or squashed me. It was nice.>",
            "Swallowed a comma by accident. Now everything has a pause.",
        },
        normal = {
            "Will this book end well? Books never end well.",
            "I'm here. <brave:Steady and ready.|fearful:Trembling, but here.|A bit nervous, but here.>",
            "If you stop reading, I'll… be fine. I think.",
            "I heard thick books have more filling.<domain: This one's filling is {taste}.|>",
            "When I grow up, I want to read the dictionary. All of it.",
            "You read in such a hurry. Is someone waiting for you?",
            "Sometimes I think the characters can see me. <fearful:That's why I hide.|romantic:And they smile.|>",
            "Why do books smell like {smell|old rain}?",
            "<brave:I used to fear the end of books. Now I run towards it.|bitter:I'm afraid of the end of books. With good reason.|I'm afraid of the end of books. And the beginning. And the middle.>",
            "<brave:Today I'm brave. Tomorrow too.|Today I decided to be brave. We'll see about tomorrow.>",
            "Sometimes I read the same line three times. To make sure it exists.",
        },
        sad = {
            "I'm hungry. And <romantic:lovesick|scared>. Mostly hungry.",
            "Did you forget me? It's fine, everyone forgets.",
            "Just one tiny page… please?",
            "My belly is rumbling. Sounds like {comparison|a suspense chapter}.",
            "If I disappear, look {place|between pages 40 and 41}.",
            "I counted the letters on the cover. All of them. Twice. It's all there was.",
            "Hungry for a story. Any story.",
            "Even the index looks like a feast right now.",
        },
        sleeping = {
            "Zzz… dreaming the bookcase collapsed… <brave:and I held it up alone…|>",
            "Zzz… don't turn off the light… <fearful:leave it on…|I mean, do…>",
            "Zzz… one more page… just one more… <nocturnal:the night is ours…|>",
        },
        cocoon = {
            "I'm in here. Dark, cozy and no letters. Awful.",
        },
        sleepRest = {
            "Zzz… dreaming of <romantic:letter paper|erudite:parchment|{thing|rice paper}>…",
            "Zzz… who turned off the world's light? <fearful:Turn it on…|>",
            "Zzz… dreaming of an endless library… <fearful:with no way out…|brave:and me exploring it all…|>",
            "Zzz… the cover is so warm… <romantic:like a hug…|>",
        },
        word = "I ate the word “%s”. <hopeful:It tasted like Sunday.|fearful:I think it was haunted.|erudite:I'm saving it for a sonnet.|I think it disagreed with me.>",
    },
    old = {
        happy = {
            "Hm. Not a bad book, actually.",
            "Ate. Satisfied. Don't get used to it.",
            "{exclamation|} A decent page. Rare, these days.",
            "That paragraph deserved a cigarette afterwards.",
            "Good book. I'll miss hating it.",
            "Literature spared me today. We'll see tomorrow.",
            "Satisfied. <hopeful:That's how comedies begin.|That's how tragedies begin.>",
            "What prose. <hopeful:It makes me believe in humanity. No almost.|It almost makes me believe in humanity. Almost.>",
            "A decent book. I'll note the date, to remember when the world was worth it.",
            "This author knew what they were doing. I hate when that happens.",
            "Good chapter. <romantic:I was moved and I won't pretend otherwise.|Excuse me while I pretend I wasn't moved.>",
        },
        normal = {
            "I've read too much to <hopeful:lose hope|have hope>.",
            "Every book ends. Like everything.",
            "The more I read, the less I understand the world.",
            "Read. Or don't. The ending is the same.",
            "I lit a cigarette. A metaphorical one. Paper and fire don't mix.",
            "Every library is a cemetery with good lighting.",
            "The classics are books everyone quotes and nobody eats.",
            "A preface is where the author apologises in advance.",
            "I was young and optimistic once. <hopeful:I still am.|It lasted a chapter.>",
            "Footnotes: where the truth goes to hide.",
            "Nobody reads anymore. That's why I eat.<domain: Today's menu: {taste}.|>",
            "Life is a badly edited novel.",
            "Today's bestseller is tomorrow's wrapping paper.",
            "I've read so many happy endings <romantic:and I still cry at every one|I lost faith in endings>.",
            "Every narrator lies. The honest ones lie better.",
            "Culture is what's left when you forget what you read. I remember everything. Bad luck.",
            "The young read to find themselves. The old read to hide.",
            "I don't hate people. Only the ones who dog-ear pages.",
            "My opinion of the world fits in a footnote. Small and ignored.",
        },
        sad = {
            "Hungry. As always. Like everyone.<domain: I miss {taste}.|>",
            "You know what's worse than a bad book? No book at all.",
            "I'm wasting away between two covers. How poetic. How useless.",
            "Leave me here with my imaginary cigarette and my very real hunger.",
            "Empty shelf, empty soul. Empty belly too.",
            "Hunger and lucidity. <hopeful:At least the lucidity.|The worst combination.>",
            "Nobody reads. Nobody feeds me. Civilisation is over.",
            "I'm so starved I'd consider <erudite:an instruction manual. In German|popular:a gossip magazine. Gladly|an instruction manual>.",
        },
        sleeping = {
            "Zzz… grumbling about <domain:{thing}|the state of literature>…",
            "Zzz… no bestsellers… please…",
            "Zzz… dreaming of a used bookshop closed just for me…",
        },
        cocoon = {
            "I'm not here. I'm between the pages, where it's more honest.",
        },
        sleepRest = {
            "Zzz… smoking a cigarette in a dream… <erudite:and quoting Baudelaire…|>",
            "Zzz… the last page <hopeful:sometimes surprises|always disappoints>…",
            "Zzz… grumbling in <popular:plain English|Latin>…",
            "Zzz… proofreading the world… <hopeful:fewer errors than I expected…|so many errors…>",
        },
        word = "“%s”. Ate it. <erudite:A noble word; this century doesn't deserve it.|popular:Dictionary word. No flavour.|Nobody uses that word anymore.>",
    },
}

S.SPEECHES_BOOK = {
    young = {
        "“%s” tastes like <fearful:a snuffed candle|brave:adventure|{taste|mystery}>. Or mould.",
        "Does “%s” end well? Tell me without telling me.",
        "I dreamt about “%s” last night. <brave:I was the heroine.|romantic:It was a lovely dream.|I got scared.>",
    },
    old = {
        "“%s”? I've eaten worse. I've eaten better. Still hungry.<domain: This one smelled of {smell}.|>",
        "After “%s”, I need <romantic:a handkerchief|fearful:a light on|a cigarette> and a long silence.",
        "“%s” won't change the world. But it changed me a little. For the worse.",
    },
}
S.SPEECHES_CHARACTER = {
    young = { "I like %s. <romantic:I like them a lot.|cynical:For now.|Is that dangerous?>", "%s showed up again. I got nervous." },
    old = { "%s again. Is there nobody else in this book?", "I know %s's type. <hopeful:It ends well, believe it or not.|It ends badly.>",
              "%s talks like someone who never read a book." },
}

S.SPEECHES_NEXT_FORM_NEAR = {
    young = {
        "%d more pages and I grow. What if I turn out ugly?",
        "In %d pages I'll be someone else. Promise you'll recognise me?",
    },
    old = {
        "In %d pages I change. The world stays the same. As always.",
    },
}
S.SPEECHES_NEXT_FORM_IMMINENT = {
    egg = { "Knock. Knock. KNOCK. Read a tiny bit more!" },
    young = {
        "My back is creaking. Is it now? It's now!",
    },
    old = {
        "I'm about to change. I doubt it'll improve anything.",
    },
}

return S
