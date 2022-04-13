
STATES = {
    MAIN_MENU = 'main_menu',
    CUTSCENE_ZERO_1 = 'cutscene_zero_1',
    CUTSCENE_ZERO_2 = 'cutscene_zero_2',
    CUTSCENE_ZERO_3 = 'cutscene_zero_3',
    CUTSCENE_ZERO_4 = 'cutscene_zero_4',
    LEVEL_ZERO = 'level_zero',
    END_LEVEL_ZERO = "end_level_zero",
    CALL_THIEF = "call_thief",
    CUTSCENE_THIEF_1 = 'cutscene_thief_1',
    CUTSCENE_THIEF_2 = 'cutscene_thief_2',
    CUTSCENE_THIEF_3 = 'cutscene_thief_3',
    CUTSCENE_THIEF_4 = 'cutscene_thief_4',
    CUTSCENE_THIEF_5 = 'cutscene_thief_5',
    LEVEL_ONE = 'level_one',
    END_LEVEL_ONE = "end_level_one",
    SELECT_MENU_1 = "select_menu_1",
    LEVEL_TWO = "level_two",
    END_LEVEL_TWO = "end_level_two",
    SELECT_MENU_2 = "select_menu_2",
    LEVEL_THREE = "level_three",
    END_LEVEL_THREE = "end_level_three",
    SELECT_MENU_3 = "select_menu_3",
    LEVEL_FOUR = "level_four",
    END_LEVEL_FOUR = "end_level_four",
    SELECT_MENU_4 = "select_menu_4",
    CUTSCENE_NEWS = "cutscene_news",
    CUTSCENE_FINAL = "cutscene_final"
}

SKIPPABLE_STATES = {
    STATES.MAIN_MENU, STATES.CUTSCENE_ZERO_1, STATES.CUTSCENE_ZERO_2,
    STATES.CUTSCENE_ZERO_3, STATES.CUTSCENE_ZERO_4, STATES.CUTSCENE_THIEF_1,
    STATES.CUTSCENE_THIEF_2, STATES.CUTSCENE_THIEF_3, STATES.CUTSCENE_THIEF_4, STATES.CUTSCENE_THIEF_5,
    STATES.CUTSCENE_NEWS, STATES.CUTSCENE_FINAL
}

PLAYABLE_STATES = {STATES.LEVEL_ZERO, STATES.LEVEL_ONE, STATES.LEVEL_TWO, STATES.LEVEL_THREE, STATES.LEVEL_FOUR, STATES.CALL_THIEF}

END_LEVEL_STATES = {STATES.END_LEVEL_ZERO, STATES.END_LEVEL_ONE, STATES.END_LEVEL_TWO, STATES.END_LEVEL_THREE, STATES.END_LEVEL_FOUR}

SELECT_MENU_STATES = {STATES.SELECT_MENU_1, STATES.SELECT_MENU_2, STATES.SELECT_MENU_3, STATES.SELECT_MENU_4}

CUR_STATE = STATES.MAIN_MENU

SELECT_MENU = {selected = 0, options = {}}

function update_state_machine()
    -- stops all SFX
    sfx(-1)

    -- advances state machine to next state
    -- may run additional logic in between
    if CUR_STATE == STATES.MAIN_MENU then
        CUR_STATE = STATES.CUTSCENE_ZERO_1
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_1 then
        CUR_STATE = STATES.CUTSCENE_ZERO_2
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_2 then
        CUR_STATE = STATES.CUTSCENE_ZERO_3
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_3 then
        CUR_STATE = STATES.CUTSCENE_ZERO_4
    elseif CUR_STATE == STATES.CUTSCENE_ZERO_4 then
        music(3)
        CUR_STATE = STATES.LEVEL_ZERO
    elseif CUR_STATE == STATES.LEVEL_ZERO then
        music(-1)
        CUR_STATE = STATES.END_LEVEL_ZERO
    elseif CUR_STATE == STATES.END_LEVEL_ZERO then
        music(1)
        CUR_STATE = STATES.CALL_THIEF
    elseif CUR_STATE == STATES.CALL_THIEF then
        CUR_STATE = STATES.CUTSCENE_THIEF_1
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_1 then
        CUR_STATE = STATES.CUTSCENE_THIEF_2
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_2 then
        CUR_STATE = STATES.CUTSCENE_THIEF_3
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_3 then
        CUR_STATE = STATES.CUTSCENE_THIEF_4
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_4 then
        CUR_STATE = STATES.CUTSCENE_THIEF_5
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_5 then
        music(3)
        restart_level_vars()
        CUR_STATE = STATES.LEVEL_ONE
    elseif CUR_STATE == STATES.LEVEL_ONE then
        CUR_STATE = STATES.END_LEVEL_ONE
    elseif CUR_STATE == STATES.END_LEVEL_ONE then
        CUR_STATE = STATES.SELECT_MENU_1
    elseif CUR_STATE == STATES.SELECT_MENU_1 then
        music(3)
        restart_level_vars()
        LEVELS.level_one.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.LEVEL_TWO
    elseif CUR_STATE == STATES.LEVEL_TWO then
        CUR_STATE = STATES.END_LEVEL_TWO
    elseif CUR_STATE == STATES.END_LEVEL_TWO then
        CUR_STATE = STATES.SELECT_MENU_2
    elseif CUR_STATE == STATES.SELECT_MENU_2 then
        music(3)
        restart_level_vars()
        LEVELS.level_two.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.LEVEL_THREE
    elseif CUR_STATE == STATES.LEVEL_THREE then
        CUR_STATE = STATES.END_LEVEL_THREE
    elseif CUR_STATE == STATES.END_LEVEL_THREE then
        CUR_STATE = STATES.SELECT_MENU_3
    elseif CUR_STATE == STATES.SELECT_MENU_3 then
        music(3)
        restart_level_vars()
        LEVELS.level_three.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.LEVEL_FOUR
    elseif CUR_STATE == STATES.LEVEL_FOUR then
        CUR_STATE = STATES.END_LEVEL_FOUR
    elseif CUR_STATE == STATES.END_LEVEL_FOUR then
        CUR_STATE = STATES.SELECT_MENU_4
    elseif CUR_STATE == STATES.SELECT_MENU_4 then
        music(3)
        restart_level_vars()
        LEVELS.level_four.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.CUTSCENE_NEWS
    elseif CUR_STATE == STATES.CUTSCENE_NEWS then
        CUR_STATE = STATES.CUTSCENE_FINAL
    else
        init()
    end

    if has_value(PLAYABLE_STATES, CUR_STATE) and CUR_STATE ~= CALL_THIEF then 
        setup_level() 
    end
end
