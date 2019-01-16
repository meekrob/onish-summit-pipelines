#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH --ntasks=1
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3

expfile=$1
controlfile=$2
FRAGLEN=${3:-150}
PEAK_OUTPUT_DIR=${4:-.}

SPP=spp # loadbx has bin/spp as wrapper to run_spp.R
spp_cmd="$SPP -c=${expfile}   \
     -i=${controlfile} \
     -npeak=300000  \
     -odir=${PEAK_OUTPUT_DIR}  \
     -speak=${FRAGLEN} \
     -savr -savp -rf  \
     -out=do_single_SPP.ccscores"

echo $spp_cmd
time eval $spp_cmd
