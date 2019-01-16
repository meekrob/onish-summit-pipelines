#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:01:00
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/test-paths.bashrc

#### Usage ####
if [ $# -eq 0 ];
then
    echo "$0 infile.gz ...other arguments to plotHeatmap" >&2;
    exit 0
fi


### input file ###
### expecting something like L3_NONENCODEdeep.gz
computeGZfile=$1 # -m, output from computeMatrix
shift
### automatically assumed output files ###
outPNGfile=${computeGZfile/.gz/.png}
outMATfile=${computeGZfile/.gz/.mat}
outBEDfile=${computeGZfile/.gz/_sortedRegions.bed}

### everything else ###
## --dpi 100 --sortUsing max --regionsLabel --regionsLabel "lots of text" --samplesLabel "lots of text"
everythingElse=$@

cmd="plotHeatmap -m $computeGZfile -o $outPNGfile --outFileNameMatrix $outMATfile --outFileSortedRegions $outBEDfile $everythingElse"
echo $cmd
time eval $cmd
