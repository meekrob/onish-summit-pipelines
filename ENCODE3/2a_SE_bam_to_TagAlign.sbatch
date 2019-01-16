#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --time=0:03:00
#SBATCH --qos=normal
#SBATCH --ntasks=1
# ---------------------------- Setup ----------------------------
NTHREADS=${SLURM_NTASKS:-1} # will passthrough the --ntasks set above
ATHREADS=$(expr $NTHREADS - 1) # A-additional threads
echo -e "\e[30m\e[1m[$0] $SLURM_JOB_NAME $@\e[0m" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu 
source $PROJ_DIR/paths.bashrc
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3
source $PIPELINE/OUTER_VARS.sh # a set of functions to define 

date # timestamp


# ---------------------- Software Versions ------------------------
echo "Using bedtools:"
bedtools --version
echo "Using awk:"
awk --version | head -1
echo "Using shuf"
shuf --version | head -1
echo "Using openssl"
openssl version
echo
# ------------------------ Random function  ----------------------------
#- Correcting the misuse of random-sources thanks to this post:
#- https://www.gnu.org/software/coreutils/manual/html_node/Random-sources.html#Random-sources
get_seeded_random()
{
  seed=$1
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt  </dev/zero 2>/dev/null
}

# ---------------------- Files -----------------------
#
# input: Filtered bam file- FINAL_BAM_FILE
#
FINAL_BAM_FILE=$1
#
# root,prefix
OFPREFIX=${FINAL_BAM_FILE%%.*} # delete everything after (and including) the first dot
SEED=${OFPREFIX}-2a
FINAL_BAM_PREFIX=$OFPREFIX
#
# output: tagAlign File $FINAL_TA_FILE 
#         Subsampled tagAlign file for CC analysis ${SUBSAMPLED_TA_FILE}

FINAL_TA_FILE="${FINAL_BAM_PREFIX}.SE.tagAlign.gz"



# ===================
# Create tagAlign file
# ===================

# Create SE tagAlign file
echo "FINAL_BAM_FILE: $FINAL_BAM_FILE"
set -xv
time bedtools bamtobed -i ${FINAL_BAM_FILE} | awk 'BEGIN{OFS="\t"}{$4="N";$5="1000";print $0}' | gzip -nc > ${FINAL_TA_FILE}
set +xv
echo "FINAL_TA_FILE: $FINAL_TA_FILE"
pychecksum.py $FINAL_TA_FILE md5

# =================================
# Subsample tagAlign file
# ================================
NREADS=15000000
SUBSAMPLED_TA_FILE="${OFPREFIX}.filt.nodup.sample.$((NREADS / 1000000)).SE.tagAlign.gz"

echo "SEED=$SEED"
cmd="zcat ${FINAL_TA_FILE} | grep -v \“chrM\” | shuf -n ${NREADS} --random-source=<(get_seeded_random $SEED) | gzip -nc > ${SUBSAMPLED_TA_FILE}"
echo $cmd
eval time $cmd

pychecksum.py $SUBSAMPLED_TA_FILE md5

# ------------------ Branchpoint -------------
#                         2a 
#                         |
#  ${SUBSAMPLED_TA_FILE} / \ ${FINAL_TA_FILE}
#                      2b   2c
next_step_log_2b="${SUBSAMPLED_TA_FILE/.gz/}.cc.qc.log-%j"
next_batch="sbatch -o $next_step_log_2b pipeline/2b_cross-corr_QC.sbatch $SUBSAMPLED_TA_FILE"
echo $next_batch
eval $next_batch

next_step_log_2c="${FINAL_TA_FILE/.SE.tagAlign.gz/}.filt.nodup.log-%j"
next_batch="sbatch -o $next_step_log_2c pipeline/2c_self-pseudoreplicates.sbatch $FINAL_TA_FILE"
echo $next_batch
eval $next_batch

