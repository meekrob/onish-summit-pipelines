#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=0:45:00
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
loadpy3 # for deeptools

computeGZfile="referencePoint.gz"
heatmapFile="referencePoint.png"
cmd="computeMatrix reference-point --referencePoint center -p $NTHREADS -S AR120_over_AR122.x150n.bw EO38_over_EO42.x150n.bw AR112_over_AR114.x150n.bw AR136_over_AR138.x150n.bw -R AR120_kd_auto_peaks.bed9_3 -a 500 -b 500 -o $computeGZfile"



echo $cmd
time eval $cmd

cmd="plotHeatmap -m $computeGZfile -o $heatmapFile"
echo $cmd
time eval $cmd
