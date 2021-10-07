using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

# %% Define benchmarking stuff
using LinearAlgebra: norm

function convergence!(integ, u0, Tmax = 10000)
    reinit!(integ, u0)
    while integ.t < Tmax
        step!(integ)
        n = norm(integ.u .- integ.uprev)
        if n < 1e-3 # convergence to fixed point.
            return true
        end
    end
    return false
end

function naive_basins(xg, yg, ds) # knows the dynamical system and the location of attractors...
    integ = integrator(ds)
    basins = zeros(Int, length(xg), length(yg))
    for (i, x) ∈ enumerate(xg), (j, y) ∈ enumerate(yg)
        u0 = SVector(x, y, 0, 0)
        success = convergence!(integ, u0)
        @assert success
        # The following code finds out which attractor we have converged to
        s = SVector(integ.u[1], integ.u[2])
        dmin, k = findmin([norm(s - m) for m in ds.f.magnets])
        basins[i, j] = k
    end
    return basins
end

# %%
α = 0.2; ω = 1.0; d = 0.3
dx = 100
xg = yg = range(-5, 5; length = dx)
d, α, ω = 0.3, 0.2, 0.5
ds = Systems.magnetic_pendulum(; α, ω, d)

@time basins1, att = basins_of_attraction((xg, yg), ds; show_progress=false)

@time basins2 = naive_basins(xg, yg, ds)

fig = Figure()
heatmap!(Axis(fig[1,1]), basins1)
heatmap!(Axis(fig[1,2]), basins2)
display(fig)

# okay all good.

# %% Actual benchmark figure now
using BenchmarkTools, Statistics

Ms = 50:10:200
B1 = Float64[]
B2 = Float64[]
for M ∈ Ms
    xg = yg = range(-5, 5; length = M)
    grid = (xg, yg)
    b1 = @benchmark basins_of_attraction($(grid), $(ds); show_progress=false)
    push!(B1, median(b1).time / 1e9)
    b2 = @benchmark naive_basins($xg, $yg, $ds)
    push!(B2, median(b2).time / 1e9)
end

wsave(datadir("benchmarks", "basins_vs_naive.jld2"), @strdict(Ms, B1, B2))

# %%
@unpack Ms, B1, B2 = wload(datadir("benchmarks", "basins_vs_naive.jld2"))

using CairoMakie; CairoMakie.activate!()
fig = Figure()
ax = Axis(fig[1,1]; xlabel = "# of initial conditions", ylabel = "time [sec]", fontsize = 28)
scatterlines!(ax, Ms.^2, B1, label = "our algorithm", color = COLORS[1], markercolor = COLORS[1])
scatterlines!(ax, Ms.^2, B2, label = "naive", color = COLORS[2], marker = :rect, markercolor = COLORS[2])
axislegend(ax; position = :lt)
colsize!(fig.layout, 1, Relative(18/19))
CairoMakie.save(plotsdir("benchmark.png"), fig; px_per_unit = 4)
