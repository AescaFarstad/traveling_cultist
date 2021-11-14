require level
require daslib/media
require ui_comps
require data_source

def render_level(level:Level)
    for e, idx in level.playerSolution.edges, iter_range(level.playerSolution.edges)
        line(e.p1.x, e.p1.y, e.p2.x, e.p2.y, 0xffffff)
    for c in level.cities
        let isTaken = solution_contains_point(level.playerSolution, c)
        fill_circle(c.x, c.y, isTaken ?  4.0 :  3.0, isTaken ?  0x44ff44 :  0xffffff)


def render_interaction(mouse:MouseInput; input_state:InputState; level:Level)
    set_font_name("mono")
    if input_state.hasDeleteCandidate
        let crossSize = 15.0
        let color = 0xff3333
        line(input_state.deleteCandidate.x - crossSize,
             input_state.deleteCandidate.y - crossSize,
             input_state.deleteCandidate.x + crossSize,
             input_state.deleteCandidate.y + crossSize, color)
        line(input_state.deleteCandidate.x - crossSize,
             input_state.deleteCandidate.y + crossSize,
             input_state.deleteCandidate.x + crossSize,
             input_state.deleteCandidate.y - crossSize, color)
        circle(input_state.deleteCandidate.x, input_state.deleteCandidate.y, 12.0, color)
    let hullColor = length(input_state.dragHull) == 0 ? 0xEBAA1F : 0xFCD686
    if input_state.edgeCandidate != -1 && input_state.edgeCandidate < length(level.playerSolution.edges)
        let color = length(input_state.dragHull) == 0 ? 0xEBAA1F : 0xFCD686
        let edge& = level.playerSolution.edges[input_state.edgeCandidate]
        line(edge.p1.x, edge.p1.y, edge.p2.x, edge.p2.y, hullColor)

    for idx in iter_range(input_state.dragHull)
        let idx2 = (idx + 1) % length(input_state.dragHull)
        line(input_state.dragHull[idx].x,input_state.dragHull[idx].y, input_state.dragHull[idx2].x, input_state.dragHull[idx2].y, hullColor)

    if length(input_state.dragHull) > 0
        let phantomColor = 0x555555
        let ignoreIdx = length(input_state.dragHull) > 3 ? input_state.hullBaseIdx : 1
        let ignorePoint1 = input_state.dragHull[ignoreIdx]
        let ignorePoint2 = input_state.dragHull[(ignoreIdx + 1)  % length(input_state.dragHull)]
        for idx in iter_range(input_state.phantomHull)
            let idx2 = (idx + 1) % length(input_state.phantomHull)
            var render = input_state.phantomHull[idx] != ignorePoint1 && input_state.phantomHull[idx] != ignorePoint2
            render = render || input_state.phantomHull[idx2] != ignorePoint1 && input_state.phantomHull[idx2] != ignorePoint2
            if render
                line(input_state.phantomHull[idx].x,input_state.phantomHull[idx].y, input_state.phantomHull[idx2].x, input_state.phantomHull[idx2].y, phantomColor)
            fill_circle(input_state.phantomHull[idx].x, input_state.phantomHull[idx].y, 3.0, 0xffff77)
        if input_state.expectedDelta != .0
            set_font_size(14)
            let pos = mouse.pos + float2(10, - 20)
            text_out(pos.x, pos.y, "{int(input_state.expectedDelta)}", input_state.expectedDelta > .0 ? 0xFFB477 : 0xA9FF77)


    set_font_size(18)
    let pathIsfull = length(level.playerSolution.edges) == length(level.cities)
    let rankings = [[tuple<caption:string; color:uint; len:int>
                        [[auto "Deity:    {int(level.knownLength)}", 0xFCFCDF, int(level.knownLength)]];
                        [[auto "Messiah:  {int(level.knownLength * 1.009)}", 0xFFFFB7, int(level.knownLength * 1.009)]];
                        [[auto "Leader:   {int(level.knownLength * 1.019)}", 0xF0F059, int(level.knownLength * 1.019)]];
                        [[auto "Magister: {int(level.knownLength * 1.030)}", 0xDFDF07, int(level.knownLength * 1.030)]];
                        [[auto "Master:   {int(level.knownLength * 1.045)}", 0xE6C639, int(level.knownLength * 1.045)]];
                        [[auto "Adept:    {int(level.knownLength * 1.055)}", 0xD8B041, int(level.knownLength * 1.055)]]
                        ]]
    var coords = float2(10.0, 8.0)
    var step = 22.0
    var playerDisplayed = false
    for r in rankings
        if !playerDisplayed && pathIsfull && int(level.playerSolution.length) <= r.len
            playerDisplayed = true
            text_out(coords.x, coords.y, "You:      {int(level.playerSolution.length)}", 0xffffff)
            coords.y += step
        text_out(coords.x, coords.y, r.caption, r.color)
        coords.y += step
    if !playerDisplayed
        let color = pathIsfull ? 0xffffff : 0xff0000
        text_out(coords.x, coords.y, "You:      {int(level.playerSolution.length)}", color)
        coords.y += step
        set_font_size(14)
        text_out(coords.x, coords.y, "Connect all cities.", 0x813737)
    set_font_name("sans")
    set_font_size(10)
    for e, idx in level.playerSolution.edges, iter_range(level.playerSolution.edges)
        let diff = e.p2 - e.p1
        let offset = abs(diff.x) > abs(diff.y) ? float2(.0,  - 15.0) : float2(8.0, .0)
        text_out(e.center.x + offset.x, e.center.y + offset.y, "{int(e.length)}", 0xC0C0C0)
    //fill_rect(  BAN_RECT.x, BAN_RECT.y, BAN_RECT.z - BAN_RECT.x, BAN_RECT.w - BAN_RECT.y, 0x313B29)
    text_out(5.0, float(get_screen_height()) - 12.0, "id: {level.id} seed:{level.startingSeed}", 0x3A3A3A)

def render_ui(buttons:array<Button>)
    set_font_size(14)
    for button in buttons
        var btnSize = button.size
        var btnPos = button.pos
        var borderColor = 0x7A8175
        if button.hovered
            let p = 2.0
            btnSize = button.size + float2(p, p)
            btnPos = button.pos - float2(p, p) * 0.5
            borderColor = 0x30991B
        if button.clicked
            let p = 4.0
            btnSize = button.size - float2(p, p)
            btnPos = button.pos + float2(p, p) * 0.5
        if button.hovered
            let padding = 4.0
            fill_rect(  btnPos.x + padding,
                        btnPos.y + padding,
                        btnSize.x - padding * 2.0,
                        btnSize.y - padding * 2.0, 0x313B29)
        rect(   btnPos.x,
                btnPos.y,
                btnSize.x,
                btnSize.y, borderColor)
        if button.selected
            let padding = 2.0
            rect(   btnPos.x + padding,
                    btnPos.y + padding,
                    btnSize.x - padding * 2.0,
                    btnSize.y - padding * 2.0, borderColor)
        let textColor = 0xA7A8A5
        let txt = button.hovered && !empty(button.hoverCaption) ? button.hoverCaption : button.caption
        let size = get_text_size(txt)
        let pos = (button.pos + button.size * 0.5) - size * 0.5
        text_out(floor(pos.x), floor(pos.y), txt, textColor)

def render_help()
    set_font_name("sans")
    set_font_size(20)
    var pos = float2(20.0, 20.0)
    let inc = 30.0
    let color = 0x7BAD4B
    text_out(pos.x, pos.y, "You need to create a route going through all points.", color)
    pos.y += inc
    text_out(pos.x, pos.y, "Controls:", color)
    pos.y += inc
    text_out(pos.x, pos.y, "    Click and hold left mouse button next to an edge, drag it over other points. This will insert these points into the route.", color)
    pos.y += inc
    text_out(pos.x, pos.y, "    Click a point to eject it from the route.", color)
    pos.y += inc
    pos.y += inc
    text_out(pos.x, pos.y, "• All scores in the table are theoretically achievable. But may be tough.", color)
    pos.y += inc
    text_out(pos.x, pos.y, "• First 3 levels are fixed, always the same for everybody. Use them to compare your scores", color)
    pos.y += inc
    text_out(pos.x, pos.y, "• The other levels are randomly generated each time. They are a bit easier ;)", color)
    pos.y += inc
    pos.y += inc
    pos.y += inc
    text_out(pos.x, pos.y, "Click anywhere to close.", color)