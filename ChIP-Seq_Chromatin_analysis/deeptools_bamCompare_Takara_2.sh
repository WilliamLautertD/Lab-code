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
BAM_DIR="/rs01/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/results/bwa_mapping_hg19/rmdupl_duplicates"
BW_DIR_default="/rs01/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/results/bw_RPE_Takara_default"
BW_DIR_custom="/rs01/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/results/bw_RPE_Takara_custom"

mkdir -p "$BW_DIR_default" "$BW_DIR_custom"

# Parameters
BIN_SIZE=200
SMOOTH_LEN=600

#----------------------------------------------------------
# CTCF  (Input: 02262026_RPE_CTCF_INPUT_S9)
#----------------------------------------------------------

# DEFAULT
for bam in "$BAM_DIR"/02262026_RPE_CTCF_10_cycles_S5.sorted.rmdup.bam \
"$BAM_DIR"/02262026_RPE_CTCF_8_cycles_S1.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_default/${base}_B${BIN_SIZE}_SML${SMOOTH_LEN}.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02262026_RPE_CTCF_INPUT_S9.sorted.rmdup.bam" \
    -o "$bw" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE"
done

#----------------------------------------------------------
# Histones (Input: 02262026_RPE_HISTONE_INPUT_S10)
# Samples:
# H3K36me3 R1/R2
# H3K9me1/2  R1/R2
#----------------------------------------------------------

# DEFAULT
for bam in "$BAM_DIR"/02262026_RPE_K9me1_10_cycles_S6.sorted.rmdup.bam \
  "$BAM_DIR"/02262026_RPE_K9me1_8_cycles_S2.sorted.rmdup.bam \
  "$BAM_DIR"/02262026_RPE_K9me2_10_cycles_S7.sorted.rmdup.bam \
  "$BAM_DIR"/02262026_RPE_K9me2_8_cycles_S3.sorted.rmdup.bam \
  "$BAM_DIR"/02262026_RPE_H3K36me3_10_cycles_S8.sorted.rmdup.bam \
  "$BAM_DIR"/02262026_RPE_H3K36me3_8_cycles_S4.sorted.rmdup.bam; do
  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$BW_DIR_default/${base}_B${BIN_SIZE}_SML${SMOOTH_LEN}.bw"
  echo "Processing DEFAULT $bam -> $bw"

  bamCompare \
    -b1 "$bam" \
    -b2 "$BAM_DIR/02262026_RPE_HISTONE_INPUT_S10.sorted.rmdup.bam" \
    -o "$bw" \
    --numberOfProcessors "$SLURM_CPUS_PER_TASK" \
    --operation ratio \
    --smoothLength "$SMOOTH_LEN" \
    --binSize "$BIN_SIZE"
done



