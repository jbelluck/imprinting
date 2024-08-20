#!/bin/bash

# make bash safer
set -euo pipefail

# load the needed modules
module purge
module load bedtools/2.31.1 # bedtools sort
module load htslib/1.20 # bgzip, tabix

# define bed directory
BED_DIR="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls"

# define chm13v2 sizes file
REF_SIZES="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chm13v2.sizes"

# loop through the bed files
for bed_file in "$BED_DIR"/*at_to_chm13v2_*map_ont.methyl.bed; do

	echo $bed_file

	#bed_base=$(basename "${bed_file}")
	bed_base=${bed_file%.*}

	# add back "chr" to column 1
	awk '{ if ($1 !~ /^chr/) print "chr"$0; else print $0 }' $bed_file > "${bed_base}.chradded.bed"

	echo "chr added back"

	# sort the bed file
	bedtools sort -g $REF_SIZES -i "${bed_base}.chradded.bed" > "${bed_base}.sorted.bed"

	echo "sorted the bed file"

	# remove the unsorted bed
	rm -v "${bed_base}.chradded.bed" $bed_file

	# rename the sorted bed to removed "sorted" from the name
	mv -v "${bed_base}.sorted.bed" $bed_file

	# bgzip the bed file
	bgzip $bed_file

	echo "zipped the bed file"

	# index the bed file
	tabix -p bed "${bed_file}.gz"

	echo "indexed the bed file"

done
