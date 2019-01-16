#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --time=0:05:00
#SBATCH --qos=normal
#SBATCH --ntasks=12
# ---------------------------- Setup ----------------------------
NTHREADS=$SLURM_NTASKS # will passthrough the --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
# erinnishgrp@colostate.edu 
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3
# for loading SPP
ml intel
ml impi
ml boost
ml R


date # timestamp
# ----------- Software ---------------
echo "fork of hms-dbmi/spp at https://github.com/meekrob/spp"
sed --version | head -1
echo

# ---------------------- Files -----------------------
#
# input: Subsampled tagAlign file ${SUBSAMPLED_TA_FILE}
#
SUBSAMPLED_TA_FILE=$1
echo "SUBSAMPLED_TA_FILE=$SUBSAMPLED_TA_FILE"
#
# output: -OutFile containing NSC/RSC results in tab-delimited file 
#           of 11 columns (same file can be appended 
#           to from multiple runs) ${CC_SCORES_FILE}
#         -Cross-correlation plot ${CC_PLOT_FILE}
#
CC_SCORES_FILE="${SUBSAMPLED_TA_FILE%%.gz}.cc.qc"
echo "CC_SCORES_FILE=$CC_SCORES_FILE"
CC_PLOT_FILE="${SUBSAMPLED_TA_FILE%%.gz}.cc.plot.pdf"
echo "CC_PLOT_FILE=$CC_PLOT_FILE"

# R command
cmd="spp -c=${SUBSAMPLED_TA_FILE} -p=${NTHREADS} -filtchr=chrM -savp=${CC_PLOT_FILE} -out=${CC_SCORES_FILE} -rf"
echo $cmd
eval time $cmd

# sed command
set -x
sed -r 's/,[^\t]+//g' ${CC_SCORES_FILE} > $TMPDIR/temp
mv $TMPDIR/temp ${CC_SCORES_FILE}
set +x

pychecksum.py ${CC_SCORES_FILE} md5 # filestamp
