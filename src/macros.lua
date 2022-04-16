SWITCHBOARD = {
    X = 10,
    Y = 10,
    N_ROWS = 4,
    N_COLS = 7,
    COL_SPACING = 34,
    ROW_SPACING = 23
}

GRAVITY = 9.8
ROPE_WIDTH = 10

FRAME_COUNTER = 0
SECONDS_PASSED = 0
ASCII_UPPER_A = 65
Z_KEYCODE = 26
UP_KEYCODE = 58
DOWN_KEYCODE = 59

-- knobs are computed based on switch board params
KNOBS = {}
KNOB_STATE = {
    OFF = "off",
    INCOMING = "incoming",
    DISPATCHING = "dispatching",
    CONNECTED = "connected",
    MISSED = "missed"
}
CALL_STATE = {
    ONGOING = 'ongoing',
    DISPATCHING = "dispatching",
    FINISHED = 'finished',
    INTERRUPTED = 'interrupted',
    UNUSED = "unused"
}
KNOB_WIDTH, KNOB_HEIGHT, KNOB_SCALE = 8, 8, 2
SEGMENTS_LENGTH = 10
KNOB_PIVOT, CALL_SELECTED, OPERATOR_KNOB = nil, nil, nil

-- calls from knob to knob
CALLS = {}

DISPATCH = nil

TEXT_COLOR = 12
TEXT_X_SHIFT = 25
LINE_HEIGHT = 10
