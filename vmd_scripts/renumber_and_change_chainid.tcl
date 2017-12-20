#!/usr/bin/env tclsh

#Purpose: To renumber residues and change chain id of camkii
#Author : Mustafa Tekpinar
#Date   : July 31, 2015
#Licence: LGPL v3
#Email  :tekpinar@buffalo.edu

if { $argc != 6 } {
    puts "Usage: vmd -dispdev text -e script_name.tcl -args chainid  shift prot.pdb prot_modified.pdb"
    exit -1
} else {
    set chainid [lindex $argv 0]
    puts "Chain ID: [lindex $argv 0]"

    set shift [lindex $argv 1]
    puts "Shift: [lindex $argv 1]"

    set pdb_file [lindex $argv 2]
    puts "pdb file: [lindex $argv 2]"

    set outfile [lindex $argv 3]
    puts "Results file: [lindex $argv 3]"
}

# load psf-dcd
mol new ${pdb_file} waitfor all

# we specify the value to shift each residue
#set chainid A
#set outfile "3soa_model1_test.pdb"
#set shift 6
# we define an empty list to hold the shifted resids
set newNumbering {}

# we get an selection of all atoms in the residues
# that we want to shift
set mySelection [atomselect top all]

# we pull out the list of resids
set oldNumbering [$mySelection get resid]

# we loop over this list and shift each value
# and store the result in $newNumbering
foreach resid $oldNumbering {
  lappend newNumbering [expr {$resid + $shift}]
}
# finally we assign the list with the shifted resids
# to our selection
$mySelection set resid $newNumbering
$mySelection set chain $chainid
$mySelection writepdb ${outfile}
