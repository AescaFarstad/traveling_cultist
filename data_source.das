require Level

let
    padding = float4(100, 100, 50, 100) //top, right, bottom, left
    cityDensity = 0.0001

def init_level(var level:Level; width, height:float)
    level.size = float3(width - padding.w - padding.y, 0.0, height - padding.x - padding.z)
    level.center = float3(padding.w + level.size.x * 0.5, 0.0, padding.x + level.size.z * 0.5)
    add_cities(level, int(level.size.x * level.size.z * cityDensity))
