module DemoSim

using GLMakie: Figure, Node, heatmap, Point2f0, scatter!, Axis, limits!, record
using Random: AbstractRNG, default_rng

export generategrid, evolvegridonestep!, evolvegridfromaction!, agentselectaction, main, animate

@enum Space begin
    grass
    rock
    water
    dirt
end

struct Agent 
    # how much the agent values each type of Space
    preferences::Dict{Space,Int}
end

mutable struct Grid
    # locations of agents
    agents::Dict{Agent,Pair{Int,Int}}
    spaces::Array{Space,2}
    # values intrinsic to each type of Space
    values::Dict{Space,Int}
end

@enum Action begin
    up = 1
    down = 2
    left = 3
    right = 4
    stay = 5
end

"""
    generategrid([rng])

Generate a simulated world where each block in the grid is a randomly-chosen Space.
"""
function generategrid(rng::AbstractRNG)
    agents = Dict()
    rows = rand(rng, 3:5)
    cols = rand(rng, 3:5)
    spaces = rand(rng, [grass, rock, water, dirt], (rows, cols))
    values = Dict{Space,Int64}(grass=>1,rock=>2,water=>3,dirt=>4)
    return Grid(agents, spaces, values)
end

# default case
generategrid() = generategrid(default_rng())

"""
    evolvegridonestep!(grid::Grid[, rng])

Mutate `grid` by randomly choosing a block and setting it to a randomly-chosen Space.
"""
function evolvegridonestep!(grid::Grid, rng::AbstractRNG)
    dims = size(grid.spaces)
    # pick a random location
    r = rand(rng, 1:dims[1])
    c = rand(rng, 1:dims[2])
    # set it to a random Space
    grid.spaces[r,c] = rand(rng, [grass, rock, water, dirt])
end

# default case
evolvegridonestep!(grid::Grid) = evolvegridonestep!(grid, default_rng())

"""
    evolvegridfromaction!(agent, grid, action)

Mutate `grid` by having `agent` take the specified `action`.
"""
function evolvegridfromaction!(agent::Agent, grid::Grid, action::Action)::Int64
    @assert agent in keys(grid.agents)
    # compute new loc
    action_map = Dict{Action,Pair{Int,Int}}(up=>Pair(-1,0),down=>Pair(1,0),left=>Pair(0,-1),right=>Pair(0,1),stay=>Pair(0,0))
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
end

"""
    agentselectaction(agent, grid[, rng])

Return a randomly chosen Action for `agent` to take on `grid`.
"""
function agentselectaction(agent::Agent, grid::Grid, rng::AbstractRNG)
    @assert agent in keys(grid.agents)
    action = rand(rng, [up, down, left, right, stay])
end

# default case
agentselectaction(agent::Agent, grid::Grid) = agentselectaction(agent, grid, default_rng())

"""
    main([iters=10])

Generate a simulated world with one agent and evolve it over `iters` time steps
while tracking the agent's total accumulated reward.
"""
function main(; iters=10)
    grid = generategrid()
    # set up agent and reward
    prefs = Dict{Space,Int64}(grass=>1,rock=>2,water=>3,dirt=>4)
    agent = Agent(prefs)
    grid.agents[agent] = Pair(1,1)
    total_reward = 0
    # evolve over time
    for t in 1:iters
        evolvegridonestep!(grid)
        action = agentselectaction(agent, grid)
        reward = evolvegridfromaction!(agent, grid, action)
        total_reward += reward
    end
end

"""
    animate([iters=10, resolution=(1200,900), file="animation.mp4", framerate=30])

Generate and visualize the evolution of a simulated world with one agent over `iters` time steps
while tracking the agent's total accumulated reward.
"""
function animate(; iters=10, resolution=(1200,900), file="animation.mp4", framerate=30)
    grid = generategrid()
    # get dimensions
    dims = size(grid.spaces)
    rows, cols = dims[1], dims[2]
    # set up agent and reward
    prefs = Dict{Space,Int}(grass=>1,rock=>2,water=>3,dirt=>4)
    agent = Agent(prefs)
    grid.agents[agent] = Pair(1,1)
    total_reward = 0

    fig = Figure(resolution=resolution)
    # grid visualization
    spaces_obs = Node{Array{Int,2}}([prefs[grid.spaces[r,c]] for c in 1:cols, r in 1:rows])
    ax, hm = heatmap(fig[1, 1:3], 1:cols+1, 1:rows+1, spaces_obs)
    # agent visualization
    agent_obs = Node{Point2f0}(Point2f0(1.5, 1.5))
    scatter!(agent_obs; color=:red, markersize=45)
    # reward graph
    points = Node(Point2f0[(0, 0)])
    ax = fig[:, end+1] = Axis(fig)
    scatter!(ax, points)
    limits!(ax, 0, iters+1, 0, 250)
    
    # evolve over time and animate
    iterator = 0:iters
    record(fig, file, iterator; framerate=framerate) do t
        evolvegridonestep!(grid)
        # update grid visualization
        spaces_obs[] = [prefs[grid.spaces[r,c]] for c in 1:cols, r in 1:rows]

        action = agentselectaction(agent, grid)
        reward = evolvegridfromaction!(agent, grid, action)
        # update agent visualization
        new_loc = grid.agents[agent]
        agent_obs[] = Point2f0(new_loc[2]+0.5, new_loc[1]+0.5)

        total_reward += reward
        # update reward graph
        new_point = Point2f0(t, total_reward)
        points[] = push!(points[], new_point)

        sleep(1/10)
    end
end

end # module
