# load multi-frame pdb file, storing B factors from each frame in user.
# usage: pdbbfactor <filename>
#
# Justin Gullingsrud
# 3 September 2004

proc pdbbfactor { fname } {
    mol new $fname waitfor all
#    mol delrep 0 top
    mol representation Tube
    puts "Opened pdb file: $fname"
    set all [atomselect top all]
    puts "Selected [$all num] atoms!"
    set frame 0
    set in [open $fname r]
    set beta {}
    while { [gets $in line] != -1 } {
	switch -- [string range $line 0 3] {
	    ENDM {
		$all frame $frame
		$all set user $beta
		set beta {}
		incr frame
	    }
	    ATOM -
	    HETA {
		lappend beta [string range $line 60 65]
	    }
	}
    }
    mol color User
}

