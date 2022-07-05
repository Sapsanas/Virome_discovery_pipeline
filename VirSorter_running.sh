#!/bin/bash
#SBATCH --job-name=VirSorter
#SBATCH --output=VirSorter.out
#SBATCH --error=VirSorter.err
#SBATCH --mem=8gb
#SBATCH --time=117:00:00
#SBATCH --cpus-per-task=4 


export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

##### Dependencies #####
module load Anaconda3

# Running VirSorter doi:10.7717/peerj.985 #
#running in decontamination mode based on the results of bacterial genomic dna contamination using alignment to cpn60db

source activate virsorter
wrapper_phage_contigs_sorter_iPlant.pl \
	-f ./Roux_analysis/nonredundant_contigs.fasta \
	--db 2 \
	--wdir ./Roux_analysis/VirSorter \
	--ncpu 4 \
	--virome \
	--data-dir /groups/umcg-lld/tmp03/umcg-sgarmaeva/virsorter-data \
	--no_c 1

# VirSorter predicted VLP extraction #
grep -v "#" ./Roux_analysis/VirSorter/VIRSorter_global-phage-signal.csv | \
	cut -f1 -d "," | \
	sed s/VIRSorter_// | \
	cut -f 1 -d "-" | \
	sed s/_/./2 | \
	sed s/_/./8 > ./Roux_analysis/tidy/VIRSorter_global-phage-signal_tidy

