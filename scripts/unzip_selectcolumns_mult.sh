#!/bin/bash

# make bash safer
set -euo pipefail

# load the needed modules
module purge
module load bedtools/2.31.1 # bedtools sort
module load htslib/1.20 # bgzip, tabix

# define bed directory
BED_DIR="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls"

# loop through the bed files
for bed_file in "$BED_DIR"/*at_to_chm13v2_winnowmap_ont.methyl.bed.gz; do

	echo $bed_file

	#bed_base=$(basename "${bed_file}")
	bed_base=${bed_file%.*}
	bed_base=${bed_base%.*}

	echo $bed_base

	# unzip the bed file
	gunzip $bed_file

	echo "unzipped"

	# select only the relevant columns (1, 2, 4, 6)
	awk -F'\t' '{print $1 "\t" $2 "\t" $4 "\t" $6}' "${bed_base}.bed" > "${bed_base}.trim.bed"

	echo "selected columns"

	# add a header
	HEADER="chr\tpos\tN\tX"
	{ echo -e "$HEADER"; cat "${bed_base}.trim.bed"; } > "${bed_base}.trim.header.bed"

	echo "added header"

	# remove the trim.swapped.bed file
	mv "${bed_base}.trim.header.bed" "${bed_base}.trim.bed"

	# zip the original bed file
	bgzip "${bed_base}.bed"
	
done
