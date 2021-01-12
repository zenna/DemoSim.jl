module JuliaWorld

using GLMakie

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
    agents::Dict{Agent,Pair{Integer,Integer}}  # location of agents
    spaces::Array{Space,2}
    values::Dict{Space,Integer}  # intrinsic to each space
end

@enum Action begin
    up = 1
    down = 2
    left = 3
    right = 4
    stay = 5
end

function generategrid()
    agents = Dict()
    rows = rand(3:5)
    cols = rand(3:5)
    spaces = rand([grass, rock, water, dirt], (rows, cols))
    values = Dict{Space,Int64}(grass=>1,rock=>2,water=>3,dirt=>4)
    return rows, cols, Grid(agents, spaces, values)
end

function evolvegridonestep!(grid::Grid)
    dims = size(grid.spaces)
    r = rand(1:dims[1])
    c = rand(1:dims[2])
    grid.spaces[r,c] = rand([grass, rock, water, dirt])
end

function evolvegridfromaction!(agent::Agent, grid::Grid, action::Action)::Int64
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

function agentselectaction(agent::Agent, grid::Grid)
    @assert agent in keys(grid.agents)
    action = rand([up, down, left, right, stay])
    return action
end

function main()
    rows, cols, grid = generategrid()
    prefs = Dict{Space,Int64}(grass=>1,rock=>2,water=>3,dirt=>4)
    agent = Agent(prefs)
    grid.agents[agent] = Pair(1,1)
    total_reward = 0
    for t in 1:10
        evolvegridonestep!(grid)
        action = agentselectaction(agent, grid)
        reward = evolvegridfromaction!(agent, grid, action)
        total_reward += reward
        @show grid
        @show reward
        @show total_reward
    end
end

function animate()
    ITERS = 20
    rows, cols, grid = generategrid()
    prefs = Dict{Space,Integer}(grass=>1,rock=>2,water=>3,dirt=>4)
    agent = Agent(prefs)
    grid.agents[agent] = Pair(1,1)
    total_reward = 0

    # Makie visualization
    fig = Figure(resolution=(1200, 900))
    spaces_obs = Node{Array{Integer,2}}([prefs[grid.spaces[r,c]] for c in 1:cols, r in 1:rows])
    ax, hm = heatmap(fig[1, 1:3], 1:cols+1, 1:rows+1, spaces_obs)

    agent_obs = Node{Point2f0}(Point2f0(1.5, 1.5))
    scatter!(agent_obs; color=:red, markersize=45)

    points = Node(Point2f0[(0, 0)])
    ax = fig[:, end+1] = Axis(fig)
    scatter!(ax, points)
    limits!(ax, 0, ITERS+1, 0, 250)

    iterator = 0:ITERS
    record(fig, "animation.mp4", iterator; framerate=30) do t
        evolvegridonestep!(grid)
        spaces_obs[] = [prefs[grid.spaces[r,c]] for c in 1:cols, r in 1:rows]

        action = agentselectaction(agent, grid)
        reward = evolvegridfromaction!(agent, grid, action)
        new_loc = grid.agents[agent]
        agent_obs[] = Point2f0(new_loc[2]+0.5, new_loc[1]+0.5)

        total_reward += reward
        new_point = Point2f0(t, total_reward)
        points[] = push!(points[], new_point)

        sleep(1/10)
    end
end

end # module
