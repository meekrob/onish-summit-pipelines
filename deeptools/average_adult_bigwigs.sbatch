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


rep1="AR116_over_AR118_minus_AR117_over_AR118.x150n.bw"
#rep2="AR120_over_AR122_minus_AR121_over_AR122.x150n.bw"
# missing AR132
rep3="EO30_over_EO32_minus_EO31_over_EO32.x150n.bw"
rep4="EO38_over_EO42_minus_EO39_over_EO42.x150n.bw"
wigfilename="Adult_input_norm_igg_subtracted.wig"
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
