#!/usr/bin/env tclsh

#Purpose: To build a pure water box without protein. 
#         We need to use protein size parameters here. 

#if { $argc != 2 } {
#    puts "Usage: buildWatBox.tcl protein.psf and protein.pdb"
#}

set protein_psf 6LYZ_autopsf.psf
set protein_pdb 6LYZ_autopsf.pdb

#puts "$protein_psf"
#puts "$protein_pdb"

set padding 20.0

#mol load psf $protein_psf pdb $protein_pdb

set all [atomselect top "all"]

#Measure min-max of box. 
set vecs [measure minmax $all]
#This returns two lists: One coordinates of min and the other coordinates of max. 

set vec0 [lindex $vecs 0]
set vec1 [lindex $vecs 1]

set xMin [expr ([lindex $vec0 0] - $padding)]
set yMin [expr ([lindex $vec0 1] - $padding)]
set zMin [expr ([lindex $vec0 2] - $padding)]

set xMax [expr ([lindex $vec1 0] + $padding)]
set yMax [expr ([lindex $vec1 1] + $padding)]
set zMax [expr ([lindex $vec1 2] + $padding)]

set min "$xMin $yMin $zMin"
set max "$xMax $yMax $zMax"
set minmax [list $min $max]

package require solvate

#solvate -o wb_only -s WT -minmax $minmax -x 0 -y 0 -z 0 +x 0 +y 0 +z 0 -b 2.4
solvate $protein_psf $protein_pdb -o prot_in_wb_only -s WT -minmax $minmax -x 0 -y 0 -z 0 +x 0 +y 0 +z 0 -b 2.4

exit