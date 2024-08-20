#!/bin/sh

# this script runs levioSAM2 on a single .bam file, using a chain file to lift over the reads to the reference genome

module load leviosam2/0.4.2 # will load singularity for you as well, and set $LEVIOSAM2_CONFIGS
module load samtools

# inputs: .chain file, target (reference) .fa, target .fai, alignment .bam file
# output directory (for .clft and .bam files) will be set when calling this script
chain_file=$1
ref_fa=$2
ref_fai=$3
aligned_to_source_bam=$4
echo 4
echo $4

echo chain
echo $chain_file
echo ref_fa
echo $ref_fa
echo ref_fai
echo $ref_fai
echo input bam
echo $aligned_to_source_bam


# define the basename of source_to_target, based on the .chain file (for use in naming the output .clft file)
source_to_target=$(basename "$chain_file" .chain)

echo source_to_target
echo $source_to_target

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

module load winnowmap
module load minimap2

mapper=${mapper%%_*}
if [ "$mapper" == "minimap" ]; then
	mapper="minimap2"
fi

echo basename
echo $base_name
echo mapper
echo $mapper
echo parent
echo $parent
echo output_bam
echo $output_bam


# lift over the reads from the input bam file to the reference genome
leviosam2.py \
	-t 16 \
	-s ont \
	--use_preset True \
	-f $ref_fa \
	-C "${source_to_target}.clft" \
	-a $mapper \
	-O bam \
	-i $aligned_to_source_bam \
	-o $output_bam \
	--lift_realign_config ${LEVIOSAM2_CONFIGS}/ont_all.yaml \
	--target_aligner_index $ref_fa


