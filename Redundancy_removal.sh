#!/bin/bash
#SBATCH --job-name=redrem
#SBATCH --output=redrem.out
#SBATCH --error=redrem.err
#SBATCH --mem=16gb
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4 


export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

# Redunduncy removal based on scripts from Shkoporov et al. 2019, doi: 10.1016/j.chom.2019.09.009 #

cat ./all_scaffolds_Roux/*_renamed_scaffolds.fasta > ./Roux_analysis/all_scaffolds_Roux/all_scaffolds.fasta
 
/home/umcg-sgarmaeva/opt/blast/bin/makeblastdb \
	-in ./Roux_analysis/all_scaffolds_Roux/all_scaffolds.fasta \
	-dbtype 'nucl' \
	-out ./Roux_analysis/all_scaffolds_Roux/all_scaffolds_db

/home/umcg-sgarmaeva/opt/blast/bin/blastn \
	-db ./Roux_analysis/all_scaffolds_Roux/all_scaffolds_db \
	-query ./Roux_analysis/all_scaffolds_Roux/all_scaffolds.fasta \
	-outfmt "6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send" \
	-num_threads 4 \
	-evalue 1e-10 \
	-out ./Roux_analysis/all_scaffolds_Roux/reciprocal.outfmt6.txt

/groups/umcg-lld/tmp03/umcg-sgarmaeva/scripts/contigs_redundancy_removal_v2.sh \
	./Roux_analysis/all_scaffolds_Roux/reciprocal.outfmt6.txt \
	90 \
	0.9 \
	./Roux_analysis/all_scaffolds_Roux/all_scaffolds.fasta

# Result of redundancy removal is nonredundant_scaffolds.fasta
