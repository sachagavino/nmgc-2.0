Introduction
************

What is NMGC?
=================
The Nautilus Multi-Grain Code (NMGC) is a gas-grain code for astrochemistry written in Fortran 90 and derived from the code gas-grain code Nautilus.
The software is mainly written to compute the chemical evolution of a physical model, given a set of initial chemical abundances. As we will see, NMGC is particularly 
suited to calculate the chemical abundances inside molecular clouds, proto-stellar envelopes, and protoplanetary disks.

The particularity of NMGC, as opposed to Nautilus, is its abilitity to consistently use multiple grain populations, each of which with their own density
and temperature. This is a powerful tool to investigate the various effects of dust grain size and temperature on the chemical evolution in an astrophysical environment.

Note that in the following text, the name Nautilus and NMGC are sometimes used interchangeably, which should not be a source of confusion to you, since after all both codes have the same core.

Copyright
=========
NMGC is derived from the Nautilus code developed in the Bordeaux astrochemistry group. Nautilus is adapted from the original gas-grain model of Hasegawa & Herbst (1993) and has been developed in Ohio
State University (OSU model) later on. It has been continuously developed since then. 
It uses the LSODES (Livermore Solver for Ordinary Differential Equations with general Sparse Jacobian matrix) solver (Hindmarsh 1983).
A detailed description is given by Semenov et al. (2010). Major notable changes have been done over the last few years. The three-phase model was included in Nautilus (and NMGC)
in Bordeaux (Ruaud et al. 2016). The original NMGC version was developed in Bordeaux by Iqbal & Wakelam (2018), which was later adapted for protoplanetary disks and customized grain size distributions (Gavino et al 2021).  