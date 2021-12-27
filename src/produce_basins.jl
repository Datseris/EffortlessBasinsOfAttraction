# This file defines some functions that automate the production of basins of 
# attraction for arbitrary dynamical systems, provided the systems are
# contained in the `Systems` submodule.

# This struct is a container of general basin configuration.
# it is made so that interplay with DrWatson's `savename` is automated
# and the names include the parameters and basin keywords.
# This is done for `produce_or_load` to be automated.
# To see what's the benefit of `BasinConfig`, call `savename(config)`. 
Base.@kwdef struct BasinConfig
    system::Symbol
    grid::Tuple
    p = NamedTuple()
    basin_kwargs = NamedTuple()
    N = prod(length.(grid))
    extra_diffeq = NamedTuple()
end

DrWatson.default_allowed(::BasinConfig) = (Real, String, Symbol, NamedTuple)
DrWatson.allignore(::BasinConfig) = ["system", "extra_diffeq"]
DrWatson.default_expand(::BasinConfig) = ["p", "basin_kwargs"]
DrWatson.default_prefix(c::BasinConfig) = string(c.system)

using OrdinaryDiffEq: Vern9
const default_diffeq = (alg = Vern9(), reltol = 1e-9, abstol = 1e-9, maxiters = Int(1e12))
const default_diffeq_nonadaptive = (
    alg = Vern9(), reltol = 1e-6, abstol = 1e-6, 
    adaptive = false, dt = 0.01, maxiters = Int(1e12)
)

# These functions just configures `produce_or_load` in an automated manner 
function produce_basins_f(config)
    @unpack grid, p, basin_kwargs, system = config
    ds = create_dynamical_system(system, p)
    @info("Producing basins for $system")
    @time basins, attractors = basins_of_attraction(
        grid, ds; diffeq = merge(default_diffeq, config.extra_diffeq), basin_kwargs..., 
    )
    # The returned dictionary is what will be saved into the file
    return @strdict(grid, basins, attractors, config)
end

function produce_basins(config; force = false) # actually calls produce_or_load
    file, path = produce_or_load(
        datadir("basins"), config, produce_basins_f; 
        storepatch = false, suffix = "jld2", force,
    )
    return file["basins"], file["attractors"]
end

# This function exists so that we can have some flexibility on creating the 
# dynamical system (e.g. Poincare maps or arbitrary-dimensional systems)
function create_dynamical_system(system, p)
    if system == :thomas_cyclical_poincare
        ds = Systems.thomas_cyclical(; p...)
        return poincaremap(ds, (3, 0.0), 1e6;
            rootkw = (xrtol = 1e-8, atol = 1e-8), diffeq = default_diffeq
        )
    elseif system == :coupled_logistic_maps
        D = p.D
        return Systems.nld_coupled_logistic_maps(D; λ = p.λ, k = p.k)
    elseif system == :kuramoto
        D = p.D
        return Systems.kuramoto(D; K = p.K)
    elseif system == :lorenz96
        D = p.D
        return Systems.lorenz96(D; F = p.F)
    elseif system == :lorenz96_ebm_gelbrecht
        D = p.D
        return ContinuousDynamicalSystem(lorenz96_ebm_gelbrecht, [rand(D)..., 230.0], nothing)
    elseif system == :hidden_attractor
        return ContinuousDynamicalSystem(hidden_rule, rand(3), nothing)
    elseif isdefined(Systems, system)
        f = getproperty(Systems, system)
        return f(; p...)
    end
end

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

function hidden_rule(u, p, t)
    x, y, z = u
    du1 = -y
    du2 = x + z
    du3 = 2*y^2 + x*z - 0.35
    return SVector(du1, du2, du3)
end