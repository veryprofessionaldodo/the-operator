function draw_old_timey_background()
      local rand_x = math.random(-1, 1)
      local rand_y = math.random(-1, 1)
      spr(256, rand_x, rand_y, 1, 3, 0, 0, 14, 10)
end

function draw_cutscene_zero_one()
      draw_old_timey_background()
      text_height = 45
      print("Miss Nicole Tangle, am I correct?", TEXT_X_SHIFT, text_height,
            TEXT_COLOR)
      print("What's shaken?", TEXT_X_SHIFT, text_height + LINE_HEIGHT, TEXT_COLOR)
      print("Welcome here to your first training", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 2, TEXT_COLOR)
      print("on how to operate this ritzie", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 3, TEXT_COLOR)
      print("new switchboard!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 4,
            TEXT_COLOR)
end

function draw_cutscene_zero_two()
      draw_old_timey_background()
      text_height = 40
      print("First of all, whenever you see a", TEXT_X_SHIFT, text_height,
            TEXT_COLOR)
      print("blinking green knob, that means", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT, TEXT_COLOR)
      print("you've got a call!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 2,
            TEXT_COLOR)
      print("If there's no cable connected to", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 3, TEXT_COLOR)
      print("that knob, just grab a free one", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 4, TEXT_COLOR)
      print("on your board and put'it there!", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 5, TEXT_COLOR)
end

function draw_cutscene_zero_three()
      draw_old_timey_background()
      text_height = 35
      print("After that you'll just have to grab", TEXT_X_SHIFT, text_height,
            TEXT_COLOR)
      print("the other end of the cable and", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT, TEXT_COLOR)
      print("connect it to the CR knob at the", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 2, TEXT_COLOR)
      print("bottom of your desk!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 3,
            TEXT_COLOR)
      print("A letter-number combination will", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 4, TEXT_COLOR)
      print("appear, which is the knob where", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 5, TEXT_COLOR)
      print("you will now redirect the call to.", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT * 6, TEXT_COLOR)
end

function draw_cutscene_zero_four()
      draw_old_timey_background()
      text_height = 55
      print("Alright, best way to learn it is", TEXT_X_SHIFT, text_height,
            TEXT_COLOR)
      print("to do it! So get on with it!", TEXT_X_SHIFT,
            text_height + LINE_HEIGHT, TEXT_COLOR)
      print("Go chase yourself!", TEXT_X_SHIFT, text_height + LINE_HEIGHT * 2,
            TEXT_COLOR)
end

function draw_cutscene_thief_one()
      draw_old_timey_background()
      text_height = 35
      print("He-Hello? Yes, hello there dolly, I was", 5, text_height, TEXT_COLOR)
      print("wondering if you could help me? Look here,", 5,
            text_height + LINE_HEIGHT, TEXT_COLOR)
      print("I'm currently a bit low on the dough, if you", 5,
            text_height + LINE_HEIGHT * 2, TEXT_COLOR)
      print("catch my drift. And for a while I've been", 5,
            text_height + LINE_HEIGHT * 3, TEXT_COLOR)
      print("thinking about, you know, getting some", 5,
            text_height + LINE_HEIGHT * 4, TEXT_COLOR)
      print("*help* from the bank. Problem is,", 5, text_height + LINE_HEIGHT * 5,
            TEXT_COLOR)
      print("ain't easy finding a crew in this economy.", 5,
            text_height + LINE_HEIGHT * 6, TEXT_COLOR)
end

function draw_cutscene_thief_two()
      draw_old_timey_background()
      text_height = 45
      print("This made me think to myself:", 5, text_height, TEXT_COLOR)
      print("who better to find the mugs", 5, text_height + LINE_HEIGHT,
            TEXT_COLOR)
      print("I need than an esteemed operator", 5, text_height + LINE_HEIGHT * 2,
            TEXT_COLOR)
      print("like you? Sorry to entangle you,", 5, text_height + LINE_HEIGHT * 3,
            TEXT_COLOR)
      print("with this, but whaddya say, hun?", 5, text_height + LINE_HEIGHT * 4,
            TEXT_COLOR)
      print("--Pause--", 5, text_height + LINE_HEIGHT * 5, TEXT_COLOR)
end

function draw_cutscene_thief_three()
      draw_old_timey_background()
      text_height = 45
      print("I'm assuming that the silence means yes!", 5, text_height, TEXT_COLOR)
      print("Great! You're really the bee's knees!", 5, text_height + LINE_HEIGHT,
            TEXT_COLOR)
      print("So, I'm in need of a getaway driver,", 5,
            text_height + LINE_HEIGHT * 2, TEXT_COLOR)
      print("a demolitions expert, a strategist", 5,
            text_height + LINE_HEIGHT * 3, TEXT_COLOR)
      print("and an arms dealer.", 5, text_height + LINE_HEIGHT * 4, TEXT_COLOR)
end

function draw_cutscene_thief_four()
      draw_old_timey_background()
      text_height = 55
      print("Just get me the channels", 5, text_height, TEXT_COLOR)
      print("on which I can contact them,", 5, text_height + LINE_HEIGHT,
            TEXT_COLOR)
      print("I'll handle the rest!", 5, text_height + LINE_HEIGHT * 2, TEXT_COLOR)
      print("Talk to you soon, I hope!", 5, text_height + LINE_HEIGHT * 3,
            TEXT_COLOR)
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
