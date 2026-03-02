#!/bin/bash
#SBATCH --job-name=deeptools_2
#SBATCH --output=deeptools_2.log
#SBATCH --error=deeptools_2.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

set -euo pipefail
shopt -s nullglob

# Directories
BAM_DIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/bwa_mapping_hg19/marked_duplicates"
BW_DIR_default="/home/lauterw/RPE_Takara_Chip_Seq_Test/results/bw_RPE_Takara_default"
BW_DIR_custom="/home/lauterw/RPE_Takara_Chip_Seq_Test/results/bw_RPE_Takara_custom"

mkdir -p "$BW_DIR_default" "$BW_DIR_custom"

# Parameters
BIN_SIZE=200
SMOOTH_LEN=600

#----------------------------------------------------------
# KDM4C
# R1 Input: 01162026_RPE_KDM4C_INPUT_R1_S12
# R2 Input: 01162026_RPE_KDM4C_INPUT_R2_S22
#----------------------------------------------------------

# DEFAULT (R1)
for bam in "$BAM_DIR"/01162026_RPE_KDM4C_R1_S11.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_default/${base}.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4C_INPUT_R1_S12.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

# DEFAULT (R2)
for bam in "$BAM_DIR"/01162026_RPE_KDM4C_R2_S21.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_default/${base}.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4C_INPUT_R2_S22.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

# CUSTOM (R1)
for bam in "$BAM_DIR"/01162026_RPE_KDM4C_R1_S11.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_custom/${base}.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4C_INPUT_R1_S12.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

# CUSTOM (R2)
for bam in "$BAM_DIR"/01162026_RPE_KDM4C_R2_S21.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_custom/${base}.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4C_INPUT_R2_S22.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

#----------------------------------------------------------
# KDM4D
# R1 Input: 01162026_RPE_KDM4D_INPUT_R1_S14
# R2 Input: 01162026_RPE_KDM4D_INPUT_R2_S24
#----------------------------------------------------------

# DEFAULT (R1)
for bam in "$BAM_DIR"/01162026_RPE_KDM4D_R1_S13.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_default/${base}.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4D_INPUT_R1_S14.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

# DEFAULT (R2)
for bam in "$BAM_DIR"/01162026_RPE_KDM4D_R2_S23.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_default/${base}.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4D_INPUT_R2_S24.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

# CUSTOM (R1)
for bam in "$BAM_DIR"/01162026_RPE_KDM4D_R1_S13.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_custom/${base}.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4D_INPUT_R1_S14.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

# CUSTOM (R2)
for bam in "$BAM_DIR"/01162026_RPE_KDM4D_R2_S23.marked.bam; do
  base=$(basename "$bam" .marked.bam)
  bw="$BW_DIR_custom/${base}.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/01162026_RPE_KDM4D_INPUT_R2_S24.marked.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK"
done

echo "Done."

