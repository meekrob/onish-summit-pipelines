#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:05:00
#SBATCH --qos=normal
#SBATCH --output=aggregate.%j.out
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc

locus=$1

shift
wigfiles=$@

output=$locus.df
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi

