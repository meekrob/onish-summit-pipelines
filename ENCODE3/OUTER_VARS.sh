##### OUTER_VARS.sh
# This is a sourced file that uses functions to define the shared
# variables used in ENCODE scripts, given the same name like AR100.
# Some constants, used regardless of sample, are defined here.
##

# CONSTANTS
readonly BWA_INDEX_NAME=ce11.unmasked.fa
readonly BLACKLIST=/projects/dcking@colostate.edu/support_data/ce11/ce11-blacklist.bed.gz
readonly REL_PEAK_DIR="Peaks"

die()
{
    echo $@ > /dev/stdout
    exit 1
}

# use like 
#FASTQ_FILE_1=$(fastq_file_1 AR100)
fastq_file_1()
{
    sample=$1
    dir=${2:-../01_RAW} # optional directory with default
    if [ -e "$dir/$1.trimmed.fastq" ]
    then
        echo "$dir/$1.trimmed.fastq"
    elif [ -e "$dir/$1.fastq" ]
    then
        echo "$dir/$1.fastq"
    else
        die "no fastq for $1 found in $dir"
    fi
}

raw_bam_prefix()
{
    echo "$1.raw.srt"
}

raw_bam_file()
{
    # Created by: 1a.
    # Used by: 1b to create final_bam_file.
    echo "$(raw_bam_prefix $1).bam"
}

final_ta_file()
{
    echo "$1.SE.tagAlign.gz"
}

cc_scores_file()
{
    stf=$(subsampled_ta_file $1)
    echo ${stf%%.gz}.cc.qc
}

cc_plot_file()
{
    stf=$(subsampled_ta_file $1)
    echo ${stf%.gz}.cc.plot.pdf
}

subsampled_ta_file()
{
    # should $NREADS be passed as $2?
    NREADS=15000000
    echo "$1.filt.nodup.sample.$((NREADS / 1000000)).SE.tagAlign.gz"
}

ofprefix()
{
    echo $1
}

pr_prefix()
{
    echo $1.filt.nodup
}

pr1_ta_file()
{
    # Made by: 2c, from FINAL_TA_FILE
    # Used by: 2d, to create pooled replicates.
    # Will return something like: SAMPLE.filt.nodup.SE.pr1.tagAlign.gz
    echo $(pr_prefix $1).SE.pr1.tagAlign.gz
}
pr2_ta_file()
{
    # Made by: 2c, from FINAL_TA_FILE
    # Used by: 2d, to create pooled replicates.
    # Will return something like: SAMPLE.filt.nodup.SE.pr2.tagAlign.gz
    echo $(pr_prefix $1).SE.pr2.tagAlign.gz
}

final_bam_prefix()
{
    # Made by: 1b, from RAW_BAM_FILE
    # Used by: 2a, to create FINAL_TA_FILE and SUBSAMPLED_TA_FILE
    echo $1.filt.nodup.srt
}

final_bam_file()
{
    echo $(final_bam_prefix $1).bam
}

final_bam_index_file()
{
    echo $(final_bam_prefix $1).bai
}

# the following are used to name files during 3a_SPP, and thus are input for 4_IDR
get_rpeakfile_raw()
{
    CHIP_TA_PREFIX=$1
    CONTROL_TA_PREFIX=$2
    # copied directly from 3a
    echo ${CHIP_TA_PREFIX}.tagAlign_VS_${CONTROL_TA_PREFIX}.tagAlign.regionPeak.gz
}

get_rpeakfile()
{
    CHIP_TA_PREFIX=$1
    CONTROL_TA_PREFIX=$2
    echo ${CHIP_TA_PREFIX}.tagAlign_x_${CONTROL_TA_PREFIX}.tagAlign.regionPeak.gz
}

get_filt_rpeakfile()
{
    CHIP_TA_PREFIX=$1
    CONTROL_TA_PREFIX=$2
    echo ${CHIP_TA_PREFIX}.tagAlign_x_${CONTROL_TA_PREFIX}.tagAlign.filt.regionPeak.gz
}
# Some shell cmds used in pipes in 
# more than one place.
_grep_valid_chrom_()
{
    # chrom must be chr + a arabic (normal) numeral for some genomes, roman numeral for c. Elegans or 'X' or 'Y'
    grep -P 'chr[\dIVXY]+[ \t]'
}
_awk_max_1000_col5_()
{ 
    # set max of col5 to 1000
    awk 'BEGIN{OFS="\t"} {if ($5>1000) $5=1000; print $0}'
}

### utilities for the command line
awk_filter_narrowpeak_q()
{
    q=$1 # select all lines where column 9 is > -log10(q)
    awk -v q=$q '$9 > -log(q)/log(10) { print $0 }'
}
