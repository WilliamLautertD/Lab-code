#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=deeptools
#SBATCH --output=deeptools.log
#SBATCH --error=deeptools.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

set -euo pipefail
shopt -s nullglob

# Directories
BAM_DIR="/rs01/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection/bwa_mapping_hg19/rmdupl_duplicates"
BW_DIR_default="/rs01/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection/bw_RPE_Takara_default"
BW_DIR_custom="/rs01/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection/bw_RPE_Takara_custom"

mkdir -p "$BW_DIR_default" "$BW_DIR_custom"

# Parameters
BIN_SIZE=50
SMOOTH_LEN=200

#----------------------------------------------------------
# CTCF  (Input: 02122026_RPE_CTCF_INPUT_S16)
#----------------------------------------------------------

# DEFAULT
for bam in "$BAM_DIR"/02122026_RPE_CTCF_R*.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_default/${base}_B50_SML200.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02122026_RPE_CTCF_INPUT_S16.sorted.rmdup.bam" \
    -o "$bw" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE"
done

# CUSTOM CPM
for bam in "$BAM_DIR"/02122026_RPE_CTCF_R*.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_custom/${base}_CPM_B50_SML200.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02122026_RPE_CTCF_INPUT_S16.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --normalizeUsing CPM \
    --extendReads \
    --scaleFactorsMethod None
done

# Custom RPKM
for bam in "$BAM_DIR"/02122026_RPE_CTCF_R*.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_custom/${base}_RPKM_B50_SML200.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02122026_RPE_CTCF_INPUT_S16.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --normalizeUsing RPKM \
    --extendReads \
    --scaleFactorsMethod None
done


#----------------------------------------------------------
# Histones (Input: 02122026_RPE_Histone_INPUT_S15)
# Samples:
# H3K36me1/2/3 R1/R2
# H3K9me1/2/3  R1/R2
#----------------------------------------------------------

# DEFAULT
for bam in "$BAM_DIR"/02122026_RPE_H3K*_R*.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_default/${base}_B50_SML200.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02122026_RPE_Histone_INPUT_S15.sorted.rmdup.bam" \
    -o "$bw" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE"
done

# CUSTOM CPM
for bam in "$BAM_DIR"/02122026_RPE_H3K*_R*.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_custom/${base}_CPM_B50_SML200.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02122026_RPE_Histone_INPUT_S15.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --normalizeUsing CPM \
    --extendReads \
    --scaleFactorsMethod None
done

# Custom RPKM
for bam in "$BAM_DIR"/02122026_RPE_H3K*_R*.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_custom/${base}_RPKM_B50_SML200.bw"
  echo "Processing CUSTOM  $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02122026_RPE_Histone_INPUT_S15.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --normalizeUsing RPKM \
    --extendReads \
    --scaleFactorsMethod None
done

