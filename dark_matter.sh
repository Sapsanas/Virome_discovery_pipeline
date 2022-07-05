#!/bin/bash
#SBATCH --job-name=dark_matter
#SBATCH --output=dark_matter.out
#SBATCH --error=dark_matter.err
#SBATCH --mem=40gb
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=4 


SAMPLE_ID=$1
echo "SAMPLE_ID=${SAMPLE_ID}"

export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

/home/umcg-sgarmaeva/opt/blast/bin/blastn \
	-query ./Roux_analysis/dark_matter/${SAMPLE_ID}.fa \
	-db /groups/umcg-tifn/tmp03/LLD2/good/tmps/Samples/db_NCBI_nt/nt_db \	
	-evalue 1e-10 \
	-outfmt '6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send stitle' \
	-out ./Roux_analysis/dark_matter/${SAMPLE_ID}_nr_nt_3k.txt \
	-num_threads 4
