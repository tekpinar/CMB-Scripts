#  Draw a spring of a predefined length, helical rise, etc, oriented from the 
#  previously picked point to the eye.
#  You must be in orthographic perspective for this to work
#

proc spring {} {
	
  # radius of spring in Angstrom 
  set rads 0.5
  # radius of tube in Angstrom 
  set radt 0.5
  # resolution of spring, number of polygon edges per turn  
  set poly 100
  # number of turns per one radius helical rise 
  set turn 2.0
  # length of spring + cylinders 
  set ltot 10.0 
  # fraction of the length covered by spring (0-1)
  set span 0.8 

  # get picked atom
  global vmd_pick_atom vmd_pick_mol
  set sel [atomselect $vmd_pick_mol "index $vmd_pick_atom"]

  # coordinates of the atom
  set coord1 [lindex [$sel get {x y z}] 0]

  # position in world space
  set mat [lindex [molinfo $vmd_pick_mol get view_matrix] 0]
  set world1 [vectrans $mat $coord1]

  # since this is orthographic, I just get the projection
  lassign $world1 x1 y1 
  # get a coordinate behind the eye
  set world2 "$x1 $y1 5"

  # convert back to molecule space
  # (need an inverse, which is only available with the measure command)
  set inv [measure inverse $mat]
  set coord2 [vectrans $inv $world2]

  # compute length and scaling conversion 
  set lcoord21 [veclength [vecsub $coord2 $coord1]]
  set lworld21 [veclength [vecsub $world2 $world1]]
  set ratio [expr $lworld21 / $lcoord21]

  # compute endpoint
  set coord3 [vecadd $coord1 [vecscale [vecsub $coord2 $coord1] [expr $ltot / $lcoord21]]] 

  # compute endpoints of spring
  set start [expr 0.5 * (1 - $span)]
  set finish [expr 0.5 * (1 + $span)]
  set coord3s [vecadd $coord3 [vecscale [vecsub $coord1 $coord3] $start]]
  set coord1s [vecadd $coord3 [vecscale [vecsub $coord1 $coord3] $finish]]

  #draw end cylinders and cone
  draw color orange
  draw cylinder $coord1 $coord1s radius $radt
  draw sphere $coord1 radius $radt
  draw cylinder $coord3 $coord3s radius $radt
  set coord4 [vecsub $coord3 [vecscale [vecsub $coord1 $coord3] [expr $start * 0.5]]]
  set radc [expr 2 * $radt]
  draw color red
  draw cone $coord3 $coord4 radius $radc

  #----------------------------------------------------------------------
  #draw spring; we do this in world space and transform to molecule space
  #----------------------------------------------------------------------

  #initialize
  set old $coord1s
  draw color orange
  draw sphere $old radius $radt
  set world3s [vectrans $mat $coord3s]
  set world1s [vectrans $mat $coord1s]
  lassign $world3s x1 y1 maxoffset
  lassign $world1s x1 y1 offset
  set i 0
  set worldrad [expr $ratio * $rads]
  set deltaoffset [expr $worldrad / ($poly * $turn)]
  set pi [expr 2*asin(1.0)]
  set sx [expr $worldrad + $x1]
  set worldnew "$sx $y1 $offset"
  set new [vectrans $inv $worldnew]
  draw cylinder $old $new radius $radt
  set old $new
  draw sphere $old radius $radt
  set offset [expr $offset + $deltaoffset]
  set i 1

  # loop
  draw color blue
  while {$offset <= $maxoffset} {
	set sx [expr $worldrad * cos($i * 2 * $pi / $poly) + $x1]
	set sy [expr $worldrad * sin($i * 2 * $pi / $poly) + $y1]
        set worldnew "$sx $sy $offset"
	set new [vectrans $inv $worldnew]
	draw cylinder $old $new radius $radt
	set old $new
	set offset [expr $offset + $deltaoffset]
	incr i
  }	
  draw color orange
  set new $coord3s
  draw cylinder $old $new radius $radt
  draw sphere $old radius $radt
  draw sphere $new radius $radt

  puts "Start: {$coord1}"
  puts "End: {$coord3}"
  puts "spring from {$coord1s} to {$coord3s}, radius $rads, tube radius $radt A, resolution $poly, $turn turns per helical rise of $rads A."
}
