#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=GATK_model_call_CNV
#SBATCH --output=GATK_model_call_CNV.log
#SBATCH --error=GATK_model_call_CNV.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=20
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
module purge
module load openjdk/17.0.8.1_1-gcc-13.1.0
module load gatk/4.4.0.0-gcc-13.1.0

# Directories
DIR="/home/lauterw/WIAB_IDPE/results/GATK_CNV"
BAM="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"
DENOISED_dir="$DIR/denoised"

SEG_dir="$DIR/segments"

#tmp dir
TMPDIR='/rs01/home/lauterw/tmp'

# export variables
export DIR BAM COUNTS_RPE COUNTS_P53 PON_dir DENOISED_dir SEG_dir TMPDIR

# Ensure output directory exists
mkdir -p "$SEG_dir"
mkdir -p "$SEG_dir/RPE_SETD2i" "$SEG_dir/P53_SETD2i"
mkdir -p "$SEG_dir/RPE_SETD2i_teste_default" "$SEG_dir/P53_SETD2i_teste_default"

# Run ModelSegments and CallCopyRatioSegments - RPE SETD2i
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    gatk ModelSegments \
        --denoised-copy-ratios "$DENOISED_dir/RPE/{}.denoisedCR.tsv" \
        --output "$SEG_dir/RPE_SETD2i" \
        --output-prefix {} \
        --number-of-changepoints-penalty-factor 2.0 &&

    gatk CallCopyRatioSegments \
        -I "$SEG_dir/RPE_SETD2i/{}.cr.seg" \
        -O "$SEG_dir/RPE_SETD2i/{}.called.seg"
' :::: "$BAM/RPE_SETD2i_WIAB_IDPE.txt"

# Run ModelSegments and CallCopyRatioSegments - P53 SETD2i
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    gatk ModelSegments \
        --denoised-copy-ratios "$DENOISED_dir/P53/{}.denoisedCR.tsv" \
        --output "$SEG_dir/P53_SETD2i" \
        --output-prefix {} \
        --number-of-changepoints-penalty-factor 2.0 &&

    gatk CallCopyRatioSegments \
        -I "$SEG_dir/P53_SETD2i/{}.cr.seg" \
        -O "$SEG_dir/P53_SETD2i/{}.called.seg"
' :::: "$BAM/P53_SETD2i_WIAB_IDPE.txt"




# ──────────────────────────────────────────────
# RPE SETD2i teste default samples
# ──────────────────────────────────────────────
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    gatk ModelSegments \
        --denoised-copy-ratios "$DENOISED_dir/RPE/{}.denoisedCR.tsv" \
        --output "$SEG_dir/RPE_SETD2i_teste_default" \
        --output-prefix {} &&

    gatk CallCopyRatioSegments \
        -I "$SEG_dir/RPE_SETD2i_teste_default/{}.cr.seg" \
        -O "$SEG_dir/RPE_SETD2i_teste_default/{}.called.seg"
' :::: "$BAM/RPE_SETD2i_WIAB_IDPE.txt"

# ──────────────────────────────────────────────
# P53 SETD2i teste default samples
# ──────────────────────────────────────────────
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    gatk ModelSegments \
        --denoised-copy-ratios "$DENOISED_dir/P53/{}.denoisedCR.tsv" \
        --output "$SEG_dir/P53_SETD2i_teste_default" \
        --output-prefix {} &&

    gatk CallCopyRatioSegments \
        --I "$SEG_dir/P53_SETD2i_teste_default/{}.cr.seg" \
        -O "$SEG_dir/P53_SETD2i_teste_default/{}.called.seg"
' :::: "$BAM/P53_SETD2i_WIAB_IDPE.txt"