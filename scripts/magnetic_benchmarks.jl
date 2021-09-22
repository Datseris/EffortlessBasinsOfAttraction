using DrWatson
@quickactivate "BasinsPaper"
using DynamicalSystems, GLMakie
GLMakie.activate!()
# include(srcdir("makie_style.jl"))


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

function naive_basins(xg, yg, ds) # nows the dynamical system and the location of attractors...
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