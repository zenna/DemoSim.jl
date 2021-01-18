using DemoSim
using Test

# just types for now, functionality will change w/ GAN
@inferred generategrid()

# just types for now, functionality will change
grid = generategrid()
@inferred evolvegridonestep!(grid)

@testset "evolvegridfromaction" begin
    # types
    prefs = Dict{Space,Int64}(DemoSim.grass=>1,DemoSim.rock=>2,DemoSim.water=>3,DemoSim.dirt=>4)
    agent = Agent(prefs)
    grid.agents[agent] = Pair(1,1)
    action = DemoSim.down
    @inferred evolvegridfromaction!(agent, grid, action)
    
    # up
    action = DemoSim.up
    grid.agents[agent] = Pair(2,1)
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(1,1)
    
    # down
    action = DemoSim.down
    grid.agents[agent] = Pair(2,1)
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(3,1)
    
    # left
    action = DemoSim.left
    grid.agents[agent] = Pair(1,2)
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(1,1)

    # right
    action = DemoSim.right
    grid.agents[agent] = Pair(1,2)
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(1,3)

    # stay
    action = DemoSim.stay
    grid.agents[agent] = Pair(1,2)
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(1,2)
    
    # out of bounds
    action = DemoSim.up
    grid.agents[agent] = Pair(1,1)
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(1,1)

    # overlap w/ another agent
    prefs2 = Dict{Space,Int64}(DemoSim.grass=>1,DemoSim.rock=>2,DemoSim.water=>3,DemoSim.dirt=>4)
    agent2 = Agent(prefs2)
    grid.agents[agent] = Pair(1,1)
    grid.agents[agent2] = Pair(1,2)
    action = DemoSim.left
    evolvegridfromaction!(agent, grid, action)
    @test grid.agents[agent] == Pair(1,1)
    @test grid.agents[agent2] == Pair(1,2)
end

# types
grid = generategrid()
prefs = Dict{Space,Int64}(DemoSim.grass=>1,DemoSim.rock=>2,DemoSim.water=>3,DemoSim.dirt=>4)
agent = Agent(prefs)
grid.agents[agent] = Pair(1,1)
@inferred agentselectaction(agent, grid)
