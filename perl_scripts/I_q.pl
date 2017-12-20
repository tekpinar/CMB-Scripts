#!/usr/bin/perl -w
use strict;
use Math::Trig;
#Purpose: To compare SAXS profiles produced by CRYSOL, FAST-Saxs, experimantal and 
#Date  : 06/13/2011
#Author: Mustafa Tekpinar, tekpinar@buffalo.edu

die "Wrong number of parameters from command line \n
USAGE: perl I_q.pl I_q_buffer.txt I_q_sample.txt\n" unless $#ARGV ==1;

#Open and read buffer data!
my @buffer=();
open (BUF_FILE, "<$ARGV[0]") || die "Could not open $ARGV[0]\n";
while (my $line_in=<BUF_FILE>) 
{
    chomp($line_in);
    my ($I_q, $sValue)=split(/\s+/, $line_in);
    push(@buffer, $I_q);
}
close(BUF_FILE);

#Open and read sample data!
my @sample=();
open (SAMP_FILE, "<$ARGV[1]") || die "Could not open $ARGV[1]\n";
while (my $line_in=<SAMP_FILE>) 
{
    chomp($line_in);
    my ($I_q, $sValue)=split(/\s+/, $line_in);
    push(@sample, $I_q);
}
close(SAMP_FILE);

my $i=0; #My dear regular counter.

#foreach(@buffer)
#{
#    print "$_\n";
#}

my $alpha=1.0;
my $c=0;
print scalar(@buffer)."\n";
for($i=0; $i<scalar(@buffer); $i++)
{
    my $temp= (-$sample[$i] + $alpha*$buffer[$i] +$c );
    my $q=0.001*$i*2*pi;
    printf ("%.3lf\t%.3lf\n", $q, $temp);
}
