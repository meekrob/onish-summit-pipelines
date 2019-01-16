#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=1:00:00
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/test-paths.bashrc
#loadpy3 # for deeptools

# input
peakFile=allENCODE_peaks.bed
random_peakFile=random_allENCODE_peaks.bed
HOT=top_01.ce11.sorted.bed
# output
computeGZfile="allENCODEdeep.gz" 
heatmapFile="allENCODEdeep.png"

# ENCODE 
LE_1=LE_1.dustedx150n.bw
LE_2=LE_2.dustedx150n.bw
L1_1=L1_1.dustedx150n.bw
L1_2=L1_2.dustedx150n.bw
L3_1=L3_1.dustedx150n.bw
L3_2=L3_2.dustedx150n.bw
ENCODE="$LE_1 $LE_2 $L1_1 $L1_2 $L3_1 $L3_2"
NONENCODE="$All_E $All_L3 $All_adult"
cmd="computeMatrix reference-point --referencePoint center --missingDataAsZero --binSize 5 -p $NTHREADS -S $ENCODE -R $peakFile $random_peakFile $HOT -a 500 -b 500 -o $computeGZfile"
#cmd="computeMatrix reference-point --referencePoint center --binSize 10 -p $NTHREADS -S $All_E $All_L3 $All_adult $ENCODE -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
echo $cmd
time eval $cmd

if [ $? -eq 0 ]
then
    cmd="plotHeatmap -m $computeGZfile -o $heatmapFile --samplesLabel LE_1 LE_2 L1_1 L1_2 L3_1 L3_2 --regionsLabel modENCODE random HOT"
    #cmd="plotHeatmap -m $computeGZfile -o $heatmapFile "
    echo $cmd
    time eval $cmd

fi
