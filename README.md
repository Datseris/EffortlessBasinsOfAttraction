# EffortlessBasinsOfAttraction

This code base is using the Julia Language and [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> EffortlessBasinsOfAttraction

It is authored by George Datseris, Alexandre Wagemakers.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> Pkg.add("DrWatson") # install globally, for using `quickactivate`
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box, including correctly finding local paths.

---

The script that reproduces the main figure of our paper is in `scripts/figure_with_everything.jl`. The code infastructure that allows this script to be so clean is in `src/produce_basins.jl`. In short, a configuration structure `BasinConfig` is defined. This structure contains the info for the system, its parameters, and keywords for estimating the basins. The structure is given in the function `produce_basins`, which unrolls everything inside and calls the function `basins_of_attraction` from the DynamicalSystems.jl package.