using DynamicalSystems
# Create instance of `DynamicalSystem`:
function lorenz84(u, p, t)
    F, G, a, b = p
    x, y, z = u
    dx = -y^2 -z^2 -a*x + a*F
    dy = x*y - y - b*x*z + G
    dz = b*x*y + x*z - z
    return SVector(dx, dy, dz)
end
F, G, a, b = 6.886, 1.347, 0.255, 4.0
p  = [F, G, a, b]
u0 = rand(3) # initial condition doesn't matter
lo = ContinuousDynamicalSystem(lorenz84, u0, p)
# Calculate basins of attraction and relative fractions:
xg = range(-1, 3;   length = 80)
yg = range(-2, 3;   length = 80)
zg = range(-2, 2.5; length = 80)
grid = (xg, yg, zg)
default_diffeq = (alg = Vern9(), reltol = 1e-9, abstol = 1e-9)
basins, attractors = basins_of_attraction(grid, lo; diffeq)
fracs = basin_fractions(basins)
# Use output to e.g., calculate Lyapunov exponents and label each attractor:
for (key, att) in attractors
    u0 = att[1] # First found point of attractor
    ls = lyapunovspectrum(lo, 10000; u0)
    println("Attractor $(key) has spectrum: $(ls)")
end
