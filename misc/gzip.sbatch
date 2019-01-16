#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:15:00
#SBATCH --qos=normal
#SBATCH --output=gzip-%j.out

echo "[$0] $SLURM_JOB_NAME $@" # log the command line
cmd="gzip -f $1"
echo $cmd
time eval $cmd
