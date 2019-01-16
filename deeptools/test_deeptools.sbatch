#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:30:00
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
loadpy3 # for deeptools

cmd="computeMatrix scale-regions -S AR120_over_AR122.x150n.bw AR100_over_AR103.x150n.bw -R AR120_kd_auto_peaks.bed9_3 -a 2000 -b 2000 -o test_deeptools.gz"
echo $cmd
time eval $cmd

cmd="plotHeatmap -m test_deeptools.gz -o heatmap.png"
echo $cmd
time eval $cmd
