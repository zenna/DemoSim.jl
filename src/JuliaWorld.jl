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

struct Agent 
    preferences::Dict{Space,Integer}
end

mutable struct Grid
    agents::Dict{Agent,Pair{Integer,Integer}}
    spaces::Array{Space,2}
    values::Dict{Space,Integer}
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
    values = Dict{Space,Integer}(grass=>1,rock=>2,water=>3,dirt=>4)
    return Grid(agents, spaces, values)
end

function evolveGridOneStep!(grid::Grid)
    dims = size(grid.spaces)
    r = rand(1:dims[1])
    c = rand(1:dims[2])
    grid.spaces[r,c] = rand([grass, rock, water, dirt])
end

function evolveGridFromAction!(agent::Agent, grid::Grid, action::Action)
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
    # compute reward
    type = grid.spaces[clamped_r,clamped_c]
    reward = grid.values[type] * agent.preferences[type]
    return reward
end

function agentSelectAction(agent::Agent, grid::Grid)
    @assert agent in keys(grid.agents)
    action = rand([up, down, left, right, stay])
    return action
end

function main()
    grid = generateGrid()
    prefs = Dict{Space,Integer}(grass=>1,rock=>2,water=>3,dirt=>4)
    agent = Agent(prefs)
    grid.agents[agent] = Pair(1,1)
    total_reward = 0
    for t in 1:10
        evolveGridOneStep!(grid)
        action = agentSelectAction(agent, grid)
        reward = evolveGridFromAction!(agent, grid, action)
        total_reward += reward
        @show grid
        @show reward
        @show total_reward
    end
end

end # module
