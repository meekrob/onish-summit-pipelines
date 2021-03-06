#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:10:00
#SBATCH --qos=normal
echo "[$0] $SLURM_JOB_NAME $@" # log the command line

PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
infile=$1
root=${infile%%.fastq} # delete the file extension
echo "infile is $infile"
echo "root is $root"

if [ "$root" == "$infile" ]
then
    >&2 echo "$infile did not have the expected file extension"
    exit 1;
fi

outfile=${root}.dusted.fastq
echo "outfile is $outfile"
artifacts=${root}.dusted.artifacts
SPA=/projects/dcking@colostate.edu/support_data/solexa-library-seqs.fasta
cmd="tagdust -f .001 $SPA $infile -o $outfile -a $artifacts"
echo $cmd
time eval $cmd

if [ $? -ne 0 ]
then
    >&2 echo "tagdust failed on $infile"
    exit 1
fi

# launch next job(s) if not given a second argument, 
# such as `sbatch tagdust.sbatch file.fastq nochain`
if [ -z $2 ];
then
    sbatch pipeline/bowtie.sbatch $outfile
    sbatch pipeline/fastqc.sbatch $outfile
fi
