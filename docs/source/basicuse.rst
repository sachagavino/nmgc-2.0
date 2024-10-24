How to use the code
************


Quickstart
=================

We saw that typing ``nmgc`` in the shell displays the software banner, with a bunch of suggested actions. These actions are the core of Nautilus and you will need them to use the software. 
A detailed description of these options is provided below.


The first thing you want to do is to go to the working directory in which you stored your NMGC input files.
If you don't know what these input are, they are described in details in Section :ref:`chap-input-files`. 
You might want to read that section from now on if you don't know what input files to use for your simulations.

Once in your working directory, you want to type ``nmgc``, followed by one of these four actions:

* run
* outputs
* rates
* major_reactions

For instance, if you type::

    nmgc run

This will execute the main chemical scheme using your input files.

The four actions
=================

run
---------------------
This action launches the main chemical scheme. The code reads the input files you provided (chemical network, physical model, initial abundances, etc.), and proceeds to
compute the chemical evolution. At the end of the simulation, binary files are generated, in particualar the files abundances.00000i.out and rates.00000i.out, with ``i`` corresponding to
the time output. These files stores the outcome of your simulation i.e. the chemical abundances as a function of the integration time for each species and each spatial location.

outputs
---------------------
These output files mentioned above are not readable by default. The purpose of the action ``outputs`` is to convert the binary files into ASCII, easy to read, output files.
It means that you want to run the action ``outputs`` right after the ``run`` action ended (assuming the simulations went well). 
The ``outputs`` action mainly generates three new folders called ``ab/``, ``ml/``, and ``struct/``  

rates
---------------------
This action generates two files. 

* ``rates.out``: This 

* ``rate_coefficients``:


major_reactions
---------------------


The four modes
=================