###!/usr/bin/env tclsh
set file [open "myoutput.dat" w]
for {set x 0} {$x <= 504} {incr x} {  
    set sel [atomselect top "water and noh within 10.0 of protein" frame $x]
    set result [$sel num]
    puts $file "$x    $result"
}
close $file