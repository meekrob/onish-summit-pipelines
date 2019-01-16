#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --qos=normal
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc

locus=allEMBRYO_kd_auto_peaks.bed
wigfiles="AR100.trimmed.dusted.sortedx150n.bw \
AR128.trimmed.dusted.sortedx150n.bw \
EO34.trimmed.dusted.sortedx150n.bw \
EO62.trimmed.sortedx150n.bw \
EO66.trimmed.sortedx150n.bw"


output="embryo.aggregate.df"
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi


### now do the signal intensities

wigfiles="AR100_over_AR103.x150n.bw \
AR128_over_AR130.x150n.bw \
EO34_over_EO40.x150n.bw \
EO62_over_EO64.x150n.bw \
EO66_over_EO68.x150n.bw"

output="embryo.signal.aggregate.df"
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi

### now do the signal intensities minus the IgG intensities
wigfiles="AR100_over_AR103_minus_AR102_over_AR103.x150n.bw \
AR128_over_AR130_minus_AR129_over_AR130.x150n.bw \
EO34_over_EO40_minus_EO35_over_EO40.x150n.bw \
EO62_over_EO64_minus_EO63_over_EO64.x150n.bw \
EO66_over_EO68_minus_EO67_over_EO68.x150n.bw"

output="embryo.signaldiff.aggregate.df"
cmd="meekrob-javaGenomicsToolkit ngs.SplitWigIntervalsToDataFrame -l $locus -o $output $wigfiles"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "test mode"
fi

