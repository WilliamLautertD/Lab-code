#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=deeptools_no_SF_with_dup
#SBATCH --output=deeptools_no_SF_with_dup.log
#SBATCH --error=deeptools_no_SF_with_dup.err
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=20
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load deepTools (adjust if using a module system)
#module load deepTools

# Directories
BAM_DIR="/home/lauterw/MapR_Madison/results/bwa_mapping_hg19/marked_duplicates"
BW_DIR="/home/lauterw/MapR_Madison/results/bw_no_SF_with_duplicates"
MATRIX_DIR="/home/lauterw/MapR_Madison/results/matrix_with_dup"
FIG_DIR="/home/lauterw/MapR_Madison/results/figures_with_dup"

mkdir -p $BW_DIR $MATRIX_DIR $FIG_DIR

# Parameters
BIN_SIZE=200


# 1️⃣ Convert BAM to BigWig
for bam in $BAM_DIR/*.marked.bam; do
    base=$(basename $bam .marked.bam)
    bw="$BW_DIR/${base}.bw"
    echo "Processing $bam → $bw"
    bamCoverage -b $bam \
                -o $bw \
                --binSize $BIN_SIZE \
                --normalizeUsing CPM \
                --extendReads \
		--smoothLength 600 \
                --numberOfProcessors $SLURM_CPUS_PER_TASK
done

# 2⃣ Create matrix for PCA
multiBigwigSummary bins \
    -b $BW_DIR/*.bw \
    -o $MATRIX_DIR/mnase.npz \
    --binSize $BIN_SIZE_MATRIX \
    --outRawCounts $MATRIX_DIR/mnase_counts.tab \
    --numberOfProcessors $SLURM_CPUS_PER_TASK

# 3️⃣ Generate PCA plot
# Extract sample names from BigWig filenames
labels=$(ls $BW_DIR/*.bw | xargs -n1 basename | sed 's/\.bw//g' | tr '\n' ' ')

# Optional: define colors (red for DN, blue for WT)
colors=$(ls $BW_DIR/*.bw | xargs -n1 basename | sed 's/\.bw//g' | sed 's/^DN.*/red/; s/^WT.*/blue/' | tr '\n' ' ')

plotPCA -in $MATRIX_DIR/mnase.npz \
        -o $FIG_DIR/mnase_PCA.png \
        --labels $labels \
        --plotHeight 6 \
        --plotWidth 6 \
        --colors $colors

echo "✅ PCA plot saved to $FIG_DIR/mnase_PCA.png"

