#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=GATK_denoise
#SBATCH --output=GATK_denoise.log
#SBATCH --error=GATK_denoise.err
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
DIR="/home/lauterw/WIAB_IDPE/results/GATK_CNV/"
BAM="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"
COUNTS_RPE="$DIR/counts/treated/RPE"
COUNTS_P53="$DIR/counts/treated/P53_merged"
PON_dir="$DIR/pon"
DENOISED_dir="$DIR/denoised"

#tmp dir
TMPDIR='/rs01/home/lauterw/tmp'

# export variables
export DIR BAM COUNTS_RPE COUNTS_P53 PON_dir DENOISED_dir TMPDIR

# Ensure output directory exists
mkdir -p "$DENOISED_dir"
mkdir -p "$DENOISED_dir/RPE"
mkdir -p "$DENOISED_dir/P53"

# Running DenoiseReadCounts
## RPE SETD2i
parallel --dry-run --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    
    gatk DenoiseReadCounts \
        -I "$COUNTS_RPE/{}.counts.hdf5" \
        --count-panel-of-normals "$PON_dir/RPE/pon_RPE.hdf5" \
        --standardized-copy-ratios "$DENOISED_dir/RPE/{}.standardizedCR.tsv" \
        --denoised-copy-ratios "$DENOISED_dir/RPE/{}.denoisedCR.tsv"

' :::: "$BAM/RPE_SETD2i_WIAB_IDPE.txt"

## P53 SETD2i
parallel --dry-run --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    
    gatk DenoiseReadCounts \
        -I "$COUNTS_P53/{}.counts.hdf5" \
        --count-panel-of-normals "$PON_dir/P53/pon_P53.hdf5" \
        --standardized-copy-ratios "$DENOISED_dir/P53_merged/{}.standardizedCR.tsv" \
        --denoised-copy-ratios "$DENOISED_dir/P53_merged/{}.denoisedCR.tsv"

' :::: "$BAM/P53_SETD2i_WIAB_IDPE.txt"


gatk DenoiseReadCounts \
	-I "$COUNTS_P53/WIAB_IDPE_P53_merged.counts.hdf5" \
        --count-panel-of-normals "$PON_dir/P53/pon_P53.hdf5" \
        --standardized-copy-ratios "$DENOISED_dir/P53_merged/WIAB_IDPE_P53_merged.standardizedCR.tsv" \
        --denoised-copy-ratios "$DENOISED_dir/P53_merged/WIAB_IDPE_P53_merged.denoisedCR.tsv"

