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

function generate_unique_coord(coords)
    local cols = map(coords, function(coord) return coord[1] end)
    local col = generate_col()
    while has_value(cols, col) do col = generate_col() end

    local rows = map(coords, function(coord) return coord[2] end)
    local row = generate_row()
    while has_value(rows, row) do row = generate_row() end

    return {col, row}
end

function generate_col()
    return string.char(ASCII_UPPER_A + math.random(1, SWITCHBOARD.N_COLS) - 1)
end

function generate_row() return math.random(1, SWITCHBOARD.N_ROWS) end

function center_text(msg, height)
    x = (SCREEN_WIDTH/2) - (#msg*2.65)
    print(msg, x, height, TEXT_COLOR)
end

function text_shadow(msg, height)
    print(msg, MESSAGE_X, height, 12, false, 1, true)
    print(msg, MESSAGE_X + 1, height + 1, 0, false, 1, true)
end

function sleep(time)
    if (FRAME_COUNTER % 60 == 0) then SECONDS_PASSED = SECONDS_PASSED + 1 end

    if(SECONDS_PASSED == time) then
        update_state_machine()
    end
end

function play_call_sfx()
    if (FRAME_COUNTER % 60 == 0) then sfx(13, 60, 18, 3, 6) end
end
