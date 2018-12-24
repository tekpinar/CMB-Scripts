#!/usr/bin/env tclsh
#Purpose: 
#Author : Mustafa Tekpinar - tekpinar@buffalo.edu
#Date   : 05/31/2011
#Licence: LGPL v3
if { $argc != 3 } {
    puts "\n\nPurpose: To get cell vectors and center for a protein in a water box.

Usage: \n
         vmd -dispdev text -e namdGetSysParams.tcl -args ref.pdb out.txt\n\n
"         
    exit -1
} else {
    set ref_pdb [lindex $argv 0]
    puts "Reference pdb file: [lindex $argv 0]"

    set out_txt [lindex $argv 1]
    puts "Output file: [lindex $argv 1]"
}

mol new $ref_pdb

set file [open out_txt w]

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
set crystalString [format "CRYST1  %.3f\t%.3f\t%.3f  90.00  90.00  90.00 P 1           1" $xBasis $yBasis $zBasis]
puts $file $xString
puts $file $yString
puts $file $zString
puts $file $cntrString
puts $file $crystalString
close $file
exit 0
