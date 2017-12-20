#Purpose: Combine R2 structure with a bunch of random CO2 molecules in environment
#         I hope to see that increase of CO2 in environment will make R2->T transition easier. 
package require psfgen
resetpsf

set prt 1bbb
set protein ${prt}_co_rmvd_autopsf
set ligand co2_autopsf

readpsf ${protein}.psf
readpsf ${ligand}.psf

coordpdb ${protein}.pdb
coordpdb ${ligand}.pdb

writepsf ${prt}_${ligand}.psf
writepdb ${prt}_${ligand}.pdb

puts "HE TERMINADO!!!!"

quit 