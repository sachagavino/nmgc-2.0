SRC = .
#SRC = /Users/sachagavino/science/programs/NMGC/version_1.0/src

# Optimize
OPTIM = -O2 -fopenmp
# OPTIM = -O2 

# The system defines used in executing make
# FF = /Users/sachagavino/?

# For using the OpenMP parallel version of NMGC one has to add '-fopenmp' in
# the next command line (see also the NMGC manual).
FF = gfortran

# Glueing all the things together
FFLAGS   = $(OPTIM) $(BCHECK)
#FFLAGS   = $(OPTIM)
#-Wall
LFLAGS   = $(OPTIM) 
#-Wall


#
# Names
#
SRCMAIN        = $(SRC)/main.f90
SRCGASGRAIN    = $(SRC)/gasgrain.f90
SRCDUSTEMP     = $(SRC)/dust_temperature_module.f90
SRCGIT         = $(SRC)/git_infos.f90
SRCGLOBAL      = $(SRC)/global_variables.f90
SRCINPUTOUTPUT = $(SRC)/input_output.f90
SRCISO         = $(SRC)/iso_fortran_env.f90
SRCMAJOR       = $(SRC)/major_reactions.f90
SRCOUTPUT      = $(SRC)/outputs.f90
SRCRATES       = $(SRC)/rates.f90
SRCSELECT      = $(SRC)/select_outputs.f90
SRCTRACEM      = $(SRC)/trace_major.f90
SRCNUMTYPE     = $(SRC)/numerical_types.f90
SRCSOLVER      = $(SRC)/ode_solver.f90
SRCOPKDA1      = $(SRC)/opkda1.f90
SRCOPKDA2      = $(SRC)/opkda2.f90
SRCOPKDAMAIN   = $(SRC)/opkdamain.f90
SRCRATEDISK    = $(SRC)/photorates_disks.f90
SRCSHIELD      = $(SRC)/shielding.f90
SRCSTRUCT      = $(SRC)/structure.f90
SRCTEST        = $(SRC)/unitary_tests.f90
SRCUTIL        = $(SRC)/utilities.f90
#SRCUSERDEF     = ./nmgc_profile

OBJ            	= main.o gasgrain.o dust_temperature_module.f90 git_infos.o \
                 global_variables.o input_output.o iso_fortran_env.o \
				 major_reactions.o outputs.o rates.o \
				 select_outputs.o trace_major.o numerical_types.o \
				 ode_solver.o opkda1.o opkda2.o opkdamain.o photorates_disks.o \
				 shielding.o structure.o unitary_tests.o utilities.o

AMODULES		= numerical_types.o iso_fortran_env.o utilities.o
BMODULES		= $(AMODULES) shielding.o
MODULES 	  	= $(BMODULES) global_variables.o iso_fortran_env.o shielding.o utilities.o \
			  	dust_temperature_module.o gasgrain.o photorates.o



#################################################
#                   RULES                       #
#################################################

all:	            nmgc

nmgc:               $(OBJ) Makefile
	                $(FF) $(LFLAGS) $(OBJ) $(LIBS) -o $@ 

main.o:        		$(SRCMAIN) $(MODULES) Makefile
					$(FF) -c $(FFLAGS)  $(SRCMAIN) -o $@

numerical_types.o: 	$(SRCNUMTYPE) Makefile
	                $(FF) -c $(FFLAGS)  $(SRCNUMTYPE) -o $@

iso_fortran_env.o: 	$(SRCISO) Makefile
	                $(FF) -c $(FFLAGS)  $(SRCISO) -o $@

utilities.o:   		$(SRCUTIL) Makefile
	                $(FF) -c $(FFLAGS)  $(SRCUTIL) -o $@

global_variables.o: $(SRCGLOBAL)  Makefile
	                $(FF) -c $(FFLAGS)  $(SRCGLOBAL) -o $@

shielding.o: $(SRCSHIELD)  Makefile
	                $(FF) -c $(FFLAGS)  $(SRCSHIELD) -o $@






install:	    nmgc
	            ./install.perl

# clean:
# 	@rm -f	*.o *.mod
# 	@echo OBJECT and MODULE files removed.