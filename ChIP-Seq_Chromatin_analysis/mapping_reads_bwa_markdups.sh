#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=bwa_mapping_markdups
#SBATCH --output=bwa_markdups_output.log
#SBATCH --error=bwa_markdups_error.err
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=21
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
module load bwa
module load samtools

# Constants
REF="/home/lauterw/refs/human_hg38_UCSC/hg38.fa"
DATADIR="/home/lauterw/WIAB_IDPE/data/trimmed_reads"
LIST="/home/lauterw/WIAB_IDPE/data/basenames.txt"
OUTDIR="/home/lauterw/WIAB_IDPE/results/bwa_output"

mkdir -p "$OUTDIR"
mkdir -p "$OUTDIR/marked_duplicates"
mkdir -p "$OUTDIR/rg_added"

export TMPDIR='/rs01/home/lauterw/tmp'

export REF DATADIR LIST OUTDIR 

parallel --tmpdir "$TMPDIR" --jobs 6 --halt soon,fail=10 '
    SAMPLE={}

    R1="$DATADIR/${SAMPLE}_trimmed_R1.fastq.gz"
    R2="$DATADIR/${SAMPLE}_trimmed_R2.fastq.gz"

    BAM="$OUTDIR/${SAMPLE}.sorted.bam"
    BAM_RG="$OUTDIR/rg_added/${SAMPLE}.rg.bam"
    BAM_MARKED="$OUTDIR/marked_duplicates/${SAMPLE}.marked.bam"
    METRICS="$OUTDIR/marked_duplicates/${SAMPLE}.marked_dup_metrics.txt"

    echo "Mapping and sorting $SAMPLE..."
    bwa mem -t 21 "$REF" "$R1" "$R2" | \
        samtools view -bS - | \
        samtools sort -@ 21 -o "$BAM"

    samtools index "$BAM"

    echo "Adding read groups for $SAMPLE..."
    picard -Djava.io.tmpdir="$TMPDIR" AddOrReplaceReadGroups \
        I="$BAM" \
        O="$BAM_RG" \
        RGID="$SAMPLE" \
        RGLB="lib1" \
        RGPL="ILLUMINA" \
        RGPU="unit1" \
        RGSM="$SAMPLE" \
        CREATE_INDEX=true

    # Remove the intermediate sorted BAM without RG (and its index)
    rm -f "$BAM" "$BAM.bai"

    echo "Marking duplicates for $SAMPLE..."
    picard -Djava.io.tmpdir="$TMPDIR" MarkDuplicates \
        I="$BAM_RG" \
        O="$BAM_MARKED" \
        M="$METRICS" \
        CREATE_INDEX=true

    # Remove BAM with only RG but no marked duplicates (and its index)
    rm -f "$BAM_RG" "$BAM_RG.bai"

    samtools flagstat -@ 20 "$BAM_MARKED" > "${BAM_MARKED%.bam}.flagstats.tsv"

    echo "Finished $SAMPLE"

' :::: "$LIST"
