#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:30:00
#SBATCH --qos=normal
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc


bwCorrelate() {
    rval=$(bigWigCorrelate $1 $2)
    echo -ne $rval
}

# L3 ELT-2s:
arr_elt2_L3=(AR112 AR124 AR136 EO24 EO37)
arr_input_L3=(AR114 AR126 AR138 EO28 EO41)
arr_IgG_L3=(AR113 AR125 AR137 EO27)

fileext=.trimmed.dusted.sortedx150n.bw

len=${#arr_elt2[@]}
first=0
last=$((len - 1))

echo -n "L3:ELT-2" # why no newline?
# header row
for (( i=1; i < ${#arr_elt2_L3[@]}; i++ ))
do
    echo -ne "\t____${arr_elt2_L3[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_elt2_L3[@]} - 1; i++ ))
do
    echo -ne ${arr_elt2_L3[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_elt2_L3[@]}; j++))
    do
        #echo -ne "\t${arr_elt2_L3[$i]}:${arr_elt2_L3[$j]}"
        c=$(bwCorrelate ${arr_elt2_L3[$i]}$fileext ${arr_elt2_L3[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done

echo
echo -n "L3:inpt" # why no newline?
# header row
for (( i=1; i < ${#arr_input_L3[@]}; i++ ))
do
    echo -ne "\t____${arr_input_L3[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_input_L3[@]} - 1; i++ ))
do
    echo -ne ${arr_input_L3[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_input_L3[@]}; j++))
    do
        c=$(bwCorrelate ${arr_input_L3[$i]}$fileext ${arr_input_L3[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done


echo
echo -n "L3:IgG" # why no newline?
# header row
for (( i=1; i < ${#arr_IgG_L3[@]}; i++ ))
do
    echo -ne "\t____${arr_IgG_L3[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_IgG_L3[@]} - 1; i++ ))
do
    echo -ne ${arr_IgG_L3[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_IgG_L3[@]}; j++))
    do
        c=$(bwCorrelate ${arr_IgG_L3[$i]}$fileext ${arr_IgG_L3[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done


