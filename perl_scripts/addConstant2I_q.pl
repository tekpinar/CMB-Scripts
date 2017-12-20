#!/usr/bin/perl -w
use strict;

#Purpose: I will add a constant value to shift my I_q values. 

die "USAGE: Number of arguments insufficient\n
USAGE: perl addConstant2I_q.pl I_q_file.dat constant\n" unless $#ARGV==1;

my @I_q_array=();
my @q_array=();
my $i=0;
my $I_q_shifted_file=$ARGV[0];
$I_q_shifted_file=~ s/\.dat$/_shifted.dat/;

my $I_q_sqrd_file=$ARGV[0];
$I_q_sqrd_file=~ s/\.dat$/_sqrd.dat/;

my $shift=$ARGV[1];

print "\n$I_q_shifted_file\n";
#Read input file to an array!
open(I_Q_DAT,"<$ARGV[0]") || die("Cannot Open File $ARGV[0]\n");
while (my $line_in = <I_Q_DAT>) 
{
    chomp ($line_in);
    ($q_array[$i], $I_q_array[$i])= split (/\t/, $line_in);
#    print "$q_array[$i]\t$I_q_array[$i]\n";
    $i++;
}
close(I_Q_DAT);
my $numoflines=$i;

#Write shifted values to an array!
open(I_Q_SHIFT_DAT,">$I_q_shifted_file") || die("Cannot Open File $I_q_shifted_file\n");
for($i=0; $i<$numoflines; $i++)
{
    $I_q_array[$i]=$I_q_array[$i]+$shift;
    print  I_Q_SHIFT_DAT "$q_array[$i]\t$I_q_array[$i]\n";
}

close(I_Q_SHIFT_DAT);

#Write squared values to an array!
open(I_Q_SQRD_DAT,">$I_q_sqrd_file") || die("Cannot Open File $I_q_sqrd_file\n");
for($i=0; $i<$numoflines; $i++)
{
    $I_q_array[$i]= ($I_q_array[$i]*$I_q_array[$i]);
    print  I_Q_SQRD_DAT "$q_array[$i]\t$I_q_array[$i]\n";
}

close(I_Q_SQRD_DAT);

