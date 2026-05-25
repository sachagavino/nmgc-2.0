The astrochemistry of NMGC
==========================

.. note::

   This page documents the physical and chemical equations implemented in NMGC,
   cross-referenced against the source code in ``src/``. All equation labels
   reference *Gavino (2020), Chapter 3* (Thesis), denoted **[G20-§x]** below.
   Fortran source references are given as ``filename.f90:line``.


Introduction
------------

NMGC (NAUTILUS Multi-Grain Code) is a time-dependent gas-grain astrochemical code
that evolves the chemical abundances of hundreds to thousands of molecular species
in astrophysical environments (dark clouds, protoplanetary disks, PDRs, …).
It couples:

- **Gas-phase chemistry** — reactions between gas-phase species.
- **Surface chemistry** — adsorption, desorption, diffusion, and reactions on grain surfaces.
- **Mantle chemistry** — reactions in the bulk ice mantle (three-phase model).

The code is based on :cite:t:`Hasegawa1992` and successive improvements
:cite:t:`Ruaud2016,Iqbal2018`. This chapter describes the physical equations
that govern each process, their NMGC implementation, and notes any discrepancy
between the simplified reference description and the actual code.


Chemical kinetics
-----------------

Consider a gas-phase reaction between two reactants :math:`X_1` and :math:`X_2`
forming products :math:`X_3` and :math:`X_4`:

.. math::

   X_1 + X_2 \rightarrow X_3 + X_4.

The **rate** :math:`v` of this elementary reaction is:

.. math::

   v = k_{12}\,[X_1]\,[X_2],

where :math:`k_{12}` is the rate constant and :math:`[X_i]` denotes number density
(cm\ :sup:`−3`). The time-evolution of species :math:`i` is driven by the balance
of all formation and destruction reactions:

.. math::

   \frac{\mathrm{d}[X_i]}{\mathrm{d}t} = \text{Formation} - \text{Destruction}.

For a network of :math:`N` species and :math:`M` reactions this gives a coupled,
non-linear system of :math:`N` stiff ordinary differential equations (ODEs):

.. math::

   \frac{\mathrm{d}[X_i]}{\mathrm{d}t} = f_i\!\left([X_1], \ldots, [X_N]\right),
   \quad i = 1, \ldots, N.

**Source:** ``ode_solver.f90:get_temporal_derivatives`` (lines 380–543) assembles
:math:`\dot{Y}` for every species by looping over all reactions, accumulating gains
into products and losses from reactants (``YD2`` arrays).

.. code-block:: fortran
   :caption: ode_solver.f90 — core ODE loop (simplified)

   do I = 1, nb_reactions
     RATE = reaction_rates(I) * Y(r1) * Y(r2) * actual_gas_density   ! two-body
     YD2(product1) = YD2(product1) + RATE
     YD2(reactant1) = YD2(reactant1) - RATE
     ...
   enddo


Rate-equation approach
----------------------

NMGC uses the **rate-equation** (deterministic, continuous) approach.
The stiff ODE system is integrated by **DLSODES** (double-precision LSODES from
ODEPACK), a multi-step Adams/BDF solver with sparse Jacobian support
:cite:t:`Hindmarsh1983`.  The Jacobian is computed analytically in
``ode_solver.f90:get_jacobian`` (lines 219–365).

**Strengths:**

- Computationally efficient even for large networks (thousands of species).
- Numerically stable for stiff systems.

**Limitations:**

- Deterministic and continuous — poor accuracy when surface populations are
  small (stochastic regime, :math:`N_s \lesssim 1`).
- Does not resolve discrete thermal fluctuations of grain temperature.

The time-integration is driven from ``main.f90`` via repeated calls to DLSODES.
Rates are split into **constant** (temperature/density-only dependent,
``set_constant_rates``) and **abundance-dependent** (``set_dependant_rates``),
the latter called inside the ODE integrator at each function evaluation.


The three-phase model
---------------------

NMGC implements the three-phase model of :cite:t:`Ruaud2016`, tracking
gas-phase :math:`n(i)`, surface :math:`n_s(i)`, and mantle :math:`n_m(i)`
densities for each species :math:`i`.

The three coupled ODEs
^^^^^^^^^^^^^^^^^^^^^^

Gas-phase evolution:

.. math::

   \frac{\mathrm{d}n(i)}{\mathrm{d}t} =
     \sum_{l,j} k_{lj}\,n(l)\,n(j)
     + k_{\mathrm{diss}}(j)\,n(j)
     + k_{\mathrm{des}}(i)\,n_s(i)
     - k_{\mathrm{acc}}(i)\,n(i)
     - k_{\mathrm{diss}}(i)\,n(i)
     - n(i)\sum_j k_{ij}\,n(j).

Surface evolution:

.. math::

   \frac{\mathrm{d}n_s(i)}{\mathrm{d}t} =
     \sum_{l,j} k^s_{lj}\,n_s(l)\,n_s(j)
     + k^s_{\mathrm{diss}}(j)\,n_s(j)
     + k_{\mathrm{acc}}(i)\,n(i)
     + k^m_{\mathrm{swap}}(i)\,n_m(i)
     + \frac{\mathrm{d}n_m(i)}{\mathrm{d}t}\bigg|_{m\to s}
     - n_s(i)\sum_j k^s_{ij}\,n_s(j)
     - k_{\mathrm{des}}(i)\,n_s(i)
     - k^s_{\mathrm{diss}}(i)\,n_s(i)
     - k^s_{\mathrm{swap}}(i)\,n_s(i)
     - \frac{\mathrm{d}n_s(i)}{\mathrm{d}t}\bigg|_{s\to m}.

Mantle evolution:

.. math::

   \frac{\mathrm{d}n_m(i)}{\mathrm{d}t} =
     \sum_{l,j} k^m_{lj}\,n_m(l)\,n_m(j)
     + k^m_{\mathrm{diss}}(j)\,n_m(j)
     + k^m_{\mathrm{swap}}(i)\,n_s(i)
     + \frac{\mathrm{d}n_s(i)}{\mathrm{d}t}\bigg|_{s\to m}
     - n_m(i)\sum_j k^m_{ij}\,n_m(j)
     - k^m_{\mathrm{diss}}(i)\,n_m(i)
     - k^m_{\mathrm{swap}}(i)\,n_m(i)
     - \frac{\mathrm{d}n_m(i)}{\mathrm{d}t}\bigg|_{m\to s}.

**Implementation:** In ``ode_solver.f90:get_temporal_derivatives`` (lines 380–543)
the main ODE loop handles gas-phase and all surface/mantle reactions uniformly via
``YD2``.  Reaction types 40 and 41 (surface↔mantle transfer) are accumulated
separately and added after the call to ``set_dependant_rates_3phase`` (lines
468–537).

Surface-to-mantle and mantle-to-surface transfer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Surface-to-mantle** (type 40):

.. math::
   :label: s2m

   \frac{\mathrm{d}n_s(i)}{\mathrm{d}t}\bigg|_{s\to m}
   = \alpha_{\mathrm{gain}}\,\frac{n_s(i)}{n_{s,\mathrm{tot}}}\,
     \frac{\mathrm{d}n_{s,\mathrm{gain}}}{\mathrm{d}t},

with:

.. math::

   \alpha_{\mathrm{gain}} = \frac{\sum_i N_s(i)}{\beta\,N_{\mathrm{site}}},
   \quad \beta = 2\;\text{(Fayolle et al. 2011)}.

**Mantle-to-surface** (type 41):

.. math::
   :label: m2s

   \frac{\mathrm{d}n_m(i)}{\mathrm{d}t}\bigg|_{m\to s}
   = \alpha_{\mathrm{loss}}\,\frac{n_m(i)}{n_{m,\mathrm{tot}}}\,
     \frac{\mathrm{d}n_{s,\mathrm{loss}}}{\mathrm{d}t},

with:

.. math::

   \alpha_{\mathrm{loss}} = \min\!\left(\frac{\sum_i N_m(i)}{\sum_i N_s(i)},\; 1\right).

**Implementation** — ``ode_solver.f90:set_dependant_rates_3phase``,
lines 2001–2054:

.. code-block:: fortran
   :caption: ode_solver.f90:2033–2037 — surface-to-mantle transfer (type 40)

   ! alpha_gain = (ab_surf * GTODN / N_site) / nb_active_lay
   alpha_3_phase = ab_surf(ic_i) * GTODN(ic_i) / nb_sites_per_grain(ic_i) / nb_active_lay
   reaction_rates(j) = alpha_3_phase * rate_tot_acc(ic_i) / ab_surf(ic_i)

.. code-block:: fortran
   :caption: ode_solver.f90:2004–2007 — mantle-to-surface transfer (type 41)

   ! alpha_loss = min(ab_mant / ab_surf, 1)
   alpha_3_phase = ab_mant(ic_i) / ab_surf(ic_i)
   IF (alpha_3_phase >= 1.0d0) alpha_3_phase = 1.0d0
   reaction_rates(j) = -alpha_3_phase * rate_tot_des(ic_i) / ab_mant(ic_i)

**✓ Verified:** :eq:`s2m` and :eq:`m2s` are correctly implemented.
``nb_active_lay`` = :math:`\beta = 2` (set in ``parameters.in``),
``rate_tot_acc`` and ``rate_tot_des`` are the total surface accretion and
desorption rates accumulated in ``get_temporal_derivatives`` (lines 470–485).

Mantle-to-surface swapping
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. math::
   :label: swap_m

   k^m_{\mathrm{swap}}(i) =
   \begin{cases}
     \dfrac{1}{t^m_{\mathrm{hop}}(i)} & N_{\mathrm{lay,m}} < 1 \\[6pt]
     \dfrac{1}{t^m_{\mathrm{hop}}(i)\,N_{\mathrm{lay,m}}} & N_{\mathrm{lay,m}} \geq 1
   \end{cases}

**Implementation** — lines 2010–2022:

.. code-block:: fortran
   :caption: ode_solver.f90:2011,2014 — mantle-to-surface swapping

   rate_mant_to_surf = y(r1) * THERMAL_HOPING_RATE(r1)
   if (sumlaymant(ic_i) >= 1.0d0) &
     rate_mant_to_surf = rate_mant_to_surf / sumlaymant(ic_i)
   rate_mant_to_surf = rate_mant_to_surf / y(r1)   ! gives k_swap^m

where ``THERMAL_HOPING_RATE(K)`` = :math:`\nu_0\exp(-E^m_{\mathrm{diff}}/T_d)/N_{\mathrm{site}}`
and ``sumlaymant`` = :math:`N_{\mathrm{lay,m}} = \sum_i N_m(i)/N_{\mathrm{site}}`.

Surface-to-mantle swapping
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. math::
   :label: swap_s

   k^s_{\mathrm{swap}}(i) = \frac{\sum_j k^m_{\mathrm{swap}}(j)\,n_m(j)}{n_{s,\mathrm{tot}}}.

**Implementation** — lines 2040–2043:

.. code-block:: fortran
   :caption: ode_solver.f90:2041 — surface-to-mantle swapping

   rate_surf_to_mant = y(r1) * rate_tot_mant_surf(ic_i) / ab_surf(ic_i)
   rate_surf_to_mant = rate_surf_to_mant / y(r1)   ! gives k_swap^s

where ``rate_tot_mant_surf`` accumulates :math:`\sum_j k^m_{\mathrm{swap}}(j)\,Y_j`
over all mantle species.

**✓ Verified:** :eq:`swap_m` and :eq:`swap_s` are exactly implemented.

Mantle chemistry
^^^^^^^^^^^^^^^^

Mantle species (prefix ``K`` in the reaction network) participate in
LH-type reactions (type 14/21) exactly as surface species, but with their own
diffusion barriers (``DIFF_BINDING_RATIO_MANT``).  When
:math:`N_{\mathrm{lay,m}} > 1`, the LH rate is additionally divided by
:math:`N_{\mathrm{lay,m}}` to account for the increased scanning time through
the mantle (``ode_solver.f90:1825–1827``).

Three-phase flag
^^^^^^^^^^^^^^^^

The three-phase model is activated by setting ``is_3_phase = 1`` in
``parameters.in``.  When ``is_3_phase = 0``, types 40 and 41 rates are zeroed
(lines 2024, 2050) and NMGC runs as a two-phase (gas + surface) model.

.. rubric:: Summary of reaction type codes

.. list-table:: NMGC reaction type codes
   :header-rows: 1
   :widths: 10 40 30

   * - Type
     - Process
     - Source routine
   * - 0
     - Gas–grain charge reactions
     - ``set_constant_rates``
   * - 1
     - Direct CR/X-ray ionization (gas)
     - ``set_constant_rates``
   * - 2
     - CR-induced UV photodissociation (gas)
     - ``set_dependant_rates``
   * - 3
     - UV photodissociation, ISRF (gas)
     - ``set_dependant_rates``
   * - 4–8
     - Bimolecular gas reactions (Kooij, Ionpol)
     - ``set_constant_rates``
   * - 10–11
     - Ad-hoc H\ :sub:`2` formation (legacy)
     - ``set_constant_rates``
   * - 14
     - LH surface reactions
     - ``set_dependant_rates``
   * - 15
     - Thermal evaporation (surface)
     - ``set_constant_rates``
   * - 16
     - CR-induced desorption (surface)
     - ``set_constant_rates``
   * - 17–18
     - CR-induced UV photodissociation (surface)
     - ``set_dependant_rates``
   * - 19–20
     - UV photodissociation (surface)
     - ``set_dependant_rates``
   * - 21
     - LH mantle reactions
     - ``set_dependant_rates``
   * - 30
     - Eley-Rideal reactions
     - ``set_dependant_rates``
   * - 31
     - Complex Induced Reactions (CIR/Hot-Atom)
     - ``set_constant_rates``
   * - 40
     - Surface-to-mantle transfer
     - ``set_dependant_rates_3phase``
   * - 41
     - Mantle-to-surface transfer
     - ``set_dependant_rates_3phase``
   * - 66
     - Photodesorption by external UV
     - ``set_dependant_rates``
   * - 67
     - Photodesorption by CR-induced UV
     - ``set_dependant_rates``
   * - 97
     - B14 stochastic H\ :sub:`2` formation (gas-phase equivalent)
     - ``set_dependant_rates``
   * - 99
     - Accretion (gas → surface)
     - ``set_dependant_rates``


Gas-phase chemistry
-------------------

Reaction rate constants follow the **modified Arrhenius equation** (Kooij formula):

.. math::
   :label: arrhenius

   k_{ij} = \alpha_{ij}\left(\frac{T_g}{300\,\mathrm{K}}\right)^{\!\beta}
             \exp\!\left(\frac{-E_{A,ij}}{k_B\,T_g}\right),

where :math:`\alpha_{ij}` is the pre-exponential factor, :math:`\beta` the
temperature exponent (:math:`-1 \leq \beta \leq 1`, with :math:`\beta = 0` giving
classical Arrhenius), :math:`E_{A,ij}` the activation energy, and :math:`T_g` the
gas temperature.  The reference temperature is :math:`T_0 = 300\,\mathrm{K}`.

**Implementation** — ``ode_solver.f90:set_constant_rates``, reaction type 4–8 (formula 3):

.. code-block:: fortran
   :caption: ode_solver.f90:672 — Kooij (modified Arrhenius), formula 3

   reaction_rates(J) = RATE_A(J) * (T300**RATE_B(J)) * EXP(-RATE_C(J) / actual_gas_temp)

where ``T300 = actual_gas_temp / 300.d0``, ``RATE_A`` = :math:`\alpha`,
``RATE_B`` = :math:`\beta`, ``RATE_C`` = :math:`E_A / k_B` (in K).
Temperature-clamping to ``[REACTION_TMIN, REACTION_TMAX]`` is applied when
outside the valid range.  Ion-polar reactions use the Ionpol1 (formula 4) and
Ionpol2 (formula 5) formulae (lines 724–826).

**✓ Verified:** implementation matches :eq:`arrhenius`.

Ionization and dissociation by cosmic rays
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Direct cosmic-ray (and X-ray) ionization/dissociation (reaction type 1) is computed as:

.. math::

   k_{\mathrm{diss}}(i) = \alpha_i\,\zeta,

where :math:`\zeta = \zeta_{\mathrm{CR}} + \zeta_X` is the total ionization rate.

**Implementation** — ``ode_solver.f90:set_constant_rates``, type 1:

.. code-block:: fortran
   :caption: ode_solver.f90:647

   reaction_rates(J) = RATE_A(J) * (CR_IONISATION_RATE + X_IONISATION_RATE)

Cosmic-ray induced **UV** photodissociation (type 2) accounts for H\ :sub:`2`
fraction and grain albedo (:math:`\omega = 0.5`, hardcoded):

.. math::

   k_{\mathrm{diss}}(i) \approx \alpha_i\,\zeta\,\frac{n(\mathrm{H}_2)}{0.5\,n_H}
   \approx \alpha_i\,\zeta\,\frac{1}{1-\omega}\,\frac{n(\mathrm{H}_2)}{n_H},

**Implementation** — type 2:

.. code-block:: fortran
   :caption: ode_solver.f90:1252

   reaction_rates(J) = RATE_A(J) * (CR_IONISATION_RATE + X_IONISATION_RATE) * Y(INDH2) / 0.5D0

.. note::

   The full reference formula [G20, Eq. III.rate1] is
   :math:`\alpha\,\zeta_{H_2}\,(1-\omega)^{-1}\,n(H_2)/[n(H)+2n(H_2)]`.
   The code simplifies this by assuming mostly molecular gas
   (:math:`n(H) \ll 2\,n(H_2)`) and fixing :math:`\omega = 0.5`.
   This is a minor simplification acceptable for dense, predominantly molecular gas.

Ionization and dissociation by UV (ISRF or CR-induced)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

UV photodissociation by the ISRF (or CR-induced UV photons, type 3) follows:

.. math::

   k_{\mathrm{diss}}(i) = \alpha_i\,\chi\,\exp(-\beta_i\,A_v),

where :math:`\chi` is the UV scaling factor (``UV_FLUX``) and :math:`A_v` the
visual extinction.

**Implementation** — type 3:

.. code-block:: fortran
   :caption: ode_solver.f90:1264

   reaction_rates(J) = RATE_A(J) * EXP(-RATE_C(J) * actual_av) * UV_FLUX

Self-shielding corrections for H\ :sub:`2`, CO, and N\ :sub:`2` are applied when
the relevant flags (``is_absorption_h2``, ``is_absorption_co``, ``is_absorption_n2``)
are set (lines 1270–1408).  Full wavelength-resolved cross-section photorates
(Heays et al. 2017 formalism, flag ``photo_disk = 1``) are computed via the
``photorates`` module.

**✓ Verified:** implementation matches the reference formula.


Surface chemistry
-----------------

Adsorption
^^^^^^^^^^

The **sticking coefficient** :math:`S(X)` gives the probability that an incoming
species :math:`X` remains on the grain surface after a collision.  The accretion
rate of species :math:`X` onto a grain of radius :math:`a_i` is:

.. math::

   f_{\mathrm{acc}}(X) = S(X)\,v_X\,n_d(a_i)\,a_i^2\,n_g(X),

where :math:`v_X = \sqrt{8k_B T_g / (\pi m_X)}` is the mean thermal velocity and
:math:`n_d(a_i)` is the grain number density.

**Implementation** — ``gasgrain.f90:init_reaction_rates`` (lines 690–724) and
``ode_solver.f90:set_dependant_rates``, type 99 (lines 1528–1596):

.. code-block:: fortran
   :caption: gasgrain.f90:691 — accretion prefactor (π a² √(8kB/π/AMU))

   COND(i) = PI * grain_radii(i)**2 * SQRT(8.0d0 * K_B / PI / AMU)

.. code-block:: fortran
   :caption: ode_solver.f90:1140,1536 — sticking-weighted accretion rate

   ACC_RATES_PREFACTOR(J) = COND(j) * STICK_SPEC(r1) / SQRT(SPECIES_MASS(r1))
   ACCRETION_RATES(r1)    = ACC_RATES_PREFACTOR(J) * TSQ * Y(r1) * actual_gas_density

where ``TSQ = sqrt(Tg)``, so the full expression gives:

.. math::

   f_{\mathrm{acc}} = \pi a^2 \sqrt{\frac{8k_B}{\pi m_X}}\,S(X)\,\sqrt{T_g}\,
                      Y(X)\,n_H
                    = S(X)\,v_X\,n_d\,a^2\,n_g(X),

with :math:`n_g(X) = Y(X)\,n_H` and :math:`n_d \equiv n_H/\mathrm{GTODN}`.

**Species-specific sticking** (``sticking_special_cases``, lines 2072–2130):
H and H\ :sub:`2` use temperature-dependent sticking coefficients
:cite:t:`Chaabouni2012` with a smooth interpolation between bare-grain and
ice-covered surface values.

**Two bonding types** are recognized in the surface parameter file
(``surface_parameters.in``):

- **Physisorption** (Lennard-Jones potential): binding energy 10–400 meV,
  stored as ``BINDING_ENERGY`` in Kelvin.
- **Chemisorption** (Morse potential): binding energy 1–10 eV (mainly for H
  and radicals on graphitic sites).

**✓ Verified:** accretion rates match the reference formula exactly.

Desorption
^^^^^^^^^^

Thermal desorption
""""""""""""""""""

The thermal desorption rate depends on the binding energy :math:`E_{\mathrm{bind}}(X)`
and the characteristic vibrational frequency :math:`\nu(X)`:

.. math::
   :label: thermal_des

   k_{\mathrm{des,th}}(X) = \nu(X)\,\exp\!\left(\frac{-E_{\mathrm{bind}}(X)}{k_B T_d}\right),

with the vibrational frequency:

.. math::
   :label: vib_freq

   \nu(X) = \sqrt{\frac{2\,n_s\,E_{\mathrm{bind}}(X)}{\pi^2\,m_X}}
           = \sqrt{\frac{2\,E_{\mathrm{bind}}(X)}{\pi^2\,d^2\,m_X}},

where :math:`n_s` is the surface site density (:math:`\approx d^{-2}`,
:math:`d = 1\,\text{Å}`) and :math:`m_X` is the mass of species :math:`X`.

**Implementation** — ``gasgrain.f90:init_reaction_rates``, lines 920–923:

.. code-block:: fortran
   :caption: gasgrain.f90:922 — vibrational frequency

   VIBRATION_FREQUENCY(I) = SQRT(2.0d0 * K_B / PI / PI / AMU &
                             * SURFACE_SITE_DENSITY * BINDING_ENERGY(I) / SMA)

where ``SMA`` is the species mass in AMU, ``BINDING_ENERGY`` in Kelvin
(so ``K_B * BINDING_ENERGY`` gives energy in erg), and ``SURFACE_SITE_DENSITY``
plays the role of :math:`n_s \approx d^{-2}`.

Thermal desorption rates (type 15) — ``ode_solver.f90:set_constant_rates``, line 846:

.. code-block:: fortran
   :caption: ode_solver.f90:846 — thermal evaporation rate

   reaction_rates(J) = RATE_A(J) * branching_ratio(J) &
                      * VIBRATION_FREQUENCY(r1) * EXP(-BINDING_ENERGY(r1) / Td)

**✓ Verified:** both :eq:`thermal_des` and :eq:`vib_freq` are exactly implemented.

Cosmic-ray desorption (sputtering)
"""""""""""""""""""""""""""""""""""

A cosmic-ray heats the grain transiently to a peak temperature
:math:`T_{\mathrm{CR}}` (dependent on grain size), causing enhanced thermal
desorption during the peak duration :math:`\Delta t_{\mathrm{CR}}`:

.. math::

   k_{\mathrm{des,CR}}(X) = f_{\mathrm{CR}}\,\nu(X)\,
                             \exp\!\left(\frac{-E_{\mathrm{bind}}(X)}{k_B T_{\mathrm{CR}}}\right),

where :math:`f_{\mathrm{CR}}` encodes the fraction of time spent at the peak.

**Implementation** — type 16, ``ode_solver.f90:set_constant_rates``, lines 864–904:

.. code-block:: fortran
   :caption: ode_solver.f90:886 — CR desorption

   reaction_rates(J) = RATE_A(J) * branching_ratio(J) &
     * (zeta / 1.3D-17) * VIBRATION_FREQUENCY(r1) &
     * FE_IONISATION_RATE_r_dpnt * CR_PEAK_DURATION &
     * EXP(-BINDING_ENERGY(r1) / CR_PEAK_GRAIN_TEMP_all(grain_rank))

.. note::

   **Discrepancy vs. simplified description:** The briefing states a fixed 70 K
   peak temperature.  The code uses ``CR_PEAK_GRAIN_TEMP_all(grain_rank)``, which
   is a **grain-size-dependent** CR peak temperature computed for each size bin.
   Large grains (:math:`a > 100\,\mu\mathrm{m}`) have CR desorption suppressed
   (line 890: ``if (grain_radii > 1.D-4) reaction_rates = 0.D0``).
   This is physically more accurate than the simplified 70 K prescription.

Photodesorption
"""""""""""""""

UV photodesorption is implemented for two sources:

- **External UV** (type 66, lines 1604–1619): rate scales as
  :math:`\alpha / n_s \times G_0 \times \exp(-2 A_v)`.
- **CR-induced UV** (type 67, lines 1626–1640): rate scales as
  :math:`\alpha / n_s \times 10^4 \times \zeta_{\mathrm{ref}}/\zeta`.

A ``MLAY = 2`` layer correction ensures that only the upper :math:`\sim 2`
monolayers can photodesorb when the surface coverage exceeds 2 monolayers.

Chemical (reactive) desorption
"""""""""""""""""""""""""""""""

Chemical desorption (CD) is the ejection of a newly formed product into the
gas-phase using part of the reaction exothermicity.

**Garrod et al. 2007 prescription** (``is_chem_des = 0``, **default**):

.. math::
   :label: chem_des_garrod

   \mathrm{CD} = \frac{a\,\Xi}{1 + a\,\Xi}, \quad
   \Xi = \left(1 - \frac{E_{\mathrm{bind}}}{E_{\mathrm{exo}}}\right)^{s-1},

where :math:`a = \nu(X)/\nu_d` (ratio of vibrational frequency to grain energy
dissipation rate, parameter ``VIB_TO_DISSIP_FREQ_RATIO``), :math:`E_{\mathrm{exo}}`
is the reaction exothermicity (from formation enthalpies), and:

.. math::

   s - 1 = \begin{cases} 1 & \text{diatomics}\ (N = 2)\\ 3N - 6 & \text{polyatomics}\ (N > 2). \end{cases}

**Implementation** — ``gasgrain.f90:init_reaction_rates``, lines 1285–1358:

.. code-block:: fortran
   :caption: gasgrain.f90:1286 — Garrod 2007 chemical desorption (is_chem_des=0)

   SUM2 = 1.0d0 - (SUM1 / DHFSUM)            ! SUM1 = E_bind, DHFSUM = E_exo
   if (ATOMS .EQ. 2) SUM2 = SUM2**(3*ATOMS-5)  ! s-1 = 1 for diatomics
   if (ATOMS .GT. 2) SUM2 = SUM2**(3*ATOMS-6)  ! s-1 = 3N-6 for polyatomics
   SUM2 = VIB_TO_DISSIP_FREQ_RATIO * SUM2       ! a * Xi
   EVFRAC = SUM2 / (1.0d0 + SUM2)              ! a*Xi / (1 + a*Xi)

**✓ Verified:** exactly implements :eq:`chem_des_garrod`.

The **Minissale et al. 2016** prescription (``is_chem_des = 1``) is also
implemented (lines 1294–1315) but was **not used** in the thesis work.

.. note::

   The EVFRAC is then used as a multiplier on the ``branching_ratio`` for surface
   reactions, splitting the reaction flux between a fraction staying on the grain
   and a fraction desorbing into the gas-phase (lines 1348–1358).


Surface migration
^^^^^^^^^^^^^^^^^

Species migrate across the grain surface via two mechanisms.

Thermal hopping
"""""""""""""""

.. math::
   :label: thermal_hop

   k_{\mathrm{migr}}^{\mathrm{(thermal)}}(T) =
     \frac{\nu_0}{N_{\mathrm{site}}} \exp\!\left(\frac{-E_{\mathrm{diff}}}{k_B T_d}\right),

where :math:`N_{\mathrm{site}}` is the number of surface sites per grain (so that
the rate is in units of site\ :sup:`-1` s\ :sup:`-1`, i.e. hops per site per second).

**Implementation** — ``ode_solver.f90:set_constant_rates``, lines 923–945:

.. code-block:: fortran
   :caption: ode_solver.f90:934 — thermal hopping rate per site

   THERMAL_HOPING_RATE(K) = VIBRATION_FREQUENCY(K) &
                           * EXP(-DIFFUSION_BARRIER(K) / actual_dust_temp(ic_i)) &
                           / nb_sites_per_grain(ic_i)

The diffusion barrier ``DIFFUSION_BARRIER`` is read from ``surface_parameters.in``
or set as a fixed fraction of the binding energy via ``DIFF_BINDING_RATIO_SURF``
(surface) or ``DIFF_BINDING_RATIO_MANT`` (mantle), except for atomic H whose
barrier is read directly.

Quantum tunnelling
""""""""""""""""""

Tunnelling through a rectangular barrier of height :math:`E_{\mathrm{diff}}` and
width :math:`a \approx 1\,\text{Å}`:

.. math::
   :label: tunnel_hop

   k_{\mathrm{migr}}^{\mathrm{(tunnel)}} =
     \frac{\nu_0}{N_{\mathrm{site}}}
     \exp\!\left(\frac{-2a}{\hbar}\sqrt{2\,m\,E_{\mathrm{diff}}}\right).

**Implementation** — ``gasgrain.f90:init_reaction_rates``, lines 931–933
(tunnelling rate precomputed at initialization):

.. code-block:: fortran
   :caption: gasgrain.f90:932 — tunnelling diffusion rate (type 2)

   TUNNELING_RATE_TYPE_2(I) = VIBRATION_FREQUENCY(I) &
     * EXP(-2.0d0 * DIFFUSION_BARRIER_THICKNESS / H_BARRE &
           * SQRT(2.0d0 * AMU * SMA * K_B * DIFFUSION_BARRIER(I)))

where ``DIFFUSION_BARRIER_THICKNESS`` = :math:`a` (barrier width in cm,
read from ``parameters.in``).

**Total migration rate** (in ``set_dependant_rates``, lines 1684–1740):
the code compares :math:`k_{\mathrm{thermal}}` and :math:`k_{\mathrm{tunnel}}`
and takes the **fastest** according to the ``GRAIN_TUNNELING_DIFFUSION`` switch:

.. code-block:: fortran
   :caption: ode_solver.f90:1686 — select fastest migration for JH, JH2

   tunneling_rate = TUNNELING_RATE_TYPE_1(r1) / nb_sites_per_grain(...)
   if (tunneling_rate > DIFFUSION_RATE_1(J)) DIFFUSION_RATE_1(J) = tunneling_rate

Modes:

- ``GRAIN_TUNNELING_DIFFUSION = 0`` — thermal hopping only.
- ``GRAIN_TUNNELING_DIFFUSION = 1`` — faster of thermal or type-1 tunnelling
  (band-gap formula) for H and H\ :sub:`2`.
- ``GRAIN_TUNNELING_DIFFUSION = 2`` — faster of thermal or type-2 tunnelling
  (barrier-width formula, :eq:`tunnel_hop`) for H and H\ :sub:`2`.
- ``GRAIN_TUNNELING_DIFFUSION = 3`` — fastest of all three for H and H\ :sub:`2`.
- ``GRAIN_TUNNELING_DIFFUSION = 4`` — type-2 tunnelling also applied to atomic O.

**✓ Verified:** both :eq:`thermal_hop` and :eq:`tunnel_hop` are implemented.
The total migration rate is effectively
:math:`k_{\mathrm{migr}} = \max(k_{\mathrm{thermal}}, k_{\mathrm{tunnel}})`,
which equals :math:`k_{\mathrm{thermal}} + k_{\mathrm{tunnel}}` when one dominates.

Surface reaction mechanisms
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Langmuir-Hinshelwood (LH)
""""""""""""""""""""""""""

Two adsorbed species :math:`i` and :math:`j` react when at least one diffuses and
they meet on the same site.  Rate constant:

.. math::
   :label: lh_rate

   k_{ij} = \kappa_{ij}
             \left(\frac{1}{t_{\mathrm{hop}}(i)} + \frac{1}{t_{\mathrm{hop}}(j)}\right)
             \frac{1}{N_{\mathrm{site}}\,n_d},

For barrier-less reactions: :math:`\kappa_{ij} = 1`.
For activated reactions (:math:`E_{A,ij} > 0`):

.. math::

   \kappa_{ij} = \frac{\nu_{ij}\,\kappa^*_{ij}}
                      {\nu_{ij}\,\kappa^*_{ij} + k_{\mathrm{hop}}(i)
                       + k_{\mathrm{evap}}(i) + k_{\mathrm{hop}}(j) + k_{\mathrm{evap}}(j)},

with :math:`\kappa^*_{ij} = \exp(-E_{A,ij}/T_d)` (thermal) or
:math:`\kappa^*_{ij} = \exp[-(2/\hbar)\sqrt{2\mu E_{A,ij}}\,a]` (tunnelling through
the reaction barrier, reduced mass :math:`\mu`).

**Implementation** — ``ode_solver.f90:set_dependant_rates``, type 14 (lines 1665–1847):

.. code-block:: fortran
   :caption: ode_solver.f90:1819,1821 — LH reaction rate

   DIFF = DIFFUSION_RATE_1(J) + DIFFUSION_RATE_2(J)   ! sum of hop rates per site
   reaction_rates(J) = RATE_A(J) * branching_ratio(J) &
                      * BARR * DIFF * GTODN(grain_rank) / actual_gas_density

where ``GTODN / actual_gas_density`` = :math:`1/n_d` (since
``GTODN`` = :math:`n_H/n_d`), and ``BARR`` = :math:`\kappa_{ij}`.

The reaction barrier is handled (lines 1744–1763): for activated reactions the
code compares the thermal activation probability ``ACTIV = E_A / Td`` with the
quantum tunnelling probability ``SURF_REACT_PROBA(J)`` (pre-computed in
``gasgrain.f90:1422`` from the reduced mass and barrier width), and uses the
**smaller** exponent (= faster rate):

.. code-block:: fortran
   :caption: ode_solver.f90:1746 — reaction barrier (thermal vs tunnelling)

   ACTIV = ACTIVATION_ENERGY(J) / actual_dust_temp(grain_rank)
   if (ACTIV > SURF_REACT_PROBA(J)) ACTIV = SURF_REACT_PROBA(J)
   BARR = EXP(-ACTIV)

**✓ Verified:** exactly implements :eq:`lh_rate` with barrier correction.

Eley-Rideal (ER)
""""""""""""""""

One reactant is adsorbed; the other arrives from the gas-phase:

.. math::

   k_{ij} = \frac{k_{\mathrm{acc}}(i)}{n_{s,\mathrm{tot}}}.

**Implementation** — type 30, lines 1869–1882:

.. code-block:: fortran
   :caption: ode_solver.f90:1873 — ER rate

   reaction_rates(J) = RATE_A(J) * branching_ratio(J) &
     * ACC_RATES_PREFACTOR(J) * TSQ / GTODN(...) / ab_surf(grain_rank)

where ``ab_surf`` :math:`\approx n_{s,\mathrm{tot}} / n_H`.
The ER mechanism is enabled by setting ``is_er_cir = 1`` in ``parameters.in``.
It operates on **surface** species only (not mantle).

Hot Atom (HA) mechanism
"""""""""""""""""""""""

Newly accreted species that are not immediately thermalized can diffuse
("hot-atom" diffusion) before adsorbing.  In NMGC this is modelled via the
type-31 complex-induced reaction (CIR) channel (lines 957–975):

.. code-block:: fortran
   :caption: ode_solver.f90:968 — hot-atom / CIR rate

   IF (tunneling_rate(J) > THERMAL_HOPING_RATE(r1)) THEN
     reaction_rates(J) = RATE_A(J) * branching_ratio(J) * tunneling_rate(J) * BARR
   ELSE
     reaction_rates(J) = RATE_A(J) * branching_ratio(J) * THERMAL_HOPING_RATE(r1) * BARR
   ENDIF

The CIR channel is controlled by the ``is_er_cir`` flag.


How NMGC treats H\ :sub:`2` formation
---------------------------------------

**Problem:** The classical Langmuir-Hinshelwood H\ :sub:`2` formation mechanism
is efficient only at :math:`T \approx 5\text{–}15\,\mathrm{K}`.  Small grains in
UV-irradiated disk surfaces or PDRs can be significantly warmer, suppressing the
LH mechanism.  A proper treatment must account simultaneously for:

1. Stochastic temperature fluctuations of small grains (transient heating by UV photon absorption).
2. Discrete adsorbed H-atom populations (stochastic regime).

**Adopted prescription:** :cite:t:`Bron et al. (2014)` (B14) analytical fits to master-equation
solutions.  Activated by setting ``is_h2_formation_rate = 1`` in ``parameters.in``.

Equivalent density correction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

B14's rates were derived at :math:`T_g = 100\,\mathrm{K}`.  To correct for
a different gas temperature and density, NMGC computes an **equivalent density**:

.. math::
   :label: neq

   n_{\mathrm{eq}} = n_H \sqrt{\frac{T_g}{100\,\mathrm{K}}}\,
                     \frac{s(T_g)}{s(100\,\mathrm{K})},

where the sticking coefficient follows :cite:t:`LeBourlot2012`:

.. math::
   :label: sticking_h2

   s(T) = \left[1 + \left(\frac{T}{T_2}\right)^{\!\beta}\right]^{-1},
   \quad T_2 = 464\,\mathrm{K},\quad \beta = 1.5.

**Implementation** — ``ode_solver.f90:set_dependant_rates``, type 97,
lines 1479–1511:

.. code-block:: fortran
   :caption: ode_solver.f90:1483–1484 — equivalent density (B14)

   stick_Tgas = 1.d0 / (1.d0 + (gas_temperature(x_i) / T_2)**beta)
   stick_100  = 1.d0 / (1.d0 + (100.d0 / T_2)**beta)
   n_eq = H_number_density(x_i) * SQRT(gas_temperature(x_i)/100.d0) &
         * (stick_Tgas / stick_100)

**✓ Verified:** exactly implements :eq:`neq` and :eq:`sticking_h2`.

.. note::

   **Minor notation discrepancy:** The thesis (G20 Eq. III.stick) writes
   :math:`s(T) = (1 + T^\beta / T_2)^{-1}`, which may be read as
   :math:`T^\beta / T_2` rather than :math:`(T/T_2)^\beta`.  The code correctly
   implements the standard Le Bourlot et al. (2012) formula :math:`(1 + (T/T_2)^\beta)^{-1}`.

Polylogarithmic analytical fits
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Using :math:`n_{\mathrm{eq}}`, the code evaluates the B14 formation rate
:math:`R_f` via a two-step polylogarithmic fit:

.. code-block:: fortran
   :caption: ode_solver.f90:1487–1505 — polylogarithmic B14 fit

   rate_max = -1.87663716d-1 + 8.65799199d-1*log10(n_eq)**1 &
              + 2.70415877d-1*log10(n_eq)**2 - ...   ! fit at min G

   Q = rate_max + (-0.24083058/n_eq**0.09)*log10(G)**1 &
                + (-0.5315985/n_eq**0.085)*log10(G)**2 &
                + (0.02165607/n_eq**0.5)*log10(G)**3

   reaction_rates(J) = RATE_A(J) * 10**Q

where ``G`` is the local UV flux (from ``INT_LOCAL_FLUX`` if ``photo_disk = 1``,
or from :math:`\exp(-\beta A_v) \times G_0` otherwise).

**Physical interpretation:**

- At low density the rate decreases roughly as :math:`1/G` (grains spend more
  time cold, LH mechanism kicks in transiently).
- At high density the rate saturates because UV flux is insufficient to maintain
  a large atomic H reservoir.

**Spatial threshold:** the B14 prescription is applied only up to a height
``height_h2formation`` (line 1480); above this height ``reaction_rates = 0``,
falling back to no H\ :sub:`2` formation (or the standard LH channel if it is active).

The Eley-Rideal (chemisorption-based) H\ :sub:`2` formation channel is included
automatically through the type-30 ER reactions for adsorbed H atoms.



