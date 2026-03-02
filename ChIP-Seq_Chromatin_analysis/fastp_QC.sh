#!/bin/bash
#SBATCH -p general
#SBATCH --job-name=QC_and_trimming
#SBATCH --output=QC_and_trimming.log
#SBATCH --error=QC_and_trimming.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=20
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules (if needed)
# module load fastp
# module load FastQC
# module load MultiQC

# Define constants
DATADIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/02_26_2026_RPE_Takara_ChIP_Seq_Test_3/data"
LIST="${DATADIR}/filenames.txt"

OUTDIR="${DATADIR}/trimmed"

# Make output directory if it doesn't exist
mkdir -p $OUTDIR
mkdir -p $OUTDIR/qc

export DATADIR LIST OUTDIR

# Running FASTQC on raw reads
parallel -j 5 --dry-run '
    echo fastqc "${DATADIR}/{}_L001_R1_001.fastq.gz" -o ${DATADIR}/qc/
    conda run qc_analysis fastqc \
        "${DATADIR}/{}_L001_R1_001.fastq.gz" \
        -o ${DATADIR}/qc/ -t 20
    
    echo fastqc "${DATADIR}/{}_L001_R2_001.fastq.gz" -o ${DATADIR}/qc/
    conda run qc_analysis fastqc \
        "${DATADIR}/{}_L001_R2_001.fastq.gz" \
        -o ${DATADIR}/qc/ -t 20
' :::: $LIST

# Running fastp for trimming
parallel -j 5 --dry-run '
    conda run qc_analysis fastp \
    --in1 "${DATADIR}/{}_L001_R1_001.fastq.gz" \
    --in2 "${DATADIR}/{}_L001_R2_001.fastq.gz" \
    --out1 "${OUTDIR}/{}_trimmed_R1.fastq.gz" \
    --out2 "${OUTDIR}/{}_trimmed_R2.fastq.gz" \
    --thread 20
' :::: $LIST

# QC report for trimmed reads
# FastQC
echo conda run qc_analysis fastqc $OUTDIR/* -o $OUTDIR/qc/ -t 20

# MultiQC
echo conda run qc_analysis multiqc $OUTDIR/qc/fastqc/ \
    --outdir $OUTDIR/qc/multiqc \
    --title "MultiQC Report"
