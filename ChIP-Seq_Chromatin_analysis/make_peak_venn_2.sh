#!/usr/bin/env bash
set -euo pipefail

A="04_23_2026_RPE_siSETD2_23_KDM4C_Set_1_S23_seacr_top0.01.stringent.bed"
B="04_23_2026_RPE_siSETD2_25_KDM4C_Set_1_S24_seacr_top0.01.stringent.bed"


A_NAME="siSETD2_23_KDM4C"
B_NAME="siSETD2_25_KDM4C"

OUT_PREFIX="siSETD2_23_KDM4C_vs_siSETD2_25_KDM4C_Set1"

# Output files
COUNTS_TSV="${OUT_PREFIX}_counts.tsv"
OVERLAP_BED="${OUT_PREFIX}_shared_peaks.bed"
JACCARD_TSV="${OUT_PREFIX}_jaccard.tsv"
R_SCRIPT="${OUT_PREFIX}_venn.R"
VENN_PDF="${OUT_PREFIX}_venn.pdf"
OVERLAP_BED="${OUT_PREFIX}_shared_peaks.bed"  
A_UNIQUE_BED="${OUT_PREFIX}_siSETD2_23_KDM4C_Set_1_S23_unique_peaks.bed"
B_UNIQUE_BED="${OUT_PREFIX}_siSETD2_25_KDM4C_Set_1_S24_unique_peaks.bed"

# Check inputs
for f in "$A" "$B"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: file not found: $f" >&2
    exit 1
  fi
done

if ! command -v bedtools >/dev/null 2>&1; then
  echo "Error: bedtools not found in PATH" >&2
  exit 1
fi

if ! command -v Rscript >/dev/null 2>&1; then
  echo "Error: Rscript not found in PATH" >&2
  exit 1
fi

# Peak counts
A_total=$(wc -l < "$A" | tr -d ' ')
B_total=$(wc -l < "$B" | tr -d ' ')

# Save overlapping peaks from A that overlap B
bedtools intersect -a "$A" -b "$B" -u \
  | LC_ALL=C sort -k1,1 -k2,2n -k3,3n \
  > "$OVERLAP_BED"

# Peaks unique to A
bedtools intersect -a "$A" -b "$B" -v \
  | LC_ALL=C sort -k1,1 -k2,2n -k3,3n \
  > "$A_UNIQUE_BED"

# Peaks unique to B
bedtools intersect -a "$B" -b "$A" -v \
  | LC_ALL=C sort -k1,1 -k2,2n -k3,3n \
  > "$B_UNIQUE_BED"

shared=$(wc -l < "$OVERLAP_BED" | tr -d ' ')
A_only=$(wc -l < "$A_UNIQUE_BED" | tr -d ' ')
B_only=$(wc -l < "$B_UNIQUE_BED" | tr -d ' ')

# Jaccard: keep only chromosomes present in both files, then sort consistently
cut -f1 "$A" | sort -u > A.chroms
cut -f1 "$B" | sort -u > B.chroms
comm -12 A.chroms B.chroms > common.chroms

grep -Fwf common.chroms "$A" > A.filtered.tmp.bed
grep -Fwf common.chroms "$B" > B.filtered.tmp.bed

LC_ALL=C sort -k1,1 -k2,2n -k3,3n A.filtered.tmp.bed > A.filtered.bed
LC_ALL=C sort -k1,1 -k2,2n -k3,3n B.filtered.tmp.bed > B.filtered.bed

bedtools jaccard -a A.filtered.bed -b B.filtered.bed > "$JACCARD_TSV"

rm -f A.chroms B.chroms common.chroms A.filtered.tmp.bed B.filtered.tmp.bed A.filtered.bed B.filtered.bed

echo
echo "Jaccard results:"
cat "$JACCARD_TSV"


# Create R script
cat > "$R_SCRIPT" <<EOF
args <- commandArgs(trailingOnly = TRUE)

A_total <- as.numeric(args[1])
B_total <- as.numeric(args[2])
shared  <- as.numeric(args[3])
A_name  <- args[4]
B_name  <- args[5]
out_pdf <- args[6]

if (!requireNamespace("VennDiagram", quietly = TRUE)) {
  install.packages("VennDiagram", repos = "https://cloud.r-project.org")
}

library(VennDiagram)
library(grid)

pdf(out_pdf, width = 6, height = 6)
grid.newpage()

venn.plot <- draw.pairwise.venn(
  area1 = A_total,
  area2 = B_total,
  cross.area = shared,
  category = c(A_name, B_name),
  fill = c("skyblue2", "yellow3"),
  alpha = c(0.5, 0.5),
  scaled = TRUE,
  cex = 1.6,
  cat.cex = 1.2,
  cat.pos = c(-20, 20),
  cat.dist = c(0.05, 0.05)
)

grid.draw(venn.plot)
dev.off()
EOF

# Run R script
Rscript "$R_SCRIPT" \
  "$A_total" \
  "$B_total" \
  "$shared" \
  "$A_NAME" \
  "$B_NAME" \
  "$VENN_PDF"

echo
echo "Done."
echo "PDF: $VENN_PDF"
echo "Counts table: $COUNTS_TSV"
echo "Overlap peaks: $OVERLAP_BED"
echo "Jaccard table: $JACCARD_TSV"
echo "Unique peaks in A: $A_UNIQUE_BED"
echo "Unique peaks in B: $B_UNIQUE_BED"