#!/bin/bash

# script runs wfmash_paf.sh on fasta files to align diploid genome assemblies to the CHM13 reference genome
# this is compatible with the file structure of the V3 assemblies (list of fasta files is stored in a txt file)

# .txt file with list of genome assembly fasta files
FILE_LIST="/data/Phillippy2/projects/belluck_dmr/v3_fastasss.txt"

# CHM13 reference genome
CHM13="/data/Phillippy2/projects/belluck_dmr/chm13/v2.0/chm13v2.fa"

# job script
JOB_SCRIPT="/data/Phillippy2/projects/belluck_dmr/wfmash_paf_v3.sh"

# for each fasta file, run the script
for fasta_file in $(cat "$FILE_LIST"); do
	# get the genome identifier (for use in naming the error/output files)
	genome_ID=$(echo "$fasta_file" | awk -F'/' '{print $7}')

	# submit the sbatch job
	echo "Submitting wfmash_paf.sh for $genome_ID"
	sbatch -J "$genome_ID" --cpus-per-task=28 --mem=247g --partition=norm -D /data/Phillippy2/projects/belluck_dmr/wfmash_v3 --time=24:00:00 --error="${genome_ID}.err.log" --output="${genome_ID}.out.log" "$JOB_SCRIPT" "$fasta_file" "$CHM13" "$genome_ID" "chm13v2"
done
