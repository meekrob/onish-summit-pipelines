#!/usr/bin/env bash
#2d. Generate pooled dataset and pooled-pseudoreplicates
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=normal
#SBATCH --time=1:00:00
# ---------------------------- Setup ----------------------------
NTHREADS=$SLURM_NTASKS # will passthrough the --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3
source $PIPELINE/OUTER_VARS.sh

date # timestamp

# ---------------------------- Software ----------------------------
echo "Using zcat:"
zcat --version | head -1
echo

# ---------------------- Files -----------------------
#
# input: TagAlign file ${FINAL_TA_FILE} from one sample replicate ${REP1_TA_FILE}, 
#          and         ${FINAL_TA_FILE} from its other  replicate ${REP2_TA_FILE}
#         versus       ${FINAL_TA_FILE} from control
sample_1=$1 # from 2a of AR116:  AR116.SE.tagAlign.gz
sample_2=$2 # from 2a of AR120:  AR120.SE.tagAlign.gz
control=$3
DATASET_PREFIX=${4%/}

# ========================
# Create working directory
# =======================
# check for subdirectory
if [ ! -d $DATASET_PREFIX ];
then
    mkdir -v $DATASET_PREFIX
fi

cd $DATASET_PREFIX

# ========================
# Create pooled datasets
# =======================
REP1_TA_FILE=${DATASET_PREFIX}.Rep1.tagAlign.gz
if [ ! -e $REP1_TA_FILE ]
then
    ln -vs ../$(final_ta_file $sample_1) $REP1_TA_FILE
fi

REP2_TA_FILE=${DATASET_PREFIX}.Rep2.tagAlign.gz
if [ ! -e $REP2_TA_FILE ]
then
    ln -vs ../$(final_ta_file $sample_2) $REP2_TA_FILE
fi

CONTROL_TA_FILE=${DATASET_PREFIX}.control.tagAlign.gz
if [ ! -e $CONTROL_TA_FILE ]
then
    ln -vs ../$(final_ta_file $control) $CONTROL_TA_FILE
fi

POOLED_TA_FILE=${DATASET_PREFIX}.Rep0.tagAlign.gz
zcat_cmd="zcat ${REP1_TA_FILE} ${REP2_TA_FILE} | gzip -nc > ${POOLED_TA_FILE}"
echo $zcat_cmd
eval $zcat_cmd

# ========================
# Create pooled pseudoreplicates
# =======================
# rep 1, pseudoreplicate 1
REP1_PR1_TA_FILE=${DATASET_PREFIX}.Rep1.pr1.tagAlign.gz
# rep 1, pseudoreplicate 2
REP1_PR2_TA_FILE=${DATASET_PREFIX}.Rep1.pr2.tagAlign.gz

### link sample_1 pseudo-replicates, if needed
if [ ! -e $REP1_PR1_TA_FILE ]
then
    ln -vs ../$(pr1_ta_file $sample_1) $REP1_PR1_TA_FILE
fi
if [ ! -e $REP1_PR2_TA_FILE ]
then
    ln -vs ../$(pr2_ta_file $sample_1) $REP1_PR2_TA_FILE
fi

# rep 2, pseudoreplicate 1
REP2_PR1_TA_FILE=${DATASET_PREFIX}.Rep2.pr1.tagAlign.gz
# rep 2, pseudoreplicate 2
REP2_PR2_TA_FILE=${DATASET_PREFIX}.Rep2.pr2.tagAlign.gz

### link sample_2 pseudo-replicates, if needed
if [ ! -e $REP2_PR1_TA_FILE ]
then
    ln -vs ../$(pr1_ta_file $sample_2) $REP2_PR1_TA_FILE
fi
if [ ! -e $REP2_PR2_TA_FILE ]
then
    ln -vs ../$(pr2_ta_file $sample_2) $REP2_PR2_TA_FILE
fi


# pooled pseudoreplicate 1 TA file
PPR1_TA_FILE=${DATASET_PREFIX}.Rep0.pr1.tagAlign.gz
# pooled pseudoreplicate 2 TA file
PPR2_TA_FILE=${DATASET_PREFIX}.Rep0.pr2.tagAlign.gz

zcat ${REP1_PR1_TA_FILE} ${REP2_PR1_TA_FILE} | gzip -nc > ${PPR1_TA_FILE}
zcat ${REP1_PR2_TA_FILE} ${REP2_PR2_TA_FILE} | gzip -nc > ${PPR2_TA_FILE}


#pychecksum.py outfile md5 # filestamp
