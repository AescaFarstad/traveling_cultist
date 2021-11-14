require solver_annealing2opt
require solver_2opt
require solver_3opt
require solver_util
require fio

def combo_solve(var list:array<float2>; var seed:int4&; time_limit:int)
    let totalStartedAt = ref_time_ticks()
    var bestLen = quick_length(list)
    while ref_time_ticks() - totalStartedAt < int64(10000) * int64(time_limit)
        //let startedAt = ref_time_ticks()
        var l := list
        //anneal(l, seed, 200.0, 0.2, 0.997)
        shuffle(l, seed)
        var len = .0
        var newLen = quick_length(l)
        while newLen != len
            while single_2opt_pass(l) {}
            while single_3opt_pass(l) {}
            len = newLen
            newLen = quick_length(l)
        if len < bestLen
            bestLen = len
            list := l
        //let finishedAt = ref_time_ticks()
        //print("One combo iteration took {(finishedAt - startedAt) / int64(10000)}. len:{len}\n")
    let totalFinishedAt = ref_time_ticks()
    print("combo_solve took {(totalFinishedAt - totalStartedAt) / int64(10000)}\n")