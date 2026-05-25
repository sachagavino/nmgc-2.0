# NMGC Version 2.0

## Introduction
The Nautilus Multi-Grain Code (NMGC) is a gas-grain code derived from the NAUTILUS code that is able to deal with multiple grain species for astrophysical environments. It is written in Fortran 90.

## User's guide
You can find how to download and use NMGC [here][1].

## Branches
main: stable up-to-date version.

dev: use it at your own risks.

## News

[25.05.2026]: **Bug fix (commit -m cr_hopping and accr rate)** ACCRETION_RATES(species) is a per-species scalar that is overwritten for each grain bin in the ITYPE=99 accretion loop. When modify_specific_rates (activated by MODIFY_RATE_FLAG != 0) reads it to compute the rate-limiting comparison for surface reactions, it sees the value from the last grain bin that accreted a given species, not necessarily the bin where the surface reaction happens.
Impact: The modified-rate correction for H and H2 on grain surfaces uses wrong accretion rates when MODIFY_RATE_FLAG != 0 and nb_grains > 1.
Fix: Make ACCRETION_RATES a per-reaction (or per-species-per-bin) array, or compute it locally in modify_specific_rates using ACC_RATES_PREFACTOR(J).


[25.05.2026]: **Bug fix (commit -m cr_hopping and accr rate)** When is_crid != 0, the code computes a CR hopping rate per surface species to drive cosmic-ray-induced diffusion. It needs the Fe-ion rate scaled by the grain bin's cross-section. But FE_IONISATION_RATE_r_dpnt is a scalar set inside the ITYPE=16 desorption loop, and when the species loop runs it retains the value from the last ITYPE=16 reaction processed — which may belong to a different grain bin than the species currently being processed.
Impact: Wrong CR hopping rates for species on all bins except whichever one happened to be last in the ITYPE=16 loop. Only triggered when both is_crid != 0 and nb_grains > 1.
Fix: Compute FE_IONISATION_RATE * grain_radii(ic_i)² / grain_radius² locally inside the species loop using ic_i (the bin index of the species).

[14.04.2026]: **major change** The code now generates a single output file abundances.out, instead of one per timestep. The abundances per timestep are inside the single file. If the run fails between two timesteps, then only the complete sets of abundances are stored in the file so it is readable in any case. This change is
meant to facilitate dada handling (sometimes the user may need to work with hundreds of models). Also, it is also recommanded not to work with the ascii files and work with the binary file instead. A Python package (astroMUGS) was specifically built to easily read, write, and plot this output file. 


[22.03.2026]: **fix** In ``ode_solver.f90``, changed `IWORK(6) = 2000` to `IWORK(6) = 10000` to increase the first-step MXSTEP, because in 
disk models it is common to hit the cap on the first step on certain spatial points.

[17.03.2026]: **Bug fix** In `main.f90`, The `do i=1,nb_species` loop at line 702 ends at line 704. After the loop, `i equals nb_species + 1`. Then line 707 uses i (which is now nb_species + 1 = 4579) to index `temp_abundances`. The check at line 707 was meant to be inside the loop. The NaN guard was added but put after the enddo instead of inside the loop. After a `do i=1,nb_species` loop, `i is nb_species + 1` — so it was checking (and clamping) one element past the array. The fix moves it inside the loop where it belongs, so every species gets the NaN protection.

[14.01.2026]: **Bug fix**  Added 11 missing species index lookups (INDCO2, INDN2O, INDCH4, INDOH, INDHCO, INDCN, INDHCN, INDHNC, INDNH, INDNH2, INDNH3) in the index_datas() subroutine in `gasgrain.f90:614-624`. The root cause: the `Y*` name constants and IND* index variables were declared in `global_variables.f90` (lines 99-110 and 125-135), and the column density code in `main.f90` (lines 353-395) used them, but the actual species lookup in index_datas() only initialized 13 of the 24 species indices. The missing 11 defaulted to 0, causing `abundances(0, x_i)` — an out-of-bounds access.

[02.10.2025]: **Bug fix**  In ode_solver.f90, `GRAIN_RANK` was initialized to 0 for all reactions, only set for grain-related reactions (those involving J/K/GRAIN species). But the loop at line 1122 iterates over ALL reactions, so gas-phase reactions access grain_radii(0) — out of bounds. This was always a bug, but without -fbounds-check it silently read garbage memory. The fix is `GRAIN_RANK(J) > 0` guard at line 1122. Another bug found in `set_work_arrays(Y)`, which is called from integrate_chemical_scheme during the spatial loop. The fix is `x_i = 1` initialization in count_nonzeros at line 156 in ode_solver.f90. 

[10.08.2024]: 0D models now works in multi-grain mode. 1D models can now be something else than a disk. Parameters.in file is simplified. UV field is added in static. parameters.in file is changed accordingly. Please upgrade to version of date 10.08.2024 or later of the stable branch.


[1]: https://nmgc-20.readthedocs.io/en/latest
     