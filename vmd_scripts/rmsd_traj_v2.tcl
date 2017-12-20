#Purpose : This script calculates rmsd (of only CA atoms) between a specified pdb file and each frame of a trajectory!
#         It assumes that there is not any other structure loaded before!
#Author  : Mustafa Tekpinar
#Email   : tekpinar@buffalo.edu
#Date    : February 1, 2012
#Modified: April 3, 2015
#          I added the script a selection string  
if { $argc != 6 } {
    puts "Usage: vmd -dispdev text -e rmsd_traj.tcl -args target.pdb trj.psf trj.dcd results.dat \"selection string\" "
    exit -1
} else {
    set target_pdb [lindex $argv 0]
    puts "pdb file: [lindex $argv 0]"
    set traj_psf [lindex $argv 1]
    puts "psf file: [lindex $argv 1]"
    set traj_dcd [lindex $argv 2]
    puts "dcd file: [lindex $argv 2]"
    set results_file [lindex $argv 3]
    puts "Results file: [lindex $argv 3]"
    set sel_string [lindex $argv 4]
    puts "Selection string: [lindex $argv 4]"
}

# load reference pdb file
mol new ${target_pdb}
set reference [atomselect 0 ${sel_string}]

puts "Number of reference atoms: [$reference num]"
# load psf-dcd 
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

# the frame being compared
set compare [atomselect 1 ${sel_string}]
puts "Number of compare atoms: [$compare num]"
# open results file
set file [open "${results_file}" w ]

# determine number of frames in trajectory
set num_steps [molinfo 1 get numframes]

for {set frame 0} {$frame < $num_steps} {incr frame} {
    
    # get the correct frame
    $compare frame $frame
    
    # compute the transformation
    set trans_mat [measure fit $compare $reference]
    
    # do the alignment
    $compare move $trans_mat
    
    # compute the RMSD
    set rmsd [measure rmsd $compare $reference]
    
    # print rmsd (ca) to the results file
    puts $file [format "%d\t%.6f" $frame $rmsd]
}
close $file

$compare delete
$reference delete 
mol delete all
exit