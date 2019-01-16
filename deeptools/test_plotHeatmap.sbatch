#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=testing

cmd="plotHeatmap -m test_deeptools.gz -o heatmap.png"
echo $cmd
time eval $cmd
