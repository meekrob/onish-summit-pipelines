#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=2:00:00
#SBATCH --qos=normal
#SBATCH --output=hisat-%j.out

echo "[$0] $SLURM_JOB_NAME $@" # log the command line
PROJ_DIR=/projects/dcking@colostate.edu
source $PROJ_DIR/paths.bashrc
date

export HISAT2_INDEXES=/projects/dcking@colostate.edu/support_data/hisat2
root=$1
cmd="hisat2 -x ce11 -U sophie/$root.fastq > $root.sam"
echo $cmd
time eval $cmd
pychecksum.py $root.sam sha256
