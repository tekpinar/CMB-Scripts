#!/usr/bin/env tclsh
#Purpose: To calculate time evolution of angle of something, which only Ahmet Yildirim knows :). 
#Author : Modified from Ozge Yoluk's script with Mustafa Tekpinar and Ahmet Yildirim.
#Date   : October 12, 2016
#Licence: LGPL v3

if { $argc != 5 } {
    puts "Usage: vmd -dispdev text -e CAP_helix_179-195_rotation.tcl -args ref.pdb trj.pdb trj.xtc results.dat"
    exit -1
} else {
    set ref_pdb [lindex $argv 0]
    puts "Reference pdb: [lindex $argv 0]"

    set traj_pdb [lindex $argv 1]
    puts "trajectory pdb file: [lindex $argv 1]"

    set traj_xtc [lindex $argv 2]
    puts "trajectory xtc file: [lindex $argv 2]"
    
    set outfile [lindex $argv 3]
    puts "Results file: [lindex $argv 3]"
}
mol load pdb ${ref_pdb}
mol load pdb ${traj_pdb} xtc ${traj_xtc} 

proc angle { a b } {
    set amag [veclength $a]
    set bmag [veclength $b]
    set dotprod [vecdot $a $b]
    return [expr 57.2958 * acos($dotprod / ($amag * $bmag))]
}

package require Orient
namespace import Orient::orient

set sel [atomselect 0 "chain A and name CA"]
set I [draw principalaxes $sel]
set A [orient $sel [lindex $I 2] {0 0 1}]
[atomselect 0 all] move $A
set I [draw principalaxes $sel]

set ref [atomselect 0 "name CA and resid 9 to 134 and protein and chain A"]
set to_move [atomselect 1 "name CA and resid 9 to 134 and protein and chain A"]

set num_steps [molinfo 1 get numframes]
puts "The system has $num_steps frames."
set file [open ${outfile} w]

set compare [atomselect 1 "name CA and resid 9 to 134 and protein and chain A"]

for {set frame 0} {$frame < $num_steps} {incr frame} {
    
    # get the correct frame
    $compare frame $frame
    
    # compute the transformation
    set trans_mat [measure fit $compare $ref]
    
    # do the alignment
    $compare move $trans_mat
    
    # compute the RMSD
    set rmsd [measure rmsd $compare $ref]
    
    # print rmsd (ca) to the results file
    puts [format "%d\t%.6f" $frame $rmsd]
}

for {set x 0} {$x < $num_steps} {incr x} {  

#    $to_move frame $x

#    set trans_mat [measure fit $to_move $ref]
#    [atomselect 1 all] move $trans_mat
#    $to_move move $trans_mat
    
    set sel_h1 [atomselect 0 "name CA and resid 179 to 195 and chain A"]
    set I_hel_1 [draw principalaxes $sel_h1]
    
    set sel_h2 [atomselect 1 "name CA and resid 179 to 195 and chain A" frame $x]
    set I_hel_2 [draw principalaxes $sel_h2]
    
    set dot1 [vecdot  [lindex $I_hel_1 2] [lindex $I 2]]
    set hel1 [vecsub [lindex $I_hel_1 2] [vecscale $dot1 [lindex $I 2]]]
    
    set dot2 [vecdot  [lindex $I_hel_2 2] [lindex $I 2]]
    set hel2 [vecsub [lindex $I_hel_2 2] [vecscale $dot2 [lindex $I 2]]]
    
    set vec1 [lindex $I_hel_1 2]
    set vec2 [lindex $I_hel_2 2]
#    set rot [angle $hel1 $hel2]
    set rot [angle $vec1 $vec2]
    puts $file [format "%i\t%.2f" $x $rot]
}

close $file
exit
