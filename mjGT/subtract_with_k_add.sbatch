#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=0:05:00
#SBATCH --qos=normal
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
# --------------------- Setup -----------------------
NTHREADS=${SLURM_NTASKS:-1} # will passthrough the --ntasks set above
ATHREADS=$(expr $NTHREADS - 1) # A-additional threads
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR

PROJ_DIR=/projects/dcking@colostate.edu
cl=$PROJ_DIR/support_data/ce11/ce11.chrom.sizes
source $PROJ_DIR/paths.bashrc

minuend=$1
exp=${minuend%%.*}
subtrahend=$2
igg=${subtrahend%%.*}

konstant=$3
# Do the subtraction of the BigWigs
wigfilename="${exp}_minus_${igg}_plus_${konstant}.x150n.wig"
cmd="meekrob-javaGenomicsToolkit wigmath.CustomEquation_2 -p $NTHREADS -m $minuend -s $subtrahend -k $konstant -o $wigfilename"
echo $cmd

if [ -n "$SLURM_JOB_NAME" ];
then

    time eval $cmd
    # Convert wig output to bigwig
    bwfilename=${wigfilename/.wig/.bw}
    cmd="wigToBigWig $wigfilename $cl $bwfilename"
    echo $cmd
    time eval $cmd
    # Check bigwig integrity
    cmd="bigWigInfo $bwfilename"
    eval $cmd
    chk=$?
    if [  $chk == 0 ];
    then 
        echo "BigWig OK: deleting wig file"
        rm -v $wigfilename
    else
        echo "Check failed {$chk}"
        exit $chk
    fi
else
    echo "__dry run__"
fi
