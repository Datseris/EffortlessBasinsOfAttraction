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