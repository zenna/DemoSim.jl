module JuliaWorld

# abstract type Space end

# struct Grass <: Space end
# struct Rock <: Space end
# struct Water <: Space end
# struct Dirt <: Space end

@enum Space begin
    grass
    rock
    water
    dirt
end

struct Agent end

mutable struct Grid
    agents::Dict{Agent,Pair{Integer,Integer}}
    spaces::Array{Space,2}
end

@enum Action begin
    up = 1
    down = 2
    left = 3
    right = 4
    stay = 5
end

function generateGrid()
    agents = Dict()
    rows = rand(3:5)
    cols = rand(3:5)
    spaces = rand([grass, rock, water, dirt], (rows, cols))
    return Grid(agents, spaces)
end

end # module
