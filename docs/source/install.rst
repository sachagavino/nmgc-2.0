Installation of NMGC
************

How to obtain NMGC
=================

NMGC can be obtained by cloning its repository. This is also the best way to keep up-to-date.
From a terminal, go to a directory where you want to install the code, and type:: 


    git clone https://github.com/sachagavino/nmgc-2.0.git


This will create a folder ``nmgc-2.0/``, which contains the full git repository. You can now access the package::


    cd nmgc-2.0/


To make sure you use the latest version, you can type:: 


    git pull



Requirements
=================

The following softwares are required:

#. ``make``

    The GNU Make tool is required to compile the software. In principle, it should already be pre-installed on your machine.
    In case it is not, you can type ``sudo apt-get install make`` if you are working on Linux, or ``brew install make`` regardless of your OS.

#. ``perl``

    Perl is a Unix-friendly scripting language that unable text processing tasks. It is required to copy the executable in the $HOME/bin directory.
    Note that this requirements will be removed in the next update of NMGC.

#. ``Fortran-90 compiler``

    The software has been tested with the ``gfortran`` compiler only, but there is no reason it should not be working with the others. 


Compiling the code
=================

To compile the code, enter the ``src/`` folder. 
First, if you want to compile with something else than ``gfortran``, you will have to edit the ``Makefile`` and change this line::

    FF = gfortran

so you can switch to whatever Fortran-90 compiler you want to use.

Now, still in the ``src/`` folder, you want to compile the software by typing:: 

    make install

You should see the executable called ``nmgc`` appear in ``src/``. 

Additionnally, the perl script will check if the ``$HOME/bin`` directory exists on your machine. If not, it will ask you to create one (you should say yes). 
Then, it will add a link ``nmgc`` in ``$HOME/bin``. This will allow you to execute the software everywhere you want to. For this to be possible, the 
``$HOME/bin`` directory must be in the path of your current shell. The script should warn you during the installation if it is not the case.
If ``make install`` tells you that the ``bin/`` directory is not in your path, you can do it yourself by adding the following line in your ``$HOME/.zshrc``::

    export PATH=/<YOUR HOME>/bin:$PATH

Note that ``<YOUR HOME>`` is what you obtain when you type ``echo $HOME`` in your shell. Depending on your OS or needs, you might want to use another configuration
file, ``.bashrc`` for instance, instead of the suggested ``.zshrc``.

Don't forget to type ``source $HOME/.zshrc`` and ``rehash`` after that, so the new path is recognized by your shell (or alternatively opening a new terminal will do it).

You can now execute the code anywhere. If you want to know the installation went well, open a terminal (or use the same one as you have used so far), go to any folder, 
and type ``nmgc``. If the terminal shows the following text::

    ================================================================
          WELCOME TO NMGC: THE MULTI-GRAIN VERSION OF NAUTILUS

                To keep up-to-date follow NMGC on github

                https://github.com/sachagavino/nmgc-2.0

                Please, read the NMGC documentation at
                https://nmgc-20.readthedocs.io/en/latest/
    ================================================================

    Please, use one of these options:
    run        : Integrate the evolution of the chemical scheme
    outputs    : Read binary outputs to convert into ASCII format
    rates      : Create flux and rate coefficients at each time
    major      : Find the major reactions for each time and species

 
Then the installation went well and you can start using the software.


