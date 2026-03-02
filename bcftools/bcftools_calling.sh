#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=bcftools_calling
#SBATCH --output=bcftools_calling.log
#SBATCH --error=bcftools_calling.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=15
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules available in the cluster environment
module load bcftools/1.16-gcc-13.1.0

# Directories 
BAMDIR="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"
OUTBASE="/home/lauterw/WIAB_IDPE/results/Variant_calling/"
REF="/home/lauterw/refs/human_hg38_UCSC/hg38.fa"

# List samples
LIST_P53_loss="$BAMDIR/P53_loss_Ref_WIAB_IDPE.txt"
LIST_P53_SETD2i="$BAMDIR/P53_SETD2i_WIAB_IDPE.txt"


# Export variables for GNU Parallel
export BAMDIR OUTBASE LIST_P53_loss LIST_P53_SETD2i REF

# Set temporary directory for GNU Parallel
export TMPDIR='/rs01/home/lauterw/tmp'

# Create output directory if it doesn't exist\
mkdir -p "$OUTBASE/P53_control"
mkdir -p "$OUTBASE/P53_SETD2i"

# Calculate coverage for each sample and coverage level in parallel
parallel --dry-run --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    
    SAMPLE={}
    
    BAM="$BAMDIR/P53_control/${SAMPLE}.marked.bam"

    echo "Variant calling with bcftools for $SAMPLE..."

    bcftools mpileup -O v -f "$REF" "$BAM" | bcftools call -vm -O v > "$OUTBASE/P53_control/${SAMPLE}.variants.vcf"

    echo "Finished $SAMPLE"

' :::: "$LIST_P53_loss"


# Calculate coverage for each sample and coverage level in parallel
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    
    SAMPLE={}
    
    BAM="$BAMDIR/P53_SETD2i/${SAMPLE}.marked.bam"

    echo "Variant calling with bcftools for $SAMPLE..."

    bcftools mpileup -O v -f "$REF" "$BAM" | bcftools call -vm -O v > "$OUTBASE/P53_SETD2i/${SAMPLE}.variants.vcf"


    echo "Finished $SAMPLE"

' :::: "$LIST_P53_SETD2i"
