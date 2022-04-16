STATES = {
    MAIN_MENU = 'main_menu',
    CUTSCENE_ZERO_1 = 'cutscene_zero_1',
    CUTSCENE_ZERO_2 = 'cutscene_zero_2',
    CUTSCENE_ZERO_3 = 'cutscene_zero_3',
    CUTSCENE_ZERO_4 = 'cutscene_zero_4',
    LEVEL_ONE = 'level_one',
    CUTSCENE_THIEF_1 = 'cutscene_thief_1',
    CUTSCENE_THIEF_2 = 'cutscene_thief_2',
    CUTSCENE_THIEF_3 = 'cutscene_thief_3',
    CUTSCENE_THIEF_4 = 'cutscene_thief_4',
    SELECT_MENU_1 = "select_menu_1",
    LEVEL_TWO = "level_two",
    SELECT_MENU_2 = "select_menu_2",
    CUTSCENE_NEWS = "cutscene_news",
    CUTSCENE_FINAL = "cutscene_final"
}

SKIPPABLE_STATES = {
    STATES.MAIN_MENU, STATES.CUTSCENE_ZERO_1, STATES.CUTSCENE_ZERO_2,
    STATES.CUTSCENE_ZERO_3, STATES.CUTSCENE_ZERO_4, STATES.CUTSCENE_THIEF_1,
    STATES.CUTSCENE_THIEF_2, STATES.CUTSCENE_THIEF_3, STATES.CUTSCENE_THIEF_4,
    STATES.CUTSCENE_NEWS, STATES.CUTSCENE_FINAL
}

PLAYABLE_STATES = { STATES.LEVEL_ONE, STATES.LEVEL_TWO }

CUR_STATE = STATES.MAIN_MENU

SELECT_MENU = { selected = 0, options = {} }

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
        CUR_STATE = STATES.LEVEL_ONE
    elseif CUR_STATE == STATES.LEVEL_ONE then
        sfx(13, 60, 18, 3, 6)
        music(1)
        CUR_STATE = STATES.CUTSCENE_THIEF_1
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_1 then
        CUR_STATE = STATES.CUTSCENE_THIEF_2
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_2 then
        CUR_STATE = STATES.CUTSCENE_THIEF_3
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_3 then
        CUR_STATE = STATES.CUTSCENE_THIEF_4
    elseif CUR_STATE == STATES.CUTSCENE_THIEF_4 then
        CUR_STATE = STATES.SELECT_MENU_1
    elseif CUR_STATE == STATES.SELECT_MENU_1 then
        music(3)
        LEVELS.level_one.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.LEVEL_TWO
    elseif CUR_STATE == STATES.LEVEL_TWO then
        CUR_STATE = STATES.SELECT_MENU_2
    elseif CUR_STATE == STATES.SELECT_MENU_2 then
        LEVELS.level_two.chosen = SELECT_MENU.options[SELECT_MENU.selected + 1]
        CUR_STATE = STATES.CUTSCENE_NEWS
    elseif CUR_STATE == STATES.CUTSCENE_NEWS then
        CUR_STATE = STATES.CUTSCENE_FINAL
    else
        init()
    end

    if has_value(PLAYABLE_STATES, CUR_STATE) then setup_level() end
end
