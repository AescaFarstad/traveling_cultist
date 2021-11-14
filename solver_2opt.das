require math
require solver_util

require debug_draw

def single_2opt_pass(var list:array<float3>)
    let len = length(list)
    var hasChange = false
    for p1 in range(len)
        for k in range(p1 + 2, len - 1)
            let p2 = (p1 + 1) % len
            let p3 = k % len
            let p4 = (p3 + 1) % len
            let cost = calc_swap_cost(list, p1, p2, p3, p4)
            if cost < 0.0
                hasChange = true
                reverse_sequence(list, p2, p4)
    return hasChange