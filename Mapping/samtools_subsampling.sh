#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=samtools_subsampling
#SBATCH --output=samtools_subsampling.log
#SBATCH --error=samtools_subsampling.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=15
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
module load samtools/1.17-gcc-13.1.0

# Constants
REF="/home/lauterw/refs/human_hg38_UCSC/hg38.fa"
DATADIR="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"


# Lists of samples
LIST_P53_SETD2i="$DATADIR/P53_SETD2i_WIAB_IDPE.txt"
LIST_P53_loss="$DATADIR/P53_loss_Ref_WIAB_IDPE.txt"

# Output directory
OUTDIR_SETD2i="/home/lauterw/WIAB_IDPE/results/bwa_output/P53_loss_SETD2i_subsampled"
OUTDIR_loss="/home/lauterw/WIAB_IDPE/results/bwa_output/P53_loss_subsampled"

# Subsample and process each sample in the list
COVERAGE="01 05 10 15 20 25 30"

# Create output directories if they don't exist
mkdir -p "$OUTDIR_SETD2i"
mkdir -p "$OUTDIR_loss"

# Temporary directory for Picard
export TMPDIR='/rs01/home/lauterw/tmp'

# Export variables for GNU Parallel
export REF DATADIR LIST_P53_SETD2i LIST_P53_loss OUTDIR_SETD2i OUTDIR_loss
export COVERAGE


# Process P53_SETD2i samples
parallel --tmpdir "$TMPDIR" --jobs 6 --halt soon,fail=10 '
    SAMPLE={}
    
    for i in $COVERAGE; do
        
        samtools view -s 42.$i \
        -b "$DATADIR/P53_SETD2i/${SAMPLE}.marked.bam" > "$OUTDIR_SETD2i/${SAMPLE}.subsampled_${i}.bam"
        
        samtools index "$OUTDIR_SETD2i/${SAMPLE}.subsampled_${i}.bam"
    
    done

    echo "Finished $SAMPLE"

' :::: "$LIST_P53_SETD2i"

# Process P53_loss samples
parallel --tmpdir "$TMPDIR" --jobs 6 --halt soon,fail=10 '
    SAMPLE={}
    
    for i in $COVERAGE; do
        
        samtools view -s 42.$i \
        -b "$DATADIR/P53_control/${SAMPLE}.marked.bam" > "$OUTDIR_loss/${SAMPLE}.subsampled_${i}.bam"
        samtools index "$OUTDIR_loss/${SAMPLE}.subsampled_${i}.bam"
    
    done

    echo "Finished $SAMPLE"

' :::: "$LIST_P53_loss"
