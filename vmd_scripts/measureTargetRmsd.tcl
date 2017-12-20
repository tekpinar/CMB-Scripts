#!/usr/bin/env tclsh

#Purpose: To measure rmsd of target structure versus  accelerated molecular dynamics (aMD) trajectory . 
#         The asssuption is target structure will be loaded first. Then, aMD trajectory is loaded. 

set target_pdb 2HHB.pdb

set traj_psf   /panasas/scratch/tekpinar/hemoglobin/R-T_transition/build/ionized.psf
set traj_dcd   /panasas/scratch/tekpinar/hemoglobin/R-T_transition/production/prod_aMD_1.dcd

mol load pdb 1BBB.pdb
set target [atomselect 0 "name CA"]

mol load psf ${traj_psf} dcd ${traj_dcd} 

set  aMD_traj [atomselect 1 "name CA"]

set numframes [molinfo 1 get numframes]

for {set frame 0} {${frame} < ${numframes}} {incr frame} {
 #Define a vector from alpha1 -> beta1
    $aMD_traj frame $frame
    set rmsd_fr [ measure rmsd $aMD_traj $target ]

    puts $rmsd_fr
}