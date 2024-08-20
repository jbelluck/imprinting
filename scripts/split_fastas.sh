#!/bin/bash

module load samtools

# directory with genome assemblies (.fa and .fai)
FASTA_DIR="/data/Phillippy2/projects/belluck_dmr/v3_fastas"

for fasta_file in "$FASTA_DIR"/*.fa; do
        # get the genome identifier (for use in naming the error/output files)
        genome_ID=$(basename "$fasta_file" .fa)
	samtools faidx ${genome_ID}.fa
	for HAP in {m,p}at; do
    		grep ${HAP} ${genome_ID}.fa.fai | cut -f 1 | sort -V > ${genome_ID}.${HAP}.list
    		samtools faidx -n 999999999 -r ${genome_ID}.${HAP}.list ${genome_ID}.fa > ${genome_ID}.${HAP}.fa
    		samtools faidx ${genome_ID}.${HAP}.fa
	done
done

