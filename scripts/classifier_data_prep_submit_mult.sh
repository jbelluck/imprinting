#!/bin/bash


bed_chr_dir="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/"

# loop through each directory
for chr_dir in "$bed_chr_dir"/*/; do

        echo $chr_dir
        # get the name of the chromosome
        chr=$(basename "$chr_dir")
        echo $chr


	sbatch -J "${chr}_classifier_data_prep" --cpus-per-task=12 --mem=10g --gres=lscratch:5 --partition=quick -D /data/Phillippy2/projects/belluck_dmr/classifier_data/ --time=4:00:00 --error="${chr}_classifier_data_prep.err.log" --output="${chr}_classifier_data_prep.out.log" /data/Phillippy2/projects/belluck_dmr/classifier_data_prep_submit.sh $chr
	echo $chr
done

