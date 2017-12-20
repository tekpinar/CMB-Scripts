#!/usr/bin/env tclsh

#Purpose: To calculate lid and nmp angles to investigate ake time evolution. 
#Author : Mustafa Tekpinar
#Date   : November 28, 2014
#Licence: LGPL v3

if { $argc != 6 } {
    puts "Usage: vmd -dispdev text -e angle_plot.tcl -args frm_beg frm_end trj.pdb trj.xtc results.dat"
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
    
    set outfile [lindex $argv 4]
    puts "Results file: [lindex $argv 4]"
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

#NMP Core tip
set nmp_sel1 [atomselect top "protein and backbone and resid 115 to 125"]
$nmp_sel1 num

#NMP joint
set nmp_sel2 [atomselect top "protein and backbone and resid 90 to 99"]
$nmp_sel2 num

#NMP tip
set nmp_sel3 [atomselect top "protein and backbone and resid 35 to 55"]
$nmp_sel3 num

#LID Core tip
set lid_sel1 [atomselect top "protein and backbone and resid 179 to 185"]
$lid_sel1 num

#LID joint
set lid_sel2 [atomselect top "protein and backbone and resid 115 to 125"]
$lid_sel2 num

#LID tip
set lid_sel3 [atomselect top "protein and backbone and resid 125 to 153"]
$lid_sel3 num

set frm_skip 1
set file [open ${outfile} w]

for {set x $frm_beg} {$x < $frm_end} {incr x $frm_skip} {  

#At first, lets handle nmp side vectors    
    $nmp_sel1 frame $x
    $nmp_sel2 frame $x
    $nmp_sel3 frame $x
    set com_nmp_core [measure center ${nmp_sel1} weight mass]
    set com_nmp_joint [measure center ${nmp_sel2} weight mass]
    set com_nmp_tip [measure center ${nmp_sel3} weight mass]

    set nmp_vec1 [vecsub  $com_nmp_core $com_nmp_joint]
    set nmp_vec2 [vecsub  $com_nmp_tip $com_nmp_joint]

    set nmp_angle [expr acos(([vecdot $nmp_vec1 $nmp_vec2])/(([veclength $nmp_vec1])*([veclength $nmp_vec2])))*360/(2*acos(-1))];

#Now, lets handle lid side vectors    
    $lid_sel1 frame $x
    $lid_sel2 frame $x
    $lid_sel3 frame $x
    set com_lid_core [measure center ${lid_sel1} weight mass]
    set com_lid_joint [measure center ${lid_sel2} weight mass]
    set com_lid_tip [measure center ${lid_sel3} weight mass]

    set lid_vec1 [vecsub  $com_lid_core $com_lid_joint]
    set lid_vec2 [vecsub  $com_lid_tip $com_lid_joint]

    set lid_angle [expr acos(([vecdot $lid_vec1 $lid_vec2])/(([veclength $lid_vec1])*([veclength $lid_vec2])))*360/(2*acos(-1))];

#Finally, lets write the results to a file.
    puts $file [format "%i\t%.3f\t%.3f" $x $nmp_angle $lid_angle]

}

close $file
puts "Angle calculation has been completed successfully!"

exit

