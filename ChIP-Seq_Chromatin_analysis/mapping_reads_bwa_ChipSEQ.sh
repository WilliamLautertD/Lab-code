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
module load bwa/0.7.17-gcc-13.1.0
module load samtools/1.17-gcc-13.1.0

# Define constants
REF="/home/lauterw/refs/human_hg19_igenome/hg19.fa"
DATADIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/data/trimmed"
LIST="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/filenames.txt"

OUTDIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/results/bwa_mapping_hg19"

mkdir -p "$OUTDIR"
mkdir -p "$OUTDIR/rmdupl_duplicates"

# Set temporary directory for GNU Parallel
TMPDIR='/rs01/home/lauterw/tmp'
mkdir -p "$TMPDIR"
export TMPDIR

export REF DATADIR LIST OUTDIR

parallel -j 2 --halt soon,fail=10 '
    READS={}
    
    R1="'$DATADIR'/${READS}_trimmed_R1.fastq.gz"
    R2="'$DATADIR'/${READS}_trimmed_R2.fastq.gz"
    
    OUTBAM="'$OUTDIR/rmdupl_duplicates'/${READS}.sorted.rmdup.bam"

    TMPPFX="${TMPDIR}/${READS}.{#}"

    echo "Processing $READS..."

    bwa mem -t 20 "'$REF'" "$R1" "$R2" | \
        samtools collate -@ 4 -O -u - | \
        samtools fixmate -@ 4 -m -u - - | \
        samtools sort -@ 5 -T "${TMPPFX}.sort" -u - | \
        samtools markdup -@ 4 - - | \
        samtools view -@ 5 -b -q 30 -F 4 -F 256 -F 2048 -F 1024 - | \
        samtools sort -@ 5 -T "${TMPPFX}.finalsort" -o "${OUTBAM}" - 

    samtools index "$OUTBAM"

    samtools flagstat -@ 5 -O tsv "$OUTBAM" > "${OUTBAM%.bam}.flagstats.tsv"

    echo "Finished $READS"

' :::: "$LIST"


