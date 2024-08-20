#!/bin/bash

chr=$1
echo $chr

# load R (loading the DSS library on version 4.4.1 hasn't been working for me)
module load R/4.4.0

Rscript "/data/Phillippy2/projects/belluck_dmr/classifier_data_prep.r" $chr > "/data/Phillippy2/projects/belluck_dmr/classifier_data/${chr}_classifier.out"

