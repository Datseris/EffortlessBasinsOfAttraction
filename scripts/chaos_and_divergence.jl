using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

a, b = 1.4, 0.3
p = @ntuple a b
system = :henon

basin_kwargs = (horizon_limit=100.0, mx_chk_fnd_att=30, mx_chk_lost=2)
basin_kwargs = NamedTuple()
Z = 201
xg = range(-1.5, 1.5; length = Z)
yg = range(-0.5, 0.5; length = Z)
grid = (xg, yg)
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config; force = true)

@show attractors

# %% 
fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; attractors)
