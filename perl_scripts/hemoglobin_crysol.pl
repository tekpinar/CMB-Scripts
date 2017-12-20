#!/bin/perl -w 
#Purpose: Calculate S/WAXS intensities of different hbCO states
#Author : Mustafa Tekpinar
#Date   : 4 June 2012
#Licence: LGPL v3. 

use strict; 

#Selected hbCO states:-----T state-----, ----R2 state-----, -----R state-----, ----RR2 state----, -----R3 state----
my @hbCO_states =    ('2dn2_prtAndHeme', '1bbb_prtAndHeme', '2dn3_prtAndHeme', '1mko_prtAndHeme', '1yzi_prtAndHeme');
#my @hbCO_states =    ('1bbb_prtAndHeme');
my $CRYSOL_EXE="/user/tekpinar/crysol/atsas-2.4.1-4/bin/./crysol";


# At first run crysol for with proper water weight
#My water weight is percentage
my $prcnt=9;
my $wtr_prcnt=($prcnt*(0.334)/100.0);
my $d_ro=0.03; #This is Crysol default value!
print "Water shell contrast (d_ro/ro)=$wtr_prcnt\n";

my $exp_data="hemoglobin_hbCO_waxs_exp_50mg-ml.dat";
my $qMin=0.0;
my $qMax=1.0;
my $numDatPnts=101;
foreach(@hbCO_states)
{
    print  "Running: \n";
    my $prot_end="$_";
    print  "$CRYSOL_EXE ${prot_end}.pdb /lm 50 /fb 18 /sm $qMax /ns $numDatPnts /dns 0.334 /dro $d_ro\n";
    system("$CRYSOL_EXE ${prot_end}.pdb /lm 50 /fb 18 /sm $qMax /ns $numDatPnts /dns 0.334 /dro $d_ro\n");
    system("rm -f ${prot_end}00.log");
    system("rm -f ${prot_end}00.sav");
    system("rm -f ${prot_end}00.flm");
    system("rm -f ${prot_end}00.fit");
    system("rm -f ${prot_end}00.alm");    
    $qMax=~s/\./p/g ;
    my $theo_data="${prot_end}00.int";
    
#Count the number of lines in the file
    open (FILE, "<", $theo_data) or die "I can't open $theo_data to read!\n";
    my  @lines = <FILE>;
    print "Number of lines in this file is $#lines\n";
    close(FILE);
    $theo_data="${prot_end}_qMax${qMax}_crysol";    
    system("tail -n $#lines ${prot_end}00.int|cut -c3-29> ${theo_data}.int");
    
    system("rm -f ${prot_end}00.int");
    print "Theoretical intensity file is $theo_data.int\n";
    
    $qMax=1.0; #Since in substitute statement this string changes, one needs to reassign the value again!
#Run chi test for the theoretical data file!
    system("./simpleChiComp.exe $exp_data ${theo_data}.int $qMin $qMax ${theo_data}_fit.int");
}
