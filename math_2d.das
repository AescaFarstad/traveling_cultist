require math

def distance(a, b:float2)
    return length(a - b)

def distance_sq(a, b:float2)
    return length_sq(a - b)


def signed_point_to_line_distance(p, from, to: float2)
    if from.x == to.x
        if from.y == to.y
            return .0
        return from.x - p.x
    let A = from.y - to.y
    let B = to.x - from.x
    let C = from.x * to.y - to.x * from.y
    return (A * p.x + B * p.y + C) / sqrt(A * A + B * B)


def test_point_in_polygon(p:float2; polygon; dir:float = 1.0)
    for from, idx in polygon, iter_range(polygon)
        let to = polygon[(idx + 1) % length(polygon)]
        let relation = (from.x - p.x) * (to.y - p.y) - (from.y - p.y) * (to.x - p.x)
        if relation * dir >= 0.0
            return relation == 0.0 ? .0 : -1.0
    return 1.0


def distance_from_point_to_segment(p, s1, s2:float2)
    let v1 = s2 - s1
    let v2 = p - s1
    let len = length_sq(v1)
    if len == .0
        return length(v2)
    let t = dot(v1, v2) / len

    if t <= 0.0
        return length(v2)
    if t >= 1.0
        return length(p - s2)
    return abs(dot(v2, float2(v1.y, -v1.x)) / sqrt(len))

def cross2d(a, b: float2)
    return a.y * b.x - a.x * b.y

def lerp(x1, y1, x2, y2, arg)
    if x1 == x2
        return y1 == y2 ? y1 : .0
    return (arg  - x1) * (y1 - y2) / (x1 - x2) + y1

def nlerp(x1, y1, x2, y2, power, arg)
    if x1 == x2
        return y1 == y2 ? y1 : .0
    let x1u = pow(x1, power)
    let x2u = pow(x2, power)
    let argu = pow(arg, power)
    return (argu - x1u) * (y1 - y2) / (x1u - x2u) + y1

def rotate_vec(vec:float2; angle:float)
    var s, c : float
    sincos(angle, s, c)
    return float2(vec.x * c - vec.y * s, vec.x * s + vec.y * c)


def test_segment_intersection(s11, s12, s21, s22:float2): int //0 == overlap at end points, 1 = intersect, -1 = don't
    if s11 == s21 || s11 == s22 || s12 == s21 || s12 == s22
        return 0
    if (min(s11.x, s12.x) > max(s21.x, s22.x) ||
        min(s11.y, s12.y) > max(s21.y, s22.y) ||
        min(s21.x, s22.x) > max(s11.x, s12.x) ||
        min(s21.y, s22.y) > max(s11.y, s12.y))
        return -1

    var intersectionPoint:float2
    if !line_line_intersection(s11, s12, s21, s22, intersectionPoint)
        return -1
    else
        let tolerance = 0.00001
        let res = ( min(s11.x, s12.x) - intersectionPoint.x < tolerance &&  max(s11.x,s12.x) - intersectionPoint.x > -tolerance &&
                    min(s11.y, s12.y) - intersectionPoint.y < tolerance &&  max(s11.y,s12.y) - intersectionPoint.y > -tolerance &&
                    min(s21.x, s22.x) - intersectionPoint.x < tolerance &&  max(s21.x,s22.x) - intersectionPoint.x > -tolerance &&
                    min(s21.y, s22.y) - intersectionPoint.y < tolerance &&  max(s21.y,s22.y) - intersectionPoint.y > -tolerance)
		return res ? 1 : -1

def line_line_intersection(s11, s12, s21, s22:float2; var output: float2&)
    let A1 = s12.y - s11.y
    let B1 = s11.x - s12.x
    let C1 = A1 * s11.x + B1 * s11.y

    let A2 = s22.y - s21.y
    let B2 = s21.x - s22.x
    let C2 = A2 * s21.x + B2 * s21.y

    let det = A1 * B2 - A2 * B1
    if det == .0
        return false
    output.x = (B2 * C1 - B1 * C2) / det
    output.y = (A1 * C2 - A2 * C1) / det
    return true

def convex_hull(source:array<float2>)
    if length(source) <= 3
        return <- clone_to_move(source)

    var maxX = source[0].x
    var maxXIdx = 0
    var minX = source[0].x
    var minXIdx = 0
    for p, idx in source, iter_range(source)
        if maxX < p.x
            maxX = p.x
            maxXIdx = idx
        if minX > p.x
            minX = p.x
            minXIdx = idx

    var list:array<float2>
    push(list, source[maxXIdx])
    push(list, source[minXIdx])
    var outside := source
    if minXIdx > maxXIdx
        erase(outside, minXIdx)
        erase(outside, maxXIdx)
    else
        erase(outside, maxXIdx)
        erase(outside, minXIdx)

    while length(outside) > 0
        var i = 0
        while i < length(list)
            if !extend_hull(list, outside, i)
                i++
    return <- list


def extend_hull(var hull: array<float2>; var outside:array<float2>; from: int)
    let to = (from + 1) % length(hull)
    var maxP = 0
    var maxDst = -1.0
    for idx in iter_range(outside)
        let dst = signed_point_to_line_distance(outside[idx], hull[from], hull[to])
        if dst > maxDst
            maxDst = dst
            maxP = idx
    if maxDst > .0
        var newOutside:array<float2>
        let polygon = [[float2[3] hull[from]; outside[maxP]; hull[to]]]
        for p in outside
            if test_point_in_polygon(p, polygon) < 0.0
                push(newOutside, p)
        push(hull, outside[maxP], to)
        outside := newOutside
    return maxDst > .0