#!/usr/bin/env python
#Purpose  : To plot time development of principal components 1 and 2. 
#Author   : Mustafa Tekpinar
#Email    : tekpinar@buffalo.edu
#Copyright: Mustafa Tekpinar - 2014
#Major Revision Date     : July 3, 2014
import os
import sys
import getopt
import matplotlib.pyplot as plt

def usage():
    print "Usage:"
    print "python pca_plot.py -m md_pca_data.xvg -e exp_pca_data.xvg -t 'CHARMM27-TIP3P' -o test.png"
    print "It is assumed that PCA file is a text file that contain principal"
    print "component 1 and principal component 2 each in a column."
    print "After -t parameter, you write a title string."
    print "After -o parameter, you write output file name."
    sys.exit(-1)

##################### HANDLE ARGUMENTS ##########################################
opts, args = getopt.getopt(sys.argv[1:],"hm:e:t:o:",["md-trj=","exp=", "title=", "out="])
print opts
print args
theo_file = None
exp_file = None
out_file = None
title = None

try:
    opts, args = getopt.getopt(sys.argv[1:],"hm:e:t:o:",["md-trj=","exp=", "title=", "out="])
except getopt.GetoptError:
    usage()
for opt, arg in opts:
    if opt == '-h':
        usage()        
    elif opt in ("-m", "--md-trj"):
        theo_file = arg
    elif opt in ("-e", "--exp"):
        exp_file = arg
    elif opt in ("-t", "--title"):
        title = arg
    elif opt in ("-o", "--out"):
        out_file = arg
    else:
        assert False, usage()

if theo_file==None or exp_file==None or out_file==None:
    usage()

print 'MD PCA file is ', theo_file
print 'Experimental PCA file is ', exp_file
print 'Your output file is', out_file
print 'Your title will be ', title
#################################################################################

##################### READ AND PROCESS MD PCA RESULTS ###########################
#MD_FILE=open("ake_vec1_vec2_md.txt", 'r')
MD_FILE=open(theo_file, 'r')
md_lines=MD_FILE.readlines()
md_columns=[]
md_pc1=[]
md_pc2=[]
md_time_percentage=[]
counter=0
for line in md_lines:
    if((line[0]!='#') and (line[0]!='@')):
        print line
        md_columns=line.split()
        md_pc1.append(float(md_columns[0]))
        md_pc2.append(float(md_columns[1]))
        counter+=1
#    md_time_percentage.append(float(md_columns[2]))
MD_FILE.close()

print "This file has %d lines"%counter
#    time_percentage=(float(i)/float(counter-1))
for i in range(counter):
    time_percentage=0.0
    time_percentage=(float(i)*0.04)
    md_time_percentage.append(time_percentage)
#sys.exit(-1)
#################################################################################



EXP_FILE=open(exp_file, 'r')
#EXP_FILE=open("1and4_ake_ca_exp_pca.dat", 'r')
#EXP_FILE=open("proj_ev1ev2_c_alpha_adk_pca_exp_files2.xvg", 'r')
exp_lines=EXP_FILE.readlines()
exp_columns=[]
exp_pc1=[]
exp_pc2=[]
exp_time_percentage=[]

for line in exp_lines:
    if((line[0]!='#') and (line[0]!='@')):
        exp_columns=line.split()
        exp_pc1.append(float(exp_columns[0]))
        exp_pc2.append(float(exp_columns[1]))
EXP_FILE.close()
print exp_pc1
print exp_pc2
#################################################################################

plt.subplot()

plt.scatter(md_pc1, md_pc2, marker='o', c=[md_time_percentage], s=10)   
plt.plot(exp_pc1[0], exp_pc2[0], marker='*', c='b', markersize=15)      
plt.plot(exp_pc1[1], exp_pc2[1], marker='*', c='r', markersize=15)      

cb=plt.colorbar()
cb.set_label('Time (ns)')
plt.title(title)
plt.xlabel('PC 1 (nm)')
plt.ylabel('PC 2 (nm)' )
plt.grid()
plt.xlim(-10, 15)
plt.ylim(-6, 8)
plt.savefig(out_file)
#plt.show()

