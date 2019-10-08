#!/usr/bin/env tclsh

#Do it for without BTT
################################################################################################################
mol new npt-wout-pbc.gro type gro first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
#mol addfile octWoutBTTprod-sim1-pbc.xtc type xtc first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all

set sel [atomselect top "protein and name CA and within 5 of nucleic"]
set selectedAtomsList [$sel list]
set selectedAtomsString [regsub -all {\s+} $selectedAtomsList "|a "]
set finalString [concat "a " $selectedAtomsString]

puts "$finalString"
set myShellCommand "gmx make_ndx -f npt-wout-pbc.gro -o npt-wout-pbc.ndx<<EOF
$finalString
q
EOF"

exec sh -c $myShellCommand
mol delete all
#Do it for without BTT
#################################################################################################################


mol new npt-with-pbc.gro type gro first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
#mol addfile octWithBTTprod-sim1-pbc.xtc type xtc first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all

set sel [atomselect top "protein and name CA and within 5 of nucleic"]
set selectedAtomsList [$sel list]
set selectedAtomsString [regsub -all {\s+} $selectedAtomsList "|a "]
set finalString [concat "a " $selectedAtomsString]

puts "$finalString"
set myShellCommand "gmx make_ndx -f npt-with-pbc.gro -o npt-with-pbc.ndx<<EOF
$finalString
q
EOF"

exec sh -c $myShellCommand
exit
