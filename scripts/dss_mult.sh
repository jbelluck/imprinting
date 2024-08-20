#!/bin/bash

# this script runs dss.r for each chromosome to identify DMLs and DMRs

# this directory contains a separate directory for each chromosome (which contains bedmethyl files for each haplotype and sample)
# structure:
# bed_chr_dir
	# chr1
		# HG00423_mat.bed
		# HG00423_pat.bed
		# ...
	# chr2
	# ...
	# chrX
		# should contain fewer files (only the female samples)
#bed_chr_dir="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/"
bed_chr_dir="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/"

# output directory to store the DMLs and DMRs
out_dir="/data/Phillippy2/projects/belluck_dmr/v3_dmrs"

# load R (loading the DSS library on version 4.4.1 hasn't been working for me)
module load R/4.4.0

# loop through each directory
for chr_dir in "$bed_chr_dir"/*/; do

	echo $chr_dir
	# get the name of the chromosome
	chr=$(basename "$chr_dir")
	echo $chr

	# input args: the directory with all the bed files, the chromosome name (ex: "chr1"), the directory to save DML and DMR files
	Rscript /data/Phillippy2/projects/belluck_dmr/dss.r $chr_dir $chr $out_dir > "/data/Phillippy2/projects/belluck_dmr/v3_dmrs/${chr}.dss.out"
done
