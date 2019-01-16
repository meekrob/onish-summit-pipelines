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

stage=L3
peakFile=allAdult_kd_auto_peaks.bed
computeGZfile="all${stage}MinusIgGMatrix.gz"
heatmapFile="alli${stage}MinusIgGMatrix.png"
rep1="AR112_over_AR114_minus_AR113_over_AR114.x150n.bw"
rep2="AR124_over_AR126_minus_AR125_over_AR126.x150n.bw"
rep3="AR136_over_AR138_minus_AR137_over_AR138.x150n.bw"
rep4="EO24_over_EO28_minus_EO27_over_EO28.x150n.bw"
cmd="computeMatrix reference-point --referencePoint center -p $NTHREADS -S $rep1 $rep2 $rep3 $rep4 $rep5 -R allAdult_kd_auto_peaks.bed -a 500 -b 500 -o $computeGZfile"

echo $cmd
time eval $cmd

cmd="plotHeatmap -m $computeGZfile -o $heatmapFile"
echo $cmd
time eval $cmd
