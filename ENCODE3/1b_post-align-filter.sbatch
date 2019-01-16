#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --ntasks=12
# ---------------------------- Setup ----------------------------
NTHREADS=${SLURM_NTASKS:-1} # will passthrough the --ntasks set above
ATHREADS=$(expr $NTHREADS - 1) # A-additional threads
echo -e "\e[30m\e[1m[$0] $SLURM_JOB_NAME $@\e[0m" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
# set bin, etc.
PRJ=/projects/dcking@colostate.edu
source $PRJ/paths.bashrc
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3
date # timestamp

# ---------------------- Software Versions ------------------------
echo "Using samtools:"
samtools --version
echo "Using picard MarkDuplicates:"
picard MarkDuplicates -h 2>&1 |  grep ^Version
echo "Using bedtools:"
bedtools --version

# ----------------------  Files -----------------------
#
# input: RAW_BAM_FILE: sample.raw.srt.bam 
#
RAW_BAM_FILE=$1
OFPREFIX=${1%%.*} # delete the first-dot and beyond
#
# output: FINAL_BAM_FILE, FINAL_BAM_INDEX_FILE, FINAL_BAM_FILE_MAPSTATS, DUP_FILE_QC, PBC_FILE_QC
#
FILT_BAM_PREFIX="${OFPREFIX}.filt.srt"
FILT_BAM_FILE="${FILT_BAM_PREFIX}.bam"
MAPQ_THRESH=30

# --------------------- For Color Terminals  -----------------------
bold() {
    echo -e "\e[1m$@\e[0m"
}

echo -e "\e[32m"
echo "Sam Flags"
set -x
# $ samtools help flags
# Sam Flags:
#   0x1 PAIRED        .. paired-end (or multiple-segment) sequencing technology
#   0x2 PROPER_PAIR   .. each segment properly aligned according to the aligner
#   0x4 UNMAP         .. segment unmapped
UNMAP="0x4" # 4
#   0x8 MUNMAP        .. next segment in the template unmapped
MUNMAP="0x8" # 8
#   0x10    REVERSE       .. SEQ is reverse complemented
#   0x20    MREVERSE      .. SEQ of the next segment in the template is reversed
#   0x40    READ1         .. the first segment in the template
#   0x80    READ2         .. the last segment in the template
#   0x100   SECONDARY     .. secondary alignment
SECONDARY="0x100" # 256
#   0x200   QCFAIL        .. not passing quality controls
FAILS_V_CHECKS="0x200" # 512. V- vendor
#   0x400   DUP           .. PCR or optical duplicate
PCR_DUPLICATE="0x400" # 1024
#   0x800   SUPPLEMENTARY .. supplementary alignment
SAM_FLAGS=$(( $UNMAP | $MUNMAP | $SECONDARY | $FAILS_V_CHECKS | $PCR_DUPLICATE )) ## bitwise OR the individual flags
set +x
echo -e "\e[39m"

# =============================
# Remove  unmapped, mate unmapped
# not primary alignment, reads failing platform
# Remove low MAPQ reads
# ==================  

samtools_view_cmd="samtools view -F $SAM_FLAGS -q ${MAPQ_THRESH} -b ${RAW_BAM_FILE} -@ $ATHREADS > ${FILT_BAM_FILE}"
echo "$(bold samtools_view_cmd:)$samtools_view_cmd"
time eval $samtools_view_cmd

# ========================
# Mark duplicates
# ======================
echo -e "\e[32m"
set -x
TMP_FILT_BAM_FILE="${FILT_BAM_PREFIX}.dupmark.bam"
#MARKDUP="/srv/gs1/software/picard-tools/1.126/picard MarkDuplicates"
DUP_FILE_QC="${FILT_BAM_PREFIX}.dup.qc" # QC file
set +x
echo -e "\e[39m"

#java -Xmx4G -jar ${MARKDUP} INPUT=${FILT_BAM_FILE} OUTPUT=${TMP_FILT_BAM_FILE} METRICS_FILE=${DUP_FILE_QC} VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true REMOVE_DUPLICATES=false
picard_cmd="picard -Xmx4G MarkDuplicates INPUT=${FILT_BAM_FILE} OUTPUT=${TMP_FILT_BAM_FILE} METRICS_FILE=${DUP_FILE_QC} VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true REMOVE_DUPLICATES=false"
echo "$(bold picard_cmd:)$picard_cmd"
time eval $picard_cmd

mv_cmd="mv ${TMP_FILT_BAM_FILE} ${FILT_BAM_FILE}"
echo "$(bold mv_cmd:)$mv_cmd"
eval $mv_cmd

# ============================
# Remove duplicates
# Index final position sorted BAM
# ============================

echo -e "\e[32m"
set -x
FINAL_BAM_PREFIX="${OFPREFIX}.filt.nodup.srt"
FINAL_BAM_FILE="${FINAL_BAM_PREFIX}.bam" # To be stored
FINAL_BAM_INDEX_FILE="${FINAL_BAM_PREFIX}.bai" # To be stored
FINAL_BAM_FILE_MAPSTATS="${FINAL_BAM_PREFIX}.flagstat.qc" # QC file
set +x
echo -e "\e[39m"

filter_sam_view_cmd="samtools view -F $SAM_FLAGS -b ${FILT_BAM_FILE} -@ $ATHREADS > ${FINAL_BAM_FILE}"
echo "$(bold filter_sam_view_cmd:) $filter_sam_view_cmd"
time eval $filter_sam_view_cmd

# Index Final BAM file
bam_index_cmd="samtools index ${FINAL_BAM_FILE} ${FINAL_BAM_INDEX_FILE}"
echo "$(bold bam_index_cmd:) $bam_index_cmd"
time eval $bam_index_cmd


final_flagstat_cmd="samtools flagstat ${FINAL_BAM_FILE} > ${FINAL_BAM_FILE_MAPSTATS}"
echo "$(bold final_flagstat_cmd:) $final_flagstat_cmd"
time eval $final_flagstat_cmd

# =============================
# Compute library complexity
# =============================
# sort by position and strand
# Obtain unique count statistics

#module add bedtools/2.26.0

PBC_FILE_QC="${FINAL_BAM_PREFIX}.pbc.qc"

# PBC File output
# TotalReadPairs [tab] DistinctReadPairs [tab] OneReadPair [tab] TwoReadPairs [tab] NRF=Distinct/Total [tab] PBC1=OnePair/Distinct [tab] PBC2=OnePair/TwoPair

bedtools_cmd="bedtools bamtobed -i ${FILT_BAM_FILE} | awk 'BEGIN{OFS="\t"}{print \$1,\$2,\$3,\$6}' | grep -v 'chrM' | sort | uniq -c | awk 'BEGIN{mt=0;m0=0;m1=0;m2=0} (\$1==1){m1=m1+1} (\$1==2){m2=m2+1} {m0=m0+1} {mt=mt+\$1} END{printf \"%d\t%d\t%d\t%d\t%f\t%f\t%f\n\",mt,m0,m1,m2,m0/mt,m1/m0,m1/m2}' > ${PBC_FILE_QC}"
echo "$(bold bedtools_cmd:)$bedtools_cmd"
time eval $bedtools_cmd
echo "wrote ${PBC_FILE_QC}"

rm_cmd="rm ${FILT_BAM_FILE}"
echo "$(bold rm_cmd:)$rm_cmd"
eval $rm_cmd

# --------------------- Launch next job ---------------
next_step_logfile="${FINAL_BAM_PREFIX}.SE.tagAlign.log-%j"
sbatch -o $next_step_logfile pipeline/2a_SE_bam_to_TagAlign.sbatch ${FINAL_BAM_FILE}
