#!/usr/bin/tclsh
#Purpose: To rebuild Saddle Point Path frames produced with only backbone atoms by using vmd. 
#Author: Mustafa Tekpinar
#Date: 31 October 2011
proc  produceChains {} {
    set  sel [atomselect top "chain A"]
    $sel writepdb chn0.pdb
    $sel delete
    set  sel [atomselect top "chain A"]
    $sel writepdb chn0.pdb
    $sel delete

}


set HOME /user/tekpinar
set thickness 7.0
set frm_begin 0
set frm_end   50
set i 0
set numberofchains 4
set frame_name frm

set filename ${frame_name}${i}.pdb
mol load pdb $filename 
produceChains
mol delete top


exit