###############################################################
# sasa.tcl                                                    #
# DESCRIPTION:                                                #
#    This script is quick and easy to provide procedure       #
# for computing the Solvent Accessible Surface Area (SASA)    #
# of Protein and allows Users to select regions of protein.   #
#                                                             #   
# EXAMPLE USAGE:                                              #
#         source sasa.tcl                                     #
#         Selection: chain A and resid 1                      #
#                                                             #
#   AUTHORS:                                                  #
#Sajad Falsafi (sajad.falsafi@yahoo.com)               #
#       Zahra Karimi                                          # 
#       3 Sep 2011                                           #
###############################################################

#puts -nonewline "\n \t \t Selection: "
#gets stdin selmode
#Purpose: Calculate rmsf by using vmd
if { $argc != 4 } {
    puts "Usage: vmd -dispdev text -e sasa.tcl -args trj.psf trj.dcd sasa.dat"
    exit -1
} else {
    set traj_psf [lindex $argv 0]
    puts "psf file: [lindex $argv 0]"

    set traj_dcd [lindex $argv 1]
    puts "dcd file: [lindex $argv 1]"
    
    set outfile [lindex $argv 2]
    puts "Results file: [lindex $argv 2]"

#    set beg_frm [lindex $argv 3]
#    puts "Beginning frame: [lindex $argv 3]"

#    set end_frm [lindex $argv 4]
#    puts "End frame: [lindex $argv 4]"
}

# load psf-dcd
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

set selmode "chain C or chain D"
# selection
set sel [atomselect top "$selmode"]
$sel num
set protein [atomselect top "protein"]
set n [molinfo top get numframes]
set output [open "$outfile" w]
# sasa calculation loop
for {set i 0} {$i < $n} {incr i} {
    molinfo top set frame $i
    set sasa [measure sasa 1.4 $protein -restrict $sel]
    puts "\t \t progress: $i/$n"
    puts $output "$sasa"
}
puts "\t \t progress: $n/$n"
puts "Done."
puts "output file: $outfile"
close $output
exit
