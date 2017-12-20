#!/usr/bin/env python
#Purpose: Saving dcd files as pdb

import os
import glob

#These folders have large dcd trajectories inside.
#folders=["3kql",
#         "tMD/3kqu_closed_to_3kqk_open",
#         "tMD/3kqk_open_to_3kqn_closed",
#         "aMD",
#         "cMD",
#         "cMD2"]

folders=["tMD/3kqk_open_to_3kqn_closed"]

workdir="/panasas/scratch/tekpinar/ns3_helicase/"
traj_psf="build/ionized.psf"

stride=100
for path in folders:
    full_path=workdir+path

    os.chdir(full_path)
    print 'Current directory: %s' %full_path
    prod_dcd_list=glob.glob('production/*.dcd')

    os.system("rm -vf equillibration/equil.dcd")

    for traj_dcd in prod_dcd_list:
        print  '%s'%traj_dcd
        out_file=os.path.splitext(traj_dcd)[0]
        out_file=out_file+".pdb"
        command="vmd -dispdev text -e ~/vmd_scripts/saveDcd2Pdb.tcl -args "+traj_psf+" "+traj_dcd+" "+out_file+" "+str(stride)
        print "Running command:\n%s" %command
        ret_val=os.system(command)
        print "Return value: %d" %ret_val
        remove_command="rm -vf "+traj_dcd
        os.system(remove_command)
