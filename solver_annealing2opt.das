require math
require random
require solver_util

def anneal(var list:array<float2>; var seed:int4&; start_temperature, end_temperature, cooling:float; iters_per_cycle:int = 100)
    var temperature = start_temperature
    let len = length(list)
    while temperature > end_temperature
        for i in range(iters_per_cycle)
            let p1 = random_int(seed) % len
            let p2 = (p1 + 1) % len
            let p0 = (p1 - 1 + len) % len
            let p3 = random_int(seed) % len
            let p4 = (p3 + 1) % len

            if (list[p3] == list[p0] ||
                list[p3] == list[p1] ||
                list[p3] == list[p2])
                continue

            let cost = calc_swap_cost(list, p1, p2, p3, p4)
            let tolerance = random_float(seed)
            let scaledCost = exp(-cost / temperature)
            if scaledCost > tolerance
                reverse_sequence(list, p2, p4)
        temperature *= cooling



