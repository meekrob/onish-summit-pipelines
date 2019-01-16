#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:05:00
#SBATCH --qos=normal
#SBATCH --output=embryo_cross_correlations_%j.txt
NTHREADS=${SLURM_NTASKS} # passes --ntasks set above
echo "[$0] $SLURM_JOB_NAME $@" # log the command line
export TMPDIR=$SLURM_SCRATCH
export TMP=$TMPDIR
date # timestamp

# erinnishgrp@colostate.edu projects setup
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc


fileext1=.trimmed.dusted.sortedx150n.bw
fileext2=.trimmed.sortedx150n.bw

getExt() {
    if [[ ${1:2:1} == '6' ]]
    then
        echo $1$fileext2
    else
        echo $1$fileext1
    fi
}

bwCorrelate() {
    # deal with file extensions
    
    rval=$(bigWigCorrelate $(getExt $1) $(getExt $2))
    echo -ne $rval
}

# Embryo ELT-2s:
arr_elt2_Embryo=(AR100 AR128 EO34 EO62 EO66)
arr_input_Embryo=(AR103 AR130 EO40 EO64 EO68)
arr_IgG_Embryo=(AR102 AR129 EO35 EO63 EO67)


len=${#arr_elt2[@]}
first=0
last=$((len - 1))

echo -n "Embryo:ELT-2" # why no newline?
# header row
for (( i=1; i < ${#arr_elt2_Embryo[@]}; i++ ))
do
    echo -ne "\t____${arr_elt2_Embryo[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_elt2_Embryo[@]} - 1; i++ ))
do
    echo -ne ${arr_elt2_Embryo[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_elt2_Embryo[@]}; j++))
    do
        c=$(bwCorrelate ${arr_elt2_Embryo[$i]}$fileext ${arr_elt2_Embryo[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done

echo
echo -n "Embryo:inpt" # why no newline?
# header row
for (( i=1; i < ${#arr_input_Embryo[@]}; i++ ))
do
    echo -ne "\t____${arr_input_Embryo[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_input_Embryo[@]} - 1; i++ ))
do
    echo -ne ${arr_input_Embryo[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_input_Embryo[@]}; j++))
    do
        c=$(bwCorrelate ${arr_input_Embryo[$i]}$fileext ${arr_input_Embryo[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done


echo
echo -n "Embryo:IgG" # why no newline?
# header row
for (( i=1; i < ${#arr_IgG_Embryo[@]}; i++ ))
do
    echo -ne "\t____${arr_IgG_Embryo[$i]}____"
done
echo -e

# half-matrix comparison table
for (( i=0; i < ${#arr_IgG_Embryo[@]} - 1; i++ ))
do
    echo -ne ${arr_IgG_Embryo[$i]}
    for (( j=0; j < $i; j++ ))
    do
        echo -ne "\t____ ____"
    done
    for ((j=i+1; j < ${#arr_IgG_Embryo[@]}; j++))
    do
        c=$(bwCorrelate ${arr_IgG_Embryo[$i]}$fileext ${arr_IgG_Embryo[$j]}$fileext)
        echo -ne "\t$c"
    done
    echo

done


