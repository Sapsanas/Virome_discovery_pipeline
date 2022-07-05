#!/bin/bash
#SBATCH --job-name=assembly
#SBATCH --output=assembly.out
#SBATCH --error=assembly.err
#SBATCH --mem=48gb
#SBATCH --time=8:00:00
#SBATCH --cpus-per-task=4 


SAMPLE_ID=$1
echo "SAMPLE_ID=${SAMPLE_ID}"

##### Dependencies #####
module load Python/2.7.11-foss-2015b
module load FastQC
module load Bowtie2
module load Java

export PATH=$PATH:/home/umcg-sgarmaeva/.local/bin

mkdir ./{$SAMPLE_ID}/clean_reads/
gunzip ./${SAMPLE_ID}/filtering_data/${SAMPLE_ID}_*.fq.gz

# Quality control: adapter trimming, etc #

module load kneaddata
kneaddata \
	--input ./${SAMPLE_ID}/filtering_data/${SAMPLE_ID}_1.fq \
	-t 6 \
	-p 7 \
	--input ./${SAMPLE_ID}/filtering_data/${SAMPLE_ID}_2.fq \
	-db /groups/umcg-gastrocol/tmp03/metagenomic_tools/kneaddata-0.5.4/human_genome_reference_38p12 \
	--output ./${SAMPLE_ID}/filtering_data/ \
	--log ./$SAMPLE_ID/clean_reads/$SAMPLE_ID.log
mv ./${SAMPLE_ID}/filtering_data/*kneaddata_paired_1.fastq ./${SAMPLE_ID}/clean_reads/
mv ./${SAMPLE_ID}/filtering_data/*kneaddata_paired_2.fastq ./${SAMPLE_ID}/clean_reads/ 

rm -r ./${SAMPLE_ID}/filtering_data/

# Quality control: read error correction according to Roux et al. 2019, https://doi.org/10.7717/peerj.6902 #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/bbmap/tadpole.sh \
	in=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1_kneaddata_paired_1.fastq \
	out=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1.QC1.fq \
	mode=correct \
	ecc=t \
	prefilter=2 \
	t=4
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/bbmap/tadpole.sh \
	in=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1_kneaddata_paired_2.fastq \
	out=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_2.QC1.fq \
	mode=correct \
	ecc=t \
	prefilter=2 \
	t=4

# Quality control: read deduplication according to Roux et al. 2019, https://doi.org/10.7717/peerj.6902 #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/bbmap/clumpify.sh \
	in=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1.QC1.fq \
	in2=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_2.QC1.fq \
	out=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1.QC2.fq \
	out2=./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_2.QC2.fq \
	dedupe=t \
	subs=0 \
	passes=2 \
	deletetemp=t \
	t=4

rm ./$SAMPLE_ID/clean_reads/${SAMPLE_ID}_*.QC1.fq

gzip ./$SAMPLE_ID/clean_reads/${SAMPLE_ID}_1_kneaddata_paired_1.fastq
gzip ./$SAMPLE_ID/clean_reads/${SAMPLE_ID}_1_kneaddata_paired_2.fastq

# Quality control: alignment reads to cpn60 UT database accoording to Shkoporov et al., 2018, https://doi.org/10.1186/s40168-018-0446-z #
bowtie2 \
	-x /groups/umcg-lld/tmp03/umcg-sgarmaeva/databases/cpn60/cpn60db \
	-1 ./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1.QC2.fq \
	-2 ./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_2.QC2.fq \
	-S ./${SAMPLE_ID}/cpn60db.sam \
	-p 2 \
	--no-unal \
	--end-to-end &> ./Roux_analysis/final_viral_scaffolds/cpn60db_alignment_log/${SAMPLE_ID}_bowtie2.cpn60db.log

# Contigs assembly according to Roux et al. 2019, https://doi.org/10.7717/peerj.6902 #
spades.py \
	-1 ./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_1.QC2.fq \
	-2 ./${SAMPLE_ID}/clean_reads/${SAMPLE_ID}_2.QC2.fq \
	--sc \
	-t 8 \
	-o ./${SAMPLE_ID}/clean_metaspades_out/ \
	--only-assembler

# Assembly QC #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/tools/quast-5.0.0/quast.py \
	 ./${SAMPLE_ID}/clean_metaspades_out/contigs.fasta \
	-o ./${SAMPLE_ID}/clean_metaspades_out/quast_out 

# Trimming contigs to the length of 1000 bp using filter_contigs.pl (Author: Vivek Krishnakumar, copied from https://www.biostars.org/p/79202/#79467) #
/groups/umcg-lld/tmp03/umcg-sgarmaeva/scripts/filter_contigs.pl \
	1000 \
	./${SAMPLE_ID}/clean_metaspades_out/scaffolds.fasta > \
	./${SAMPLE_ID}/clean_metaspades_out/${SAMPLE_ID}_scaffolds.min1000.fasta 

sed 's/>NODE/>'${SAMPLE_ID}'_NODE/g' ./${SAMPLE_ID}/clean_metaspades_out/${SAMPLE_ID}_scaffolds.min1000.fasta > \
	./${SAMPLE_ID}/clean_metaspades_out/${SAMPLE_ID}_renamed_scaffolds.fasta
cp ./${SAMPLE_ID}/clean_metaspades_out/${SAMPLE_ID}_renamed_scaffolds.fasta ./all_scaffolds_Roux

