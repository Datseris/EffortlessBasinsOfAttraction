using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`


# %% Lorenz96 coupled with Ice-Albedo feedback
# From Maximilian Gelbrecht et al.
function lorenz96_ebm_gelbrecht(dx, x, p, t)
    N = length(x) - 1 # number of grid points of Lorenz 96
    T = x[end]
    a₀ = 0.5
    a₁ = 0.4
    S = 8.0
    F = 8.0
    Tbar = 270.0
    ΔT = 60.0
    α = 2.0
    β = 1.0
    σ = 1/180
    E = 0.5*sum(x[n]^2 for n in 1:N)
    𝓔 = E/N
    forcing = F*(1 + β*(T - Tbar)/ΔT)
    # 3 edge cases
    @inbounds dx[1] = (x[2] - x[N - 1]) * x[N] - x[1] + forcing
    @inbounds dx[2] = (x[3] - x[N]) * x[1] - x[2] + forcing
    @inbounds dx[N] = (x[1] - x[N - 2]) * x[N - 1] - x[N] + forcing
    # then the general case
    for n in 3:(N - 1)
      @inbounds dx[n] = (x[n + 1] - x[n - 2]) * x[n - 1] - x[n] + forcing
    end
    # Temperature equation
    dx[end] = S*(1 - a₀ + (a₁/2)*tanh(T-Tbar)) - (σ*T)^4 - α*(𝓔/(0.6*F^(4/3)) - 1)
    return nothing
end

function paper_projection(tr)
    N = length(tr[1]) - 1
    M = zeros(length(tr))
    T = copy(M); 𝓔 = copy(M) 
    for (i, p) in enumerate(tr)
        M[i] = sum(p[n] for n in 1:N)/N
        𝓔[i] = sum(p[n]^2 for n in 1:N)/2/N
        T[i] = p[N+1]
    end
    return M, 𝓔, T
end

Ts = 240:0.5:300
N = 5
fig = Figure(); display(fig)
ax = Axis3(fig[1,1]; ylabel = "M", xlabel = "𝓔", zlabel = "T")
ds = ContinuousDynamicalSystem(lorenz96_ebm_gelbrecht, rand(N+1), nothing)
for T0 in (220.0, 300.0)
    u0 = [4rand(N)..., T0]
    tr = trajectory(ds, 20000.0, u0; Δt = 0.05)
    M, 𝓔, T = paper_projection(tr)
    lines!(ax, 𝓔, M, T; transparent = true)
end

# %% Basins
# For these parameters it seems that the low temperature attractor is limit cycle
# and the upper temperature is chaotic (or extremely long period)
p = (D = 5,)
system = :lorenz96_ebm_gelbrecht
xgs = [range(-8, 15; length = 10) for i in 1:p.D]
Tg = range(230, 300; length = 101)
grid = (xgs..., Tg)

@show prod(length.(grid))
basin_kwargs = (Δt = 0.5,)
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = true)

@show basin_fractions(basins)

fig = Figure()
plot_2D_basins!(fig, basins[1,1,1,1, :, :], xgs[end], Tg; title = system)


# %% Plot found trajectories
fig = Figure(); display(fig)
ax = Axis3(fig[1,1])
for i in keys(attractors)
    tr = attractors[i]
    markersize = length(tr) > 2 ? 2000 : 6000
    marker = length(tr) > 2 ? :circle : :rect
    color = COLORS[i]

    idxs = [1,4,6]
    x,y,z = columns(tr)[idxs]
    scatter!(ax, x,y,z; markersize, marker, color)
    tr = trajectory(ds, 5000, tr[1]; Ttr = 1000, default_diffeq...)
    x,y,z = columns(tr)[idxs]
    lines!(ax, x,y,z; linewidth = 1.0, color)
    
    ls = lyapunovspectrum(ds, 40000, 2; Ttr = 1000, u0 = tr[1])
    @show ls
end