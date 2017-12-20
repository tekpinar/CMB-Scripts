#!/usr/bin/env tclsh
#Purpose: To write protein+plus water within a certain cutoff radiuss to a file
#The script can be generalized to any selection of atoms. The trajectory file 
#is a dcd file. 

set multiFramPdbFile prot_in_wb_only_fix_100fr

mol load pdb ${multiFramPdbFile}.pdb

set sel [atomselect top "protein or (water within 7.0 of protein)"
set $startframe 0
set $endframe 100
set frmPrfx protWT_frms
animate write pdb ${protWT_frms}.pdb $sel beg $startframe end $lastframe

exit