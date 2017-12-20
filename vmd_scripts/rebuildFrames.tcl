#!/usr/bin/env tclsh
#Purpose: To rebuild Saddle Point Path frames produced with only backbone atoms by using vmd. 
#Author: Mustafa Tekpinar
#Date: 31 October 2011
set HOME /user/tekpinar
set thickness 7.0

set frame_name frm
set frm_begin 0
set frm_end   50
set i 10
#for { set i $frm_begin } { $i <= $frm_end } { incr i } {
    mol load pdb ${frame_name}${i}.pdb 
    set prot [atomselect top protein]
    set chains [lsort -unique [$prot get pfrag]]
    foreach chain $chains {
	set sel [atomselect top "pfrag $chain"]
	#Write each chain to a different file.
	$sel writepdb chn${chain}.pdb
	# Load psfgen package
	package require psfgen
	
	resetpsf
	# Read topology file
	topology $HOME/toppar/top_all22_prot.inp
	pdbalias residue HIS HSD
	pdbalias atom ILE CD1 CD
	segment ${chain} {pdb chn${chain}.pdb}
	coordpdb chn${chain}.pdb ${chain}
	guesscoord
	writepdb chn${chain}_autopsf.pdb
	writepsf chn${chain}_autopsf.psf
    }
    resetpsf
    foreach chain $chains {
	# Read in structure files
	readpsf chn${chain}_autopsf.psf
	# Read in coordinates
	coordpdb chn${chain}_autopsf.pdb
    }
    
    #Combine all chains of the frame.
    writepsf ${frame_name}${i}_autopsf.psf
    writepdb ${frame_name}${i}_autopsf.pdb
    resetpsf
    
    mol delete all
    
    #Delete all intermediate files
    foreach chain $chains {
	exec rm chn${chain}.pdb
	exec rm chn${chain}_autopsf.psf
	exec rm chn${chain}_autopsf.pdb
    }
    
    resetpsf
    package require solvate
    solvate ${frame_name}${i}_autopsf.psf ${frame_name}${i}_autopsf.pdb -t 12 -o ${frame_name}${i}_box
    mol delete all
    mol load pdb ${frame_name}${i}_box.pdb
    set sel [atomselect top "(same residue as (name OH2 and within $thickness of (not water))) or (not water)"] 
    $sel writepdb ${frame_name}${i}_shell.pdb
    mol delete all
    exec rm combine.psf
    exec rm combine.pdb
    exec rm ${frame_name}${i}_box.psf
    exec rm ${frame_name}${i}_box.pdb
    exec rm ${frame_name}${i}_box.log
    exec rm ${frame_name}${i}_autopsf.psf
#}
exit