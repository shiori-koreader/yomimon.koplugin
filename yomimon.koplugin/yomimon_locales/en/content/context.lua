-- Phrases with reading data (same keys as the Portuguese bank).
return {
    madrugada = {
        jovem = {
            "It's {hora}. Shouldn't we be asleep? <noturna:I love this hour.|I'm scared of the dark and you're reading.>",
            "{hora} and you're here. Is everything okay? I'm okay. I think. I'm sleepy.",
            "Reading at {hora} feels forbidden. <medrosa:It scares me.|noturna:Our favourite hour.|I like it.>",
            "At {hora} the letters get bigger. Or my eyes get smaller.",
            "{hora}! If anyone asks, we were asleep.<dominio: Dreaming {lugar}.|>",
        },
        velha = {
            "{hora}. Nothing good was ever read after midnight. Except everything worth reading.",
            "Reading at {hora}. <noturna:The best hour, I always said so.|diurna:This is no hour for decent creatures.|Tomorrow you'll blame the book. I blame you.>",
            "{hora}. Me with my imaginary cigarette, you with your screen light. Two vices.",
            "{hora}. The hour when every sentence sounds true. Careful what you highlight.",
        },
    },
    recorde = {
        jovem = {
            "I've never eaten so much in one day: {n} pages. My belly is proud and scared.",
            "A record of {n} pages. I think I grew a millimetre.",
        },
        velha = {
            "New record: {n} pages in a day. Are you running away from something?",
            "{n} pages. I've never eaten so much. Note the date, so I can complain about it later.",
        },
    },
    maratona = {
        jovem = {
            "{n} pages today. <corajosa:I could take a hundred more.|My belly is all round.>",
            "That's {n} pages already! I can't walk anymore, I just roll.",
        },
        velha = {
            "{n} pages today. My belly thanks you; my dignity, less so.",
            "{n} pages. <erudita:Proust would approve. Perhaps.|That's not reading, that's moving house.>",
            "{n} pages already. Blink. Drink some water. Then come back, of course.",
        },
    },
    sumiu = {
        jovem = {
            "{n} days without paper. I counted every hour. <medrosa:Afraid you wouldn't come back.|There were a lot.>",
            "{n} days! I nearly ate my own shadow. <medrosa:It scared me.|corajosa:I wrestled it.|dominio:It tasted like {gosto}.|>",
        },
        velha = {
            "{n} days without reading. <otimista:It's fine, we start again.|Did civilisation fall and nobody told me?>",
            "{n} days without you. <romantica:I missed you. There, I said it.|I won't ask where you were. You weren't reading, that's what matters.>",
        },
    },
    tarde = {
        jovem = {
            "It's {hora} already. Just one more chapter, right? I know how this ends.",
            "<noturna:{hora}… I'm wide awake. Keep going.|{hora}… my little eyes are getting heavy, but keep going.>",
            "Reading at {hora} is like telling a secret. Quietly.",
        },
        velha = {
            "{hora}. The hour when every reader swears they'll sleep after this chapter.",
            "It's {hora}. The book won't run away. You will, from exhaustion.",
            "{hora}. Still awake <noturna:by choice. The night is mine|because of you. Not that I care>.",
        },
    },
    cedo = {
        jovem = {
            "Reading at {hora}? Before breakfast? <diurna:I love mornings!|noturna:I haven't even slept yet.|So brave.>",
            "{hora} and you're already feeding me. Good morning!",
            "You woke up early to read? I woke up early to eat. We're a team.",
        },
        velha = {
            "{hora}. Reading before coffee. <diurna:The only natural order of things.|I don't understand it, but I respect it.>",
            "It's {hora}. Birds sing, you read, I eat. The only natural order I approve of.",
            "Reading at {hora}. The day hasn't started and it's already better than yesterday.",
        },
    },
    sessao = {
        jovem = {
            "{n} pages without stopping! Can I breathe?",
            "You read {n} pages in one go. Is everything okay out there?",
            "{n} pages in a row. This book got you. It got me too.",
        },
        velha = {
            "{n} pages in a row. Either the book is good or your life got worse.",
            "A {n}-page session. The monks in the scriptorium would approve.",
        },
    },
    sequencia = {
        jovem = {
            "{n} days in a row reading! I'm getting spoiled.",
            "Day {n} in a row of food. I think you like me.<dominio: Today it was {gosto}.|>",
            "{n} days without missing one. <romantica:This is basically dating.|otimista:It'll be a hundred.|Don't stop now, okay?>",
        },
        velha = {
            "{n} days in a row. Consistency: the most boring and rarest virtue.",
            "{n} days reading without fail. <otimista:I believe in you.|cinica:Let's see how long it lasts.|I almost believe in you.>",
            "Day {n} in a row. I won't praise you. There, I praised you.",
        },
    },
    bom_dia = {
        jovem = {
            "{n} pages today. I'm getting chubby.",
            "{n} pages today. <amarga:At least there's that.|It's a good day, isn't it?>",
        },
        velha = {
            "{n} pages today. Respectable. Not spectacular, but respectable.<dominio: With a taste of {gosto}.|>",
            "{n} pages today. That almost counts as reading.",
            "{n} pages. A decent day. <otimista:They've been turning up more.|Rare things, decent days.>",
        },
    },
    nada_hoje = {
        jovem = {
            "No pages today… it's fine, I'll wait. I'm very good at waiting.",
            "I haven't eaten anything today. Not even a comma.",
            "The day is ending and the book is still closed. I sat staring at the cover.",
        },
        velha = {
            "No pages today. The day isn't over yet. But it's trying.",
            "Today: zero pages. Noted in my diary of disappointments.",
            "The book stayed closed all day. So did I, on the inside.",
        },
    },
    reta_final = {
        jovem = {
            "{pct} of “{livro}”. It's ending! I don't want it to end!",
            "The home stretch of “{livro}”. <corajosa:I'll go to the end without blinking.|medrosa:I'll eat with my eyes shut.|I'll eat slowly so it lasts.>",
            "Almost done with “{livro}”. And then what will I eat?",
        },
        velha = {
            "{pct} of “{livro}”. The home stretch. <otimista:This is where good authors shine.|This is where authors ruin everything.>",
            "Nearly the end of “{livro}”. Don't tell me. I'll eat the ending either way.",
            "Last pages of “{livro}”. Brace for the post-book void. I already live there.",
        },
    },
    metade = {
        jovem = {
            "Halfway through “{livro}”! It's getting good. Or bad. I can't tell yet.",
            "I've eaten half of “{livro}”. The other half is staring at me.",
        },
        velha = {
            "Halfway through “{livro}”. Downhill from here.",
            "The middle of “{livro}”. Where authors usually get lost.",
        },
    },
    comeco = {
        jovem = {
            "Starting “{livro}”… it smells like {cheiro|new paper}. Or trouble.",
            "The first pages of “{livro}”. <corajosa:I'm already excited.|I'm already nervous.>",
        },
        velha = {
            "The start of “{livro}”. Every cover promises. Let's see what it delivers.",
            "First bites of “{livro}”. <otimista:Promising.|I don't hate it yet. Yet.>",
        },
    },
    fim_de_semana = {
        jovem = {
            "Weekend reading! The best kind of weekend.",
            "Weekends are paper days. Yay.",
        },
        velha = {
            "The weekend and you're reading. No parties? Good. Parties are overrated.",
            "The weekend. The world goes out, you read. The right choice.",
        },
    },
}
