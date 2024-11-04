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

.. _sec-elm-input:
INPUT: element.in (required)
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

.. _sec-param-input:
INPUT: parameters.in (required)
==================

The file ``parameters.in`` is the main parameter file for your chemistry model. It is composed of switches, gas-phase, and gain parameters. This is also where you define the integration time, the number of time outputs,
the modes (number of grains and dimension), the chemical model (2 vs. 3-phase model). Here is below the exhaustive list of all parameters that can be set by order of appearance in the file. Every line starting with ``!`` are commented and not taken into account.

* ``is_3_phase``:

    This switch sets the chemistry model. If set to ``1``, then the simulation will use the three-phase model (as described in Ruaud et al. (2016)). The three-phase model allow for the gas, the grain surface, and the grain mantle
    to be chemically active. Chemical species can 'swap' from the mantle to the surface, and vice versa. The chemical species in the mantle cannot react with the gas-phase directly. If it is set to ``0``, then the simulation
    considers the two-phase model, where only the gas-phase and grain surface are chemically active.

* ``preliminary test``: 

* ``is_structure_evolution``:

* ``grain_temperature_type``: 

* ``photo_disk``:

* ``is_grain_reactions``:  

* ``is_h2_adhoc_form``:  

* ``is_h2_formation_rate``:  

* ``height_h2formation``:  

* ``is_absorption_h2``: 

* ``is_absorption_co``:  

* ``is_absorption_n2``:  

* ``is_photodesorb``:  

* ``is_crid``:  

* ``is_er_cir``:  

* ``grain_tunneling_diffusion``:  

* ``modify_rate_flag``:  

* ``conservation_type``:  

* ``nb_active_lay``: 


-------------------------------------

* ``structure_type``: 

* ``spatial_resolution``: 

* ``multi_grain``: 

-------------------------------------

* ``initial_gas_density``: 

* ``initial_gas_temperature``: 

* ``initial_visual_extinction``: 

* ``cr_ionisation_rate``: 

* ``x_ionisation_rate``: 

* ``initial_dust_temperature``:

* ``initial_dtg_mass_ratio``:

* ``sticking_coeff_neutral``:

* ``sticking_coeff_positive``:

* ``sticking_coeff_negative``:

* ``grain_density``:

* ``grain_radius``:

* ``diffusion_barrier_thickness``:

* ``surface_site_density``:

* ``diff_binding_ratio_surf``:

* ``diff_binding_ratio_mant``:

* ``chemical_barrier_thickness``:

* ``cr_peak_grain_temp``:

* ``cr_peak_duration``:

* ``Fe_ionisation_rate``:

* ``vib_to_dissip_freq_ratio``:

* ``ED_H2``:

-------------------------------------

* ``start_time``:

* ``stop_time``:

* ``nb_outputs``:

* ``output_type``:

* ``relative_tolerance``:

* ``minimum_initial_abundance``:





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
INPUT: 1D_static.in  (optional)
==================

.. _sec-evolv-input:
INPUT: structure_evolution.dat  (optional)
==================



-------------------------------------

.. _sec-ab-output:
OUTPUT: abundances.00000i.out
==================

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

