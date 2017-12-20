#!/usr/bin/perl -w 
#Purpose: Just to get the values of a bunch of theoretical files vs hbCO experimental waxs profile. 
#Author : Mustafa Tekpinar
#Date   : 17 January 2012

use strict; 
use File::Basename;

my @T_States_Waxs_List=("2HHB_I_q_makowski_xs_7A_all_fix.dat", 
			"2HHB_I_q_makowski_xs_7A.dat", 
			"2hhb_I_q_makowski_xs_7A_ions.dat", 
			"2hhb_I_q_makowski_xs_7A_short.dat", 
			"2HHB_ALL_FIX_I_q_makowski_xs_7A_901_1000.dat");

#Here is a bunch of system calls!
my $qMin=0.0;
my $qMax=1.0;
my $expIntFile="hemoglobin_deoxy_waxs_exp_50mg-ml.txt";
my $all_chi_vals="all_chi_val_for_T_state.txt";
foreach (@T_States_Waxs_List) {
#    print $_;
    my ($name,$path,$suffix) = fileparse ( $_, qr{\..*}); 
    my $fit_file="$name"."_fit.dat";
#    print "Name:$name, Path: $path Extension: $suffix Fit file: $fit_file\n";
    system("echo 'File Name: $_'>>$all_chi_vals");
    system("./simpleChiComp.exe $expIntFile $_ $qMin $qMax $fit_file>>$all_chi_vals");
    system("echo '\n\n'>>$all_chi_vals");
}
