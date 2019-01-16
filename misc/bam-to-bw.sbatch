#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:15:00
#SBATCH --qos=normal
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
# --------------------- Setup -----------------------
NTHREADS=$SLURM_NTASKS # will passthrough the --ntasks set above
ATHREADS=$(expr $NTHREADS - 1) # A-additional threads
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR

PROJ_DIR=/projects/dcking@colostate.edu
cl=$PROJ_DIR/support_data/ce11/ce11.chrom.sizes
source $PROJ_DIR/paths.bashrc
bamfile=$1

bedfile=${bamfile/.bam/.bed}

cmd="bedtools bamtobed -i $bamfile > $bedfile"
echo $cmd
time eval $cmd

bwfile=${bedfile/.bed/x150n.bw}
cmd="bedToBw.sh $bedfile 150 $cl -n -bw"
echo $cmd
eval time $cmd

cmd="bigWigInfo $bwfile"
eval $cmd
