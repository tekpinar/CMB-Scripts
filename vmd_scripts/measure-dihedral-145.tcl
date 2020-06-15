#Purpose : This script calculates dihedral angles of the side chain of C145
#          Unfortunately, it is very case specific. 
#Author  : Mustafa Tekpinar
#Email   : tekpinar@buffalo.edu
#Date    : May 15, 2020

if { $argc != 4 } {
    puts "Usage: vmd -dispdev text -e measure-dihedrals.sh -args target.pdb trj.dcd results.dat "
    exit -1
} else {
    set target_pdb [lindex $argv 0]
    puts "pdb file: [lindex $argv 0]"
    set traj_dcd [lindex $argv 1]
    puts "dcd file: [lindex $argv 1]"
    set results_file [lindex $argv 2]
    puts "Results file: [lindex $argv 2]"
}

# load reference pdb file
mol new ${target_pdb}

# load psf-dcd 
mol addfile ${traj_dcd} waitfor all

# the frame being compared
set selchA1 [[atomselect top "resid 145 and chain A and name CA"] get index]
set selchA2 [[atomselect top "resid 145 and chain A and name CB"] get index]
set selchA3 [[atomselect top "resid 145 and chain A and name CG"] get index]
set selchA4 [[atomselect top "resid 145 and chain A and name C"] get index]

set selchB1 [[atomselect top "resid 145 and chain B and name CA"] get index]
set selchB2 [[atomselect top "resid 145 and chain B and name CB"] get index]
set selchB3 [[atomselect top "resid 145 and chain B and name CG"] get index]
set selchB4 [[atomselect top "resid 145 and chain B and name C"] get index]

# open results file
set file [open "${results_file}" w ]

# determine number of frames in trajectory
set num_steps [molinfo 0 get numframes]

for {set frame 0} {$frame < $num_steps} {incr frame} {

    set dihedralC145ChainA [measure dihed [list $selchA4 $selchA1 $selchA2 $selchA3] frame $frame]
    set dihedralC145ChainB [measure dihed [list $selchB4 $selchB1 $selchB2 $selchB3] frame $frame]

    puts $file [format "%d\t%.2f\t%.2f" $frame $dihedralC145ChainA $dihedralC145ChainB]
#    set dihedralC145ChainA [measure dihed { $sel1 $sel2 $sel3 $sel4 } frame $frame]
}
close $file
mol delete all
exit
