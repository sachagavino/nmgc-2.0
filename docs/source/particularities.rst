The particularities of the multi-grain mode
************

NMGC versus the main version of Nautilus
=================

What dust temperature to use
=================


Best practices for disks
=================

At gas number density < 4 cm⁻³, two-body reaction rates are negligibly slow while photorates are fast — the solver needs tiny timesteps to resolve the imbalance. 
At 10^3–10^4 cm⁻³ the chemistry is still diffuse but more tractable. The chemistry at these floor-value points isn't physically meaningful anyway.

The convergence issue at T ≈ a few seconds is classic for photon-dominated regions.
If you look at the tracebacks, there are high chances that the H/H2 are to blame, 
because their transition timescale at very low density and low Av is extremely short compared to the output timestep, forcing the solver into thousands of tiny steps.

To avoid, any of these issues, we made sure the user can define a floor values of Av and gas number density inside ``write_nautilus``. 
The user can select ``min_gas_density`` and ``min_av`` to any floor-values. We let free the user to select, because the floor-value
will depend on the model, and in particular on the UV flux. But we recommand a safe choice of ``Av >= 1 MAG`` and ``nH >= 10^2 cm⁻³``. 