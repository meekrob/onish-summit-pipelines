#!/usr/bin/env bash
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3
source $PIPELINE/OUTER_VARS.sh

if [ $# -eq 0 ];
then
    echo "Print logfile template for a jobstep"
    echo "$0 jobstep"
    echo "$0 jobstep sample_id"
    exit 1
fi

step=$1
sample_id=${2:-"SAMPLE_ID"}

case $step in
1a)
    next_step_outfile=$sample_id.raw.srt.bam
    next_step_logfile=${next_step_outfile}.log-%j
    echo $next_step_logfile
;;
1b)
    next_step_infile=$(raw_bam_file $sample_id)
    next_step_outfile=${next_step_infile/.raw.srt.bam/.filt.nodup.srt.bam}
    next_step_logfile=${next_step_outfile/.bam/.log-%j}
    echo $next_step_logfile
;;
2a)
    next_step_logfile="$(final_bam_prefix $sample_id).SE.tagAlign.log-%j"
    echo $next_step_logfile
;;
2b)
    SUBSAMPLED_TA_FILE=$(subsampled_ta_file $sample_id)
    next_step_log_2b="${SUBSAMPLED_TA_FILE/.gz/}.cc.qc.log-%j"
    echo $next_step_log_2b
;;
2c)
    FINAL_TA_FILE=$(final_ta_file $sample_id)
    next_step_log_2c="${FINAL_TA_FILE/.SE.tagAlign.gz/}.filt.nodup.log-%j"
    echo $next_step_log_2c
;;
*)
    echo "$step not found" >&2
    exit 1
;;
esac

