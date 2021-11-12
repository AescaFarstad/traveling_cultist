require level
require daslib/media
require debug_draw
require math_2d

def render_level(level:Level)
    for c in level.cities
        let isTaken = solution_contains_point(level.playerSolution, c)
        fill_circle(c.x, c.z, isTaken ?  3.0 :  3.0, isTaken ?  0x44ff44 :  0xffffff)
    for e, idx in level.playerSolution.edges, iter_range(level.playerSolution.edges)
        line(e.p1.x, e.p1.z, e.p2.x, e.p2.z, 0xffffff)


def render_interaction(input_state:InputState; level:Level)
    if input_state.hasDeleteCandidate
        let crossSize = 15.0
        let color = 0xff3333
        line(input_state.deleteCandidate.x - crossSize,
             input_state.deleteCandidate.z - crossSize,
             input_state.deleteCandidate.x + crossSize,
             input_state.deleteCandidate.z + crossSize, color)
        line(input_state.deleteCandidate.x - crossSize,
             input_state.deleteCandidate.z + crossSize,
             input_state.deleteCandidate.x + crossSize,
             input_state.deleteCandidate.z - crossSize, color)
        circle(input_state.deleteCandidate.x, input_state.deleteCandidate.z, 12.0, color)
    let hullColor = length(input_state.dragHull) == 0 ? 0xEBAA1F : 0xFCD686
    if input_state.edgeCandidate != -1 && input_state.edgeCandidate < length(level.playerSolution.edges)
        let color = length(input_state.dragHull) == 0 ? 0xEBAA1F : 0xFCD686
        let edge& = level.playerSolution.edges[input_state.edgeCandidate]
        line(edge.p1.x, edge.p1.z, edge.p2.x, edge.p2.z, hullColor)
        //dd_arrow_y(edge.p1, edge.p2)

    for idx in iter_range(input_state.dragHull)
        let idx2 = (idx + 1) % length(input_state.dragHull)
        line(input_state.dragHull[idx].x,input_state.dragHull[idx].z, input_state.dragHull[idx2].x, input_state.dragHull[idx2].z, hullColor)

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
                line(input_state.phantomHull[idx].x,input_state.phantomHull[idx].z, input_state.phantomHull[idx2].x, input_state.phantomHull[idx2].z, phantomColor)
    set_font_name("sans")  // set_font_name("mono"), set_font_name("sans"), set_font_name("*.ttf")
    set_font_size(20)
    text_out(10.0, 10.0, "length: {int(level.playerSolution.length)}", 0xffff00)
    set_font_size(10)
    for e, idx in level.playerSolution.edges, iter_range(level.playerSolution.edges)
        let diff = e.p2 - e.p1
        let offset = abs(diff.x) > abs(diff.z) ? float2(.0,  - 15.0) : float2(8.0, .0)
        text_out(e.center.x + offset.x, e.center.z + offset.y, "{int(e.length)}", 0xffffff)