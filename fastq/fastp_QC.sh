#!/bin/bash
#SBATCH -p general
#SBATCH --job-name=trimming_fastp
#SBATCH --output=trimming_fastp_output.log
#SBATCH --error=trimming_fastp_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=10
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules (if needed)
# module load fastp
# module load FastQC
# module load MultiQC

# Define constants
DATADIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection"
LIST="${DATADIR}/filenames.txt"

OUTDIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_12_2026_Takara_Test_with_size_selection/data/trimmed"

export DATADIR LIST OUTDIR

mkdir -p $OUTDIR


# QC report for raw reads
# FastQC
fastqc $DATADIR/* -t 10 -o $OUTDIR/
multiqc $DATADIR --outdir $OUTDIR -n MultiQC_raw_reads

# Running fastp
parallel --dry-run -j 10 '
    fastp --in1 "${DATADIR}/{}_L001_R1_001.fastq.gz" --in2 "${DATADIR}/{}_L001_R2_001.fastq.gz" \
    --out1 "${OUTDIR}/{}_trimmed_R1.fastq.gz" \
    --out2 "${OUTDIR}/{}_trimmed_R2.fastq.gz" \
    --thread 10
' :::: $LIST

# QC report for trimmed reads
# FastQC
#fastqc $OUTDIR/* -t 10 -o $OUTDIR/

# MultiQC
#multiqc $DATADIR --outdir $OUTDIR -n MultiQC_trimmed
