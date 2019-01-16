#!/usr/bin/env bash

if [ $# -eq 0 ];
then
    echo "start the chain"
    echo "$0 ../01_RAW/file.fastq"
    exit 1
fi

fastqfile=$1
fileroot=$(basename ${fastqfile%.*}) # notdir, noext
next_step_outfile=$fileroot.raw.srt.bam
next_step_logfile=${next_step_outfile}.log-%j

cmd="sbatch -o $next_step_logfile --parsable pipeline/1a_bwa.sbatch $fastqfile"
echo $cmd
eval $cmd
