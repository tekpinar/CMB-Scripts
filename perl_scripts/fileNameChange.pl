#!/bin/perl -w
use strict;

#Purpose: Change file names produced by split
#Author : Mustafa Tekpinar - tekpinar@buffalo.edu
#Date   : 05/18/2011

for(my $i=20; $i<121; $i++)
{
#    my $fileBase="ws"."$i";
    my $j=$i-20;
#    if($i<10)
#    {
#	$fileBase="ws"."$i";    
#    }
#    else
#    {
#	$fileBase="x"."$i";    
#    }

    my $pdbFileOld="ns"."$i".".pdb";
 #   $fileBase=~s/x/wb/;
    my $pdbFileNew;
    if($j<10)
    { $pdbFileNew="ns0"."$j".".pdb";}
    else
    { $pdbFileNew="ns"."$j".".pdb";}

    print "$pdbFileOld\t$pdbFileNew\n";
    system("mv $pdbFileOld $pdbFileNew");

}
