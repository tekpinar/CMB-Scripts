#!/usr/bin/env tclsh

#Purpose: To calculate waters within a certain cavity.
#         I wrote this script especially to count number
#         of waters within central cavity of hemoglobin. 
#         We are trying to see the time dependency of this number. 

#Author : Mustafa Tekpinar
#Date   : July 09, 2012
#Licence: LGPL v3

if { $argc != 7 } {
    puts "Usage: vmd -dispdev text -e waters_within_cavity.tcl -args frm_beg frm_end trj.psf trj.dcd max_radius results.dat"
    exit -1
} else {
    set frm_beg [lindex $argv 0]
    puts "Beginning frame: [lindex $argv 0]"

    set frm_end [lindex $argv 1]
    puts "End frame: [lindex $argv 1]"

    set traj_psf [lindex $argv 2]
    puts "psf file: [lindex $argv 2]"

    set traj_dcd [lindex $argv 3]
    puts "dcd file: [lindex $argv 3]"
    
    set max_radius [lindex $argv 4]
    puts "Maximum Radius: [lindex $argv 4]"

    set outfile [lindex $argv 5]
    puts "Results file: [lindex $argv 5]"
}

# load psf-dcd
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

set num_steps [molinfo 0 get numframes]

if { $frm_beg < 0} {
puts "WARNING: Beginning frame can not be less than zero!"
puts "         Setting the first framme to zero!"
set $frm_beg 0
}

if { $frm_end > $num_steps} {
puts "WARNING: End frame can not be more than the number of frames in the trajectory file!"
puts "         Setting frm_end to maximum frame number!"
set $frm_end $num_steps
}

#Measure center of mass for of protein
#This selection include ligands. 
set sel1 [atomselect top "not water and not ions"]
$sel1 num

#Since in WAXS calcaulations, proteins are fixed,
#we don't have to check center of mass for each frame!
set com_protein [measure center ${sel1} weight mass]
set x1 [lindex $com_protein 0]
set y1 [lindex $com_protein 1]
set z1 [lindex $com_protein 2]

#Maximum radius that I will use to check waters within cavity.
#Since after cavity I expect an abrupt drop in water numbers,
#I can adjust this parameter! 
#set max_radius 10
set max_rad_sqrd [expr $max_radius*$max_radius]

set frm_skip 1
set file [open ${outfile} w]




for {set x $frm_beg} {$x < $frm_end} {incr x $frm_skip} {  

#####Make the water selections in cavity and update this selection throughout the loop!
    set wat_in_cavity [atomselect top "same residue as {water and ((x-$x1)*(x-$x1) + (y-$y1)*(y-$y1) + (z-$z1)*(z-$z1))<($max_rad_sqrd)}" frame $x]
    
    set number [$wat_in_cavity num]

    $wat_in_cavity delete
    puts $file "$x    $number"
}


#Check as a file if the waters are really in cavity
set wat_in_cavity [atomselect top "same residue as {water and ((x-$x1)*(x-$x1) + (y-$y1)*(y-$y1) + (z-$z1)*(z-$z1))<($max_rad_sqrd)}" frame [expr ($frm_end-1)] ]

$wat_in_cavity writepdb wat_in_cavity.pdb 
$wat_in_cavity delete

close $file
puts "Water count within cavity has been completed successfully!"
exit