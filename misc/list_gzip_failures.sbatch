#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH --output="gzip_failures-%j.txt"

echo "[$0] $SLURM_JOB_NAME $@" # log the command line

for f in $@;
do
    echo -n $f
    gzip -t $f
    echo " $?"
done

