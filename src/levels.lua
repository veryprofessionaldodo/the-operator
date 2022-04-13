
TIMEOUT = 90
LEVELS = {
    level_zero = {
        time = 50,
        max_messages = 10,
        missed = 0,
        interrupted = 0,
        wrong = 0
    },
    call_thief = {
        time = 3,
        max_messages = 1,
        missed = 0,
        interrupted = 0,
        wrong = 0
    },
    level_one = {
        time = TIMEOUT,
        max_messages = 7,
        messages = {
            {
                content = "Hello! I'm returning a call to my chauffer, he should be @receiver",
                timestamp = 3
            }, {
                content = "Could you connect me to the taxi company @receiver? There's a driver there who knows the city like the back of his hand",
                solution = true,
                timestamp = 20
            }, {
                content = "I'm looking to buy myself one of those new spiffy cars. I heard @receiver was maybe selling one",
                timestamp = 40
            }, {
                content = "I can't with this heap of a car! Call @receiver for me, will'ya doll?",
                timestamp = 52
            }
        },
        missed = 0,
        interrupted = 0,
        wrong = 0
    },
    level_two = {
        time = TIMEOUT,
        max_messages = 9,
        messages = {
            {
                content = "Call the mine @receiver and tell the to get me the ragamuffin who colapsed half of my gold mine!",
                timestamp = 5
            }, {
                content = "Could you get me that delightful scotish man at @receiver? I've heard he can handle a grenade launcher well.",
                solution = true,
                timestamp = 20
            }
        },
        missed = 0,
        interrupted = 0,
        wrong = 0
    },
    level_three = {
        time = TIMEOUT,
        max_messages = 15,
        messages = {
            {
                content = "Hiya, we're trying to play chess over the phone. Call @receiver and tell him I want Pawn to F3.",
                timestamp = 10
            }, {
                content = "Hello, @receiver just called, we're playing chess. Pawn to E6.",
                timestamp = 16
            },
            {
                content = "I'm trying to reach @receiver. Pawn to G4.",
                timestamp = 40
            }, {
                content = "Yes! Call @receiver. Queen to H4! Checkmate!",
                solution = true,
                timestamp = 46
            }
        },
        missed = 0,
        interrupted = 0,
        wrong = 0
    },
    level_four = {
        time = TIMEOUT,
        max_messages = 15,
        messages = {
            {
                content = "Get me @receiver, spiffy! His trigger men just tried to chisel me!",
                timestamp = 2
            }, {
                content = "Where are the coppers when you need them? Call the station! @receiver, move!",
                timestamp = 4
            }, {
                content = "Good golly! This town ain't safe no more! Call me @receiver, I need a piece!",
                solution = true,
                timestamp = 6
            }
        },
        missed = 0,
        interrupted = 0,
        wrong = 0
    }
}

MESSAGE_POOL = {
    {content = "Hiya sweet-cheeks, connect me to line @receiver, pronto!"},
    {content = "Hello, could you reach @receiver for me?"},
    {content = "Get @receiver for me, will ya?"},
    {content = "...rt...ng...a...@receiver...ps?"},
    {content = "I just wanna give @receiver a piece of my mind!"}, {
        content = "Is this thing working? Oh I can never get this to work... Hello? Deary? @receiver?"
    }, {content = "Can I talk to @receiver, please?"},
    {content = "Dolly? Yes, get me to @receiver."}, {content = "@receiver"},
    {content = "Can-a a you-a connect-a me-a to @receiver?"},
    {content = "I need to talk to @receiver, make it quick"},
    {content = "It'd be swell if I could call @receiver."},
    {content = "Get me @receiver, savvy?"},
    {content = "I can't with this no more, just call @receiver!"}, {
        content = "Why do you grifters take so much time to do everything? Connect me with @receiver, woman!"
    }, {content = "Darling, I'd like to talk to @receiver, ok?"}
}

MESSAGES = {}