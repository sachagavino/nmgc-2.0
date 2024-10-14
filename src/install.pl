#!/usr/bin/perl
#=======================================================
#           INSTALL ROUTINE FOR "NMGC"
#=======================================================
$pwd  = `pwd` ; 
chop($pwd) ;
print "Installing NMGC in the directory:\n  '$pwd'\n";
$home = $ENV{"HOME"};