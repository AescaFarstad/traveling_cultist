require level
require math
require debug_draw
require math_2d
require daslib/media

let city_radius_sq = 10.0 * 10.0
let edge_interaction_dst = 0.0

def translate_input(var input:MouseInput)
    let becameDown = get_mouse_button_down(MB_LEFT)
    let becameUp = get_mouse_button_up(MB_LEFT)
    input.lmb_wasDown = input.lmb_isDown
    input.lmb_isDown = becameDown || input.lmb_isDown
    input.lmb_isDown = !becameUp && input.lmb_isDown
    let mousePosR = get_mouse_position()
    input.pos = float3(mousePosR.x, .0, mousePosR.y)

def handle_input(mouse:MouseInput; var input_state:InputState; var level:Level)
    input_state.interactedWithGame = false
    if length(level.playerSolution.edges) == 0
        return
    if !mouse.lmb_isDown && !mouse.lmb_wasDown
        input_state.edgeCandidate = -1

    input_state.hasDeleteCandidate = false
    clear(input_state.dragHull)
    clear(input_state.intersectedEdges)
    clear(input_state.aboutToDeleteEdges)
    clear(input_state.innerPoints)
    clear(input_state.phantomHull)
    if !mouse.lmb_wasDown
        for e in level.playerSolution.edges
            if distance_sq(e.p1, mouse.pos) < city_radius_sq
                input_state.deleteCandidate = e.p1
                input_state.hasDeleteCandidate = true
                break
    if !mouse.lmb_isDown && !mouse.lmb_wasDown
        var nearestEdge = -1
        var nearestEdgeDst = FLT_MAX
        for e, idx in level.playerSolution.edges, iter_range(level.playerSolution.edges)
            let dst = distance_from_point_to_segment(mouse.pos, e.p1, e.p2)
            if dst < nearestEdgeDst
                nearestEdgeDst = dst
                nearestEdge = idx
        if nearestEdgeDst < edge_interaction_dst + 2.5 * sqrt(level.playerSolution.edges[nearestEdge].length) && !input_state.hasDeleteCandidate
            input_state.edgeCandidate = nearestEdge

    if !mouse.lmb_wasDown && mouse.lmb_isDown && length(level.playerSolution.edges) > 3
        if input_state.hasDeleteCandidate
            solution_delete_point(level.playerSolution, input_state.deleteCandidate)
            input_state.interactedWithGame = true

    if mouse.lmb_wasDown && input_state.edgeCandidate != -1 && input_state.edgeCandidate < length(level.playerSolution.edges)
        input_state.interactedWithGame = true
        let edge& = level.playerSolution.edges[input_state.edgeCandidate]
        input_state.dragHull <- build_hull(mouse.pos, edge, input_state.hullBaseIdx)
        input_state.hullDir = cross2d(edge.p2 - edge.p1, mouse.pos - edge.p1) > 0.0 ? 1.0 : -1.0
        fill_inner_points(input_state, level)
        fill_phantom_hull(input_state, level)
        if !mouse.lmb_isDown
            let p1 = edge.p1
            let p2 = edge.p2
            for p in input_state.innerPoints
                if p != p1 && p != p2
                    solution_delete_point(level.playerSolution, p)
            let eidx = find_edge_index(level.playerSolution, p1, p2)
            let hullIdx = find_edge_in_hull_index(input_state.phantomHull, p1, p2)
            var hull:array<float3>
            if input_state.hullDir > .0
                for i in range(1, length(input_state.phantomHull) - 1)
                    let idx = (hullIdx - i + length(input_state.phantomHull)) % length(input_state.phantomHull)
                    push(hull, input_state.phantomHull[idx])
            else
                let hullIdx2 = (hullIdx + 1) % length(input_state.phantomHull)
                for i in range(1, length(input_state.phantomHull) - 1)
                    let idx = (i + hullIdx + 1)  % length(input_state.phantomHull)
                    push(hull, input_state.phantomHull[idx])
            solution_insert_into_edge(level.playerSolution, eidx, hull)

def find_edge_in_hull_index(hull:array<float3>; p1, p2:float3)
    for e, idx in hull, iter_range(hull)
        let idx2 = (idx + 1) % length(hull)
        if hull[idx] == p1 && hull[idx2] == p2 || hull[idx] == p2 && hull[idx2] == p1
            return idx
    return -1

def build_hull(head:float3; source:Edge; var baseIdx: int&)
    let dst = distance_from_point_to_segment(head, source.p1, source.p2)
    if dst > source.length * 0.4 || dst > 40.0
        return <- build_skewed_parabola(head, source, baseIdx)
    else
        var result:array<float3>
        push(result, head)
        push(result, source.p1)
        push(result, source.p2)
        baseIdx = 1
        return <- result

def build_skewed_parabola(head:float3; source:Edge; var baseIdx: int&)
    var result:array<float3>
    push(result, head)
    add_parabolized_edge(result, head, source.p1, source.center, false)
    baseIdx = length(result) - 1
    add_parabolized_edge(result, head, source.p2, source.center, true)
    return <- result


def add_parabolized_edge(var result:array<float3>; head, base, origin:float3; inserse:bool)
    let mainEdgeLength = length(head - base)
    let divCount = max(15.0, ceil(mainEdgeLength / 45.0))
    let phi = asin(dot(normalize(head - base), normalize(head - origin)))
    let alpha = phi / (divCount)
    let sign = cross2d((base - origin), (head - origin)) > .0 ? -1.0 : 1.0
    var refFrame = normalize(rotate_vec(origin - head, PI * 0.5 * sign))
    if inserse
        push(result, base)
    for k in range(int(divCount))
        let i = inserse ? int(divCount) - 1 - k : k
		let point = rotate_vec(refFrame, -alpha * sign * float(i));
        let vertx = head + point * nlerp(.0, 10.0, divCount, mainEdgeLength, 1.6, float(i))
        push(result, vertx)
    if !inserse
        push(result, base)


def fill_inner_points(var input_state:InputState; level:Level)
    if length(input_state.dragHull) <= 3
        add_inner_points(input_state.innerPoints, input_state.dragHull, level.cities, input_state.hullDir)
    else //hull isn't necessarily convex, so split it into convex halves
        var subHull1:array<float3>
        var subHull2:array<float3>
        let upToIdx =  (distance_sq(input_state.dragHull[input_state.hullBaseIdx], input_state.dragHull[0]) >
                        distance_sq(input_state.dragHull[input_state.hullBaseIdx + 1], input_state.dragHull[0])) ? input_state.hullBaseIdx + 1 : input_state.hullBaseIdx
        for idx in iter_range(input_state.dragHull)
            if idx <= upToIdx
                push(subHull1, input_state.dragHull[idx])
            if idx >= upToIdx
                push(subHull2, input_state.dragHull[idx])
        push(subHull2, input_state.dragHull[0])
        add_inner_points(input_state.innerPoints, subHull1, level.cities, input_state.hullDir)
        add_inner_points(input_state.innerPoints, subHull2, level.cities, input_state.hullDir)
    if find_index(input_state.innerPoints, input_state.dragHull[input_state.hullBaseIdx]) == -1
        push(input_state.innerPoints, input_state.dragHull[input_state.hullBaseIdx])
    if find_index(input_state.innerPoints, input_state.dragHull[input_state.hullBaseIdx + 1]) == -1
        push(input_state.innerPoints, input_state.dragHull[input_state.hullBaseIdx + 1])

def add_inner_points(var result:array<float3>; hull:array<float3>; points:array<float3>; dir:float)
    for p in points
        if test_point_in_polygon(p, hull, dir) > .0
            push(result, p)

def fill_phantom_hull(var input_state:InputState; level:Level)
    var hull <- convex_hull(input_state.innerPoints)
    input_state.phantomHull <- hull
    return