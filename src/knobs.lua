
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