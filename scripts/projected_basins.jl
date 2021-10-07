using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

α = 0.2; ω = 1.0; d = 0.3

p = @ntuple ω d α
xg = yg = range(-3, 3; length = 200)
grid = (xg, yg)
system = :magnetic_pendulum
# basin_kwargs = (mx_chk_att = 1, mx_chk_fnd_att = 10,)
config = BasinConfig(; system, p, grid)

basins, attractors = produce_basins(config; force = true)

fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; attractors, title = system)

# %% refining the basins
xg = range(1.80, 1.95; length = 250)
yg = range(0, 0.12; length = 250)
grid = (xg, yg)
basin_kwargs = (attractors = attractors,)
config = BasinConfig(; system, p, grid, basin_kwargs)

basins, attractors = produce_basins(config; force = false)

fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; title = "magnetic pendulum zoom")
