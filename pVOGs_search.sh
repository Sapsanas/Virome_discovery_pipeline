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
	-a ./Roux_analysis/pVOGs/nonredundant_scaffolds.min1000.AA.fasta \
	-i ./Roux_analysis/nonredundant_scaffolds.fasta \
	-p meta \
	&> ./Roux_analysis/pVOGs/prodigal.log

# Searching for similarities to pVOGs db #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/hmmer-3.2.1/src/hmmsearch \
	-E 0.000001 \
	--tblout ./Roux_analysis/pVOGs/nonredundant_scaffolds.min1000.AA.tblout \
	--cpu 4 \
	/groups/umcg-lld/tmp03/umcg-sgarmaeva/databases/pvogs/AllvogHMMprofiles/all_vogs.hmm \
	./Roux_analysis/pVOGs/nonredundant_scaffolds.min1000.AA.fasta \
	&> ./Roux_analysis/pVOGs/hmmsearch.log

# pVOGs predicted VLP extraction #
sed -e '1,3d' < ./Roux_analysis/pVOGs/nonredundant_scaffolds.min1000.AA.tblout | \
	head -n -10 | \
	awk -F ' ' '{print $1}' | \
	sort -u | \
	sed 's/_[0-9]\+$//' | \
	uniq -c > ./Roux_analysis/pVOGs/viral_genes_pred_tidy
awk '$1 > 1' ./Roux_analysis/pVOGs/viral_genes_pred_tidy | \
	awk -F ' ' '{print $2}' > ./Roux_analysis/tidy/atleasttwo_viral_genes_tidy
