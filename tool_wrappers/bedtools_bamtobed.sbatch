#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=0:07:00
#SBATCH --qos=normal
#SBATCH --output=bedtools_bamtobed-%j.out
echo "[$0] $SLURM_JOB_NAME $@" # log the command line

bamfile=$1

if [ -z $bamfile ]
then
    echo "$0 infile.bam" >&2
    exit 1
fi

outfile=${bamfile/.bam/.bed}
echo "outfile name will be: $outfile"

cmd="bedtools bamtobed -i $bamfile > $outfile"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ]
then
    PROJ_DIR=/projects/dcking@colostate.edu
    source $PROJ_DIR/paths.bashrc
    eval time $cmd
else
    echo ":::dry run:::"
fi
