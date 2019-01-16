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

# input
peakFile=allNONENCODE_peaks.bed
random_peakFile=random_allNONENCODE_peaks.bed
HOT=top_01.ce11.sorted.bed
# output
computeGZfile="allNONENCODEdeep.gz" 

# embryo
E_rep1=AR100_over_AR103.x150n.bw
E_rep2=AR105_over_AR107.x150n.bw
E_rep3=AR109_over_AR111.x150n.bw
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
ENCODE="$LE_1 $LE_2 $L1_1 $L1_2 $L3_1 $L3_2"
NONENCODE="$All_E $All_L3 $All_adult"
cmd="computeMatrix reference-point --referencePoint center --missingDataAsZero --binSize 5 -p $NTHREADS -S $NONENCODE -R $peakFile $random_peakFile $HOT -a 500 -b 500 -o $computeGZfile"
#cmd="computeMatrix reference-point --referencePoint center --binSize 10 -p $NTHREADS -S $All_E $All_L3 $All_adult $ENCODE -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
echo $cmd
time eval $cmd
computeMatrix_success=$?

### labels
embryo="\"embryo rep1\" \"embryo rep2\" \"embryo rep3\" \"embryo rep4\" \"embryo rep5\" \"embryo rep4\"" 
L3="\"L3 rep1\" \"L3 rep2\" \"L3 rep3\" \"L3 rep4\" \"L3 rep5\""
Adult="\"Adult rep1\" \"Adult rep2\" \"Adult rep3\" \"Adult rep4\" \"Adult rep5\""
SAMPLESLABELS="$embryo $L3 $Adult"

heatmapFile="allNONENCODEdeep.png"
if [ $compute_matrix_success -eq 0 ]
then
    cmd="plotHeatmap -m $computeGZfile -o $heatmapFile --dpi 100 --sortUsing max --regionsLabel aELT-2 random HOT --samplesLabel $SAMPLESLABELS"
    echo $cmd
    time eval $cmd
fi
