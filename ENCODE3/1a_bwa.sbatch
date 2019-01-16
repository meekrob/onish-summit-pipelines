#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH --ntasks=12
# --------------------- Setup -----------------------
NTHREADS=$SLURM_NTASKS # will passthrough the --ntasks set above
ATHREADS=$(expr $NTHREADS - 1) # A-additional threads
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR

# set bin, etc.
PRJ=/projects/dcking@colostate.edu
source $PRJ/paths.bashrc
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3

# ----------------- Software Versions -----------------
echo "using bwa"
bwa 2>&1 | head -4 | tail -3
echo "using samtools"
samtools --version

# ----------------------  Files -----------------------
#
# input: sample.fastq, bwa indexes
#
FASTQ_FILE_1=$1
BWA_INDEX_NAME=ce11.unmasked.fa
echo "FASTQ_FILE_1=$FASTQ_FILE_1"
#
# output: BAM file, mapping stats from flag stat
#
OFPREFIX=$(basename ${FASTQ_FILE_1%.*}) # notdir, noext
echo "OFPREFIX=$OFPREFIX"
SAI_FILE_1="${OFPREFIX}.sai"
RAW_BAM_PREFIX="${OFPREFIX}.raw.srt"
RAW_BAM_FILE="${RAW_BAM_PREFIX}.bam" # To be stored
RAW_BAM_FILE_MAPSTATS="${RAW_BAM_PREFIX}.flagstat.qc" # QC File

echo "SAI_FILE_1=$SAI_FILE_1"
echo "RAW_BAM_PREFIX=$RAW_BAM_PREFIX"
echo "RAW_BAM_FILE=$RAW_BAM_FILE"
echo "RAW_BAM_FILE_MAPSTATS=$RAW_BAM_FILE_MAPSTATS"

# ---------------------------------------------------


# ========================================
# Map reads to create raw SAM file
# ========================================


#aln_cmd="bwa aln -q 5 -l 32 -k 2 -t ${NTHREADS} ${BWA_INDEX_NAME} ${FASTQ_FILE_1} > ${SAI_FILE_1}"
aln_cmd="bwa aln -t ${NTHREADS} ${BWA_INDEX_NAME} ${FASTQ_FILE_1} > ${SAI_FILE_1}"
echo $aln_cmd
time eval $aln_cmd

sort_prefix="$TMPDIR/samsort_$SLURM_JOB_ID"
samse_cmd="bwa samse ${BWA_INDEX_NAME} ${SAI_FILE_1} ${FASTQ_FILE_1} | samtools view -@ $ATHREADS -Su - | samtools sort -T $sort_prefix -@ $ATHREADS -o ${RAW_BAM_FILE}"
echo $samse_cmd
time eval $samse_cmd

pychecksum.py ${RAW_BAM_FILE} md5 # filestamp

rm ${SAI_FILE_1}

flagstat_cmd="samtools flagstat ${RAW_BAM_FILE} > ${RAW_BAM_FILE_MAPSTATS}"
echo $flagstat_cmd
time eval $flagstat_cmd
cat ${RAW_BAM_FILE_MAPSTATS}

pychecksum.py ${RAW_BAM_FILE_MAPSTATS} md5 # filestamp

next_step_infile=${RAW_BAM_FILE}
next_step_outfile=${next_step_infile/.raw.srt.bam/.filt.nodup.srt.bam}
next_step_logfile=${next_step_outfile/.bam/.log-%j}

sbatch -o $next_step_logfile pipeline/1b_post-align-filter.sbatch $next_step_infile
