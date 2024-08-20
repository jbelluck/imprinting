#!/bin/bash

# script runs paf2chain on all paf files in PAF_DIR and converts them to chain files, then swaps the chain files
# the swapped chain files, saved as {genome_ID}_swapped.chain, has the HPRC genome first (technically as the "reference sequence") and CHM13 second (technically as the "query sequence")

module load ucsc

# directory with paf files
PAF_DIR="/data/Phillippy2/projects/belluck_dmr/wfmash_paf"

# run paf2chain on all paf files
for paf_file in "$PAF_DIR"/*.paf; do
        # get the genome identifier (for use in naming the chain file)
        genome_ID=$(basename "$paf_file" .paf)

        # run paf2chain
        /data/Phillippy/tools/paf2chain/target/release/paf2chain -i "$paf_file" > "${PAF_DIR}/${genome_ID}.chain"

	# run chainswap
	chainSwap "${PAF_DIR}/${genome_ID}.chain" "${PAF_DIR}/${genome_ID}_swapped.chain"
done
