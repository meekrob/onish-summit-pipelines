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
source $PROJ_DIR/test-paths.bashrc

# input
peakFile=allL3_kd_auto_peaks.bed
random_peakFile=allL3_kd_auto_peaks_random.bed
# output
computeGZfile="L3_NONENCODEdeep.gz" 

# L3
L3_rep1=AR112_over_AR114.x150n.bw
L3_rep2=AR124_over_AR126.x150n.bw
L3_rep3=AR136_over_AR138.x150n.bw
L3_rep4=EO24_over_EO28.x150n.bw # 50ug a-ELT2
L3_rep5=EO37_over_EO41.x150n.bw # no IgG control
All_L3="$L3_rep1 $L3_rep2 $L3_rep3 $L3_rep4 $L3_rep5"
NONENCODE="$All_E $All_L3 $All_adult"
BINSIZE=2
cmd="computeMatrix reference-point --referencePoint center --missingDataAsZero --binSize $BINSIZE -p $NTHREADS -S $NONENCODE -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
echo $cmd
time eval $cmd
compute_matrix_success=$?

### labels
L3="\"L3 rep1\" \"L3 rep2\" \"L3 rep3\" \"L3 rep4\" \"L3 rep5\""
SAMPLESLABELS="$L3"

heatmapFile=${computeGZfile/.gz/.png}
if [ $compute_matrix_success -eq 0 ]
then
    cmd="plotHeatmap -m $computeGZfile -o $heatmapFile --dpi 100 --sortUsing max --regionsLabel aELT-2 random --samplesLabel $SAMPLESLABELS"
    echo $cmd
    time eval $cmd
fi
