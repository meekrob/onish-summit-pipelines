#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:05:00
#SBATCH --qos=normal
#SBATCH --output=L3s_mjGT.%j.out
#SBATCH --error=L3s_mjGT.%j.err
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc

locus=allL3_kd_auto_peaks.bed

wigfiles="AR112.trimmed.dustedx150n.bw \
AR124.trimmed.dustedx150n.bw \
AR132.trimmed.dustedx150n.bw \
EO24.trimmed.dustedx150n.bw \
EO37.trimmed.dustedx150n.bw"


output="L3.aggregate.df"
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi


### now do the signal intensities

wigfiles="AR112_over_AR114.x150n.bw \
AR124_over_AR126.x150n.bw \
AR136_over_AR138.x150n.bw \
EO24_over_EO28.x150n.bw \
EO37_over_EO41.x150n.bw"
output="L3.signal.aggregate.df"
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi

### now do the signal intensities minus the IgG intensities
wigfiles="AR112_over_AR114_minus_AR113_over_AR114.x150n.bw \
AR124_over_AR126_minus_AR125_over_AR126.x150n.bw \
AR136_over_AR138_minus_AR137_over_AR138.x150n.bw \
EO24_over_EO28_minus_EO27_over_EO28.x150n.bw"
##### EO37: rep 5 has no IGG #####

output="L3.signaldiff.aggregate.df"
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi

