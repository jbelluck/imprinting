#!/bin/bash

# script to lift over methylation calls from bedmethyl files using crossmap

module purge
module load ucsc/466
module load crossmap
module load bedtools/2.31.1 # bedtools sort
module load htslib/1.20 # bgzip, tabix

# define bedmethyl file location
BED_DIR="/data/Phillippy2/projects/hprc-methyl/alns-verkkoV2.1-asmsV3"

# define chain file location
CHAIN_DIR="/data/Phillippy2/projects/hprc-assemblies/assemblies-v3/mm2_nflo_chains/finished_chains"

# define fasta file locations
FASTA_DIR="/data/Phillippy2/projects/belluck_dmr/v3_fastas"
REF_PATH="/data/Phillippy2/projects/belluck_dmr/chm13/v2.0/chm13v2.fa"

# create the .sizes file
if [ ! -s "chm13v2.sizes" ]; then
	faSize -detailed $REF_PATH > chm13v2.sizes
fi

echo "sizes file created"

count=0
# loop through the chain files
for chain in "$CHAIN_DIR"/*.chain; do
	((count += 1))	

	echo $chain

	# get the genome identifier and haplotype
        if [[ $chain == *"hap1"* ]]; then
                SAMPLE="${chain##*/}"
                SAMPLE="${SAMPLE%%_*}"
		HAP="mat"
        elif [[ $chain == *"hap2"* ]]; then
                SAMPLE="${chain##*/}"
                SAMPLE="${SAMPLE%%_*}"
		HAP="pat"
        fi

	echo $SAMPLE
	echo $HAP

	if [ $count -ge 23 ] && [ $count -le 32 ]; then

		# for each aligner
		for aligner in winnowmap minimap; do

			echo $aligner

			# define the bed file
			bed_file="${BED_DIR}/${aligner}_ont-x-${SAMPLE}-verkkoV2.1-asmV3.F0x904.methyl.${HAP}.bed"

			echo $bed_file

			if [[ ! -f "${bed_file}" ]]; then
				# unzip the bed file
				gunzip "${bed_file}.gz"
			fi

			# select columns
			cut -f 1-3,5,11-13,15-18 $bed_file > ${SAMPLE}_${HAP}_${aligner}_ont.methyl.bed

			echo "columns selected"

			# use crossmap to lift over the calls from the bed file to chm13v2
			crossmap bed $chain ${SAMPLE}_${HAP}_${aligner}_ont.methyl.bed ${SAMPLE}_${HAP}_to_chm13v2_${aligner}_ont.methyl.bed

			echo "finished lifting methylation calls"

		# sort the bed file
#                bedtools sort -g chm13v2.sizes -i ${SAMPLE}_${HAP}_to_chm13v2_${aligner}_ont.methyl.bed > ${SAMPLE}_${HAP}_to_chm13v2_${aligner}_ont.methyl.sorted.bed


#		echo "finished sorting bed file"

                # bgzip the bed file
#               bgzip ${SAMPLE}_${HAP}_to_chm13v2_${aligner}_ont.methyl.sorted.bed

                # index the bed file
#                tabix -p bed ${SAMPLE}_${HAP}_to_chm13v2_${aligner}_ont.methyl.sorted.bed

#		echo "finished zipping and indexing bed file"
		
#		echo "${BED_DIR}/${aligner}_ont-x-${SAMPLE}-verkkoV2.1-asmV3.F0x904.methyl.${HAP}.bed"
#		bgzip "${BED_DIR}/${aligner}_ont-x-${SAMPLE}-verkkoV2.1-asmV3.F0x904.methyl.${HAP}.bed"
		done
	fi
done

