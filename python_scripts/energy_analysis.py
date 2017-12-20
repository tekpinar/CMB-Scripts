#!/opt/local/bin/python
#Purpose: To do energy analysis of gromacs files!
#Copyright: Mustafa Tekpinar-2013, tekpinar@buffalo.edu
#Date: December 6, 2013
import sys
import os
import getopt
import numpy as np
import matplotlib.pyplot as plt

#Step 0 - Parse arguments 
def usage():
    print 'Usage: energy_analysis.py -i <inputfile> -t <ff_type>'
    print '-t <charmm> or -t <amber> or -t <gromacs> or -t <opls>'
    sys.exit(2)

opts, args = getopt.getopt(sys.argv[1:],"hi:t:",["ifile=","type="])
#print opts
#print args
inputfile = None
outputfile = None

try:
    opts, args = getopt.getopt(sys.argv[1:],"hi:t:",["ifile=","type="])
except getopt.GetoptError:
    usage()
for opt, arg in opts:
    if opt == '-h':
        usage()        
    elif opt in ("-i", "--ifile"):
        inputfile = arg
    elif opt in ("-t", "--type"):
        ff_type = arg
    else:
        assert False, usage()

if inputfile==None or ff_type==None:
    usage()

print 'Input file is ', inputfile
print 'Force field type is ', ff_type

#Step 1 Open files and obtain the data in total energy and proper dihedrals
#We need some Unix hocus pocus here to get data from log file. 
string="grep -A 1 '           Step           Time         Lambda\|Proper Dih. \|Total Energy' "+inputfile+"|awk 'NR%3==2'|head -n -2 >only_nums.dat"
print string
os.system(string)

print "Hey there, I completed here successfully!"
ENERGY_FILE=open("only_nums.dat", "r")
lines=ENERGY_FILE.readlines()
dataInLine=[]
i=0
timeList=[]
properDihEnergy=[]
cmapDihEnergy=[]
totalEnergy=[]
for line in lines:
#    print lines[100]
    if(i%3==0):
        dataInLine=lines[i].split()
        timeList.append(float(dataInLine[1]))

    if(i%3==1):
        dataInLine=lines[i].split()
        
        #For Charmm, add CMAP dihedral energy
        if(ff_type=="charmm"):
            properDihEnergy.append(float(dataInLine[1]))
#            properDihEnergy.append(float(dataInLine[1])-float(dataInLine[3]))

        else:
            properDihEnergy.append(float(dataInLine[1]))

    if(i%3==2):
        dataInLine=lines[i].split()
        if(ff_type=="amber"):
            #This one is only necessary for Amber force field.
            totalEnergy.append(float(dataInLine[0]))
        if((ff_type=="opls") or (ff_type=="gromacs")):
            #This one is only necessary for OPLS and 56a3 force field.
            totalEnergy.append(float(dataInLine[1]))
        if(ff_type=="charmm"):
            #This one is only necessary for Charmm force field.
            totalEnergy.append(float(dataInLine[2]))
#    print dataInLine
    i+=1
ENERGY_FILE.close()
i=0
energyRatio=[]
for item in timeList:
    energyRatio.append(properDihEnergy[i]/totalEnergy[i])
#    print timeList[i], energyRatio[i]
    i+=1

i=0
RESULTS_FILE=open(inputfile+"_dih.dat", "w")
for item in energyRatio:
    print >>RESULTS_FILE, timeList[i], properDihEnergy[i]
#    print >>RESULTS_FILE, timeList[i], energyRatio[i]
    i+=1
RESULTS_FILE.close()

#Step 2 Call matplotlib to plot their ratio
#plt.figure()
#plt.subplot(2,1,1)
plt.plot(timeList, energyRatio, 'k')
#plt.ylabel('Root Mean Square Fluctuations')
#plt.xlabel('Residue Numbers')
#plt.title('Experiment vs Theory')
#plt.xlim(0, 125)

#plt.show()
