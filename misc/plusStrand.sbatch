#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --output=slurm-plusStrand-%j.out

echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp
infile=$1
dofile=${infile/.0bed/.plus.bed}
do_cmd="grep '+$' $infile > $dofile"
echo $do_cmd
time eval $do_cmd
sort_cmd="bedSort $dofile $dofile"
echo $sort_cmd
time eval $sort_cmd
# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
CE=$PROJ_DIR/support_data/ce11/ce11.chrom.sizes
bedfile=$dofile
bdgfile=${bedfile/.bed/.bdg}
bdg_cmd="bedtools genomecov -bg -i $bedfile -g $CE > $bdgfile"
echo $bdg_cmd
time eval $bdg_cmd
bwfile=${bdgfile/.bdg/.bw}
bw_cmd="bedGraphToBigWig $bdgfile $CE $bwfile"
echo $bw_cmd
time eval $bw_cmd

