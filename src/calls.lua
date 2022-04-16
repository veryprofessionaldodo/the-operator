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
