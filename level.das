require math
require daslib/random
require debug_draw
require math_2d
require dasbox
require solver_util
require solver_combo
require model public


def reset_level(var level:Level)
    var list := level.cities
    level.playerSolution <- solution_from_list(convex_hull(list))
    return

def load_setting(var level:Level; setting:LevelSetting; ban_rect:float4)
    clear(level.cities)
    if setting.seed != int4()
        level.seed = setting.seed
    else
        debug("asferfresd")
        randomize_seed(level.seed)
    level.startingSeed = level.seed
    let numCities = int(level.size.x * level.size.z * setting.density)
    add_cities(level, numCities, setting.minDst, setting.p_factor, ban_rect)
    level.playerSolution <- solution_from_list(convex_hull(level.cities))
    level.id = setting.id
    if setting.knownLength > .0
        level.knownLength = setting.knownLength
    else
        level.aiSolution := level.cities
        combo_solve(level.aiSolution, level.seed, setting.timeLimit)
        level.knownLength = quick_length(level.aiSolution)
    return

def add_cities(var level:Level; num: int; min_dst:float; p_factor:int; ban_rect:float4)
    var left = num
    let bufferSq = min_dst * min_dst
    var itersLeft = 1000000
    while left >= 0 && itersLeft-- > 0
        var bestLoc: float3
        var bestDstSq = -1.0
        for it in range(p_factor)
            let loc = level.center - level.size * 0.5 + float3( random_float(level.seed) * level.size.x, .0,
                                                                random_float(level.seed) * level.size.z)
            if loc.x > ban_rect.x && loc.z > ban_rect.y && loc.x < ban_rect.z && loc.z < ban_rect.w
                continue
            var minDstSq = FLT_MAX
            for p in level.cities
                minDstSq = min(minDstSq, distance_sq(p, loc))
            if minDstSq > bestDstSq && minDstSq > bufferSq
                bestDstSq = minDstSq
                bestLoc = loc
        if bestDstSq > .0
            level.cities |> push(bestLoc)
            left--

def solution_from_list(list:array<float3>): Solution
    if length(list) < 2
        return <- [[Solution]]
    var solution:Solution
    for idx in iter_range(list)
        let nextIdx = (idx + 1) % length(list)
        let edge = create_edge(list[idx], list[nextIdx])
        solution.length += edge.length
        push(solution.edges, edge)
    return <- solution

def solution_delete_point(var solution:Solution; target:float3)
    var edgeFromIdx = -1
    var edgeToIdx = -1
    for e, idx in solution.edges, iter_range(solution.edges)
        if e.p1 == target
            edgeToIdx = idx
        if e.p2 == target
            edgeFromIdx = idx
    if edgeFromIdx == -1 || edgeToIdx == -1
        //debug("ERROR, target point does not exist in the solution, can't delete")
        return false
    var edgeFrom & = solution.edges[edgeFromIdx]
    var edgeTo & = solution.edges[edgeToIdx]
    let oldLength = edgeFrom.length
    set_edge(edgeFrom, edgeFrom.p1, edgeTo.p2)
    solution.length -= oldLength
    solution.length -= edgeTo.length
    solution.length += edgeFrom.length
    erase(solution.edges, edgeToIdx)
    return true

def solution_contains_point(solution:Solution; p:float3)
    for e in solution.edges
        if e.p1 == p
            return true
    return false

def find_edge_index(solution:Solution; p1, p2:float3)
    for e, idx in solution.edges, iter_range(solution.edges)
        if e.p1 == p1 && e.p2 == p2
            return idx
    return -1

def solution_insert_into_edge(var solution:Solution; edge_idx:int; hull:array<float3>)
    var trackEdgeIdx = edge_idx
    var prev = solution.edges[edge_idx].p1
    for p in hull
        push(solution.edges, create_edge(prev, p), trackEdgeIdx)
        prev = p
        trackEdgeIdx++
    set_edge(solution.edges[trackEdgeIdx], prev, solution.edges[trackEdgeIdx].p2)
    update_solution_length(solution)

def update_solution_length(var solution:Solution)
    solution.length = .0
    for e in solution.edges
        solution.length += e.length