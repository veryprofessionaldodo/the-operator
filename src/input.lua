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
    if (dst_knob == OPERATOR_KNOB or KNOB_PIVOT == OPERATOR_KNOB or
        CALL_SELECTED.src == OPERATOR_KNOB) and message ~= nil then
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

function update_select_menu()
    if keyp(DOWN_KEYCODE) then
        SELECT_MENU.selected = (SELECT_MENU.selected + 1) % 3
    elseif keyp(UP_KEYCODE) then
        SELECT_MENU.selected = (SELECT_MENU.selected - 1) % 3
    elseif keyp(Z_KEYCODE) then
        update_state_machine()
    end
end
