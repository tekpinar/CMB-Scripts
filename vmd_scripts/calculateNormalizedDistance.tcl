##
## Make an atom selection, set the "User" fields for all atoms
## in the selection ("all" in this case since I'm too lazy to do
## something more interesting)
##
mol new path_open2closed_rc10.pdb waitfor all
set n [molinfo top get numframes]
set sel [atomselect top "all"]
#set dip [open "zundel.dip" r]

for {set i 0} {$i<$n} {incr i} {
    animate goto $i
    $sel frame $i
    puts "Setting User data for frame [$sel frame] ..."
#    $sel set user [$sel get beta]
    set nd ""
    foreach atom [$sel get index] {
	set posB [lindex [[atomselect top "index $atom" frame 0] get {x y z}] 0]

	set posI [lindex [[atomselect top "index $atom" frame $i] get {x y z}] 0]
#	set posI [lindex [[atomselect top "index $atom" frame $n] get {x y z}] 0]

	set posE [lindex [[atomselect top "index $atom" frame $n] get {x y z}] 0]
   
	# set xB [lindex $posB 0]
	# set yB [lindex $posB 1]
	# set zB [lindex $posB 2]

	# set xI [lindex $posI 0]
	# set yI [lindex $posI 1]
	# set zI [lindex $posI 2]

	# set xE [lindex $posE 0]
	# set yE [lindex $posE 1]
	# set zE [lindex $posE 2]

	# set ND_BI [expr pow(($xB-$xI)*($xB-$xI) + ($yB-$yI)*($yB-$yI) + ($zB-$zI)*($zB-$zI),0.5)]
	# set ND_IE [expr pow(($xI-$xE)*($xI-$xE) + ($yI-$yE)*($yI-$yE) + ($zI-$zE)*($zI-$zE),0.5)]

	set ND_BI [veclength [vecsub $posB $posI]]
	set ND_IE [veclength [vecsub $posI $posE]]
#	nd [expr (($ND_BI)/($ND_BI+$ND_IE))]

	lappend nd [expr (($ND_BI)/($ND_BI+$ND_IE))]
	#    if {$dist > $max} {set max $dist}
    }

#    puts $nd
#    $sel set user [expr $i*0.1]
    $sel set user $nd
#    $sel get user
#    unset nd
}
$sel delete
##
## change the "color by" and "trajectory" tab settings so that
## the new color values, and start it animating...
##
mol modcolor 0 0 User
mol colupdate 0 0 1
#mol scaleminmax 0 0 0.0 $n
mol scaleminmax 0 0 0.0 1.0
animate forward 

