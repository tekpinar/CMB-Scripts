#!/bin/tclsh
# VMD for LINUXAMD64, version 1.8.6 (April 6, 2007)
# Log file 'saveAsPdb.txt', created by user tekpinar
#Purpose: A generic script to write a bunch of trajectories in pdb format

#package require fileutil 

if { $argc != 5 } {
    puts "Usage: vmd -dispdev text -e saveDcd2Pdb.tcl -args trj.psf trj.dcd output.pdb stride"
    exit -1
} else {
    set traj_psf [lindex $argv 0]
    puts "psf file: [lindex $argv 0]"
    set traj_dcd [lindex $argv 1]
    puts "dcd file: [lindex $argv 1]"
    
    set outfile [lindex $argv 2]
    puts "Output file: [lindex $argv 2]"

    set stride [lindex $argv 3]
    puts "Stride: [lindex $argv 3]"
}

# load psf-dcd
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

set my_sel [atomselect top "all"]
set num_steps [molinfo 0 get numframes]
put "Total Number of steps in this trajectory is : $num_steps"

animate write pdb ${outfile} beg 0 end -1 skip $stride sel [atomselect top all] 
#animate write pdb ${outfile} beg 0 end 7499 skip $stride waitfor all sel $my_sel 0

exit