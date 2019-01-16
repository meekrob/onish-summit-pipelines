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
source $PROJ_DIR/paths.bashrc
loadpy3 # for deeptools

# input
peakFile=allStages_kd_auto_peaks.bed
random_peakFile=allStages_kd_auto_peaks_random3.bed
# output
computeGZfile="allStagesMatrix_plusENCODE.gz" 
heatmapFile="allStagesMatrix_plusENCODE.png"

# embryo
E_rep1=AR100_over_AR103.x150n.bw
#E_rep2=AR105_over_AR107.x150n.bw
E_rep2=EO62_over_EO64.x150n.bw
#E_rep3=AR109_over_AR111.x150n.bw
E_rep3=EO66_over_EO68.x150n.bw
E_rep4=AR128_over_AR130.x150n.bw
E_rep5=EO24_over_EO28.x150n.bw
All_E="$E_rep1 $E_rep2 $E_rep3 $E_rep4 $E_rep5"
# L3
L3_rep1=AR112_over_AR114.x150n.bw
L3_rep2=AR124_over_AR126.x150n.bw
L3_rep3=AR136_over_AR138.x150n.bw
L3_rep4=EO24_over_EO28.x150n.bw
L3_rep5=EO37_over_EO41.x150n.bw
All_L3="$L3_rep1 $L3_rep2 $L3_rep3 $L3_rep4 $L3_rep5"
# adult
Ad_rep1=AR116_over_AR118.x150n.bw
Ad_rep2=AR120_over_AR122.x150n.bw
Ad_rep3=AR132_over_AR134.x150n.bw
Ad_rep4=EO30_over_EO32.x150n.bw
Ad_rep5=EO38_over_EO42.x150n.bw
All_adult="$Ad_rep1 $Ad_rep2 $Ad_rep3 $Ad_rep4 $Ad_rep5"

cmd="computeMatrix reference-point --referencePoint center --missingDataAsZero --binSize 5 -p $NTHREADS -S $All_E $All_L3 $All_adult -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
#cmd="computeMatrix reference-point --referencePoint center --binSize 10 -p $NTHREADS -S $All_E $All_L3 $All_adult $ENCODE -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
echo $cmd
time eval $cmd

if [ $? -eq 0 ]
then
    cmd="plotHeatmap -m $computeGZfile -o $heatmapFile"
    echo $cmd
    time eval $cmd

fi
