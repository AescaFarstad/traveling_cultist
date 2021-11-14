require math

struct Edge
    p1:float3
    p2: float3
    center:float3
    length:float

def create_edge(from, to:float3): Edge
    var e:Edge
    set_edge(e, from, to)
    return <- e

def set_edge(var edge; from, to:float3)
    edge.p1 = from
    edge.p2 = to
    edge.center = (from + to) * 0.5
    edge.length = distance(from, to)

struct Solution
    edges:array<Edge>
    length:float

struct Level
    size:float3
    center:float3
    cities: array<float3>
    seed: int4
    playerSolution:Solution
    aiSolution:array<float3>
    knownLength:float
    id:int
    startingSeed:int4


struct MouseInput
    lmb_isDown:bool
    lmb_wasDown:bool
    pos: float3

struct InputState
    deleteCandidate:float3
    hasDeleteCandidate:bool
    edgeCandidate:int
    dragHull:array<float3>
    intersectedEdges:array<int>
    aboutToDeleteEdges:array<int>
    innerPoints:array<float3>
    hullBaseIdx:int
    hullDir:float
    phantomHull:array<float3>
    interactedWithGame:bool
    interactedWithUI:bool
    showHelp:bool

struct LevelSetting
    seed:int4
    knownLength:float
    density:float
    p_factor:int
    minDst:float
    id:int
    timeLimit:int