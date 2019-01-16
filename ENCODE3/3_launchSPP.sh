#!/usr/bin/env bash
# Using the checking logic in jobstep, compile the SPP jobs and launch them
PRJ=/projects/dcking@colostate.edu
PIPELINE=/projects/dcking@colostate.edu/pipelines/ENCODE3
source $PIPELINE/OUTER_VARS.sh

# 3a_SPP uses REL_PEAK_DIR from OUTER_VARS as its output location
# thus 4_idr must use it as the location for input files
PEAK_OUTPUT_DIR=$REL_PEAK_DIR

DATASET_PREFIX=${1%/}
# Enter subdir #
cd $DATASET_PREFIX

# detect replicates and control
CONTROL_TA_PREFIX=${DATASET_PREFIX}.control
FRAG=205

get_fraglen()
{
    # get from REP_PREFIX
    pfx=$1
    rep_filename=$(basename $(readlink $pfx.tagAlign.gz))
    sample_name=${rep_filename%%.*}
    samp_cc_scores_file=../$(cc_scores_file $sample_name)
    cut -f3 $samp_cc_scores_file
}

#### primary replicates and their pooled file
REP1_PREFIX=$DATASET_PREFIX.Rep1
cmd="sbatch --parsable -o rep1Vcontrol.log-%j $PIPELINE/3a_SPP.sbatch $REP1_PREFIX $CONTROL_TA_PREFIX $(get_fraglen $REP1_PREFIX)"
echo $cmd
rep1jid=$(eval $cmd)
echo $rep1jid

REP2_PREFIX=$DATASET_PREFIX.Rep2
cmd="sbatch --parsable -o rep2Vcontrol.log-%j $PIPELINE/3a_SPP.sbatch $REP2_PREFIX $CONTROL_TA_PREFIX $(get_fraglen $REP2_PREFIX)"
echo $cmd
rep2jid=$(eval $cmd)
echo $rep2jid

POOLED_TA_PREFIX=${DATASET_PREFIX}.Rep0
cmd="sbatch --parsable -o pooledVcontrol.log-%j $PIPELINE/3a_SPP.sbatch $POOLED_TA_PREFIX $CONTROL_TA_PREFIX $(get_fraglen $REP1_PREFIX)"
echo $cmd
pooledTAjid=$(eval $cmd)
echo $pooledTAjid


#### 4a. for true replicates. True replicate 1, true replicate 2, pooled replicates.
dependency="afterok:$rep1jid,afterok:$rep2jid,afterok:$pooledTAjid"
idr_launch="sbatch -o 4a_primary_IDR.log-%j -d $dependency $PIPELINE/4_IDR.sbatch \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP1_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP2_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $POOLED_TA_PREFIX $CONTROL_TA_PREFIX) primaryReps"
echo $idr_launch
$idr_launch
# Nt = best number of peaks passing IDR threshold by comparing true replicates


#### 4b. IDR analysis - self-pseudoreplicates

## N1, Rep1 pr1/pr2, using rep1 peak file as pooled file
REP1_PR1_TA_PREFIX=${DATASET_PREFIX}.Rep1.pr1
cmd="sbatch --parsable -o rep1pr1Vcontrol.log-%j  $PIPELINE/3a_SPP.sbatch $REP1_PR1_TA_PREFIX $CONTROL_TA_PREFIX $FRAG"
echo $cmd
rep1pr1jid=$(eval $cmd)
echo $rep1pr1jid

REP1_PR2_TA_PREFIX=${DATASET_PREFIX}.Rep1.pr2
cmd="sbatch --parsable -o rep1pr2Vcontrol.log-%j  $PIPELINE/3a_SPP.sbatch $REP1_PR2_TA_PREFIX $CONTROL_TA_PREFIX $FRAG"
echo $cmd
rep1pr2jid=$(eval $cmd)
echo $rep1pr2jid

dependency="afterok:$rep1pr1jid,afterok:$rep1pr2jid,afterok:$rep1jid"
idr_launch="sbatch -o 4b_selfpseudo1_IDR.log-%j -d $dependency $PIPELINE/4_IDR.sbatch \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP1_PR1_TA_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP1_PR2_TA_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP1_PREFIX $CONTROL_TA_PREFIX) selfPseudoReps1"
echo $idr_launch
$idr_launch
# N1 = No. of peaks passing IDR threshold by comparing self-pseudoReplicates for Rep1

## N2, Rep2 pr1/pr2, using rep2 peak file as pooled file
REP2_PR1_TA_PREFIX=${DATASET_PREFIX}.Rep2.pr1
cmd="sbatch --parsable -o rep2pr1Vcontrol.log-%j  $PIPELINE/3a_SPP.sbatch $REP2_PR1_TA_PREFIX $CONTROL_TA_PREFIX $FRAG"
echo $cmd
rep2pr1jid=$(eval $cmd)
echo $rep2pr1jid

REP2_PR2_TA_PREFIX=${DATASET_PREFIX}.Rep2.pr2
cmd="sbatch --parsable -o rep2pr2Vcontrol.log-%j  $PIPELINE/3a_SPP.sbatch $REP2_PR2_TA_PREFIX $CONTROL_TA_PREFIX $FRAG"
echo $cmd
rep2pr2jid=$(eval $cmd)
echo $rep2pr2jid

dependency="afterok:$rep2pr1jid,afterok:$rep2pr2jid,afterok:$rep2jid"
idr_launch="sbatch -o 4b_selfpseudo2_IDR.log-%j -d $dependency $PIPELINE/4_IDR.sbatch \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP2_PR1_TA_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP2_PR2_TA_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $REP2_PREFIX $CONTROL_TA_PREFIX) selfPseudoReps2"
echo $idr_launch
$idr_launch
## N2 = No. of peaks passing IDR threshold by comparing self-pseudoReplicates for Rep2

#### 4c. IDR analysis - pooled pseudoreplicates
PPR1_TA_PREFIX=${DATASET_PREFIX}.Rep0.pr1
cmd="sbatch --parsable -o ppr1Vcontrol.log-%j  $PIPELINE/3a_SPP.sbatch $PPR1_TA_PREFIX $CONTROL_TA_PREFIX $FRAG"
echo $cmd
ppr1jid=$(eval $cmd)
echo $ppr1jid

PPR2_TA_PREFIX=${DATASET_PREFIX}.Rep0.pr2
cmd="sbatch --parsable -o ppr2Vcontrol.log-%j  $PIPELINE/3a_SPP.sbatch $PPR2_TA_PREFIX $CONTROL_TA_PREFIX $FRAG"
echo $cmd
ppr2jid=$(eval $cmd)
echo $ppr2jid

dependency="afterok:$ppr1jid,afterok:$ppr2jid,afterok:$pooledTAjid"
idr_launch="sbatch -o 4c_pooledPseudo_IDR.log-%j -d $dependency $PIPELINE/4_IDR.sbatch \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $PPR1_TA_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $PPR2_TA_PREFIX $CONTROL_TA_PREFIX) \
    $PEAK_OUTPUT_DIR/$(get_filt_rpeakfile $POOLED_TA_PREFIX $CONTROL_TA_PREFIX) pooledPseudoReps"
echo $idr_launch
$idr_launch

## Np = No of peaks passing IDR threshold by comparing pooled pseudo-replicates

# 4f. IDR QC scores
# 
