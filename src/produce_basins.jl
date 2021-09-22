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
end

DrWatson.default_allowed(::BasinConfig) = (Real, String, Symbol, NamedTuple)
DrWatson.allignore(::BasinConfig) = ["system"]
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
        grid, ds; diffeq = default_diffeq, basin_kwargs..., 
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
            rootkw = (xrtol = 1e-8, atol = 1e-8), default_diffeq...
        )
    elseif system == :coupled_logistic_maps
        D = p.D
        return Systems.nld_coupled_logistic_maps(D; λ = p.λ, k = p.k)
    elseif system == :lorenz96
        D = p.D
        return Systems.lorenz96(D; F = p.F)
    elseif isdefined(Systems, system)
        f = getproperty(Systems, system)
        return f(; p...)
    end
end
