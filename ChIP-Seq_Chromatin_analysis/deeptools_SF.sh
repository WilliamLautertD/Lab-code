#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=deeptools_SF
#SBATCH --output=deeptools_SF.log
#SBATCH --error=deeptools_SF.err
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=20
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load deepTools (adjust if using a module system)
#module load deepTools

# Directories
BAM_DIR="/home/lauterw/MapR_Madison/results/experiment_1/bwa_mapping/marked_duplicates"
BW_DIR="/home/lauterw/MapR_Madison/results/experiment_1/bw_SF"
MATRIX_DIR="/home/lauterw/MapR_Madison/results/experiment_1/matrix_SF"
FIG_DIR="/home/lauterw/MapR_Madison/results/experiment_1/figures_SF"

mkdir -p $BW_DIR $MATRIX_DIR $FIG_DIR

# Parameters
BIN_SIZE=200

export $BIN_SIZE

# 1️⃣ Convert BAM to BigWig


# DN1_MNASE
bamCoverage -b $BAM_DIR/DN1_MNASE_S4_L001.marked.bam \
            -o $BW_DIR/DN1_MNASE.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 0.36 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# DN1_RH
bamCoverage -b $BAM_DIR/DN1_RH_S3_L001.marked.bam \
            -o $BW_DIR/DN1_RH.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 14.99 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# DN2_MNASE
bamCoverage -b $BAM_DIR/DN2_MNASE_S6_L001.marked.bam \
            -o $BW_DIR/DN2_MNASE.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 0.51 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# DN2_RH
bamCoverage -b $BAM_DIR/DN2_RH_S8_L001.marked.bam \
            -o $BW_DIR/DN2_RH.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 14.99 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# WT1_MNASE
bamCoverage -b $BAM_DIR/WT1_MNASE_S2_L001.marked.bam \
            -o $BW_DIR/WT1_MNASE.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 1.81 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# WT1_RH
bamCoverage -b $BAM_DIR/WT1_RH_S1_L001.marked.bam \
            -o $BW_DIR/WT1_RH.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 14.99 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# WT2_MNASE
bamCoverage -b $BAM_DIR/WT2_MNASE_S5_L001.marked.bam \
            -o $BW_DIR/WT2_MNASE.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 2.48 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK

# WT2_RH
bamCoverage -b $BAM_DIR/WT2_RH_S7_L001.marked.bam \
            -o $BW_DIR/WT2_RH.bw \
            --binSize $BIN_SIZE \
            --normalizeUsing CPM \
            --extendReads \
            #--ignoreDuplicates \
            --smoothLength 600 \
            --scaleFactor 14.99 \
            --numberOfProcessors $SLURM_CPUS_PER_TASK





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

