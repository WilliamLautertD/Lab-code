#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=bcftools_annotation
#SBATCH --output=bcftools_annotation.log
#SBATCH --error=bcftools_annotation.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
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
LIST_RPE_control="$BAMDIR/RPE_Ref_WIAB_IDPE.txt"
LIST_RPE_SETD2i="$BAMDIR/RPE_SETD2i_WIAB_IDPE.txt"


# Export variables for GNU Parallel
export BAMDIR OUTBASE LIST_RPE_control LIST_RPE_SETD2i REF

# Set temporary directory for GNU Parallel
export TMPDIR='/rs01/home/lauterw/tmp'

# Create output directory if it doesn't exist\
mkdir -p "$OUTBASE/RPE_control"
mkdir -p "$OUTBASE/RPE_SETD2i"

# If you have plain .vcf files:
for f in "$OUTBASE/RPE_control"/*.vcf; do
  bgzip -c "$f" > "$f.gz"
  tabix -p vcf "$f.gz"
done
ls /home/lauterw/WIAB_IDPE/results/Variant_calling/RPE_control/*.vcf.gz \
| while read f; do
    bcftools view -h "$f" >/dev/null 2>&1 && echo "$f"
  done > "$OUTBASE/RPE_control/control.ok.list"

# If you have plain .vcf files:
for f in "$OUTBASE/RPE_SETD2i"/*.vcf; do
  bgzip -c "$f" > "$f.gz"
  tabix -p vcf "$f.gz"
done
ls /home/lauterw/WIAB_IDPE/results/Variant_calling/RPE_SETD2i/*.vcf.gz \
| while read f; do
    bcftools view -h "$f" >/dev/null 2>&1 && echo "$f"
  done > "$OUTBASE/RPE_SETD2i/SETD2i.ok.list"


# Merge control gzipped VCFs into a single cohort VCF
bcftools merge \
  -m all \
  -Oz -o "$OUTBASE/RPE_control/merged_RPE_control.cohort.vcf.gz" -l "$OUTBASE/RPE_control/control.ok.list"

tabix -p vcf "$OUTBASE/RPE_control/merged_RPE_control.cohort.vcf.gz"

bcftools merge \
  -m all \
  -Oz -o "$OUTBASE/RPE_SETD2i/merged_RPE_SETD2i.cohort.vcf.gz" -l "$OUTBASE/RPE_SETD2i/SETD2i.ok.list"

tabix -p vcf "$OUTBASE/RPE_SETD2i/merged_RPE_SETD2i.cohort.vcf.gz"

