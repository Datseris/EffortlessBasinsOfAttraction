struct CyclicContainer{T} <: AbstractVector{T}
    c::Vector{T}
    n::Int
end
CyclicContainer(c) = CyclicContainer(c, 0)

Base.length(c::CyclicContainer) = length(c.c)
Base.size(c::CyclicContainer) = size(c.c)
Base.getindex(c::CyclicContainer, i::Int) = c.c[mod1(i, length(c.c))]
function Base.getindex(c::CyclicContainer)
    c.n += 1
    c[c.n]
end
Base.iterate(c::CyclicContainer, i = 1) = iterate(c.c, i)
Base.getindex(c::CyclicContainer, i) = [c[j] for j in i]

COLORS = [
    "#1B1B1B",
    "#6D44D0",
    "#2CB3BF",
    "#DA5210",
    "#03502A",
    "#866373",
    "white",
    "blue",
]

CCOLORS = CyclicContainer(COLORS)
LINESTYLES = CyclicContainer(["-", ":", "--", "-."])

export COLORS, CCOLORS, LINESTYLES