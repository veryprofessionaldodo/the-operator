-- title:  The Operator
-- author: Team "It's about drive"
-- desc:   RetroJam 2022 organized by IEEE UP SB
-- script: lua
STATES = {
    MAIN_MENU = 'main_menu',
    CUTSCENE_ZERO_1 = 'cutscene_zero_1',
    CUTSCENE_ZERO_2 = 'cutscene_zero_2',
    CUTSCENE_ZERO_3 = 'cutscene_zero_3',
    CUTSCENE_ZERO_4 = 'cutscene_zero_4',
    LEVEL_ONE = 'level_one',
    CUTSCENE_THIEF_1 = 'cutscene_thief_1',
    CUTSCENE_THIEF_2 = 'cutscene_thief_2',
    CUTSCENE_THIEF_3 = 'cutscene_thief_3',
    CUTSCENE_THIEF_4 = 'cutscene_thief_4',
    SELECT_MENU_1 = "select_menu_1",
    LEVEL_TWO = "level_two",
    SELECT_MENU_2 = "select_menu_2",
    CUTSCENE_NEWS = "cutscene_news",
    CUTSCENE_FINAL = "cutscene_final"
}

SKIPPABLE_STATES = {
    STATES.MAIN_MENU, STATES.CUTSCENE_ZERO_1, STATES.CUTSCENE_ZERO_2,
    STATES.CUTSCENE_ZERO_3, STATES.CUTSCENE_ZERO_4, STATES.CUTSCENE_THIEF_1,
    STATES.CUTSCENE_THIEF_2, STATES.CUTSCENE_THIEF_3, STATES.CUTSCENE_THIEF_4,
    STATES.CUTSCENE_NEWS, STATES.CUTSCENE_FINAL
}

PLAYABLE_STATES = {STATES.LEVEL_ONE, STATES.LEVEL_TWO}

CUR_STATE = STATES.MAIN_MENU

SELECT_MENU = {selected = 0, options = {}}

TIMEOUT = 60
LEVELS = {
    level_zero = {time = 30, max_messages = 5},
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
        }
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
        }
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
        }
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
        }
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

function TIC()
    update()
    draw()
end

-- inits
function init()
    reset()
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
        src = KNOBS[9],
        dst = KNOBS[4],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[9], KNOBS[4])
    })
    table.insert(calls, {
        src = KNOBS[3],
        dst = KNOBS[13],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[3], KNOBS[13])
    })
    table.insert(calls, {
        src = KNOBS[6],
        dst = KNOBS[24],
        state = CALL_STATE.UNUSED,
        rope_segments = create_rope_segments(KNOBS[6], KNOBS[24])
    })

    return calls
end

function reset()
    music(4)

    -- reset state
    CUR_STATE = STATES.MAIN_MENU

    -- reset counters
    for _, level in pairs(LEVELS) do
        level.missed = 0
        level.interrupted = 0
        level.wrong = 0
        level.solution = nil
    end
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

        -- timeout go next
        if SECONDS_PASSED == TIMEOUT then update_state_machine() end
    elseif has_value({STATES.SELECT_MENU_1, STATES.SELECT_MENU_2}, CUR_STATE) then
        update_select_menu()
    end
end

function update_select_menu()
    if keyp(DOWN_KEYCODE) then
        SELECT_MENU.selected = (SELECT_MENU.selected + 1) % 3
    elseif keyp(UP_KEYCODE) then
        SELECT_MENU.selected = (SELECT_MENU.selected - 1) % 3
    elseif keyp(Z_KEYCODE) then
        update_state_machine()
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
                    sfx(18, 30, -1, 3, 6)
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
            if src_knob == nil then break end

            src_knob.state = KNOB_STATE.INCOMING
            src_knob.pickup_timer = 30

            dst_knob = get_available_knob()
            sfx(13, 60, 18, 3, 6)

            message.src = src_knob
            message.dst = dst_knob
            message.content = message.content:gsub("@receiver",
                                                   dst_knob.coords[1] ..
                                                       dst_knob.coords[2])
            message.processed = true

            if message.solution then
                LEVELS[CUR_STATE].solution = message.dst.coords
                local first_option = LEVELS[CUR_STATE].solution
                local second_option = generate_unique_coord({first_option})
                local third_option = generate_unique_coord({
                    first_option, second_option
                })
                SELECT_MENU.options = {
                    first_option[1] .. first_option[2],
                    second_option[1] .. second_option[2],
                    third_option[1] .. third_option[2]
                }
            end
        end
    end
end

function generate_unique_coord(coords)
    local cols = map(coords, function(coord) return coord[1] end)
    local col = generate_col()
    while has_value(cols, col) do col = generate_col() end

    local rows = map(coords, function(coord) return coord[2] end)
    local row = generate_row()
    while has_value(rows, row) do row = generate_row() end

    return {col, row}
end

function update_ropes()
    -- if not (FRAME_COUNTER % 20 == 0) then return end
    for i = 1, #CALLS do
        simulate_ropes(CALLS[i])
        for j = 1, 50 do constraint_ropes(CALLS[i]) end
    end
end

function simulate_ropes(call)
    for i = 2, #call.rope_segments - 1 do
        call.rope_segments[i].y = call.rope_segments[i].y + GRAVITY / 5
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
    if #usable_knobs == 0 then return nil end
    local index = math.random(1, #usable_knobs)
    return usable_knobs[index]
end

function update_state_machine()
    -- stops all SFX
    sfx(-1)

    -- advances state machine to next state
    -- may run additional logic in between
    if CUR_STATE == STATES.MAIN_MENU then
        CUR_STATE = STATES.CUTSCENE_ZERO_1
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_1 then
        CUR_STATE = STATES.CUTSCENE_ZERO_2
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_2 then
        CUR_STATE = STATES.CUTSCENE_ZERO_3
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_3 then
        CUR_STATE = STATES.CUTSCENE_ZERO_4
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_4 then
        music(3)
        CUR_STATE = STATES.LEVEL_ONE
    elseif CUR_STATE == STATES.LEVEL_ONE then
        sfx(13, 60, 18, 3, 6)
        music(1)
        CUR_STATE = STATES.CUTSCENE_THIEF_1
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_1 then
        CUR_STATE = STATES.CUTSCENE_THIEF_2
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_2 then
        CUR_STATE = STATES.CUTSCENE_THIEF_3
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_3 then
        CUR_STATE = STATES.CUTSCENE_THIEF_4
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_4 then
        CUR_STATE = STATES.SELECT_MENU_1
    elseif CUR_STATE == STATES.SELECT_MENU_1 then
        music(3)
        LEVELS.level_one.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.LEVEL_TWO
    elseif CUR_STATE == STATES.LEVEL_TWO then
        CUR_STATE = STATES.SELECT_MENU_2
    elseif CUR_STATE == STATES.SELECT_MENU_2 then
        LEVELS.level_two.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.CUTSCENE_NEWS
    elseif CUR_STATE == STATES.CUTSCENE_NEWS then
        CUR_STATE = STATES.CUTSCENE_FINAL
    else
        init()
    end

    if has_value(PLAYABLE_STATES, CUR_STATE) then setup_level() end
end

function setup_level()
    MESSAGES = generate_messages(LEVELS[CUR_STATE].messages)
    SECONDS_PASSED = 0
end

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
    local limit = math.min(#messages, 10)
    local indices = map(mandatory_messages,
                        function(_m) return math.random(1, limit) end)
    indices = unique_indices(indices)

    for i, message_spec in pairs(mandatory_messages) do
        local message = build_message(message_spec)
        table.insert(messages, indices[i], message)
    end

    -- DEBUG
    -- for _, v in pairs(messages) do
    --     trace(v.content)
    -- end

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
    message.solution = ifthenelse(spec.solution ~= nil, spec.solution, false)
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
                    sfx(17, 40, -1, 3, 15)
                end
                KNOB_PIVOT = CALL_SELECTED.dst
            elseif CALLS[i].dst == knob_hovered then
                CALL_SELECTED = CALLS[i]
                if CALL_SELECTED.state == CALL_STATE.ONGOING then
                    CALL_SELECTED.state = CALL_STATE.UNUSED
                    LEVELS[CUR_STATE].interrupted = LEVELS[CUR_STATE]
                                                        .interrupted + 1
                    sfx(17, 40, -1, 3, 15)
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

function reset_call_segments(call)
    call.rope_segments[1] = {x = call.src.x, y = call.src.y}
    call.rope_segments[#call.rope_segments] = {x = call.dst.x, y = call.dst.y}
end

function on_mouse_up(mx, my, md)
    local dst_knob = get_hovered_knob(mx, my)

    -- reset position in case no knob was discovered
    if dst_knob == nil then
        reset_call_segments(CALL_SELECTED)
        CALL_SELECTED, KNOB_PIVOT = nil, nil
        return
    end

    local selected_src = KNOB_PIVOT.x == CALL_SELECTED.dst.x and KNOB_PIVOT.y ==
                             CALL_SELECTED.dst.y
    local selected_dst = KNOB_PIVOT.x == CALL_SELECTED.src.x and KNOB_PIVOT.y ==
                             CALL_SELECTED.src.y
    -- it can't be the same as the current source or destination
    local is_same_node = (dst_knob.x == CALL_SELECTED.src.x and dst_knob.y ==
                             CALL_SELECTED.src.y) or
                             (dst_knob.x == CALL_SELECTED.dst.x and dst_knob.y ==
                                 CALL_SELECTED.dst.y)

    if is_same_node then
        reset_call_segments(CALL_SELECTED)
        CALL_SELECTED, KNOB_PIVOT = nil, nil
        return
    end

    local overlaps = #filter(CALLS, function(call)
        return call.state ~= CALL_STATE.INTERRUPTED and
                   (call.src == dst_knob or call.dst == dst_knob)
    end) > 0

    if overlaps then
        reset_call_segments(CALL_SELECTED)
        CALL_SELECTED, KNOB_PIVOT = nil, nil
        return
    end

    local message = filter(MESSAGES, function(message)
        return message.src == KNOB_PIVOT
    end)[1]

    -- incorrect connection with operator, ignore
    if (dst_knob == OPERATOR_KNOB or KNOB_PIVOT == OPERATOR_KNOB) and message ==
        nil then
        CALL_SELECTED.src = KNOB_PIVOT
        CALL_SELECTED.dst = dst_knob

        CALL_SELECTED.state = CALL_STATE.UNUSED
        reset_call_segments(CALL_SELECTED)
        return
    end

    -- is connecting to operator, with a valid message
    if (dst_knob == OPERATOR_KNOB or KNOB_PIVOT == OPERATOR_KNOB) and message ~= nil then
        -- local previous_rope_segments = CALL_SELECTED.rope_segments
        CALL_SELECTED.src = KNOB_PIVOT
        CALL_SELECTED.dst = dst_knob
        reset_call_segments(CALL_SELECTED)
        CALL_SELECTED.state = CALL_STATE.DISPATCHING
        CALL_SELECTED.message = message
        DISPATCH = message
        sfx(14, 48, -1, 3, 15)
    elseif dst_knob ~= OPERATOR_KNOB and CALL_SELECTED.dst ~= OPERATOR_KNOB then
        local index = 1
        for i = 1, #CALLS do
            if CALLS[i].dst == KNOB_PIVOT or CALLS[i].src == KNOB_PIVOT then
                index = i
                break
            end
        end

        CALLS[index].src = KNOB_PIVOT
        CALLS[index].dst = dst_knob
        reset_call_segments(CALLS[index])
        CALLS[index].state = CALL_STATE.UNUSED
        CALLS[index].message = message
    else
        -- everything is correct, it's now an ongoing call
        -- if selected_src then CALL_SELECTED.src = dst_knob end
        -- if selected_dst then CALL_SELECTED.dst = dst_knob end

        if CALL_SELECTED.message ~= nil then
            local expected = CALL_SELECTED.message.dst.coords
            local actual = dst_knob.coords
            if expected ~= actual then
                LEVELS[CUR_STATE].wrong = LEVELS[CUR_STATE].wrong + 1
                CALL_SELECTED.state = CALL_STATE.UNUSED
                CALL_SELECTED.src.state = KNOB_STATE.OFF
                CALL_SELECTED.dst.state = KNOB_STATE.OFF
                sfx(17, 61, -1, 3, 15)
            else
                CALL_SELECTED.state = CALL_STATE.ONGOING
                CALL_SELECTED.duration = 5
                sfx(16, 60, -1, 3, 15)
            end
        end
        CALL_SELECTED.dst = dst_knob

        reset_call_segments(CALL_SELECTED)
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
    elseif (CUR_STATE == STATES.CUTSCENE_ZERO_1) then
        draw_cutscene_zero_one()
    elseif (CUR_STATE == STATES.CUTSCENE_ZERO_2) then
        draw_cutscene_zero_two()
    elseif (CUR_STATE == STATES.CUTSCENE_ZERO_3) then
        draw_cutscene_zero_three()
    elseif (CUR_STATE == STATES.CUTSCENE_ZERO_4) then
        draw_cutscene_zero_four()
    elseif (CUR_STATE == STATES.CUTSCENE_THIEF_1) then
        draw_cutscene_thief_one()
    elseif (CUR_STATE == STATES.CUTSCENE_THIEF_2) then
        draw_cutscene_thief_two()
    elseif (CUR_STATE == STATES.CUTSCENE_THIEF_3) then
        draw_cutscene_thief_three()
    elseif (CUR_STATE == STATES.CUTSCENE_THIEF_4) then
        draw_cutscene_thief_four()
    elseif has_value({STATES.SELECT_MENU_1, STATES.SELECT_MENU_2}, CUR_STATE) then
        draw_select_menu()
    elseif (CUR_STATE == STATES.CUTSCENE_NEWS) then
        draw_cutscene_news()
    elseif (CUR_STATE == STATES.CUTSCENE_FINAL) then
        draw_cutscene_final()
    end
end

function draw_game()
    draw_switchboard()
    draw_footer()
    draw_knobs()
    draw_calls()
    draw_timer()

    if DISPATCH ~= nil then
        local coords = DISPATCH.dst.coords
        local message = DISPATCH.content
        -- print(coords[1] .. coords[2], 80, 120, 1)
        draw_receiving_call(message)
    end
    -- print(LEVELS[CUR_STATE].missed, 100, 100, 1)
    -- print(LEVELS[CUR_STATE].interrupted, 120, 100, 1)
    -- print(LEVELS[CUR_STATE].wrong, 140, 100, 1)

    -- local coords = LEVELS[CUR_STATE].solution
    -- if coords ~= nil then print(coords[1] .. coords[2], 80, 100, 1) end
end

function draw_receiving_call(message)
    if #message > 86 then
        print(string.sub(message, 0, 43), 45, 105, TEXT_COLOR, false, 1, true)
        print(string.sub(message, 44, 86), 45, 115, TEXT_COLOR, false, 1, true)
        print(string.sub(message, 87, #message), 45, 125, TEXT_COLOR, false, 1, true)
    elseif #message > 43 then
        print(string.sub(message, 0, 43), 45, 115, TEXT_COLOR, false, 1, true)
        print(string.sub(message, 44, #message), 45, 125, TEXT_COLOR, false, 1, true)
    else
        print(message, 45, 120, TEXT_COLOR, false, 1, true)
    end
end

function draw_footer()
		spr(464, 0, 100, 6, 2, 0, 0, 15, 3)
end

function draw_switchboard()
    -- rectb(2, 2, (SWITCHBOARD.N_COLS * SWITCHBOARD.COL_SPACING) - 8,
    --       SWITCHBOARD.N_ROWS * SWITCHBOARD.ROW_SPACING, 1)
    spr(7, 35, 0, 0, 1, 0, 0, 1, 15)
    spr(7, 69, 0, 0, 1, 0, 0, 1, 15)
    spr(7, 102, 0, 0, 1, 0, 0, 1, 15)
    spr(7, 137, 0, 0, 1, 0, 0, 1, 15)
    spr(7, 170, 0, 0, 1, 0, 0, 1, 15)
    spr(7, 205, 0, 0, 1, 0, 0, 1, 15)
    
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
        spr(0 + FRAME_COUNTER % 60 // 30 * 2, knob.x, knob.y, 11, KNOB_SCALE)
    elseif knob.state == KNOB_STATE.DISPATCHING then
        spr(3, knob.x, knob.y, 11, KNOB_SCALE)
    elseif knob.state == KNOB_STATE.CONNECTED then
        spr(5, knob.x, knob.y, 3, KNOB_SCALE)
    elseif knob.state == KNOB_STATE.MISSED then
        spr(1, knob.x, knob.y, 11, KNOB_SCALE)
    else
        spr(0, knob.x, knob.y, 11, KNOB_SCALE)
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
    local clock_x = 215
    local clock_y = 120
    local clock_radius = 10

	spr(12, 200, 105, 5,1,0,0,4,4 )

    circ(clock_x, clock_y, clock_radius, 12)
    if (FRAME_COUNTER % 60 == 0) then SECONDS_PASSED = SECONDS_PASSED + 1 end

    for i = 0, SECONDS_PASSED, 0.3 do
        line_increment = deg_to_rad(-90 + i * 6)
        line(clock_x, clock_y,
             round(clock_x + clock_radius * math.cos(line_increment)),
             round(clock_y + clock_radius * math.sin(line_increment)), 4)
    end
    
   
end

function draw_main_menu() 
    print("The", 20, 40, 12, true, 2) 
    print("Operator", 20, 70, 12, true, 2)
    spr(154, 130, 20, 1, 2,0,0, 5, 6)
end

function draw_select_menu()
    print("Select one with arrows", 0, 10, 1)
    for i, option in pairs(SELECT_MENU.options) do
        if i == SELECT_MENU.selected + 1 then print(">", 110, 25 * i, 1) end
        print(option, 120, 25 * i, 1)
    end
end

function draw_cutscene_zero_one()
    text_height = 45
    print("Miss Nicole Tangle, am I correct?", TEXT_X_SHIFT, text_height,
          TEXT_COLOR)
    print("What's shaken?", TEXT_X_SHIFT, text_height + LINE_HEIGHT, TEXT_COLOR)
    print("Welcome here to your first training", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("on how to operate this ritzie", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("new switchboard!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 4,
          TEXT_COLOR)
end

function draw_cutscene_zero_two()
    text_height = 40
    print("First of all, whenever you see a", TEXT_X_SHIFT, text_height,
          TEXT_COLOR)
    print("blinking green knob, that means", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT, TEXT_COLOR)
    print("you've got a call!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 2,
          TEXT_COLOR)
    print("If there's no cable connected to", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("that knob, just grab a free one", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 4, TEXT_COLOR)
    print("on your board and put'it there!", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 5, TEXT_COLOR)
end

function draw_cutscene_zero_three()
    text_height = 35
    print("After that you'll just have to grab", TEXT_X_SHIFT, text_height,
          TEXT_COLOR)
    print("the other end of the cable and", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT, TEXT_COLOR)
    print("connect it to the CR knob at the", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("bottom of your desk!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 3,
          TEXT_COLOR)
    print("A letter-number combination will", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 4, TEXT_COLOR)
    print("appear, which is the knob where", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 5, TEXT_COLOR)
    print("you will now redirect the call to.", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT * 6, TEXT_COLOR)
end

function draw_cutscene_zero_four()
    text_height = 55
    print("Alright, best way to learn it is", TEXT_X_SHIFT, text_height,
          TEXT_COLOR)
    print("to do it! So get on with it!", TEXT_X_SHIFT,
          text_height + LINE_HEIGHT, TEXT_COLOR)
    print("Go chase yourself!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 2,
          TEXT_COLOR)
end

function draw_cutscene_thief_one()
    text_height = 35
    print("He-Hello? Yes, hello there dolly, I was", 5, text_height,
          TEXT_COLOR)
    print("wondering if you could help me? Look here,", 5, text_height + LINE_HEIGHT, TEXT_COLOR)
    print("I'm currently a bit low on the dough, if you", 5,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("catch my drift. And for a while I've been", 5,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("thinking about, you know, getting some", 5,
          text_height + LINE_HEIGHT * 4, TEXT_COLOR)
    print("*help* from the bank. Problem is,", 5,
          text_height + LINE_HEIGHT * 5, TEXT_COLOR)
    print("ain't easy finding a crew in this economy.", 5,
          text_height + LINE_HEIGHT * 6, TEXT_COLOR)
end

function draw_cutscene_thief_two()
    text_height = 45
    print("This made me think to myself:", 5, text_height,
          TEXT_COLOR)
    print("who better to find the mugs", 5, text_height + LINE_HEIGHT, TEXT_COLOR)
    print("I need than an esteemed operator", 5,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("like you? Sorry to entangle you,", 5,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("with this, but whaddya say, hun?", 5, text_height + LINE_HEIGHT * 4,
          TEXT_COLOR)
    print("--Pause--", 5, text_height + LINE_HEIGHT * 5,
    TEXT_COLOR)
end

function draw_cutscene_thief_three()
    text_height = 45
    print("I'm assuming that the silence means yes!", 5, text_height,
          TEXT_COLOR)
    print("Great! You're really the bee's knees!", 5, text_height + LINE_HEIGHT, TEXT_COLOR)
    print("So, I'm in need of a getaway driver,", 5,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("a demolitions expert, a strategist", 5,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("and an arms dealer.", 5, text_height + LINE_HEIGHT * 4,
          TEXT_COLOR)
end

function draw_cutscene_thief_four()
    text_height = 55
    print("Just get me the channels", 5, text_height,
          TEXT_COLOR)
    print("on which I can contact them,", 5, text_height + LINE_HEIGHT, TEXT_COLOR)
    print("I'll handle the rest!", 5,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("Talk to you soon, I hope!", 5,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
end

function draw_cutscene_news()
    print("BREAKING NEWS", 100, 75, TEXT_COLOR) 
end

function draw_cutscene_final() 
    trace(LEVELS.level_one.chosen)
    trace(LEVELS.level_one.solution)
    if levels.level_one.solution == levels.level_one.chosen
    and levels.level_two.solution == levels.level_two.chosen
        -- and levels.level_three.solution == levels.level_three.chosen
        -- and levels.level_four.solution == levels.level_four.chosen
    then
        draw_victory()
    else 
        draw_lost()
    end


end

function draw_victory() 
    text_height = 55
    print("The robbery of the century just", 5, text_height,
          TEXT_COLOR)
    print("happened, you won't believe it!", 5, text_height + LINE_HEIGHT, TEXT_COLOR)
    print("A four men crew just robbed the", 5,
          text_height + LINE_HEIGHT * 2, TEXT_COLOR)
    print("M-BES Zelment bank out of ", 5,
          text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("200 billion dollars like", 5,
        text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("it was nothing!", 5,
        text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("That's a lotta cabbage!", 5,
    text_height + LINE_HEIGHT * 3, TEXT_COLOR)
end

function draw_lost()
    print("YOU LOSE", 100, 70, TEXT_COLOR) 
    print("TRY AGAIN!", 100, 80, TEXT_COLOR) 
end

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
-- 000:0eeeeebbeeddddebedcddeeeedddeeeeeddeeeeeedeeedeebeeeeeebbbeeeebb
-- 001:3322ffbb3343332b24c3322f2333222ff3322f2ff222f32fb222222bbbffffbb
-- 002:556677bb5555566b65c56677655667777566677776777677b777777bbb7777bb
-- 003:443322bb4444113b34c4113234413132e1131132e1111132b333333bbb2222bb
-- 004:0033febb00117deb31ceeeee31eeee0ef7eee80efeee880eb000000bbbeeeebb
-- 005:bbaaaa33bbbbaaa3abbaa999abaa9999aaa99899aa998a993999999333999933
-- 007:d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000
-- 012:555555555555555d5555555c55555ddc55555dcc55555ccc5555cccd555dccde
-- 013:55ddccdddcccddddccccddddccddd0d0cddddddddd0000e0d0000000000eeeee
-- 014:ddddddd5ddddddcdddddedecddddeeee00000eee0e00e0eee000000eee000000
-- 015:55555555d5555555cd555555cc555555ecc55555ecc55555eccd5555eecc5555
-- 023:d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000
-- 028:555dccd0555dcc00555dce00555cc00055dcc00055dd000055cd000055cd0000
-- 029:00e00e0e00000eee0e0e00ee0e0e00ee0ee0000e00ee00e0e0000000e00ee000
-- 030:e000ee00ee0000000000e00000000000000000000000000000000e0000000000
-- 031:0eccd5550eecd55500edd55500eed55500eed555000ed555000dd555000ec555
-- 035:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 039:d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000
-- 044:55dc000055dd000055cc000055cdd00055dcd00055cddd0055cdd00055cddf00
-- 045:000ee0000e000000000e00000000000000000000000e000000000000e0000000
-- 046:00000000000000e00000000000e00000000e0000000000000000e00000000000
-- 047:000cc5550000e5550000e5550000ce550000ce55000dc555000dc555000cd555
-- 055:d000000000000000d0000000d000000000000000d0000000d0000000d0000000
-- 060:55cddfe055cddfd0555d0ede55edefde5dcccedd5dccccedeeecccccdeddcccc
-- 061:000000000000000000000000d0000e00ddddd000d0000000ced0000eceeeeeee
-- 062:00000000000000000000000000000000e00000000000000eeee00eeeeeeeeee0
-- 063:000cd55500cddd55e0dcdcc5eddcecc5eeddccc5ee0dcccee0ccccdeccccdddd
-- 071:d0000000d000000000000000d0000000d0000000d0000000d0000000d0000000
-- 087:d000000000000000d0000000d0000000d000000000000000d000000000000000
-- 103:d000000000000000d0000000d0000000d000000000000000d0000000d0000000
-- 119:d00000000000000000000000d000000000000000d0000000d0000000d0000000
-- 135:d0000000d000000000000000d0000000d0000000d0000000d0000000d0000000
-- 151:d000000000000000d0000000d0000000d000000000000000d000000000000000
-- 155:0000000000000000000000000000000000000000000000000000000000000002
-- 156:0000000000000000000000000000002000002211002121112111112211112000
-- 157:0000000000000000000000000202100011111220122022221112112222022222
-- 158:0000000000000000000000000000000000000000200000002000000022000000
-- 167:d000000000000000d0000000d0000000d000000000000000d0000000d0000000
-- 171:0000002100000001000002210000011200022110000011200000110000221100
-- 172:1112020210202000120000000000000000000000000000000000000000000000
-- 173:2222222200002202000000220000000200000002000000200000000000000000
-- 174:2202000020220000000020002222000022222000002200000202000200020000
-- 183:d00000000000000000000000d000000000000000d0000000d0000000d0000000
-- 186:0000000000000000000000000000000000000000000000000000000100000001
-- 187:0022000000222000000222200011222011212222122222221222222202222222
-- 190:2022222000022222000220000200020200022202000022000002220000022200
-- 191:0000000000000000200000000000000000000000000000000000000020000000
-- 199:d00000000000000000000000d000000000000000d0000000d0000000d0000000
-- 202:0000000100000001000000010000000100000001000000000000000000000000
-- 203:1222222212222222222222221222222212222220122222200222220000000000
-- 206:0002222000022200000222000020022000222220000222000202220020022000
-- 215:000000000000000000000000d0000000000000000000000000000000d0000000
-- 219:0000000000000000000000000000000000040000004444000444440004044000
-- 221:0000000000000021000000110000211100002122000011220000122200202222
-- 222:1222220011222200122222002222220022222200224112002241100022112000
-- 231:d000000000000000d0000000d0000000d0000000000000000000000000000000
-- 235:0444404044444440040444440000004400000000000000000000000000000000
-- 236:0000000000000000040000004404040044404400000000400000000000000000
-- 237:0202222200022444000244114444111444444442404022220000222200000020
-- 238:4111200011222000442000004200000022000000000000000000000000000000
-- 247:00000000d000000000000000000000000000000000000000d0000000d0000000
-- </TILES>

-- <SPRITES>
-- 001:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed
-- 002:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeededdddde
-- 003:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddeddd
-- 004:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 005:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 006:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 007:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 008:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 009:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 010:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 011:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeede
-- 012:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 013:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 017:eeeeeeedeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeedd
-- 018:ddddddddddddededdeeeeeeedeeeeeeeeeeeeeeeeeeeeeeedeeeeeeedeeeeeee
-- 019:ddddddddeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 020:dddddeeeeeeeddeeeeeeedeeeeeeedeeeeeeddeeeeeeddeeeeeeedeededddeee
-- 021:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 022:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 023:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 024:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 025:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 026:eeeedeededddddddedddeeeeeddeeeeeeddeeeeeeddddddeedddddddeeddedee
-- 027:deddeeddddddddddeeedededeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeee
-- 028:eddddddeeddddddeeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 029:ddeeeeeeddddeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeeddeeeeeeddeeee
-- 033:eeeeeeedeeeeeeddeeeeeeedeeeeeeedeeeeeeedeeeeeeddeeeeeeedeeeeeeed
-- 034:deeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeedeeddddedeeddddedeedeede
-- 035:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 036:deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 037:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 038:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 039:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 040:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 041:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 042:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 043:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 044:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 045:eeddeeeeeedeeeeeeedeeeeeeeddeeeeeeeeeeeeeedeeeeeeedeeeeeeeddeeee
-- 049:eeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeeeeeeeeeee
-- 050:deeeeddedeeeeededeeeeeeedeeededededdddeeddddeeeedeeeeeeeedeeeeee
-- 051:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 052:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 053:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 054:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 055:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 056:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 057:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 058:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 059:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 060:eeeeeeeeeeeeeeeeedddeeeeddeeeeeedeeeeeeeddeeeeeeedeeeeedeedeedde
-- 061:eedeeeeeeedeeeeeeedeeeeeeedeeeeeeddeeeeeeddeeeeeddeeeeeeeeeeeeee
-- 065:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 066:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 067:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 068:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 069:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 070:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 071:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 072:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 073:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 074:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 075:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 076:eedddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddeeeddddddddddeeedddeeeeeed
-- 077:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeedeeeeeeeddeeeeee
-- 081:eeeeeeeeeeeeeeeeeeeeeeedeeeeeeedeeeeeeddeeeeeeddeeeeeeddeeeeeedd
-- 082:eeeeeeeeedddddeeddededdedeeeedddeeeeeeeeeeeeedeeeeeeedddeeeeedde
-- 083:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeedeeeeeeeeeeeeeeeeeeeeeee
-- 084:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 085:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 086:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 087:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 088:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 089:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 090:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 091:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 092:ddeeeeeedddeeeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 093:ddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeedddeeeeeddeeeeeeddeeeeee
-- 097:eeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeedeeeeeedd
-- 098:eeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 099:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeed
-- 100:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeeeedddeeeeddddeee
-- 101:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 102:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 103:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 104:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 105:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 106:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeedeeeeeedddeeeedddeeeeedddee
-- 107:eeeeeeeeeeeeeeeeeeeeeeeedeeeeeeeddeeeeeeddeeeeeeeeeeeeeeeeeeeeee
-- 108:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeedeeeeeeedeeeeeeed
-- 109:ddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeee
-- 113:eeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeedeeeeeeeeeeeeeeee
-- 114:eeeeeeeedeeeeeeedeeeeeeedddeeddddddddeeddddedddeeeeeeeeeeeeeeeee
-- 115:eeeeeeedeeeeeeedeeeeeeededdddddddddddeeeeeeeddedeeeeeedeeeeeeeee
-- 116:deeddeeeededdeeeddeddeeeeddddeeeedddeeeedddeeeeeeeeeeeeeeeeeeeee
-- 117:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 118:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 119:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 120:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 121:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 122:eeeddeeeeeeddeddeeedddddeeeededdeeeeedeeeeeeeeeeeeeeeeeeeeeeeeee
-- 123:eeeeeeeddeddddddddddddddddddededeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 124:ddeddddddddddddddddddddddddedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 125:ddeeeeeeddeeeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 198:0000000000000000000000000000000000000000000000000000000000000200
-- 199:0000000000000000000000000000000000000000000000000000424222222222
-- 203:0000000000000000000000000000000000000000000000000000000000ee0000
-- 208:6666666622226222ddeeeeeeddeeeeeeeeeeededeeeeedddeeedddddeeeddddd
-- 209:6622666622222222eeeeeeeeeedeeeeeedddedeeddddddeeddddddeeddddddee
-- 210:22666666220eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeee
-- 211:66666662eeeeeeeeeeeeeeeeeeeededeeeddddddeeddddddedddddddeedddddd
-- 212:66626e66eeeeeeeeeeeeeeeedeeeeddeededededddddddeeddddeededddddddd
-- 213:e2ee2666eeeeeeeeeeddeeeeeedeedeeeeeeeedddddddddddddddddddddddddd
-- 214:eee2eeeeeeeeeeeeeeeee2eeeeededeedddddddddddddddddddddddddddddddd
-- 215:e2eeeeeeeeeeeeeeeeeeeedeeeddeeeddddddddddddddddddddddddddddddddd
-- 216:eeeeeeeeeeeeeeeeeeeeeeeeeddeeeeddddddddddddddddddddddddddddddddd
-- 217:eeeeeee6eeeeeeeeeeeeeeeedddeeeeedeeedddddddddddddddddddddddddddd
-- 218:6e66eeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddedd
-- 219:222e6ee6eeeeeeeeeeeeeeeedddddeddddddddddddddddddddddddddddddddde
-- 220:6626662eeeeeeeeeeeeeedeeddeeeeeeddeeeee0dddeee00dddeee00dddee000
-- 221:eeeeeeeeeeeeeeeeeee0e0eee000000e00000000000000000000000000000000
-- 222:eeeeeeeeeeeeeeeeeeeeeeee0eeeeeeee0eeeeee0eeeeeee00eeeeee000eeeee
-- 223:22262226ee222222eeee2222eeeeeeeeeeeeeeeee0eeeee00000e00000000000
-- 224:eeddddddeeddddddeeddddddeeddddddeeddddddeededdddeeeeddddeeeddddd
-- 225:ddddddeeddddddeeddddddeedddddddedddddddeddddddd0dddddde0dddddee0
-- 226:ee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeee0eeeee0e0eeeee
-- 227:eeddeddddeededddeeededddeeedeeddeeeeeeddeeeeeeddeeeeeeedeeeeeeee
-- 228:ddeeeddddeedddddddddddddedddddddeeddddddeeddddddeeddddddeeeeeedd
-- 229:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeedede
-- 230:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 231:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 232:ddddddddddddddddddddddddddddddddddddddddddddddddddddddeedddddeee
-- 233:dddddddddddddddddddddddddddddddddddddddddddddddddedddddddeeeeddd
-- 234:ddddddddddddddddddddddddddddddddddddddddddddddddddddddeeddddddde
-- 235:dddddddddddddddddddddddddddddddddddddddddddddddddededededeeeeeee
-- 236:ddde0000ddee0000ddee0000dee00000deee0000eeee0000eeee0000eee00000
-- 238:000000ee00000000000000000000000000000000000000000000000000000000
-- 240:eeeeddddeeeeedddeeeeedddeeeeeeeeeeeeeeee0eeeeeee00eeeeee0000eeee
-- 241:dddeee00deeee000eeee0000e0000000000000000000000000000000e0000000
-- 242:0e0eeeee000eeeee0000eeee00000eee00000eee000000ee0000000000000000
-- 243:eeeeeeeeeeeeeeedeeedeeeeeeeeeeeeeeeeeeedeeeeeeed0eeeeeeee0eeeeee
-- 244:deeeeeeeeeeeeeeeeeeddeedeeeeeeeedeeeeeeeddeeeeeeeeeeeeeeeeeeeeee
-- 245:eddeededeeeeeeeeeeedeeeedededdeeeeeeeeeeeeeeeedeeeeeeeedeeeeeeee
-- 246:ddeddeeeeeeeeeeeeeeeeeeeeeedddddeeeeedeededeededdeeeedeeeeeeeeee
-- 247:eeeeeeeeeeedeedeeeeeedeeddddddddddeeeedeedeeeeededdededdeeeeeede
-- 248:eeeededeeeeeeeeeeeeeedeeddddddededeedeeeededdeddeeeddeeedeeeeede
-- 249:deddeeeeeedeeeeedeeedededddddddddeedeeedeeeeeeeeeededeeeedededee
-- 250:eeeedeeedeeeeeeeddedededddddddddddddddeeeeededeeeeedeeeeeeedeeee
-- 251:eeeeeededeeedeeeeddeeeeedeeedeeedeeddeeeeeedeeeeedeeeeeeedededde
-- 252:eeee0000eee00000eeee0000eeeeee00eeeeee00ee000000ee000000ee000000
-- </SPRITES>

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
-- 013:140044006400a400d400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400405000050000
-- 014:080048008800b800d80018004800e800f800010001000100f10001000100f10001000100f1000100f1000100f10001000100f100010001000100f10047b000000000
-- 015:01000100f100f100010001000100f100f1000100f1000100f1000100010001000100f10001000100f1000100f1000100f1000100f100010001000100374000000000
-- 016:080048008800b800d80018004800e800f800013701370137018701870187018701870187018701870187118721873187518771878187b187d187f187570000000000
-- 017:080048008800b800d80018004800e800f800013f013f013f013f013e013e013e013e013d013d013d013d113d213c313c513c713c813cb13cd13cf13cd73000000000
-- 018:080038009800e20002002200320042006200720082009200a200b200c200e200e200f200f200f200f200f200f200f200f200f200f200f200f200f200974000000000
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
-- 033:000000000000000000000000000000000000000000000000413436024600000000000000000000000000000000000000000000000000000000000000e00036000000000000000000000000000000000000000000000000d00036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:000000000000000000000000000000000000000000000000b13438024600000000000000000000000000000000000000000000000000000000000000e00038000000000000000000000000000000000000000000000000900038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 035:4fa1c80000001000000000004000c80000000000000000001000000000000000000000004000c80000001000000000004000c80000000000000000001000000000000000000000004000c80000001000000000004000c80000000000000000001000000000000000000000004000c80000001000000000004000c8000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 036:efa1c8000000100000000000e000c8000000000000000000100000000000000000000000e000c8000000100000000000e000c8000000000000000000100000000000000000000000e000c8000000100000000000e000c8000000000000000000100000000000000000000000e000c8000000100000000000e000c8000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 037:7af1ca0000001000000000007000ca0000000000000000001000000000000000000000007000ca0000001000000000007000ca0000000000000000001000000000000000000000007000ca0000001000000000007000ca0000000000000000001000000000000000000000007000ca0000001000000000007000ca0000000000000000001000000000000000000000007000ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:400024000000000000400026400024000000000000000000000000000000000000000000700024000000000000e00026e00024000000000000000000000000000000000000000000700024000000000000e00026e00024000000000000000000000000000000000000000000900024000000000000d00026d00024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:b12436088100023600000000000000000000000000000000000000000000000000000000e00036000000000000000000000000000000000000000000900036000000000000000000000000000000000000000000400036000000000000000000000000000000000000000000900036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:baf1c80a00001000000000007000c80000000000000000001000000000000000000000009000c80000001000000000007000c8000000000000000000100000000000000000000000b000c80000001000000000007000c80000000000000000001000000000000000000000004000c80000001000000000007000c80000000000000000001000000000000000000000007000ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:935636088100000000000000b00036000000000000000000400036000000000000000000e00034000000000000000000000000000000000000000000000000000000e00036000000100000000000e00036000000100000000000e00036100000e00036100000e00036100000e21436000000000000400038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:61243a08810003560000000000000000000000000000040040003a00000060043a000000e0003800000000000000000000000000000000000000000000000000000000000000000062143a00000000000000000000000000000000040040003a00000060003a00000000000090003a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:4fa1c80000001000000000004000c80000000000000000001000000000000000000000004000c80000001000000000004000c80000000000000000001000000000000000000000009000c80000001000000000009000c80000000000000000001000000000000000000000009000c80000001000000000009000c8000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 044:41243a08810003560000000070003a000000000000000000000000000000000000000000700038000000000000000000600038000000000000000000000000000000000000000000700038000000000000000000400038000000000000000000000000000000000000000000600038000000000000000000400038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 045:412438088100035600000000000000000000000000000000088100000000000000000000077100000000000000000000666138000000000000000000055100000000000000000000044100000000000000000000b33138000000000000000000022100000000000000000000411138000000000000000000000000000000000000000000000000000000000000010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:2c0441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000abc001
-- 001:0817021817021818421818821c20001c2c000000000000000000000000000000000000000000000000000000000000002e0100
-- 002:e00000ec3000ec3010000010ec30000000000000000000000000000000000000000000000000000000000000000000002e8100
-- 003:2100002d40002d40002d44102d44102556d52d4410296856296b56296b17047000257000257e102d40200c40000000002e81ef
-- 004:4a9720ca972056a720ca972a56a7aaca97ea56a76bca97ab000000000000000000000000000000000000000000000000ec01ef
-- 005:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e0100
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2cffa5597d3c38d67571ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86482418
-- </PALETTE>

