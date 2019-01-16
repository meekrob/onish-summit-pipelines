#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --output=bedToBw-%j.out
#SBATCH --partition=shas
echo "[$0] $SLURM_JOB_NAME $@" # log the command line

bedfile=$1

if [ -z $bedfile ]
then
    echo "$0 infile.bed" >&2
    exit 1
fi


# the outfile name is not specified in the command but will take the following form:
outfile=${bedfile/.bed/x150n.bw}
echo "outfile name will be: $outfile"

PROJ_DIR=/projects/dcking@colostate.edu
cl=$PROJ_DIR/support_data/ce11/ce11.chrom.sizes

cmd="bedToBw.sh $bedfile 150 $cl -n -bw"
echo $cmd
if [ -n "$SLURM_JOB_NAME" ]
then
    source $PROJ_DIR/paths.bashrc
    # this command creates at least two tempfiles, use one on scratch space
    export TMPDIR=$SLURM_SCRATCH
    export TEMPDIR=$SLURM_SCRATCH
    eval time $cmd
else
    echo "::: dry run :::"
fi

