using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

ω = 1.0
f = 0.2
d = 0.15
β = -1.0

p = @ntuple ω f d β
xg = yg = range(-2.2, 2.2, length=250)
grid = (xg, yg)
system = :duffing
basin_kwargs = (T = 2π/ω, )
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config; force = false)

fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; attractors)

# %% Test trajectories
ds = Systems.duffing(; p...)
tr = trajectory(ds, 10000.0; Ttr = 100)
lines(tr.data)
