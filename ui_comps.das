struct Button
    size:float2
    pos:float2
    caption:string
    hoverCaption:string
    selected:bool
    hovered:bool
    clicked:bool
    key:int

def hit_test(pos:float2; button:Button)
    return (pos.x > button.pos.x &&
            pos.y > button.pos.y &&
            pos.x < button.pos.x + button.size.x &&
            pos.y < button.pos.y + button.size.y)