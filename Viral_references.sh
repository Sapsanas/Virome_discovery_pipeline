#!/bin/bash
#SBATCH --job-name=Irish_topology
#SBATCH --output=Irish_topology.out
#SBATCH --error=Irish_topology.err
#SBATCH --mem=20gb
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=4 


export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

# Blasting nonredundant scaffolds against virus reference databases #

/home/umcg-sgarmaeva/opt/blast/bin/blastn \
	-query ./Roux_analysis/nonredundant_scaffolds.fasta \
	-db /groups/umcg-lld/tmp03/umcg-sgarmaeva/databases/viral_refseq_0819/viral_refseq_all.fna \
	-evalue 1e-10 \
	-outfmt '6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send stitle' \
	-out ./Roux_analysis/Viral_RefSeq/nr_scaffolds_viral_refseq_outfmt6.0819.txt \
	-num_threads 4 


/home/umcg-sgarmaeva/opt/blast/bin/blastn \
	-query ./Roux_analysis/nonredundant_scaffolds.fasta \
	-db /groups/umcg-lld/tmp03/umcg-sgarmaeva/databases/crAss-like_seqs/crAss_427_db \
	-evalue 1e-10 \
	-outfmt '6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send stitle' \
	-out ./Roux_analysis/CrAss-like/nr_scaffolds_viral_refseq_outfmt6.CrAss.txt \
	-num_threads 4

# Viral Refseq aligned scaffolds extraction #
bash /contigs_redundancy_removal_v2_AG2.sh \
	./Roux_analysis/Viral_RefSeq/nr_scaffolds_viral_refseq_outfmt6.0819.txt \
	50 \
	0.9
awk -F '\t' '{print $1}' ./Roux_analysis/Viral_RefSeq/scaffolds_blastall_filtered.txt | \
	 sort | \
	uniq > ./Roux_analysis/tidy/refseq_tidy

# CrAss-like aligned scaffolds extraction #
bash /contigs_redundancy_removal_v2_AG2.sh \
        ./Roux_analysis/CrAss-like/nr_scaffolds_viral_refseq_outfmt6.CrAss.txt \
        50 \
        0.9
awk -F '\t' '{print $1}' ./Roux_analysis/CrAss-like/scaffolds_blastall_filtered.txt | \
         sort | \
        uniq > ./Roux_analysis/tidy/crass_tidy
