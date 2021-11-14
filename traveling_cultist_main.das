require daslib/media
require data_source
require level
require render
require interaction
require math_2d
require solver_combo
require ui_comps
require ui
require ui_keys
//require debug_draw
//options debugger            // uncomment for debug in VS Code
//require daslib/debug        // uncomment for debug in VS Code

let padding = float4(100, 80, 40, 80) //top, right, bottom, left

var
    level:Level
    input_state:InputState
    mouse:MouseInput
    buttons:array<Button>

// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Traveling cultist")
    level.size = float2(float(get_screen_width()) - padding.w - padding.y, float(get_screen_height()) - padding.x - padding.z)
    level.center = float2(padding.w + level.size.x * 0.5, padding.x + level.size.y * 0.5)
    load_setting(level, levels[0], BAN_RECT)
    set_antialiasing(16)
    populate_ui(buttons)
    buttons[0].selected = true

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    translate_input(mouse)
    if !input_state.showHelp
        if !input_state.interactedWithGame
            interact_with_ui(mouse, input_state, buttons)
        if !input_state.interactedWithUI
            handle_input(mouse, input_state, level)
        process_buttons(input_state, level, buttons)
    else
        if !mouse.lmb_wasDown && mouse.lmb_isDown
            input_state.showHelp = false

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    if !input_state.showHelp
        render_level(level)
        render_interaction(mouse, input_state, level)
        render_ui(buttons)
        //render_debug()
        //clear_debug()
    else
        render_help()
