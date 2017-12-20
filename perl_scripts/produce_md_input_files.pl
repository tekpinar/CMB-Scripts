#!/usr/bin/perl -w
use strict; 
use Env;
die "Wrong number of parameters from command line \n
USAGE: perl produce_md_input_files.pl workDir\n" unless $#ARGV == 0;

#Purpose: This file will prepare all input files for 
#         -Minimization
#         -Equilibration
#         -Production

#Author : Mustafa Tekpinar
#Date   : March 7, 2012

#First Step: Lets prepare minimization input file!
my $cMD_on=1;
my $tMD_on=0;
my $aMD_on=0;
my $sMD_on=0;
my $is_heating_on=1;
my $temperature=300; #Body temperature!
my $time_step_size=1; #Use 2 femtosecond time steps.
my $min_steps=10000;
my $heat_steps=(1000*$temperature);
my $equil_steps=2000000;
my $prod_steps =10000000;
my $work_dir=$ARGV[0];
#my $work_dir="/panasas/scratch/tekpinar/hemoglobin/MD/R1-T_transition";
#my $work_dir="/panasas/scratch/tekpinar/ns3_helicase/cMD2";
my $build_dir="$work_dir/build";
my $minim_dir="$work_dir/minimization";
my $heat_dir="$work_dir/heating";
my $equil_dir="$work_dir/equilibration";
my $prod_dir="$work_dir/production";
my $psf_file="$build_dir/ionized.psf";
my $pdb_file="$build_dir/ionized.pdb";
my $par_file="/Users/mt/Documents/ccr_home/toppar/par_all27_prot_na.prm";
my $top_file="/Users/mt/Documents/ccr_home/toppar/top_all27_prot_na.rtf";

#The array will have 6 numbers: CellBasisVector1, CellBasisVector2, CellBasisVector3, CenterX, CenterY, CenterZ
my @boxParams=(0.0, 0.0, 0.0, 0.0, 0.0, 0.0); 

sub getSystemParamets
{
    my $psf_file=$_[0];
    my $pdb_file=$_[1];

    my $script_file="/Users/mt/Documents/ccr_home/myscripts/vmd_scripts/namdGetSysParams.tcl";
#Obtain the box size parameters by using VMD!
#    system("/Applications/VMD_1.9.2.app/Contents/vmd/vmd_MACOSXX86 -dispdev text $psf_file $pdb_file -e $script_file");
#Read those parameters into an array and return the array!
    print "Honey, here I am!";
#The array will have 6 numbers: CellBasisVector1, CellBasisVector2, CellBasisVector3, CenterX, CenterY, CenterZ
    my @boxParams=(0.0, 0.0, 0.0, 0.0, 0.0, 0.0); 
    open (BOX_FILE, "<", "myParams.dat") or die "Can not open myParams.dat file to read $!";
    my @lines=<BOX_FILE>;

    my ($text, $data0, $data1, $data2)=split(/\s+/, $lines[0]);
    $boxParams[0]=$data0;

    ($text, $data0, $data1, $data2)=split(/\s+/, $lines[1]);
    $boxParams[1]=$data1;

    ($text, $data0, $data1, $data2)=split(/\s+/, $lines[2]);
    $boxParams[2]=$data2;

    ($text, $data0, $data1, $data2)=split(/\s+/, $lines[3]);
    $boxParams[3]=$data0;
    $boxParams[4]=$data1;
    $boxParams[5]=$data2;
    foreach(@boxParams)
    {
	print $_."\n";
    }

    close(BOX_FILE);
    return @boxParams;
}

sub minimization
{
#Arguments: temperature min_step_num psf_file pdb_file par_file boxParams
    my $temperature=$_[0];
    my $min_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];    
    open (CONF_FILE, ">", "min.conf") or die "Can not open min.conf file to write $!";
    printf(CONF_FILE "set  T  $temperature
set  STEPSIZE  $time_step_size
set  MINSTEPS $min_steps
set  ENERGYSTEP  100
set  TRAJSTEP  1000

### FORCE FIELD
paraTypeCharmm  on
parameters  $par_file
exclude  scaled1-4
1-4scaling  1.0

### INPUT
temperature  \$T
structure    $psf_file
coordinates  $pdb_file
firsttimestep  0

### OUTPUT
binaryoutput  no
outputName  min
dcdfreq  \$TRAJSTEP
outputEnergies  \$ENERGYSTEP

### INTEGRATOR
timestep  \$STEPSIZE
rigidBonds  none
nonbondedFreq  1
stepspercycle  10

### PERIODIC BOUNDARY
cellBasisVector1  %.2f   0.0    0.0
cellBasisVector2  0.0    %.2f   0.0
cellBasisVector3  0.0    0.0    %.2f
cellOrigin        %.2f   %.2f   %.2f
wrapWater  on

### LONG-RANGE FORCE
cutoff  12.0
switching  on
switchdist  10.0
pairlistdist  14.0

### FIXED ATOMS (set PDB beta-column to 1)
if {0} {
fixedAtoms  off
fixedAtomsFile nofile.pdb
fixedAtomsCol  B
}
minimize  \$MINSTEPS", $boxParams[0], $boxParams[1], $boxParams[2], $boxParams[3], $boxParams[4], $boxParams[5]);
    close (CONF_FILE);
}
sub heating
{
#Arguments: temperature heat_steps psf_file pdb_file par_file
    my $temperature=$_[0];
    my $heat_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];    
    open (CONF_FILE, ">", "heat.conf") or die "Can not open heat.conf file to write $!";

    printf(CONF_FILE "margin  2.0
set  T  $temperature
set  STEPSIZE  $time_step_size
set  RUNSTEPS  $heat_steps
set  ENERGYSTEP  2000
set  TRAJSTEP  2000

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################
structure       $psf_file
coordinates     $minim_dir/min.coor
extendedSystem  $minim_dir/min.xsc

set outputname     heat  
#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          $par_file

# Force-Field Parameters
exclude             scaled1-4
1-4scaling          1.0
cutoff              12.
switching           on
switchdist          10.
pairlistdist        14

# Integrator Parameters
timestep            \${STEPSIZE}
nonbondedFreq       1
fullElectFrequency  2
stepspercycle       10  # Frequency of updating Verlet list (in integration steps)
rigidBonds          all # Apply SHAKE algorithm to all covalent bonds involving hydrogens


# Periodic Boundary Conditions
#cellBasisVector1	89.39	0.00	0.00
#cellBasisVector2	0.00	93.77	0.00
#cellBasisVector3	0.00	0.00	82.25
#cellOrigin		-73.64	26.49	-58.67

wrapAll             on


## harmonic constraints are off
#constraints         on
#consref             mini_2.restart.pdb 
#conskfile           rest.pdb
#conskcol            B            ;# capital 'o' for occupancy column
#constraintScaling   10.0         ;# scale values in 'O'-columns by a factor of 10

# PME (for full-system periodic electrostatics)
PME                 on
PMEGridSpacing      1.0


# OUTPUT
outputName          heat
restartfreq         \${RUNSTEPS}     ;# 500steps = every 1ps
dcdfreq             \${TRAJSTEP}
xstFreq             \${TRAJSTEP}
outputEnergies      \${ENERGYSTEP}


#############################################################
## EXECUTION SCRIPT                                        ##
#############################################################

#MD protocol block ………………….
numsteps 	\${RUNSTEPS} 	# Number of integration steps
temperature 	0 	        # Initial temperature (in K), at which initial velocity
			        # distribution is generated
reassignFreq 	1	        # Number of steps between reassignment of velocities
reassignIncr 	0.001	        # Increment used to adjust temperature
			        # during temperature reassignment
reassignHold 	\${T} 	        # The value of temperature to be kept after heating is
			        # completed");

    close (CONF_FILE);
}

sub equilibration
{
#Arguments: temperature equil_steps psf_file pdb_file par_file
    my $temperature=$_[0];
    my $equil_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];
    my $is_heating_on=$_[5];
    open (CONF_FILE, ">", "equil.conf") or die "Can not open equil.conf file to write $!";
    printf(CONF_FILE "margin  2.0
set  T  $temperature
set  STEPSIZE  $time_step_size
set  RUNSTEPS  $equil_steps
set  ENERGYSTEP  2000
set  TRAJSTEP  2000

### FORCE FIELD

paraTypeCharmm  on
parameters  $par_file
exclude  scaled1-4
1-4scaling  1.0

### INPUT

structure       $psf_file
if {$is_heating_on} {
coordinates     $pdb_file
bincoordinates  $heat_dir/heat.coor
extendedSystem  $heat_dir/heat.xsc
}
if {1-$is_heating_on} {
coordinates     $minim_dir/min.coor
}
temperature  \$T

firsttimestep  0

### OUTPUT

binaryoutput  no
outputName  equil
dcdfreq  \$TRAJSTEP
outputEnergies  \$ENERGYSTEP

### INTEGRATOR

timestep  \$STEPSIZE
rigidBonds  all
nonbondedFreq  1
stepspercycle  10

### PERIODIC BOUNDARY
if {$is_heating_on!=1} {
cellBasisVector1  %.2f   0.0    0.0
cellBasisVector2  0.0    %.2f   0.0
cellBasisVector3  0.0    0.0    %.2f
cellOrigin        %.2f   %.2f   %.2f
}
wrapAll  on

### LONG-RANGE FORCE

cutoff  12.0
switching  on
switchdist  10.0
pairlistdist  14.0

# PME 
PME  yes
PMEGridSpacing  1.0

### THERMOSTAT

# Langevin
langevin  on
langevinDamping  1.0
langevinTemp  \$T
langevinHydrogen  on

### BAROSTAT

useGroupPressure  yes
useFlexibleCell  no
useConstantArea  no
langevinPiston  on
langevinPistonTarget  1.01325
langevinPistonPeriod  200.0
langevinPistonDecay  100.0
langevinPistonTemp  \$T

### FIXED ATOMS (set PDB beta-column to 1)
if {0} {
fixedAtoms  on
fixedAtomsFile  $minim_dir/min.coor
fixedAtomsCol  B
}
### EXECUTION SCRIPT
 
run  \$RUNSTEPS", $boxParams[0], $boxParams[1], $boxParams[2], $boxParams[3], $boxParams[4], $boxParams[5]);
    close (CONF_FILE);
}
sub production_NPT_cMD
{
#Arguments: temperature prod_steps psf_file pdb_file par_file
    my $temperature=$_[0];
    my $prod_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];    
    open (CONF_FILE, ">", "prod_NPT_cMD.conf") or die "Can not open prod_NPT_cMD.conf file to write $!";
    printf(CONF_FILE "margin  2.0
set  T  $temperature
set  STEPSIZE  $time_step_size
set  RUNSTEPS  $prod_steps
set  ENERGYSTEP  2000
set  TRAJSTEP  2000

### FORCE FIELD

paraTypeCharmm  on
parameters   $par_file
exclude  scaled1-4
1-4scaling  1.0

### INPUT

structure $psf_file
coordinates $equil_dir/equil.coor
extendedSystem $equil_dir/equil.xsc

temperature  \$T

firsttimestep  0

### OUTPUT

binaryoutput  no
outputName  prod_npt_cMD
dcdfreq  \$TRAJSTEP
outputEnergies  \$ENERGYSTEP

### INTEGRATOR

timestep  \$STEPSIZE
rigidBonds  all
nonbondedFreq  1
stepspercycle  10

### PERIODIC BOUNDARY

wrapWater  on

### LONG-RANGE FORCE

cutoff  12.0
switching  on
switchdist  10.0
pairlistdist  14.0

# PME 
PME  yes
PMEGridSpacing  1.0

### THERMOSTAT

# Langevin
langevin  on
langevinDamping  1.0
langevinTemp  \$T
langevinHydrogen  on

### BAROSTAT

useGroupPressure  yes
useFlexibleCell  no
useConstantArea  no
langevinPiston  on
langevinPistonTarget  1.01325
langevinPistonPeriod  200.0
langevinPistonDecay  100.0
langevinPistonTemp  \$T

### FIXED ATOMS (set PDB beta-column to 1)
if {0} {
fixedAtoms  on
fixedAtomsFile  $minim_dir/min.coor
fixedAtomsCol  B
}
### EXECUTION SCRIPT
 
run  \$RUNSTEPS");
}


sub production_NVT_cMD
{
#Arguments: temperature prod_steps psf_file pdb_file par_file
    my $temperature=$_[0];
    my $prod_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];    
    open (CONF_FILE, ">", "prod_NVT_cMD.conf") or die "Can not open prod_NVT_cMD.conf file to write $!";
    printf(CONF_FILE "margin  2.0
set  T  $temperature
set  STEPSIZE  $time_step_size
set  RUNSTEPS  $prod_steps
set  ENERGYSTEP  2000
set  TRAJSTEP  2000

### FORCE FIELD

paraTypeCharmm  on
parameters   $par_file
exclude  scaled1-4
1-4scaling  1.0

### INPUT

structure $psf_file
coordinates $equil_dir/equil.coor
extendedSystem $equil_dir/equil.xsc

temperature  \$T

firsttimestep  0

### OUTPUT

binaryoutput  no
outputName  prod_nvt_cMD
dcdfreq  \$TRAJSTEP
outputEnergies  \$ENERGYSTEP

### INTEGRATOR

timestep  \$STEPSIZE
rigidBonds  all
nonbondedFreq  1
stepspercycle  10

### PERIODIC BOUNDARY

wrapWater  on

### LONG-RANGE FORCE

cutoff  12.0
switching  on
switchdist  10.0
pairlistdist  14.0

# PME 
PME  yes
PMEGridSpacing  1.0

### THERMOSTAT

# Langevin
langevin  on
langevinDamping  1.0
langevinTemp  \$T
langevinHydrogen  on

### BAROSTAT

useGroupPressure  yes
useFlexibleCell  no
useConstantArea  no
#langevinPiston  on
#langevinPistonTarget  1.01325
#langevinPistonPeriod  200.0
#langevinPistonDecay  100.0
#langevinPistonTemp  \$T

### FIXED ATOMS (set PDB beta-column to 1)
if {0} {
fixedAtoms  on
fixedAtomsFile  $minim_dir/min.coor
fixedAtomsCol  B
}
### EXECUTION SCRIPT
 
run  \$RUNSTEPS");
}


sub production_NPT_tMD
{
#Arguments: temperature prod_steps psf_file pdb_file par_file tmd_file
    my $temperature=$_[0];
    my $prod_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];    
    my $tmd_file=$_[5];    
    open (CONF_FILE, ">", "prod_tMD.conf") or die "Can not open prod_tMD.conf file to write $!";
    printf(CONF_FILE "margin  2.0
set  T  $temperature
set  STEPSIZE  $time_step_size
set  RUNSTEPS  $prod_steps
set  ENERGYSTEP  2000
set  TRAJSTEP  2000

### FORCE FIELD

paraTypeCharmm  on
parameters   $par_file
exclude  scaled1-4
1-4scaling  1.0

### INPUT

structure $psf_file
coordinates $equil_dir/equil.coor
extendedSystem $equil_dir/equil.xsc

temperature  \$T

firsttimestep  0

### OUTPUT

binaryoutput  no
outputName  prod_tMD
dcdfreq  \$TRAJSTEP
outputEnergies  \$ENERGYSTEP

### INTEGRATOR

timestep  \$STEPSIZE
rigidBonds  all
nonbondedFreq  1
stepspercycle  10

### PERIODIC BOUNDARY

wrapWater  on

### LONG-RANGE FORCE

cutoff  12.0
switching  on
switchdist  10.0
pairlistdist  14.0

# PME 
PME  yes
PMEGridSpacing  1.0

### THERMOSTAT

# Langevin
langevin  on
langevinDamping  1.0
langevinTemp  \$T
langevinHydrogen  on

### BAROSTAT

useGroupPressure  yes
useFlexibleCell  no
useConstantArea  no
langevinPiston  on
langevinPistonTarget  1.01325
langevinPistonPeriod  200.0
langevinPistonDecay  100.0
langevinPistonTemp  \$T

### FIXED ATOMS (set PDB beta-column to 1)
if {0} {
fixedAtoms  on
fixedAtomsFile  $minim_dir/min.coor
fixedAtomsCol  B
}

###TARGETTED MOLECULAR DYNAMICS PARAMETERS
if {1} {
TMD on
TMDk 500.0
TMDOutputFreq 2000
TMDFile $tmd_file
TMDFirstStep 0
TMDLastStep \$RUNSTEPS 
}


### EXECUTION SCRIPT
 
run  \$RUNSTEPS");
}

sub production_sMD
{
#Arguments: temperature prod_steps psf_file pdb_file par_file tmd_file
    my $temperature=$_[0];
    my $prod_steps=$_[1];
    my $psf_file=$_[2];
    my $pdb_file=$_[3];
    my $par_file=$_[4];    
    my $smd_file=$_[5];    
    open (CONF_FILE, ">", "prod_sMD.conf") or die "Can not open prod_sMD.conf file to write $!";
    printf(CONF_FILE "#margin  2.0
set  T  $temperature
set  STEPSIZE  $time_step_size
set  RUNSTEPS  $prod_steps
set  ENERGYSTEP  2000
set  TRAJSTEP  2000

### FORCE FIELD

paraTypeCharmm  on
parameters   $par_file
exclude  scaled1-4
1-4scaling  1.0

### INPUT

structure $psf_file
coordinates $equil_dir/equil.coor
extendedSystem $equil_dir/equil.xsc

temperature  \$T

firsttimestep  0

### OUTPUT

binaryoutput  no
outputName  prod_tMD
dcdfreq  \$TRAJSTEP
outputEnergies  \$ENERGYSTEP

### INTEGRATOR

timestep  \$STEPSIZE
rigidBonds  all
nonbondedFreq  1
stepspercycle  10

### PERIODIC BOUNDARY

wrapWater  on

### LONG-RANGE FORCE

cutoff  12.0
switching  on
switchdist  10.0
pairlistdist  14.0

# PME 
PME  yes
PMEGridSpacing  1.0

### THERMOSTAT

# There is not any temperature control in sMD. So, Langevin is off!
langevin  off
langevinDamping  1.0
langevinTemp  \$T
langevinHydrogen  on

### BAROSTAT

useGroupPressure  yes
useFlexibleCell  no
useConstantArea  no
langevinPiston  on
langevinPistonTarget  1.01325
langevinPistonPeriod  200.0
langevinPistonDecay  100.0
langevinPistonTemp  \$T

### EXTRA BONDS: I put these extra bonds just to comply with experimental results
if {0} {
extraBonds yes 
extraBondsFile $build_dir/extraBond_N_ter_AandB.dat 
}




### FIXED ATOMS (set PDB beta-column to 1)
if {1} {
fixedAtoms  on
fixedAtomsFile  $smd_file
fixedAtomsCol  B
}

###STEERED MOLECULAR DYNAMICS PARAMETERS (set occupancy 1)
if {1} {
SMD on
SMDFile $smd_file
SMDk 7.2
#This means for each picoseconds, it is supposed to pull 1 Angstrom  
SMDVel 0.0004
SMDDir -0.292 0.905 -0.306 
SMDOutputFreq 2000
}


### EXECUTION SCRIPT
 
run  \$RUNSTEPS");
}


#MAIN PROGRAM

#Change to building directory!
chdir($build_dir, ) or die "Can't chdir to $build_dir, $!";

#Get system parameters!
@boxParams=getSystemParamets($psf_file, $pdb_file);


#Check if minimization directory exists!
if (-d $minim_dir)
{ 
    print "$minim_dir exists!\n";
}
else
{   
    mkdir($minim_dir) or die "Can't mkdir $minim_dir";
    print "$minim_dir created!\n"
}
#Change to minimization directory!
chdir($minim_dir, ) or die "Can't chdir to $minim_dir, $!";

#Produce minimization script
minimization($temperature, $min_steps, $psf_file, $pdb_file, $par_file, \@boxParams);


if($is_heating_on)
{
####Check if heating directory exists!
    if (-d $heat_dir)
    { 
	print "$heat_dir exists!\n";
    }
    else
    {   
	mkdir($heat_dir) or die "Can't mkdir $heat_dir";
	print "$heat_dir created!\n"
    }
####Change to heating directory!
    chdir($heat_dir, ) or die "Can't chdir to $heat_dir, $!";
    
####Produce heating script
    heating($temperature, $heat_steps, $psf_file, $pdb_file, $par_file);
}


#Check if equilibration directory exists!
if (-d $equil_dir)
{ 
    print "$equil_dir exists!\n";
}
else
{   
    mkdir($equil_dir) or die "Can't mkdir $equil_dir";
    print "$equil_dir created!\n"
}

#Change to equilibration directory!
chdir($equil_dir, ) or die "Can't chdir to $equil_dir, $!";

#Produce equilibration script
equilibration($temperature, $equil_steps, $psf_file, $pdb_file, $par_file, $is_heating_on);


#Check if production directory exists!
if (-d $prod_dir)
{ 
    print "$prod_dir exists!\n";
}
else
{   
    mkdir($prod_dir) or die "Can't mkdir $prod_dir";
    print "$prod_dir created!\n"
}

#Change to production directory!
chdir($prod_dir, ) or die "Can't chdir to $prod_dir, $!";

if($cMD_on)
{
####Produce production script for classical molecular dynamics
    production_NPT_cMD($temperature, $prod_steps, $psf_file, $pdb_file, $par_file);
}
elsif($aMD_on)
{
#TODO: Complete this part later
####Set target pdb file for targetted molecular dynamics.
#    my $amd_file="${build_dir}/target.pdb";
####Produce production script for targetted molecular dynamics
#    production_NPT_aMD($temperature, $prod_steps, $psf_file, $pdb_file, $par_file, $amd_file);
}
elsif($tMD_on)
{
####Set target pdb file for targetted molecular dynamics.
    my $tmd_file="${build_dir}/target.pdb";
####Produce production script for targetted molecular dynamics
    production_NPT_tMD($temperature, $prod_steps, $psf_file, $pdb_file, $par_file, $tmd_file);
}
elsif($sMD_on)
{
####Set reference pdb file for steered molecular dynamics.
    my $smd_file="${build_dir}/ionized_ref.pdb";
####Produce production script for steered molecular dynamics
    production_sMD($temperature, $prod_steps, $psf_file, $pdb_file, $par_file, $smd_file);
}
else
{
    die "You have to select a molecular dynamics method!\n"; 
}
