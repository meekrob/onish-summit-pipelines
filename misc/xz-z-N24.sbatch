#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=0:15:00
#SBATCH --qos=normal
#SBATCH --output=xz-%j.out
#---------------------------------------------
NTASKS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
date
cmd="xz -z -9 -T $NTASKS $@"
echo $cmd
time eval $cmd
