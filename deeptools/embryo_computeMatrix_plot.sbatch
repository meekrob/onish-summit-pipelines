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

peakFile=allEMBRYO_kd_auto_peaks.bed
computeGZfile="allEmbryoMatrix.gz"
heatmapFile="allEmbryoMatrix.png"
rep1="AR100_over_AR103.x150n.bw"
rep2="AR105_over_AR107.x150n.bw"
rep3="AR109_over_AR111.x150n.bw"
rep4="AR128_over_AR130.x150n.bw"
rep4="EO24_over_EO28.x150n.bw"

cmd="computeMatrix reference-point  --missingDataAsZero  --referencePoint center -p $NTHREADS -S $rep1 $rep2 $rep3 $rep4 $rep5 -R $peakFile -a 500 -b 500 -o $computeGZfile"

echo $cmd
time eval $cmd

cmd="plotHeatmap -m $computeGZfile -o $heatmapFile"
echo $cmd
time eval $cmd
