#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=0:30:00
#SBATCH --qos=normal
#SBATCH --output=bowbam-%j.out
# --------------------- Setup -----------------------
NTHREADS=$SLURM_NTASKS # will passthrough the --ntasks set above
ATHREADS=$(expr $NTHREADS - 1) # A-additional threads
echo "[$0] $SLURM_JOB_NAME $@" # log the command line

PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
infile=$1
echo "infile is $infile"

root=$(basename $infile)
root=${root%%.fastq} # delete the file extension

echo "root is $root"

outfile=${root}.sam
echo "outfile is $outfile"

# run bowtie
cmd="bowtie -a -q -S --nomaqround -m 1 -p $NTHREADS --best --chunkmbs 200 --seed 123 $BOWTIE_INDEXES/ce11 $infile $outfile"
echo $cmd
time $cmd
# check for nonzero shell
if [ $? -ne 0 ]
then
    >&2 echo "bowtie command failed."
    exit 1
fi

# samtools quickcheck
cmd="samtools quickcheck $outfile"
echo $cmd
eval $cmd
if [ $? -ne 0 ]
then
    >&2 echo "bowtie command passed, but the output file \'$outfile\' failed integrity check."
    exit 1
fi
# create bam from sam
infile=$outfile
outfile=${infile/.sam/.bam}
cmd="samtools view -b -S ${infile} -@ $ATHREADS -o ${outfile}"
echo $cmd
time $cmd
# bam sort
infile=$outfile
outfile=${infile/.bam/.sorted.bam}
cmd="samtools sort -@ $ATHREADS -o $outfile $infile"
echo $cmd
time eval $cmd

# bam index
cmd="samtools index $outfile"
echo $cmd
time eval $cmd

## launch the bedToBw thread
#infile=$outfile
#outfile=${infile/.bam/.bed}
#logfile=${infile/.bam/.bed.log-%j}
#sbatch -o $logfile pipeline/bam-to-bed.sbatch $infile
