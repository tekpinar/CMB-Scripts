#!/usr/bin/perl -w
use strict;
use Math::Trig;
#Purpose: To merge multiframe pdb files. 
#Date  : 06/15/2011
#Author: Mustafa Tekpinar, tekpinar@buffalo.edu

die "Wrong number of parameters from command line \n
USAGE: perl mergeMultiFramePdb protFile.pdb waterFile.pdb\n" unless $#ARGV ==1;


my $i=0; #My dear regular counter.
my $protLn4Frm=1961;
my $watLn4Frm=46873;
my $frameNum=100;

my $mergedFileName="mergedFilewFixProt.pdb";

#my $onlyProtFile="prot_only_100f.pdb";
#my $onlyWatFile="wb_only_100f.pdb";

my $onlyProtFile=$ARGV[0];
my $onlyWatFile=$ARGV[1];

for($i=0; $i<$frameNum; $i++)
{
    my $prtUpdtd=($i+1)*$protLn4Frm;
    my $watUpdtd=($i+1)*$watLn4Frm;

    system("head -n $prtUpdtd $onlyProtFile|tail -n $protLn4Frm|grep ATOM >>$mergedFileName");
    open(DAT,">>$mergedFileName") || die("Cannot Open File");
    print DAT "TER\n";
    close(DAT); 
#    system("cat ter.txt>>$mergedFileName");
    system("head -n $watUpdtd $onlyWatFile|tail -n $watLn4Frm|grep ATOM >>$mergedFileName");
    open(DAT,">>$mergedFileName") || die("Cannot Open File");
    print DAT "TER\nEND\n";
    close(DAT); 
#    system("cat terEnd.txt>>$mergedFileName");
}

#Open and read protFile data!
#my @buffer=();
#open (PROT_FILE, "<$ARGV[0]") || die "Could not open $ARGV[0]\n";
#while (my $line_in=<PROT_FILE>) 
#{
#    chomp($line_in);
#    my ($I_q, $sValue)=split(/\s+/, $line_in);
#    push(@buffer, $I_q);
#}
#close(PROT_FILE);

#Open and read waterFile data!
#my @sample=();
#open (WTR_FILE, "<$ARGV[1]") || die "Could not open $ARGV[1]\n";
#while (my $line_in=<WTR_FILE>) 
#{
#    chomp($line_in);
#    my ($I_q, $sValue)=split(/\s+/, $line_in);
#    push(@sample, $I_q);
#}
#close(WTR_FILE);



