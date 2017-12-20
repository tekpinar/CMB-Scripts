#!/usr/bin/perl -w
# Generate postscript and png plot with GNUplot from Perl
# Author: Ioan Vancea
# Usage: Give "data file" as an argument for script
 
use strict;
use PDL;
#use warnings;
 
my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
# POSTSCRIPT
open (GNUPLOT, "|gnuplot");
print GNUPLOT <<EOPLOT;
set term postscript enhanced color
set output "${file1}_${file2}.ps"
plot "$file1" using 3:1 w lines 1, "$file2" using 3:1 w lines 1
    
EOPLOT
    close(GNUPLOT);
 
