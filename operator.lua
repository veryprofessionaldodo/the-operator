-- title:  The Operator
-- author: Team "It's about drive"
-- desc:   RetroJam 2022 organized by IEEE UP SB
-- script: lua
-- Viewport 240x136
STATES = {
    MAIN_MENU = 'main_menu',
    CUTSCENE_ZERO = 'cutscene_zero',
    LEVEL_ONE = 'level_one',
    RESULT_ONE = 'result_one',
    RESULT_FINAL = 'result_final'
}

SKIPPABLE_STATES = {
    STATES.MAIN_MENU, STATES.CUTSCENE_ZERO, STATES.RESULT_ONE,
    STATES.RESULT_FINAL
}

PLAYABLE_STATES = {STATES.LEVEL_ONE}

CUR_STATE = STATES.MAIN_MENU

LEVELS = {
    level_one = {
        messages = {
            {
                caller = "Shake Spear",
                receiver = "BigZ",
                content = "Hello World",
                timestamp = 2,
                processed = false
            }, {
                caller = "Tom Segura",
                receiver = "João Conde",
                content = "Auuuch where is the hospital I played basketball",
                timestamp = 4,
                processed = false
            }, {
                caller = "Slim Shady",
                receiver = "Diogo Dores",
                content = "Wazuuuuuuuuuup",
                timestamp = 6,
                processed = false
            }
        }
    }
}

MESSAGES = {}

SWITCHBOARD = {
    X = 10,
    Y = 10,
    N_ROWS = 4,
    N_COLS = 7,
    COL_SPACING = 34,
    ROW_SPACING = 23
}

FRAME_COUNTER = 0
SECONDS_PASSED = 0
ASCII_UPPER_A = 65
Z_KEYCODE = 26

-- knobs are computed based on switch board params
KNOBS = {}
KNOB_STATE = {
    OFF = "off",
    INCOMING = "incoming",
    DISPATCHING = "dispatching",
    CONNECTED = "connected"
}
CALL_STATE = {
    ONGOING = 'ongoing',
    DISPATCHING = "dispatching",
    FINISHED = 'finished',
    INTERRUPTED = 'interrupted',
    UNUSED = "unused"
}
KNOB_WIDTH, KNOB_HEIGHT, KNOB_SCALE = 8, 8, 2
KNOB_SELECTED, CALL_SELECTED, OPERATOR_KNOB = nil, nil, nil

MISSED_CALLS = 0

-- calls from knob to knob
CALLS = {}

DISPATCH = nil

function TIC()
    update()
    draw()
end

-- inits
function init()
    CUR_STATE = STATES.LEVEL_ONE
    KNOBS = init_knobs()
    CALLS = init_calls()

    setup_level()
end

function init_knobs()
    local knobs = {}

    -- switchboard knobs
    for i = 0, SWITCHBOARD.N_ROWS - 1 do
        for j = 0, SWITCHBOARD.N_COLS - 1 do
            local x = SWITCHBOARD.X + (j * SWITCHBOARD.COL_SPACING)
            local y = SWITCHBOARD.Y + (i * SWITCHBOARD.ROW_SPACING)
            local knob = {
                coords = {string.char(ASCII_UPPER_A + j), i + 1},
                x = x,
                y = y,
                state = KNOB_STATE.OFF,
                pickup_timer = 0
            }
            table.insert(knobs, knob)
        end
    end

    -- add operator knob
    OPERATOR_KNOB = {x = 10, y = 115, state = KNOB_STATE.OFF, timer = 0}

    return knobs
end

function init_calls()
    local calls = {}

    -- TODO: generate random
    table.insert(calls,
                 {src = KNOBS[1], dst = KNOBS[2], state = CALL_STATE.UNUSED})
    table.insert(calls,
                 {src = KNOBS[5], dst = KNOBS[15], state = CALL_STATE.UNUSED})
    table.insert(calls,
                 {src = KNOBS[8], dst = KNOBS[12], state = CALL_STATE.UNUSED})
    table.insert(calls,
                 {src = KNOBS[9], dst = KNOBS[4], state = CALL_STATE.UNUSED})

    return calls
end

-- updates
function update()
    FRAME_COUNTER = FRAME_COUNTER + 1

    if has_value(SKIPPABLE_STATES, CUR_STATE) and keyp(Z_KEYCODE) then
        update_state_machine()
    elseif has_value(PLAYABLE_STATES, CUR_STATE) then
        update_mouse()
    end

    -- UPDATE STATES
    -- TODO: perhaps not needed
    OPERATOR_KNOB.state = KNOB_STATE.OFF
    for _, knob in pairs(KNOBS) do
        if knob.state ~= KNOB_STATE.INCOMING then
            knob.state = KNOB_STATE.OFF
        else
            if (FRAME_COUNTER % 60 == 0) then
                knob.pickup_timer = knob.pickup_timer - 1
                if knob.pickup_timer == 0 then
                    MISSED_CALLS = MISSED_CALLS + 1
                    knob.state = KNOB_STATE.OFF
                end
            end
        end
    end

    for _, call in pairs(CALLS) do
        if call.state == CALL_STATE.DISPATCHING then
            call.src.state = KNOB_STATE.DISPATCHING
            call.dst.state = KNOB_STATE.DISPATCHING
        elseif call.state == CALL_STATE.ONGOING then
            if call.src.state ~= KNOB_STATE.INCOMING and call.dst.state ~=
                KNOB_STATE.INCOMING then
                call.src.state = KNOB_STATE.CONNECTED
                call.dst.state = KNOB_STATE.CONNECTED
            end
            if (FRAME_COUNTER % 60 == 0) then
                call.duration = call.duration - 1
                if call.duration == 0 then
                    call.state = CALL_STATE.FINISHED
                    call.src.state = KNOB_STATE.OFF
                    call.dst.state = KNOB_STATE.OFF
                    for i = 1, #MESSAGES do
                        if MESSAGES[i] == call.message then
                            table.remove(MESSAGES, i)
                            break
                        end
                    end
                end
            end
        end
    end

    for _, message in pairs(MESSAGES) do
        if message.timestamp == SECONDS_PASSED and not message.processed then
            src_knob = get_available_knob()
            src_knob.state = KNOB_STATE.INCOMING
            src_knob.pickup_timer = 10

            dst_knob = get_available_knob()

            message.src = src_knob
            message.dst = dst_knob
            message.processed = true
        end
    end
end

function get_available_knob()
    local allocated_srcs = map(MESSAGES,
                               function(message) return message.src end)
    local allocated_dsts = map(MESSAGES,
                               function(message) return message.dst end)
    local usable_knobs = filter(KNOBS, function(knob)
        return knob.state == KNOB_STATE.OFF and
                   not has_value(allocated_srcs, knob) and
                   not has_value(allocated_dsts, knob)
    end)
    local index = math.random(1, #usable_knobs)
    return usable_knobs[index]
end

function update_state_machine()
    -- stops all SFX
    -- sfx(-1)

    -- advances state machine to next state
    -- may run additional logic in between
    if CUR_STATE == STATES.MAIN_MENU then
        CUR_STATE = STATES.CUTSCENE_ZERO
    elseif CUR_STATE == STATES.CUTSCENE_ZERO then
        CUR_STATE = STATES.LEVEL_ONE
    elseif CUR_STATE == STATES.LEVEL_ONE then
        CUR_STATE = STATES.RESULT_ONE
    elseif CUR_STATE == STATES.RESULT_ONE then
        CUR_STATE = STATES.RESULT_FINAL
    elseif CUR_STATE == STATES.RESULT_FINAL then
        init()
    end

    if has_value(PLAYABLE_STATES, CUR_STATE) then setup_level() end
end

function setup_level() MESSAGES = generate_messages(LEVELS[CUR_STATE].messages) end

function generate_messages(messages_meta)
    local messages = {}

    for _, meta in pairs(messages_meta) do
        local message = {}
        message.caller = meta.caller
        message.content = meta.content
        message.receiver = meta.receiver
        message.timestamp = meta.timestamp
        table.insert(messages, message)
    end

    return messages
end

function generate_col()
    return string.char(ASCII_UPPER_A + math.random(1, SWITCHBOARD.N_COLS) - 1)
end

function generate_row() return math.random(1, SWITCHBOARD.N_ROWS) end

function update_mouse()
    local mx, my, md = mouse()

    -- select knob to drag
    if md and KNOB_SELECTED == nil then
        local knob_hovered = get_hovered_knob(mx, my)
        for i = 1, #CALLS do
            if CALLS[i].src == knob_hovered then
                CALL_SELECTED = CALLS[i]
                CALL_SELECTED.state = CALL_STATE.INTERRUPTED
                KNOB_SELECTED = CALL_SELECTED.dst
            elseif CALLS[i].dst == knob_hovered then
                CALL_SELECTED = CALLS[i]
                CALL_SELECTED.state = CALL_STATE.INTERRUPTED
                KNOB_SELECTED = CALL_SELECTED.src
            end
        end
    end

    -- mouse up
    if not md and KNOB_SELECTED ~= nil then on_mouse_up(mx, my, md) end
end

function on_mouse_up(mx, my, md)
    local dst_knob = get_hovered_knob(mx, my)

    local is_same_node = dst_knob ~= nil and dst_knob.x == KNOB_SELECTED.x and
                             dst_knob.y == KNOB_SELECTED.y
    local overlaps = #filter(CALLS, function(call)
        return call.state ~= CALL_STATE.INTERRUPTED and
                   (call.src == dst_knob or call.dst == dst_knob)
    end) > 0

    local message = filter(MESSAGES, function(message)
        return message.src == KNOB_SELECTED
    end)[1]

    if dst_knob == OPERATOR_KNOB and not is_same_node and not overlaps and
        message ~= nil then
        table.insert(CALLS, {
            src = KNOB_SELECTED,
            dst = dst_knob,
            state = CALL_STATE.DISPATCHING
        })
        DISPATCH = message.dst.coords
    elseif dst_knob ~= nil and dst_knob ~= OPERATOR_KNOB and not is_same_node and
        not overlaps then
        table.insert(CALLS, {
            src = KNOB_SELECTED,
            dst = dst_knob,
            state = CALL_STATE.ONGOING,
            message = message,
            duration = 5
        })
    else
        CALL_SELECTED.state = CALL_STATE.ONGOING
        CALL_SELECTED.duration = 5
    end

    CALL_SELECTED, KNOB_SELECTED = nil, nil
end

function get_hovered_knob(mx, my)
    -- check if its hovering the operator knob
    if contains(OPERATOR_KNOB.x, OPERATOR_KNOB.y,
                OPERATOR_KNOB.x + KNOB_WIDTH * KNOB_SCALE,
                OPERATOR_KNOB.y + KNOB_HEIGHT * KNOB_SCALE, mx, my) then
        return OPERATOR_KNOB
    end

    local ranges = filter(KNOBS, function(knob)
        return contains(knob.x, knob.y, knob.x + KNOB_WIDTH * KNOB_SCALE,
                        knob.y + KNOB_HEIGHT * KNOB_SCALE, mx, my)
    end)

    return ifthenelse(#ranges > 0, ranges[1], nil)
end

function contains(x0, y0, x1, y1, x, y)
    local inside_x = x >= x0 and x <= x1
    local inside_y = y >= y0 and y <= y1
    return inside_x and inside_y
end

function get_knob(coord) return KNOBS[get_knob_pos(coord)] end

function get_knob_pos(coord)
    col = string.byte(coord[1]) - ASCII_UPPER_A + 1
    row = tonumber(coord[2])
    return SWITCHBOARD.N_COLS * (row - 1) + col
end

-- draws
function draw()
    cls()
    -- rectb(0, 0, 240, 136, 2)
    draw_switchboard()
    draw_knobs()
    draw_calls()
    draw_timer()

    -- drag knob line
    local mx, my, md = mouse()
    if md and KNOB_SELECTED ~= nil then
        draw_call(KNOB_SELECTED.x + KNOB_WIDTH, KNOB_SELECTED.y + KNOB_HEIGHT,
                  mx, my)
    end

    if DISPATCH ~= nil then print(DISPATCH[1] .. DISPATCH[2], 100, 120, 1) end
    print(MISSED_CALLS, 100, 100, 1)
    print(#MESSAGES, 120, 100, 1)
end

function draw_switchboard()
    -- rectb(2, 2, (SWITCHBOARD.N_COLS * SWITCHBOARD.COL_SPACING) - 8,
    --       SWITCHBOARD.N_ROWS * SWITCHBOARD.ROW_SPACING, 1)
    draw_header()
    draw_sidebar()
end

function draw_header()
    for i = 0, SWITCHBOARD.N_COLS - 1 do
        local x = SWITCHBOARD.X + KNOB_WIDTH - 3 + i * SWITCHBOARD.COL_SPACING
        print(string.char(ASCII_UPPER_A + i), x, 0, 1)
    end
end

function draw_sidebar()
    for i = 0, SWITCHBOARD.N_ROWS - 1 do
        local y = SWITCHBOARD.Y + KNOB_HEIGHT - 3 + i * SWITCHBOARD.ROW_SPACING
        print(i + 1, 0, y, 1)
    end
end

function draw_knobs()
    for i = 1, #KNOBS do
        draw_knob(KNOBS[i])
    end
    draw_knob(OPERATOR_KNOB)
end

function draw_knob(knob)
    local is_blinking = knob.state == KNOB_STATE.INCOMING
    if is_blinking then
        spr(0 + FRAME_COUNTER % 60 // 30 * 2, knob.x, knob.y, -1, KNOB_SCALE)
    elseif knob.state == KNOB_STATE.DISPATCHING then
        spr(3, knob.x, knob.y, -1, KNOB_SCALE)
    elseif knob.state == KNOB_STATE.CONNECTED then
        spr(5, knob.x, knob.y, -1, KNOB_SCALE)
    else
        spr(0, knob.x, knob.y, -1, KNOB_SCALE)
    end
end

function draw_calls()
    for _, call in pairs(CALLS) do
        if call.state ~= CALL_STATE.INTERRUPTED then
            draw_call(call.src.x + KNOB_WIDTH, call.src.y + KNOB_HEIGHT,
                      call.dst.x + KNOB_WIDTH, call.dst.y + KNOB_HEIGHT)
        end
    end
end

function draw_call(x0, y0, x1, y1) line(x0, y0, x1, y1, 1) end

function draw_timer()
    local clock_x = 214
    local clock_y = 119
    local clock_radius = 10

    print("Time Left", clock_x - 14, clock_y - 17, 3, false, 1, true)
    circ(clock_x, clock_y, clock_radius, 1)
    if (FRAME_COUNTER % 60 == 0) then SECONDS_PASSED = SECONDS_PASSED + 1 end

    for i = 0, SECONDS_PASSED, 0.3 do
        line_increment = deg_to_rad(-90 + i * 6)
        line(clock_x, clock_y,
             round(clock_x + clock_radius * math.cos(line_increment)),
             round(clock_y + clock_radius * math.sin(line_increment)), 2)
    end

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

function map(tbl, func)
    local newtbl = {}
    for i, v in pairs(tbl) do newtbl[i] = func(v) end
    return newtbl
end

function filter(tbl, func)
    local newtbl = {}
    for i, v in pairs(tbl) do if func(v) then table.insert(newtbl, v) end end
    return newtbl
end

function deg_to_rad(angle) return angle * math.pi / 180 end

function round(x) return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5) end

-- starts the game
init()

-- <TILES>
-- 000:00ffff000ffeeff0ffeeeefffeeeeedffeeeeedfffeeedff0ffedff000ffff00
-- 001:00ffff000ff22ff0ff2222fff222223ff222223fff2223ff0ff23ff000ffff00
-- 002:00ffff000ff66ff0ff6666fff666665ff666665fff6665ff0ff65ff000ffff00
-- 003:00ffff000ff44ff0ff4444fff444441ff444441fff4441ff0ff41ff000ffff00
-- 004:00ffff000ffffff0ffffffffffffffffffffffffffffffff0ffffff000ffff00
-- 005:00ffff000ff99ff0ff9999fff999998ff999998fff9998ff0ff98ff000ffff00
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

