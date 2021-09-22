using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

system = :coupled_logistic_maps
D = 4
λ = 1.2
k = 0.08
p = @ntuple λ k D
basin_kwargs = (mx_chk_hit_bas = 20, mx_chk_lost = 5, mx_chk_fnd_att = 90)

grid = Tuple(range(-1.7, 1.7, length = 201) for i in 1:D)
xg, yg, zg = grid

config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = false)

fig = Figure()
plot_2D_basins!(fig, basins[:, :, length(zg)÷2+4], xg, yg; title = system)


# %% Test trajectories
ds = create_dynamical_system(system, p)
u0s = [0.7*rand(3) .+ 0.1 for i in 1:6]

fig = Figure(); display(fig)
ax = Axis3(fig[1,1])
for (i, u) in enumerate(u0s)
    tr = trajectory(ds, 1000, u; Ttr = 1000)
    scatterlines!(ax, tr.data[500:end];
        marker = :circle, linewidth = 0.5, transparent = false,
        color = COLORS[i], markersize = 4000, markercolor = COLORS[i]
    )
    @show tr[end]
end

# Z = 300
# xg = range(-2.5, 2.5; length = Z)
# yg = range(-1.0, 1.0; length = Z)

# grid = (xg, yg)
# config = BasinConfig(; system, p, basin_kwargs, grid)

# basins, attractors = produce_basins(config; force = false)

# fig = Figure()
# plot_2D_basins!(fig, basins, xg, yg; attractors)
