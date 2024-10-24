How to use the code
************


Quickstart
=================

We saw that typing ``nmgc`` in the shell displays the software banner, with a bunch of suggested actions. **These actions are the core of Nautilus and you will need them to use the software.** 
A detailed description of these options is provided below.


The first thing you want to do is to go to the working directory in which you stored your NMGC input files.
If you don't know what these inputs are, they are described in details in Section :ref:`chap-input-files`. 
You might want to read that section from now on if you don't know what input files to use for your simulations.

Once in your working directory, you want to type ``nmgc``, followed by one of these four actions:

* run
* outputs
* rates
* major_reactions

For instance, if you type::

    nmgc run

This will execute the main chemical scheme using the input files located in the current directory.

The four actions
=================

run
---------------------
This action launches the main chemical scheme. The code reads the input files you provided (chemical network, physical model, initial abundances, etc.), and proceeds to
compute the chemical evolution. At the end of the simulation, binary files are generated, in particular the files abundances.00000i.out and rates.00000i.out, with ``i`` corresponding to
the time output, meaning that there should be as many of these files as the number of outputs defined in ``parameters.in``. These files store the results of your simulation i.e. the chemical abundances as a function of the integration time for each species and each spatial location.

outputs
---------------------
These output files described above are not readable by default. There comes the action ``outputs``. The purpose of this action is to convert these binary files into easy-to-read files in ASCII format.
It means that you want to run the action ``outputs`` right after the action ``run`` ended (assuming the simulations went well). 
The ``outputs`` action mainly generates three new folders called ``ab/``, ``ml/``, and ``struct/``.  

rates
---------------------
This action generates two files: 

* ``rates.out``: contains the flux of all reactions of the network at each time. More precisely, the flux corresponds to the rate coefficients multipled by the densities of the reactants.

* ``rate_coefficients``: contains the rate coefficients at each time.


major_reactions
---------------------
If you are interested in figuring out what were the major reactions that destroyed/produced a given chemical species at a given time in your simulations, an easy way to do that is the action ``major_reactions``.  
If you run ``major_reactions``, the software will run a script that will ask you to provide information about the species you are interested in, the time output, and the spatial location in your model. It will then provide all major reactions that destroyed or produced this species.


The four modes
=================
NMGC can be run by using different modes: **two dimensional modes, and two grain size modes.** These modes are set in ``parameters.in`` (see Section :ref:`chap-input-files`).

Dimensions
---------------------
NMGC uses two dimensional modes, called ``0D`` and ``1D``. In the ``0D`` mode, the physical model is only composed of one cell, with a single density, temperature, UV flux value, etc. This is a well-suited mode for homogeneous physical environements.
The ``1D`` mode allows the user to build a more complex physical structure, composed of multiple cells, each of which with a given physical condition. This is usually the preferred mode for non-homogeneous models such as protoplanetary disks. In general. the users divide their model into a set of multiple ``1D`` simulations (usually referred to as 1D+1 simulations).
The dimensional mode can be set using the parameter ``structure_type`` in ``parameters.in``. Note that the ``1D`` mode is divided into two modes called ``1D_no_diff`` and ``1D_diff``, which depends on whether or not diffusion exists between the neighboring cells. 

Grain sizes
---------------------
NMGC also comes with two grain size modes, called multi-grain and single-grain. In the single-grain mode, NMGC works exactly like the main version of Nautilus (apart from a bunch of differences that are described in :ref:`chap-input-files`). 
The multi-grain mode, on the other hand, is the main specificity of NMGC. If the user uses this mode, then NMGC considers a set of discretized grain populations, each with their own size, density and surface temperature.
The grain size mode can be set in ``parameters.in``, using the flag ``multi-grain``. If ``multi-grain`` is set to ``0``, then the code works in single-grain mode. If ``multi-grain`` is set to ``1``, then the code works in multi-grain mode. 

Of course, **the grain size modes and dimensional modes can be used together** (the two grain size modes can be run either in ``0D`` or ``1D``), making a total of four possible modes. 
Typically, when the simulation is set to ``multi-grain`` mode, the grain parameters (sizes, densities, temperatures), are read either in the input file called ``0D_grain_sizes.in`` in ``0D`` mode, or in the input file called ``1D_grain_sizes.in`` in ``1D`` mode.