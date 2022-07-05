#!/bin/bash

for SAMPLE in $@; do
    if [ -d ${SAMPLE} ]; then
        sbatch --output ${SAMPLE}_assembly.out --error ${SAMPLE}_assembly.err --job-name ${SAMPLE} Per_sample_assembly.sh ${SAMPLE} 
	sbatch --output ${SAMPLE}_dm.out --error ${SAMPLE}_dm.err --job-name ${SAMPLE}_dm dark_matter.sh ${SAMPLE}
    fi
done

#execution: bash runAllSamples.bash $(cat sample.list) or $(cat fragment.list)
