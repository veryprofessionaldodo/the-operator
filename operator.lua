-- title:  The Operator
-- author: Team "It's about drive"
-- desc:   RetroJam 2022 organized by IEEE UP SB
-- script: lua
-- Viewport 240x136
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
    FINISHED = 'finished',
    INTERRUPTED = 'interrupted'
}
KNOB_WIDTH, KNOB_HEIGHT, KNOB_SCALE = 8, 8, 2
KNOB_PIVOT, CALL_SELECTED = nil, nil
SEGMENTS_LENGTH = 10

-- calls from knob to knob
CALLS = {}

LEVELS = {ONE = {}}

function TIC()
    cls()
    update()
    draw()
end

-- inits
function init()
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
            local knob = {x = x, y = y, state = KNOB_STATE.OFF, timer = 0}
            table.insert(knobs, knob)
        end
    end

    -- add operator knob
    local op_knob = {x = 10, y = 115, state = KNOB_STATE.OFF, timer = 0}
    table.insert(knobs, op_knob)

    return knobs
end

function init_calls()
    local calls = {}

    -- TODO: generate random
    table.insert(calls,
                 {src = KNOBS[1], dst = KNOBS[2], state = CALL_STATE.ONGOING, rope_segments = create_rope_segments(KNOBS[1], KNOBS[2])})
    table.insert(calls,
                 {src = KNOBS[5], dst = KNOBS[15], state = CALL_STATE.ONGOING, rope_segments = create_rope_segments(KNOBS[5], KNOBS[15])})
    table.insert(calls,
                 {src = KNOBS[8], dst = KNOBS[12], state = CALL_STATE.ONGOING, rope_segments = create_rope_segments(KNOBS[8], KNOBS[12])})
    table.insert(calls,
                 {src = KNOBS[9], dst = KNOBS[4], state = CALL_STATE.ONGOING, rope_segments = create_rope_segments(KNOBS[9], KNOBS[4])})

    return calls
end

function create_rope_segments(pos_1, pos_2)
    local diffX = pos_2.x - pos_1.x 
    local diffY = pos_2.y - pos_1.y
    local length = math.sqrt(math.pow(diffX, 2), math.pow(diffY, 2))
    -- get more segments, that way there's a bit of flex 
    local num_segments = math.ceil(length / SEGMENTS_LENGTH * 1.5)

    local segments = {}
    for i = 1, num_segments do
        local new_segment = { previous = {x = 0, y = 0}, current = {x = 0, y = 0}}
        new_segment.x = pos_1.x + diffX * (i - 1) / (num_segments - 1)
        new_segment.y = pos_1.y + diffY * (i - 1) / (num_segments - 1)

        table.insert(segments, new_segment)
    end

    return segments
end

-- updates
function update()
    update_mouse()

    if FRAME_COUNTER % 1 == 0 then 
        for i = 1, #CALLS do
            simulate_ropes(CALLS[i])
            for j = 1, 50 do
                constraint_ropes(CALLS[i])
            end
            simulate_ropes(CALLS[i])
        end 
    end

    -- DEBUG: see if selected
    -- if knob then knob.state = KNOB_STATE.INCOMING end

    FRAME_COUNTER = FRAME_COUNTER + 1
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
        if diff < 0 then 
            break
        end

        -- get direction of correction vector
        local correction_vector = get_vector_from_points(current_point, next_point)
        -- print(get_distance_between_points({x = 0, y = 0}, correction_vector), 50, 50, 3)
        correction_vector.x = correction_vector.x * ((distance - SEGMENTS_LENGTH) / distance)
        correction_vector.y = correction_vector.y * ((distance - SEGMENTS_LENGTH) / distance)

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

function get_vector_from_points(p1, p2)
    return { x = p2.x - p1.x, y = p2.y - p1.y }
end 

function normalize_vector(vec)
    local length = get_distance_between_points({x = 0, y = 0}, vec)
    return { x = vec.x / length, y = vec.y / length }
end

function update_mouse()
    local mx, my, md = mouse()

    -- select knob to drag
    if md and KNOB_PIVOT == nil then
        local knob_hovered = get_knob(mx, my)
        for i = 1, #CALLS do
            if CALLS[i].src == knob_hovered then
                CALL_SELECTED = CALLS[i]
                CALL_SELECTED.state = CALL_STATE.INTERRUPTED
                KNOB_PIVOT = CALL_SELECTED.dst
            elseif CALLS[i].dst == knob_hovered then
                CALL_SELECTED = CALLS[i]
                CALL_SELECTED.state = CALL_STATE.INTERRUPTED
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
    local dst_knob = get_knob(mx, my)
    local is_same_node = dst_knob ~= nil and dst_knob.x == KNOB_PIVOT.x and
                             dst_knob.y == KNOB_PIVOT.y

    local overlaps = #filter(CALLS, function(call)
        return call.state ~= CALL_STATE.INTERRUPTED and
                   (call.src == dst_knob or call.dst == dst_knob)
    end) > 0

    if dst_knob ~= nil and not is_same_node and not overlaps then
        dst_knob.state = KNOB_STATE.CONNECTED
        table.insert(CALLS, {
            src = KNOB_PIVOT,
            dst = dst_knob,
            state = CALL_STATE.ONGOING
        })
    else
        CALL_SELECTED.state = CALL_STATE.ONGOING
    end

    CALL_SELECTED, KNOB_PIVOT = nil, nil
end

function get_knob(mx, my)
    local ranges = filter(KNOBS, function(knob)
        local inside_x = mx >= knob.x and mx <= knob.x + KNOB_WIDTH * KNOB_SCALE
        local inside_y = my >= knob.y and my <= knob.y + KNOB_HEIGHT *
                             KNOB_SCALE
        return inside_x and inside_y
    end)
    return ifthenelse(#ranges > 0, ranges[1], nil)
end

-- draws
function draw()
    -- rectb(0, 0, 240, 136, 2)
    draw_switchboard()
    -- draw_knobs()
    draw_calls()
    draw_timer()
    print(#CALLS[1].rope_segments, 40, 40, 3)
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
        print(string.char(65 + i), x, 0, 1)
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
        -- TODO: this blinking should be calculated based on state and timer of the knob
        local knob = KNOBS[i]
        local is_blinking = knob.state == KNOB_STATE.INCOMING
        if is_blinking then
            spr(0 + FRAME_COUNTER % 60 // 30 * 2, knob.x, knob.y, -1, KNOB_SCALE)
        else
            spr(0, knob.x, knob.y, -1, KNOB_SCALE)
        end
    end
end

function draw_calls()
    for _, call in pairs(CALLS) do
        draw_call(call)
        -- if call.state == CALL_STATE.ONGOING then
        --     draw_call(call)
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
    clock_x = 214
    clock_y = 119
    clock_radius = 10

    print("Time Left", clock_x - 14, clock_y - 17, 3, false, 1, true)
    circ(clock_x, clock_y, clock_radius, 1)
    if(FRAME_COUNTER%60 == 0) then
        SECONDS_PASSED = SECONDS_PASSED + 1
    end

    for i = 0, SECONDS_PASSED, 0.3 do
        line_increment = deg_to_rad(-90 + i * 6)
        line(clock_x, clock_y, round(clock_x+clock_radius*math.cos(line_increment)), round(clock_y+clock_radius*math.sin(line_increment)), 2)
    end
    
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

function deg_to_rad(angle)
    return angle * math.pi / 180
end

function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
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

