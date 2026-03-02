#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=mark_dups_picard
#SBATCH --output=mark_dups_picard_output.log
#SBATCH --error=mark_dups_picard_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=20
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
module load samtools
module load picard  # make sure Picard 3+ is available

# Directories
OUTDIR="/home/lauterw/WIAB_IDPE/results/bwa_output"  # your sorted BAMs
LIST="/home/lauterw/WIAB_IDPE/data/basenames.txt"

mkdir -p "$OUTDIR/marked_duplicates"
mkdir -p "$OUTDIR/rg_added"

export OUTDIR LIST

parallel --jobs 6 --halt soon,fail=10 '
    WIAB_IDPE={}

    BAM="$OUTDIR/${WIAB_IDPE}.sorted.bam"
    BAM_RG="$OUTDIR/rg_added/${WIAB_IDPE}.rg.bam"
    BAM_MARKED="$OUTDIR/marked_duplicates/${WIAB_IDPE}.marked.bam"
    METRICS="$OUTDIR/marked_duplicates/${WIAB_IDPE}.marked_dup_metrics.txt"

    echo "Adding read groups for $WIAB_IDPE..."
    picard AddOrReplaceReadGroups \
        I="$BAM" \
        O="$BAM_RG" \
        RGID="$WIAB_IDPE" \
        RGLB="lib1" \
        RGPL="ILLUMINA" \
        RGPU="unit1" \
        RGSM="$WIAB_IDPE" \
        CREATE_INDEX=true

    echo "Marking duplicates for $WIAB_IDPE..."
    picard MarkDuplicates \
        I="$BAM_RG" \
        O="$BAM_MARKED" \
        M="$METRICS" \
        CREATE_INDEX=true

    samtools flagstat -@ 20 "$BAM_MARKED" > "${BAM_MARKED%.bam}.flagstats.tsv"

    echo "Finished $WIAB_IDPE"

' :::: "$LIST"

