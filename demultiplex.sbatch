#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
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

infile=$1
ext=${infile##*.}

echo "infile is $infile"
echo "ext is $ext"

if [ "$ext" == "gz" ];
then
    cat="gzcat"
else
    cat="cat"
fi

cmd="$cat $infile | fastx_barcode_splitter.pl --bcfile barcode_index_AR100.txt --suffix .fastq --prefix '' --bol"
echo $cmd
time eval $cmd

#pychecksum.py outfile md5 # filestamp
