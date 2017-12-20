#!/bin/tclsh
# VMD for LINUXAMD64, version 1.8.6 (April 6, 2007)
# Log file 'saveAsPdb.txt', created by user tekpinar
#Purpose: A generic script to write a bunch of trajectories in pdb format

package require fileutil 

if { $argc != 4 } {
    puts "Usage: vmd -dispdev text -e saveAsPdb.tcl -args trj.psf trj.dcd output.pdb"
    exit -1
} else {
    set traj_psf [lindex $argv 0]
    puts "psf file: [lindex $argv 0]"
    set traj_dcd [lindex $argv 1]
    puts "dcd file: [lindex $argv 1]"
    
    set outfile [lindex $argv 2]
    puts "Output file: [lindex $argv 2]"
}

# load psf-dcd
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

set num_steps [molinfo 0 get numframes]
put "Total Number of steps in this trajectory is : $num_steps"

set stride [expr ($num_steps/100)]
#set new_num_steps [expr $num_steps/$stride]

#puts "Stride is $stride"
set sel [atomselect 0 "not water and not ions"]
#   package require fileutil
set f 0
for { set i 0 } { $i < $num_steps} { incr i $stride} {
    $sel frame $i
    $sel update
    $sel writepdb temp_$f.pdb 
    puts "I am working on file temp_${f}.pdb"
    #    ::fileutil::appendToFile ${outfile} temp_${f}.pdb 
    #    ::fileutil::appendToFile ${outfile} temp.pdb
 
    #    eval exec cat temp.pdb
    #    exec rm -f temp_${f}.pdb
    #    set f [expr $f+1]; 
}

exit