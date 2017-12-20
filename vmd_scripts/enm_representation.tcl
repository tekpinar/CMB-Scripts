#!/usr/bin/env tclsh
#Purpose: To draw Elastic Network Model(ENM) representation for proteins.
#Author: Mustafa Tekpinar
#Email : tekpinar@buffalo.edu

if { $argc != 3 } {
    puts "Usage: vmd -e enm_representation.tcl -args file.pdb outfile.dat 10.0"
    exit -1
} else {
    set pdb_file [lindex $argv 0]
    puts "pdb file: [lindex $argv 0]"
    set out_file [lindex $argv 1] 
    puts "out file: [lindex $argv 1]"
    set R_c [lindex $argv 2] 
    puts "Cutoff radius: [lindex $argv 2]"
}

mol new $pdb_file waitfor all

#Select a CPK representation of CA atoms.
menu graphics off
menu graphics on
mol modselect 0 0 name CA
mol modstyle 0 0 CPK 1.000000 0.300000 10.000000 10.000000
menu graphics off

#R_c = Cutoff radius
#set R_c 10.0
set ca_atoms [atomselect top "name CA"]
set total_ca [$ca_atoms num]
puts "Total number of CA atoms are $total_ca"

set allca [$ca_atoms get {x y z}]
set file [open $out_file w]
for { set i 0 } { $i < $total_ca } { incr i } {
    set coord1 [lindex $allca $i]
    set contact_count 0
    for { set j 0 } { $j < $total_ca} { incr j } {
	set coord2 [lindex $allca $j]
	set dist [veclength [vecsub $coord1 $coord2]]
	if {($dist <= $R_c)&&($i!=$j)} {
	    if {[expr ($i-$j)]==1 } {
		draw material Glossy
		draw color red
		draw cylinder $coord1 $coord2 radius 0.2
	    } else {
		draw material Transparent
		draw color yellow
		draw cylinder $coord1 $coord2 radius 0.1
	    }
	incr contact_count
	}


    }

    puts $file "[expr $i+1]\t$contact_count"
}

close $file