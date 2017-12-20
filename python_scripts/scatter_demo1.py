#!/usr/bin/python
#Purpose  : To plot time development of principal components 1 and 2. 
#Author   : Mustafa Tekpinar
#Email    : tekpinar@buffalo.edu
#Copyright: Mustafa Tekpinar - 2014
#Major Revision Date     : July 3, 2014

import matplotlib.pyplot as plt

###########################################
opts, args = getopt.getopt(sys.argv[1:],"ht:e:o:",["theo=","exp=", "out="])
print opts
print args
theo_file = None
exp_file = None
out_file = None

try:
    opts, args = getopt.getopt(sys.argv[1:],"ht:e:o:",["theo=","exp=", "out="])
except getopt.GetoptError:
    usage()
for opt, arg in opts:
    if opt == '-h':
        usage()        
    elif opt in ("-t", "--theo"):
        theo_file = arg
    elif opt in ("-e", "--exp"):
        exp_file = arg
    elif opt in ("-o", "--out"):
        out_file = arg
    else:
        assert False, usage()

if theo_file==None or exp_file==None or out_file==None:
    usage()

print 'Theoretical beta factor file is ', theo_file
print 'Experimental beta factor file is ', exp_file
print 'All results will be in ', out_file



MD_FILE=open("ake_vec1_vec2_md.txt", 'r')
md_lines=MD_FILE.readlines()
md_columns=[]
md_pc1=[]
md_pc2=[]
md_time_percentage=[]
for line in md_lines:
    md_columns=line.split()
    md_pc1.append(float(md_columns[0]))
    md_pc2.append(float(md_columns[1]))
    md_time_percentage.append(float(md_columns[2]))
MD_FILE.close()

IENM_FILE=open("1and4_ake_ca_exp_pca.dat", 'r')
#IENM_FILE=open("proj_ev1ev2_c_alpha_adk_pca_exp_files2.xvg", 'r')
ienm_lines=IENM_FILE.readlines()
ienm_columns=[]
ienm_pc1=[]
ienm_pc2=[]
ienm_time_percentage=[]
for line in ienm_lines:
    ienm_columns=line.split()
    ienm_pc1.append(float(ienm_columns[0]))
    ienm_pc2.append(float(ienm_columns[1]))
#    ienm_time_percentage.append(float(ienm_columns[2]))
IENM_FILE.close()

plt.subplot()

plt.scatter(md_pc1, md_pc2, marker='o', c=[md_time_percentage], s=10)   
plt.scatter(ienm_pc1, ienm_pc2, marker='*', c=[1.0, 0.0], s=250)   
#plt.scatter(ienm_pc1, ienm_pc2, marker='^', c='b', s=35)   
plt.colorbar()
plt.xlabel('Principal Component 1 (nm)')
plt.ylabel('Principal Component 2 (nm)' )
plt.grid()
#plt.xlim(0, 20)
#plt.ylim(0, 20)
plt.show()

