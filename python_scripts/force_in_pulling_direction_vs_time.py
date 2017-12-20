#Author : Mustafa Tekpinar
#Date   : 26 September 2012
#Purpose: To calculate force in the direction of pulling or magnitude of the force.

#!/usr/bin/env python
import re
import os
import math
import sys
import numpy as np
import matplotlib.pyplot as plt

#If 0, force unit is kcal/(mol Angstrom)
FORCE_IN_PN=1

def usage():
    print 'Usage: python force_in_pulling_direction_vs_time.py -i <inputfile> -o <outputfile> -t <magnitude or pull_dir>'
    sys.exit(2)
    
################################################################################
#This part is for getting script parameters in Unix-like fashion.
#Check the number of arguments

import getopt
opts, args = getopt.getopt(sys.argv[1:],"hi:o:t:",["ifile=","ofile=", "force_type="])
#print opts
#print args
inputfile = None
outputfile = None
magOrPullDir=None

try:
    opts, args = getopt.getopt(sys.argv[1:],"hi:o:t:",["ifile=","ofile=", "force_type="])
except getopt.GetoptError:
    usage()
for opt, arg in opts:
    if opt == '-h':
        usage()        
    elif opt in ("-i", "--ifile"):
        inputfile = arg
    elif opt in ("-o", "--ofile"):
        outputfile = arg
    elif opt in ("-t", "--force_type"):
        magOrPullDir = arg
    else:
        assert False, 'Usage: python force_in_pulling_direction_vs_time.py -i <inputfile> -o <outputfile> -t <magnitude or pull_dir>'

if inputfile==None or outputfile==None or magOrPullDir==None:
    usage()

print 'Input file is ', inputfile
print 'Output file is ', outputfile
print 'Pull direction or magnitude? \nYou selected ', magOrPullDir
#print 'We are calculating '+magOrPullDir+'of the force!'
##################################################################################

##Open output file for analysis
outfile = open(outputfile, "w")
#print "Name of the file: ", outfile.name
#print "Closed or not : ", outfile.closed
#print "Opening mode : ", outfile.mode

for line in open(inputfile):
    if re.search("Info: SMD DIRECTION", line):
        print line[22:]
        dir_string=line[22:]
        dir_array=[float(x) for x in dir_string.split(" ")]
        n_x= dir_array[0] 
        n_y= dir_array[1]
        n_z= dir_array[2]
        print "Pulling directions:\n n_x=%s, n_y=%s, n_z=%s" %(n_x, n_y, n_z)

        if line == None:
            print "There is not SMD direction information in this file! %s" %(inputfile.name)

#In original (unmodified) version of 1sfc:
#fixed_x=  11.666
#fixed_y=  12.328
#fixed_z= -48.661

#In 1sfc_modif
fixed_x=  8.669  
fixed_y=  22.844
fixed_z= -62.592

#In 1sfc_conc_ca2cl_015
#fixed_x=  7.589  
#fixed_y= 11.511
#fixed_z=-53.422

#In 1sfc_conc_ca2cl_020
#fixed_x= -0.460  
#fixed_y= 13.537
#fixed_z=-74.940

#In 1sfc_conc_ca2cl_025
#fixed_x= 10.934
#fixed_y= 19.563
#fixed_z=-60.399

#In modified version of 1sfc:
#print "Enter fixed_x component:\n"
#fixed_x=raw_input()
#print "Enter fixed_y component:\n"
#fixed_y=raw_input()
#print "Enter fixed_z component:\n"
#fixed_z=raw_input()
Forces=[]
for line in open(inputfile):
    if re.search("SMD  ", line):
#        print line[5:]
        SMD_string=line[5:]
        numbers=[float(x) for x in SMD_string.split(" ")]
#        print len(numbers)
#        print numbers
        force=0.0
        if magOrPullDir=='pull_dir':
            force=(numbers[4]*float(n_x)+numbers[5]*float(n_y)+numbers[6]*float(n_z))
        elif magOrPullDir=='magnitude':
            force=math.sqrt(numbers[4]*numbers[4]+numbers[5]*numbers[5]+numbers[6]*numbers[6])
        else:
            print "ERROR: No option such as %s!"%magOrPullDir
            usage()
            sys.exit(-1)
        diff_x=(numbers[1]-fixed_x)
        diff_y=(numbers[2]-fixed_y)
        diff_z=(numbers[3]-fixed_z)
        extension=math.sqrt(diff_x*diff_x + diff_y*diff_y + diff_z*diff_z)
        if(FORCE_IN_PN):
            Forces.append(force)   
            print >>outfile, numbers[0]*0.002, extension, (force)
        else:
            Forces.append(force/69.479)   
            print >>outfile, numbers[0]*0.002, extension, (force/69.479)


    if line == None:
        print "There is not SMD direction information in this file! %s" %(inputfile.name)

outfile.close()

print len(Forces)
evenForceElements=[]
for i in range(len(Forces)):
    if(i%2==0):
        evenForceElements.append(Forces[i])
print len(evenForceElements)

#Use matplotlib to plot force distributions!
plt.figure()

#plt.xlim(-10, 25)
plt.xlim(-1000, 1500)
#plt.ylim(0, 350)
plt.hist(Forces, 100, label='Trajectory 1')
#plt.hist(evenForceElements, 100, label='Trajectory 4')
#plt.title('k=14.4 kcal/(mol $\AA^2$)')
plt.title('k=500 pN/$\AA$)')
plt.legend(loc='upper left')
plt.xlabel('Force (pN)')
plt.ylabel('Force Distribution')
plt.show()
