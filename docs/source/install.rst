Installation of NMGC
************

How to obtain NMGC
=================

NMGC can be obtained by cloning its repository. This is also the best way to keep up-to-date.
From a terminal, go to a directory where you want to install the code, and type:: 


    git clone https://github.com/sachagavino/nmgc-2.0.git


This will create a folder ``nmgc-2.0/``, which contains the full git repository. You can now access the package::


    cd nmgc-2.0/


To make sure you always use the latest version, you can type:: 


    git pull



Requirements
=================

The following softwares are required:

#. ``make``

    The GNU Make tool is required to compile the software. In principle, it should already be pre-installed on your machine.
    In case it is not, you can type ``sudo apt-get install make`` if you are working on Linux, or ``brew install make`` regardless of your OS.


#. ``Fortran-90 compiler``

    You need a Fortran-90 compiler. The default installation compiler is ``gfortran``. Please, make sure you have the latest version
    of your compiler (gfortran version > 10.3.0). 


Compiling the code
=================

To compile the code, enter the ``src/`` folder. You can compile the software by typing:: 

    make install

If you want to compile with something else than ``gfortran``, for example ``ifx``, you can type::

    make FC=ifx install

A recommandation to make debugging easy (in particular segmentation faults, which are common with gas-grain codes), is to compile with bounds checking and backtrace.
Instead of simply ``make install``, write this in the command line::

    make BCHECK="-fbounds-check -g -fbacktrace" 2>&1 | tail -5
    make install

Instead of bare segfault, the compiler will tell exactly which array, index, or source line raises the fault.


You should now see the executable called ``nmgc`` appear in ``src/``. 

Don't forget to type ``source $HOME/.zshrc`` and ``rehash`` after that, so the new path is recognized by your shell (or alternatively opening a new terminal will do it).

Depending on your OS or needs, you might want to use another configuration
file, ``.bashrc`` for instance, instead of the suggested ``.zshrc``.

You can now execute the code from any directories. To know if the installation went well, open a terminal (or use the same one as you have used so far), go to any directories, 
and type ``nmgc``. If the terminal shows the following text::

    ================================================================
          WELCOME TO NMGC: THE MULTI-GRAIN VERSION OF NAUTILUS

                To keep up-to-date follow NMGC on github

                https://github.com/sachagavino/nmgc-2.0

                Please, read the NMGC documentation at
                https://nmgc-20.readthedocs.io/en/latest/
    ================================================================

    Please, use one of these actions:
    run        : Integrate the evolution of the chemical scheme
    outputs    : Read binary outputs to convert into ASCII format
    rates      : Create flux and rate coefficients at each time
    major      : Find the major reactions for each time and species

 
Then the installation went well and you can start using the software.


