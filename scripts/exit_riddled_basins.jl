using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`

res = 1000
xg = range(-2, 2; length = res)
yg = range(0, 2;  length = res)

ω = 3.5
p = @ntuple ω
system = :riddled_basins

basin_kwargs = (horizon_limit=10.0, T = 2π/ω)
grid = (xg, yg)
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config; force = true)

@show attractors

# %% 
fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; attractors)
