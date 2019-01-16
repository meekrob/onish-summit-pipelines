#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:01:00
#SBATCH --qos=normal
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/test-paths.bashrc

infile=$1
seed=$infile
outfile=${infile/.bed/_random.bed}
cmd="create_random_permutations.py $infile -s $seed -x chip_holes.bed -e | sort -k1,1 -k2,2n > $outfile"
echo $cmd
time eval $cmd
#pychecksum.py outfile md5 # filestamp
