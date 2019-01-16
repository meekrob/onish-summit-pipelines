#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=0:25:00
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/test-paths.bashrc

# input
peakFile=allADULT_kd_auto_peaks.bed
random_peakFile=allADULT_kd_auto_peaks_random.bed
# output
computeGZfile="adult_NONENCODEdeep.gz" 

# adult
Ad_rep1=AR116_over_AR118.x150n.bw
Ad_rep2=AR120_over_AR122.x150n.bw
Ad_rep3=AR132_over_AR134.x150n.bw
Ad_rep4=EO30_over_EO32.x150n.bw
Ad_rep5=EO38_over_EO42.x150n.bw
All_adult="$Ad_rep1 $Ad_rep2 $Ad_rep3 $Ad_rep4 $Ad_rep5"
NONENCODE="$All_E $All_L3 $All_adult"
BINSIZE=2
cmd="computeMatrix reference-point --referencePoint center --missingDataAsZero --binSize $BINSIZE -p $NTHREADS -S $NONENCODE -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
echo $cmd
time eval $cmd
compute_matrix_success=$?

### labels
#embryo="\"embryo rep1\" \"embryo rep2\" \"embryo rep3\" \"embryo rep4\" \"embryo rep5\" \"embryo rep4\"" 
#L3="\"L3 rep1\" \"L3 rep2\" \"L3 rep3\" \"L3 rep4\" \"L3 rep5\""
Adult="\"Adult rep1\" \"Adult rep2\" \"Adult rep3\" \"Adult rep4\" \"Adult rep5\""
SAMPLESLABELS="$embryo $L3 $Adult"

heatmapFile=${computeGZfile/.gz/.png}
if [ $compute_matrix_success -eq 0 ]
then
    #cmd="plotHeatmap -m $computeGZfile -o $heatmapFile --dpi 100 --sortUsing max --regionsLabel aELT-2 random --samplesLabel $SAMPLESLABELS"
    cmd="deeptools_pipeline/plotHeatmap.sbatch $computeGZfile --dpi 100 --sortUsing max --regionsLabel aELT-2 random --samplesLabel $SAMPLESLABELS"
    echo $cmd
    time eval $cmd
fi
