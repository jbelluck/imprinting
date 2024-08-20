# imprinting

This directory contains all of my data and scripts from my iDMR detection and classification project from summer 2024.
If you have any questions, please reach out to me at jillian_belluck@brown.edu.
Updated August 16, 2024

Directories:

chm13 -> /data/pickettbd/parent-of-origin/chm13
Contains the CHM13 reference genome and associated files.

classifier_data
-For each chromosome, contains the iDMRs (*regions.tsv) that we identified and the CpG sites that I used as input for my classifier (*combined_data.tsv), both of which were generated with scripts/classifier_data_prep.r. cpg_sites_for_clasifier.txt contains the number of CpG sites used as input to the models.
-classifier.out contains the output of my random forest classifier for each chromosome, which was generated with scripts/classifier.r and has information about the model, accuracy, etc.
-model_stats.tsv has information about the accuracy and number of CpG sites used in the models for each chromosome. This information is plotted in plot_classifier_accuracy.png and plot_classifier_features.png. 

cpgi
-Contains bed files with known iDMRs (from Akbari 2022 papers) in HG002, HG38, and CHM13 coordinates. [Note that a more accurate list of iDMRs in CHM13 coordinates is in dmr_files].
-HG38_cpgi.bed has the CpG islands in HG38, and HG38_iDMRs_not_overlapping_with_CGIs.bed has a list of Akbari's iDMRs that don't overlap with CpG islands (~40% have no overlap).

dmr_files
-Akbari_DMRs* contain the iDMRs (from Akbari 2022 papers) in CHM13 and HG38 coordinates.
-avg_methylation_Akbari_DMRs_chm13v2.bed contains the DSS output for the 196 (out of 200) iDMRs that lifted from HG38 to CHM13, as well as the average methylation for maternal and paternal samples for those same regions in my data. avg_methylation_Belluck_DMRs_chm13v2.bed is the same, but the regions are the 182 regions I identified where the difference in average methylation between maternal and paternal haplotypes was >=0.2.
-dmr_overlaps* contains information about all of Akbari's iDMRs for which we identified an overlapping iDMR region in our data.
-dmrs_*.bed has the DMRs that I identified, filtered based on difference between average maternal and paternal methylation (>=0.1, >=0.2, all).
-Information about the DMRs that I identified and their overlaps with Akbari's DMRs are in the plots. 

scripts
-Contains all of my scripts for detecting iDMRs and classifying haplotypes. See script comments for more information.

test
-Contains files related to the CHM13 reference genome, and Brandon's test directory. 

v3_bedmethyls
-For each chromosome and haplotype, contains the bedmethyl file in the personal genome coordinates and in the CHM13 coordinates (and the regions that were unmappable with CrossMap).
-/chr_split contains a directory for each chromosome, which has the bedmethyl files in CHM13 coordinates split by chromosome, generated with splitTrimmedByChr*.

v3_chainbeds
-Contains chain files mapping the personal genomes to CHM13, and their corresponding bed files (for viewing in IGV), generated with scripts/chain2bed_mult.sh. 

v3_dmrs
-Contains the iDMRs (imprinted differentially methylated regions) and iDMLs (imprinted differentially methylated loci) for each chromosome, as calculated by the R Bioconductor DSS package (scripts/dss.r).

v3_fastas
-Contains the input fastas and output paf files for each HPRC genome, as generated with scripts/wfmash_paf.sh.

verkkoV1Asms-hprc-bri -> /data/pickettbd/parent-of-origin/verkkoV1Asms-hprc-bri
-Links to the input fastas for each HPRC genome.

