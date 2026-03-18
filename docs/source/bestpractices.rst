.. _chap-bestpractices:


Best practices for disks
************

#. Avoid convergence issues

When working with disk models, it is very common that the density drops to very low values at high altitude above the midplane, often 
down to values way lower than what is found in the ISM. This is an inherent result of many hydrodynamics simulations' output.
When astroMUGS convert such models into NMGC's inputs, the extremely low values of densities are conserved. This often results in many conversion issues in Nautilus.

At gas number density < 4 cm⁻³, two-body reaction rates are negligibly slow while photorates are fast — the solver needs tiny timesteps to resolve the imbalance. 
The chemistry at these floor-value points isn't physically meaningful anyway, and below what is found in diffuse ISM. It does not make sense to keep them in the Natilus's inputs. 


The convergence issue at T ≈ a few seconds is classic for photon-dominated regions.
If you look at the tracebacks, there are high chances that the H/H2 will be to blame, 
because their transition timescale at very low density and low Av is extremely short compared to the output timestep, forcing the solver into thousands of tiny steps.

To avoid these issues, in astroMUGS, we made sure the user can define a floor-value of Av, of gas number density, and a ceiling-value of the UV factor. 
They can be set as argument for ``write_nautilus``, like so::

    model.write_nautilus(min_gas_density=1e2, min_av=1e0, max_uv = 1e2)

We let free the user to select the value they need, because the floor-value
will depend on the model, and in particular on their UV flux. 
We typically recommand ``Av >= 1 MAG`` and ``nH >= 10^2 cm⁻³`` to be on the safe side.
Basically, at 10^3–10^4 cm⁻³ the chemistry is still diffuse enough compared to the disk midplane but tractable and will prevent convergence issues.

Some tips defining the safe zone for Nautilus:

- nH vs UV: at very low density, high UV creates extreme stiffness because photodissociation timescales are orders of magnitude shorter than recombination timescales. A rough boundary might be something like UV / nH = 1.
- nH vs Av: low density with low Av is similarly problematic — the gas is optically thin and irradiated but too diffuse to reach equilibrium quickly.
- Av vs UV: these are somewhat redundant since Av should attenuate UV, but in the coupling they come from independent sources (Av from radiative transfer, UV from geometric dilution), so inconsistencies can arise.