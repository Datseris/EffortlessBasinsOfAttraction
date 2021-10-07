module BasinsPaper
# This module is defined to use DrWatson's `@quickactivate` macro with Symbol input.
# It will bring into scope everything exported here, as well as activate the 
# project file in the same folder.

using DrWatson
using Reexport
@reexport using DynamicalSystems
@reexport using GLMakie

include("produce_basins.jl")
include("style.jl")
export BasinConfig, produce_basins, create_dynamical_system
export default_diffeq, default_diffeq_nonadaptive
export plot_2D_basins!, theme!

end