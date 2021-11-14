require math
require math_2d

struct Edge
    p1:float2
    p2: float2
    center:float2
    length:float

def create_edge(from, to:float2): Edge
    var e:Edge
    set_edge(e, from, to)
    return <- e

def set_edge(var edge; from, to:float2)
    edge.p1 = from
    edge.p2 = to
    edge.center = (from + to) * 0.5
    edge.length = distance(from, to)

struct Solution
    edges:array<Edge>
    length:float

struct Level
    size:float2
    center:float2
    cities: array<float2>
    seed: int4
    playerSolution:Solution
    aiSolution:array<float2>
    knownLength:float
    id:int
    startingSeed:int4

struct MouseInput
    lmb_isDown:bool
    lmb_wasDown:bool
    pos: float2

struct InputState
    deleteCandidate:float2
    hasDeleteCandidate:bool
    edgeCandidate:int
    dragHull:array<float2>
    intersectedEdges:array<int>
    aboutToDeleteEdges:array<int>
    innerPoints:array<float2>
    hullBaseIdx:int
    hullDir:float
    phantomHull:array<float2>
    expectedDelta:float
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