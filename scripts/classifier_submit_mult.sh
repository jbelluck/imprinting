#!/bin/bash


bed_chr_dir="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/"

module load R/4.4.0

# loop through each directory
for chr_dir in "$bed_chr_dir"/*/; do

        echo $chr_dir
        # get the name of the chromosome
        chr=$(basename "$chr_dir")
        echo $chr


	Rscript "/data/Phillippy2/projects/belluck_dmr/classifier.r" $chr "/data/Phillippy2/projects/belluck_dmr/classifier_data/model_stats.tsv" >> "/data/Phillippy2/projects/belluck_dmr/classifier_data/classifier.out"

done

