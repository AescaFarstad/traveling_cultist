require daslib/media
require data_source
require level
require render
require interaction
require debug_draw
require math_2d
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code

var
    level:Level
    input_state:InputState
    mouse:MouseInput

// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Traveling cultist")
    //randomize_seed(level.seed)
    init_level(level, float(get_screen_width()), float(get_screen_height()))
    level.playerSolution <- solution_from_list(convex_hull(level.cities))
    //for e, idx in level.playerSolution.edges, iter_range(level.playerSolution.edges)
    //    dd_label("{idx}", e.p1 + float3(10, 0, -20))
    set_antialiasing(4)
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    translate_input(mouse)
    handle_input(mouse, input_state, level)
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    render_level(level)
    render_interaction(input_state, level)
    render_debug()
    clear_debug()
    return
