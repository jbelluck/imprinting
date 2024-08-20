#!/bin/bash

module load bedtools

AKBARI_BED="/data/Phillippy2/projects/belluck_dmr/dmr_files/Akbari_DMRs_chm13v2_196.bed"
BELLUCK_BED="/data/Phillippy2/projects/belluck_dmr/dmr_files/dmrs_all.bed"

bedtools intersect -a $AKBARI_BED -b $BELLUCK_BED -wo | awk '{
  akbari_length=$3-$2;
  belluck_length=$13-$12;
  overlap_length=$NF;
  akbari_overlap_percentage=(overlap_length/akbari_length)*100;
  belluck_overlap_percentage=(overlap_length/belluck_length)*100;
  print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 "\t" $11 "\t" $12 "\t" $13 "\t" $14 "\t" $15 "\t" $16 "\t" $17 "\t" $18 "\t" $19 "\t" $20 "\t" akbari_overlap_percentage "\t" belluck_overlap_percentage;
}' > dmr_overlaps.bed




