--[[--
Vocabulary of each theme (English, Yomimon): the same six kinds as the Portuguese one.
  taste       after "tastes of" / "taste of":  "salt"
  smell      after "smells of":               "sea air"
  comparison  after "like":                    "a breaking wave"
  exclamation  on its own:                      "Land ho!"
  place       with its preposition:            "on the deck"
  thing       with its article:                "an anchor"
_cause: the bad mood with a real reason from the book ({event} already comes with "that").
Never describe the reader with a gendered word.
]]

local D = {}

D.death = {
    taste = { "a snuffed candle", "wet earth", "a wilted flower", "ash", "cold funeral tea" },
    smell = { "chrysanthemums", "burnt candles", "freshly dug earth", "funeral lilies" },
    comparison = { "a funeral bell", "a candle burning down", "a portrait with a black ribbon", "a letter nobody will read", "a stopped clock" },
    exclamation = { "Rest in peace!", "God rest them!", "Oh, the mourning!", "Heavens!" },
    place = { "in a graveyard", "behind a coffin", "in an empty chapel", "at a wake", "under a headstone" },
    thing = { "a funeral wreath", "a black veil", "a paper coffin", "a nameless headstone", "a stopped clock" },
}
D.love = {
    taste = { "chocolates", "a perfumed letter", "strawberries", "a stolen kiss", "honey" },
    smell = { "roses", "a perfumed letter", "lavender", "orange blossom", "face powder" },
    comparison = { "a folded note", "a sigh on a balcony", "a heart drawn in the margin", "a waltz", "a pair of forgotten gloves" },
    exclamation = { "Oh, love!", "How romantic!", "Sigh!", "Be still, my heart!" },
    place = { "on a moonlit balcony", "at a ball", "under a window", "in a rose garden", "on a park bench" },
    thing = { "a love letter", "a ring", "a dried rose", "an embroidered handkerchief", "a portrait in a locket" },
}
D.war = {
    taste = { "gunpowder", "rust", "army rations", "smoke", "trench mud" },
    smell = { "gunpowder", "smoke", "boot leather", "mud", "hot metal" },
    comparison = { "a marching drum", "a stray bullet", "a torn map", "a cannon", "a wet trench" },
    exclamation = { "To arms!", "Fire!", "Retreat!", "Attention!" },
    place = { "in a trench", "on the battlefield", "behind a barricade", "in the barracks", "on the front line" },
    thing = { "a medal", "a dented helmet", "a bayonet", "a torn flag", "a battle map" },
}
D.sea = {
    taste = { "salt", "sea spray", "coconut water", "dried fish", "seaweed" },
    smell = { "sea air", "salt", "wet rope", "seaweed", "ship's timber" },
    comparison = { "a breaking wave", "a ship in a storm", "an anchor", "low tide", "a lit lighthouse" },
    exclamation = { "Land ho!", "Man overboard!", "High tide!", "By Neptune's beard!" },
    place = { "on the deck", "on a desert island", "in a ship's hold", "in a lighthouse", "at the bottom of the sea" },
    thing = { "an anchor", "a message in a bottle", "a compass", "a seashell", "a treasure map" },
}
D.faith = {
    taste = { "communion wafers", "holy water", "monastery bread", "incense", "altar wine" },
    smell = { "incense", "church candles", "confessional wood", "beeswax", "myrrh" },
    comparison = { "a church bell", "a whispered prayer", "a stained-glass window", "a procession", "a worn rosary" },
    exclamation = { "Lord have mercy!", "Hallelujah!", "Amen!", "Good heavens!" },
    place = { "in an empty church", "in a monastery", "in a confessional", "at an altar", "in a roadside chapel" },
    thing = { "a rosary", "a votive candle", "a holy card", "a worn Bible", "a crucifix" },
}
D.money = {
    taste = { "coins", "old banknotes", "gold", "a locked safe", "interest" },
    smell = { "new banknotes", "a locked safe", "wallet leather", "bank ink", "metal" },
    comparison = { "a locked safe", "a debt", "a counterfeit coin", "a bank statement", "a disputed inheritance" },
    exclamation = { "What a fortune!", "Gold!", "Bankrupt!", "Not a penny!" },
    place = { "in a bank", "behind a counter", "in a vault", "in a pawnshop", "in a solicitor's office" },
    thing = { "a gold coin", "a will", "a promissory note", "a safe", "a ledger" },
}
D.madness = {
    taste = { "bitter medicine", "chamomile tea", "chalk", "mirrors", "wallpaper" },
    smell = { "ether", "a locked attic", "old wallpaper", "medicine", "a midnight candle" },
    comparison = { "laughter in the hallway", "a cracked mirror", "a clock running backwards", "an endless staircase", "a voice in the attic" },
    exclamation = { "I've gone mad!", "What delirium!", "Ha!", "Help, the walls are talking!" },
    place = { "in a locked attic", "in an endless hallway", "in an asylum", "behind the wallpaper", "inside a mirror" },
    thing = { "a cracked mirror", "a straitjacket", "a scribbled diary", "a key with no door", "some yellow wallpaper" },
}
D.time = {
    taste = { "dust", "rust", "stale bread", "cold tea", "yesterday's cake" },
    smell = { "dust", "an old clock", "a photo album", "the attic", "yellowed paper" },
    comparison = { "an hourglass", "sand running out", "a torn-off calendar", "a slow clock hand", "a faded portrait" },
    exclamation = { "Tick-tock!", "It's late!", "Ah, the years!", "What time is it?" },
    place = { "in a clock tower", "in a dusty attic", "in a photo album", "at an old station", "in the last century" },
    thing = { "a pocket watch", "an hourglass", "an old calendar", "a faded portrait", "a burnt-down candle" },
}
D.city = {
    taste = { "soot", "corner-shop coffee", "asphalt", "street-market pastries", "tram smoke" },
    smell = { "soot", "rain on asphalt", "bakery coffee", "wet newspaper", "factory smoke" },
    comparison = { "a crowded tram", "a busy street corner", "a lit lamppost", "a packed square", "a noisy tenement" },
    exclamation = { "What a racket!", "Mind the tram!", "Extra! Extra!", "What a crowd!" },
    place = { "on a street corner", "in a tenement", "in a packed square", "on a tram", "on a cobbled street" },
    thing = { "a crumpled newspaper", "a tram ticket", "an umbrella", "a lamppost", "a forgotten hat" },
}
D.nature = {
    taste = { "leaves", "dew", "grass", "fruit off the tree", "earth" },
    smell = { "the woods", "rain on soil", "wildflowers", "eucalyptus", "hay" },
    comparison = { "a branch in the wind", "a running river", "an old tree", "a field in bloom", "a wooden fence" },
    exclamation = { "So green!", "Look at the river!", "Ah, the countryside!", "Smell the rain!" },
    place = { "deep in the woods", "on a riverbank", "under a tree", "in a wheat field", "in a clearing" },
    thing = { "a dry leaf", "a twig", "a river stone", "a nest", "a pressed flower" },
}
D.food = {
    taste = { "cornbread", "warm bread", "jam", "butter", "milky coffee" },
    smell = { "bread fresh from the oven", "coffee", "cinnamon", "soup", "cake" },
    comparison = { "a banquet", "a wobbling pudding", "a pot on the stove", "a rising cake", "a Sunday table" },
    exclamation = { "I'm starving!", "Delicious!", "Dinner's served!", "What a feast!" },
    place = { "in a kitchen", "at a dinner table", "in a bakery", "in a pantry", "at a picnic" },
    thing = { "a wooden spoon", "a pudding", "a bread basket", "a chipped teacup", "a recipe book" },
}
D.family = {
    taste = { "Sunday lunch", "grandma's cake", "afternoon tea", "home-made bread", "fruit preserves" },
    smell = { "grandma's house", "laundry on the line", "Sunday lunch", "an old wardrobe", "old-fashioned soap" },
    comparison = { "a full dinner table", "a family portrait", "a quarrel at supper", "a house with many rooms", "a divided inheritance" },
    exclamation = { "Oh, family!", "What relatives!", "Mother!", "Everyone to the table!" },
    place = { "in the dining room", "at grandmother's house", "in a nursery", "at Christmas dinner", "in a big old house" },
    thing = { "a family album", "a will", "an embroidered tablecloth", "an oval portrait", "a patchwork quilt" },
}
D.childhood = {
    taste = { "jelly beans", "candyfloss", "chocolate milk", "lollipops", "porridge" },
    smell = { "crayons", "play dough", "baby powder", "coloured pencils", "sweets" },
    comparison = { "a spinning top", "a kite in the sky", "a swing", "a nursery rhyme", "a baby tooth" },
    exclamation = { "Yay!", "Tag, you're it!", "Once upon a time!", "Hide and seek!" },
    place = { "on a swing", "in a tree house", "in the back garden", "in a classroom", "under the bed" },
    thing = { "a spinning top", "a doll", "a handwriting exercise book", "a marble", "a teddy bear" },
}
D.politics = {
    taste = { "an old speech", "newspaper ink", "empty promises", "office coffee", "stamped paper" },
    smell = { "cigars", "newspaper ink", "a stuffy office", "stamped paper", "palace floor wax" },
    comparison = { "an endless speech", "a close election", "a decree", "a plot in the corridor", "a rubber stamp" },
    exclamation = { "Order!", "Long live the republic!", "Down with the king!", "A coup!" },
    place = { "in parliament", "in a palace", "at a rally", "in a closed office", "at an assembly" },
    thing = { "a decree", "a ballot", "a rubber stamp", "a crumpled speech", "a sash of office" },
}
D.science = {
    taste = { "blackboard chalk", "ether", "lab metal", "formula ink", "lens dust" },
    smell = { "a laboratory", "ether", "alcohol", "ozone", "burnt wire" },
    comparison = { "an experiment gone wrong", "a test tube", "a microscope", "a long formula", "an electric spark" },
    exclamation = { "Eureka!", "Hypothesis!", "What a discovery!", "For science!" },
    place = { "in a laboratory", "in an observatory", "behind a microscope", "in a physics class", "inside a strange machine" },
    thing = { "a test tube", "a lens", "a notebook of formulas", "a cogwheel", "a telescope" },
}
D.solitude = {
    taste = { "cold tea", "bread for one", "silence", "coffee for one", "thin soup" },
    smell = { "a closed room", "rain on the window", "an empty house", "stored sheets", "dust" },
    comparison = { "an empty chair", "a lighthouse with no ships", "an unanswered letter", "an island", "an echo" },
    exclamation = { "Anyone there?", "Nobody!", "Ah, silence.", "Hello?" },
    place = { "in an empty room", "on an island", "in a lighthouse", "in a house with nobody in it", "at a deserted station" },
    thing = { "an empty chair", "a single cup", "an unanswered letter", "a lonely umbrella", "a lit candle" },
}
D.art = {
    taste = { "oil paint", "varnish", "charcoal", "watercolour", "plaster" },
    smell = { "oil paint", "turpentine", "varnish", "a studio", "old sheet music" },
    comparison = { "a crooked painting", "a symphony", "an unfinished sculpture", "a sonnet", "an empty stage" },
    exclamation = { "Bravo!", "Encore!", "What a masterpiece!", "Muse, help me!" },
    place = { "in a studio", "in a theatre", "in a museum", "on a stage", "in a gallery" },
    thing = { "a paintbrush", "a music score", "a plaster bust", "an empty frame", "a violin" },
}
D.animals = {
    taste = { "hay", "bones", "kibble", "feathers", "fur" },
    smell = { "a stable", "wet dog", "hay", "a nest", "a burrow" },
    comparison = { "a galloping horse", "an owl", "a cat on the roof", "a whale", "a loyal dog" },
    exclamation = { "Woof!", "Meow!", "What a creature!", "Giddy up!" },
    place = { "in a stable", "in a burrow", "in a nest", "on horseback", "in a barn" },
    thing = { "a horseshoe", "a feather", "a dog collar", "a nest", "a bone" },
}
D.night = {
    taste = { "dew", "warm milk", "moonlight", "candle wax", "midnight tea" },
    smell = { "night air", "a lit candle", "night jasmine", "bed sheets", "dew" },
    comparison = { "a full moon", "an owl awake", "a candle burning down", "a starless sky", "a dark corridor" },
    exclamation = { "Good night!", "Shh, it's past midnight!", "What a moon!", "Hush!" },
    place = { "under the moon", "on a dark street", "on a rooftop at midnight", "in a room with no light", "in a tower" },
    thing = { "an oil lamp", "a candle", "a candlestick", "a nightcap", "a lantern" },
}
D.travel = {
    taste = { "road dust", "station coffee", "travel bread", "harbour salt", "train smoke" },
    smell = { "an old suitcase", "train smoke", "a dirt road", "saddle leather", "locomotive coal" },
    comparison = { "a jolting carriage", "a whistling train", "a folded map", "a full suitcase", "an endless road" },
    exclamation = { "Off we go!", "All aboard!", "Next stop!", "Hit the road!" },
    place = { "in a carriage", "on a night train", "at a coaching inn", "at a station", "on a dirt road" },
    thing = { "a suitcase", "a train ticket", "a map", "a compass", "a passport" },
}
D.revenge = {
    taste = { "iron", "a dish served cold", "blood", "ash" },
    smell = { "gunpowder", "iron", "blood", "smoke" },
    comparison = { "a blood oath", "a hidden blade", "a dish served cold", "an old debt", "a duel at dawn" },
    exclamation = { "Revenge!", "He'll pay!", "An eye for an eye!", "I'll never forget!" },
    place = { "at a duel at dawn", "in a dungeon", "behind a curtain", "at a crossroads", "in a ruined castle" },
    thing = { "a dagger", "a thrown-down glove", "an anonymous letter", "a list of names" },
}
D.freedom = {
    taste = { "wind", "fresh air", "shared bread", "stolen fruit", "rain" },
    smell = { "wind", "open fields", "the open sea", "rain", "the open road" },
    comparison = { "a bird out of its cage", "an open door", "a shout", "a broken chain", "a horse set loose" },
    exclamation = { "Freedom!", "Open the gates!", "Off with the chains!", "Fly!" },
    place = { "in open country", "out of the cage", "on top of a hill", "on an unmarked road", "on the open sea" },
    thing = { "a key", "a broken chain", "an open cage", "a flag", "a kite" },
}
D.knowledge = {
    taste = { "parchment", "quill ink", "library dust", "chalk", "study tea" },
    smell = { "a library", "parchment", "leather bindings", "quill ink", "a study candle" },
    comparison = { "an encyclopedia", "a long lecture", "a footnote", "an open dictionary", "a whole library" },
    exclamation = { "Sapere aude!", "Elementary!", "Such erudition!", "Quod erat demonstrandum!" },
    place = { "in a library", "at a university", "in a study", "in a monastery scriptorium", "at an academy" },
    thing = { "a scroll", "a magnifying glass", "an inkwell", "a dictionary", "a globe" },
}
D.fear = {
    taste = { "cold sweat", "a snuffed candle", "rust", "crypt dust", "cobwebs" },
    smell = { "the cellar", "mildew", "a snuffed candle", "a crypt", "damp earth" },
    comparison = { "a creaking door", "a shadow in the hallway", "a howl", "a footstep in the dark", "a whisper behind the curtain" },
    exclamation = { "Help!", "Who's there?", "Good grief!", "Eek, a ghost!" },
    place = { "in a dark cellar", "in a crypt", "in a haunted castle", "in an unlit hallway", "under the stairs" },
    thing = { "a cobweb", "a rusty key", "a snuffed candlestick", "a portrait whose eyes follow you", "a coffin left ajar" },
}

-- Invented cause: a bad mood gets a real reason (the standout event of a recent chapter).
D._cause = {
    events = {
        death = "that death", wedding = "that wedding", travel = "that journey", letter = "that letter",
        storm = "that storm", illness = "that fever", party = "that party", quarrel = "that fight",
        escape = "that escape", crime = "that crime",
    },
    young = {
        "I woke up glum. Must be {event} in “{book}”.",
        "I'm droopy today. I think it was {event} in “{book}”.",
        "I don't know why I'm like this. Or I do: {event} in “{book}”.",
        "I can't get it out of my head: {event} in “{book}”.",
    },
    old = {
        "Bad mood. Must be {event} in “{book}”. I never recovered.",
        "I woke up sour. It's still {event} in “{book}”, I'm sure.",
        "If I'm unbearable, blame {event} in “{book}”.",
        "Don't ask me anything today. It's {event} in “{book}”, still.",
    },
}

return D
