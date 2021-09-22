using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

# Okay, these four parameters have: fixed point, periodic trajectory, 
# and chaotic attractor. Fixed point has very small basin.
# Perhaps there is a fourth attractor, like in the original paper, but it would have
# exceptionally small basin, as I haven't been able to find it so far.
F = 6.886
G = 1.347
a = 0.255
b = 4.0

p = @ntuple F G a b

ds = Systems.lorenz84(; p...)

u0s = (
    [2.0, 1, 0], [-2.0, 1.0, 0], [3, -1, 0.0], 
    [1, -1, 1.0], [0, 1.5, 1.0], [0, 1, -0.5],
)

u0s = [u0 .+ 1e-3rand(3) for u0 in u0s]

fig = Figure(); display(fig)
ax = Axis3(fig[1,1])
for (i, u) in enumerate(u0s)
    tr = trajectory(ds, 5000.0, u; Ttr = 1000, default_diffeq...)
    lines!(ax, tr.data, linewidth = 2.0,
    transparent = false, color = COLORS[i])
    λs = lyapunovspectrum(ds, 100000; u0 = u, Ttr = 1000, default_diffeq_nonadaptive...)
    scatter!(ax, tr[end]; color = COLORS[i], markersize = 5000)
    @show λs
    @show tr[end]
    # sleep(1)
end

# %% Anyways, compute basins!
M = 80 # YOOHOOOO!! It seems that M = 80 is the critical threshold to detect all three!
system = :lorenz84
xg = range(-1, 3; length = M)
yg = range(-2, 3; length = M)
zg = range(-2, 2.5; length = M)
grid = (xg, yg, zg)
basin_kwargs = NamedTuple()
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = false)

basin_fractions(basins)

fig = Figure()
plot_2D_basins!(fig, basins[:, :, length(zg)÷2], xg, yg; title = system)

# %% Make animation of found basins
# TODO.

# %% Plot found trajectories
fig = Figure(); display(fig)
ax = Axis3(fig[1,1])
for i in keys(attractors)
    tr = attractors[i]
    markersize = length(tr) > 10 ? 2000 : 6000
    marker = length(tr) > 10 ? :circle : :rect
    color = COLORS[i]
    scatter!(ax, columns(tr)...; markersize, marker, color)
    j = findfirst(isequal(i), basins)
    x = xg[j[1]]
    y = yg[j[2]]
    z = zg[j[3]]
    tr = trajectory(ds, 1000, SVector(x,y,z); Ttr = 1000, default_diffeq...)
    lines!(ax, columns(tr)...; linewidth = 1.0, color)
end

# %% Comments problems:
# It seems that we have difficulties with our algorithm and chaotic attractors...
# It took me a bit of effort to find all three. Furthermore, it seems that 
# increasing M from 80 to just 85 brings problems and the algorithm doesn't hault
# it computes for a lot of time but it doesn't seem to make progress......
# (at least, the progress bar does not progress.)