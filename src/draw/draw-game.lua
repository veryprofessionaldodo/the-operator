
function draw_game()
    draw_switchboard()
    draw_footer()
    draw_knobs()
    draw_calls()

    if DISPATCH ~= nil then
        local coords = DISPATCH.dst.coords
        local message = DISPATCH.content
        -- print(coords[1] .. coords[2], 80, 120, 1)
        draw_receiving_call(message)
    end

    if has_value(PLAYABLE_STATES, CUR_STATE) and CUR_STATE ~= STATES.CALL_THIEF then
        print(LEVELS[CUR_STATE].missed, 100, 100, 1)
        print(LEVELS[CUR_STATE].interrupted, 120, 100, 1)
        print(LEVELS[CUR_STATE].wrong, 140, 100, 1)
    end

    -- local coords = LEVELS[CUR_STATE].solution
    -- if coords ~= nil then print(coords[1] .. coords[2], 80, 100, 1) end
end

function draw_receiving_call(message)
    local three_lines_height = 108
    local two_lines_height = 112
    if #message > 86 then
        text_shadow(string.sub(message, 0, 43), three_lines_height)
        text_shadow(string.sub(message, 44, 86), three_lines_height + MESSAGE_HEIGHT)
        text_shadow(string.sub(message, 87, #message), three_lines_height + MESSAGE_HEIGHT * 2)
    elseif #message > 43 then
        text_shadow(string.sub(message, 0, 43), two_lines_height)
        text_shadow(string.sub(message, 44, #message), two_lines_height + MESSAGE_HEIGHT)
    else
        text_shadow(message, 116)
    end
end

function draw_footer() spr(464, 0, 100, 6, 2, 0, 0, 14, 3) end

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

function draw_timer(level_time)
    local clock_x = 215
    local clock_y = 120
    local clock_radius = 10

    spr(12, 200, 105, 5, 1, 0, 0, 4, 4)

    circ(clock_x, clock_y, clock_radius, 12)
    if (FRAME_COUNTER % 60 == 0) then SECONDS_PASSED = SECONDS_PASSED + 1 end

    for i = 0, SECONDS_PASSED, 0.01 do
        line_increment = deg_to_rad(-90 + (i * 6 / (level_time / 60)))
        line(clock_x, clock_y,
            round(clock_x + clock_radius * math.cos(line_increment)),
            round(clock_y + clock_radius * math.sin(line_increment)), 4)
    end

end

function draw_main_menu()
    print("The", 20, 40, 12, true, 2)
    print("Operator", 20, 70, 12, true, 2)
    spr(154, 130, 20, 1, 2, 0, 0, 5, 6)
end

function draw_select_menu()
    print("Select one with arrows", 0, 10, 1)
    for i, option in pairs(SELECT_MENU.options) do
        if i == SELECT_MENU.selected + 1 then print(">", 110, 25 * i, 1) end
        print(option, 120, 25 * i, 1)
    end
end