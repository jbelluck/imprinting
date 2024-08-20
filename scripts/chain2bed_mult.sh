#! /usr/bin/env bash

# make bash safer
set -euo pipefail

# load the needed modules
module purge
module load ucsc/466 # chainToPsl, pslToBed, faSize
module load bedtools/2.31.1 # bedtools sort
module load htslib/1.20 # bgzip, tabix
module load ucsc

# define the chain file directory (Nancy's completed chain files from nflo workflow)
CHAIN_DIR="/data/Phillippy2/projects/hprc-assemblies/assemblies-v3/mm2_nflo_chains/finished_chains"

REF="chm13v2"
REF_PATH="/data/Phillippy2/projects/belluck_dmr/chm13/v2.0/chm13v2.fa"

# loop through the chain files
# for each, swap the chain file and use it to create a bed file
# Nancy's files are "inverted" which means the personal genome is first, but we want to use chain files with chm13 first
for chain in "$CHAIN_DIR"/*.chain; do
	# get the genome identifier
	if [[ $chain == *"hap1"* ]]; then
		SAMPLE="${chain##*/}"
		SAMPLE="${SAMPLE%%_*}.mat"
	elif [[ $chain == *"hap2"* ]]; then
		SAMPLE="${chain##*/}"
                SAMPLE="${SAMPLE%%_*}.pat"
	fi

	echo $SAMPLE

	SAMPLE_PATH="/data/Phillippy2/projects/belluck_dmr/v3_fastas/${SAMPLE}.fa"

	# swap the chain file
	chainSwap $chain ${SAMPLE}-x-${REF}.chain

	# create the .sizes files
	if [ ! -s "${SAMPLE}.sizes" ]
	then
		faSize -detailed $SAMPLE_PATH > ${SAMPLE}.sizes
	fi	

	if [ ! -s "${REF}.sizes" ]
	then
		faSize -detailed $REF_PATH > ${REF}.sizes
	fi

	echo $SAMPLE
	echo $REF

	# convert from chain to psl (so we can then convert to bed later)
	printf '%s\n' "chainToPsl ${SAMPLE}-x-${REF}.chain ${REF}.sizes ${SAMPLE}.sizes $REF_PATH $SAMPLE_PATH ${SAMPLE}-x-${REF}.chain.psl" 1>&2
	chainToPsl ${SAMPLE}-x-${REF}.chain ${REF}.sizes ${SAMPLE}.sizes $REF_PATH $SAMPLE_PATH ${SAMPLE}-x-${REF}.chain.psl

	# convert from psl to bed
	printf '%s\n' "pslToBed ${SAMPLE}-x-${REF}.chain.psl ${SAMPLE}-x-${REF}.chain.bed" 1>&2
	pslToBed ${SAMPLE}-x-${REF}.chain.psl ${SAMPLE}-x-${REF}.chain.bed

	# sort the bed file
	printf '%s\n' "bedtools sort -g ${REF}.sizes -i ${SAMPLE}-x-${REF}.chain.bed > ${SAMPLE}-x-${REF}.chain.sorted.bed" 1>&2
	bedtools sort -g ${REF}.sizes -i ${SAMPLE}-x-${REF}.chain.bed > ${SAMPLE}-x-${REF}.chain.sorted.bed

	# remove the uneeded psl and unsorted bed
	printf '%s\n' "rm -v ${SAMPLE}-x-${REF}.chain.bed ${SAMPLE}-x-${REF}.chain.psl" 1>&2
	rm -v ${SAMPLE}-x-${REF}.chain.bed ${SAMPLE}-x-${REF}.chain.psl

	# rename the sorted bed to removed "sorted" from the name
	printf '%s\n' "mv -v ${SAMPLE}-x-${REF}.chain.sorted.bed ${SAMPLE}-x-${REF}.chain.bed" 1>&2
	mv -v ${SAMPLE}-x-${REF}.chain.sorted.bed ${SAMPLE}-x-${REF}.chain.bed

	# bgzip the bed file
	printf '%s\n' "bgzip ${SAMPLE}-x-${REF}.chain.bed" 1>&2
	bgzip ${SAMPLE}-x-${REF}.chain.bed

	# index the bed file
	printf '%s\n' "tabix -p bed ${SAMPLE}-x-${REF}.chain.bed.gz" 1>&2
	tabix -p bed ${SAMPLE}-x-${REF}.chain.bed.gz
done

