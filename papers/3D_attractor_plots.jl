using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`

theme!()
fig = Figure(resolution= (800, 350)); display(fig)

function plot_attractors!(ax, ds, attractors, bsn, grid; plot_found = true)
    for i in keys(attractors)
        tr = attractors[i]
        if plot_found
            markersize = length(attractors[i]) > 10 ? 2000 : 4000
            marker = length(attractors[i]) > 10 ? :circle : :rect
            scatter!(ax, columns(tr)...; markersize, marker, transparency = true, 
            color = COLORS[i])
        end
        x,y,z = attractors[i][1]
        # j = findfirst(isequal(i), bsn)
        # x = grid[1][j[1]]
        # y = grid[2][j[2]]
        # z = grid[3][j[3]]
        tr = trajectory(ds, 100, SVector(x,y,z); Ttr = 100)
        lines!(ax, columns(tr)...; linewidth = 1.0, color = COLORS[i])
    end
end

# Lorenz84
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
# basin_kwargs = ()
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = false)

@show basin_fractions(basins)

ds = Systems.lorenz84(; p...)

ax = Axis3(fig[1,1]; title = "a) Lorenz84")
ax.xlabel = ax.ylabel = ax.zlabel = ""
plot_attractors!(ax, ds, attractors, basins, grid)

# Thomas cyclical
ax = Axis3(fig[1,2]; title = "b) Thomas cyclical")
ax.xlabel = ax.ylabel = ax.zlabel = ""


# Poincare map of interlaced periodic
system = :thomas_cyclical_poincare
b = 0.1665
p = @ntuple b
xg = yg = range(-6.0, 6.0; length = 251)
grid = (xg, yg)
config = BasinConfig(; system, p, grid)
basins, attractors = produce_basins(config)
ds = Systems.thomas_cyclical(; b)

for (i, att) in attractors
    u = att[1]
    tr = trajectory(ds, 5000.0, u; Ttr = 1000, default_diffeq...)
    lines!(ax, tr.data, linewidth = 2.0,
    transparent = false, color = COLORS[i+1])
    # λs = lyapunovspectrum(ds, 100000; u0 = u, Ttr = 1000, default_diffeq_nonadaptive...)
    if i == 3
        # scatter!(ax, tr[end]; color = COLORS[i], markersize = 5000)
    end
    # @show λs
    # @show tr[end]
    # sleep(1)
end

# Plot plane
plane = Makie.FRect3D((-5, -5, 0), (10, 10, 0))
a = RGBAf0(0,0,0,0)
c = RGBAf0(0.5, 0.5, 0.25, 1.0)
img = Makie.ImagePattern([c a; a c]);
mesh!(ax, plane; color = img);

GLMakie.save(plotsdir("attractors.png"), fig; px_per_unit = 4)
