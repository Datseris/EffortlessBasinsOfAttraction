using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

labels = String[]
B = []
A = []
X = []
Y = []

# 2D discrete escaping to infinity
a, b = 1.4, 0.3
p = @ntuple a b
system = :henon

basin_kwargs = (mx_chk_fnd_att = 30, mx_chk_lost = 2, horizon_limit = 1e2)
Z = 201
xg = range(-2.5, 2.5; length = Z)
yg = range(-1.0, 1.0; length = Z)
grid = (xg, yg)
config = BasinConfig(; system, p, basin_kwargs, grid)

basins, attractors = produce_basins(config)
push!(B, basins)
push!(A, attractors)
push!(labels, "2D discrete map + divergence to ∞")
push!(X, xg); push!(Y, yg)

# 2D stroboscopic map
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

basins, attractors = produce_basins(config)

push!(B, basins)
push!(A, attractors)
push!(labels, "2D stroboscopic map")
push!(X, xg); push!(Y, yg)

# projected basins
α = 0.2; ω = 1.0; d = 0.3
p = @ntuple ω d α
xg = yg = range(-3, 3; length = 300)
grid = (xg, yg)
system = :magnetic_pendulum
# basin_kwargs = (mx_chk_att = 1, mx_chk_fnd_att = 10,)
config = BasinConfig(; system, p, grid)
basins, attractors = produce_basins(config)
push!(B, basins)
push!(X, xg); push!(Y, yg)
push!(A, attractors)
push!(labels, "4D basins projected to 2D")

# Refining basins
xg = range(1.80, 1.95; length = 250)
yg = range(0, 0.12; length = 250)
grid = (xg, yg)
basin_kwargs = (attractors = attractors,)
config = BasinConfig(; system, p, grid, basin_kwargs)
basins, attractors = produce_basins(config)
push!(B, basins)
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "Refined basins (from 3)")

# Poincare map of interlaced periodic
system = :thomas_cyclical_poincare
b = 0.1665
p = @ntuple b
xg = yg = range(-6.0, 6.0; length = 251)
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
M = 80 # YOOHOOOO!! It seems that M = 80 is the critical threshold to detect all three!
system = :lorenz84
xg = range(-1, 3; length = M)
yg = range(-2, 3; length = M)
zg = range(-2, 2.5; length = M)
grid = (xg, yg, zg)
basin_kwargs = NamedTuple()
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config)
push!(B, basins[:, :, length(zg)÷2])
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "3D basins (chaotic+periodic interlaced)")

# 4D Discrete
system = :coupled_logistic_maps
D = 4
λ = 1.2
k = 0.08
p = @ntuple λ k D
basin_kwargs = (mx_chk_hit_bas = 20, mx_chk_lost = 5, mx_chk_fnd_att = 90)
grid = Tuple(range(-1.7, 1.7, length = 101) for i in 1:D)
xg, yg, zg = grid
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config)
push!(B, basins[:, :, length(zg)÷2, length(zg)÷2])
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "4D basins of discrete map ($(length(attractors)) attractors)")

# High dim continuous. PLACEHOLDER
system = :lorenz96
F = 8.0
D = 6
p = @ntuple D F
xg = yg = zg = range(-12.0, 12.0; length = 50)
grid = (xg, yg, zg)
basin_kwargs = ()
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = false)
# dirty fix until better system
basins[1:length(xg)÷2, :, :] .= 0 # on purpose so that there are 2 values
push!(B, basins[:, :, length(zg)÷2])
push!(A, attractors)
push!(X, xg); push!(Y, yg)
push!(labels, "High-dim. continuous chaotic")


# %% Make the figure
import CairoMakie
Used = GLMakie
Used.activate!()
fig = Figure(resolution= (900, 1150))
noatt = [6, 7, 8]

for i in 1:length(B)
    @show i 
    @show length(A[i])
    plot_2D_basins!(fig, B[i], X[i], Y[i]; title = "$(i): "*labels[i], 
        attractors = i ∈ noatt ? nothing : A[i],
        i = (i-1)÷2 + 1, j = isodd(i) ? 1 : 2, add_colorbar = false,
    )
end

# CairoMakie.save(plotsdir("all_basins.png"), fig; px_per_unit = 4)