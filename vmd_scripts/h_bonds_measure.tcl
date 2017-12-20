#!/usr/bin/tcl

#Purpose: Calculate interface H bonds between two chains of H. pylori MTAN using vmd
if { $argc != 4 } {
    puts "Usage: vmd -dispdev text -e h_bonds_measure.tcl -args trj.pdb trj.xtc h_bonds"
    exit -1
} else {
    set traj_pdb [lindex $argv 0]
    puts "pdb file: [lindex $argv 0]"

    set traj_xtc [lindex $argv 1]
    puts "xtc file: [lindex $argv 1]"
    
    set outfile [lindex $argv 2]
    puts "Results file prefix: [lindex $argv 2]"
}

# load pdb-xtc
mol new ${traj_pdb} waitfor all
mol addfile ${traj_xtc} waitfor all
set mol [molinfo top] 

set resSet1 {103 103 101 54 116 49 151 151 152 153}
set resSet2 {153 151 152 151 49 116 54 103 101 103}


for {set j 0} {$j < 10} {incr j} { 

    set res1 [lindex $resSet1 $j]
    set res2 [lindex $resSet2 $j]

    set file [open "${outfile}_Ares${res1}_Bres${res2}.dat" w ]
    set acc [atomselect $mol "protein and chain A and resid ${res1}"] 
    set don [atomselect $mol "protein and chain B and resid ${res2}"] 
    
    set nf [molinfo $mol get numframes] 
    for {set i 0} {$i < $nf} {incr i} { 
	$acc frame $i 
	$don frame $i 
	set nhb1 [llength [lindex [measure hbonds 3.0 20 $acc $don] 0]] 
	set nhb2 [llength [lindex [measure hbonds 3.0 20 $don $acc] 0]] 
	set sum [expr $nhb1+$nhb2]
	
	puts $file [format "%d %d" $i $sum]
    } 
    close $file
}
exit

