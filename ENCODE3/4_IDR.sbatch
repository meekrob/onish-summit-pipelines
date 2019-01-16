#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:03:00
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
source $PIPELINE/OUTER_VARS.sh

loadpy3 # will switch env to python3
set -x
REP1_PEAK_FILE=$1
REP2_PEAK_FILE=$2
POOLED_PEAK_FILE=$3
REP1_VS_REP2=$4 # a name like primaryReps, pseudoReps
IDR_OUTPUT=${REP1_VS_REP2}.out
IDR_THRESH=0.05

# =============================
# Perform IDR analysis.
# Generate a plot and IDR output with additional columns including IDR scores.
# =============================
idr --samples ${REP1_PEAK_FILE} ${REP2_PEAK_FILE} --peak-list ${POOLED_PEAK_FILE} --input-file-type narrowPeak --output-file ${IDR_OUTPUT} --rank signal.value --soft-idr-threshold ${IDR_THRESH} --plot --use-best-multisummit-IDR

# =============================
# Get peaks passing IDR threshold of 5%
# =============================
IDR_THRESH_TRANSFORMED=$(awk -v p=${IDR_THRESH} 'BEGIN{print -log(p)/log(10)}')

awk 'BEGIN{OFS="\t"} $12>='"${IDR_THRESH_TRANSFORMED}"' {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ${IDR_OUTPUT} | sort | uniq | sort -k7n,7n | gzip -nc > ${REP1_VS_REP2}.IDR0.05.narrowPeak.gz

NPEAKS_IDR=$(zcat ${REP1_VS_REP2}.IDR0.05.narrowPeak.gz | wc -l)
echo $NPEAKS_IDR > ${REP1_VS_REP2}.Npeaks

# =============================
# Filter using black list
# =============================
declare -f _grep_valid_chrom_ # from OUTER_VARS.sh show function in logs
declare -f _awk_max_1000_col5_ # from OUTER_VARS.sh show this function in the log
bedtools intersect -v -a ${REP1_VS_REP2}.IDR0.05.narrowPeak.gz -b ${BLACKLIST} | _grep_valid_chrom_ | _awk_max_1000_col5_ | gzip -nc > ${REP1_VS_REP2}.IDR0.05.filt.narrowPeak.gz

