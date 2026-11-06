--[[--
Banco de frases do diário (inglês). Mesma estrutura de diario_pt.lua; {tema} e {de_tema} já vêm
com artigo ("the sea"), e as preposições ficam nas frases.
]]

local B = { dia = {}, inicio = {}, fim = {}, obsessao = {}, lembranca = {} }

B.dia.magro = {
    "A thin day: {n} pages of “{livro}”.",
    "Only {n} pages today. I nibbled at “{livro}”.",
    "{n} pages of “{livro}”. An appetiser.",
    "Not much today: {n} pages of “{livro}”. I licked my fingers.",
    "A few crumbs of “{livro}”: {n} pages.",
    "{n} pages. “{livro}” barely touched my mouth.",
}
B.dia.normal = {
    "{n} pages of “{livro}”.",
    "Ate {n} pages of “{livro}”.",
    "Another {n} pages of “{livro}” in my belly.",
    "Today: “{livro}”, {n} pages.",
    "Moved {n} pages further into “{livro}”.",
    "“{livro}” gave me {n} pages today.",
    "{n} pages. “{livro}” is still on my plate.",
}
B.dia.banquete = {
    "{n} pages of “{livro}”. A banquet.",
    "A feast today: {n} pages of “{livro}”.",
    "{n} pages of “{livro}” in one go. I'm full.",
    "Ate {n} pages of “{livro}”. I forgot to breathe.",
    "A fat day: {n} pages of “{livro}”.",
    "{n} pages of “{livro}”. My belly begged for mercy.",
}
B.dia.enorme = {
    "{n} pages of “{livro}” in a single day. I'm round.",
    "{n} pages. You didn't read “{livro}”, you crossed it.",
    "Marathon: {n} pages of “{livro}”. I need to lie down.",
}
B.dia.dois_livros = {
    "{n} pages, split between “{livro}” and “{livro2}”.",
    "Two dishes today: “{livro}” and a little “{livro2}”. {n} pages.",
    "{n} pages. Torn between “{livro}” and “{livro2}”, like someone who can't pick dessert.",
    "Cheated on “{livro2}” with “{livro}”. {n} pages in total.",
}
B.dia.horario = {
    madrugada = { "Almost all of it in the small hours.", "Read after midnight, like secrets are.", "Another sleepless night.<noturna: I love it.|medrosa: With the light on.|>",
                  "We read while the house slept.<medrosa: I heard every creak.|>" },
    manha = { "All of it before lunch.", "Read in the morning, smelling of coffee.<diurna: My hour.|>", "We started early." },
    noite = { "Read late at night.", "Mostly after ten.", "Deep into the night.<noturna: Just how I like it.|>" },
}
B.dia.fala = {
    jovem = { "{nome} said “{fala}”. I repeated it quietly.", "{nome} said “{fala}”. I keep thinking about it.",
              "I saved a line from {nome}: “{fala}”.", "“{fala}”, said {nome}. I'd never be that brave." },
    velha = { "{nome} said “{fala}”. Noted, never to be forgiven.", "“{fala}”, said {nome}. I'd have said it better.",
              "Line of the day, by {nome}: “{fala}”. It deserved a cigarette.", "{nome}: “{fala}”. Saved. <romantica:I'll use it in a letter.|I'll use it against someone.>" },
}
B.dia.novo = {
    "I met {nome}.", "{nome} showed up. Not sure what I think yet.", "Enter {nome}.",
    "I was introduced to {nome}. Without much enthusiasm.", "Someone called {nome} arrived. <romantica:I liked them at once.|medrosa:I hid.|I'm keeping an eye on them.>",
    "{nome} appeared. Trouble.",
}
B.dia.novos2 = {
    "I met {nome} and {nome2}.", "{nome} and {nome2} showed up. Too many people.",
    "{nome} and {nome2} entered the scene. One of them will annoy me.", "Introduced to {nome} and {nome2}. Noted both.",
}
B.dia.evento = {
    morte = { "Someone died.", "A death. <romantica:I really cried.|medrosa:I slept with the light on.|I mourned out of politeness.>", "They buried someone. Smell of candles." },
    casamento = { "A wedding.", "Someone got married. <romantica:I cried at the altar.|otimista:This one will last.|I give it three chapters.>", "Bride, altar, vow. Noted, for later." },
    viagem = { "Someone hit the road.", "A journey. <corajosa:I went along, stowed in a suitcase.|I stayed home.>", "People leaving and arriving all day." },
    carta = { "A letter arrived.", "A letter. <romantica:I read it twice.|otimista:Good news, for a change.|Never good news.>", "Someone wrote what they shouldn't have." },
    tempestade = { "It rained in the book.", "A storm." },
    doenca = { "Someone fell ill.", "Fever and a doctor.", "Someone bedridden. Bad sign." },
    festa = { "A party.", "A ball. <romantica:I danced alone in the margin.|Nobody invited me.>", "Music and wine. For them." },
    briga = { "A fight.", "Someone finally said what they thought." },
    fuga = { "Someone ran away.", "An escape.", "People running from their own fate." },
    crime = { "A crime.", "Blood and police." },
}
B.dia.tema = {
    "It was all about {tema}.", "Nothing but {tema} today.", "Too much of {tema} today.",
    "The day tasted of {tema}.", "Everything revolved around {tema}.",
}
B.dia.pesado = { "Heavy pages.", "A dark day of paper.", "Lots of shadow, little light.", "Reading that leaves a mark." }
B.dia.leve = { "Light pages, for a change.", "A sweet day of paper.", "Reading that doesn't hurt. Rare." }
B.dia.fecho = {
    jovem = { "More tomorrow.", "I'm liking it.", "Fell asleep thinking about it.", "I want more.", "" },
    velha = { "Noted.", "How tiresome.", "Lit an imaginary cigarette.", "Onwards.", "Nothing new. Almost.", "" },
}
B.dia.fecho_escuro = {
    jovem = { "Slept badly.", "Got scared of the dark.", "Left the light on." },
    velha = { "Slept badly. As usual.", "One more weight on the shelf.", "Needed two imaginary cigarettes.", "Predictable. Hurt anyway." },
}
B.dia.fecho_leve = {
    jovem = { "Had a lovely dream.", "Happy for no reason.", "Fell asleep smiling." },
    velha = { "Almost smiled.", "I distrust so much lightness.", "Don't get used to it." },
}

B.inicio.generico = {
    "Started gnawing on “{livro}”. The cover promised a lot. Covers always do.",
    "New book: “{livro}”. Paper that doesn't know what's coming.",
    "“{livro}” has reached my plate. Let's see if it holds up.",
    "Opened “{livro}”. First pages always swear it'll be worth it.",
    "We've started “{livro}”. Me hungry, you hopeful.",
    "Another book: “{livro}”. My belly thanks you, my mood reserves judgement.",
    "“{livro}”. New address. Still unpacking.",
}
B.inicio.autor = {
    "“{livro}”, by {autor}. Let's see if {autor} deserves my appetite.",
    "Started “{livro}”. I've never eaten any {autor}. First times are always strange.",
    "{autor}, a pleasure. I've come to eat your “{livro}”.",
}
B.inicio.mesmo_autor = {
    "Another {autor}: “{livro}”. Loyalty or laziness?",
    "{autor} again. “{livro}” now. Are we dating?",
    "Back to {autor}. “{livro}” is the next course.",
    "Another {autor}. You really can't let go of this author.",
}
B.inicio.largou = {
    "Dropped “{anterior}” halfway. Now it's “{livro}”. No comment. Comment: cowardice.",
    "“{anterior}” was left behind, unfinished. Swapped for “{livro}”. I saw that.",
    "We abandoned “{anterior}”. May it rest in peace. Now: “{livro}”.",
    "We jumped to “{livro}”. “{anterior}” will be glaring at me from the shelf.",
}
B.inicio.relendo = {
    "Rereading “{livro}”. I know the ending. Eating slowly.",
    "“{livro}” again. Either you forgot it or you fell in love.",
    "Rereading “{livro}”. This time I'm watching the details. And the commas.",
}

B.fim.abertura = {
    "Finished “{livro}”.", "The end of “{livro}”.", "“{livro}” is over.", "Last page of “{livro}”.",
    "Ate the last line of “{livro}”.",
}
-- {nome}: the book's composite name (yomimon_vector.lua), e.g. "a sea story, restless"
B.fim.nome = { "It was {nome}.", "Deep down, {nome}.", "In short: {nome}.", "If anyone asks: {nome}." }
B.fim.protagonista = {
    jovem = { "I'll miss {nome}.", "{nome} is stuck in my head.", "{nome} will live in my heart. It's small, but there's room." },
    velha = { "{nome} is stuck in my head. Against my will.", "{nome} will haunt me for a few days.", "I survived {nome}. Barely." },
}
B.fim.mais_escuro = { "Darker than “{outro}”.", "Heavier than “{outro}”.", "Made “{outro}” look like a comedy." }
B.fim.mais_leve = { "Lighter than “{outro}”.", "After “{outro}”, a breather.", "Hurt less than “{outro}”." }
B.fim.serie = {
    "{ordinal} book in a row about {tema}. Are you running from something?",
    "{ordinal} book in a row about {tema}. I see a pattern.",
    "{ordinal} time one of your books feeds me {tema}. Noted.",
}
B.fim.traco = {
    amarga = { "I came out bitterer than I went in.", "This book took away a little hope." },
    otimista = { "I came out lighter than I went in.", "This book gave me back a little faith." },
    medrosa = { "I came out jumpier than I went in.", "This book taught me to check under the pages." },
    corajosa = { "I came out braver than I went in." },
    cinica = { "I came out more suspicious than I went in.", "This book taught me to follow the money." },
    romantica = { "I came out more romantic than I went in.", "This book softened me. How embarrassing." },
    popular = { "I came out in a hurry to read. Bad sign.", "This book spoiled me with its pace." },
    erudita = { "I came out more cultured than I went in. Insufferable.", "This book has me quoting authors." },
}
B.fim.nota = {
    jovem = { "Rating: {n} little stars.", "I give it {n} little stars.", "{n} little stars out of 5." },
    velha = { "Rating: {n} imaginary cigarettes.", "{n} imaginary cigarettes out of 5.", "Worth {n} imaginary cigarettes." },
}
B.fim.veredito = {
    jovem = {
        { "I ate it to be polite. Sorry, author.", "It wasn't for me. I think." },
        { "There was good stuff, but it took its time.", "Lukewarm. Like paper left in the sun." },
        { "I liked it! Not a lot. But I liked it." },
        { "What a book! I'll dream about it.", "I was sad when it ended. That's good, right?" },
        { "The best thing I've ever eaten. So far. I think. Yes.", "I want to read it again. Now. Right now." },
    },
    velha = {
        { "A book that exists. That's all." },
        { "It had its moments. Few.", "Lukewarm. Like forgotten tea." },
        { "Decent. Rare, these days.", "It didn't change my life. Didn't ruin it either." },
        { "A good book. I'll miss hating it.", "This author knew what they were doing. I hate when that happens." },
        { "Rare. A book I couldn't manage to hate.", "I close the cover with respect. And a cigarette." },
    },
}

B.obsessao.nova = {
    "I noticed I think a lot about {tema}. I didn't ask for this.",
    "I keep thinking about {tema}. Blame your books.",
    "I can't stop thinking about {tema}. I'll need another book. Or therapy.",
}
B.obsessao.troca = {
    "I used to think about {antes}. Now all I think about is {agora}. Blame you and your books.",
    "Swapped obsessions: out goes {antes_s}, in comes {agora_s}.",
    "{agora_s} has taken the place of {antes_s} in my head.",
    "I don't think about {antes} so much anymore. Now it's {agora_s}, all the time.",
}

-- Memories (yomimon_memories.lua): {autor} {n} {livro} {mes} {nome} {tema} {de_tema} ----------------
B.lembranca.autor = {
    "{autor} again. That's book number {n} by {autor} for us. This is a relationship now.",
    "Back to {autor}: book {n}. I can taste the seasoning already.",
    "Number {n} by {autor}. Some people collect stamps.",
    "More {autor}. Number {n}. You don't get tired, and honestly, neither do I.",
}
B.lembranca.aniversario = {
    "One year ago today we finished “{livro}”. I can still taste it.",
    "A year since the end of “{livro}”. Do you remember? I remember everything.",
    "Anniversary: exactly one year since the last page of “{livro}”.",
}
B.lembranca.personagem = {
    "{nome} again… we know each other from “{livro}”.",
    "Look who's back: {nome}. Haven't seen that one since “{livro}”.",
    "{nome}! I thought they stayed behind in “{livro}”.",
    "{nome} once more. “{livro}” wasn't enough, apparently.",
}
B.lembranca.recorde_longo = {
    "“{livro}”: {n} pages. The longest book you've ever read with me. I'm stuffed.",
    "Record: “{livro}” was the longest thing we've ever eaten together.",
    "We've never eaten anything as big as “{livro}”. I need to lie down.",
}
B.lembranca.recorde_rapido = {
    "No book ever went down as fast as “{livro}”. Either it was good or you were starving.",
    "Speed record: “{livro}”. It gave me hiccups.",
}
B.lembranca.serie_tema = {
    "Book number {n} in a row about {tema}. I see a pattern. Do you?",
    "Another book about {tema}. That's {n} in a row. Are you looking for something?",
    "{n} books in a row where {tema} rules. Noted in my little notebook.",
}
B.lembranca.sombrio_desde = {
    "You haven't read anything this dark since “{livro}”, back in {mes}.",
    "Not since “{livro}”, in {mes}, have I eaten pages this dark.",
    "This is as heavy as “{livro}”. And that was in {mes}.",
}
B.lembranca.mais_sombrio = {
    "This is the darkest book we've ever read together. I'm in mourning and I don't know why.",
    "I've never eaten pages this dark with you. A record nobody wanted.",
}
B.lembranca.leve_desde = {
    "Nothing this light since “{livro}”, in {mes}. What a relief.",
    "Not since “{livro}”, in {mes}, have I eaten pages this sweet.",
}
B.lembranca.mais_leve = {
    "The lightest book we've ever read together. Suspicious.",
    "I've never eaten pages this sweet with you. I'll get cavities.",
}

return B
