using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`

system = :thomas_cyclical
b = 0.1665
p = @ntuple b

xg = yg = zg = range(-6.0, 6.0; length = 100)
grid = (xg, yg, zg)

basin_kwargs = (mx_chk_hit_bas = 40, mx_chk_att = 5, mx_chk_loc_att = 120, Δt = 1.0)

config = BasinConfig(; system, p, grid, basin_kwargs)
basins, attractors = produce_basins(config; force = true)

@show basin_fractions(basins)

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
