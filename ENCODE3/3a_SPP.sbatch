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
source $PIPELINE/OUTER_VARS.sh
# from OUTER_VARS.sh
PEAK_OUTPUT_DIR=$REL_PEAK_DIR 
blacklist=$BLACKLIST

CHIP_TA_PREFIX=$1
CONTROL_TA_PREFIX=$2
FRAGLEN=$3

SPP=spp # loadbx has bin/spp as wrapper to run_spp.R
spp_cmd="$SPP -c=${CHIP_TA_PREFIX}.tagAlign.gz   \
     -i=${CONTROL_TA_PREFIX}.tagAlign.gz \
     -npeak=300000  \
     -odir=${PEAK_OUTPUT_DIR}  \
     -speak=${FRAGLEN} \
     -savr -savp -rf  \
     -out=${PEAK_OUTPUT_DIR}/${CHIP_TA_PREFIX}.ccscores"

declare -f _grep_valid_chrom_ # show function in logs
declare -f _awk_max_1000_col5_ # show this function in the log

_awk_filter_peakfile_()
{
    # column 2: enforce a min of 0
    # change 2 and 3 to ints
    # print resultant columns 1-10
    awk 'BEGIN{OFS="\t"}{ if ($2<0) $2=0; print $1,int($2),int($3),$4,$5,$6,$7,$8,$9,$10;}' 
}
declare -f _awk_filter_peakfile_ # show this function in the log


echo $spp_cmd
time eval $spp_cmd

#rpeakfile_raw=${CHIP_TA_PREFIX}.tagAlign_VS_${CONTROL_TA_PREFIX}.tagAlign.regionPeak.gz
#rpeakfile=${CHIP_TA_PREFIX}.tagAlign_x_${CONTROL_TA_PREFIX}.tagAlign.regionPeak.gz
#filt_rpeakfile=${CHIP_TA_PREFIX}.tagAlign_x_${CONTROL_TA_PREFIX}.tagAlign.filt.regionPeak.gz

cd $PEAK_OUTPUT_DIR
rpeakfile_raw=$(get_rpeakfile_raw $CHIP_TA_PREFIX $CONTROL_TA_PREFIX)
rpeakfile=$(get_rpeakfile $CHIP_TA_PREFIX $CONTROL_TA_PREFIX)
filt_rpeakfile=$(get_filt_rpeakfile $CHIP_TA_PREFIX $CONTROL_TA_PREFIX)

# filter out peaks in blacklisted region
filter_cmd="zcat $rpeakfile_raw | _awk_filter_peakfile_ | gzip -f -nc > $rpeakfile"
echo $filter_cmd
time eval $filter_cmd
bedtools_cmd="bedtools intersect -v -a <(zcat -f $rpeakfile) -b <(zcat -f $blacklist) | _awk_max_1000_col5_ | _grep_valid_chrom_ | gzip -nc > $filt_rpeakfile"
echo $bedtools_cmd
time eval $bedtools_cmd

