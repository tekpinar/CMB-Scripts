#!/opt/local/bin/python
#Purpose  : A simple script that can produce beta factor differences of mutated proteins!
#Author   : Mustafa Tekpinar
#Email    : tekpinar@buffalo.edu
#Copyright: Mustafa Tekpinar - 2013

import numpy as np
import matplotlib.pyplot as plt
import os

dataColumn=8
cutoff_radius="9.0"

#Run all command and get dada file
protein_list=['3gwg', '3h1f', '3h1g']

for item in protein_list:
    os.system("./cpu_enm_nma.exe -i "+item+".pdb -o "+item+"_cpu.nmd -R "+cutoff_radius+" -n 6")
    os.system("mv theo_beta_file.dat "+item+"_mass_weight_theo_beta_file.dat")

residueNumbers=[]
experimentalDataUnmutated=[]
experimentalDataMutated1=[]
experimentalDataMutated2=[]

theoreticalDataUnmutated=[]
theoreticalDataMutated1=[]
theoreticalDataMutated2=[]

theoreticalData=[]
experimentalData=[]
totalAreasTheo=[]
totalAreasExp=[]
i=0
for item in protein_list:
    BETA_FILE=open(item+"_mass_weight_theo_beta_file.dat", "r")
    lines=BETA_FILE.readlines()
    dataInLine=[]
    tempList1=[]
    tempList2=[]
    for line in lines:
        dataInLine=line.split()
        if(i==0):
            residueNumbers.append(float(dataInLine[0]))
        tempList1.append(float(dataInLine[1]))
        tempList2.append(float(dataInLine[dataColumn]))
    i=+1
    totalAreasExp.append(sum(tempList1))
    totalAreasTheo.append(sum(tempList2))
    print totalAreasExp
    print totalAreasTheo
    experimentalData.append(tempList1)
    theoreticalData.append(tempList2)

    BETA_FILE.close()

#for i in range(1, 3):
#    for j in range(len(experimentalData[0])):
#        experimentalData[i][j]=experimentalData[i][j]*(totalAreasExp[0]/totalAreasExp[i])
#        theoreticalData[i][j]=theoreticalData[i][j]*(totalAreasTheo[0]/totalAreasTheo[i])

plt.figure()
plt.subplot(2,1,1)
plt.plot(residueNumbers, theoreticalData[0], 'k', residueNumbers, theoreticalData[1], 'r',  residueNumbers, theoreticalData[2], 'b')
plt.ylabel('Root Mean Square Fluctuations')
#plt.xlabel('Residue Numbers')
plt.title('Experiment vs Theory')
plt.xlim(0, 125)

plt.subplot(2,1,2)
plt.plot(residueNumbers, experimentalData[0], 'k', residueNumbers, experimentalData[1], 'r',  residueNumbers, experimentalData[2], 'b')
plt.ylabel('Scaled Beta Factors')
plt.xlabel('Residue Numbers')
#plt.title('RMSF Values')
plt.xlim(0, 125)

plt.show()
