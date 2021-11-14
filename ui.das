require level
require ui_comps
require ui_keys
require data_source

let captions = [[string[6]
                "Gather followers\n       in Bodø";
                "Hypnotise masses\n       in Nantes";
                "Establish a lodge\n      in Caracas";
                "  Preach to random  \nvillagers in Wyoming";
                "Give out pamphlets\n  to random Turks";
                "Realise the futility\nof your endeavour"]]

def populate_ui(var buttons:array<Button>)
    var button:Button
    var btnX = 180.0
    var btnY = 10.0
    var btnWidth = 156.0
    var btnHeight = 52.0
    var btnGap = 12.0
    let keys = [[auto UI_KEY_LEVEL_1; UI_KEY_LEVEL_2; UI_KEY_LEVEL_3; UI_KEY_LEVEL_4; UI_KEY_LEVEL_5; UI_KEY_LEVEL_6]]
    for level, idx in levels, iter_range(levels)
        button.size = float2(btnWidth, btnHeight)
        button.pos = float2(btnX, btnY)
        btnX += btnWidth + btnGap
        button.caption = captions[idx]
        button.key = keys[idx]
        push(buttons, button)

    button.size = float2(btnWidth * 0.5, btnHeight)
    button.pos = float2(btnX, btnY)
    button.caption = "How to"
    button.hoverCaption = "...play"
    button.key = UI_KEY_HOW_TO
    push(buttons, button)

def interact_with_ui(mouse:MouseInput; var input_state:InputState; var buttons:array<Button>)
    input_state.interactedWithUI = false
    for button in buttons
        button.clicked = false
        if hit_test(mouse.pos.xz, button)
            button.hovered = true
            if !mouse.lmb_wasDown && mouse.lmb_isDown
                button.clicked = true
                input_state.interactedWithUI = true
        else
            button.hovered = false

def process_buttons(var input_state:InputState; var level:Level; var buttons:array<Button>)
    for button in buttons
        if button.clicked
            proccess_action(button.key, input_state, level, buttons)


def proccess_action(key:int; var input_state:InputState; var level:Level; var buttons:array<Button>)
    if key == UI_KEY_LEVEL_1
        on_level_btn_click(0, input_state, level, buttons)
    if key == UI_KEY_LEVEL_2
        on_level_btn_click(1, input_state, level, buttons)
    if key == UI_KEY_LEVEL_3
        on_level_btn_click(2, input_state, level, buttons)
    if key == UI_KEY_LEVEL_4
        on_level_btn_click(3, input_state, level, buttons)
    if key == UI_KEY_LEVEL_5
        on_level_btn_click(4, input_state, level, buttons)
    if key == UI_KEY_LEVEL_6
        on_level_btn_click(5, input_state, level, buttons)
    if key == UI_KEY_HOW_TO
        input_state.showHelp = true

def on_level_btn_click(idx:int; var input_state:InputState; var level:Level; var buttons:array<Button>)
    input_state.hasDeleteCandidate = false
    input_state.edgeCandidate = -1
    clear(input_state.dragHull)
    clear(input_state.innerPoints)
    clear(input_state.phantomHull)
    if level.id == idx
        reset_level(level)
        buttons[idx].hoverCaption = "RESET PATH"
    else
        load_setting(level, levels[idx], BAN_RECT)
        for i in range(6)
            buttons[i].selected = i == level.id
            buttons[i].hoverCaption = i == level.id ? "RESET PATH" : ""