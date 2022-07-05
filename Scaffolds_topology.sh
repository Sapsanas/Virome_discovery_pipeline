#!/bin/bash
#SBATCH --job-name=topology
#SBATCH --output=topology.out
#SBATCH --error=topology.err
#SBATCH --mem=16gb
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1 


module load Biopython
module load PythonPlus/2.7.11-foss-2015b-v17.06.1

export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin
export PATH=$PATH:/groups/umcg-lld/tmp03/umcg-sgarmaeva/scripts/lastz-distrib-1.04.00/bin

# Searching for circular scaffolds based on https://github.com/alexcritschristoph/VRCA/blob/master/find_circular.py #

mkdir -p ./Roux_analysis/Topology

python /groups/umcg-lld/tmp03/umcg-sgarmaeva/scripts/find_circular.py \
	-i ./Roux_analysis/nonredundant_scaffolds.fasta
mv nonredundant_scaffolds.fasta_circular.fna ./Roux_analysis/Topology


# Circular scaffolds extraction #
grep -E '>' ./Roux_analysis/Topology/nonredundant_scaffolds.fasta_circular.fna | \
	awk -F '>' '{print $2}' > ./Roux_analysis/tidy/circular_tidy
