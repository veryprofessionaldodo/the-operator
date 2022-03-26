-- title:  The Operator
-- author: Team "It's about drive"
-- desc:   RetroJam 2022 organized by IEEE UP SB
-- script: lua
-- Viewport 240x136
SWITCHBOARD = {
    start_x = 10,
    start_y = 10,
    row_num = 3,
    col_num = 7,
    col_spacing = 35,
    row_spacing = 25
}

FRAME_COUNTER = 0

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
KNOB_SELECTED, CALL_SELECTED = nil, nil

-- calls from knob to knob
CALLS = {}

function TIC()
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
    for i = 0, SWITCHBOARD.row_num - 1 do
        for j = 0, SWITCHBOARD.col_num - 1 do
            local x = SWITCHBOARD.start_x + (j * SWITCHBOARD.col_spacing)
            local y = SWITCHBOARD.start_y + (i * SWITCHBOARD.row_spacing)
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
                 {src = KNOBS[1], dst = KNOBS[2], state = CALL_STATE.ONGOING})
    table.insert(calls,
                 {src = KNOBS[5], dst = KNOBS[15], state = CALL_STATE.ONGOING})
    table.insert(calls,
                 {src = KNOBS[8], dst = KNOBS[12], state = CALL_STATE.ONGOING})
    table.insert(calls,
                 {src = KNOBS[9], dst = KNOBS[4], state = CALL_STATE.ONGOING})

    return calls
end

-- updates
function update()
    update_mouse()

    -- DEBUG: see if selected
    -- if knob then knob.state = KNOB_STATE.INCOMING end

    FRAME_COUNTER = FRAME_COUNTER + 1
end

function update_mouse()
    local mx, my, md = mouse()

    -- select knob to drag
    if md and KNOB_SELECTED == nil then
        local knob_hovered = get_knob(mx, my)
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
    local dst_knob = get_knob(mx, my)
    local is_same_node = dst_knob ~= nil and dst_knob.x == KNOB_SELECTED.x and
                             dst_knob.y == KNOB_SELECTED.y

    local overlaps = #filter(CALLS, function(call)
        return call.state ~= CALL_STATE.INTERRUPTED and
                   (call.src == dst_knob or call.dst == dst_knob)
    end) > 0

    if dst_knob ~= nil and not is_same_node and not overlaps then
        dst_knob.state = KNOB_STATE.CONNECTED
        table.insert(CALLS, {
            src = KNOB_SELECTED,
            dst = dst_knob,
            state = CALL_STATE.ONGOING
        })
    else
        CALL_SELECTED.state = CALL_STATE.ONGOING
    end
    CALL_SELECTED, KNOB_SELECTED = nil, nil
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
    cls()
    rectb(0, 0, 240, 136, 2)
    draw_switchboard()
    draw_message_box()
    draw_knobs()
    draw_calls()

    -- DEBUG
    print(KNOB_SELECTED, 10, 50)

    -- drag knob line
    local mx, my, md = mouse()
    if md and KNOB_SELECTED ~= nil then
        draw_call(KNOB_SELECTED.x + KNOB_WIDTH, KNOB_SELECTED.y + KNOB_HEIGHT,
                  mx, my)
    end
end

function draw_message_box()
    rectb(5, SWITCHBOARD.row_num * SWITCHBOARD.row_spacing + 8, 230, 25, 5)
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
        if call.state == CALL_STATE.ONGOING then
            draw_call(call.src.x + KNOB_WIDTH, call.src.y + KNOB_HEIGHT,
                      call.dst.x + KNOB_WIDTH, call.dst.y + KNOB_HEIGHT)
        end
    end
end

function draw_call(x0, y0, x1, y1) line(x0, y0, x1, y1, 1) end

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

