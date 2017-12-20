#!/usr/bin/perl -w 
use strict;

#Author : Mustafa Tekpinar
#Date   : 1 June, 2012
#Purpose: Run Crysol for a set of proteins. 
#Licence: GNU LGPL
#Version: 0.01


my @proteins = ('1bbb', '2dn3');

my $CRYSOL_EXE="/user/tekpinar/crysol/atsas-2.4.1-4/bin/./crysol";

my $qMax=0.6;
my $numDatPnts=61;

#my $d_ro=$wtr_prcnt*(0.334/100.000); #0.334 is bulk water density.
my $d_ro=0.03; #This is Crysol default value!

#if (-e ("${prot_end}00.log") ) 
#{
#    die "Crysol files already exists!\n";
#} 

# At first run crysol for with proper water weight
print  "Running: \n";
print  "$CRYSOL_EXE ${prot_end}.pdb /lm 50 /fb 18 /sm $qMax /ns $numDatPnts /dns 0.334 /dro $d_ro\n";
system("$CRYSOL_EXE ${prot_end}.pdb /lm 50 /fb 18 /sm $qMax /ns $numDatPnts /dns 0.334 /dro $d_ro\n");
system("rm -f ${prot_end}00.log");
system("rm -f ${prot_end}00.sav");
system("rm -f ${prot_end}00.flm");
system("rm -f ${prot_end}00.fit");
system("rm -f ${prot_end}00.alm");    
my $intensity_file="target_${prot_end}_dro003.int";
system("mv ${prot_end}00.int ${intensity_file}");

