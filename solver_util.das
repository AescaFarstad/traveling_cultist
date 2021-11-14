require random
require math

def shuffle(var list:array<float3>; var seed:int4&)
    let len = length(list)
    if len < 2
        return
    for i in range(len - 1)
        let k = random_int(seed) % (len - i) + i
        swap(list[i], list[k])

def reverse_sequence(var list:array<float3>; from_idx, to_idx:int)
    let len = length(list)
    let reverse = (to_idx - from_idx + len) % len < (from_idx - to_idx + len) % len
    let from = reverse ? to_idx : from_idx
    let to = reverse ? from_idx + len : to_idx

    var i = from
    while i < to  && i < to - i + from
        let idx1 = i % len
        let idx2 = (to - i + from - 1) % len
        swap(list[idx1], list[idx2])
        i++

def calc_swap_cost(list:array<float3>; p1, p2, p3, p4: int)
    return distance(list[p1], list[p3]) - distance(list[p1], list[p2]) + distance(list[p2], list[p4]) - distance(list[p3], list[p4])

def quick_length(list:array<float3>)
    var result = .0
    let len = length(list)
    for i in range(len)
        let k = (i + 1) % len
        result += distance(list[i], list[k])
    return result