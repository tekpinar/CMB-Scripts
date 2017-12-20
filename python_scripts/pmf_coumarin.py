#Author   : Mustafa Tekpinar - tekpinar@buffalo.edu
#Date     : November 18, 2013
#Purpose  : To calculate potential of mean force for my SNARE simulations!
#           This script has been adapted to ligand pulling simulations!
#Copyright: Mustafa Tekpinar - tekpinar@buffalo.edu - 2013

#####!/opt/local/bin/python
#!/usr/bin/env python
import sys
import numpy as np
import matplotlib.pyplot as plt
import getopt
import math

#Define important constants.
DEBUG_MODE =1
FORCE_IN_PN=1
k_Boltzmann=0.00198720

#Initialize some important variables
temperature= 300 #Kelvin degrees but this value will be changed by processArguments() function.
v          = 0.04  #Angstrom/picoseconds
inputfile  = None
outputfile = None

def usage():
    print "python pmf.py -i <inputfile> -o <outputfile> -v <velocity> -t <temperature(K)>" 
    print "inputfile contains three types of data in following order: Time, Extensions, Forces"
    print "Example input file line: "
    print "Time(ps) Extenstion1 Extension2 Force1 Force2\n"
    print "Velocity in Angstrom/ps units."
    print "Temperature in Kelvin degrees."
    sys.exit(-1)

#Process arguments function######################################################
def processArguments():
    temp=0.0
    opts, args = getopt.getopt(sys.argv[1:],"hi:o:v:t:",["ifile=","ofile=", "vel=", "temp="])
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hi:o:v:t:",["ifile=","ofile=", "vel=", "temp="])
    except getopt.GetoptError:
        usage()
    for opt, arg in opts:
        if opt in ("-h", "--help", "-help", "help"):
            usage()        
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg
        elif opt in ("-v", "--vel"):
            v = float(arg)
        elif opt in ("-t", "--temp"):
            temp = float(arg)
        else:
            #        assert False, usage()
            assert False, 'Usage: '

    if inputfile==None or outputfile==None:
        usage()
    if(temp==0.0):
        print "Warning: Why do you set temperature to 0 Kelvin?"
        sys.exit(-1)
    return (inputfile, outputfile, v, temp)
#################################################################################

#Define all required lists.
time=[]
extensions=[]
forces=[]
works=[] 

workAveList=[]
workAveSqrdList=[]
workSqrdAveList=[]
workSumList=[]
pmfCumulant=[]
pmfExact=[]

inputfile, outputfile, v, temperature = processArguments()
print "\n\nI'll open %s file for processing."%inputfile
print "Results will be written to '%s' file."%outputfile
print "Velocity= %f Angstrom/ps"%v
print "Temperature= %f Kelvin\n\n"%temperature
beta=(1.0/(k_Boltzmann*temperature))
constant   =beta*0.5
#constant   =0.2
print constant
#Open the first file and calculate work
forceExtensionFileName=inputfile
FORCE_FILE=open(forceExtensionFileName, "r")
lines=FORCE_FILE.readlines()
columnNumber=len(lines[0].split())
length=len(lines)
print "You have ", columnNumber, "columns."
print "You have ", length, "lines in this file."
print "The first column is assumed to be time in ps."
numberOfForceCols=(columnNumber-1)/2
print "There are ", numberOfForceCols, "columns of force data!" 
FORCE_FILE.close()

#print extensions
#print forces
for l in lines:
    data=l.split()
    time.append(float(data[0]))

    #Read extension info
    for i in range(1, (numberOfForceCols+1)):
        extensions.append(float(data[i]))

    #Read forces in piconewtons and if needed, apply unit conversion. 
    for i in range((numberOfForceCols+1), columnNumber):
        if(FORCE_IN_PN):
            #Convert pN to kcal/mol.Angstrom by dividing pN to 69.479
            forces.append(float(data[i])/69.479)
        else:
            #No need to convert pN to kcal/mol.Angstrom
            forces.append(float(data[i]))

#Determine time step in picoseconds from the file!
dt=time[1]-time[0]

print "Time step= %s ps"%dt
averageExtension=length*[0.0]
tempSum=0.0

for i in range(length):
    tempSum=0.0
    for j in range(numberOfForceCols):
        tempSum=tempSum+extensions[((numberOfForceCols*i)+j)]
        
    averageExtension[i]=(tempSum/numberOfForceCols)

for j in range(numberOfForceCols):
    tempSum=0.0
    for i in range(length):
#        tempSum+=forces[numberOfForceCols*i+j]
        tempSum=tempSum+forces[numberOfForceCols*i+j]
#       print (tempSum)
        works.append(float(tempSum*v*dt))
print len(works)

if(DEBUG_MODE):
    OUTFILE=open("works.out", "w")
    for i in range(length*numberOfForceCols):
        print  >>OUTFILE, "%.6f"%works[i]
#    print "%.6f"%works[i]
    OUTFILE.close()

tempSumWork=0.0
for i in range(length):
    tempSumWork=0.0
    for j in range(numberOfForceCols):
        tempSumWork+=works[j*length+i]
    workAveList.append(tempSumWork/numberOfForceCols)
workAveCubedList=[]
for i in range(length):
    workAveSqrdList.append(workAveList[i]*workAveList[i])
    workAveCubedList.append(workAveList[i]*workAveList[i]*workAveList[i])


tempSumWork2=0.0
tempSumWork3=0.0
workCubedAveList=[]
for i in range(length):
    tempSumWork=0.0
    tempSumWork2=0.0
    for j in range(numberOfForceCols):
        tempSumWork2+=(math.exp(-works[j*length+i]/(k_Boltzmann*temperature)))
        tempSumWork+=(works[j*length+i]*works[j*length+i])
        tempSumWork3+=(works[j*length+i]*works[j*length+i]*works[j*length+i])
    pmfExact.append(-k_Boltzmann*temperature*math.log(tempSumWork2/float(numberOfForceCols)))
    workSqrdAveList.append(tempSumWork/numberOfForceCols)
    workCubedAveList.append(tempSumWork3/numberOfForceCols)

pmfCumulant2=[]
for i in range(length):
    pmfCumulant.append(workAveList[i] - beta*0.5*math.sqrt(workSqrdAveList[i]-workAveSqrdList[i]))
    pmfCumulant2.append(workAveList[i]-(beta*0.5)*(workSqrdAveList[i]-workAveSqrdList[i]) + (beta*beta/6.0)*(workCubedAveList[i]-3.0*workSqrdAveList[i]*workAveList[i]+2.0*workAveCubedList[i])  )
#Use matplotlib to plot results!
plt.figure()

#plt.subplot(2,1,1)
#plt.plot(averageExtension, workAveList, 'b-', label='1st Order', averageExtension, pmfExact, 'k*', label='Exact')
#plt.plot(averageExtension, pmfCumulant, 'b-', label='2nd Order', linewidth=1)
#plt.plot(averageExtension, pmfCumulant2, 'r-', label='3rd Order', linewidth=1)
plt.plot(averageExtension, workAveList, 'r-', label='1st Order', linewidth=1)
plt.plot(averageExtension, workSqrdAveList, 'g-.', label='W^2', linewidth=1)
plt.plot(averageExtension, workAveSqrdList, 'b-.', label='<W>^2', linewidth=1)
plt.plot(averageExtension, pmfExact, 'k-.', label='Exact', linewidth=1)
plt.ylabel('Potential of Mean Force (kcal/mol)')
plt.xlabel('Average Extension ($\AA$)')
#plt.legend(loc='upper left')
#plt.xlim(0, 375)
#plt.ylim(0, 1600)
#a2 = [x * 69.479 for x in forces] 
#plt.hist(workAveList, 1000)
#plt.title('k=500 pN/$\AA$)')
#plt.legend(loc='upper left')
#plt.xlabel('Work (kcal/mol)')
#plt.ylabel('Work Distribution')
plt.show()
