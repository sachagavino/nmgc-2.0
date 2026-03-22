# NMGC Version 2.0

## Introduction
The Nautilus Multi-Grain Code (NMGC) is a gas-grain code derived from the NAUTILUS code that is able to deal with multiple grain species for astrophysical environments. It is written in Fortran 90.

## User's guide
You can find how to download and use NMGC [here][1].

## Branches
main: stable up-to-date version.

dev: use it at your own risks.

## News
[22.03.2026]: **fix** In ``ode_solver.f90``, changed `IWORK(6) = 2000` to `IWORK(6) = 10000` to increase the first-step MXSTEP, because in 
disk models it is common to hit the cap on the first step on certain spatial points.

[17.03.2026]: **Bug fix** In `main.f90`, The `do i=1,nb_species` loop at line 702 ends at line 704. After the loop, `i equals nb_species + 1`. Then line 707 uses i (which is now nb_species + 1 = 4579) to index `temp_abundances`. The check at line 707 was meant to be inside the loop. The NaN guard was added but put after the enddo instead of inside the loop. After a `do i=1,nb_species` loop, `i is nb_species + 1` — so it was checking (and clamping) one element past the array. The fix moves it inside the loop where it belongs, so every species gets the NaN protection.

[14.01.2026]: **Bug fix**  Added 11 missing species index lookups (INDCO2, INDN2O, INDCH4, INDOH, INDHCO, INDCN, INDHCN, INDHNC, INDNH, INDNH2, INDNH3) in the index_datas() subroutine in `gasgrain.f90:614-624`. The root cause: the `Y*` name constants and IND* index variables were declared in `global_variables.f90` (lines 99-110 and 125-135), and the column density code in `main.f90` (lines 353-395) used them, but the actual species lookup in index_datas() only initialized 13 of the 24 species indices. The missing 11 defaulted to 0, causing `abundances(0, x_i)` — an out-of-bounds access.

[02.10.2025]: **Bug fix**  In ode_solver.f90, `GRAIN_RANK` was initialized to 0 for all reactions, only set for grain-related reactions (those involving J/K/GRAIN species). But the loop at line 1122 iterates over ALL reactions, so gas-phase reactions access grain_radii(0) — out of bounds. This was always a bug, but without -fbounds-check it silently read garbage memory. The fix is `GRAIN_RANK(J) > 0` guard at line 1122. Another bug found in `set_work_arrays(Y)`, which is called from integrate_chemical_scheme during the spatial loop. The fix is `x_i = 1` initialization in count_nonzeros at line 156 in ode_solver.f90. 

[10.08.2024]: 0D models now works in multi-grain mode. 1D models can now be something else than a disk. Parameters.in file is simplified. UV field is added in static. parameters.in file is changed accordingly. Please upgrade to version of date 10.08.2024 or later of the stable branch.


[1]: https://nmgc-20.readthedocs.io/en/latest
     