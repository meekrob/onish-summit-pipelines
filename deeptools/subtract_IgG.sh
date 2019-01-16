#!/usr/bin/env bash
FILENAME=igg_control_sheet.txt
while read -r exp control IgG;
do
    
    if [ ! -z $exp ] && [ ! -z $control ] && [ ! -z $IgG ];
    then
        outfilename="${exp}_minus_${IgG}.x150n.bw"
        expfilename="${exp}_over_${control}.x150n.bw"
        IgGfilename="${IgG}_over_${control}.x150n.bw"
        if [ ! -e $expfilename ] || [ ! -e $IgGfilename ];
        then
            echo "one of the files doesn't exist: $expfilename $IgGfilename"
            continue
        else
            #cmd="javaGenomicsToolkit wigmath.Subtract -m $expfilename -s $IgGfilename -o $outfilename"
            cmd="sbatch subtract_bigwigs.sbatch $expfilename $IgGfilename"
            echo $cmd
            $cmd
        fi
    
    #else
        #echo "skipping line"
    fi
done < $FILENAME;
