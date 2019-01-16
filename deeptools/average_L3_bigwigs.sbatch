#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=0:05:00
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


rep1="AR112_over_AR114_minus_AR113_over_AR114.x150n.bw"
rep2="AR124_over_AR126_minus_AR125_over_AR126.x150n.bw"
rep3="AR136_over_AR138_minus_AR137_over_AR138.x150n.bw"
rep4="EO24_over_EO28_minus_EO27_over_EO28.x150n.bw"
# can't do rep5- EO37 because no IgG is labelled for it
wigfilename="L3_input_norm_igg_subtracted.wig"
cmd="javaGenomicsToolkit wigmath.Average -p $NTHREADS $rep1 $rep2 $rep3 $rep4 -o $wigfilename"
echo $cmd
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
