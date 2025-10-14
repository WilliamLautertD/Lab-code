#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=deeptools_denoise
#SBATCH --output=deeptools_denoise.log
#SBATCH --error=deeptools_denoise.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=20
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# -----------------------------------
# Load modules
# load conda environment with deeptools installed
# -----------------------------------

# -----------------------------------
# Directories
# -----------------------------------
DIR="/home/lauterw/WIAB_IDPE/results/deeptools_analysis"
BAM_P53_SETD2i="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates/P53_SETD2i"
BAM_RPE_SETD2i="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates/RPE_SETD2i"
BAM_P53_CONTROL="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates/P53_control"
BAM_RPE_CONTROL="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates/RPE_control"


# -----------------------------------
#tmp dir
# -----------------------------------
TMPDIR='/rs01/home/lauterw/tmp'

# -----------------------------------
# export variables
# -----------------------------------
export DIR BAM TMPDIR

# -----------------------------------
# Ensure output directory exists
# -----------------------------------
mkdir -p "$DIR/"

# -----------------------------------
# Running multiBamSummary
# -----------------------------------
multiBamSummary bins \
 --bamfiles "$BAM_P53_SETD2i"/*bam "$BAM_RPE_SETD2i"/*bam "$BAM_P53_CONTROL"/*bam "$BAM_RPE_CONTROL"/*bam \
 --minMappingQuality 30 \
 --outFileName "$DIR/readCounts.npz" \
 --numberOfProcessors max

# -----------------------------------
# Plotting results
# -----------------------------------
# Plotting heatmap
plotCorrelation \
    -in "$DIR/readCounts.npz" \
    --corMethod spearman --skipZeros \
    --plotTitle "Spearman Correlation of Read Counts" \
    --whatToPlot heatmap --colorMap RdYlBu --plotNumbers \
    -o "$DIR/heatmap_SpearmanCorr_readCounts.png"   \
    --outFileCorMatrix "$DIR/SpearmanCorr_readCounts.tab"

# Plotting PCA
plotPCA -in "$DIR/readCounts.npz" \
    -o "$DIR/PCA_readCounts.png" \
    -T "PCA of read counts"