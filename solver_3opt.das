require math
require solver_util
require debug_draw

/* variables meaning:
N points starting with 'first' and ending with 'last' will be
ejected from one place (surrounded by 'prev' and 'next')
and inserted into another place - between k and k2
prev -> point -> ... -> last -> next => k -> k2
*/

def single_3opt_pass(var list:array<float3>; limit_span:int = 20)
    let len = length(list)
    var hasChange = false
    var limit = min(limit_span, len / 2)

    var first: int
    for i in range(len)
        var prev = first
        first = (first + 1) % len

        var bestPlace = -1
        var bestN = -1
        var direction = 1
        var bestValue = .0

        for k in range(len)
            let k2 = (k + 1) % len
            let prevToFirst = distance(list[prev], list[first])
            let newToFirst = distance(list[k], list[first])
            let newToNext = distance(list[k], list[k2])
            let nextToLast = distance(list[k2], list[first])

            let cache1 = -prevToFirst + newToFirst - newToNext
            let cache2 = -prevToFirst + nextToLast - newToNext

            var next = (first + 1) % len
            for n in range(1, limit)
                var last = next
                next = (first + n) % len
                let firstToK = k > first ? k - first : k + len - first
                let lastTok2 = last > k2 ? last - k2 : last + len - k2
                if firstToK > n && lastTok2 > n && k != first && k != last && k2 != first && k2 != last
                    let lastToNext_prevToNext = distance(list[prev], list[next]) - distance(list[last], list[next])
                    let lengthChange1 = cache1 + lastToNext_prevToNext + distance(list[last], list[k2])
                    let lengthChange2 = cache2 + lastToNext_prevToNext + distance(list[last], list[k])
                    if lengthChange1 < bestValue
                        bestPlace = k2
                        bestN = n
                        bestValue = lengthChange1
                        direction = 1
                    if lengthChange2 < bestValue
                        bestPlace = k2
                        bestN = n
                        bestValue = lengthChange2
                        direction = -1
                else
                    break
        if bestValue < .0
            hasChange = true
            var newList:array<float3>
            reserve(newList, len)
            for m in range(len - bestN)
                let idx = (first + bestN + m) % len
                if idx == bestPlace
                    if direction > 0
                        for w in range(bestN)
                            let idxi = (first + w) % len
                            push(newList, list[idxi])
                    else
                        for w in range(bestN)
                            let idxi = (first + bestN - 1 - w + len) % len
                            push(newList, list[idxi])
                push(newList, list[idx])
            list := newList
    return hasChange