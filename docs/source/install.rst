Installation of NMGC
************

How to obtain NMGC
=================

NMGC can be obtained by cloning its repository. This is also the best way to keep up-to-date.
From a terminal, go to a directory where you want to install the code, and type:: 


    git clone https://github.com/sachagavino/nmgc-2.0.git


This will create a folder ``nmgc-2.0/`` in your current repository, which you can access::


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

Switch to whatever Fortran-90 compiler you want to use.

Now, still in the ``src/`` folder, you want to compile the software by typing:: 

    make install

You should see the executable called ``nmgc`` appear in ``src/``. Additionnally, the perl script will check if a ``$HOME/bin`` exists on your machine.
If not, it will ask you to create one (you should say yes). Then it will add a link ``nmgc`` in it so you can execute the software in all working directory.


