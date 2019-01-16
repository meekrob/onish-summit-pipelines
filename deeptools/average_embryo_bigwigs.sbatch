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


rep1="AR100_over_AR103_minus_AR102_over_AR103.x150n.bw"
#rep2="AR120_over_AR122_minus_AR121_over_AR122.x150n.bw"
# Missing AR105_Over etc. etc. (maybe because AR106(IgG) failed. Check into the EO60 series
rep3="AR109_over_AR111_minus_AR110_over_AR111.x150n.bw"
rep4="AR128_over_AR130_minus_AR129_over_AR130.x150n.bw"
wigfilename="Embryo_input_norm_igg_subtracted.wig"
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
