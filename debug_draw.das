require daslib/media
require math_2d

struct D_label
    text: string
    loc: float3

struct D_arrow
    from:float3
    to:float3
    color: uint


struct DebugContainer
    d_point_yellow:array<float3>
    d_circ_yellow:array<float3>
    d_circ_blue:array<float3>
    d_circ_red:array<float3>
    d_lines_yellow:array<float3>
    d_lines_blue:array<float3>
    d_labels:array<D_label>
    d_arrow_color:array<D_arrow>

var container1:DebugContainer
var container2:DebugContainer

def render_debug()
    render_debug(container1)
    render_debug(container2)

def render_debug(container:DebugContainer)
    for p in container.d_point_yellow
        fill_circle(p.x, p.z, 3.0, 0xffff33)
    for p in container.d_circ_yellow
        circle(p.x, p.z, 7.0, 0xffff33)
    for p in container.d_circ_blue
        circle(p.x, p.z, 7.0, 0x5555ff)
    for p in container.d_circ_red
        circle(p.x, p.z, 7.0, 0xff0000)
    for p in container.d_arrow_color
        line(p.from.x, p.from.z, p.to.x, p.to.z, p.color)
        let vec = normalize(p.to - p.from)
        let arrowHeadSize = max(8.0, min(15.0, length(p.to - p.from) * 0.5))
        let head1 = rotate_vec(vec, 0.5)
        let head2 = rotate_vec(vec, -0.5)
        let to1 = p.to - head1 * arrowHeadSize
        let to2 = p.to - head2 * arrowHeadSize
        line(to1.x, to1.z, p.to.x, p.to.z, p.color)
        line(to2.x, to2.z, p.to.x, p.to.z, p.color)
    set_font_name("sans")  // set_font_name("mono"), set_font_name("sans"), set_font_name("*.ttf")
    set_font_size(20)
    for l in container.d_labels
        text_out(l.loc.x, l.loc.z, l.text, 0xffff33)
    var i = length(container.d_lines_yellow) - 1
    while i > 1
        line(container.d_lines_yellow[i].x, container.d_lines_yellow[i].z, container.d_lines_yellow[i - 1].x, container.d_lines_yellow[i - 1].z, 0xffff33)
        i -= 2
    i = length(container.d_lines_blue) - 1
    while i > 1
        line(container.d_lines_blue[i].x, container.d_lines_blue[i].z, container.d_lines_blue[i - 1].x, container.d_lines_blue[i - 1].z, 0x5555ff)
        i -= 2


def clear_debug()
    clear_debug(container1)
def clear_debug2()
    clear_debug(container2)

def clear_debug(var container:DebugContainer)
    clear(container.d_point_yellow)
    clear(container.d_circ_yellow)
    clear(container.d_lines_yellow)
    clear(container.d_lines_blue)
    clear(container.d_labels)
    clear(container.d_circ_blue)
    clear(container.d_circ_red)
    clear(container.d_arrow_color)


// ---------------------------------1 ------------------------

def dd_point_y(p:float3)
    push(container1.d_point_yellow, p)

def dd_circle_y(p:float3)
    push(container1.d_circ_yellow, p)

def dd_circle_b(p:float3)
    push(container1.d_circ_blue, p)

def dd_circle_r(p:float3)
    push(container1.d_circ_red, p)

def dd_line_y(a:float3; b:float3)
    push(container1.d_lines_yellow, a)
    push(container1.d_lines_yellow, b)

def dd_line_b(a:float3; b:float3)
    push(container1.d_lines_blue, a)
    push(container1.d_lines_blue, b)

def dd_arrow_y(a:float3; b:float3)
    push(container1.d_lines_yellow, a)
    push(container1.d_lines_yellow, b)
    let vec = normalize(b - a)
    let arrowHeadSize = min(10.0, length(b - a) * 0.5)
    let head1 = rotate_vec(vec, 0.5)
    let head2 = rotate_vec(vec, -0.5)
    push(container1.d_lines_yellow, b - head1 * arrowHeadSize)
    push(container1.d_lines_yellow, b)
    push(container1.d_lines_yellow, b - head2 * arrowHeadSize)
    push(container1.d_lines_yellow, b)

def dd_label(text: string; p:float3)
    var l:D_label
    l.text = text
    l.loc = p
    push(container1.d_labels, l)

def dd_arrow_color(from, to:float3; color:uint)
    var l:D_arrow
    l.from = from
    l.to = to
    l.color = color
    push(container1.d_arrow_color, l)

def dd_polygon(poly:array<float3>)
    for i in iter_range(poly)
        let i2 = (i + 1) % length(poly)
        dd_arrow_y(poly[i], poly[i2])
        let perp = normalize(rotate_vec(poly[i2] - poly[i], PI / 2.0))
        let from = (poly[i2] + poly[i]) * 0.5
        dd_line_b(from, from + perp * 20.0)
        dd_circle_y(poly[i2])

def dd_polygon(poly:array<float3>; color:uint)
    for i in iter_range(poly)
        let i2 = (i + 1) % length(poly)
        dd_arrow_color(poly[i], poly[i2], color)
    dd_circle_b(poly[0])

def dd_order(poly:array<float3>)
    for i in iter_range(poly)
        dd_label("{i}", poly[i])

// ---------------------------------2 ------------------------

def ddd_point_y(p:float3)
    push(container2.d_point_yellow, p)

def ddd_circle_y(p:float3)
    push(container2.d_circ_yellow, p)

def ddd_circle_b(p:float3)
    push(container2.d_circ_blue, p)

def ddd_circle_r(p:float3)
    push(container2.d_circ_red, p)

def ddd_line_y(a:float3; b:float3)
    push(container2.d_lines_yellow, a)
    push(container2.d_lines_yellow, b)

def ddd_line_b(a:float3; b:float3)
    push(container2.d_lines_blue, a)
    push(container2.d_lines_blue, b)

def ddd_arrow_y(a:float3; b:float3)
    push(container2.d_lines_yellow, a)
    push(container2.d_lines_yellow, b)
    let vec = normalize(b - a)
    let arrowHeadSize = min(10.0, length(b - a) * 0.5)
    let head1 = rotate_vec(vec, 0.5)
    let head2 = rotate_vec(vec, -0.5)
    push(container2.d_lines_yellow, b - head1 * arrowHeadSize)
    push(container2.d_lines_yellow, b)
    push(container2.d_lines_yellow, b - head2 * arrowHeadSize)
    push(container2.d_lines_yellow, b)

def ddd_label(text: string; p:float3)
    var l:D_label
    l.text = text
    l.loc = p
    push(container2.d_labels, l)

def ddd_arrow_color(from, to:float3; color:uint)
    var l:D_arrow
    l.from = from
    l.to = to
    l.color = color
    push(container2.d_arrow_color, l)

def ddd_polygon(poly:array<float3>)
    for i in iter_range(poly)
        let i2 = (i + 1) % length(poly)
        ddd_arrow_y(poly[i], poly[i2])
        let perp = normalize(rotate_vec(poly[i2] - poly[i], PI / 2.0))
        let from = (poly[i2] + poly[i]) * 0.5
        ddd_line_b(from, from + perp * 20.0)
        ddd_circle_y(poly[i2])

def ddd_polygon(poly:array<float3>; color:uint)
    if length(poly) == 0
        return
    for i in iter_range(poly)
        let i2 = (i + 1) % length(poly)
        ddd_arrow_color(poly[i], poly[i2], color)
    ddd_circle_b(poly[0])

def ddd_order(poly:array<float3>)
    for i in iter_range(poly)
        ddd_label("{i}", poly[i])