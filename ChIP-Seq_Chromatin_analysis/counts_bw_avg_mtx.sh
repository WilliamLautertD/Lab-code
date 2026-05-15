#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=count_matrix_bw
#SBATCH --output=count_matrix_bw.log
#SBATCH --error=count_matrix_bw.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load necessary modules

# Define variables
WORK_DIR="/home/lauterw/KDM4C_OE"
BAM_DIR="$WORK_DIR/processed_files/normalized_hg19_bam"
THREADS=30

# need overlaped peak between replicates
BED_FILE="$WORK_DIR/processed_files/peaks_spike/seacr_top0.05_stringent_avg_deeptools/3_27_26_KDM4C_OE_H3K4me3_avg.bedGraph_seacr_top0.05_avg_deeptools.stringent.bed"

# Create output directory for bigWig files
BW_DIR="$WORK_DIR/processed_files/bigwig_spike"

# Create bigwig directory if it doesn't exist
mkdir -p "$BW_DIR"

# Generate the npz files using multiBigwigSummary
conda run -n deeptools multiBigwigSummary BED-file \
	-b "$BW_DIR"/3_27_26_EV_H3K4me3_avg.bw "$BW_DIR"/3_27_26_KDM4C_OE_H3K4me3_avg.bw \
    	-o "$BW_DIR/KDM4C_OE_H3K4me3_and_EV_H3K4me3.npz" \
    	--BED "$BED_FILE" \
	--outRawCounts "$BW_DIR/KDM4C_OE_H3K4me3_and_EV_H3K4me3.tab"


echo "npz files generated successfully."
echo "Raw counts saved to 3_27_26_KDM4C_OE_H3K4me3_and_EV_H3K4me3.tab"
