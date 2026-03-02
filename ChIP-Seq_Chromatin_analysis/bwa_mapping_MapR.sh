#!/bin/bash
#SBATCH -p general
#SBATCH --job-name=mapping_bwa
#SBATCH --output=mapping_bwa_output.log
#SBATCH --error=mapping_bwa_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=100
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules (if needed)
# module load bwa
# module load samtools

module load picard/3.1.1-gcc-13.1.0

# Define constants
REF="/home/lauterw/refs/human_hg19_igenome/hg19.fa"
DATADIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection/data/trimmed"
LIST="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection/filenames.txt"

OUTDIR="${DATADIR}/bwa_mapping_hg19"

mkdir -p "$OUTDIR"

export REF DATADIR LIST OUTDIR

parallel -j 5 --halt soon,fail=10 '
    READS={}
    
    R1="'$DATADIR'/${READS}_trimmed_R1.fastq.gz"
    R2="'$DATADIR'/${READS}_trimmed_R2.fastq.gz"
    
    BAM="'$OUTDIR'/${READS}.sorted.bam"

    echo "Processing $READS..."

    bwa mem -t 20 "'$REF'" "$R1" "$R2" | \
        samtools view -b -q 30 -F 4 -F 256 -F 2048 - | \
        samtools sort -@ 4 -o "$BAM" -T $TMPDIR/${READS}_{#}_sort

    samtools index "$BAM"

    samtools flagstats --threads 20 -O tsv "$BAM" > "${BAM%.BAM}.flagstats.tsv"

    echo "Finished $READS"
    

' :::: "$LIST"


mkdir -p "$OUTDIR/marked_duplicates"
mkdir -p "$OUTDIR/rg_added"

export OUTDIR LIST

parallel -j 6 --halt soon,fail=10 '
    READS={}

    BAM="$OUTDIR/${READS}.sorted.bam"
    BAM_RG="$OUTDIR/rg_added/${READS}.rg.bam"
    BAM_MARKED="$OUTDIR/marked_duplicates/${READS}.marked.bam"
    METRICS="$OUTDIR/marked_duplicates/${READS}.marked_dup_metrics.txt"

    echo "Adding read groups for $READS..."
    picard AddOrReplaceReadGroups \
        I="$BAM" \
        O="$BAM_RG" \
        RGID="$READS" \
        RGLB="lib1" \
        RGPL="ILLUMINA" \
        RGPU="unit1" \
        RGSM="$READS" \
        CREATE_INDEX=true

    echo "Marking duplicates for $READS..."
    picard MarkDuplicates \
        I="$BAM_RG" \
        O="$BAM_MARKED" \
        M="$METRICS" \
        CREATE_INDEX=true

    samtools flagstat -@ 20 "$BAM_MARKED" > "${BAM_MARKED%.bam}.flagstats.tsv"

    echo "Finished $READS"

' :::: "$LIST"
