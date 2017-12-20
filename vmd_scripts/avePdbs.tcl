#!/usr/bin/env tclsh

#Purpose: To get average pdb structures during transition from 
#         T state to R state. 

set numframes [molinfo 0 get numframes]

#Select just protein atoms!
set selStr "not water and not ions"
proc avStruct {selStr start stop fName {molid top}} {
    set sel [atomselect $molid $selStr]
    set avXYZ [measure avpos $sel first $start last $stop]
    set xyzBak [$sel get {x y z}]
    $sel set {x y z} $avXYZ
    $sel writepdb ${fName}.pdb
    $sel set {x y z} $xyzBak
    $sel delete
}


avStruct {$selStr 4500 5000 ave_4500to5000_t2r_trj7.pdb 0}

#for {set i 0} {$i < 1000} {incr i 1} {
#    set fName  t2r_md_frm_1st_2ns_${i}
#    puts "File name is $fName!"
#    set start  [expr $i*20]
#    puts "Beginning frame is  $start!"
#    set stop  [expr (($i+1)*20)-1]
#    puts "Final frame is  $stop!"

#    set sel [atomselect top "protein" frame $i]
#    set avXYZ [measure avpos $sel first $start last $stop]
#    set xyzBak [$sel get {x y z}]
#    $sel set {x y z} $avXYZ
#    $sel writepdb ${fName}.pdb
#    $sel set {x y z} $xyzBak
#    $sel delete
#}

exit