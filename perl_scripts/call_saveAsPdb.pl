#!/usr/bin/perl -w
use strict;
use File::Basename;

#Purpose: To investigate a bunch of trajectories with VMD command line calls. 


#my  @list_r2_2_t=( "prod_cMD_1.dcd",
#		   "prod_aMD_1.dcd",
#		   "prod_aMD_2.dcd",
#		   "prod_aMD_3.dcd",
#		   "prod_aMD_4.dcd",
#		   "prod_aMD_5.dcd",
#		   "prod_aMD_6.dcd",
#		   "prod_aMD_7.dcd",
#		   "prod_aMD_8.dcd",
#		   "prod_aMD_9.dcd",
#		   "prod_aMD_11.dcd",
#		   "prod_aMD_12.dcd",
#		   "prod_aMD_13.dcd");

#my $workdir="/panasas/scratch/tekpinar/hemoglobin/R2-T_transition";
#my $traj_psf="${workdir}/build/ionized.psf";

#foreach (@list_r2_2_t) {
#    my $traj_dcd="${workdir}/production/"."$_";
#    my ($name,$path,$suffix) = fileparse ( $_, qr{\..*}); 
#    my $pdb_file="$name".".pdb";
#    system("vmd -dispdev text -e saveAsPdb.tcl -args ${traj_psf} ${traj_dcd} ${pdb_file}");
#    for (my $i=0; $i<10; $i++)
#    {
#    system("cat temp*.pdb>> ${pdb_file}");
#    }
#    system("rm -rf temp*.pdb");
#
#}

#my @list_r1_2_t=("prod.dcd", 
#		 "prod_aMD_2.dcd",
#		 "prod_aMD_1.dcd",
#		 "prod_aMD_3.dcd",
#		 "prod_aMD_4.dcd",
#		 "prod_aMD_5.dcd");

my @list_t2r=("prod_cMD_t2r_nvt_trj1_pro.dcd",
	      "prod_aMD_t2r_nvt_trj7_pro.dcd",
	      "prod_cMD_t2r_nvt_trj1.dcd",
	      "prod_aMD_t2r_nvt_trj1.dcd",
	      "prod_aMD_t2r_nvt_trj2.dcd",
	      "prod_aMD_t2r_nvt_trj3.dcd",
	      "prod_aMD_t2r_nvt_trj4.dcd",
	      "prod_aMD_t2r_nvt_trj5.dcd",
	      "prod_aMD_t2r_nvt_trj6.dcd",
	      "prod_aMD_t2r_nvt_trj7.dcd");
#	      "prod_cMD_t2r_trj2_no_wat_ions.dcd");



my $workdir="/panasas/scratch/tekpinar/hemoglobin/MD/T-R_transition";
my $traj_psf="${workdir}/production/t2r_ionized.psf";

my $catdcd_path="/util/vmd/v1.9/lib/vmd/plugins/LINUXAMD64/bin/catdcd4.0";
my $index_file="findexfile.ind";




foreach (@list_t2r) 
{
    my $traj_dcd="${workdir}/production/"."$_";
    my ($name,$path,$suffix) = fileparse ( $_, qr{\..*}); 
    my $pdb_file="$name"."_no_wat_ion.pdb";
    system("${catdcd_path}/catdcd -o ${name}_no_wat_ion.dcd -i ${index_file} $traj_dcd");

#Prototype for writing a psf-dcd pair to pdb file format by using catdcd utility:
#catdcd -o prot.pdb -otype pdb -s prot.psf -stype psf prot.dcd

  system("${catdcd_path}/catdcd -o ${name}_no_wat_ion.pdb -otype pdb -stride 100 -s $traj_psf -stype psf ${name}_no_wat_ion.dcd");

#    system("vmd -dispdev text -e saveAsPdb.tcl -args ${traj_psf} ${traj_dcd} ${pdb_file}");
#    for (my $i=0; $i<100; $i++)
#    {
#	system("cat temp*.pdb>> ${pdb_file}");
#    }
#    system("rm -rf temp*.pdb");
}

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
