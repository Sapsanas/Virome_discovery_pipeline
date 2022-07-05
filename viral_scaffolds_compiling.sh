#!/bin/bash

# Cleaning dark matter results #
for i in ./Roux_analysis/dark_matter/*.txt; do 
	/contigs_redundancy_removal_v2_AG2.sh ${i} 90 0; 
	awk -F '\t' '$3 > 100' ./Roux_analysis/dark_matter/scaffolds_blastall_filtered.txt | \
	awk -F '\t' '{print $1}' | sort | uniq >> ./Roux_analysis/dark_matter/scaffolds_discard
done

for i in ./Roux_analysis/dark_matter/*.txt; do 
	awk -F '\t' '$3 > 90 && $4 > 100' ${i} | \
	awk -F '\t' '{print $1}' | \
	sort | uniq >> ./Roux_analysis/dark_matter/scaffolds_discard_add; 
done

cat ./Roux_analysis/dark_matter/scaffolds_discard ./Roux_analysis/dark_matter/scaffolds_discard_add | \
	 sort | uniq > ./Roux_analysis/dark_matter/scaffolds_discard_all

#All the scaffolds > 3kbp (in split_fasta dir):

grep '>' ./Roux_analysis/nonredundant_scaffolds.3k.fasta | \
	sed 's/>//g' | sort > ./Roux_analysis/all_scaffolds_3k

#To obtain the list of viral dark matter contigs (in split_fasta dir):
comm -23 ./Roux_analysis/all_scaffolds_3k ./Roux_analysis/dark_matter/scaffolds_discard_all > ./Roux_analysis/tidy/dark_matter_tidy


cat ./Roux_analysis/tidy/*_tidy | sort | uniq > ./Roux_analysis/tidy/all_retained_viral_ids

/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/bin/pullseq \
	-i ./Roux_analysis/nonredundant_scaffolds.fasta \
	-n ./Roux_analysis/tidy/all_retained_viral_ids \
	> ./Roux_analysis/tidy/retained_scaffolds.fasta

