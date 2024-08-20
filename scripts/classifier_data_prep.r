# this script reads in bed files and formats them for the classifier for one chromosome (test chromosome: 18)
# each row is a sample, column 1 has labels, remaining columns represent CpG sites

# input: chromosome number (ex: "chr18")
args <- commandArgs(trailingOnly=TRUE)
input_chr <- args[1]


library(dplyr)
library(tidyr)
library(readr)

print("Input chromosome")
print(input_chr)

print("done reading libraries")

# read  in the data frames
read_bed_file <- function(file_path, label, sample_id, regions) {
  data <- read.table(file_path, header = TRUE, sep = "\t")
  colnames(data) <- c("chr", "pos", "reads", "meth_reads")
  
  # Filter data for the chromosome and pos within regions
  data <- data %>%
    filter(chr == input_chr) %>%
    rowwise() %>%
    filter(any(pos >= regions$start & pos <= regions$end)) %>%
    mutate(methylation = meth_reads / reads) %>%
    select(pos, methylation)
  
  data$Label <- label
  data$Sample <- sample_id
  print(sample_id)
  return(data)
}

# read in the dmr data
all_dmrs_path <- "/data/Phillippy2/projects/belluck_dmr/dmr_files/dmrs_all.bed"
all_dmrs <- read.table(all_dmrs_path, header = FALSE, sep = "\t")
colnames(all_dmrs) <- c("chr", "start", "end", "len", "cpg", "matmeth", "patmeth", "diffmeth", "areastat") 
all_dmrs_filtered <- all_dmrs %>% filter(chr == input_chr)
all_dmrs_sorted <- all_dmrs_filtered %>%
  arrange(desc(abs(areastat)))
all_dmrs_sorted <- all_dmrs_sorted %>%
  mutate(cumulative_cpg = cumsum(cpg))
filtered_dmrs <- all_dmrs_sorted %>%
  filter(cumulative_cpg <= 20000)
filtered_dmrs <- filtered_dmrs %>%
  select(-cumulative_cpg)


regions <- filtered_dmrs %>% select(start, end)
write_tsv(regions, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_regions.tsv"))
print("done filtering dmrs")

# read in and impute the maternal and paternal data
maternal_files <- list.files(path = paste0("/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/", input_chr, "/"), pattern = paste0("*mat_to_chm13v2_winnowmap_ont.methyl.trim.", input_chr, ".bed"), full.names = TRUE)
maternal_data <- do.call(rbind, lapply(seq_along(maternal_files), function(i) {
  read_bed_file(maternal_files[i], label = "Maternal", sample_id = basename(maternal_files[i]), regions = regions)
}))
#write_tsv(maternal_data, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_mat_data.tsv"))
print("done reading maternal")

maternal_data_wide <- maternal_data %>%
  pivot_wider(names_from = Sample, values_from = methylation)
# only keep rows where at least 50% of the samples have data for that site
maternal_data_wide <- maternal_data_wide %>%
  filter(rowSums(is.na(.)) < ((ncol(maternal_data_wide) - 2)/2))
#write_tsv(maternal_data_wide, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_mat_data_wide.tsv"))
print("done maternal wider")

maternal_data_imputed <- maternal_data_wide %>%
  rowwise() %>%
  mutate(across(starts_with("HG"), ~if_else(is.na(.),
                                                mean(c_across(starts_with("HG")), na.rm = TRUE),
                                                .))) %>%
  ungroup()
#write_tsv(maternal_data_imputed, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_mat_data_imputed.tsv"))
print("done maternal imputed")

maternal_data_long <- as.data.frame(t(maternal_data_imputed))
colnames(maternal_data_long) <- maternal_data_long[1, ]
maternal_data_long <- cbind(Sample = colnames(maternal_data_imputed), maternal_data_long)
maternal_data_long <- maternal_data_long[-(1:2), ]
maternal_data_long <- maternal_data_long %>%
        mutate(Label = "Maternal", .after = "Sample")
#write_tsv(maternal_data_long, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_mat_data_long.tsv"))

print("done reading in and imputing maternal data")


paternal_files <- list.files(path = paste0("/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/", input_chr, "/"), pattern = paste0("*pat_to_chm13v2_winnowmap_ont.methyl.trim.", input_chr, ".bed"), full.names = TRUE)
paternal_data <- do.call(rbind, lapply(seq_along(paternal_files), function(i) {
  read_bed_file(paternal_files[i], label = "Paternal", sample_id = basename(paternal_files[i]), regions = regions)
}))
#write_tsv(paternal_data, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_pat_data.tsv"))
print("done reading paternal")

paternal_data_wide <- paternal_data %>%
  pivot_wider(names_from = Sample, values_from = methylation)
# only keep rows where at least 50% of the samples have data for that site
paternal_data_wide <- paternal_data_wide %>%
  filter(rowSums(is.na(.)) < ((ncol(paternal_data_wide) - 2)/2))
#write_tsv(paternal_data_wide, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_pat_data_wide.tsv"))
print("done paternal wider")

paternal_data_imputed <- paternal_data_wide %>%
  rowwise() %>%
  mutate(across(starts_with("HG"), ~if_else(is.na(.),
                                                mean(c_across(starts_with("HG")), na.rm = TRUE),
                                                .))) %>%
  ungroup()
#write_tsv(paternal_data_imputed, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_pat_data_imputed.tsv"))
print("done paternal imputed")

paternal_data_long <- as.data.frame(t(paternal_data_imputed))
colnames(paternal_data_long) <- paternal_data_long[1, ]
paternal_data_long <- cbind(Sample = colnames(paternal_data_imputed), paternal_data_long)
paternal_data_long <- paternal_data_long[-(1:2), ]
paternal_data_long <- paternal_data_long %>%
        mutate(Label = "Paternal", .after = "Sample")
#write_tsv(paternal_data_long, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_pat_data_long.tsv"))

print("done reading in and imputing paternal data")


shared_columns <- intersect(names(maternal_data_long), names(paternal_data_long))
mat_data <- maternal_data_long %>% select(all_of(shared_columns))
pat_data <- paternal_data_long %>% select(all_of(shared_columns))

combined_data <- bind_rows(mat_data, pat_data)

write_tsv(combined_data, paste0("/data/Phillippy2/projects/belluck_dmr/classifier_data/", input_chr, "_combined_data.tsv"))
print("saved combined data")

