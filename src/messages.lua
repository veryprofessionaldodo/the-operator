
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

    return messages
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