#!/usr/bin/perl -w 
use strict;

die "Wrong number of parameters from command line \n
USAGE: perl produceFramesList.pl FramesList.txt protWTprefix justWTprefix framesBegin framesEnd skip\n" unless $#ARGV == 5;


open(OUTFILE, ">", "$ARGV[0]") || die ("Could not open $ARGV[0]");

my $i=0;
my $protWTprefix=$ARGV[1];
my $justWTprefix=$ARGV[2];
my $framesBegin =$ARGV[3];
my $framesEnd   =$ARGV[4];
my $skip=$ARGV[5];

for($i=$framesBegin; $i<=$framesEnd; $i+=$skip)
{
    $protWTprefix=$ARGV[1];
    $justWTprefix=$ARGV[2];
    $protWTprefix=$protWTprefix."shell${i}.pdb"; 
    $justWTprefix=$justWTprefix."blob${i}.pdb"; 
    
    print OUTFILE "$protWTprefix\t$justWTprefix\n";
#    system("cp /panasas/scratch/tekpinar/6lyz/$protWTprefix .");
#    system("cp /panasas/scratch/tekpinar/6lyz/$justWTprefix .");
}
close(OUTFILE);
