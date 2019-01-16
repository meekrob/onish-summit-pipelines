#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:15:00
#SBATCH --qos=normal
#SBATCH --output=xz-%j.out
#---------------------------------------------
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
date
cmd="xz -z $@"
echo $cmd
time eval $cmd
