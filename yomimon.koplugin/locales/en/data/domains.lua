--[[--
Vocabulário de cada tema (inglês, Yomimon): mesmos seis tipos de dominios_pt.lua.
  gosto       after "tastes of" / "taste of":  "salt"
  cheiro      after "smells of":               "sea air"
  comparacao  after "like":                    "a breaking wave"
  exclamacao  on its own:                      "Land ho!"
  lugar       with its preposition:            "on the deck"
  coisa       with its article:                "an anchor"
_causa: o mau humor com motivo real do livro ({evento} já vem com "that").
Never describe the reader with a gendered word.
]]

local D = {}

D.morte = {
    gosto = { "a snuffed candle", "wet earth", "a wilted flower", "ash", "cold funeral tea" },
    cheiro = { "chrysanthemums", "burnt candles", "freshly dug earth", "funeral lilies" },
    comparacao = { "a funeral bell", "a candle burning down", "a portrait with a black ribbon", "a letter nobody will read", "a stopped clock" },
    exclamacao = { "Rest in peace!", "God rest them!", "Oh, the mourning!", "Heavens!" },
    lugar = { "in a graveyard", "behind a coffin", "in an empty chapel", "at a wake", "under a headstone" },
    coisa = { "a funeral wreath", "a black veil", "a paper coffin", "a nameless headstone", "a stopped clock" },
}
D.amor = {
    gosto = { "chocolates", "a perfumed letter", "strawberries", "a stolen kiss", "honey" },
    cheiro = { "roses", "a perfumed letter", "lavender", "orange blossom", "face powder" },
    comparacao = { "a folded note", "a sigh on a balcony", "a heart drawn in the margin", "a waltz", "a pair of forgotten gloves" },
    exclamacao = { "Oh, love!", "How romantic!", "Sigh!", "Be still, my heart!" },
    lugar = { "on a moonlit balcony", "at a ball", "under a window", "in a rose garden", "on a park bench" },
    coisa = { "a love letter", "a ring", "a dried rose", "an embroidered handkerchief", "a portrait in a locket" },
}
D.guerra = {
    gosto = { "gunpowder", "rust", "army rations", "smoke", "trench mud" },
    cheiro = { "gunpowder", "smoke", "boot leather", "mud", "hot metal" },
    comparacao = { "a marching drum", "a stray bullet", "a torn map", "a cannon", "a wet trench" },
    exclamacao = { "To arms!", "Fire!", "Retreat!", "Attention!" },
    lugar = { "in a trench", "on the battlefield", "behind a barricade", "in the barracks", "on the front line" },
    coisa = { "a medal", "a dented helmet", "a bayonet", "a torn flag", "a battle map" },
}
D.mar = {
    gosto = { "salt", "sea spray", "coconut water", "dried fish", "seaweed" },
    cheiro = { "sea air", "salt", "wet rope", "seaweed", "ship's timber" },
    comparacao = { "a breaking wave", "a ship in a storm", "an anchor", "low tide", "a lit lighthouse" },
    exclamacao = { "Land ho!", "Man overboard!", "High tide!", "By Neptune's beard!" },
    lugar = { "on the deck", "on a desert island", "in a ship's hold", "in a lighthouse", "at the bottom of the sea" },
    coisa = { "an anchor", "a message in a bottle", "a compass", "a seashell", "a treasure map" },
}
D.fe = {
    gosto = { "communion wafers", "holy water", "monastery bread", "incense", "altar wine" },
    cheiro = { "incense", "church candles", "confessional wood", "beeswax", "myrrh" },
    comparacao = { "a church bell", "a whispered prayer", "a stained-glass window", "a procession", "a worn rosary" },
    exclamacao = { "Lord have mercy!", "Hallelujah!", "Amen!", "Good heavens!" },
    lugar = { "in an empty church", "in a monastery", "in a confessional", "at an altar", "in a roadside chapel" },
    coisa = { "a rosary", "a votive candle", "a holy card", "a worn Bible", "a crucifix" },
}
D.dinheiro = {
    gosto = { "coins", "old banknotes", "gold", "a locked safe", "interest" },
    cheiro = { "new banknotes", "a locked safe", "wallet leather", "bank ink", "metal" },
    comparacao = { "a locked safe", "a debt", "a counterfeit coin", "a bank statement", "a disputed inheritance" },
    exclamacao = { "What a fortune!", "Gold!", "Bankrupt!", "Not a penny!" },
    lugar = { "in a bank", "behind a counter", "in a vault", "in a pawnshop", "in a solicitor's office" },
    coisa = { "a gold coin", "a will", "a promissory note", "a safe", "a ledger" },
}
D.loucura = {
    gosto = { "bitter medicine", "chamomile tea", "chalk", "mirrors", "wallpaper" },
    cheiro = { "ether", "a locked attic", "old wallpaper", "medicine", "a midnight candle" },
    comparacao = { "laughter in the hallway", "a cracked mirror", "a clock running backwards", "an endless staircase", "a voice in the attic" },
    exclamacao = { "I've gone mad!", "What delirium!", "Ha!", "Help, the walls are talking!" },
    lugar = { "in a locked attic", "in an endless hallway", "in an asylum", "behind the wallpaper", "inside a mirror" },
    coisa = { "a cracked mirror", "a straitjacket", "a scribbled diary", "a key with no door", "some yellow wallpaper" },
}
D.tempo = {
    gosto = { "dust", "rust", "stale bread", "cold tea", "yesterday's cake" },
    cheiro = { "dust", "an old clock", "a photo album", "the attic", "yellowed paper" },
    comparacao = { "an hourglass", "sand running out", "a torn-off calendar", "a slow clock hand", "a faded portrait" },
    exclamacao = { "Tick-tock!", "It's late!", "Ah, the years!", "What time is it?" },
    lugar = { "in a clock tower", "in a dusty attic", "in a photo album", "at an old station", "in the last century" },
    coisa = { "a pocket watch", "an hourglass", "an old calendar", "a faded portrait", "a burnt-down candle" },
}
D.cidade = {
    gosto = { "soot", "corner-shop coffee", "asphalt", "street-market pastries", "tram smoke" },
    cheiro = { "soot", "rain on asphalt", "bakery coffee", "wet newspaper", "factory smoke" },
    comparacao = { "a crowded tram", "a busy street corner", "a lit lamppost", "a packed square", "a noisy tenement" },
    exclamacao = { "What a racket!", "Mind the tram!", "Extra! Extra!", "What a crowd!" },
    lugar = { "on a street corner", "in a tenement", "in a packed square", "on a tram", "on a cobbled street" },
    coisa = { "a crumpled newspaper", "a tram ticket", "an umbrella", "a lamppost", "a forgotten hat" },
}
D.natureza = {
    gosto = { "leaves", "dew", "grass", "fruit off the tree", "earth" },
    cheiro = { "the woods", "rain on soil", "wildflowers", "eucalyptus", "hay" },
    comparacao = { "a branch in the wind", "a running river", "an old tree", "a field in bloom", "a wooden fence" },
    exclamacao = { "So green!", "Look at the river!", "Ah, the countryside!", "Smell the rain!" },
    lugar = { "deep in the woods", "on a riverbank", "under a tree", "in a wheat field", "in a clearing" },
    coisa = { "a dry leaf", "a twig", "a river stone", "a nest", "a pressed flower" },
}
D.comida = {
    gosto = { "cornbread", "warm bread", "jam", "butter", "milky coffee" },
    cheiro = { "bread fresh from the oven", "coffee", "cinnamon", "soup", "cake" },
    comparacao = { "a banquet", "a wobbling pudding", "a pot on the stove", "a rising cake", "a Sunday table" },
    exclamacao = { "I'm starving!", "Delicious!", "Dinner's served!", "What a feast!" },
    lugar = { "in a kitchen", "at a dinner table", "in a bakery", "in a pantry", "at a picnic" },
    coisa = { "a wooden spoon", "a pudding", "a bread basket", "a chipped teacup", "a recipe book" },
}
D.familia = {
    gosto = { "Sunday lunch", "grandma's cake", "afternoon tea", "home-made bread", "fruit preserves" },
    cheiro = { "grandma's house", "laundry on the line", "Sunday lunch", "an old wardrobe", "old-fashioned soap" },
    comparacao = { "a full dinner table", "a family portrait", "a quarrel at supper", "a house with many rooms", "a divided inheritance" },
    exclamacao = { "Oh, family!", "What relatives!", "Mother!", "Everyone to the table!" },
    lugar = { "in the dining room", "at grandmother's house", "in a nursery", "at Christmas dinner", "in a big old house" },
    coisa = { "a family album", "a will", "an embroidered tablecloth", "an oval portrait", "a patchwork quilt" },
}
D.infancia = {
    gosto = { "jelly beans", "candyfloss", "chocolate milk", "lollipops", "porridge" },
    cheiro = { "crayons", "play dough", "baby powder", "coloured pencils", "sweets" },
    comparacao = { "a spinning top", "a kite in the sky", "a swing", "a nursery rhyme", "a baby tooth" },
    exclamacao = { "Yay!", "Tag, you're it!", "Once upon a time!", "Hide and seek!" },
    lugar = { "on a swing", "in a tree house", "in the back garden", "in a classroom", "under the bed" },
    coisa = { "a spinning top", "a doll", "a handwriting exercise book", "a marble", "a teddy bear" },
}
D.politica = {
    gosto = { "an old speech", "newspaper ink", "empty promises", "office coffee", "stamped paper" },
    cheiro = { "cigars", "newspaper ink", "a stuffy office", "stamped paper", "palace floor wax" },
    comparacao = { "an endless speech", "a close election", "a decree", "a plot in the corridor", "a rubber stamp" },
    exclamacao = { "Order!", "Long live the republic!", "Down with the king!", "A coup!" },
    lugar = { "in parliament", "in a palace", "at a rally", "in a closed office", "at an assembly" },
    coisa = { "a decree", "a ballot", "a rubber stamp", "a crumpled speech", "a sash of office" },
}
D.ciencia = {
    gosto = { "blackboard chalk", "ether", "lab metal", "formula ink", "lens dust" },
    cheiro = { "a laboratory", "ether", "alcohol", "ozone", "burnt wire" },
    comparacao = { "an experiment gone wrong", "a test tube", "a microscope", "a long formula", "an electric spark" },
    exclamacao = { "Eureka!", "Hypothesis!", "What a discovery!", "For science!" },
    lugar = { "in a laboratory", "in an observatory", "behind a microscope", "in a physics class", "inside a strange machine" },
    coisa = { "a test tube", "a lens", "a notebook of formulas", "a cogwheel", "a telescope" },
}
D.solidao = {
    gosto = { "cold tea", "bread for one", "silence", "coffee for one", "thin soup" },
    cheiro = { "a closed room", "rain on the window", "an empty house", "stored sheets", "dust" },
    comparacao = { "an empty chair", "a lighthouse with no ships", "an unanswered letter", "an island", "an echo" },
    exclamacao = { "Anyone there?", "Nobody!", "Ah, silence.", "Hello?" },
    lugar = { "in an empty room", "on an island", "in a lighthouse", "in a house with nobody in it", "at a deserted station" },
    coisa = { "an empty chair", "a single cup", "an unanswered letter", "a lonely umbrella", "a lit candle" },
}
D.arte = {
    gosto = { "oil paint", "varnish", "charcoal", "watercolour", "plaster" },
    cheiro = { "oil paint", "turpentine", "varnish", "a studio", "old sheet music" },
    comparacao = { "a crooked painting", "a symphony", "an unfinished sculpture", "a sonnet", "an empty stage" },
    exclamacao = { "Bravo!", "Encore!", "What a masterpiece!", "Muse, help me!" },
    lugar = { "in a studio", "in a theatre", "in a museum", "on a stage", "in a gallery" },
    coisa = { "a paintbrush", "a music score", "a plaster bust", "an empty frame", "a violin" },
}
D.animais = {
    gosto = { "hay", "bones", "kibble", "feathers", "fur" },
    cheiro = { "a stable", "wet dog", "hay", "a nest", "a burrow" },
    comparacao = { "a galloping horse", "an owl", "a cat on the roof", "a whale", "a loyal dog" },
    exclamacao = { "Woof!", "Meow!", "What a creature!", "Giddy up!" },
    lugar = { "in a stable", "in a burrow", "in a nest", "on horseback", "in a barn" },
    coisa = { "a horseshoe", "a feather", "a dog collar", "a nest", "a bone" },
}
D.noite = {
    gosto = { "dew", "warm milk", "moonlight", "candle wax", "midnight tea" },
    cheiro = { "night air", "a lit candle", "night jasmine", "bed sheets", "dew" },
    comparacao = { "a full moon", "an owl awake", "a candle burning down", "a starless sky", "a dark corridor" },
    exclamacao = { "Good night!", "Shh, it's past midnight!", "What a moon!", "Hush!" },
    lugar = { "under the moon", "on a dark street", "on a rooftop at midnight", "in a room with no light", "in a tower" },
    coisa = { "an oil lamp", "a candle", "a candlestick", "a nightcap", "a lantern" },
}
D.viagem = {
    gosto = { "road dust", "station coffee", "travel bread", "harbour salt", "train smoke" },
    cheiro = { "an old suitcase", "train smoke", "a dirt road", "saddle leather", "locomotive coal" },
    comparacao = { "a jolting carriage", "a whistling train", "a folded map", "a full suitcase", "an endless road" },
    exclamacao = { "Off we go!", "All aboard!", "Next stop!", "Hit the road!" },
    lugar = { "in a carriage", "on a night train", "at a coaching inn", "at a station", "on a dirt road" },
    coisa = { "a suitcase", "a train ticket", "a map", "a compass", "a passport" },
}
D.vinganca = {
    gosto = { "iron", "a dish served cold", "blood", "ash" },
    cheiro = { "gunpowder", "iron", "blood", "smoke" },
    comparacao = { "a blood oath", "a hidden blade", "a dish served cold", "an old debt", "a duel at dawn" },
    exclamacao = { "Revenge!", "He'll pay!", "An eye for an eye!", "I'll never forget!" },
    lugar = { "at a duel at dawn", "in a dungeon", "behind a curtain", "at a crossroads", "in a ruined castle" },
    coisa = { "a dagger", "a thrown-down glove", "an anonymous letter", "a list of names" },
}
D.liberdade = {
    gosto = { "wind", "fresh air", "shared bread", "stolen fruit", "rain" },
    cheiro = { "wind", "open fields", "the open sea", "rain", "the open road" },
    comparacao = { "a bird out of its cage", "an open door", "a shout", "a broken chain", "a horse set loose" },
    exclamacao = { "Freedom!", "Open the gates!", "Off with the chains!", "Fly!" },
    lugar = { "in open country", "out of the cage", "on top of a hill", "on an unmarked road", "on the open sea" },
    coisa = { "a key", "a broken chain", "an open cage", "a flag", "a kite" },
}
D.saber = {
    gosto = { "parchment", "quill ink", "library dust", "chalk", "study tea" },
    cheiro = { "a library", "parchment", "leather bindings", "quill ink", "a study candle" },
    comparacao = { "an encyclopedia", "a long lecture", "a footnote", "an open dictionary", "a whole library" },
    exclamacao = { "Sapere aude!", "Elementary!", "Such erudition!", "Quod erat demonstrandum!" },
    lugar = { "in a library", "at a university", "in a study", "in a monastery scriptorium", "at an academy" },
    coisa = { "a scroll", "a magnifying glass", "an inkwell", "a dictionary", "a globe" },
}
D.medo = {
    gosto = { "cold sweat", "a snuffed candle", "rust", "crypt dust", "cobwebs" },
    cheiro = { "the cellar", "mildew", "a snuffed candle", "a crypt", "damp earth" },
    comparacao = { "a creaking door", "a shadow in the hallway", "a howl", "a footstep in the dark", "a whisper behind the curtain" },
    exclamacao = { "Help!", "Who's there?", "Good grief!", "Eek, a ghost!" },
    lugar = { "in a dark cellar", "in a crypt", "in a haunted castle", "in an unlit hallway", "under the stairs" },
    coisa = { "a cobweb", "a rusty key", "a snuffed candlestick", "a portrait whose eyes follow you", "a coffin left ajar" },
}

-- Invented cause: a bad mood gets a real reason (the standout event of a recent chapter).
D._causa = {
    eventos = {
        morte = "that death", casamento = "that wedding", viagem = "that journey", carta = "that letter",
        tempestade = "that storm", doenca = "that fever", festa = "that party", briga = "that fight",
        fuga = "that escape", crime = "that crime",
    },
    jovem = {
        "I woke up glum. Must be {evento} in “{livro}”.",
        "I'm droopy today. I think it was {evento} in “{livro}”.",
        "I don't know why I'm like this. Or I do: {evento} in “{livro}”.",
        "I can't get it out of my head: {evento} in “{livro}”.",
    },
    velha = {
        "Bad mood. Must be {evento} in “{livro}”. I never recovered.",
        "I woke up sour. It's still {evento} in “{livro}”, I'm sure.",
        "If I'm unbearable, blame {evento} in “{livro}”.",
        "Don't ask me anything today. It's {evento} in “{livro}”, still.",
    },
}

return D
