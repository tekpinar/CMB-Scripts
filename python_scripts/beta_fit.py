#!/usr/bin/python
#Purpose  : This script fits a theoretical beta factor file to an experimental beta factor file as 
#           explained in "Bahar, I., Atilgan, A. R. & Erman, B. Direct evaluation of thermal 
#           fluctuations in proteins using a single-parameter harmonic potential. Fold Des 2, 173-181 (1997)". 
#Author   : Mustafa Tekpinar
#Email    : tekpinar@buffalo.edu
#Copyright: Mustafa Tekpinar - 2014
#Date     : January 6, 2014
#Updated  : January 12, 2015

import sys
import os
import getopt
import numpy

def usage():
    print "Usage:"
    print "python beta_fit.py -t theo_data.dat -e exp_data.dat -o out_file.dat"
    print "theo_data.dat format is  '(Residue Number)    (Beta Factor)' "
    print " exp_data.dat format is  '(Residue Number)    (Beta Factor)' "
    print " out_file.dat format is  '(Residue Number)    (Beta Factor Experimental) (Fit Theoretical Beta Factors)' "
    sys.exit(-1)

def find_cc(theoreticalData, experimentalData):
    """This function finds cross-correlation between experimental and theoretical data."""
    A=numpy.array(theoreticalData)
    B=numpy.array(experimentalData)        
    cc= (   numpy.inner(A,B)/ ( numpy.linalg.norm(A)*numpy.linalg.norm(B) )   )
    print "Cross-correlation: %5.3f"%cc

def beta_fit(exp_file, theo_file, result_file):
    #Step 0- Define variables needed!
    residueNumbersExp=[]
    residueNumbersTheo=[]
    experimentalData=[]
    theoreticalData=[]
    totalAreasTheo=0.0
    totalAreasExp=0.0

    #Step 1- Read experimental data initially.
    EXP_BETA_FILE=open(exp_file, "r")
    lines=EXP_BETA_FILE.readlines()
    dataInLine1=[]
    for line in lines:
        dataInLine1=line.split()
        residueNumbersExp.append(int(dataInLine1[0]))
        experimentalData.append(float(dataInLine1[1]))
    EXP_BETA_FILE.close()
    ##################################################    

    #Step 2- Read theoretical rmsf data now.
    THEO_BETA_FILE=open(theo_file, "r")
    lines=THEO_BETA_FILE.readlines()
    dataInLine2=[]
    for line in lines:
        dataInLine2=line.split()
        residueNumbersTheo.append(int(dataInLine2[0]))
        theoreticalData.append(float(dataInLine2[1]))
    THEO_BETA_FILE.close()
    ##################################################    
    #Step 3- Find cross-correlation value before modifying data.
    find_cc(theoreticalData, experimentalData)


    #Step 4- Find fitting factor to multiply theoretical data with.
    #Check if number of residues is same in both theoretical and experimental files!
    if(len(residueNumbersExp)!=len(residueNumbersTheo)):
        print "Number of residues in two files is not same!"
        sys.exit(-1)
    
    totalAreasExp=sum(experimentalData)     #Total epxerimental area
    print "Total experimental area is %lf" %totalAreasExp
    totalAreasTheo=sum(theoreticalData)
    print "Total theoretical area is %lf" %totalAreasTheo
    ratio=totalAreasExp/totalAreasTheo
    ##################################################

    #Step 5- Write all results to a file.
    RESULTS_FILE=open(out_file, "w")
    i=0
    for item in residueNumbersExp:
        print >>RESULTS_FILE, "%s\t%.3lf\t%.3lf"%(item, experimentalData[i], ratio*theoreticalData[i])
        i+=1
    RESULTS_FILE.close()
    ##################################################    

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

beta_fit(exp_file, theo_file, out_file)
