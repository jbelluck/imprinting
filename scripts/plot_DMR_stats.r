library(ggplot2)
library(tidyr)
library(dplyr)


data <- read.delim("/data/Phillippy2/projects/belluck_dmr/dmr_files/dmr_stats.tsv", sep = "\t")

data$chr <- gsub("^chr", "", data$chr)

data$chr <- factor(data$chr, levels = c(as.character(1:22), "X"))


# Step 2: Prepare the data for ggplot
# Reshape the data to long format
data_long <- data %>%
  select(chr, matDMRs, patDMRs) %>%
  pivot_longer(cols = c(matDMRs, patDMRs),
               names_to = "Type",
               values_to = "DMRs")

# Make sure the "Type" column is a factor with correct order
data_long$Type <- factor(data_long$Type, levels = c("patDMRs", "matDMRs"))

data_long2 <- data %>%
  select(chr, matCpGs, patCpGs) %>%
  pivot_longer(cols = c(matCpGs, patCpGs),
               names_to = "Type",
               values_to = "CpGs")

# Make sure the "Type" column is a factor with correct order
data_long2$Type <- factor(data_long2$Type, levels = c("patCpGs", "matCpGs"))




# Step 3: Create the stacked bar plot
plot_dmrs <- ggplot(data_long, aes(x = chr, y = DMRs, fill = Type)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("matDMRs" = "red", "patDMRs" = "blue")) +
  labs(x = "chr", y = "DMRs") +
  theme_minimal()

ggsave(filename = "plot_dmr_stats.png", plot = plot_dmrs, width = 10, height = 6, dpi = 300)


plot_cpgs <- ggplot(data_long2, aes(x = chr, y = CpGs, fill = Type)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("matCpGs" = "red", "patCpGs" = "blue")) +
  labs(x = "chr", y = "CpGs") +
  theme_minimal()

ggsave(filename = "plot_cpg_stats.png", plot = plot_cpgs, width = 10, height = 6, dpi = 300)


