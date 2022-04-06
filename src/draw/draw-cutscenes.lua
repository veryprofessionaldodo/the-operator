
function draw_old_timey_background()
    SCREEN_SHAKE_COUNTER = SCREEN_SHAKE_COUNTER + 0.1 * 3
    local x = math.sin(SCREEN_SHAKE_COUNTER) + 0.5
    local y = math.cos(SCREEN_SHAKE_COUNTER) + 0.5

    spr(256, x, y, 1, 3, 0, 0, 14, 10)

    for i=1,50 do
      pix(math.random(5,234),math.random(5,130),0)
    end
end

function draw_cutscene_zero_one()
    draw_old_timey_background()
    text_height = 47
    center_text("Miss Nicole Tangle, am I correct?", text_height)
    center_text("What's shaken?", text_height + LINE_HEIGHT)
    center_text("Welcome here to your first", text_height + LINE_HEIGHT * 2)
    center_text("training on how to operate this", text_height + LINE_HEIGHT * 3)
    center_text("ritzie new switchboard!", text_height + LINE_HEIGHT * 4)
end

function draw_cutscene_zero_two()
    draw_old_timey_background()
    text_height = 47
    center_text("Firstly, if you see a blinking", text_height)
    center_text("green plug, you've got a call!", text_height + LINE_HEIGHT)
    center_text("If there's no cable connected to", text_height + LINE_HEIGHT * 2)
    center_text("that knob, just grab a free one", text_height + LINE_HEIGHT * 3)
    center_text("on your board and put'it there!", text_height + LINE_HEIGHT * 4)
end

function draw_cutscene_zero_three()
    draw_old_timey_background()
    text_height = 42
    center_text("Then, just grab the other end", text_height)
    center_text("of the cable and connect it to", text_height + LINE_HEIGHT)
    center_text("the plug on your desk!", text_height + LINE_HEIGHT * 2)
    center_text("A caller will then tell you", text_height + LINE_HEIGHT * 3)
    center_text("the channel to which you have", text_height + LINE_HEIGHT * 4)
    center_text("to redirect the call to.", text_height + LINE_HEIGHT * 5)
end

function draw_cutscene_zero_four()
    draw_old_timey_background()
    text_height = 57
    center_text("Alright, best way to learn it is", text_height)
    center_text("to do it! So get on with it!", text_height + LINE_HEIGHT)
    center_text("Go chase yourself!", text_height + LINE_HEIGHT * 2)
end

function draw_cutscene_thief_one()
    cls()
    draw_game()
    text_height = 108
    text_shadow("He-Hello? Yes, hello there dolly!", text_height)
    text_shadow("No, no! No need to connect me anywhere, I'm", text_height + MESSAGE_HEIGHT)
    text_shadow("right where I want to be!", text_height + MESSAGE_HEIGHT * 2)
end

function draw_cutscene_thief_two()
    draw_game()
    text_height = 108
    text_shadow("I'm gonna be honest, I'm a bit low on the", text_height)
    text_shadow("dough right now. So, I've been thinking about,", text_height + MESSAGE_HEIGHT)
    text_shadow("you know, getting some *help* from the bank.", text_height + MESSAGE_HEIGHT * 2)
end

function draw_cutscene_thief_three()
    draw_game()
    text_height = 108
    text_shadow("This made me think to myself: who better to", text_height)
    text_shadow("find the mugs I need, than an esteemed", text_height + MESSAGE_HEIGHT)
    text_shadow("operator like you? Whaddya say, hun?", text_height + MESSAGE_HEIGHT * 2)
end

function draw_cutscene_thief_four()
    draw_game()
    text_height = 108
    text_shadow("I'm assuming that the silence means yes! Great!", text_height)
    text_shadow("I'm in need of a getaway driver, a demolitions", text_height + MESSAGE_HEIGHT)
    text_shadow("expert, a strategist and an arms dealer.", text_height + MESSAGE_HEIGHT * 2)
end

function draw_cutscene_thief_five()
      draw_game()
      text_height = 108
      text_shadow("Just get me the channels on which I can", text_height)
      text_shadow("contact them, I'll handle the rest!", text_height + MESSAGE_HEIGHT)
      text_shadow("Talk to you soon, I hope!", text_height + MESSAGE_HEIGHT * 2)
  end

function draw_cutscene_news()
    draw_old_timey_background()
    print("BREAKING NEWS", 100, 75, TEXT_COLOR)
end

function draw_cutscene_final()
    draw_old_timey_background()

    if LEVELS.level_one.solution == LEVELS.level_one.chosen and
        LEVELS.level_two.solution == LEVELS.level_two.chosen then
        draw_victory()
        music(2)
    else
        draw_lost()
        music(0)
    end

end

function draw_end_level()
    draw_game()

    spr(352, 70, 40, 5, 3, 0, 0, 4, 2)
    print("DAY'S OVER!", 90, 62, 0)
end

function draw_victory()
    text_height = 55
    print("The robbery of the century just", 5, text_height, TEXT_COLOR)
    print("happened, you won't believe it!", 5, text_height + LINE_HEIGHT,
          TEXT_COLOR)
    print("A four men crew just robbed the", 5, text_height + LINE_HEIGHT * 2,
          TEXT_COLOR)
    print("M-BES Zelment bank out of ", 5, text_height + LINE_HEIGHT * 3,
          TEXT_COLOR)
    print("200 billion dollars like", 5, text_height + LINE_HEIGHT * 3,
          TEXT_COLOR)
    print("it was nothing!", 5, text_height + LINE_HEIGHT * 3, TEXT_COLOR)
    print("That's a lotta cabbage!", 5, text_height + LINE_HEIGHT * 3,
          TEXT_COLOR)
end

function draw_lost()
    print("YOU LOSE", 100, 70, TEXT_COLOR)
    print("TRY AGAIN!", 100, 80, TEXT_COLOR)
end