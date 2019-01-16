#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:20:00
#SBATCH --qos=normal
#SBATCH --output=outfiles/%j-gzip.out
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
outfile=${1}.gz
cmd="gzip $1"
time eval $cmd
pychecksum.py $outfile md5
