# this script runs the DSS package on a set of bed files to identify DMRs

# directory with all the bed files
args <- commandArgs(trailingOnly=TRUE)

bed_dir <- args[1]
print(bed_dir)
chr <- args[2]
print(chr)
out_dir <- args[3]
print(out_dir)

# load libraries
suppressPackageStartupMessages(library(BiocManager))
print("BiocManager loaded")
suppressPackageStartupMessages(library(DSS))
print("DSS loaded")
require(bsseq)

# create a list of all the bed files
bed_files <- list.files(bed_dir, pattern = ".bed$", full.names = TRUE)
num_files <- length(bed_files)
paste0(num_files, " bed files found")
print(bed_files)

# create a list of dataframes
bed_df_list <- list()

print("Reading in files...")
for (file in bed_files) {
	file_name <- basename(file)
	# get the genome identifier (HG0****_*at)
	var_name <- substr(file_name, 1, 11)
	df <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
	bed_df_list[[var_name]] <- df
	print(var_name)
}
print("Done")

# create a vector of mat/pat identifiers
indices <- 1:num_files
mat_pat_vector <- ifelse(indices %% 2 == 0, paste0("pat", indices/2), paste0("mat", (indices+1)/2))
print("mat/pat vector")
print(mat_pat_vector)

# make a BS object
print("Making BS object...")
BSobj = makeBSseqData( bed_df_list, mat_pat_vector )

# print out information about the BS object
BSobj

# create a vector for each group
mat_vector <- paste0("mat", seq(1, num_files/2))
pat_vector <- paste0("pat", seq(1, num_files/2))
print("mat vector")
print(mat_vector)
print("pat vector")
print(pat_vector)

# perform statistical testing with smoothing
print("Statistical testing with smoothing...")
print("dmlTest.sm = DMLtest(BSobj, group1=mat_vector, group2=pat_vector, smoothing=TRUE, equal.disp=FALSE, smoothing.span=500, ncores=20)")
dmlTest.sm = DMLtest(BSobj, group1=mat_vector, group2=pat_vector, smoothing=TRUE, equal.disp=FALSE, smoothing.span=500, ncores=20)

# idenfity DMLs and DMRs
# delta = the minimum difference between mean methylation of maternal and paternal haplotypes
# p.threshold = the minimum p-value for a locus to be considered significant
# minlen = the minimum length of a DMR
# minCG = the minimum number of CpG sites needed for a DMR
# dis.marge = if two DMRs are within this distance of each other, they will be merged
# pct.sig = the minimum percentage of CpG sites that must be significant in a region
print("Calling DMLs")
print("dmls = callDML(dmlTest.sm, delta=0, p.threshold=0.001)")
dmls = callDML(dmlTest.sm, delta=0, p.threshold=0.001)
print("Calling DMRs")
print("dmrs = callDMR(dmlTest.sm, delta=0, p.threshold=0.001, minlen=100, minCG=15, dis.merge=100, pct.sig=0.5)")
dmrs = callDMR(dmlTest.sm, delta=0, p.threshold=0.001, minlen=100, minCG=15, dis.merge=100, pct.sig=0.5)

# write the data to tsv files
paste0("Saving DML and DMR tables to ", out_dir)
write.table(dmls, file = paste0(out_dir, "/", chr, ".dmls.tsv"), sep = "\t", row.names = FALSE, quote = FALSE)
write.table(dmrs, file = paste0(out_dir, "/", chr, ".dmrs.tsv"), sep = "\t", row.names = FALSE, quote = FALSE)


