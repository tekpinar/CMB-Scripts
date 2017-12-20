#!/usr/bin/env tclsh

#for {set i 4} {$i <=10} {incr i} {

set file [open "prot_in_wb_1stShell_fix_n0.dat" w]
for {set x 0} {$x < 500} {incr x} {  
    # set sel [atomselect top "protein" frame $x]
#    set sel [atomselect top "(water and noh within 10.5 of alpha) and not (water and noh within 3.5 of alpha)"]
#    set sel [atomselect top "(water and noh within 3.0 of protein)" frame $x]
    set sel [atomselect top "(water and noh within 6.5 of protein) and not (water and noh within 3.5 of protein)" frame $x]
    set number [$sel num]
    puts $file "$x    $number"
}
#    puts [exec mv 6lyz_wat_count.dat 6lyz_wat_count_${i}A.dat]
close $file
#}
exit