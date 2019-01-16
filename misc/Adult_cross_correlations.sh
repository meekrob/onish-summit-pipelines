#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:05:00
#SBATCH --qos=normal
#SBATCH --output=adult_cross_correlations_%j.txt
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

# Adult ELT-2s:
arr_elt2_Adult=(AR116 AR120 AR132 EO30 EO38)
arr_input_Adult=(AR118 AR122 AR134 EO32 EO42)
arr_IgG_Adult=(AR117 AR121 AR133 EO31 EO39)

fileext=.trimmed.dusted.sortedx150n.bw

len=${#arr_elt2[@]}
first=0
last=$((len - 1))

echo -n "Adult:ELT-2" # why no newline?
# header row
for (( i=1; i < ${#arr_elt2_Adult[@]}; i++ ))
do
    echo -ne "\t____${arr_elt2_Adult[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_elt2_Adult[@]} - 1; i++ ))
do
    echo -ne ${arr_elt2_Adult[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_elt2_Adult[@]}; j++))
    do
        #echo -ne "\t${arr_elt2_Adult[$i]}:${arr_elt2_Adult[$j]}"
        c=$(bwCorrelate ${arr_elt2_Adult[$i]}$fileext ${arr_elt2_Adult[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done

echo
echo -n "Adult:inpt" # why no newline?
# header row
for (( i=1; i < ${#arr_input_Adult[@]}; i++ ))
do
    echo -ne "\t____${arr_input_Adult[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_input_Adult[@]} - 1; i++ ))
do
    echo -ne ${arr_input_Adult[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_input_Adult[@]}; j++))
    do
        c=$(bwCorrelate ${arr_input_Adult[$i]}$fileext ${arr_input_Adult[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done


echo
echo -n "Adult:IgG" # why no newline?
# header row
for (( i=1; i < ${#arr_IgG_Adult[@]}; i++ ))
do
    echo -ne "\t____${arr_IgG_Adult[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_IgG_Adult[@]} - 1; i++ ))
do
    echo -ne ${arr_IgG_Adult[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_IgG_Adult[@]}; j++))
    do
        c=$(bwCorrelate ${arr_IgG_Adult[$i]}$fileext ${arr_IgG_Adult[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done


