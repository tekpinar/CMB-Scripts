#!/usr/bin/tcl

#Purpose: Calculate interface H bonds between two chains of H. pylori MTAN using vmd
#Version 2: This script has been modified to calculate h bonds of D198 in MTAN simulations.

if { $argc != 6 } {
    puts "Usage: vmd -dispdev text -e h_bonds_measure.tcl -args trj.pdb trj.xtc outfile.dat sel1 sel2"
    puts "Do not forget to put sel1 string and sel2 strings into separate double quoations!"
    puts "sel1 and sel2 should not be overlapping!"
    exit -1
} else {
    set traj_pdb [lindex $argv 0]
    puts "pdb file: [lindex $argv 0]"

    set traj_xtc [lindex $argv 1]
    puts "xtc file: [lindex $argv 1]"
    
    set outfile [lindex $argv 2]
    puts "Results file prefix: [lindex $argv 2]"

    set sel_string1 [lindex $argv 3]
    puts "Selection string: [lindex $argv 3]"

    set sel_string2 [lindex $argv 4]
    puts "Selection string: [lindex $argv 4]"
}

# load pdb-xtc
mol new ${traj_pdb} waitfor all
mol addfile ${traj_xtc} waitfor all
set mol [molinfo top] 

set file [open "${outfile}" w ]
set acc [atomselect $mol ${sel_string1}] 
set don [atomselect $mol ${sel_string2}] 

set nf [molinfo $mol get numframes] 
for {set i 0} {$i < $nf} {incr i} { 
    $acc frame $i 
    $don frame $i 
    set nhb1 [llength [lindex [measure hbonds 3.0 20 $acc $don] 0]] 
    set nhb2 [llength [lindex [measure hbonds 3.0 20 $don $acc] 0]] 
    set sum [expr $nhb1+$nhb2]
    
    puts $file [format "%.1f %d" [expr ($i*0.16)] $sum]
} 
close $file
exit