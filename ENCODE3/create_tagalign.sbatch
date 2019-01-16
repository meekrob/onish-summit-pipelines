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
infile=$1
infile_base=$(basename $infile)
outfile=${infile_base/bam/SE.tagAlign.gz}


_awk_make_tagalign_cols_()
{
    awk 'BEGIN{OFS="\t"}{$4="N";$5="1000";print $0}'
}

#cmd="bedtools bamtobed -i ${infile} | _awk_make_tagalign_cols_ | gzip -nc > ${outfile}"
cmd="bedtools bamtobed -i ${infile} | _awk_make_tagalign_cols_ > ${outfile}"

declare -f _awk_make_tagalign_cols_
echo $cmd
time eval $cmd
