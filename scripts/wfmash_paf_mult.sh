#!/bin/bash

# script runs wfmash_paf.sh on all fasta files in FASTA_DIR to align diploid genome assemblies to the CHM13 reference genome

# directory with genome assemblies (.fa and .fai)
FASTA_DIR="/data/Phillippy2/projects/belluck_dmr/v3_fastas"

# CHM13 reference genome
CHM13="/data/Phillippy2/projects/belluck_dmr/chm13/v2.0/chm13v2.fa"

# job script
JOB_SCRIPT="/data/Phillippy2/projects/belluck_dmr/wfmash_paf.sh"

# run script on all fasta files
for fasta_file in "$FASTA_DIR"/*at.fa; do
	# get the genome identifier (for use in naming the error/output files)
	genome_ID=$(basename "$fasta_file" .fa)

	# submit the sbatch job
	sbatch -J "$genome_ID" --cpus-per-task=28 --mem=247g --partition=norm -D /data/Phillippy2/projects/belluck_dmr/v3_fastas --time=24:00:00 --error="${genome_ID}.err.log" --output="${genome_ID}.out.log" "$JOB_SCRIPT" "$fasta_file" "$CHM13"
done
