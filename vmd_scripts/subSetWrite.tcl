#!/usr/bin/env tclsh
#Purpose: To write protein+plus water within a certain cutoff radiuss to a file
#The script can be generalized to any selection of atoms

set multiFramPdbFile mergedFilewFixProt.pdb
mol load pdb ${multiFramPdbFile}

set frmNum [molinfo top get numframes]
set frmPrfx justWT_fr
for {set i 0} {$i < $frmNum} {incr i} {  
#    set file [open "frm${i}." w]
    # set sel [atomselect top "protein" frame $i]
#    set sel [atomselect top "(water and noh within 10.5 of alpha) and not (water and noh within 3.5 of alpha)"]
#    set sel [atomselect top "(water and noh within 3.0 of protein)" frame $i]
#    set sel [atomselect top "(water and noh within 6.5 of protein) and not (water and noh within 3.5 of protein)" frame $i]
    set sel [atomselect top "(water within 7.0 of protein)" frame $i] 
    $sel writepdb ${frmPrfx}${i}.pdb
#    $sel delete
}

#for {set i 0} {$i < 100} {incr i} {  
#    exec [cat frm_${i}.pdb prot_in_7A_shell_fix_100fr.pdb]
#}
#}
exit