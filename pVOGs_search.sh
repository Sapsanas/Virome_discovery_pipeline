#!/bin/bash
#SBATCH --job-name=pVOGs
#SBATCH --output=pVOGs.out
#SBATCH --error=pVOGs.err
#SBATCH --mem=8gb
#SBATCH --time=23:00:00
#SBATCH --cpus-per-task=4 

export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

## searching for pVOGs doi:10.1093/nar/gkw975##
mkdir -p ./Roux_analysis/pVOGs
# Predicting ORFs #

/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/prodigal/prodigal \
	-a ./Roux_analysis/pVOGs/nonredundant_contigs.min1000.AA.fasta \
	-i ./Roux_analysis/nonredundant_contigs.fasta \
	-p meta \
	&> ./Roux_analysis/pVOGs/prodigal.log

# Searching for similarities to pVOGs db #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/hmmer-3.2.1/src/hmmsearch \
	-E 0.000001 \
	--tblout ./Roux_analysis/pVOGs/nonredundant_contigs.min1000.AA.tblout \
	--cpu 4 \
	/groups/umcg-lld/tmp03/umcg-sgarmaeva/databases/pvogs/AllvogHMMprofiles/all_vogs.hmm \
	./Roux_analysis/pVOGs/nonredundant_contigs.min1000.AA.fasta \
	&> ./Roux_analysis/pVOGs/hmmsearch.log
