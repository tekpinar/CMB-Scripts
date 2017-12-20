#!/usr/bin/env tclsh

#Purpose: To make a custom made solvate script and to measure number of waters in the shell.
package require solvate
solvate 6LYZ_autopsf.psf 6LYZ_autopsf.pdb -o prot_in_wb_only0p9 -s WT -minmax {{-38.9740009308 -14.9400000572 -22.3020000458} {39.9899997711 58.9339981079 61.5480003357}} -x 0 -y 0 -z 0 +x 0 +y 0 +z 0 -b 0.9
