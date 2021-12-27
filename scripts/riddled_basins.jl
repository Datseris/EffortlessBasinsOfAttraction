# Kuramoto model
using DrWatson
@quickactivate :EffortlessBasinsOfAttraction # exports DynamicalSystems, GLMakie and other goodies in `src`
using OrdinaryDiffEq

# Duffing oscillator is used as forced pendulum by setting nonlinearity 
# coefficient to zero
system = :forced_pendulum
d = 0.2; f = 1.3636363636363635; ω = 0.5 # Parametro para cuenca riddle.
p = @ntuple d f ω

# We have to define a callback to wrap the phase in [-π,π]
function affect!(integrator)
    uu = integrator.u
    if integrator.u[1] < 0
        set_state!(integrator, SVector(uu[1] + 2π, uu[2]))
        u_modified!(integrator, true)
    else
        set_state!(integrator, SVector(uu[1] - 2π, uu[2]))
        u_modified!(integrator, true)
    end
end
condition(u,t,integrator) = (integrator.u[1] < -π  || integrator.u[1] > π)
cb = DiscreteCallback(condition,affect!)

basin_kwargs = (T = 2*pi/ω,)
extra_diffeq = (callback = cb,)
res = 1000
xg = range(-pi,pi,length = res)
yg = range(-4.,4.,length = res)
grid = (xg, yg)
config = BasinConfig(; system, p, basin_kwargs, grid, extra_diffeq)
basins, attractors = produce_basins(config; force = true)

# %% plot basins
fig = Figure()
plot_2D_basins!(fig, basins, xg, yg; attractors)

# %% Test trajectories
ds = Systems.forced_pendulum(; p...)
tr = trajectory(ds, 10000.0; Ttr = 100)
lines(tr.data)
