#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=GATK_process_intervals
#SBATCH --output=GATK_process_intervals.log
#SBATCH --error=GATK_process_intervals.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
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
REF_gen="/home/lauterw/refs/human_hg38_UCSC"
TARGETS_dir="$DIR/targets"

# Illumina exome targets
TARGETS_illumina="/home/lauterw/WIAB_IDPE/data/Illumina_Exome_TargetedRegions_v1.2.hg38.bed"

#tmp dir
TMPDIR='/rs01/home/lauterw/tmp'

# export variables
export DIR REF_gen TARGETS_dir TARGETS_illumina TMPDIR

# Ensure output directory exists
mkdir -p "$TARGETS_dir"

# Run PreprocessIntervals
gatk PreprocessIntervals \
    -R "$REF_gen/hg38.fa" \
    --interval-merging-rule OVERLAPPING_ONLY \
    -L "$TARGETS_illumina" \
    -O "$TARGETS_dir/preprocessed_intervals.interval_list"


gatk AnnotateIntervals \
  -R "$REF_gen/hg38.fa" \
  --interval-merging-rule OVERLAPPING_ONLY \
  -L "$TARGETS_dir/preprocessed_intervals.interval_list" \
  -O "$TARGETS_dir/annotated_intervals.tsv"
