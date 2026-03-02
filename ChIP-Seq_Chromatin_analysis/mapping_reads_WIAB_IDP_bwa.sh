#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=mapping_bwa
#SBATCH --output=mapping_bwa_output.log
#SBATCH --error=mapping_bwa_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=20
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules (if needed)
# module load bwa
# module load samtools

# Define constants
REF="/home/lauterw/refs/human_GRCh38_p14/GRCh38.p14_genomic.fna"
DATADIR="/home/lauterw/WIAB_IDPE/data/trimmed_reads"
LIST="/home/lauterw/WIAB_IDPE/data/basenames.txt"

OUTDIR="/home/lauterw/WIAB_IDPE/results/bwa_output"

mkdir -p "$OUTDIR"

export REF DATADIR LIST OUTDIR

parallel -j 6 --halt soon,fail=10 '
    WIAB_IDPE={}
    
    R1="'$DATADIR'/${WIAB_IDPE}_trimmed_R1.fastq.gz"
    R2="'$DATADIR'/${WIAB_IDPE}_trimmed_R2.fastq.gz"
    
    BAM="'$OUTDIR'/${WIAB_IDPE}.sorted.bam"

    echo "Processing $WIAB_IDPE..."

    bwa mem -t 20 "'$REF'" "$R1" "$R2" | \
        samtools view -bS - | \
        samtools sort -o "$BAM"

    samtools index "$BAM"

    samtools flagstats --threads 20 -O tsv "$BAM"

    echo "Finished $WIAB_IDPE"

' :::: "$LIST"
