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
        },
        missed = 0,
        interrupted = 0
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
    UNUSED = "unused",
    DISPATCHING = "dispatching",
    ONGOING = 'ongoing',
    FINISHED = 'finished',
    INTERRUPTED = 'interrupted',
    DELETED = "deleted"
}
KNOB_WIDTH, KNOB_HEIGHT, KNOB_SCALE = 8, 8, 2
KNOB_SELECTED, CALL_SELECTED, OPERATOR_KNOB = nil, nil, nil

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
                    LEVELS[CUR_STATE].missed = LEVELS[CUR_STATE].missed + 1
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
                KNOB_SELECTED = CALL_SELECTED.dst

                if CALL_SELECTED.state == CALL_STATE.ONGOING then
                    CALL_SELECTED.state = CALL_STATE.INTERRUPTED
                    LEVELS[CUR_STATE].interrupted = LEVELS[CUR_STATE]
                                                        .interrupted + 1
                else
                    CALL_SELECTED.state = CALL_STATE.DELETED
                end
            elseif CALLS[i].dst == knob_hovered then
                CALL_SELECTED = CALLS[i]
                KNOB_SELECTED = CALL_SELECTED.src

                if CALL_SELECTED.state == CALL_STATE.ONGOING then
                    CALL_SELECTED.state = CALL_STATE.INTERRUPTED
                    LEVELS[CUR_STATE].interrupted = LEVELS[CUR_STATE]
                                                        .interrupted + 1
                else
                    CALL_SELECTED.state = CALL_STATE.DELETED
                end
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
    print(LEVELS[CUR_STATE].missed, 100, 100, 1)
    print(LEVELS[CUR_STATE].interrupted, 120, 100, 1)
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
    else
        spr(0, knob.x, knob.y, -1, KNOB_SCALE)
    end
end

function draw_calls()
    for _, call in pairs(CALLS) do
        if call.state ~= CALL_STATE.INTERRUPTED and call.state ~=
            CALL_STATE.DELETED then
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
-- 001:01234566666666666666666666543210
-- 002:01234566666666666666666789abcdef
-- 003:000111234579aceffeca975432111000
-- 004:00123456789abcdeedcba98765432100
-- 006:323344c667778990aabbbbc5ccdddded
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
-- 020:98f124000000000000000000000000d00024000000000000000000000000400024000000000000000000000000600024000000000000000000000000700024000000000000000000000000600024000000000000000000000000400024000000000000000000000000d00022000000000000000000000000b00002000000000000000000000000000000000000000000000000000000600004000000000000000000000000a00004000000000000000000000000000000000000000000000000
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
-- </PATTERNS>

-- <TRACKS>
-- 000:2c0441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000abc001
-- 001:0817021817021818421818821c20001c2c000000000000000000000000000000000000000000000000000000000000002e0100
-- 002:e00000ec3000ec3010000010ec30000000000000000000000000000000000000000000000000000000000000000000002e8100
-- 003:1100002d40002d40002d44102d44102556d52d4410296856296b56296b17047000257000257e102d40200c40000000002e81ef
-- 004:856ad6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c90000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2cffa559b13e53d67571ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

