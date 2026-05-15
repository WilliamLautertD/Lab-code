# Load libraries
library(tidyverse)
library(egg)
library(GenomicRanges)
library(biomaRt)
library(purrr)
library(patchwork)

# Input files
# read counts
counts <- read_tsv("KDM4C_OE_H3K4me3_and_EV_H3K4me3.tab")

# subset and keep the numeric
counts_numeric <- counts[,4:5] # Change the column indices to match your numeric columns

# Make it log2 transform
counts_log2 <- log2(counts_numeric)

# Merge
counts_trans <- bind_cols(counts[,1:3], counts_log2)
names <- c("chr", 
           "start", 
           "end", 
           "3_27_26_EV_H3K4me3_avg.bw",
           "3_27_26_KDM4C_OE_H3K4me3_avg.bw")

colnames(counts_trans) <- names

# Annotate
# MYC region


MYC_CHR   <- "chr8" # Change it to your peak chromosome
MYC_START <- 128744201 # Change it to your peak start
MYC_END   <- 128756200 # Change it to your peak end


PEAK_CHR   <- "chr8"
PEAK_START <- 128980878
PEAK_END   <- 128984816

counts_trans_annotated <- counts_trans %>%
  mutate(
    gene = case_when(
      # MYC bin
      chr == MYC_CHR &
        start <= MYC_START &
        end   >= MYC_END ~ "MYC",
      # Peak 78610
      chr == PEAK_CHR &
        start <= PEAK_END &
        end   >= PEAK_START ~ "PVT1",
      TRUE ~ NA_character_
    )
  )

# Verify annotation
counts_trans_annotated %>% filter(!is.na(gene))
counts_trans_annotated %>% filter(gene == "MYC")

# PLot 
# Set comparisons for the scatter plot
pairs <- list(
  c("3_27_26_EV_H3K4me3_avg.bw", "3_27_26_KDM4C_OE_H3K4me3_avg.bw")
)

# Scatter plots with identity line and threshold lines
plots <- map(pairs, \(p) {
  ggplot(counts_trans_annotated, aes(x = .data[[p[1]]], y = .data[[p[2]]])) +
    geom_point(alpha = 0.2, color = "lightblue") +
    geom_point(
      data = subset(counts_trans_annotated, gene == "MYC"),
      color = "red",
      size = 2
    ) +
    # Identity line (y = x), gray dashed
    geom_abline(intercept = 0, slope = 1,
                color = "darkgrey", linetype = "dashed", linewidth = 0.6) +
    # Upper threshold line (y = x + 1, i.e. 2-fold up), red dashed
    geom_abline(intercept = 1, slope = 1,
                color = "red", linetype = "dashed", linewidth = 0.6) +
    # Lower threshold line (y = x - 1, i.e. 2-fold down), red dashed
    geom_abline(intercept = -1, slope = 1,
                color = "red", linetype = "dashed", linewidth = 0.6) +
    
    # Upper threshold line (y = x + 1, i.e. 2-fold up), red dashed
    geom_abline(intercept = 0.2630344, slope = 1,
                color = "orange", linetype = "dashed", linewidth = 0.6) +
    # Lower threshold line (y = x - 1, i.e. 2-fold down), red dashed
    geom_abline(intercept = -0.2630344, slope = 1,
                color = "orange", linetype = "dashed", linewidth = 0.6) +
    
    labs(
      x = p[1],
      y = p[2],
      title = paste(p[1], "vs", p[2], "- RPKM (log2)")
    ) +
    theme_classic() +
    theme(
      plot.title = element_text(size = 10)
    ) +
    xlim(c(-3, 8)) +
    ylim(c(-3, 8))
})


combined_plot <- wrap_plots(plots)

# Save plots to PDF
ggsave(
  filename = "EV_H3K4me3_and_KDM4C_OE_H3K4me3.pdf",
  plot = combined_plot,
  width = 15,
  height = 10
)

# Compute fold change for MYC

fold_change <- counts_trans_annotated %>% 
  filter(gene == "MYC") %>%
  dplyr::select(chr, start, end, 
         `3_27_26_EV_KDM4C_4ug_avg.bw`, 
         `3_27_26_KDM4C_OE_KDM4C_4ug_avg.bw`) %>%
  mutate(
    log2FC = `3_27_26_KDM4C_OE_KDM4C_4ug_avg.bw` - `3_27_26_EV_KDM4C_4ug_avg.bw`,
    fold_change = 2^log2FC
  )

write_tsv(fold_change, "fold_change_KDM4C_OE_KDM4C_4ug_and_EV_KDM4C_4ug.txt")


