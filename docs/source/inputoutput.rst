.. _chap-input-files:

The input and output files of NMGC
***************************************

The input files are the same as for the official version of Nautilus, except for a few differences. Whenever differences exist between the two version, they are mentioned and described below in each section.   

NMGC needs at minimum six inputs to be able to run. If one of these six files are missing, the code will automatically stop. They are described below and their name is followed by ``(required)``. 
There are three additional optional input files that can be added. 
Wether or not you use one or severals of these optional files will depend on your needs.



.. _sec-inputs:

INPUTS
==================

.. _sec-ab-input:
INPUT: abundances.in (required)
--------------------------------------------

The file ``abundances.in`` sets the initial chemical composition of the gas and/or dust at the start of the simulation. All abundances are **fractional abundances relative to the total hydrogen nuclei density**, i.e., :math:`x_i = n_i / n_{\rm H}`.

**Format:** one species per line, using the syntax ``species_name = value``. Lines beginning with ``!`` are comments. Inline comments (after ``!`` on a data line) are also allowed.

.. code-block:: none

   ! Abundances in relative abundances with respect to Hydrogen
   He    = 9.000000D-02
   H2    = 5.000000D-01
   C+    = 1.700000D-04  ! depleted carbon (dark cloud)
   O     = 2.400000D-04

Any species in the chemical network that is **not listed** in ``abundances.in`` is automatically assigned the default floor value ``minimum_initial_abundance`` defined in ``parameters.in`` (typically ``1.0 × 10``\ :sup:`-40`). It is therefore not necessary to list every species in the network — only those with a meaningful non-negligible starting abundance.

**Atomic vs. molecular initial conditions**

The file can contain either atomic or molecular initial abundances, depending on the physical context:

* **Atomic initial abundances** are typically used for simulations of the interstellar medium or chemically unevolved environments, where the gas is assumed to start from an essentially pristine, unprocessed state. The code then computes the build-up of molecular complexity from scratch. The species to include are those representative of the elemental composition of the gas. A standard set for a solar-composition gas is:

  .. code-block:: none

     He, H, H2, C+, N, O, S+, Si+, Fe+, Na+, Mg+, P+, Cl+, F

  The exact abundances depend on the adopted elemental composition (solar, diffuse ISM, depleted dark cloud, etc.) and the assumed depletion factors for refractory elements.

* **Molecular initial abundances** are preferred when the initial gas is known to already carry some chemical complexity — for instance, when modelling a protoplanetary disk whose material has been processed through an earlier prestellar or protostellar phase, or when restarting from the output of a previous simulation. In this case the file lists the abundances of whichever species are relevant; the rest of the network is initialised at the floor value.

.. note::

   The species names in ``abundances.in`` must match exactly the names used in the chemical network files (``gas_species.in``, ``grain_species.in``). Names are case-sensitive.

.. _sec-act-input:
INPUT: activation_energies.in (required)
--------------------------------------------

The file ``activation_energies.in`` provides the chemical reaction barrier energies (activation energies) for grain-surface and grain-mantle reactions. It is read at startup and its entries are matched against the reactions in the chemical network. Any grain reaction that is **not** listed here is assigned an activation energy of zero (i.e., no chemical barrier).

The file uses the same fixed-width column layout as the reaction network files. Each data line specifies the reactants, products, and activation energy of one reaction:

.. code-block:: none

   !                                                         EA(K)
   JCH4       JCCH                   -> JC2H2      JCH3                  2.50e+02   Mitchell 84
   JH         JCH4                   -> JCH3       JH2                   5.94e+03   JChPhy 50,5076 (1969)
   JH         JCO                    -> JHCO                             2.50e+03   WOON priv commun

The columns are:

* **Reactants** — up to two grain-surface (``J``-prefix) or grain-mantle (``K``-prefix) species, in fixed 11-character wide fields.
* **Products** — the reaction products, also in fixed 11-character wide fields.
* **Activation energy** [K] — the height of the chemical reaction barrier, in Kelvin. This is used in the rate calculation for thermally activated surface reactions (Langmuir–Hinshelwood mechanism) and for the quantum tunneling rate through the barrier.

Lines beginning with ``!`` are treated as comments and skipped. Inline comments (any text after the activation energy value) are also ignored, and are commonly used to record bibliographic references.

.. note::

   In multi-grain mode (``multi_grain = 1``), each entry in this file is automatically replicated for all grain size bins. It is therefore not necessary to list a reaction multiple times for different grain populations.

.. note::

   The activation energies listed here are the **chemical reaction barriers**, distinct from the **diffusion barriers** of surface species (which are derived from the binding energies in ``grain_species.in`` via ``diff_binding_ratio_surf`` and ``diff_binding_ratio_mant`` in ``parameters.in``). Both barriers enter the rate calculation, but they are stored separately.

.. _sec-network-input:
INPUT: chemical network (required)
--------------------------------------------

The chemical network is defined by four files that together describe all the chemical species and reactions included in the simulation: two for the gas-phase chemistry (``gas_species.in`` and ``gas_reactions.in``) and two for the grain-phase chemistry (``grain_species.in`` and ``grain_reactions.in``). All four files must be present for the code to run.

The network format used in NMGC is based on the `KIDA (Kinetic Database for Astrochemistry) <https://kida.astrochem-tools.org/>`_ format, which is a community standard for astrochemical reaction networks. The network distributed with NMGC is derived from the kida.uva.2014 gas-phase network, extended with a grain-surface network. Users may download updated or alternative gas-phase networks directly from the KIDA database and adapt them to the NMGC format.

The species naming conventions used throughout the network are:

* Gas-phase species: standard chemical names (e.g., ``CO``, ``H2O``, ``HCO+``, ``e-``).
* Grain-surface species: prefixed with ``J`` (e.g., ``JCO``, ``JH2O``).
* Grain-mantle species (three-phase model): prefixed with ``K`` (e.g., ``KCO``, ``KH2O``).
* In multi-grain mode, a two-digit bin index is inserted after the prefix: ``J01CO``, ``J02CO``, etc.
* Special pseudo-species: ``CR`` (cosmic ray), ``CRP`` (cosmic-ray-induced UV photon), ``Photon`` (UV photon), ``GRAIN0`` (neutral grain), ``GRAIN-`` (negatively charged grain).


.. _sec-gspec-input:
gas_species.in
~~~~~~~~~~~~~~~~~~~~~~

The file ``gas_species.in`` lists all gas-phase species in the chemical network. The code uses it to identify species, compute molecular masses, and track elemental abundances.

**Format:** one species per line. The first column is the species name, the second column is the electric charge (in units of the elementary charge), and the remaining columns are the integer counts of each element in the molecule, in the same order as they appear in ``element.in``.

.. code-block:: none

   H            0  1  0  0  0  0  0  0  0  0  0  0  0  0
   C            0  0  0  1  0  0  0  0  0  0  0  0  0  0
   OH           0  1  0  0  0  1  0  0  0  0  0  0  0  0
   CO           0  0  0  1  0  1  0  0  0  0  0  0  0  0
   H2O          0  2  0  0  0  1  0  0  0  0  0  0  0  0

For a network with :math:`N_{\rm el}` elements (as listed in ``element.in``), each line has :math:`2 + N_{\rm el}` columns. The order of elements must match exactly the order in ``element.in``.


.. _sec-grspec-input:
grain_species.in
~~~~~~~~~~~~~~~~~~~~~~

The file ``grain_species.in`` lists all species that appear in ``grain_reactions.in``. Its format is identical to ``gas_species.in``. It includes:

* Grain-surface species (``J``-prefix, e.g., ``JH2O``, ``JCO``).
* Grain-mantle species (``K``-prefix) when using the three-phase model.
* Gas-phase species that appear as **products of grain reactions** (e.g., desorption products such as ``H2O``, ``CO``), which must be listed here as well as in ``gas_species.in``.

In multi-grain mode, the code automatically generates entries for each grain bin from the bare species name (e.g., ``JH2O`` → ``J01H2O``, ``J02H2O``, ...), so it is not necessary to list each bin explicitly.


.. _sec-greac-input:
gas_reactions.in
~~~~~~~~~~~~~~~~~~~~~~

The file ``gas_reactions.in`` contains all gas-phase reactions. Each non-comment line defines one reaction with the following fixed-width columns:

.. code-block:: none

   !    Reactants              Products                           A          B          C       ...  ITYPE  Tmin   Tmax  formula  ID
   H          CR             H+         e-                   4.600e-01  0.000e+00  0.000e+00  ...  1    -9999   9999  1    15 1  1
   CO         Photon         C          O                    2.000e-10  0.000e+00  3.100e+00  ...  3    -9999   9999  1   100 1  1
   H3+        CO             HCO+       H2                   1.700e-09 -5.000e-01  0.000e+00  ...  4       10    300  3   200 1  1

The key columns are:

* **Reactants** — up to 3 species in fixed 11-character fields. Pseudo-species ``CR``, ``CRP``, and ``Photon`` are used to identify the type of reaction (see ITYPE below).
* **Products** — up to 5 species in fixed 11-character fields. Empty product slots are left blank.
* **A, B, C** — rate coefficient parameters. For most bimolecular reactions the rate follows the modified Arrhenius (Kooij) formula: :math:`k = A \times (T/300)^B \times e^{-C/T}` [cm\ :sup:`3` s\ :sup:`-1`]. For unimolecular reactions (photodissociation, CR ionisation) A directly gives the rate coefficient in s\ :sup:`-1`.
* **ITYPE** — integer identifying the reaction type and the rate formula to apply. The most common types are:

  .. list-table::
     :header-rows: 1
     :widths: 10 90

     * - ITYPE
       - Reaction class
     * - 0
       - Gas–grain collision (grain charging/neutralisation by ions or electrons)
     * - 1
       - Direct cosmic-ray and X-ray ionisation/dissociation
     * - 2
       - Dissociation by cosmic-ray-induced UV photons (CRP)
     * - 3
       - Photodissociation/ionisation by the interstellar UV field (ISRF)
     * - 4–8
       - Bimolecular gas-phase reactions (ion–neutral, neutral–neutral; several rate formulas)
     * - 14, 21
       - Langmuir–Hinshelwood grain-surface reactions (two adsorbed species)
     * - 15
       - Thermal desorption of grain-surface and mantle species
     * - 16
       - Cosmic-ray spot desorption (Hasegawa & Herbst 1993)
     * - 17
       - UV photodesorption by the ISRF
     * - 18
       - UV photodesorption by CR-induced photons
     * - 99
       - Accretion (adsorption) of a gas-phase species onto the grain surface

* **Tmin, Tmax** — temperature range [K] over which the rate coefficients are valid. Outside this range the rate is clamped to its value at the boundary.
* **formula** — integer selecting the rate formula (e.g., 1 = simple power law, 3 = Kooij, 4 = ionpol1, 5 = ionpol2).
* **ID** — unique reaction identifier. Reactions with the same ID but different temperature ranges represent a single reaction described by multiple sets of coefficients covering different temperature intervals.

The same reaction ID can appear more than once (with different Tmin/Tmax) to provide piecewise rate coefficients. The code selects the entry whose temperature range best matches the current gas temperature.


.. _sec-grreac-input:
grain_reactions.in
~~~~~~~~~~~~~~~~~~~~~~

The file ``grain_reactions.in`` contains all grain-phase reactions: accretion, desorption, surface reactions, and mantle processes. Its format is **identical** to ``gas_reactions.in``. The same ITYPE codes apply, with the grain-specific types (14, 15, 16, 17, 18, 99 and others) being the most common.

A few conventions specific to the grain network:

* Reactant and product species use the ``J``- and ``K``-prefix naming. A gas-phase species appearing as a product indicates desorption back into the gas phase.
* In multi-grain mode, each reaction listed with a bare ``J``- or ``K``-prefix is automatically replicated for all grain bins.
* The ``NA`` string appears in the uncertainty column (in place of ``logn`` used in the gas network) as a placeholder when uncertainty information is unavailable.

.. _sec-elm-input:
INPUT: element.in (required)
--------------------------------------------

The file ``element.in`` lists all atomic elements present in the chemical network, together with their atomic mass in atomic mass units (AMU). The code uses these masses to compute the molecular masses of all species in the network.

**Format:** one element per line — element name followed by its mass in AMU. The first line is a comment header (starting with ``!``).

.. code-block:: none

   ! Species name ; mass (AMU)
   H     1.000
   He    4.000
   C    12.000
   O    16.000
   ...

The set of elements must be consistent with the chemical network: every element that appears in a species name in ``gas_species.in`` or ``grain_species.in`` must be listed here. The masses are used internally to compute molecular masses and do not need to be changed under normal circumstances. Users may modify them (e.g., to use isotopic masses for deuterium chemistry), but should do so with care as incorrect masses will affect accretion rates, thermal desorption rates, and any process that depends on species mass.


.. _sec-param-input:
INPUT: parameters.in (required)
--------------------------------------------

The file ``parameters.in`` is the main parameter file for your chemistry model. It gathers switches, gas-phase parameters, and grain parameters. This is also where you define the integration time, the number of output times,
the simulation mode (dimension and number of grain sizes), and the chemical model (2-phase vs. 3-phase). Below is the exhaustive list of all parameters, in the order they appear in the file. Every line starting with ``!`` is a comment and is not read by the code.

.. note::

   Parameter names and their values are separated by an ``=`` sign. Any text after the value on the same line is treated as a comment and ignored. Blank lines and lines containing only spaces are also skipped.


**Switches**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
--------------------------------------------

The file ``surface_parameters.in`` provides the surface chemistry parameters for all grain-surface species (``J``-prefix) in the network. It is the grain-phase counterpart of ``gas_species.in``. Each non-comment line defines one species and contains the energetic quantities that control its thermal desorption, surface diffusion, quantum tunneling, and enthalpy budget.

**Format:** one species per line with fixed-width columns:

.. code-block:: none

   ! Spec        m/mH  ED(K) Eb(K) dEb(K)                           dHf(kcal/mol)
   JH            1   650.  230. 3.0E+01 Herma, Ebfac=50%         *  +51.63
   JH2           2   440.  220. 0.0e+00 Herma, Ebfac=50%         *    0.00
   JCO          28  1150.    0. 0.0e+00 Herma's suggestion       *  -27.20
   JH2O         18  5700.    0. 0.0e+00 Herma's suggestion       *  -57.10

The columns are:

1. **Species name** (11 characters) — the grain-surface species identifier. The ``J`` prefix denotes a surface species; ``K`` would denote a mantle species (three-phase model). In multi-grain mode, the code automatically replicates each entry for all grain size bins by appending a bin index to the species name.

2. **Mass** [m/m\ :sub:`H`, AMU] — the molecular mass of the species in atomic mass units.

3. **E**\ :sub:`D` [K] — the **binding (desorption) energy**, i.e., the energy required to desorb the species from the grain surface into the gas phase. This is the key parameter controlling the thermal desorption rate.

4. **E**\ :sub:`b` [K] — the **diffusion barrier**, i.e., the energy barrier between adjacent surface sites that the species must overcome to hop across the surface. If set to ``0``, the code computes it automatically as ``diff_binding_ratio_surf × E_D`` (or ``diff_binding_ratio_mant × E_D`` for mantle species), using the ratios defined in ``parameters.in``.

5. **dE**\ :sub:`b` [K] — the **quantum tunneling bandwidth**, used in the calculation of the quantum diffusion rate through the diffusion barrier (Hasegawa & Herbst 1993 formalism). A value of ``0`` disables quantum diffusion for that species.

6. **Reference** (free text, 27 characters) — a bibliographic or descriptive comment. This field is skipped by the parser; the ``*`` character at the end serves only as a visual column separator.

7. **dH**\ :sub:`f` [kcal mol\ :sup:`-1`] — the **standard enthalpy of formation** of the species. This is used in the RRK (Rice–Ramsperger–Kessel) desorption mechanism to compute the energy released upon exothermic surface reactions, part of which may go into desorbing the product directly off the grain. A value of ``-999.99`` is a placeholder indicating the enthalpy is unknown.

Lines beginning with ``!`` are treated as comments and skipped. Commented-out alternative parameter sets (as in the example above) are a common way to document different literature values for the same species without losing them.

.. note::

   In multi-grain mode (``multi_grain = 1``), each line is automatically replicated for all grain size bins. The species name for bin :math:`n` takes the form ``J`` + zero-padded bin index + remainder of the name (e.g., ``J01H``, ``J02H``, ...). It is therefore not necessary to list each grain bin explicitly.

.. _sec-0d-input:
INPUT: 0D_grain_sizes.in (optional)
--------------------------------------------

The file ``0D_grain_sizes.in`` defines the grain size distribution for a **0D (single-point) simulation in multi-grain mode**. It is read when both ``multi_grain = 1`` and ``structure_type = 0D`` are set in ``parameters.in``. If this file is absent under those conditions, the code will exit with an error.

The number of grain size bins is not specified in ``parameters.in`` — it is inferred automatically from the number of non-comment lines in this file. Each non-comment line defines one grain population.

**Format:** one line per grain size bin, with 4 columns:

.. code-block:: none

   ! grain-radius [cm]   1/abundance   grain-temp [K]   CR-peak-Temperature [K]
   2.3265E-06   8.772881E+10   28.25   73
   1.0404E-03   1.970458E+17   17.81   73

The columns are:

1. **Grain radius** [cm] — the representative radius of this grain population.

2. **1/abundance** (GTODN) [dimensionless] — the inverse of the grain fractional abundance relative to hydrogen, :math:`{\rm GTODN} = n_{\rm H} / n_{\rm grain}`. The actual grain abundance used by the code is :math:`x_{\rm grain} = 1/{\rm GTODN}`. Typical values range from ~10\ :sup:`10` for large grains to ~10\ :sup:`13` for small grains, reflecting the fact that fewer large grains are needed to account for the same total dust mass.

3. **Grain temperature** [K] — the fixed temperature of this grain population. Only used when ``grain_temperature_type = fixed_to_dust_size`` in ``parameters.in``; otherwise the column is read but ignored.

4. **CR peak temperature** [K] — the peak grain temperature reached after a cosmic-ray heating event for this grain population (see ``cr_peak_grain_temp`` in ``parameters.in``). Smaller grains typically reach higher peak temperatures upon cosmic-ray impact.

Lines beginning with ``!`` are treated as comments and skipped. Inline comments (any text after a ``!`` on a data line) are also stripped before parsing.

.. note::

   There is no hard upper limit on the number of grain size bins, but it is recommended to keep the number small (typically 2–10) as each additional grain population adds a full set of grain-surface species to the chemical network, which significantly increases the computational cost.


.. _sec-1d-input:
INPUT: 1D_grain_sizes.in (optional)
--------------------------------------------

The file ``1D_grain_sizes.in`` defines the grain size distribution for a **1D simulation in multi-grain mode**. It is read when both ``multi_grain = 1`` and ``structure_type = 1D_no_diff`` or ``1D_diff`` are set in ``parameters.in``. It allows the grain properties (size, abundance, temperature) to vary spatially along the 1D grid.

The number of grain size bins is inferred automatically from the number of columns: ``nb_grains = total_columns / 4``. The number of data lines must equal the number of spatial grid points (``spatial_resolution``), and must match the number of rows in ``1D_static.dat``.

**Format:** one line per spatial grid point. All grain properties for all grain populations are written on a single line, **grouped by quantity** (not interleaved): first all grain radii, then all GTODN values, then all grain temperatures, then all CR peak temperatures.

For a simulation with :math:`N` grain bins and :math:`M` spatial points, the file has :math:`M` data lines each containing :math:`4 \times N` values:

.. code-block:: none

   ! grain-radius [cm](1:N)   1/abundance(1:N)   grain-temp [K](1:N)   CR-peak-Temp [K](1:N)   ! spatial_point
   a_1  a_2 ... a_N    GTODN_1  GTODN_2 ... GTODN_N    T_1  T_2 ... T_N    Tcr_1  Tcr_2 ... Tcr_N    ! 1
   a_1  a_2 ... a_N    GTODN_1  GTODN_2 ... GTODN_N    T_1  T_2 ... T_N    Tcr_1  Tcr_2 ... Tcr_N    ! 2
   ...

The four groups of columns are:

1. **Grain radii** [cm] — one value per grain bin, the representative radius of each grain population at this spatial point.

2. **1/abundance** (GTODN) [dimensionless] — one value per grain bin, :math:`n_{\rm H} / n_{\rm grain}` for each population. This allows the grain size distribution to evolve spatially (e.g., grain growth toward the disk midplane, or settling of large grains).

3. **Grain temperatures** [K] — one value per grain bin. Only used when ``grain_temperature_type = fixed_to_dust_size``; otherwise read but ignored.

4. **CR peak temperatures** [K] — one value per grain bin. Overrides ``cr_peak_grain_temp`` from ``parameters.in`` on a per-grain, per-point basis.

Lines beginning with ``!`` are skipped. Inline comments (after a ``!`` on a data line) are stripped before parsing, so a spatial-point index comment at the end of each line (as in the example files) is harmless and recommended for readability.

.. note::

   The same recommendation on the number of grain bins applies as for ``0D_grain_sizes.in``: keep it small (typically 2–10). In multi-grain mode, this file **overrides columns 6, 7, and 9** of ``1D_static.dat`` (dust temperature, GTODN, and grain radius respectively) at every spatial point. The single dust temperature in column 6 of ``1D_static.dat`` is not read when ``multi_grain = 1``; per-bin temperatures from this file are used instead.

.. _sec-static-input:
INPUT: 1D_static.dat  (optional)
--------------------------------------------

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
--------------------------------------------

The file ``structure_evolution.dat`` provides a time-dependent physical structure for the simulation. It is read when ``is_structure_evolution = 1`` is set in ``parameters.in``. **This file is currently only supported in 0D mode** (``structure_type = 0D``).

At each chemistry time step, the code interpolates the physical conditions from this table and updates the model accordingly, allowing the chemistry to evolve under continuously changing conditions. Typical use cases include:

* tracking the chemical evolution of a fluid parcel drifting through a varying environment (e.g., a dust grain settling toward the disk midplane, or infall along a streamline in a protostellar envelope);
* studying the chemical response to episodic or transient events such as accretion bursts (FU Ori-type outbursts), UV flares, or periodic irradiation variability;
* modelling the chemical history along trajectories extracted from hydrodynamical simulations.

**Format:** two comment lines as a header, followed by one data row per time sample:

.. code-block:: none

   ! time    log(Av)    log(n)    log(T)
   ! (yr)   (mag)      (cm-3)    (K)
   0.000e+00 -1.231e+00 1.813e+00 1.698e+00
   2.360e-01 -1.233e+00 1.758e+00 1.712e+00
   ...

The columns are:

1. **Time** [yr] — the time of this sample, in years. Converted internally to seconds.
2. **log**\ :sub:`10`\ **(A**\ :sub:`V`\ **)** [log\ :sub:`10`\ (mag)] — the base-10 logarithm of the visual extinction.
3. **log**\ :sub:`10`\ **(n**\ :sub:`H`\ **)** [log\ :sub:`10`\ (cm\ :sup:`-3`\ )] — the base-10 logarithm of the total hydrogen nuclei number density.
4. **log**\ :sub:`10`\ **(T**\ :sub:`gas`\ **)** [log\ :sub:`10`\ (K)] — the base-10 logarithm of the gas kinetic temperature.
5. **log**\ :sub:`10`\ **(T**\ :sub:`dust`\ **)** [log\ :sub:`10`\ (K)] — *(optional)* the base-10 logarithm of the dust temperature. If this column is present, ``grain_temperature_type`` must be set to ``table_evolv`` in ``parameters.in``; the code will exit with an error otherwise. If the column is absent, the dust temperature is handled according to the ``grain_temperature_type`` setting.

Note that all physical quantities except time are given as **base-10 logarithms**. A future version of NMGC will extend this file to also include a time-varying UV radiation field.

.. warning::

   The time samples must be **linearly and equally spaced**. The code computes the interpolation step as a constant interval between the first and last time entry and will produce incorrect results if the spacing is irregular.



-------------------------------------

.. _sec-outputs:

OUTPUTS
==================

.. _sec-ab-output:
OUTPUT: abundances.out
--------------------------------------------

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
--------------------------------------------

OUTPUT: col_dens.00000i.out
--------------------------------------------

OUTPUT: species.out
--------------------------------------------

OUTPUT: elemental_abundances.out
--------------------------------------------

OUTPUT: info.out
--------------------------------------------

OUTPUT: ab/, ml/, and struct/
--------------------------------------------

OUTPUT: rates.out
--------------------------------------------

OUTPUT: rate_coefficients.out
--------------------------------------------

