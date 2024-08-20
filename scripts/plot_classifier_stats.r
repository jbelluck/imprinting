# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# Read the TSV file
df <- read.table("/data/Phillippy2/projects/belluck_dmr/classifier_data/model_stats.tsv", header = TRUE, sep = "\t")

# Remove 'chr' from the 'chr' column and convert to a numeric value
df$chr <- gsub("chr", "", df$chr)
df$chr <- factor(df$chr, levels = c(as.character(1:22), "X"))

# Split 'seed_accuracies' into individual rows
df_expanded <- df %>%
  separate_rows(seed_accuracies, sep = ",") %>%
  mutate(seed_accuracies = as.numeric(seed_accuracies))

# Plot for total_accuracy with seed accuracies as points
p1 <- ggplot(df, aes(x = chr, y = total_accuracy)) +
  geom_bar(stat = "identity", fill = "orange") +
  geom_point(data = df_expanded, aes(x = chr, y = seed_accuracies), color = "blue", size = 3, alpha = 0.3) +
  theme_minimal() +
  labs(x = "Chromosome", y = "Accuracy") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# Plot for avg_CpGs_used
p2 <- ggplot(df, aes(x = chr, y = avg_CpGs_used)) +
  geom_bar(stat = "identity", fill = "green") +
  theme_minimal() +
  labs(x = "Chromosome", y = "Average Features") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# Save the plots
ggsave("/data/Phillippy2/projects/belluck_dmr/classifier_data/plot_classifier_accuracy.png", plot = p1, width = 8, height = 6)
ggsave("/data/Phillippy2/projects/belluck_dmr/classifier_data/plot_classifier_features.png", plot = p2, width = 8, height = 6)

