SRC = .
#SRC = /Users/sachagavino/science/programs/NMGC/version_2.0/src

FF = gfortran

FFLAGS   = $(BCHECK)

MISMATCH = -fallow-argument-mismatch # In order to have type mismatches errors coming \
from the old ODEPACK Fortran 77 sources still be compiled.
#-Wall


#
# Names
#
SRCMAIN        = $(SRC)/main.f90
SRCGASGRAIN    = $(SRC)/gasgrain.f90
SRCDUSTEMP     = $(SRC)/dust_temperature_module.f90
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
SRCOPKDMAIN    = $(SRC)/opkdmain.f90
SRCPRATES      = $(SRC)/photorates.f90
SRCSHIELD      = $(SRC)/shielding.f90
SRCSTRUCT      = $(SRC)/structure.f90
SRCUTIL        = $(SRC)/utilities.f90

OBJ            	= main.o gasgrain.o dust_temperature_module.o \
                global_variables.o input_output.o iso_fortran_env.o \
				numerical_types.o outputs.o rates.o major_reactions.o \
				ode_solver.o opkda1.o opkda2.o opkdmain.o photorates.o \
				shielding.o structure.o utilities.o

#OBJ            	= main.o gasgrain.o dust_temperature_module.o \
                global_variables.o input_output.o iso_fortran_env.o \
				major_reactions.o outputs.o rates.o \
				select_outputs.o trace_major.o numerical_types.o \
				ode_solver.o opkda1.o opkda2.o opkdmain.o photorates.o \
				shielding.o structure.o unitary_tests.o utilities.o

AMODULES		= iso_fortran_env.o numerical_types.o   
BMODULES		= $(AMODULES)  utilities.o global_variables.o dust_temperature_module.o photorates.o structure.o shielding.o
CMODULES		= $(BMODULES) input_output.o
DMODULES 	  	= ode_solver.o   
GMODULES		= gasgrain.o 
PMODULES		= outputs.o rates.o major_reactions.o


#################################################
#                   RULES                       #
#################################################

all:	            		nmgc

nmgc:             			$(OBJ) Makefile
	                		$(FF) $(LFLAGS) $(OBJ) -o $@ 

main.o:        				$(SRCMAIN)  $(CMODULES) $(GMODULES) $(PMODULES) Makefile
							$(FF) -c $(FFLAGS)  $(SRCMAIN) -o $@

iso_fortran_env.o: 			$(SRCISO) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCISO) -o $@

global_variables.o: 		$(SRCGLOBAL) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCGLOBAL) -o $@

numerical_types.o: 			$(SRCNUMTYPE) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCNUMTYPE) -o $@

utilities.o:   				$(SRCUTIL) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCUTIL) -o $@

gasgrain.o: 				$(SRCGASGRAIN) $(CMODULES) $(DMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCGASGRAIN) -o $@

dust_temperature_module.o:  $(SRCDUSTEMP) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCDUSTEMP) -o $@

shielding.o:     			$(SRCSHIELD) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCSHIELD) -o $@

structure.o:     			$(SRCSTRUCT) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCSTRUCT) -o $@

ode_solver.o:     			$(SRCSOLVER) $(BMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCSOLVER) -o $@

photorates.o:     			$(SRCPRATES) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCPRATES) -o $@

input_output.o:     		$(SRCINPUTOUTPUT) $(AMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCINPUTOUTPUT) -o $@

major_reactions.o:     		$(SRCMAJOR) $(BMODULES) $(GMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCMAJOR) -o $@

outputs.o:     				$(SRCOUTPUT) $(BMODULES) $(GMODULES) Makefile
	                		$(FF) -c $(FFLAGS)  $(SRCOUTPUT) -o $@

rates.o:     				$(SRCRATES) $(BMODULES) $(GMODULES) Makefile
	                		$(FF) -c $(FFLAGS) $(SRCRATES) -o $@

# select_outputs.o:     		$(SRCSELECT) $(BMODULES) Makefile
# 	                		$(FF) -c $(FFLAGS)  $(SRCSELECT) -o $@

# trace_major.o:     			$(SRCTRACEM) $(BMODULES) Makefile
# 	                		$(FF) -c $(FFLAGS)  $(SRCTRACEM) -o $@

opkda1.o: 					$(SRCOPKDA1)  Makefile
	                		$(FF) -c -w $(FFLAGS) $(MISMATCH) $(SRCOPKDA1) -o  $@

opkda2.o: 					$(SRCOPKDA2)  Makefile
	                		$(FF) -c -w $(FFLAGS) $(MISMATCH) $(SRCOPKDA2) -o $@
				
opkdmain.o: 				$(SRCOPKDMAIN)  Makefile
	                		$(FF) -c -w $(FFLAGS) $(MISMATCH) $(SRCOPKDMAIN) -o $@


install:	    nmgc
				./install.pl

clean:
	@rm -f	*.o *.mod
	@echo OBJECT and MODULE files removed.