#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:30:00
#SBATCH --qos=normal
#SBATCH --output=outfiles/%j-gzip_bdg.out
echo "[$0] $SLURM_JOB_NAME $@" # log the command line

cmd="gzip -v *.bdg"
echo $cmd
time eval $cmd

