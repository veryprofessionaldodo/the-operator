-- title:  The Operator
-- author: Team "It's about drive"
-- desc:   RetroJam 2022 organized by IEEE UP SB
-- script: lua
-- Viewport 240x136
SWITCHBOARD = {
    start_x = 10,
    start_y = 10,
    row_num = 4,
    col_num = 5,
    col_spacing = 35,
    row_spacing = 25
}

FRAME_COUNTER = 0

-- knobs are computed based on switch board params
KNOBS = {}
KNOB_STATE = {OFF = "off", INCOMING = "incoming", CONNECTED = "connected"}
KNOB_WIDTH, KNOB_HEIGHT = 8, 8

function TIC()
    update()
    draw()
end

-- inits
function init() KNOBS = get_knobs() end

function get_knobs()
    local knobs = {}
    for i = 0, SWITCHBOARD.row_num - 1 do
        for j = 0, SWITCHBOARD.col_num - 1 do
            x = SWITCHBOARD.start_x + (j * SWITCHBOARD.col_spacing)
            y = SWITCHBOARD.start_y + (i * SWITCHBOARD.row_spacing)
            knob = {x = x, y = y, state = KNOB_STATE.OFF, timer = 0}
            table.insert(knobs, knob)
        end
    end
    return knobs
end

-- updates
function update() FRAME_COUNTER = FRAME_COUNTER + 1 end

-- draws
function draw()
    cls()
    rectb(0, 0, 240, 136, 2)
    draw_switchboard()
    draw_message_box()
    draw_knobs()
end

function draw_switchboard()
    rectb(5, 5, (SWITCHBOARD.col_num * SWITCHBOARD.col_spacing) - 8,
          SWITCHBOARD.row_num * SWITCHBOARD.row_spacing, 1)
    draw_header()
    draw_sidebar()
end

function draw_header()
    for i = 0, SWITCHBOARD.col_num - 1 do
        local x = SWITCHBOARD.start_x + KNOB_WIDTH - 3 + i *
                      SWITCHBOARD.col_spacing
        print(string.char(65 + i), x, 0, 1)
    end
end

function draw_sidebar()
    for i = 0, SWITCHBOARD.row_num - 1 do
        local y = SWITCHBOARD.start_y + KNOB_HEIGHT - 3 + i *
                      SWITCHBOARD.row_spacing
        print(i + 1, 0, y, 1)
    end
end

function draw_knobs()
    for i = 1, #KNOBS do
        -- TODO: this blinking should be calculated based on state and timer of the knob
        local is_blinking = i == 2
        if is_blinking then
            spr(0 + FRAME_COUNTER % 60 // 30 * 2, KNOBS[i].x, KNOBS[i].y, -1, 2)
        else
            spr(0, KNOBS[i].x, KNOBS[i].y, -1, 2)
        end
    end
end

function draw_message_box()
    rectb(5, SWITCHBOARD.row_num * SWITCHBOARD.row_spacing + 8, 230, 25, 5)
end

-- utils
function has_value(tab, val)
    for _i, value in ipairs(tab) do if value == val then return true end end
    return false
end

function ifthenelse(cond, t, f)
    if cond then
        return t
    else
        return f
    end
end

-- starts the game
init()

-- <TILES>
-- 000:00ffff000ffeeff0ffeeeefffeeeeedffeeeeedfffeeedff0ffedff000ffff00
-- 001:00ffff000ff22ff0ff2222fff222223ff222223fff2223ff0ff23ff000ffff00
-- 002:00ffff000ff66ff0ff6666fff666665ff666665fff6665ff0ff65ff000ffff00
-- 003:00ffff000ff44ff0ff4444fff444441ff444441fff4441ff0ff41ff000ffff00
-- 004:00ffff000ffffff0ffffffffffffffffffffffffffffffff0ffffff000ffff00
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2cffa559b13e53d67571ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

