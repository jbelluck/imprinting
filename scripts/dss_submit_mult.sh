#!/bin/bash

# this script submits dss_submit.sh for each directory in bed_chr_dir

# bed_chr_dir contains a separate directory for each chromosome (which contains bedmethyl files for each haplotype and sample)
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
bed_chr_dir="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/"

# loop through each directory
for chr_dir in "$bed_chr_dir"/*/; do

	echo $chr_dir
	# get the name of the chromosome
	chr=$(basename "$chr_dir")
	echo $chr

	# submit the job to run the r script
	sbatch -J $chr --cpus-per-task=28 --mem=247g --gres=lscratch:5 --partition=norm -D /data/Phillippy2/projects/belluck_dmr/v3_dmrs/ --time=24:00:00 --error="${chr}.err.log" --output="${chr}.out.log" /data/Phillippy2/projects/belluck_dmr/dss_submit.sh $chr_dir
	echo $chr
done

