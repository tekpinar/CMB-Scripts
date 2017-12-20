#!/usr/bin/perl -w
use strict;
use File::Basename;

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

my $pdb_beg_name="1bbb"; 
my $pdb_end_name="2hhb"; 

my $beg_pdb="${pdb_beg_name}.pdb";
my $end_pdb="${pdb_end_name}.pdb";
my $plt_file_name="mod_fr_rc_r2_2_t_overall_trj.plt";
open PLT_FILE, ">", "${plt_file_name}" or die "${plt_file_name} file can not be produced!";
print PLT_FILE "set xlabel \"Time Step\" \n";
print PLT_FILE "set ylabel \"Reaction Coordinate\" \n";
print PLT_FILE "set yrange [-1.0:1.0]\n";
print PLT_FILE "set grid\n";
print PLT_FILE "plot ";
my $i=0;
foreach (@list_r2_2_t) {
    my $traj_dcd="${workdir}/production/"."$_";
    my ($name,$path,$suffix) = fileparse ( $_, qr{\..*}); 
    my $data_file="mod_fr_rc_r2_2_t_"."$name"."_overall.dat";
    system("vmd -dispdev text -e mod_fr_rc_traj.tcl -args ${beg_pdb} ${end_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
    if($i==0)
    {
	print PLT_FILE "plot \"$data_file\" u 1:3\n";
    }
    else
    {
    	print PLT_FILE "replot \"$data_file\" u 1:3\n";
    }
    $i++;
}
close (PLT_FILE);

#my $pdb_name="1yzi"; #This is R3 structure!
#my $target_pdb="${pdb_name}.pdb";
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

#my $workdir="/panasas/scratch/tekpinar/hemoglobin/R1-T_transition";
#my $traj_psf="${workdir}/build/ionized.psf";

#my $pdb_name="1bbb"; #This is R2 structure!
#my $target_pdb="${pdb_name}.pdb";
#foreach (@list_r1_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my $data_file="rmsd_to_r_2_r2_${pdb_name}_"."$_".".dat";
#    set file [open "$data_file" w]
#    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
#}

#my $pdb_name="1yzi"; #This is R3 structure!
#my $target_pdb="${pdb_name}.pdb";
#foreach (@list_r1_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my $data_file="rmsd_to_r_2_r3_${pdb_name}_"."$_".".dat";
#    set file [open "$data_file" w]
#    system("vmd -dispdev text -e rmsd_traj.tcl -args ${target_pdb} ${traj_psf} ${traj_dcd} ${data_file}");
#}
