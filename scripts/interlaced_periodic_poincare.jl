using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`


system = :thomas_cyclical
b = 0.1665
p = @ntuple b

xg = yg = zg = range(-6.0, 6.0; length = 251)
grid = (xg, yg, zg)
config = BasinConfig(; system, p, grid)
basins, attractors = produce_basins(config; force = false)

fig = Figure()
plot_2D_basins!(fig, basins[:, :, length(zg)÷2], xg, yg; title = system)

# %% poincare map version

system = :thomas_cyclical_poincare
grid = (xg, yg)
config = BasinConfig(; system, p, grid)
basins, attractors = produce_basins(config; force = false)

fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; attractors, title = system)


# include(srcdir("makie_style.jl"))
# %% testing
# I believe that for b=0.2 we have coexistence of 
# chaotic attractor and periodic orbit attractor...?
# Lyapunov spectrum is positive but when plotting 
# in 3D the orbit closes. WTF...


ds = Systems.thomas_cyclical(; b)

u0s = ([5.0, 0, 0], [-5.0, 5.0, 0], [0, -5, 5.0])

fig = Figure(); display(fig)
ax = Axis3(fig[1,1])
for (i, u) in enumerate(u0s)
    tr = trajectory(ds, 10000.0, u; Ttr = 1000)
    lines!(ax, tr.data, linewidth = 2.0,
    transparent = false, linestyle = (:solid, :dash, :dot)[i])
end
