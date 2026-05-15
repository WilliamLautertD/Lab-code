library(tidyverse)
library(egg)
library(GenomicRanges)
library(biomaRt)
library(purrr)
library(patchwork)

# read counts
counts <- read_tsv("KDM4C_OE_H3K4me3_and_EV_H3K4me3.tab")


# subset and keep the numeric
counts_numeric <- counts[,4:5]

# Make it log2 transform
counts_log2 <- log2(counts_numeric)

# Merge
counts_trans <- bind_cols(counts[,1:3], counts_log2)
names <- c("chr", 
           "start", 
           "end", 
           "3_27_26_EV_H3K4me3_avg.bw",             # col 4 — matches original
           "3_27_26_KDM4C_OE_H3K4me3_avg.bw")       # col 5 — matches original 

colnames(counts_trans) <- names


# Annotate
# MYC region
KDm4C_CHR   <- "chr8"
KDm4C_START <- 128744201
KDm4C_END   <- 128756200


PEAK_CHR   <- "chr8"
PEAK_START <- 128980878
PEAK_END   <- 128984816

counts_trans_annotated <- counts_trans %>%
  mutate(
    gene = case_when(
      # MYC bin
      chr == KDm4C_CHR &
        start <= KDm4C_START &
        end   >= KDm4C_END ~ "MYC",
      # Peak 78610
      chr == PEAK_CHR &
        start <= PEAK_END &
        end   >= PEAK_START ~ "PVT1",
      TRUE ~ NA_character_
    )
  )

# Verify
counts_trans_annotated %>% filter(!is.na(gene))

# Verify it worked
counts_trans_annotated %>% filter(gene == "MYC")

# PLot 
# Set comparisons
pairs <- list(
  c("3_27_26_EV_H3K4me3_avg.bw", "3_27_26_KDM4C_OE_H3K4me3_avg.bw")
)

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

ggsave(
  filename = "EV_H3K4me3_and_KDM4C_OE_H3K4me3.pdf",
  plot = combined_plot,
  width = 15,
  height = 10
)

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




#### 
# Define threshold
FC_THRESHOLD <- 1  # log2 fold change (= 2-fold)

# Extract regions enriched in siSETD2 across ALL pairs
# A region is "enriched in siSETD2" if siSETD2 > siCT + threshold

enriched_siSETD2 <- counts_trans_annotated %>%
  filter(
    # Set 1 comparisons
    (`RPE_siSETD2_23_KDM4C_Set_1_S23` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD |
       `RPE_siSETD2_23_KDM4C_Set_1_S23` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD |
       `RPE_siSETD2_25_KDM4C_Set_1_S24` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD |
       `RPE_siSETD2_25_KDM4C_Set_1_S24` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD) &
      # Set 2 comparisons
      (`RPE_siSETD2_23_KDM4C_Set_2_S27` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD |
         `RPE_siSETD2_23_KDM4C_Set_2_S27` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD |
         `RPE_siSETD2_25_KDM4C_Set_2_S28` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD |
         `RPE_siSETD2_25_KDM4C_Set_2_S28` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD)
  )



enriched_siSETD2_strict <- counts_trans_annotated %>%
  filter(
    `RPE_siSETD2_23_KDM4C_Set_1_S23` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD,
    `RPE_siSETD2_23_KDM4C_Set_1_S23` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD,
    `RPE_siSETD2_25_KDM4C_Set_1_S24` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD,
    `RPE_siSETD2_25_KDM4C_Set_1_S24` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD,
    `RPE_siSETD2_23_KDM4C_Set_2_S27` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD,
    `RPE_siSETD2_25_KDM4C_Set_2_S28` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD
  )

nrow(enriched_siSETD2_strict)


enriched_siSETD2_strict %>%
  dplyr::select(chr, start, end) %>%
  write_tsv("../seacr_top0.05_stringent/enriched_in_siSETD2_KDM4C.bed", 
            col_names = FALSE)


counts_trans_annotated <- counts_trans_annotated %>%
  mutate(
    enriched_siSETD2 = case_when(
      `RPE_siSETD2_23_KDM4C_Set_1_S23` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD &
        `RPE_siSETD2_23_KDM4C_Set_1_S23` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD &
        `RPE_siSETD2_25_KDM4C_Set_1_S24` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD &
        `RPE_siSETD2_25_KDM4C_Set_1_S24` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD &
        `RPE_siSETD2_23_KDM4C_Set_2_S27` > `RPE_siCT1_KDM4C_Set_1_S21` + FC_THRESHOLD &
        `RPE_siSETD2_25_KDM4C_Set_2_S28` > `RPE_siCT1_KDM4C_Set_2_S25` + FC_THRESHOLD ~ "Enriched in siSETD2",
      TRUE ~ "Background"
    )
  )

plots <- map(pairs, \(p) {
  ggplot(counts_trans_annotated, aes(x = .data[[p[1]]], y = .data[[p[2]]])) +
    geom_point(
      data = subset(counts_trans_annotated, enriched_siSETD2 == "Background"),
      alpha = 0.2, color = "lightblue", size = 0.8
    ) +
    geom_point(
      data = subset(counts_trans_annotated, enriched_siSETD2 == "Enriched in siSETD2"),
      color = "firebrick", alpha = 0.8, size = 1.2
    ) +
    # MYC point
    geom_point(
      data = subset(counts_trans_annotated, gene == "MYC"),
      color = "green", size = 3
    ) +
    # Peak 78610 point
    geom_point(
      data = subset(counts_trans_annotated, gene == "PVT1"),
      color = "orange", size = 3
    ) +
    # Optional: label the points directly on plot
    ggrepel::geom_label_repel(
      data = subset(counts_trans_annotated, !is.na(gene)),
      aes(label = gene),
      size = 3,
      box.padding = 0.5,
      show.legend = FALSE
    ) +
    geom_abline(intercept =  0, slope = 1, color = "darkgrey", linetype = "dashed", linewidth = 0.6) +
    geom_abline(intercept =  1, slope = 1, color = "red",      linetype = "dashed", linewidth = 0.6) +
    geom_abline(intercept = -1, slope = 1, color = "red",      linetype = "dashed", linewidth = 0.6) +
    labs(
      x = p[1],
      y = p[2],
      title = paste(p[1], "vs", p[2], "- RPKM (log2)")
    ) +
    theme_classic() +
    theme(plot.title = element_text(size = 8)) +
    xlim(c(-3, 6)) +
    ylim(c(-3, 6))
})

combined_plot <- wrap_plots(plots)

ggsave(
  filename = "../seacr_top0.05_stringent/siCT_vs_siSETD2_CutTag_KDM4C_enriched.pdf",
  plot = combined_plot,
  width = 15,
  height = 10
)
