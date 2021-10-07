using DrWatson
@quickactivate :BasinsPaper # exports DynamicalSystems, GLMakie and other goodies in `src`

system = :lorenz96
F = 8.0
D = 6
p = @ntuple D F
xg = yg = zg = range(-12.0, 12.0; length = 50)
grid = (xg, yg, zg)
basin_kwargs = ()
config = BasinConfig(; system, p, basin_kwargs, grid)
basins, attractors = produce_basins(config; force = true)



# Can use Thomas cyclical to make some really cool animations
# for JuliaDynamics youtube

# I believe that for b=0.2 we have coexistence of 
# chaotic attractor and periodic orbit attractor...?
# Lyapunov spectrum is positive but when plotting 
# in 3D the orbit closes. WTF...

# For F = 4 we have periodic, for F = 6 quasiperiodic or 
# extremely high periodicity and for F = 8 chaos.

# %% Testing
F = 8.0
D = 6
ds = Systems.lorenz96(D; F)
u0s = [rand(D) for i in 1:3]
u0s[1] = [rand(3)..., 0, 0, 0]

fig = Figure(); display(fig)
ax = Axis3(fig[1,1])
for (i, u) in enumerate(u0s)
    tr = trajectory(ds, 1000.0, u; Ttr = 1000)
    lines!(ax, tr[:, 1:3].data, linewidth = 1.0,
    transparent = false)
end

# TODO: Can also be used for beautiful illustrations


# projection...


# %% Lorenz96 coupled with Ice-Albedo feedback
# From Maximilian Gelbrecht 1,2,a , Valerio Lucarini 3,4 , Niklas Boers 1,5,6 , and Jürgen
# Kurths 1,2,7
using DynamicalSystems, GLMakie

function lorenz96_ebm_gelbrecht(dx, x, p, t)
    N = length(x) - 1 # number of grid points of Lorenz 96
    T = x[end]
    a₀ = 0.5
    a₁ = 0.4
    S = 16
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

Ts = 250:0.5:300
N = 32
fig = Figure(); display(fig)
ax = Axis3(fig[1,1]; ylabel = "M", xlabel = "𝓔", zlabel = "T")
ds = ContinuousDynamicalSystem(lorenz96_ebm_gelbrecht, rand(N+1), nothing)
for T0 in (220.0, 300.0)
    u0 = [4rand(N)..., T0]
    tr = trajectory(ds, 10000.0, u0)
    M, 𝓔, T = paper_projection(tr)
    lines!(ax, 𝓔, M, T)
end