#!/usr/bin/env tclsh
#Purpose: To get cell vectors and center for a protein in a water box.
#Author : Mustafa Tekpinar - tekpinar@buffalo.edu
#Date   : 05/31/2011

set file [open "myParams.dat" w]

set all [atomselect top "all"]

#Measure center. 
set cntrCoor [measure center $all]
set cntrString [format "cellOrigin\t\t%.2f\t%.2f\t%.2f" [lindex $cntrCoor 0] [lindex $cntrCoor 1] [lindex $cntrCoor 2]]

#Measure min-max of box. 
set vecs [measure minmax $all]
#This returns two lists: One coordinates of min and the other coordinates of max. 
set vec0 [lindex $vecs 0]
set vec1 [lindex $vecs 1]

set xBasis [expr abs([lindex $vec0 0] - [lindex $vec1 0])]
set yBasis [expr abs([lindex $vec0 1] - [lindex $vec1 1])]
set zBasis [expr abs([lindex $vec0 2] - [lindex $vec1 2])]

set xString [format "cellBasisVector1\t%.2f\t0.00\t0.00" $xBasis]
set yString [format "cellBasisVector2\t0.00\t%.2f\t0.00" $yBasis]
set zString [format "cellBasisVector3\t0.00\t0.00\t%.2f" $zBasis]

puts $file $xString
puts $file $yString
puts $file $zString
puts $file $cntrString
close $file