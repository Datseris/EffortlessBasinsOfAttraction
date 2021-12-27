using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`

labels = String[]
B = [] # global basins container (as 2D slices)
A = [] # global attractor container
X = [] # global x-axis grid container
Y = [] # global y-axis grid container

# 2D discrete escaping to infinity
a, b = 1.4, 0.3
p = @ntuple a b
system = :henon

basin_kwargs = (mx_chk_fnd_att = 30, mx_chk_lost = 2, horizon_limit = 1e2)
Z = 1001
xg = range(-2.5, 2.5; length = Z)
yg = range(-1.0, 1.0; length = Z)
grid = (xg, yg)
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config)
push!(B, basins)
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "2D map & divergence to ∞")

# 2D stroboscopic map
ω = 1.0
f = 0.2
d = 0.15
β = -1.0

p = @ntuple ω f d β
xg = yg = range(-2.2, 2.2, length=1000)
grid = (xg, yg)
system = :duffing
basin_kwargs = (T = 2π/ω, )
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config)

push!(B, basins)
push!(A, attractors)
push!(labels, "2D stroboscopic map")
push!(X, xg); push!(Y, yg)

# projected basins
α = 0.2; ω = 1.0; d = 0.3
p = @ntuple ω d α
xg = yg = range(-5, 5; length = 1000)
grid = (xg, yg)
system = :magnetic_pendulum
basin_kwargs = (Δt = 1,)
config = BasinConfig(; system, p, grid, basin_kwargs)
basins, attractors = produce_basins(config; force = false)
push!(B, basins)
push!(X, xg); push!(Y, yg)
push!(A, attractors)
push!(labels, "4D system projected to 2D")

# Refining basins
xg = range(1.80, 1.95; length = 500)
yg = range(0, 0.12; length = 500)
grid = (xg, yg)
basin_kwargs = (attractors = attractors, Δt = 4, )
config = BasinConfig(; system, p, grid, basin_kwargs)
basins, attractors = produce_basins(config)
push!(B, basins)
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "Refined basins (from (c))")

# Poincare map of interlaced periodic
system = :thomas_cyclical_poincare
b = 0.1665
p = @ntuple b
xg = yg = range(-6.0, 6.0; length = 551)
grid = (xg, yg)
config = BasinConfig(; system, p, grid)
basins, attractors = produce_basins(config)
push!(B, basins)
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "2D Poincaré map")

# 3D Basins with chaotic attractor interlaced
F = 6.886
G = 1.347
a = 0.255
b = 4.0
p = @ntuple F G a b
M = 120
system = :lorenz84
xg = range(-3, 3; length = M)
yg = range(-3, 3; length = M)
zg = range(-3, 3; length = M)
grid = (xg, yg, zg)
basin_kwargs = (Δt = 0.2,)
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = false)

push!(B, basins[:, :, length(zg)÷2])
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "3D basins: chaotic & \nperiodic & fixed point")

# 4D Discrete
system = :coupled_logistic_maps
D = 4
λ = 1.2
k = 0.08
p = @ntuple λ k D
basin_kwargs = (mx_chk_hit_bas = 20, mx_chk_lost = 5, mx_chk_fnd_att = 90)
M = 151
grid = Tuple(range(-1.7, 1.7, length = M) for i in 1:D)
xg, yg, zg = grid
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config)
push!(B, basins[:, :, length(zg)÷2, length(zg)÷2])
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "4D basins of discrete map \nwith $(length(attractors)) attractors")

# High dim continuous
system = :lorenz96_ebm_gelbrecht
p = (D = 5,)
xgs = [range(-8, 15; length = 11) for i in 1:p.D-1]
push!(xgs, range(-8, 15; length = 21))
Tg = range(230, 300; length = 21)
grid = (xgs..., Tg)
basin_kwargs = (Δt = 0.5,)
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = false)

push!(B, basins[1,1,1,1, :, :])
push!(A, attractors)
push!(X, xgs[end]); push!(Y, Tg)
push!(labels, "6D continuous chaotic \nbistable system")

# Riddled exit Basins
res = 1000
xg = range(-2, 2; length = res)
yg = range(0, 2;  length = res)
ω = 3.5
p = @ntuple ω
system = :riddled_basins

basin_kwargs = (horizon_limit=10.0, T = 2π/ω)
grid = (xg, yg)
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config; force = false)
push!(B, basins)
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "Riddled & exit basins")


# %% Make the figure
import CairoMakie
Used = CairoMakie
Used.activate!()
theme!()
fig = Figure(resolution= (900, 1000), fontsize = 16)
display(fig)
noatt = [6, 7, 8, 9]

plotmatrix = zeros(3,3)
catind = CartesianIndices(plotmatrix)

for i in 1:length(plotmatrix)
    @show i 
    @show length(A[i])
    icord, jcord = Tuple(catind[i])
    plot_2D_basins!(fig, B[i], X[i], Y[i]; title = "($(('a':'z')[i])) "*labels[i], 
        attractors = i ∈ noatt ? nothing : A[i],
        i = jcord, j = icord, add_colorbar = false,
    )
end
rowgap!(fig.layout, 10)
colgap!(fig.layout, 10)
# Used.save(plotsdir("all_basins.png"), fig; px_per_unit = 4)
fig