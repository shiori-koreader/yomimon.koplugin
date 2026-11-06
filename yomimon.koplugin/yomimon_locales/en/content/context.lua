-- Phrases with reading data (same keys as the Portuguese bank).
return {
    small_hours = {
        young = {
            "It's {hour}. Shouldn't we be asleep? <nocturnal:I love this hour.|I'm scared of the dark and you're reading.>",
            "{hour} and you're here. Is everything okay? I'm okay. I think. I'm sleepy.",
            "Reading at {hour} feels forbidden. <fearful:It scares me.|nocturnal:Our favourite hour.|I like it.>",
            "At {hour} the letters get bigger. Or my eyes get smaller.",
            "{hour}! If anyone asks, we were asleep.<domain: Dreaming {place}.|>",
        },
        old = {
            "{hour}. Nothing good was ever read after midnight. Except everything worth reading.",
            "Reading at {hour}. <nocturnal:The best hour, I always said so.|diurnal:This is no hour for decent creatures.|Tomorrow you'll blame the book. I blame you.>",
            "{hour}. Me with my imaginary cigarette, you with your screen light. Two vices.",
            "{hour}. The hour when every sentence sounds true. Careful what you highlight.",
        },
    },
    record = {
        young = {
            "I've never eaten so much in one day: {n} pages. My belly is proud and scared.",
            "A record of {n} pages. I think I grew a millimetre.",
        },
        old = {
            "New record: {n} pages in a day. Are you running away from something?",
            "{n} pages. I've never eaten so much. Note the date, so I can complain about it later.",
        },
    },
    marathon = {
        young = {
            "{n} pages today. <brave:I could take a hundred more.|My belly is all round.>",
            "That's {n} pages already! I can't walk anymore, I just roll.",
        },
        old = {
            "{n} pages today. My belly thanks you; my dignity, less so.",
            "{n} pages. <erudite:Proust would approve. Perhaps.|That's not reading, that's moving house.>",
            "{n} pages already. Blink. Drink some water. Then come back, of course.",
        },
    },
    vanished = {
        young = {
            "{n} days without paper. I counted every hour. <fearful:Afraid you wouldn't come back.|There were a lot.>",
            "{n} days! I nearly ate my own shadow. <fearful:It scared me.|brave:I wrestled it.|domain:It tasted like {taste}.|>",
        },
        old = {
            "{n} days without reading. <hopeful:It's fine, we start again.|Did civilisation fall and nobody told me?>",
            "{n} days without you. <romantic:I missed you. There, I said it.|I won't ask where you were. You weren't reading, that's what matters.>",
        },
    },
    afternoon = {
        young = {
            "It's {hour} already. Just one more chapter, right? I know how this ends.",
            "<nocturnal:{hour}… I'm wide awake. Keep going.|{hour}… my little eyes are getting heavy, but keep going.>",
            "Reading at {hour} is like telling a secret. Quietly.",
        },
        old = {
            "{hour}. The hour when every reader swears they'll sleep after this chapter.",
            "It's {hour}. The book won't run away. You will, from exhaustion.",
            "{hour}. Still awake <nocturnal:by choice. The night is mine|because of you. Not that I care>.",
        },
    },
    early = {
        young = {
            "Reading at {hour}? Before breakfast? <diurnal:I love mornings!|nocturnal:I haven't even slept yet.|So brave.>",
            "{hour} and you're already feeding me. Good morning!",
            "You woke up early to read? I woke up early to eat. We're a team.",
        },
        old = {
            "{hour}. Reading before coffee. <diurnal:The only natural order of things.|I don't understand it, but I respect it.>",
            "It's {hour}. Birds sing, you read, I eat. The only natural order I approve of.",
            "Reading at {hour}. The day hasn't started and it's already better than yesterday.",
        },
    },
    session = {
        young = {
            "{n} pages without stopping! Can I breathe?",
            "You read {n} pages in one go. Is everything okay out there?",
            "{n} pages in a row. This book got you. It got me too.",
        },
        old = {
            "{n} pages in a row. Either the book is good or your life got worse.",
            "A {n}-page session. The monks in the scriptorium would approve.",
        },
    },
    sequence = {
        young = {
            "{n} days in a row reading! I'm getting spoiled.",
            "Day {n} in a row of food. I think you like me.<domain: Today it was {taste}.|>",
            "{n} days without missing one. <romantic:This is basically dating.|hopeful:It'll be a hundred.|Don't stop now, okay?>",
        },
        old = {
            "{n} days in a row. Consistency: the most boring and rarest virtue.",
            "{n} days reading without fail. <hopeful:I believe in you.|cynical:Let's see how long it lasts.|I almost believe in you.>",
            "Day {n} in a row. I won't praise you. There, I praised you.",
        },
    },
    good_morning = {
        young = {
            "{n} pages today. I'm getting chubby.",
            "{n} pages today. <bitter:At least there's that.|It's a good day, isn't it?>",
        },
        old = {
            "{n} pages today. Respectable. Not spectacular, but respectable.<domain: With a taste of {taste}.|>",
            "{n} pages today. That almost counts as reading.",
            "{n} pages. A decent day. <hopeful:They've been turning up more.|Rare things, decent days.>",
        },
    },
    nothing_today = {
        young = {
            "No pages today… it's fine, I'll wait. I'm very good at waiting.",
            "I haven't eaten anything today. Not even a comma.",
            "The day is ending and the book is still closed. I sat staring at the cover.",
        },
        old = {
            "No pages today. The day isn't over yet. But it's trying.",
            "Today: zero pages. Noted in my diary of disappointments.",
            "The book stayed closed all day. So did I, on the inside.",
        },
    },
    final_stretch = {
        young = {
            "{pct} of “{book}”. It's ending! I don't want it to end!",
            "The home stretch of “{book}”. <brave:I'll go to the end without blinking.|fearful:I'll eat with my eyes shut.|I'll eat slowly so it lasts.>",
            "Almost done with “{book}”. And then what will I eat?",
        },
        old = {
            "{pct} of “{book}”. The home stretch. <hopeful:This is where good authors shine.|This is where authors ruin everything.>",
            "Nearly the end of “{book}”. Don't tell me. I'll eat the ending either way.",
            "Last pages of “{book}”. Brace for the post-book void. I already live there.",
        },
    },
    half = {
        young = {
            "Halfway through “{book}”! It's getting good. Or bad. I can't tell yet.",
            "I've eaten half of “{book}”. The other half is staring at me.",
        },
        old = {
            "Halfway through “{book}”. Downhill from here.",
            "The middle of “{book}”. Where authors usually get lost.",
        },
    },
    start = {
        young = {
            "Starting “{book}”… it smells like {smell|new paper}. Or trouble.",
            "The first pages of “{book}”. <brave:I'm already excited.|I'm already nervous.>",
        },
        old = {
            "The start of “{book}”. Every cover promises. Let's see what it delivers.",
            "First bites of “{book}”. <hopeful:Promising.|I don't hate it yet. Yet.>",
        },
    },
    weekend = {
        young = {
            "Weekend reading! The best kind of weekend.",
            "Weekends are paper days. Yay.",
        },
        old = {
            "The weekend and you're reading. No parties? Good. Parties are overrated.",
            "The weekend. The world goes out, you read. The right choice.",
        },
    },
}
