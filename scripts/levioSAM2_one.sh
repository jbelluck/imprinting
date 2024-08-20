#!/bin/sh

# this script runs levioSAM2 on a single .bam file, using a chain file to lift over the alignment to the reference genome

module load singularity
module load leviosam2

# set path for levioSAM2
#levioSAM2="/data/Phillippy/tools/leviosam2/0.4.2/bin/leviosam2"

# inputs: .chain file, target (reference) .fa, target .fai, alignment .bam file
# output directory (for .clft and .bam files) will be set when calling this script
chain_file=$1
ref_fa=$2
ref_fai=$3
aligned_to_source_bam=$4

# define the basename of source_to_target, based on the .chain file (for use in naming the output .clft file)
source_to_target=$(basename "$chain_file" .chain)

# define name of the out .bam file
# format: genomeID_to_referenceID_parent_mapper_sequencer
base_name=$(basename "$aligned_to_source_bam")
mapper=${base_name%%-*} #extract everything up to the first "-"
parent=${base_name%.*}
parent=${parent##*.} #extract the part after the last "."
output_bam="${source_to_target}_${parent}_${mapper}"

# check if the .clft file exists first, only index the .chain file if the .clft file doesn't exist
clft_file="${PWD}/${source_to_target}.clft"
if [ ! -f "$clft_file" ]; then
    echo "$clft_file does not exist. Indexing the chain file..."
    leviosam2 index -c $chain_file -p $source_to_target -F $ref_fai
    echo "Lifting over the reads..."
else
    echo "$clft_file already exists. Lifting over the reads..."
fi

# lift over the reads from the input bam file to the reference genome
leviosam2 lift -C "${source_to_target}.clft" -a $aligned_to_source_bam -p $output_bam -O bam

echo "Finished lifting over the reads. Output saved as ${output_bam}"
