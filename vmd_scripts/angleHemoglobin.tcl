#!/usr/bin/env tclsh


#Purpose: To measure the angular change between a1b1 dimer vs a2b2 dimer. 
proc vmd_draw_arrow {mol start end} {
# an arrow is made of a cylinder and a cone
set middle [vecadd $start [vecscale 0.9 [vecsub $end $start]]]
graphics $mol cylinder $start $middle radius 0.15
graphics $mol cone $middle $end radius 0.25
}

set numframes [molinfo 0 get numframes]

#Measure center of mass for alpha 1
set alpha1 [atomselect top "segname P1"]
$alpha1 num

#Measure center of mass for beta 1
set beta1 [atomselect top "segname P2"]
$beta1 num


#Measure center of mass for alpha 2
set alpha2 [atomselect top "segname P3"]
$alpha2 num

#Measure center of mass for beta 1
set beta2 [atomselect top "segname P4"]
$beta2 num

set file [open "angle_vs_frame_cMD.dat" w]

for {set frame 0} {${frame} < ${numframes}} {incr frame} {
#Define a vector from alpha1 -> beta1
    $alpha1 frame $frame
    set com_alpha1 [measure center ${alpha1} weight mass]

    $beta1 frame $frame
    set com_beta1 [measure center ${beta1} weight mass]

    set diff_vec1 [vecsub $com_alpha1 $com_beta1]

#Define a vector from alpha2 -> beta2
    $alpha2 frame $frame
    set com_alpha2 [measure center ${alpha2} weight mass]

    $beta2 frame $frame
    set com_beta2 [measure center ${beta2} weight mass]
    
    set diff_vec2 [vecsub $com_alpha2 $com_beta2]

#    draw arrow $com_alpha1 $com_beta1
#    draw arrow $com_alpha2 $com_beta2

    set norm1 [veclength $diff_vec1]
#    put $norm1
    set norm2 [veclength $diff_vec2] 
#    put $norm2
    set norm1Xnorm2 [expr $norm1*$norm2]

    set norm_v1_dot_v2 [vecdot $diff_vec1 $diff_vec2]
#    put $norm_v1_dot_v2
    set angle [expr 180*acos($norm_v1_dot_v2/$norm1Xnorm2)/acos(-1.0)]
#    set new_fr [expr ($frame*2)]
#    puts $file "$new_fr\t$angle"
    puts $file "$frame\t$angle"
}
close $file
#put $com_alpha1
#put $com_beta1
#put $diff_vec1

#put $com_alpha2
#put $com_beta2
#put $diff_vec2


$alpha1 delete 
$beta1 delete 
$alpha2 delete 
$beta2 delete 
exit