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
        time = 20,
        max_messages = 20,
        messages = {
            {
                caller = "Shake Spear",
                receiver = "BigZ",
                content = "Hello World",
                timestamp = 2
            }, {
                caller = "Tom Segura",
                receiver = "João Conde",
                content = "Auuuch where is the hospital I played basketball",
                timestamp = 4
            }, {
                caller = "Slim Shady",
                receiver = "Diogo Dores",
                content = "Wazuuuuuuuuuup",
                timestamp = 6
            }
        },
        missed = 0,
        interrupted = 0,
        wrong = 0
    }
}

MESSAGE_POOL = {
    {
        caller = "John Doe #1",
        receiver = "Mary Jane #1",
        content = "Random one liner"
    }, {
        caller = "John Doe #2",
        receiver = "Mary Jane #2",
        content = "Random two liner"
    }, {
        caller = "John Doe #3",
        receiver = "Mary Jane #3",
        content = "Random three liner"
    }, {
        caller = "John Doe #4",
        receiver = "Mary Jane #4",
        content = "Random four liner"
    }, {
        caller = "John Doe #5",
        receiver = "Mary Jane #5",
        content = "Random five liner"
    }, {
        caller = "John Doe #6",
        receiver = "Mary Jane #6",
        content = "Random six liner"
    }, {
        caller = "John Doe #7",
        receiver = "Mary Jane #7",
        content = "Random seven liner"
    }, {
        caller = "John Doe #8",
        receiver = "Mary Jane #8",
        content = "Random eight liner"
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

GRAVITY = 9.8
ROPE_WIDTH = 10

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

function TIC()
    update()
    draw()
end

-- inits
function init()
    CUR_STATE = STATES.MAIN_MENU
    KNOBS = init_knobs()
    CALLS = init_calls()
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
                pickup_timer = 0,
                missed_timer = 0
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
    table.insert(calls, {
        src = KNOBS[1],
        dst = KNOBS[2],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[1], KNOBS[2])
    })
    table.insert(calls, {
        src = KNOBS[5],
        dst = KNOBS[15],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[5], KNOBS[15])
    })
    table.insert(calls, {
        src = KNOBS[8],
        dst = KNOBS[12],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[8], KNOBS[12])
    })
    table.insert(calls, {
        src = KNOBS[9],
        dst = KNOBS[4],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[9], KNOBS[4])
    })

    return calls
end

function create_rope_segments(pos_1, pos_2)
    local diffX = pos_2.x - pos_1.x
    local diffY = pos_2.y - pos_1.y
    local length = math.sqrt(math.pow(diffX, 2), math.pow(diffY, 2))
    -- get more segments, that way there's a bit of flex 
    local num_segments = math.ceil(length / SEGMENTS_LENGTH *
                                       math.random(11, 13) / 10)

    local segments = {}
    for i = 1, num_segments do
        local new_segment = {
            previous = {x = 0, y = 0},
            current = {x = 0, y = 0}
        }
        new_segment.x = pos_1.x + diffX * (i - 1) / (num_segments - 1)
        new_segment.y = pos_1.y + diffY * (i - 1) / (num_segments - 1)

        table.insert(segments, new_segment)
    end

    return segments
end

-- updates
function update()
    FRAME_COUNTER = FRAME_COUNTER + 1

    if has_value(SKIPPABLE_STATES, CUR_STATE) and keyp(Z_KEYCODE) then
        update_state_machine()
    elseif has_value(PLAYABLE_STATES, CUR_STATE) then
        update_mouse()
        update_ropes()
        update_knobs()
        update_calls()
        update_messages()
    end
end

function update_knobs()
    OPERATOR_KNOB.state = KNOB_STATE.OFF
    for _, knob in pairs(KNOBS) do
        if knob.state ~= KNOB_STATE.INCOMING and knob.state ~= KNOB_STATE.MISSED then
            knob.state = KNOB_STATE.OFF
        else
            if (FRAME_COUNTER % 60 == 0) then
                knob.pickup_timer = knob.pickup_timer - 1
                if knob.state == KNOB_STATE.MISSED then
                    if knob.missed_timer ~= 1 then
                        knob.missed_timer = knob.missed_timer + 1
                    else
                        knob.state = KNOB_STATE.OFF
                    end
                end
                if knob.pickup_timer == 0 then
                    LEVELS[CUR_STATE].missed = LEVELS[CUR_STATE].missed + 1
                    knob.state = KNOB_STATE.MISSED
                end
            end
        end
    end
end

function update_calls()
    for _, call in pairs(CALLS) do
        if call.state == CALL_STATE.DISPATCHING then
            call.src.state = KNOB_STATE.DISPATCHING
            call.dst.state = KNOB_STATE.DISPATCHING
        elseif call.state == CALL_STATE.ONGOING and call.src ~= nil and call.dst ~=
            nil then
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
end

function update_messages()
    for _, message in pairs(MESSAGES) do
        if message.timestamp == SECONDS_PASSED and message.processed == nil then
            src_knob = get_available_knob()
            src_knob.state = KNOB_STATE.INCOMING
            src_knob.pickup_timer = 30

            dst_knob = get_available_knob()

            message.src = src_knob
            message.dst = dst_knob
            message.processed = true
        end
    end
end

function update_ropes()
    for i = 1, #CALLS do
        simulate_ropes(CALLS[i])
        for j = 1, 50 do constraint_ropes(CALLS[i]) end
        simulate_ropes(CALLS[i])
    end
end

function simulate_ropes(call)
    for i = 2, #call.rope_segments - 1 do
        call.rope_segments[i].y = call.rope_segments[i].y + GRAVITY / 60
    end
end

function constraint_ropes(call)
    -- first and last points remain untouched, as these 
    -- are the key handles
    local base_y = 20
    for i = 1, #call.rope_segments - 1 do
        -- get points to evaluate
        local current_point = call.rope_segments[i]
        local next_point = call.rope_segments[i + 1]

        -- measure distance between the two points
        local distance = get_distance_between_points(current_point, next_point)
        local diff = math.abs(distance - SEGMENTS_LENGTH)

        -- ignore if distance isn't bigger than specified segments length
        if diff < 0 then break end

        -- get direction of correction vector
        local correction_vector = get_vector_from_points(current_point,
                                                         next_point)
        -- print(get_distance_between_points({x = 0, y = 0}, correction_vector), 50, 50, 3)
        correction_vector.x = correction_vector.x *
                                  ((distance - SEGMENTS_LENGTH) / distance)
        correction_vector.y = correction_vector.y *
                                  ((distance - SEGMENTS_LENGTH) / distance)

        -- correction should be done only by next segment
        if i == 1 then
            next_point.x = next_point.x - correction_vector.x
            next_point.y = next_point.y - correction_vector.y
            -- correction should be done only be second to last segment
        elseif i == #call.rope_segments - 1 then
            current_point.x = current_point.x + correction_vector.x
            current_point.y = current_point.y + correction_vector.y
            -- correction should be split between current and next vector
        else
            current_point.x = current_point.x + correction_vector.x * 0.5
            current_point.y = current_point.y + correction_vector.y * 0.5
            next_point.x = next_point.x - correction_vector.x * 0.5
            next_point.y = next_point.y - correction_vector.y * 0.5
        end

        -- print(i, 10, base_y, 3)
        -- print(correction_vector.x, 20, base_y, 3)
        -- print(correction_vector.y, 130, base_y, 3)

        -- base_y = base_y + 25
        -- trace(i)
        -- trace(correction_vector.x)
        -- trace(correction_vector.y)
    end
end

function get_vector_from_points(p1, p2) return
    {x = p2.x - p1.x, y = p2.y - p1.y} end

function normalize_vector(vec)
    local length = get_distance_between_points({x = 0, y = 0}, vec)
    return {x = vec.x / length, y = vec.y / length}
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

function generate_messages(mandatory_messages)
    local messages = {}

    -- random messages
    for i = 1, LEVELS[CUR_STATE].max_messages do
        local message_spec = MESSAGE_POOL[math.random(1, #MESSAGE_POOL)]
        message_spec.timestamp = math.random(3, LEVELS[CUR_STATE].time)
        local message = build_message(message_spec)
        table.insert(messages, message)
    end

    -- guarantee they appears in the first 10
    local indices = map(mandatory_messages,
                        function(_m) return math.random(1, 10) end)
    indices = unique_indices(indices)

    for i, message_spec in pairs(mandatory_messages) do
        local message = build_message(message_spec)
        table.insert(messages, indices[i], message)
    end

    return messages
end

function unique_indices(list)
    table.sort(list)
    local newlist = {}
    for _, v in pairs(list) do
        if has_value(newlist, v) then
            table.insert(newlist, v + 1)
        else
            table.insert(newlist, v)
        end
    end
    return newlist
end

function build_message(spec)
    local message = {}
    message.caller = spec.caller
    message.content = spec.content
    message.receiver = spec.receiver
    message.timestamp = spec.timestamp
    return message
end

function generate_col()
    return string.char(ASCII_UPPER_A + math.random(1, SWITCHBOARD.N_COLS) - 1)
end

function generate_row() return math.random(1, SWITCHBOARD.N_ROWS) end

function update_mouse()
    local mx, my, md = mouse()

    -- select knob to drag
    if md and KNOB_PIVOT == nil then
        local knob_hovered = get_hovered_knob(mx, my)
        for i = 1, #CALLS do
            if CALLS[i].src == knob_hovered then
                CALL_SELECTED = CALLS[i]
                if CALL_SELECTED.state == CALL_STATE.ONGOING then
                    CALL_SELECTED.state = CALL_STATE.UNUSED
                    LEVELS[CUR_STATE].interrupted = LEVELS[CUR_STATE]
                                                        .interrupted + 1
                end
                KNOB_PIVOT = CALL_SELECTED.dst
            elseif CALLS[i].dst == knob_hovered then
                CALL_SELECTED = CALLS[i]
                if CALL_SELECTED.state == CALL_STATE.ONGOING then
                    CALL_SELECTED.state = CALL_STATE.UNUSED
                    LEVELS[CUR_STATE].interrupted = LEVELS[CUR_STATE]
                                                        .interrupted + 1
                end
                KNOB_PIVOT = CALL_SELECTED.src
            end
        end
    elseif md and KNOB_PIVOT ~= nil and CALL_SELECTED ~= nil then
        if KNOB_PIVOT == CALL_SELECTED.dst then
            CALL_SELECTED.rope_segments[1].x = mx - KNOB_WIDTH
            CALL_SELECTED.rope_segments[1].x = mx - KNOB_WIDTH
            CALL_SELECTED.rope_segments[1].y = my - KNOB_HEIGHT
            CALL_SELECTED.rope_segments[1].y = my - KNOB_HEIGHT
        else
            local num_segments = #CALL_SELECTED.rope_segments
            CALL_SELECTED.rope_segments[num_segments].x = mx - KNOB_WIDTH
            CALL_SELECTED.rope_segments[num_segments].x = mx - KNOB_WIDTH
            CALL_SELECTED.rope_segments[num_segments].y = my - KNOB_HEIGHT
            CALL_SELECTED.rope_segments[num_segments].y = my - KNOB_HEIGHT
        end
    end

    -- mouse up
    if not md and KNOB_PIVOT ~= nil then on_mouse_up(mx, my, md) end
end

function on_mouse_up(mx, my, md)
    local dst_knob = get_hovered_knob(mx, my)

    local is_same_node = dst_knob ~= nil and dst_knob.x == KNOB_PIVOT.x and
                             dst_knob.y == KNOB_PIVOT.y
    local overlaps = #filter(CALLS, function(call)
        return call.state ~= CALL_STATE.INTERRUPTED and
                   (call.src == dst_knob or call.dst == dst_knob)
    end) > 0

    local message = filter(MESSAGES, function(message)
        return message.src == KNOB_PIVOT
    end)[1]

    if dst_knob == OPERATOR_KNOB and not is_same_node and not overlaps and
        message ~= nil then
        local index = 1
        for i = 1, #CALLS do
            if CALLS[i].dst == KNOB_PIVOT or CALLS[i].src == KNOB_PIVOT then
                index = i
                break
            end
        end
        CALL_SELECTED.rope_segments[1] = {x = KNOB_PIVOT.x, y = KNOB_PIVOT.y}
        CALL_SELECTED.rope_segments[#CALL_SELECTED.rope_segments] = {
            x = dst_knob.x,
            y = dst_knob.y
        }
        local previous_rope_segments = CALL_SELECTED.rope_segments

        table.remove(CALLS, index)
        table.insert(CALLS, {
            src = KNOB_PIVOT,
            dst = dst_knob,
            state = CALL_STATE.DISPATCHING,
            rope_segments = previous_rope_segments,
            message = message
        })
        DISPATCH = message.dst.coords
    elseif dst_knob ~= nil and dst_knob ~= OPERATOR_KNOB and CALL_SELECTED.dst ~=
        OPERATOR_KNOB and not is_same_node and not overlaps then
        local index = 1
        for i = 1, #CALLS do
            if CALLS[i].dst == KNOB_PIVOT or CALLS[i].src == KNOB_PIVOT then
                index = i
                break
            end
        end

        CALLS[index].rope_segments[1] = {x = KNOB_PIVOT.x, y = KNOB_PIVOT.y}
        CALLS[index].rope_segments[#CALLS[index].rope_segments] = {
            x = dst_knob.x,
            y = dst_knob.y
        }
        local previous_rope_segments = CALLS[index].rope_segments

        table.remove(CALLS, index)
        table.insert(CALLS, {
            src = KNOB_PIVOT,
            dst = dst_knob,
            state = CALL_STATE.UNUSED,
            message = message,
            rope_segments = previous_rope_segments
        })
    elseif not is_same_node then
        if CALL_SELECTED.message ~= nil then
            local expected = CALL_SELECTED.message.dst.coords
            local actual = dst_knob.coords
            if expected ~= actual then
                LEVELS[CUR_STATE].wrong = LEVELS[CUR_STATE].wrong + 1
                CALL_SELECTED.state = CALL_STATE.UNUSED
                CALL_SELECTED.src.state = KNOB_STATE.OFF
                CALL_SELECTED.dst.state = KNOB_STATE.OFF
            else
                CALL_SELECTED.state = CALL_STATE.ONGOING
                CALL_SELECTED.duration = 5
            end
        end
        CALL_SELECTED.dst = dst_knob
        DISPATCH = nil
    end

    CALL_SELECTED, KNOB_PIVOT = nil, nil
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
    -- rectb(0, 0, 240, 136, 2)
    cls()
    if has_value(PLAYABLE_STATES, CUR_STATE) then
        draw_game()
    elseif (CUR_STATE == STATES.MAIN_MENU) then
        draw_main_menu()
    end
end

function draw_game()
    draw_switchboard()
    draw_knobs()
    draw_calls()
    draw_timer()

    if DISPATCH ~= nil then print(DISPATCH[1] .. DISPATCH[2], 100, 120, 1) end
    print(LEVELS[CUR_STATE].missed, 100, 100, 1)
    print(LEVELS[CUR_STATE].interrupted, 120, 100, 1)
    print(LEVELS[CUR_STATE].wrong, 140, 100, 1)
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
    for i = 1, #KNOBS do draw_knob(KNOBS[i]) end
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
    elseif knob.state == KNOB_STATE.MISSED then
        spr(1, knob.x, knob.y, -1, KNOB_SCALE)
    else
        spr(0, knob.x, knob.y, -1, KNOB_SCALE)
    end
end

function draw_calls()
    for _, call in pairs(CALLS) do
        -- if call.state ~= CALL_STATE.INTERRUPTED then
        draw_call(call)
        -- end
    end
end

function draw_call(call)
    for i = 1, #call.rope_segments - 1 do
        current_point = call.rope_segments[i]
        next_point = call.rope_segments[i + 1]
        line(current_point.x + KNOB_WIDTH, current_point.y + KNOB_HEIGHT,
             next_point.x + KNOB_WIDTH, next_point.y + KNOB_HEIGHT, 1)
    end
end

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

function draw_main_menu() print("Main Menu") end

-- utils
function has_value(tab, val)
    for _i, value in ipairs(tab) do if value == val then return true end end
    return false
end

function get_distance_between_points(p1, p2)
    return math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2))
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
-- 001:01234566666666666666666666543210
-- 002:01234566666666666666666789abcdef
-- 003:000111234579aceffeca975432111000
-- 004:00123456789abcdeedcba98765432100
-- 006:323344c667778990aabbbbc5ccdddded
-- 007:544333478999bcccccccba9997654445
-- </WAVES>

-- <SFX>
-- 000:0500350065008500b500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f50040b000000000
-- 001:0500150025003500450045005500550065007500850095009500a500a500b500c500c500c500d500e500f500f500f500f500f500f500f500f500f500209000000000
-- 002:d30073001300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300209000000000
-- 003:02000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020020b000000000
-- 004:02000200120012002200320042004200520062007200720082009200a200b200b200c200d200e200e200f200f200f200f200f200f200f200f200f200307000000000
-- 005:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400407000000000
-- 006:030013001300130033003300430043005300630073007300830083009300a300b300b300c300d300e300e300f300f300f300f300f300f300f300f300003000000000
-- 007:13002300330053006300730083009300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300307000080000
-- 008:0400040004000400040004000400040004001400140014002400240034004400440054005400540064006400740074008400840084009400a400a400404000000000
-- 009:060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600382000000000
-- 010:d6008600060006000600060006000600060006000600060006001600260026004600560066007600b600b600b600d600e600f600f600f600f600f60030b000000000
-- 011:0400040004000400040004000400040004000400140014002400240034003400440044005400540064006400740084009400a400b400c400d400f400304000000000
-- 012:170057009700d700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f70040b000040000
-- </SFX>

-- <PATTERNS>
-- 000:47710200000040000240000e00000040000e40001e00000000000040000e00000040000e40001e00000000000040000e00000040000e40001e00000000000040000e40000a40000440000200000040000240000e00000040000e40001e00000000000040000e00000040000e40001e00000000000040000200000040000800000040000600000040000400000040000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:4f7126012400400028800028400026000000b00028900028400026000000400028800028400026000000000000000000900026000000000000000000c00026000000d00028000000400026000000000000000000600026000000600028800028900028000000000000000000c000280000000000000000004000260ff1000dd1000bb100099100077100055100033100011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:899126012400000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00026000000000000000000f00026000000000000000000800026000000000000000000a00028000000000000000000d0002800000000000000000040002a0000000000000000008000260ff1000dd1000bb100099100077100055100033100011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:b7f126012400000000000000900026000000000000000000b00026000000000000000000900026000000000000000000400028000000000000000000000000000000000000000000b00026000000000000000000d0002800000000000000000040002a00000000000000000060002a000000000000000000b396280ff1000dd1000bb100099100077100055100033100011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:f12426000000000000000000d00026000000000000000000f00026000000000000000000d00026000000000000000000800028000000000000000000000000000000000000000000b00028000000400028b0002840002a00000000000000000080002a000000000000000000b0002a00000090002a000000f396280ff1000dd1000bb10049912a077100055100033100011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:4fa126000000000000000000000000000000000000000000000000400026000000000000000000000000000000000000000000000000000000000000000000000000000000000000900024000000000000000000000000000000000000000000000000400026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:7af126000000000000000000000000000000000000000000000000700026000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00026000000000000000000000000000000000000000000000000700026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:baa126000000000000000000000000000000000000000000000000c00026000000000000000000000000000000000000000000000000000000000000000000000000000000000000400026000000000000000000000000000000000000000000000000c00026000000000000000000000000000000000000000000000000700028000000000000600028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:baa136024600000000000000000000000000000000000000000000928036000000000000000000000000000000000000000000000000700036000000900036a00036900036700036400036000000000000000000000000000000a00036100000a00036000000000000000000700036100000000000000000000000000000e00036100000e00036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:4aa138024600000000000000000000000000000000000000000000e00036000000000000000000000000000000000000000000000000400038000000600038700038600038400038600038000000000000400038000000000000b00038000000000000900038000000000000700038000000000000400038000000000000600038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:7fc164000000400064000000400064000000400064000000400064a00066000000000000700064000000400064000000400064000000400064000000400064900066000000000000700064000000400064000000400064000000400064000000400064400066000000400064000000400064400064400064400064400064400064400064400064400064400064400064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:4af156000000000000000000e16458000000000000000000000000000000000000000000d00058000000000000000000000000000000000000000000900058000000000000000000700058000000000000000000000000000000000000000000900058000000000000000000800058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:400008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:4fa174000000700076000000b000760000004fa074000000700076000000b00074000000f00076000000600078000000b00074000000f00076000000c00074000000c00076000000400078000000c00074000000c00076000000700076000000b00076000000e00076000000600076000000b00076000000f00076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:45510200000040000440000a00000040000440000a00000040000040000040000800000040000440001a00000040000440001a00000040000a40000640000000000040000440001a00000040000200000040000240000240000a00000040000240000200000040000440000a40000600000040001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:baf178003400400078400078400078000000000000000000700078900078b00078000000f28078000000000000000000b0007a000000000000000000c0007a90007a40007a000000700078000000000000000000b0007a70007ab0007800000070007a00000000000000000060007a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:40000800000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e000000000000000000000000400008000000
-- 017:4f810800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e00000000000000000000000040000800000000000040000e00000040001e000000000000000000000000000000000000000000000000
-- 018:48f124000000000000000000000000800024000000000000000000000000b00024000000000000000000000000d00024000000000000000000b00024e00024000000000000000000000000d00024000000000000000000000000b00024000000000000000000000000800024000000000000000000000000b00022000000000000000000000000000000000000000000000000000000600024000000000000000000000000a00024000000000000000000000000000000000000000000000000
-- 019:424648000000000000000000000000800048000000000000000000000000b00048000000000000000000000000d00048000000000000000000000000e00048000000000000000000000000d00048000000000000000000000000b00048d00048000000b00048000000800048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:98f124000000000000000000000000d00024000000000000000000000000400024000000000000000000000000600024000000000000000000400024700024000000000000000000000000600024000000000000000000000000400024000000000000000000000000d00022000000000000000000000000b00002000000000000000000000000000000000000000000000000000000600004000000000000000000000000a00004000000000000000000000000000000000000000000000000
-- 021:90004800000000000000000000000070004a00000000000070004a000000000000000000000000000000000000000000000000000000000000000000600046000000000000000000000000600048000000000000600048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:00000000000000000000000000000090004a00000000000090004a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00048000000000000c00048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:7fa146000000000000000000000000700046000000000000000000000000700046000000000000000000000000700046000000000000000000000000900046000000000000000000000000900046000000000000000000000000900046000000000000000000000000900046000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:baf148000000000000000000000000b00048000000000000000000000000b00048000000000000000000000000b00048000000000000000000000000d00048000000000000000000000000d00048000000000000000000000000400048000000000000000000000000d00048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:68f12400000000000000000000000068f02400000000000000000000000068f02400000000000000000000000068f024000000000000000000000000900024000000000000000000000000900024000000000000000000000000900024000000000000000000000000900024000000000000000000000000b00022000000000000000000000000000000000000000000000000000000600024000000000000000000000000a00024000000000000000000000000000000000000000000000000
-- 026:7fa146000000700046600046000000700046000000700046600046000000700046000000700046600046000000700046000000700046600046000000900046000000900046600046000000900046000000900046600046000000d00046000000900048d00048000000900046000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:baf148000000000000000000000000b00048000000000000000000000000b00048000000000000000000000000b00048000000000000000000000000d00048000000000000000000000000d00048000000000000000000000000400048000000000000000000000000d00048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:48f124000000000000700026000000b8f026000000000000000000000000900024000000000000600026000000700026000000000000000000000000400024000000000000700026000000b8f026000000000000000000000000d00026000000000000700026000000600026700026600026000000000000000000000000000000000000000000000000000000000000000000600024000000000000000000000000a00024000000000000000000000000000000000000000000000000000000
-- 029:4000a60000004000a87000a80000000000000000000000000000000000004000a60000009000a6d000a600000000000000000000000000000000000076f0a6000000b000a66000a60000000000000000000000000000000000009000a60000007220a66000a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:4000a60000004000a87000a80000000000000000000000000000000000004991a60000009000a6d000a60000000000000000000000000000000000007661a6000000b000a66000a60000000000000000000000000000000000009000a60000007221a66000a6000000000000000000000000000000010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:400064000000700064000000600064000000500064000000400064000000000000000000b00064000000000000000000000000000000400064000000400064000000000000000000b00064000000000000000000000000000000900064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:000000000000000000000000000000000000000000000000413436024600000000000000000000000000000000000000000000000000000000000000e00036000000000000000000000000000000000000000000000000d00036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:000000000000000000000000000000000000000000000000b13438024600000000000000000000000000000000000000000000000000000000000000e00038000000000000000000000000000000000000000000000000900038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 035:0000000000000000000000000000000000000000000000004000ca0000001000000000004000ca0000000000000000000000000000001000000000004000ca0000001000000000004000ca0000000000000000000000009000ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 036:400066000000700066000000600066000000500066000000400066000000000000000000b00066000000000000000000000000400066000000400066000000000000000000b00066000000000000000000000000000000d00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 037:0000000000000000000000000000000000000000000000007000ca0000001000000000007000ca0000000000000000000000000000001000000000007000ca0000000000000000007000ca0000000000000000000000006000ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:00000000000000000000000000000000000000000000000040001e00000000000000000000000000000040000e00000040000e00000000000000000040001e00000000000000000000000000000040000e00000040000e00000000000000000040001e00000000000000000000000000000040000e00000040000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:000000000000000000000000000000000000000000012400400036000000000000000000000000000000000000000000000000700038000000000000000000000000000000000000000000000000000000000000000000600038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:000000000000000000000000000000000000000000012400700038000000000000000000000000000000000000000000000000b00038000000000000000000000000000000000000000000000000000000000000000000900038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:2c0441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000abc001
-- 001:0817021817021818421818821c20001c2c000000000000000000000000000000000000000000000000000000000000002e0100
-- 002:e00000ec3000ec3010000010ec30000000000000000000000000000000000000000000000000000000000000000000002e8100
-- 003:2100002d40002d40002d44102d44102556d52d4410296856296b56296b17047000257000257e102d40200c40000000002e81ef
-- 004:1200005200c91296e952a9e9000000000000000000000000000000000000000000000000000000000000000000000000ec01ef
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2cffa559b13e53d67571ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

