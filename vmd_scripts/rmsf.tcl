#!/usr/bin/tcl

#Purpose: Calculate rmsf by using vmd
if { $argc != 6 } {
    puts "Usage: vmd -dispdev text -e rmsf.tcl -args trj.psf trj.dcd rmsf.dat beg_frm end_frm"
    exit -1
} else {
    set traj_psf [lindex $argv 0]
    puts "psf file: [lindex $argv 0]"

    set traj_dcd [lindex $argv 1]
    puts "dcd file: [lindex $argv 1]"
    
    set outfile [lindex $argv 2]
    puts "Results file: [lindex $argv 2]"

    set beg_frm [lindex $argv 3]
    puts "Beginning frame: [lindex $argv 3]"

    set end_frm [lindex $argv 4]
    puts "End frame: [lindex $argv 4]"

}

# load psf-dcd
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

# Select atoms 

#set selection "name C4'"
#set sel [atomselect top "name C4'"]
#set ref [atomselect top "name C4'" frame $beg_frm]

set sel [atomselect top "name CA"]
set ref [atomselect top "name CA" frame $beg_frm]

#set ref [atomselect top "name CA" frame 0]
#set num_steps [molinfo 0 get numframes]
# Measure average structure
#set ref [measure avpos $sel  first $beg_frm last $end_frm step 1 ]

# Align each frame
for {set i $beg_frm } {$i <= $end_frm } { incr i } {
    $sel frame $i
    $sel move [measure fit $sel $ref]
    $sel frame $i
 }

set fp [open "${outfile}" w]

puts "Number of selected atoms= [$sel num]"

for {set i 0} {$i < [$sel num]} {incr i} {
    set rmsf [measure rmsf $sel first $beg_frm last $end_frm step 1]
#    set beta [expr 8*3.14*3.14*[lindex $rmsf $i]*[lindex $rmsf $i]/3.0]
    puts $fp "[expr {$i+1}] [lindex $rmsf $i]"
#   puts $fp "[expr {$i+1}] $beta"
}
close $fp 

exit