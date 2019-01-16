#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:09:00
#SBATCH --qos=normal
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

left=$1
right=$2
idr_threshold=$3
shift 3

output_file="${left%%.*}_${right%%.*}.IDR_${idr_threshold}.narrowPeak"

if [[ -z "$left" || -z "$right" || -z "$idr_threshold" ]]
then
    echo "USAGE:"
    echo "$0 sample1.narrowPeak sample2.narrowPeak IDR_THRESHOLD"
    echo
    exit 1
fi

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc

seed=13

cmd="idr --samples $left $right \
--idr-threshold $idr_threshold \
--random-seed $seed \
--output-file $output_file \
$@"
echo $cmd
if [ -n "$SLURM_JOB_NAME" ]
then
    time eval $cmd
else
    echo "...dry run..."
fi
    
