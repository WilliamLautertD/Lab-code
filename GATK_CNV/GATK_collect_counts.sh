#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=GATK_collect_counts
#SBATCH --output=GATK_collect_counts.log
#SBATCH --error=GATK_collect_counts.err
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
REF_gen="/home/lauterw/refs/human_hg38_UCSC"

COUNTS_dir="$DIR/counts"

#tmp dir
TMPDIR='/rs01/home/lauterw/tmp'

# export variables
export DIR BAM REF_gen COUNTS_dir TMPDIR

# Ensure output directory exists
mkdir -p "$TARGETS_dir"

# Running CollectReadCounts
## RPE Normal
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '

    #WIAB_IDPE={}

    gatk CollectReadCounts \
        -I "$BAM/RPE_control/{}.marked.bam" \
        -L "$DIR/targets/preprocessed_intervals.interval_list" \
        -R "$REF_gen/hg38.fa" \
        --interval-merging-rule OVERLAPPING_ONLY \
        --format HDF5 \
        -O "$COUNTS_dir/normal/RPE/{}.counts.hdf5"

' :::: "$BAM/RPE_Ref_WIAB_IDPE.txt"

## RPE SETD2i
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '

    #WIAB_IDPE={}

    gatk CollectReadCounts \
        -I "$BAM/RPE_SETD2i/{}.marked.bam" \
        -L "$DIR/targets/preprocessed_intervals.interval_list" \
        -R "$REF_gen/hg38.fa" \
        --interval-merging-rule OVERLAPPING_ONLY \
        --format HDF5 \
        -O "$COUNTS_dir/treated/RPE/{}.counts.hdf5"

' :::: "$BAM/RPE_SETD2i_WIAB_IDPE.txt"


## P53 Normal
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '

    #WIAB_IDPE={}

    gatk CollectReadCounts \
        -I "$BAM/P53_control/{}.marked.bam" \
        -L "$DIR/targets/preprocessed_intervals.interval_list" \
        -R "$REF_gen/hg38.fa" \
        --interval-merging-rule OVERLAPPING_ONLY \
        --format HDF5 \
        -O "$COUNTS_dir/normal/P53/{}.counts.hdf5"

' :::: "$BAM/P53_loss_Ref_WIAB_IDPE.txt"


## P53 SETD2i
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '

    #WIAB_IDPE={}

    gatk CollectReadCounts \
        -I "$BAM/P53_SETD2i/{}.marked.bam" \
        -L "$DIR/targets/preprocessed_intervals.interval_list" \
        -R "$REF_gen/hg38.fa" \
        --interval-merging-rule OVERLAPPING_ONLY \
        --format HDF5 \
        -O "$COUNTS_dir/treated/P53/{}.counts.hdf5"

' :::: "$BAM/P53_SETD2i_WIAB_IDPE.txt"

