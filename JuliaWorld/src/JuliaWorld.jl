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

function evolveGridOneStep(grid::Grid)
    dims = size(grid.spaces)
    r = rand(1:dims[1])
    c = rand(1:dims[2])
    grid.spaces[r,c] = rand([grass, rock, water, dirt])
end

function evolveGridFromAction(agent::Agent, grid::Grid, action::Action)
    # assert agent in grid.agents keys
    @assert agent in keys(grid.agents)
    # compute new loc
    action_map = Dict{Action,Pair{Integer,Integer}}(up=>Pair(-1,0),down=>Pair(1,0),left=>Pair(0,-1),right=>Pair(0,1),stay=>Pair(0,0))
    old_loc = grid.agents[agent]
    drdc = action_map[action]
    new_loc = Pair(old_loc[1]+drdc[1], old_loc[2]+drdc[2])
    # clamp
    dims = size(grid.spaces)
    clamped_r = clamp(new_loc[1], 1, dims[1])
    clamped_c = clamp(new_loc[2], 1, dims[2])
    # update agent loc in grid
    grid.agents[agent] = Pair(clamped_r, clamped_c)
end

function main()
    grid = generateGrid()
    agent = Agent()
    grid.agents[agent] = Pair(1,1)
    evolveGridFromAction(agent, grid, right)
end

end # module
