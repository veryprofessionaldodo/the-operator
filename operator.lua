-- Viewport 240x136

-- Switchboard properties
sb = {
    start_x = 10,
    start_y = 10,
    row_num = 4,
    col_num = 5,
    col_spacing = 35,
    row_spacing = 25,
}

t = 0

function TIC()
    cls()
    rectb(0, 0, 240, 136, 2)
    draw_switchboard()
    draw_message_box()
    knob_blink(sb.start_x, sb.start_y)
    t = t + 1
end

function draw_switchboard()
    rectb(5, 5, (sb.col_num * sb.col_spacing) - 8, sb.row_num * sb.row_spacing, 1)
    for i = 0, sb.row_num - 1, 1 do
        for j = 0, sb.col_num - 1, 1 do
            spr(0, sb.start_x + (j * sb.col_spacing), sb.start_y + (i * sb.row_spacing), -1, 2)
        end
    end
end

function draw_message_box()
    rectb(5, sb.row_num * sb.row_spacing + 8, 230, 25, 5)
end

function knob_blink(x, y)
    spr(0+t%60//30*2, x, y, -1, 2)
end

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

