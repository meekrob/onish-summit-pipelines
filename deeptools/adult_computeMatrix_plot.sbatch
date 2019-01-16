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

computeGZfile="allAdultMatrix.gz"
heatmapFile="allAdultMatrix.png"
rep1=AR116_over_AR118.x150n.bw
rep2=AR120_over_AR122.x150n.bw
rep3=AR132_over_AR134.x150n.bw
rep4=EO30_over_EO32.x150n.bw
rep5=EO38_over_EO42.x150n.bw
cmd="computeMatrix reference-point --missingDataAsZero --referencePoint  center -p $NTHREADS -S $rep1 $rep2 $rep3 $rep4 $rep5 -R allAdult_kd_auto_peaks.bed -a 500 -b 500 -o $computeGZfile"




echo $cmd
time eval $cmd

cmd="plotHeatmap -m $computeGZfile -o $heatmapFile"
echo $cmd
time eval $cmd
