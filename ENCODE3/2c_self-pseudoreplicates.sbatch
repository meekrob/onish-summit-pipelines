#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --time=0:01:00
#SBATCH --qos=normal
#SBATCH --ntasks=1
# ---------------------------- Setup ----------------------------
# 2c. Generate self-pseudoreplicates for each replicate (SE datasets)
NTHREADS=$SLURM_NTASKS # will passthrough the --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc

date # timestamp

# ---------------------------- Software ----------------------------
echo "Using awk:"
awk --version | head -1
echo "Using gzip:"
gzip --version | head -1
echo "Using shuf:"
shuf --version | head -1
echo "Using split:"
split --version | head -1
echo "Using openssl:"
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
# input: TagAlign file ${FINAL_TA_FILE}
FINAL_TA_FILE=$1
echo "FINAL_TA_FILE=$FINAL_TA_FILE"
#
# root,prefix
OFPREFIX=${FINAL_TA_FILE/.SE.tagAlign.gz/}
SEED=${OFPREFIX}-2c
PR_PREFIX="${OFPREFIX}.filt.nodup"
echo "OFPREFIX=${OFPREFIX}"
echo "PR_PREFIX=$PR_PREFIX"
# output: 2 pseudoreplicate virtual SE tagAlign 
#        files ${PR1_TA_FILE}  ${PR2_TA_FILE}

PR1_TA_FILE="${PR_PREFIX}.SE.pr1.tagAlign.gz"
PR2_TA_FILE="${PR_PREFIX}.SE.pr2.tagAlign.gz"
echo "PR1_TA_FILE=$PR1_TA_FILE"
echo "PR2_TA_FILE=$PR2_TA_FILE"

# ========================
# Create pseudoReplicates
# =======================

# Get total number of read pairs
nlines=$( zcat ${FINAL_TA_FILE} | wc -l )
nlines=$(( (nlines + 1) / 2 ))

# Shuffle and split BED file into 2 equal parts
echo "SEED=$SEED"
cmd="zcat ${FINAL_TA_FILE} | shuf --random-source=<(get_seeded_random $SEED)  | split -d -l ${nlines} - ${PR_PREFIX} " # Will produce ${PR_PREFIX}00 and ${PR_PREFIX}01
echo $cmd
eval $cmd

# Convert reads into standard tagAlign file
gzip1="gzip -nc ${PR_PREFIX}00 > ${PR1_TA_FILE}"
echo $gzip1
eval $gzip1
gzip2="gzip -nc ${PR_PREFIX}01 > ${PR2_TA_FILE}"
echo $gzip2
eval $gzip2
# cleanup
set -x
rm "${PR_PREFIX}00" "${PR_PREFIX}01"
set +x

pychecksum.py ${PR1_TA_FILE} md5 # filestamp
pychecksum.py ${PR2_TA_FILE} md5 # filestamp
