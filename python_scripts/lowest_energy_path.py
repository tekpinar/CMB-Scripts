from numpy.random import uniform, seed
from matplotlib.mlab import griddata
import matplotlib.pyplot as plt
import numpy as np

#inp_file="1ake_amber_gibbs_free_energy_10_trjs.txt"
#out_file="lowest_energy_amber.dat"

#inp_file="1ake_charmm_gibbs_free_energy_10_trjs.txt"
#out_file="lowest_energy_charmm.dat"

#inp_file="1ake_gromos_gibbs_free_energy_10_trjs.txt"
#out_file="lowest_energy_gromos.dat"

inp_file="1ake_opls_gibbs_free_energy_10_trjs.txt"
out_file="lowest_energy_opls.dat"



x=[]
y=[]
g_energy=[]
g_energy_resorted=[]

#This part reads input file (into a tuple)
myListofTuples = list()
MD_FILE=open(inp_file, 'r')
for line in MD_FILE.readlines():
    if((line[0]!='#') and (line[0]!='@')):
        myListofTuples.append(line.split())
        y.append(float(line.split()[1]))
        g_energy.append(float(line.split()[2]))
#        counter+=1
MD_FILE.close()

LID_tuple_list=list()

#This part finds the lowest energy values along y-axis, namely, LID Angle. 
for i in range(0,32):
    min=100000.0
    for j in range(0,32):
        if(g_energy[i*32+j]<min):
            min=g_energy[i*32+j]
    LID_tuple_list.append((y[i*32+j-1], min))
#    print "%.6f\t%.6f"%(y[i*32+j-1], min)


#Sort this list of tuples according to increasing NMP Angle values.
myListofTuples.sort(key=lambda tup: tup[0])

#Assign x and energy elements of the reordered list of tuples to a new list of tuples. 
NMP_tuple_list=list()
for i in range(0,32):
    for j in range(0,32):
        x.append(float(myListofTuples[i*32+j][0]))
        g_energy_resorted.append(float(myListofTuples[i*32+j][2]))

for i in range(0,32):
    min=100000.0
    for j in range(0,32):
        if(g_energy_resorted[i*32+j]<min):
            min=g_energy_resorted[i*32+j]
    NMP_tuple_list.append((x[i*32+j-1], min))
#    print "%.6f\t%.6f"%(x[i*32+j-1], min)

LOWEST_ENERGY_FILE=open(out_file, 'w')
for i in range(0,32):
    print >> LOWEST_ENERGY_FILE,("%10.5f\t%10.5f\t%10.5f\t%10.5f")%(NMP_tuple_list[i][0], NMP_tuple_list[i][1], LID_tuple_list[i][0], LID_tuple_list[i][1])
LOWEST_ENERGY_FILE.close()

# define grid.
#xi = np.linspace(35, 102, 1500)
#yi = np.linspace(83, 180, 1500)
## grid the data.
#zi = griddata(x, y, g_energy, xi, yi, interp='linear')
## contour the gridded data, plotting dots at the nonuniform data points.
#CS = plt.contour(xi, yi, zi, 20, linewidths=0.5, colors='k')
#CS = plt.contourf(xi, yi, zi, 20, cmap=plt.cm.rainbow, vmax=abs(zi).max(), vmin=-abs(zi).max())
#plt.colorbar()  # draw colorbar
# plot data points.
#plt.plot(x, g_energy, 'k')

#plt.scatter(x, g_energy, marker='o', c='b')
#plt.xlim(35, 102)
#plt.ylim(83, 180)
#plt.zlim(0, 16)
#plt.title('griddata test')
#plt.show()
