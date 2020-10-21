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
