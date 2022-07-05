#!/bin/bash
#SBATCH --job-name=fasta_reformat
#SBATCH --output=fasta_reformat.out
#SBATCH --error=fasta_reformat.err
#SBATCH --mem=8gb
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1

export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

## Preapring scaffolds for running dark matter criterion ##
mkdir -p ./Roux_analysis/dark_matter

# Filtering for the size of contigs: 3000bp #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/scripts/filter_contigs.pl \
	3000 \
	./Roux_analysis/nonredundant_scaffolds.fasta \
	> ./Roux_analysis/nonredundant_scaffolds.3k.fasta

# Calculating the total length of sequences #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/quast-5.0.0/quast.py \
	./Roux_analysis/nonredundant_scaffolds.3k.fasta \
	-o ./quast
## Total length is 585,802,734 > split it to fasta's with similar total length around 20 mln bp
 
# Spliting scaffolds to several multifastas with similar length using https://github.com/ISUgenomics/common_scripts/blob/master/fastasplitn.c #
# modified the output names format; recompiled the script
# here '30' is the number of files

/groups/umcg-lld/tmp03/umcg-sgarmaeva/scripts/fastasplitn ./Roux_analysis/nonredundant_scaffolds.3k.fasta 30
mv ./Roux_analysis/frag*.fa ./Roux_analysis/dark_matter

