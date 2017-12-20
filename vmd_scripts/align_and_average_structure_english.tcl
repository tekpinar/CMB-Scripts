#	Scritpt by Gonzalo Riadi at the
#	Centre for Bioinformatics and Molecular Simulacion
#	University of Talca


#********************************************************************************
#********************************   Variables    ********************************
#********************************************************************************

# The variables that can be changed are:

# $seltext is the selection of atoms that will undergo the average structure calculation.
# By default it's "all and not (waters or lipids or ions)"

# $mol is top by default. It can be changed if there's more than one molecule loaded

# $frame_start and $frame_end are the frames at start and end, respectivelly, for the
# average calculation take place. By default they are 0(first) and numsteps(last)
# of the .dcd.

# $frame_reference is the frame that will be the reference for the alignment.
# In the future, it would be great to calculate the RMSD taking the average structure as 
# the reference. By default its 0 but any frame may be chosen.

# The average calculation takes the coordinates of every atom in the $seltext every $stride
# frames. By default it's 1, which means that every frame in the .dcd is taken for 
# calculations. 2 would make the program take every other frame for calculations and so on.
# If you have a large simulation take $stride as 2 would diminish the calculation time to
# the half.

	set seltext "all and not (waters or lipids or ions)"
#	set seltext "anything you want"
	set mol top;
	set stride 1;
#Default	set frame_start 0;
        set frame_start 4500;
	set num_steps [molinfo $mol get numframes]
#Default	set frame_end $num_steps;
	set frame_end 4750;
	set frame_reference 4500;

# No further changes are needed.

#*********************************************************************************
#*****************************   Aligning Selection   ****************************
#*********************************************************************************

	set sel [atomselect $mol "$seltext"];
	# use frame 0 for the reference
	set reference [atomselect $mol "$seltext" frame $frame_reference]
	# the frame being compared
	set compare [atomselect $mol "$seltext"]
	set all [atomselect $mol all]

	for {set frame $frame_start} {$frame < $frame_end} {} {
		# get the correct frame
		$compare frame $frame
		$all frame $frame
		# compute the transformation
		set trans_mat [measure fit $compare $reference]
		# do the alignment
		$all move $trans_mat
		# compute the RMSD
		set rmsd [measure rmsd $compare $reference]
		puts "$frame $rmsd"
		set frame [expr $frame + $stride];
	}
	display update


#*********************************************************************************
#**********************   Average Structure Calculation   ************************
#*********************************************************************************

	set frame 0;
	# first I initialize the list of index of the $seltext atoms
	set indices 0;
	# then I remove the only element in it. So the atom index will actually start the list. 
	lvarpop indices;
	# just initializing the final $newcoords variable.
	set newcoords 0;
	# and removing the only element in it.
	lvarpop newcoords;
	# setting the number of steps taken for the average calculus
	set num_steps2 [expr (($frame_end - $frame_start) / $stride) + 1]
	puts "The number of steps is $num_steps2"
 	# setting the inverse of the number of steps
	set inv_num_steps [expr 1.0 / $num_steps2]

#	Makes a list with the index of $seltext
	# Put all the index in the indices list
	set indices [$sel get index];
	# two nested for loops for summing the first for every atom, the second for every frame
	# the vector suma adds all coordinates along the chosen frames and then it is scaled ...
	foreach indice $indices {
		set suma [veczero];
		puts "Index is $indice";
		for {set frame $frame_start} {$frame < $frame_end} {} {
			set seli [atomselect $mol "index $indice" frame $frame];
			set coord [$seli get {x y z}];
			foreach pieza $coord {
#				puts "The coordinates are $coord en frame $frame";
				set suma [vecadd $suma $pieza];
			}
			set frame [expr $frame + $stride];
			$seli delete;
		}
		# ...by the inverse of the number of frames obtaining the average coordinate for each atom
		set resul [vecscale $inv_num_steps $suma];
		lappend newcoords $resul;
		# Just for verification largo, the lenght of $newcoords, is set. 
#		set largo [llength $newcoords];
#		puts "The number of atoms is $largo";
	}
	set frame 0;
	# I make a selection of the average coordinates to save them in a .pdb 
	$sel set {x y z} $newcoords;
	$sel writepdb average_selection.pdb
	display update;