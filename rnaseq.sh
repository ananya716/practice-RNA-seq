#!/bin/bash
conda activate rnaseq
module unload perl
BIOPROJECT='PRJNA388952'
ASSEMBLY='ftp://ftp.ensembl.org/pub/release-101/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.28.dna_sm.toplevel.fa.gz'
ANNOTATION='ftp://ftp.ensembl.org/pub/release-101/gtf/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.28.101.chr.gtf.gz'

esearch -db bioproject -query $BIOPROJECT | \
elink -target sra | \
efetch -format runinfo > \
run_info.csv

DMEL=($(grep 'melanogaster' run_info.csv | cut -f1 -d, | head -n 2))DMEL=($(grep 'melanogaster' run_info.csv | cut -f1 -d, | head -n 2))

mkdir -p sequences

for SRA in ${DMEL[@]}; do
  fasterq-dump -O sequences $SRA
done

FASTQS=($(find ./sequences -name "*\.fastq"))

for FASTQ in ${FASTQS[@]}; do
  NEWFILE=sequences/$(basename $FASTQ .fastq)_sampled.fastq
  seqtk sample $FASTQ 100000 > $NEWFILE
done

###########################
## fastq Quality Control ##
###########################

# Make output directory for quality control files.

mkdir -p results/fastqc_reports

# Run fastqc.

FASTQS=$(find ./sequences -name "*sampled\.fastq")

fastqc -o results/fastqc_reports $FASTQS

################################
## Generate STAR Genome Index ##
################################

# Make a directory to store the genome files.

mkdir -p genome

# Download and unpack the genome assembly.

curl $ASSEMBLY | gunzip > ./genome/assembly.fasta

# Download and unpack the genome annotation.

curl $ANNOTATION | gunzip > ./genome/annotation.gtf
