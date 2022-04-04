
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
