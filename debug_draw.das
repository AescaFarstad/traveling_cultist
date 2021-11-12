require daslib/media
require math_2d

var d_point_yellow:array<float3>
var d_circ_yellow:array<float3>
var d_circ_blue:array<float3>
var d_lines_yellow:array<float3>
var d_lines_blue:array<float3>

struct D_label
    text: string
    loc: float3

struct D_arrow
    from:float3
    to:float3
    color: uint

var d_labels:array<D_label>
var d_arrow_color:array<D_arrow>

def dd_point_y(p:float3)
    push(d_point_yellow, p)

def dd_circle_y(p:float3)
    push(d_circ_yellow, p)

def dd_circle_b(p:float3)
    push(d_circ_blue, p)

def dd_line_y(a:float3; b:float3)
    push(d_lines_yellow, a)
    push(d_lines_yellow, b)

def dd_line_b(a:float3; b:float3)
    push(d_lines_blue, a)
    push(d_lines_blue, b)

def dd_arrow_y(a:float3; b:float3)
    push(d_lines_yellow, a)
    push(d_lines_yellow, b)
    let vec = normalize(b - a)
    let arrowHeadSize = min(10.0, length(b - a) * 0.5)
    let head1 = rotate_vec(vec, 0.5)
    let head2 = rotate_vec(vec, -0.5)
    push(d_lines_yellow, b - head1 * arrowHeadSize)
    push(d_lines_yellow, b)
    push(d_lines_yellow, b - head2 * arrowHeadSize)
    push(d_lines_yellow, b)

def dd_label(text: string; p:float3)
    var l:D_label
    l.text = text
    l.loc = p
    push(d_labels, l)

def dd_arrow_color(from, to:float3; color:uint)
    var l:D_arrow
    l.from = from
    l.to = to
    l.color = color
    push(d_arrow_color, l)

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

def render_debug()
    for p in d_point_yellow
        fill_circle(p.x, p.z, 3.0, 0xffff00)
    for p in d_circ_yellow
        circle(p.x, p.z, 7.0, 0xffff00)
    for p in d_circ_blue
        circle(p.x, p.z, 7.0, 0x5555ff)
    for p in d_arrow_color
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
    for l in d_labels
        text_out(l.loc.x, l.loc.z, l.text, 0xffff00)
    var i = length(d_lines_yellow) - 1
    while i > 1
        line(d_lines_yellow[i].x, d_lines_yellow[i].z, d_lines_yellow[i - 1].x, d_lines_yellow[i - 1].z, 0xffff00)
        i -= 2
    i = length(d_lines_blue) - 1
    while i > 1
        line(d_lines_blue[i].x, d_lines_blue[i].z, d_lines_blue[i - 1].x, d_lines_blue[i - 1].z, 0x5555ff)
        i -= 2


def clear_debug()
    clear(d_point_yellow)
    clear(d_circ_yellow)
    clear(d_lines_yellow)
    clear(d_lines_blue)
    clear(d_labels)