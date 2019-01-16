#!/usr/bin/env bash
date # timestamp

bamfile=$1
if [ -z $bamfile ]
then
    echo "You must specify a file in BAM format" >&2
    echo "USAGE: $0 file.bam"
    exit 1
fi


# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
SCRIPT_DIR=$PROJ_DIR/pipelines/tool_wrappers

if jid=$(sbatch --parsable $SCRIPT_DIR/bedtools_bamtobed.sbatch $bamfile) 
then
    echo "Job $jid submitted"
else
    echo "Error in job submission... quitting." >&2
    exit 1
fi

# output will be called:
bedfile=${bamfile/.bam/.bed}
sbatch --dependency=afterok:$jid $SCRIPT_DIR/bedToBw.sbatch $bedfile

