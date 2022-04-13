
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
    center_text("BREAKING NEWS", 66)
end

function draw_cutscene_final()
    draw_old_timey_background()

    if LEVELS.level_three.solution ~= LEVELS.level_three.chosen then -- Wrong strategist
        draw_ending_strategist()
    elseif LEVELS.level_four.solution ~= LEVELS.level_four.chosen then -- Wrong arms dealer
        draw_ending_arms_dealer()
    elseif LEVELS.level_two.solution ~= LEVELS.level_two.chosen then -- Wrong demolition's expert
        draw_ending_demolition_expert()
    elseif LEVELS.level_one.solution ~= LEVELS.level_one.chosen then -- Wrong getaway driver
        draw_ending_getaway_driver()
    else
        draw_victory()
        music(2)
    end

end

function draw_end_level()
    draw_game()
    spr(352, 70, 40, 5, 3, 0, 0, 4, 2)
    print("DAY'S OVER!", 90, 62, 0)
end

function draw_victory()
    text_height = 55
    center_text("The robbery of the century just", text_height)
    center_text("happened, you won't believe it!", text_height + LINE_HEIGHT)
    center_text("A four men crew just robbed the", text_height + LINE_HEIGHT * 2)
    center_text("M-BES Zelment bank out of ", text_height + LINE_HEIGHT * 3)
    center_text("200 billion dollars like", text_height + LINE_HEIGHT * 4)
    center_text("it was nothing!", text_height + LINE_HEIGHT * 5)
    center_text("That's a lotta cabbage!", text_height + LINE_HEIGHT * 6)
end

function draw_ending_strategist()
    text_height = 50
    center_text("A..grocery store was just robbed?", text_height)
    center_text("Four armed men just stole some", text_height + LINE_HEIGHT)
    center_text("... pears and apples?", text_height + LINE_HEIGHT * 2)
    center_text("I'm not sure what their strategy", text_height + LINE_HEIGHT * 3)
    center_text("was, but they definitely got", text_height + LINE_HEIGHT * 4)
    center_text("the wrong green!", text_height + LINE_HEIGHT * 5)
end

function draw_ending_arms_dealer()
    text_height = 50
    center_text("Four goons just tried to rob", text_height)
    center_text("the M-BES Bezelement bank! But", text_height + LINE_HEIGHT)
    center_text("thankfully the bank security was", text_height + LINE_HEIGHT * 2)
    center_text("able to subdue them easily! Phew!", text_height + LINE_HEIGHT * 3)
    center_text("They were trying to get into", text_height + LINE_HEIGHT * 4)
    center_text("the vault with some water guns!", text_height + LINE_HEIGHT * 5)
end

function draw_ending_demolition_expert()
    text_height = 50
    center_text("WOW! A huge explosion just", text_height)
    center_text("shook the M-BES Zelment bank!", text_height + LINE_HEIGHT)
    center_text("We are getting told that the", text_height + LINE_HEIGHT * 2)
    center_text("whole vault was destroyed!", text_height + LINE_HEIGHT * 3)
    center_text("Not a single dime left to tell", text_height + LINE_HEIGHT * 4)
    center_text("the story!", text_height + LINE_HEIGHT * 5)
end

function draw_ending_demolition_expert()
    text_height = 50
    center_text("Applesauce! The M-BES Zelment just", text_height)
    center_text("got out of a sticky situation!", text_height + LINE_HEIGHT)
    center_text("Three goons tryed to rob the bank", text_height + LINE_HEIGHT * 2)
    center_text("but they were stopped by a police", text_height + LINE_HEIGHT * 3)
    center_text("officer posing as their", text_height + LINE_HEIGHT * 4)
    center_text("getaway driver!", text_height + LINE_HEIGHT * 5)
end