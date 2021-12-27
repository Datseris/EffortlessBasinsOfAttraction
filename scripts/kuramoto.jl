using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`

system = :kuramoto
D = 10
K = 0.3
p = @ntuple K D
grid = Tuple(range(-π, π; length = 21) for i in 1:D)

config = BasinConfig(; system, p, grid)
basins, attractors = produce_basins(config; force = false)

# fig = Figure()
# plot_2D_basins!(fig, basins[:, :, length(zg)÷2+4], xg, yg; title = system)

