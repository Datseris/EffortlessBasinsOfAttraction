using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`

res = 200
xg = range(-5,1, length = res)
yg = range(-3,3, length = res)
zg = range(-3,5, length = res)

system = :hidden_attractor

basin_kwargs = (horizon_limit=500.0,)
grid = (xg, yg, zg)
config = BasinConfig(; system, basin_kwargs, grid)

basins, attractors = produce_basins(config; force = true)

@show attractors

# %%
fig = Figure()
plot_2D_basins!(fig, basins[:, :, res÷2], xg, yg; attractors)
