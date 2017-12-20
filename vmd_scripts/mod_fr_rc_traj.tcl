# Prints the RMSD of the protein atoms between each timestep
# and the first timestep for the given molecule id (default: top)
# use frame 0 for the reference

if { $argc != 6 } {
    puts "Usage: vmd -dispdev text -e mod_fr_rc_traj.tcl -args beg.pdb end.pdb trj.psf trj.dcd results.dat"
    exit -1
} else {
    set beg_pdb [lindex $argv 0]
    puts "Beginning pdb file: [lindex $argv 0]"

    set end_pdb [lindex $argv 1]
    puts "End pdb file: [lindex $argv 1]"

    set traj_psf [lindex $argv 2]
    puts "psf file: [lindex $argv 2]"

    set traj_dcd [lindex $argv 3]
    puts "dcd file: [lindex $argv 3]"
    
    set outfile [lindex $argv 4]
    puts "Results file: [lindex $argv 4]"
}

#set workdir /panasas/scratch/tekpinar/hemoglobin/R2-T_transition
#set traj_psf  ${workdir}/build/ionized.psf
#set trj_no 1
#set traj_dcd  ${workdir}/production/prod_aMD_${trj_no}.dcd
#set outfile "mod_fr_rc_aMD_r2_2_t_${trj_no}_.dat"
mol new ${beg_pdb}

#set 3kqk_domain1 "((resid 189 to 326) and name CA)"
#set 3kqk_domain2 "(((resid 327 to 430) and name CA) or  ((resid 452 to 483) and name CA))"
#Keep in mind for domain 3, it can include 625th residue!
#set 3kqk_domain3 "(((resid 431 to 451) and name CA) or  ((resid 484 to 624) and name CA))"

set select1 "protein and alpha"
#set select1 "${3kqk_domain2} or ${3kqk_domain3}"
#It is a silly error but psf-dcd pair doesnt recognize chain names even though
#there is chain information in files!
#Therefore, I use segment names which I tested to work!
#set select2 "${3kqk_domain2} or ${3kqk_domain3}"
set select2 "protein and alpha"

#No need to touch anything after this point!
set initial [atomselect 0 "${select1}"]

mol new ${end_pdb}
set final [atomselect 1 "${select1}"]

puts "Number of initial selected residues = [$initial num]"
puts "Number of final selected residues = [$final num]"

# always second selection is reference
set trans_mat0 [measure fit  $final $initial]
# do the alignment
$final move $trans_mat0
set rmsd_beg2end [measure rmsd $final $initial]

puts "RMSD is $rmsd_beg2end."

# load psf-dcd
mol new ${traj_psf} waitfor all
mol addfile ${traj_dcd} waitfor all

# the frame being compared
set comp_cur [atomselect 2 "${select2}"]
#set comp_pre $comp_cur
set comp_pre [atomselect 2 "${select2}"]

set num_steps [molinfo 2 get numframes]
set file [open "${outfile}" w]

set rmsd_temp_sum 0.0
set rmsd_full_sum 0.0

for {set frame 0} {$frame < $num_steps} {incr frame} {
    if {$frame !=0} {
	# get the correct frame
	$comp_cur frame $frame
	
	$comp_pre frame [expr ($frame-1)] 
	# compute the transformation
	set trans_mat1 [measure fit $comp_pre $comp_cur ]
	# do the alignment
	$comp_pre move $trans_mat1
	
	# compute the RMSD
	set rmsd2pre [measure rmsd $comp_pre $comp_cur ]
	set rmsd_full_sum [expr ($rmsd_full_sum + $rmsd2pre)]
    }
}

#add the last frame
$comp_pre frame [expr ($num_steps-1)] 
# compute the transformation
set trans_mat1 [measure fit $comp_pre $final ]
# do the alignment
$comp_pre move $trans_mat1

# compute the RMSD
set rmsd2pre [measure rmsd $comp_pre $final ]
set rmsd_full_sum [expr ($rmsd_full_sum + $rmsd2pre)]

set rmsd2pre 0.0

puts "RMSD full sum is $rmsd_full_sum!"

for {set frame 0} {$frame < $num_steps} {incr frame} {
    if {$frame !=0} {
	# get the current frame
	$comp_cur frame $frame

	# get the previous frame
	$comp_pre frame [expr ($frame-1)] 
	# compute the transformation
	set trans_mat2 [measure fit $comp_pre $comp_cur]
	# do the alignment
	$comp_pre move $trans_mat2

	# compute the RMSD
	set rmsd2pre [measure rmsd $comp_pre $comp_cur ]
	set rmsd_temp_sum [expr ($rmsd_temp_sum + $rmsd2pre)]
#	puts "$rmsd_temp_sum"


	# compute the transformation
	set trans_mat3 [measure fit $initial $comp_cur ]
	# do the alignment
	$initial move $trans_mat3
	
	# compute the RMSD
	set rmsd2beg [measure rmsd $initial $comp_cur ]
	#    puts "$rmsd2beg"
	
	# compute the transformation
	set trans_mat4 [measure fit $final $comp_cur ]
	# do the alignment
	$final move $trans_mat4
	
	# compute the RMSD
	set rmsd2end [measure rmsd $final $comp_cur ]
	#    puts "$rmsd2end"
	
	puts $file "$frame \t[expr ($rmsd_temp_sum/$rmsd_full_sum)]\t[expr (($rmsd2beg-$rmsd2end)/$rmsd_beg2end)]"
    }
}
close $file
exit