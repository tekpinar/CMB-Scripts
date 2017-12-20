# load trajectory and rewind
#mol new iENM_path_comp.pdb type pdb waitfor all

mol new 32h2o_h3op.xyz type xyz waitfor all
mol addfile 32h2o_h3op.dcd type dcd waitfor all
animate goto 0
set mol [molinfo top]

draw_cubic_unitcell 9.96


puts "create visualization"
mol delrep 0 top
mol representation VDW 0.1250000 20.000000
mol color Name
mol selection {not name X}
mol material Opaque
mol addrep top
mol representation DynamicBonds 1.300000 0.067700000 6.000000
mol addrep top

mol representation HBonds 3.000000 30.000000 3.000000
mol color ColorID 8
mol addrep top

mol representation VDW 0.30000 20.000000
mol color ColorID 4
mol selection {name O and user > 2}
mol material Transparent
mol addrep top
mol selupdate 3 $mol on

mol selection {all}
mol color Name
mol material Opaque

mol rename top {32 H2O + 1 H3O+}

puts "calculate number of bonded hydrogens and store in user field"
#######
# prep
set num [molinfo $mol get numframes]
set ox  [atomselect $mol {name O}]
set all [atomselect $mol {name H O}]

# create a selection for each oxygen atom
foreach i [$ox get index] {
    set sel($i) [atomselect $mol "name H and exwithin 1.30 of index $i"]
}

# loop over all frames and oxygens and 
# store the number of hydrogens in user
for {set n 0} {$n < $num} {incr n} {
    set bc {}
    foreach i [$ox get index] {
        $sel($i) frame $n
        $sel($i) update
        $all frame $n
        $all set user 0
        lappend bc [$sel($i) num]
    }
    $ox frame $n
    $ox set user $bc
    unset bc
}

# clean up selections
foreach i [$ox get index] {
    $sel($i) delete
}
$ox delete
$all delete
unset ox all sel i n

display distance     -2.000000
display projection   Orthographic
display nearclip set 0.001000
display farclip  set 10.000000
display depthcue   off

animate goto 0
#########################################################
# load trajectory and rewind
mol new iENM_path_comp.pdb type pdb waitfor all

animate goto 0
set mol [molinfo top]

puts "create visualization"
mol delrep 0 top
mol representation CPK

#Read data file for each residues normalized distance value 

#Get number of frames

#Assign user data to atom in frame!


