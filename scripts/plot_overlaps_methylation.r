column_names <- c("Akbari_chr", "Akbari_start", "Akbari_end", "Akbari_len", "Akbari_cpg", "Akbari_mat_meth", "Akbari_pat_meth", "Akbari_diff_meth", "Akbari_areastat", "Akbari_imprinting", "Belluck_chr", "Belluck_start", "Belluck_end", "Belluck_len", "Belluck_cpg", "Belluck_mat_meth", "Belluck_pat_meth", "Belluck_diff_meth", "Belluck_areastat", "overlap_len", "Akbari_pct_overlap", "Belluck_pct_overlap")

bed_df <- read.table("/data/Phillippy2/projects/belluck_dmr/dmr_files/dmr_overlaps.bed", header = FALSE, col.names = column_names)

bed_df$imprinting_variation <- bed_df$Akbari_diff_meth - bed_df$Belluck_diff_meth

write.table(bed_df, "/data/Phillippy2/projects/belluck_dmr/dmr_files/dmr_overlaps_with_header.bed", sep = "\t", row.names = FALSE, quote = FALSE)

library(ggplot2)

bed_df$color <- ifelse(
  (bed_df$Akbari_diff_meth > 0 & bed_df$Belluck_diff_meth > 0) |
  (bed_df$Akbari_diff_meth < 0 & bed_df$Belluck_diff_meth < 0),
  "green",
  "red"
)

# plot Akbari difference in methylation vs. Belluck difference in methylation, colored by the percent of the Akbari region that is overlapped by Belluck regions
plot_pct_overlap_akbari <- ggplot(bed_df, aes(x = Belluck_diff_meth, y = Akbari_diff_meth, color = Akbari_pct_overlap)) +
  geom_point(alpha = 0.5, size = 2) +
  scale_color_gradient(low = "yellow", high = "red") +  # Adjust colors as needed
  labs(x = "mean maternal - mean paternal [Belluck]", y = "mean maternal - mean paternal [Akbari]", color = "% overlap [Akbari]") +
  geom_abline(intercept = 0, slope = 1, linetype = "solid", color = "black")+
  scale_x_continuous(breaks = seq(from = floor(min(bed_df$Belluck_diff_meth)), 
                                  to = ceiling(max(bed_df$Belluck_diff_meth)), 
                                  by = 0.2)) +
  scale_y_continuous(breaks = seq(from = floor(min(bed_df$Akbari_diff_meth)), 
                                  to = ceiling(max(bed_df$Akbari_diff_meth)), 
                                  by = 0.2)) +
  theme_minimal()

# plot Akbari difference in methylation vs. Belluck difference in methylation, colored by the percent of the Belluck region that is overlapped by Akbari regions
plot_pct_overlap_belluck <- ggplot(bed_df, aes(x = Belluck_diff_meth, y = Akbari_diff_meth, color = Belluck_pct_overlap)) +
  geom_point(alpha = 0.5, size = 2) +
  scale_color_gradient(low = "yellow", high = "red") +  # Adjust colors as needed
  labs(x = "mean maternal - mean paternal [Belluck]", y = "mean maternal - mean paternal [Akbari]", color = "% overlap [Belluck]") +
  geom_abline(intercept = 0, slope = 1, linetype = "solid", color = "black")+
  scale_x_continuous(breaks = seq(from = floor(min(bed_df$Belluck_diff_meth)),
                                  to = ceiling(max(bed_df$Belluck_diff_meth)),
                                  by = 0.2)) +
  scale_y_continuous(breaks = seq(from = floor(min(bed_df$Akbari_diff_meth)),
                                  to = ceiling(max(bed_df$Akbari_diff_meth)),
                                  by = 0.2)) +
  theme_minimal()


ggsave("/data/Phillippy2/projects/belluck_dmr/dmr_files/plot_overlaps_pct_overlap_akbari.png", plot_pct_overlap_akbari)
ggsave("/data/Phillippy2/projects/belluck_dmr/dmr_files/plot_overlaps_pct_overlap_belluck.png", plot_pct_overlap_belluck)

# plot Akbari difference in methylation vs. Belluck difference in methylation, colored by imprinting consistency (green=agree, red=disagree)
plot_imprinting <- ggplot(bed_df, aes(x = Belluck_diff_meth, y = Akbari_diff_meth, color = color)) +
  geom_point(alpha = 0.5, size = 2) +
  scale_color_manual(values = c("red" = "red", "green" = "green")) +
  labs(x = "mean maternal - mean paternal [Belluck]", y = "mean maternal - mean paternal [Akbari]") +
  geom_abline(intercept = 0, slope = 1, linetype = "solid", color = "black")+
  scale_x_continuous(breaks = seq(from = floor(min(bed_df$Belluck_diff_meth)),
                                  to = ceiling(max(bed_df$Belluck_diff_meth)),
                                  by = 0.2)) +
  scale_y_continuous(breaks = seq(from = floor(min(bed_df$Akbari_diff_meth)),
                                  to = ceiling(max(bed_df$Akbari_diff_meth)),
                                  by = 0.2)) +
  theme_minimal()

ggsave("/data/Phillippy2/projects/belluck_dmr/dmr_files/plot_overlaps_imprinting_direction.png", plot_imprinting)


