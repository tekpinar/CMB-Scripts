#!/usr/bin/env tclsh
#This script is supposed to calculate rmsd between a specified pdb file and each frame of a trajectory!
#This script requires three arguments. 
#

set pdb_name 1yzi
set target_pdb ${pdb_name}.pdb
set traj_psf R-T_transition/build/ionized.psf
set traj_tag aMD_2
set traj_dcd R-T_transition/production/prod_${traj_tag}.dcd

mol new ${target_pdb}
set reference [atomselect 0 "name CA"]

#set data_file_name rmsd_to_r_2_r2_${pdb_name}_${traj_dcd}.dat
#set file [open "${data_file_name}" w]



mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

# the frame being compared
set compare [atomselect 1 "name CA"]

set num_steps [molinfo 1 get numframes]
set file [open "rmsd_to_r_2_r2_${pdb_name}_${traj_tag}.dat" w]
for {set frame 0} {$frame < $num_steps} {incr frame} {
    
    # get the correct frame
    $compare frame $frame
    
    # compute the transformation
    set trans_mat [measure fit $compare $reference]
    
    # do the alignment
    $compare move $trans_mat
    
    # compute the RMSD
    set rmsd [measure rmsd $compare $reference]
    
    # print the RMSD
    puts $file "$frame \t$rmsd"
}
close $file
$compare delete 
$reference delete 
mol delete all
exit