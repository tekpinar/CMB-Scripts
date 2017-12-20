#!/usr/bin/perl -w 
use strict;

my $i=0;
my $resultFile="prot_in_7A_shell_fix_100fr.pdb";
my $frameFilePrefix="frm_";
my $ttlFrmNmbr=100;
for($i=0; $i<$ttlFrmNmbr; $i++)
{
    system("grep ATOM $frameFilePrefix${i}.pdb>>$resultFile");
    system("cat end.txt>>$resultFile");
}
