#!/bin/bash

# this script runs levioSAM2_one.sh on all .bam files in a directory, to lift over the alignments to CHM13 coordinates

# job script
JOB_SCRIPT="/data/Phillippy2/projects/belluck_dmr/levioSAM2_one.sh"

# high-level directory with all the .bam files
BAM_DIR="/data/Phillippy2/projects/hprc-methyl/alns-verkkoV2.0-asmsV1/"

# directory with all the .chain files
CHAIN_DIR="/data/Phillippy2/projects/belluck_dmr/wfmash_paf"

# CHM13 reference genome and index
CHM13="/data/Phillippy2/projects/belluck_dmr/chm13/v2.0/chm13v2.fa"
CHM13_index="/data/Phillippy2/projects/belluck_dmr/chm13/v2.0/chm13v2.fa.fai"

# within $BAM_DIR, run levioSAM2_one.sh on all .bam files for which there is a chain file in $CHAIN_DIR
chain_suffix="_to_chm13v2.chain"

for assembly_file in "$BAM_DIR"/*.bam; do
	base_name=$(basename "$assembly_file")	
	genome_ID=$(echo "$base_name" | awk -F'-' '{print $3}') #get the genome identifier
    
	chain_file="${genome_ID}${chain_suffix}" #expected chain file name

	# Check if the chain file exists in $CHAIN_DIR
	if [[ -f "${CHAIN_DIR}/${chain_file}" ]]; then
        	echo "Chain file ${chain_file} found in ${CHAIN_DIR}. Submitting levioSAM2_one.sh for genome ${genome_ID}..."
	
		# get the parent (mat/pat)
		parent=${base_name%.*}
		parent=${parent##*.} #extract the part after the last "."

		# get the mapper
		mapper=$(echo "$base_name" | awk -F'-' '{print $1}')

		if [ ! -f "/data/Phillippy2/projects/belluck_dmr/leviosam_files/${genome_ID}_to_chm13v2_${parent}_${mapper}.bam" ]; then
			sbatch -J "${genome_ID}_levioSAM2_${mapper}_${parent}" --cpus-per-task=2 --mem=2g --partition=norm -D /data/Phillippy2/projects/belluck_dmr/leviosam_files/ --time=8:00:00 --error="${genome_ID}_levioSAM2_${mapper}_${parent}.err.log" --output="${genome_ID}_levioSAM2_${mapper}_${parent}.out.log" $JOB_SCRIPT "${CHAIN_DIR}/${chain_file}" $CHM13 $CHM13_index $assembly_file

		fi

	else
        	echo "Chain file ${chain_file} not found in ${CHAIN_DIR}."
	fi
done

