#!/usr/bin/perl -w
use strict;

#Purpose: To investigate a bunch of trajectories with VMD command line calls. 

my  @list_r2_2_t=( "prod_cMD_1.dcd",
		   "prod_aMD_1.dcd",
		   "prod_aMD_2.dcd",
		   "prod_aMD_3.dcd",
		   "prod_aMD_4.dcd",
		   "prod_aMD_5.dcd",
		   "prod_aMD_6.dcd",
		   "prod_aMD_7.dcd",
		   "prod_aMD_3100.dcd",
		   "prod_aMD_3000.dcd",
		   "prod_aMD_8.dcd",
		   "prod_aMD_9.dcd",
		   "prod_aMD_10.dcd",
		   "prod_aMD_11.dcd",
		   "prod_aMD_12.dcd");

my $workdir="/panasas/scratch/tekpinar/hemoglobin/R2-T_transition";
my $traj_psf="${workdir}/build/ionized.psf";

my $pdb_name="1ird_full"; #This is R structure!
my $target_pdb="${pdb_name}.pdb";
#foreach (@list_r2_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my $data_file="rmsd_to_r2_2_r_${pdb_name}_"."$_".".dat";
#    set file [open "$data_file" w]
#    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
#}

#$pdb_name="1yzi"; #This is R3 structure!
#$target_pdb="${pdb_name}.pdb";
#foreach (@list_r2_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my $data_file="rmsd_to_r2_2_r3_${pdb_name}_"."$_".".dat";
#    set file [open "$data_file" w]
#    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
#}

#my @list_r1_2_t=("prod.dcd", 
#		 "prod_aMD_2.dcd",
#		 "prod_aMD_1.dcd",
#		 "prod_aMD_3.dcd",
#		 "prod_aMD_4.dcd",
#		 "prod_aMD_5.dcd");

#$workdir="/panasas/scratch/tekpinar/hemoglobin/R1-T_transition";
#$traj_psf="${workdir}/build/ionized.psf";

#$pdb_name="1bbb"; #This is R2 structure!
#$target_pdb="${pdb_name}.pdb";
#foreach (@list_r1_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my $data_file="rmsd_to_r_2_r2_${pdb_name}_"."$_".".dat";
##    set file [open "$data_file" w]
#    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
#}

#$pdb_name="1yzi"; #This is R3 structure!
#$target_pdb="${pdb_name}.pdb";
#foreach (@list_r1_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my $data_file="rmsd_to_r_2_r3_${pdb_name}_"."$_".".dat";
##    set file [open "$data_file" w]
#    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
#}


my  @list_t_2_r=("prod_cMD_t2r_trj2",
		 "prod_aMD_t2r_trj1",
		 "prod_aMD_t2r_trj2",
		 "prod_aMD_t2r_trj3",
		 "prod_aMD_t2r_trj4",
		 "prod_aMD_t2r_trj6",
		 "prod_aMD_t2r_trj5_cont",
		 "prod_aMD_t2r_trj7",
		 "prod_aMD_t2r_trj8",
		 "prod_aMD_t2r_trj9",
		 "prod_aMD_t2r_trj10",
		 "prod_aMD_t2r_trj11",
		 "prod_aMD_t2r_trj12",
		 "prod_aMD_t2r_trj13",
		 "prod_aMD_t2r_trj14");

$workdir="/panasas/scratch/tekpinar/hemoglobin/MD/T-R_transition";
$traj_psf="${workdir}/build/ionized.psf";

$pdb_name="1bbb"; #This is R2 structure!
$target_pdb="${pdb_name}.pdb";
foreach (@list_t_2_r) {
    my $traj_dcd="${workdir}/production/"."$_".".dcd";
    my $data_file="rmsd_to_${pdb_name}_"."$_".".dat";
#    set file [open "$data_file" w]
    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
}
