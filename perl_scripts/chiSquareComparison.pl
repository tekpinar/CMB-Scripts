#!/usr/bin/perl -w
use strict;
use Math::Trig;
#Purpose: To compare SAXS profiles produced by CRYSOL, FAST-Saxs, experimantal and 
#         out method using chi-squared test. I have to convert data types to logscale
#         in some cases, or convert s values of Yang et al by multiplying them w/ 2*PI. 

#Date  : 05/02/2011
#Author: Mustafa Tekpinar, tekpinar@buffalo.edu

sub log10 
{
    my $n = shift;
    return log($n)/log(10);
}

sub chiSquareTest#There are 3 arguments: N-Number of data points,
{
    #How to get theoretical value at exactly experimental data point.
my $N=    
}


die "Wrong number of parameters from command line \n
USAGE: perl chiSquareComparison.pl expData.txt crysolData.int YangData.txt myData.txt\n" unless $#ARGV == 3;

#Always, that file handle stuff seem ridiculus to me. 
#Why in any programming language dont ppl get rid of it?
my $i=0; #My dear regular counter.

#Open and read experimental data!
my @exp=();
open (EXP_FILE, "<$ARGV[0]") || die "Could not open $ARGV[0]\n";
while (my $line_in=<EXP_FILE>) 
{
    chomp($line_in);
    if($line_in=~/^\#/)
    {
	next;
    }
    else
    {
	my ($space, $sValue, $I_q, $expError)=split(/\s+/, $line_in);
#Silly space characters in the beginning of the file caused me to use a dummy variable named $space!
#	print $line_in."\t$expError\n";
#	print $line_in."\n";
#	print "$sValue\t$I_q\t$expError\n";
#	$exp[$i]=([$sValue, $I_q, $expError]);
	push (@exp, [$sValue, $I_q, $expError]);
#	print "$exp[$i][0]\t$exp[$i][1]\t$exp[$i][2]\n";
	$i++;
    }
}
close(EXP_FILE);

#Open and read CRYSOL file
my @cry=();
$i=0; #Reset my dear counter.
open (CRY_FILE, "<$ARGV[1]") || die "Could not open $ARGV[1]\n";
while (my $line_in=<CRY_FILE>) 
{
    chomp($line_in);
#    if($line_in=~/^\#/)
    if($line_in=~/^ Dif/)
    {
	next;
    }
    else
    {
	#I need a dummy $space value here!
	my ($space, $sValue, $theoretical, $inVacuo, $solvent, $borderLayer)=split(/\s+/, $line_in);
#	print "  $sValue, $theoretical, $inVacuo, $solvent, $borderLayer\n";
#	print $line_in."\n";
#	print "$sValue\t$I_q\t$expError\n";
#	$exp[$i]=([$sValue, $I_q, $expError]);
	push (@cry, [$sValue, log10($theoretical)]);
#	print "$cry[$i][0]\t$cry[$i][1]\n";
	$i++;
    }
}
close(CRY_FILE);

#Open and read Yang Saxs profile
my @yang=();
$i=0; #Reset my dear counter.
open (YANG_FILE, "<$ARGV[2]") || die "Could not open $ARGV[2]\n";
while (my $line_in=<YANG_FILE>) 
{
    chomp($line_in);
    if($line_in=~/^\#/)
    {
	next;
    }
    else
    {
	my ($space, $sValue, $I_q)=split(/\s+/, $line_in);
#	print $line_in."\n";
#	print "$sValue\t$I_q\n";
	$yang[$i]=([$sValue*2*pi, $I_q]);
#	print "$yang[$i][0]\t$yang[$i][1]\n";
	$i++;
    }
}
close(YANG_FILE);

