#!/bin/bash

# this script runs dss.r for a specific chromosome to identify DMLs and DMRs

# directory with all the bed files
chr_dir=$1

# output directory to store the DMLs and DMRs
out_dir="/data/Phillippy2/projects/belluck_dmr/v3_dmrs"

# load R (loading the DSS library on version 4.4.1 hasn't been working for me)
module load R/4.4.0

# get the name of the chromosome
chr=$(basename "$chr_dir")
echo $chr

# input args: the directory with all the bed files, the chromosome name (ex: "chr1"), the directory to save DML and DMR files
Rscript /data/Phillippy2/projects/belluck_dmr/dss.r $chr_dir $chr $out_dir > "/data/Phillippy2/projects/belluck_dmr/v3_dmrs/${chr}.dss.out"

