.. _chap-input-files:

The input and output files of NMGC
***************************************

The input files are the same as for the official version of Nautilus, except for a few differences. Whenever differences exist between the two version, they are mentioned and described below in each section.   

NMGC needs at minimum six inputs to be able to run. If one of these six files are missing, the code will automatically stop. They are described below and their name is followed by ``(required)``. 
There are three additional optional input files that can be added. 
Wether or not you use one or severals of these optional files will depend on your needs.



.. _sec-ab-input:
INPUT: abundances.in (required)
==================

.. _sec-act-input:
INPUT: activation_energies.in (required)
==================

.. _sec-network-input:
INPUT: chemical network (required)
==================

.. _sec-greac-input:
gas_reactions.in
---------------------

.. _sec-gspec-input:
gas_species.in
---------------------

.. _sec-grreac-input:
grain_reactions.in
---------------------

.. _sec-grspec-input:
grain_species.in
---------------------

.. _sec-elm-input:
INPUT: element.in (required)
==================


.. _sec-param-input:
INPUT: parameters.in (required)
==================

The file ``parameters.in`` is the main parameter file for your chemistry model. It gathers switches, gas-phase parameters, and grain parameters. This is also where you define the integration time, the number of output times,
the simulation mode (dimension and number of grain sizes), and the chemical model (2-phase vs. 3-phase). Below is the exhaustive list of all parameters, in the order they appear in the file. Every line starting with ``!`` is a comment and is not read by the code.

.. note::

   Parameter names and their values are separated by an ``=`` sign. Any text after the value on the same line is treated as a comment and ignored. Blank lines and lines containing only spaces are also skipped.


**Switches**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``is_3_phase``:

    Sets the chemistry model. If ``1``, the simulation uses the **three-phase model** (as described in Ruaud et al. 2016), where the gas phase, the grain surface, and the grain mantle are all chemically active. Species can swap between surface and mantle layers, but mantle species cannot react directly with the gas phase. If ``0``, the **two-phase model** is used, where only the gas phase and the grain surface are chemically active.

* ``preliminary_test``:

    If set to ``1``, the code performs a comprehensive set of sanity checks on the chemical network and input files before starting the simulation. Recommended when setting up a new network. Set to ``0`` when launching large batches of simulations to avoid the overhead.

* ``is_structure_evolution``:

    If ``1``, the physical structure (gas density, visual extinction, gas and dust temperatures) evolves with time, read from the file ``structure_evolution.dat``. If that file is absent and this flag is set to ``1``, the code will stop. See :ref:`sec-evolv-input`.

* ``grain_temperature_type``:

    Controls how the grain temperature is set during the simulation. The accepted values are:

    * ``fixed``: All grains share the same constant temperature given by ``initial_dust_temperature``.
    * ``fixed_to_dust_size``: Each grain population has its own fixed temperature, as defined in ``0D_grain_sizes.in`` or ``1D_grain_sizes.in`` (multi-grain mode only). See :ref:`sec-0d-input` and :ref:`sec-1d-input`.
    * ``gas``: The grain temperature is set equal to the gas temperature at all times.
    * ``table_evolv``: The grain temperature is interpolated from the time-dependent values given in ``structure_evolution.dat`` (5th column). Requires ``is_structure_evolution = 1``.
    * ``table_1D``: The grain temperature is read from ``1D_static.dat`` (5th column) for each vertical grid point. Requires a 1D structure.
    * ``computed``: The grain temperature is calculated at each time step from the local UV flux and visual extinction via radiative equilibrium.

* ``photo_disk``:

    If ``1``, photodissociation rates are computed using a treatment adapted for protoplanetary disk environments (accounting for the disk geometry and the two-sided UV irradiation). Set to ``0`` for standard ISM-like irradiation.

* ``is_grain_reactions``:

    If ``0``, all grain-surface processes are disabled: there is no accretion of gas-phase species onto grains and no grain-surface reactions. Set to ``1`` (default) to activate grain chemistry.

* ``is_h2_adhoc_form``:

    If ``1``, activates an ad hoc prescription for H\ :sub:`2` formation on grain surfaces, bypassing the detailed surface reaction network. Should be used only when H\ :sub:`2` surface chemistry is not included in the chemical network.

* ``is_h2_formation_rate``:

    If ``1``, uses the H\ :sub:`2` formation rate on grain surfaces from Bron et al. (2014), which accounts for the transition from the photodissociation region (PDR) surface to the shielded interior. This is particularly relevant for 1D models of PDRs or disk surfaces.

* ``height_h2formation``:

    Spatial grid index (counting from the surface) above which the Bron et al. (2014) H\ :sub:`2` formation prescription is applied. Grid points with index below this value use the standard surface network. Set to ``0`` to disable the Bron et al. (2014) method entirely at all grid points.

* ``is_absorption_h2``:

    If ``1``, H\ :sub:`2` self-shielding is included using the prescription of Lee & Herbst (1996).

* ``is_absorption_co``:

    Controls CO self-shielding. Set to ``1`` to use Lee & Herbst (1996), ``2`` to use Visser et al. (2009), or ``0`` to disable CO self-shielding.

* ``is_absorption_n2``:

    If ``1``, N\ :sub:`2` self-shielding is included using the prescription of Li et al. (2013).

* ``is_photodesorb``:

    If ``1``, photodesorption of ice-mantle species is activated, with a default desorption yield of 10\ :sup:`-4` molecules per UV photon. Photodesorption yields can be set individually in the chemical network file.

* ``is_crid``:

    If ``1``, activates the **Cosmic Ray Induced Diffusion** (CRID) mechanism, which enhances the mobility of surface species following cosmic-ray heating events (see Reboussin et al. 2014).

* ``is_er_cir``:

    If ``1``, activates the **Eley–Rideal** (ER) and **Complex Induced Reaction** (CIR) mechanisms on grain surfaces. In the ER mechanism, a gas-phase species reacts directly with an adsorbed species without prior thermalization. Default is ``0`` (disabled).

* ``grain_tunneling_diffusion``:

    Controls whether quantum tunneling is used for the diffusion of light species on grain surfaces:

    * ``0``: Thermal (classical) diffusion for all species.
    * ``1``: Quantum mechanical tunneling (QM1 formulation) for H and H\ :sub:`2`.
    * ``2``: Quantum mechanical tunneling (QM2 formulation) for H and H\ :sub:`2`.
    * ``3``: The fastest of thermal or QM2 tunneling is chosen for H and H\ :sub:`2`.

* ``modify_rate_flag``:

    Activates the modified-rate treatment (Garrod 2008) to correct surface reaction rates when the mean time between reactive events is shorter than the diffusion timescale (i.e., when the rate equations over-produce products):

    * ``0``: No modification.
    * ``1``: Modified rates applied to reactions involving H only.
    * ``2``: Modified rates applied to reactions involving H and H\ :sub:`2`.
    * ``3``: Modified rates applied to all surface reactions.
    * ``-1``: Modified rates applied to the H + H reaction only.

* ``conservation_type``:

    Determines which elemental abundances are enforced by the solver via a conservation equation, replacing one of the differential equations to improve numerical stability:

    * ``0``: Only the electron abundance is conserved (charge conservation).
    * ``1``: Element #1 (as listed in ``element.in``) is also conserved.
    * ``2``: Elements #1 and #2 are both conserved.
    * And so on.

* ``nb_active_lay``:

    Number of chemically active monolayers on the grain surface (i.e., the layers that participate in surface reactions and desorption). In the three-phase model, this defines the boundary between the reactive surface and the inert bulk mantle. A typical value is ``2``.

-------------------------------------

**Dimension and grain-size mode**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``structure_type``:

    Defines the spatial dimension of the simulation and whether gas-phase diffusion between spatial cells is included:

    * ``0D``: Single-point (box) model. The ``spatial_resolution`` parameter is ignored.
    * ``1D_no_diff``: One-dimensional model along a vertical (or radial) structure with **no** turbulent diffusion of gas-phase species between grid cells.
    * ``1D_diff``: One-dimensional model with turbulent diffusion of gas-phase species between adjacent grid cells.

* ``spatial_resolution``:

    Number of spatial grid points in the 1D structure (i.e., the number of rows in ``1D_static.dat`` or ``structure_evolution.dat``). If set to ``1``, the model effectively runs in 0D. This parameter is ignored when ``structure_type = 0D``.

* ``multi_grain``:

    Selects the grain-size treatment:

    * ``0``: **Single-grain mode**. A single representative grain size is used, with the radius given by ``grain_radius``. Dust properties (temperature, density profile) in 1D are read from ``1D_static.dat``.
    * ``1``: **Multi-grain mode**. Multiple grain-size bins are used. Their sizes, abundances, and temperatures are read from ``0D_grain_sizes.in`` (0D) or ``1D_grain_sizes.in`` (1D). See :ref:`sec-0d-input` and :ref:`sec-1d-input`.

-------------------------------------

**Gas-phase parameters**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These parameters set the initial (or uniform, for 0D models) physical conditions of the gas. In 1D mode, they are overridden by the values in ``1D_static.dat`` or ``structure_evolution.dat``.

* ``initial_gas_density``:

    Initial number density of hydrogen nuclei [cm\ :sup:`-3`]. This is the total H nuclei density, i.e., :math:`n_H = n(\mathrm{H}) + 2\,n(\mathrm{H_2})`.

* ``initial_gas_temperature``:

    Initial gas kinetic temperature [K].

* ``initial_visual_extinction``:

    Initial visual extinction :math:`A_V` [mag], which sets the level of UV attenuation at the start of the simulation. In 1D mode, this is the cumulative extinction from the surface to each grid point, as provided in the structure file.

* ``cr_ionisation_rate``:

    Cosmic-ray ionisation rate of molecular hydrogen, :math:`\zeta_{\rm CR}` [s\ :sup:`-1`]. The canonical value for dense clouds is 1.3 × 10\ :sup:`-17` s\ :sup:`-1`.

* ``x_ionisation_rate``:

    Ionisation rate due to X-rays [s\ :sup:`-1`]. Set to ``0`` if X-ray ionisation is not included.

* ``uv_flux``:

    Scaling factor for the interstellar UV radiation field, in units of the standard Draine field. A value of ``1.0`` corresponds to the nominal ISRF. Increase this value to simulate enhanced UV environments such as PDR surfaces or disk atmospheres.

-------------------------------------

**Grain parameters**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These parameters control the properties of the dust grains and the surface chemistry. In multi-grain mode (``multi_grain = 1``), the grain radius and temperature are overridden by the values provided in the grain-size input files.

* ``initial_dust_temperature``:

    Initial (or fixed) dust grain temperature [K]. Only used when ``grain_temperature_type = fixed``.

* ``initial_dtg_mass_ratio``:

    Dust-to-gas mass ratio. The standard ISM value is 0.01.

* ``sticking_coeff_neutral``:

    Sticking coefficient for neutral gas-phase species accreting onto grain surfaces. A value of ``1.0`` means every collision results in adsorption.

* ``sticking_coeff_positive``:

    Sticking coefficient for positively charged (cation) species. Often set to ``0`` because cations are repelled by the negatively charged grain surface.

* ``sticking_coeff_negative``:

    Sticking coefficient for negatively charged (anion) species. Often set to ``0`` because anions are repelled by negatively charged grains at typical conditions.

* ``grain_density``:

    Bulk mass density of the grain material [g cm\ :sup:`-3`]. A value of ``3.0`` is typical for silicate grains.

* ``grain_radius``:

    Grain radius [cm], used in **single-grain mode** only (``multi_grain = 0``). The canonical value for a 0.1 µm grain is ``1.0e-5`` cm. Ignored when ``multi_grain = 1``.

* ``diffusion_barrier_thickness``:

    Thickness of the potential energy barrier for surface diffusion [cm], used in the calculation of quantum tunneling diffusion rates. The standard value is ``1.0e-8`` cm.

* ``surface_site_density``:

    Number density of adsorption sites on the grain surface [cm\ :sup:`-2`]. This determines how many species can be adsorbed per unit surface area. A typical value is ``8.0 × 10``\ :sup:`14` cm\ :sup:`-2`.

* ``diff_binding_ratio_surf``:

    Ratio used to estimate the diffusion barrier from the binding energy for **surface** species whose diffusion barrier is not explicitly specified in the network. The diffusion barrier is set to ``diff_binding_ratio_surf × E_D``.

* ``diff_binding_ratio_mant``:

    Same as above but for **mantle** species (three-phase model only). Mantle species are more tightly bound, so this ratio is typically larger than for surface species (e.g., ``0.8`` vs ``0.4``).

* ``chemical_barrier_thickness``:

    Width of the activation energy barrier for grain-surface reactions with an activation energy [cm]. Used for the quantum tunneling reaction-rate calculation. The standard value is ``1.0e-8`` cm.

* ``cr_peak_grain_temp``:

    Peak grain temperature [K] reached during a cosmic-ray heating event (Hasegawa & Herbst 1993). A typical value for 0.1 µm grains is ``70`` K.

* ``cr_peak_duration``:

    Duration [s] of the grain temperature spike caused by a cosmic-ray impact. Used together with ``cr_peak_grain_temp`` and ``Fe_ionisation_rate`` to calculate the time-averaged desorption rate due to CR heating.

* ``Fe_ionisation_rate``:

    Rate of cosmic-ray Fe-ion impacts per grain per second [s\ :sup:`-1` grain\ :sup:`-1`] for a 0.1 µm grain. Heavy cosmic-ray nuclei (Fe ions) are efficient at heating grains and driving thermal desorption.

* ``vib_to_dissip_freq_ratio``:

    Ratio of the surface–molecule bond vibrational frequency to the rate at which energy is dissipated into the grain lattice. Used in the RRK (Rice–Ramsperger–Kessel) desorption mechanism (Garrod et al. 2007). A value of ``1e-2`` (1%) is the standard assumption.

* ``ED_H2``:

    Binding energy of H\ :sub:`2` on itself [K]. Used in the **desorption encounter mechanism**, where an H\ :sub:`2` molecule formed on the surface may immediately desorb upon formation if it is released with enough energy. The standard value is ``23`` K.

-------------------------------------

**Integration and output parameters**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``start_time``:

    Time of the first output [yr]. The solver begins integrating from ``t = 0`` but only writes output files starting from this time. Setting a small value (e.g., ``1`` yr) captures the early-time chemistry.

* ``stop_time``:

    Time of the last output [yr]. The simulation ends after this time step.

* ``nb_outputs``:

    Total number of time snapshots written to disk, distributed between ``start_time`` and ``stop_time`` according to ``output_type``.

* ``output_type``:

    Spacing of the output times:

    * ``log``: Output times are logarithmically spaced between ``start_time`` and ``stop_time``. Recommended for most simulations, as chemical evolution is often rapid early on and slower later.
    * ``linear``: Output times are linearly spaced.

* ``relative_tolerance``:

    Relative tolerance of the ODE solver (DLSODES). A smaller value gives a more accurate solution at the cost of longer computation time. The default value of ``1e-4`` is a good compromise for most applications.

* ``minimum_initial_abundance``:

    Default minimum fractional abundance assigned to species whose initial abundance is not specified in ``abundances.in`` or is below this threshold. This floor prevents the solver from dealing with exactly-zero initial conditions. Typical value: ``1e-40``.





.. _sec-surf-input:
INPUT: surface_parameters.in (required)
==================

.. _sec-0d-input:
INPUT: 0D_grain_sizes.in (optional)
==================

.. _sec-1d-input:
INPUT: 1D_grain_sizes.in (optional)
==================

.. _sec-static-input:
INPUT: 1D_static.dat  (optional)
==================

The file ``1D_static.dat`` provides the static (time-independent) physical structure for a 1D simulation. It is read when ``structure_type`` is set to ``1D_no_diff`` or ``1D_diff`` in ``parameters.in``. If ``structure_type = 0D``, this file is not read.

The file must contain exactly one header line (starting with ``!``), followed by one data row per spatial grid point. The number of data rows must match the value of ``spatial_resolution`` in ``parameters.in``; if it does not, the code infers the spatial resolution from the number of rows and overrides the value in ``parameters.in``.

Each data row contains **10 space-separated columns**, in the following order:

.. list-table::
   :header-rows: 1
   :widths: 5 20 15 60

   * - #
     - Variable
     - Unit
     - Description
   * - 1
     - z
     - AU
     - Spatial position of the grid point (e.g., height above the disk midplane, or depth into a cloud). Distances are given in AU and converted internally to cm.
   * - 2
     - n\ :sub:`H`
     - cm\ :sup:`-3`
     - Total hydrogen nuclei number density at this grid point, i.e., :math:`n_{\rm H} = n({\rm H}) + 2\,n({\rm H_2})`.
   * - 3
     - T\ :sub:`gas`
     - K
     - Gas kinetic temperature.
   * - 4
     - A\ :sub:`V`
     - mag
     - Visual extinction, measured from the irradiated surface of the structure to this grid point. The outermost exposed layer typically has A\ :sub:`V` = 0.
   * - 5
     - κ\ :sub:`diff`
     - cm\ :sup:`2` s\ :sup:`-1`
     - Turbulent diffusion coefficient for gas-phase species between adjacent grid cells. Only used when ``structure_type = 1D_diff``. Set to ``0`` if turbulent diffusion is not needed.
   * - 6
     - T\ :sub:`dust`
     - K
     - Dust grain temperature at this grid point. Only used when ``grain_temperature_type = table_1D`` in ``parameters.in``; otherwise this column is read but ignored.
   * - 7
     - GTODN
     - —
     - Inverse grain fractional abundance, defined as :math:`{\rm GTODN} = n_{\rm H} / n_{\rm grain}`. The grain abundance relative to hydrogen is then :math:`x_{\rm grain} = 1/{\rm GTODN}`. In **multi-grain mode** (``multi_grain = 1``), this column is overridden by the values read from ``1D_grain_sizes.in``.
   * - 8
     - A\ :sub:`V`/N\ :sub:`H`
     - —
     - Conversion factor between visual extinction and hydrogen column density, specific to the local grain properties. **This column is currently not used by the code** and is reserved for future use. A placeholder value (e.g., ``1.0e-5``) must still be provided.
   * - 9
     - a\ :sub:`grain`
     - cm
     - Grain radius. In **single-grain mode** (``multi_grain = 0``), this sets the grain radius at each grid point and takes precedence over the ``grain_radius`` parameter in ``parameters.in``. In **multi-grain mode** (``multi_grain = 1``), this column is overridden by ``1D_grain_sizes.in``.
   * - 10
     - UV flux
     - ISRF units
     - Local UV radiation field intensity, in units of the standard interstellar radiation field (ISRF). This allows the UV flux to vary spatially along the 1D structure, which is particularly useful for YSO envelopes or disk surfaces irradiated at different angles. This value overrides the global ``uv_flux`` parameter from ``parameters.in`` at each grid point.

.. note::

   In **multi-grain mode** (``multi_grain = 1``), columns 6, 7 and 9 (dust temperature , GTODN, and grain radius) are replaced by the corresponding per-bin values from ``1D_grain_sizes.in``. Columns 1–5, 8, and 10 are always read from ``1D_static.dat`` regardless of the grain mode.

.. warning::

   The number of data rows in ``1D_static.dat`` and in ``1D_grain_sizes.in`` must be identical when running in multi-grain 1D mode. The code will exit with an error if they differ.

.. _sec-evolv-input:
INPUT: structure_evolution.dat  (optional)
==================



-------------------------------------

.. _sec-ab-output:
OUTPUT: abundances.out
==================

The file ``abundances.out`` is the **main output file** of NMGC. It is a single Fortran unformatted (binary) file that contains the chemical abundances of all species, at all spatial grid points, for every output timestep requested. All timesteps are appended sequentially into this one file over the course of the simulation.

.. note::

   This differs from other versions of NAUTILUS, which write one separate binary file per timestep (named ``abundances.000001.out``, ``abundances.000002.out``, etc.). In NMGC, all timesteps are collected into a single ``abundances.out`` file. This change is meant to facililate data handling. 

Each timestep block consists of three sequential unformatted Fortran records, written in the following order:

1. **Time record** — the current simulation time (real, in years).

2. **Physical structure record** — a snapshot of the local physical conditions at the time of output:

   * Gas temperature at each spatial point [K]: array of size ``spatial_resolution``
   * Dust temperature at each spatial point [K]: array of size ``spatial_resolution`` (first grain population)
   * Total H number density at each spatial point [cm\ :sup:`-3`]: array of size ``spatial_resolution``
   * Visual extinction at each spatial point [mag]: array of size ``spatial_resolution``
   * X-ray ionisation rate [s\ :sup:`-1`]: scalar

3. **Abundance record** — fractional abundances (relative to total H) of all chemical species at all spatial points: 2D array of shape ``(nb_species, spatial_resolution)``.

To read this file, one must loop over timestep blocks until the end of the file is reached. The Python package astroMUGS is designed to easily open, read, and plot the content.  

.. _sec-rates-output:
OUTPUT: rates.00000i.out
==================

OUTPUT: col_dens.00000i.out
==================

OUTPUT: species.out
==================

OUTPUT: elemental_abundances.out
==================

OUTPUT: info.out
==================

OUTPUT: ab/, ml/, and struct/
==================

OUTPUT: rates.out
==================

OUTPUT: rate_coefficients.out
==================

