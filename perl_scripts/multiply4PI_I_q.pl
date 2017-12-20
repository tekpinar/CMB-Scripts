#!/usr/bin/perl -w
use strict;
use Math::Trig;
#Purpose: I will multiply q/4*PI values of experimental data to make it compatible with my previous data. 

die "USAGE: Number of arguments insufficient\n
USAGE: perl multiply2PI_I_q.pl I_q_file.dat\n" unless $#ARGV==0;

my @I_q_array=();
my @q_array=();
my @sigma_q_array=();
my $i=0;

my $I_q_mltpld2PI_file=$ARGV[0];
$I_q_mltpld2PI_file=~ s/\.txt$/_mltpld2PI.txt/;

print "\n$I_q_mltpld2PI_file\n";
#Read input file to an array!
open(I_Q_DAT,"<$ARGV[0]") || die("Cannot Open File $ARGV[0]\n");
while (my $line_in = <I_Q_DAT>) 
{
    chomp ($line_in);
    ($q_array[$i], $I_q_array[$i], $sigma_q_array[$i])= split (/\t/, $line_in);
#    print "$q_array[$i]\t$I_q_array[$i]\t$sigma_q_array[$i]\n";
    $i++;
}
close(I_Q_DAT);
my $numoflines=$i;

#Write mltpld2PI values to an array!
open(I_Q_MUL_DAT,">$I_q_mltpld2PI_file") || die("Cannot Open File $I_q_mltpld2PI_file\n");
for($i=0; $i<$numoflines; $i++)
{
    $q_array[$i]=$q_array[$i]*2*pi;
    print  I_Q_MUL_DAT "$q_array[$i]\t$I_q_array[$i]\t$sigma_q_array[$i]\n";
}

close(I_Q_MUL_DAT);

#Write squared values to an array!
#open(I_Q_SQRD_DAT,">$I_q_sqrd_file") || die("Cannot Open File $I_q_sqrd_file\n");
#for($i=0; $i<$numoflines; $i++)
#{
#    $I_q_array[$i]= ($I_q_array[$i]*$I_q_array[$i]);
#    print  I_Q_SQRD_DAT "$q_array[$i]\t$I_q_array[$i]\n";
#}

#close(I_Q_SQRD_DAT);

