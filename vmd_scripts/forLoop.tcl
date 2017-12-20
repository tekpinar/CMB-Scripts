#
set i 100
set j 2

#for { set i 10 } { $i <= 99 } { incr i } {

mol new x000 type pdb 
mol representation CPK
set sel [atomselect 0 all]
$sel set user [$sel get beta] 

mol new x126 type pdb 
mol representation CPK
set sel [atomselect 1 all]
$sel set user [$sel get beta] 


#mol delete top

#}