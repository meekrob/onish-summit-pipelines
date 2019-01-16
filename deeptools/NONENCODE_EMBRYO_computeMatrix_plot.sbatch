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
peakFile=allEMBRYO_kd_auto_peaks.bed
random_peakFile=allEMBRYO_kd_auto_peaks_random.bed
# output
computeGZfile="embryo_NONENCODEdeep.gz" 

# embryo
E_rep1=AR100_over_AR103.x150n.bw
E_rep2=AR105_over_AR107.x150n.bw # replaced by EO62 (over EO64)
E_rep3=AR109_over_AR111.x150n.bw # replaced by EO66 (over EO68)
E_rep4=AR128_over_AR130.x150n.bw
E_rep5=EO34_over_EO40.x150n.bw 
All_E="$E_rep1 $E_rep2 $E_rep3 $E_rep4 $E_rep5"

NONENCODE="$All_E $All_L3 $All_adult"
BINSIZE=2
cmd="computeMatrix reference-point --referencePoint center --missingDataAsZero --binSize $BINSIZE -p $NTHREADS -S $NONENCODE -R $peakFile $random_peakFile -a 500 -b 500 -o $computeGZfile"
echo $cmd
time eval $cmd
compute_matrix_success=$?

### labels
embryo="\"embryo rep1\" \"embryo rep2\" \"embryo rep3\" \"embryo rep4\" \"embryo rep5\""
L3="\"L3 rep1\" \"L3 rep2\" \"L3 rep3\" \"L3 rep4\" \"L3 rep5\""
Adult="\"Adult rep1\" \"Adult rep2\" \"Adult rep3\" \"Adult rep4\" \"Adult rep5\""
SAMPLESLABELS="$embryo"

heatmapFile=${computeGZfile/.gz/.png}
if [ $compute_matrix_success -eq 0 ]
then
    cmd="plotHeatmap -m $computeGZfile -o $heatmapFile --dpi 100 --sortUsing max --regionsLabel aELT-2 random --samplesLabel $SAMPLESLABELS"
    echo $cmd
    time eval $cmd
fi
