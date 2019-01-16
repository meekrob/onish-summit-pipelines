#!/usr/bin/env bash
PRJ=/projects/dcking@colostate.edu
thresholds=".05 .10"
infiles=($@)

echo "Running thresholds $thresholds on..."
echo "All combinations of ${infiles[@]}"

numfiles=${#infiles[@]}
echo "$numfiles files"

for ((i=0; i < $numfiles -1; i++))
do
    for ((j=(($i+1)); $j < $numfiles; j++))
    do
        echo ">>>>> $i versus $j <<<<<"
        for threshold in $thresholds
        do
            echo "$threshold: ${infiles[$i]} versus ${infiles[$j]}"
            sbatch $PRJ/pipelines/IDR/do_IDR.sbatch ${infiles[$i]} ${infiles[$j]} $threshold
        done
    done
done
