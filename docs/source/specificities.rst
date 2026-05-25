.. _chap-specificities:

The specificities of the multi-grain mode
************

NMGC versus the main version of Nautilus
=================

In the standard version of Nautilus, the entire dust population is represented by a single grain of fixed radius, abundance, and temperature. Every surface and mantle species "lives" on this unique grain, and every grain-related rate (accretion, desorption, diffusion) is computed once with these single values. NMGC generalises this to an arbitrary number of grain size bins, each treated as a physically and chemically independent population. The sections below describe, for each rate or quantity that is affected, exactly how the single-grain picture is extended in the multi-grain mode.

Grain populations and abundances
---------------------------------

In NMGC, the grain size distribution is discretised into :math:`N` bins. Each bin :math:`i` is characterised by its own grain radius :math:`a_i` and its own gas-to-dust number ratio :math:`\delta_i = n_\mathrm{H}/n_{\mathrm{grain},i}`. The fractional abundance of grain bin :math:`i` relative to hydrogen is therefore :math:`1/\delta_i`. The :math:`\delta_i` values, together with the :math:`a_i`, are supplied by the user through the dedicated input files (``0D_grain_sizes.in`` or ``1D_grain_sizes.in``, see :ref:`sec-inputs`); they need not follow any particular size distribution law and can be set freely for each bin.

Because each bin has its own abundance, the total dust-to-gas mass ratio is the sum of contributions from all bins. In the standard Nautilus code, a single global grain-to-gas ratio serves all grain-related rates; in NMGC, every grain-dependent calculation uses the parameters of the specific bin the reaction belongs to.

Chemical species labeling
--------------------------

In standard Nautilus, grain surface species carry the prefix ``J`` (e.g. ``JH``, ``JCO``) and grain mantle species carry the prefix ``K`` (e.g. ``KH``, ``KCO``). In NMGC, a two-digit bin index is inserted immediately after the prefix to distinguish species on different grain populations: ``J01H``, ``J02H``, ..., ``J99H`` for the surface, and ``K01H``, ``K02H``, ..., ``K99H`` for the mantle. Each bin therefore carries a complete, independent copy of the grain-surface and grain-mantle chemical network.

As a consequence, NMGC network files list every surface and mantle reaction once per grain bin. The total number of grain-phase reactions scales linearly with :math:`N`. The reaction-rate engine identifies which bin a given reaction belongs to from the bin index embedded in the species names, and automatically selects the appropriate temperature, grain radius, and site density for that bin.

Grain temperatures
-------------------

In standard Nautilus, a single dust temperature :math:`T_\mathrm{d}` is used uniformly for all grain-phase processes. In NMGC, each bin :math:`i` carries its own temperature :math:`T_{\mathrm{d},i}`, supplied by the user. This is the central motivation for the multi-grain framework: grains of different sizes respond differently to the local radiation and cosmic-ray field, and the chemical consequences (desorption, diffusion, reactivity) must be evaluated independently for each population.

Cosmic-ray peak temperatures are similarly treated per bin. When a cosmic-ray Fe-ion strikes a grain, it deposits a fixed energy. The resulting temperature spike :math:`T_{\mathrm{CR},i}` depends on the grain's heat capacity, which scales with its volume (and therefore with :math:`a_i^3`). Smaller grains reach higher peak temperatures after a CR impact. NMGC stores a separate value of :math:`T_{\mathrm{CR},i}` for each bin; in standard Nautilus a single :math:`T_\mathrm{CR}` is used.

Accretion of gas-phase species
--------------------------------

The rate at which a gas-phase species accretes onto a grain bin scales with the geometric cross-section :math:`\pi a_i^2` of that bin, with the thermal velocity of the gas species, and with the sticking coefficient. In standard Nautilus these quantities are combined into a single prefactor per species. In NMGC, the prefactor is computed separately for each accretion reaction, i.e. for each combination of gas species and grain bin, because the cross-section :math:`\pi a_i^2` differs between bins. The resulting accretion rate onto bin :math:`i` is also divided by :math:`\delta_i` to obtain the per-hydrogen-atom rate. In this way, large grains (large :math:`a_i`, but fewer grains so large :math:`\delta_i`) and small grains (small :math:`a_i`, more grains so small :math:`\delta_i`) can contribute comparably or differently to the total accretion flux, depending on the assumed size distribution.

Thermal desorption
-------------------

The thermal desorption rate of a surface species is an exponential function of the ratio of its binding energy to the dust temperature: :math:`\nu \exp(-E_\mathrm{b}/T_{\mathrm{d},i})`. In standard Nautilus the single :math:`T_\mathrm{d}` applies to all species; in NMGC the temperature in the exponential is the temperature :math:`T_{\mathrm{d},i}` of the bin to which the species belongs. Because the exponential is strongly sensitive to temperature, even a modest temperature difference between two bins can lead to orders-of-magnitude differences in desorption rate. A species that is frozen out on a cold large grain may be entirely absent from the surface of a warmer small grain.

Cosmic-ray-induced desorption
-------------------------------

The CR-induced desorption rate has two grain-size dependencies in NMGC, both absent from standard Nautilus.

First, the rate of Fe-ion impacts per grain scales with the geometric cross-section :math:`\pi a_i^2`. Larger grains intercept more CR ions and therefore experience more heating events per unit time; however, because they also contain more molecules per desorption event, the net effect on the desorption rate per surface molecule depends on the interplay between cross-section and the per-event yield. In NMGC this is accounted for by scaling the Fe-ion encounter rate proportionally to :math:`a_i^2/a_0^2`, where :math:`a_0` is a reference grain radius.

Second, as noted above, the post-impact peak temperature :math:`T_{\mathrm{CR},i}` is bin-dependent. The desorption yield per CR event, which is an exponential in :math:`-E_\mathrm{b}/T_{\mathrm{CR},i}`, can differ strongly between bins.

Finally, NMGC implements a grain-size cutoff: grains larger than approximately :math:`1\,\mu\mathrm{m}` are treated as having negligible CR-induced desorption, because they are too large to heat up significantly under a single Fe-ion impact.

Surface diffusion and Langmuir-Hinshelwood reactions
------------------------------------------------------

The Langmuir-Hinshelwood (LH) surface reaction rate depends on how rapidly the two reactants diffuse across the grain surface to find each other. The diffusion rate of a species is inversely proportional to the number of binding sites on the grain, :math:`N_\mathrm{sites} = 4\pi a_i^2 n_\mathrm{s}`, where :math:`n_\mathrm{s}` is the surface site density. A large grain has many more sites than a small grain, and a species therefore takes longer to scan the full surface. Equivalently, the hopping rate per site (and therefore the encounter probability per unit time) is higher on a small grain.

In NMGC, the number of sites is computed per bin as :math:`4\pi a_i^2 n_\mathrm{s}` and used consistently in every thermal hopping rate and LH reaction rate for species belonging to that bin. In standard Nautilus, a single site count is used for all species.

The thermal hopping rate also depends on the dust temperature through an Arrhenius factor :math:`\exp(-E_\mathrm{diff}/T_{\mathrm{d},i})`, which is again evaluated at the per-bin temperature in NMGC.

Cosmic-ray-induced diffusion (CRID)
-------------------------------------

If cosmic-ray-induced diffusion (CRID) is activated, surface species gain an additional diffusion contribution driven by CR-heating events. In standard Nautilus, a single CR hopping rate applies to all surface species. In NMGC, the CR hopping rate is computed per bin, using the bin's CR peak temperature :math:`T_{\mathrm{CR},i}`, its number of surface sites, and the grain-size-dependent Fe-ion encounter rate (:math:`\propto a_i^2`). Small grains, which heat more strongly per CR event and have fewer sites to scan, therefore exhibit significantly enhanced CRID relative to large grains.

Outputs
--------

Because each grain bin carries an independent set of surface and mantle species, the output abundance files in NMGC list each species separately for every bin (e.g. ``J01CO``, ``J02CO``, ... for CO on bins 1, 2, ...). The total surface abundance of a species across all bins, if needed, must be summed in post-processing. This grain-resolved output makes it possible to reconstruct the full size-dependent chemical composition of the dust population.

What dust temperature to use
=================

The main purpose of a multi-grain gas–grain code is to construct sophisticated dust temperature distributions. It is therefore natural to leave this aspect flexible for the user. 
You may define even highly complex temperature profiles, provided that they remain within the Nautilus safe zone (See Chapter :ref:`chap-bestpractices` for discussion on the safe zone). 
