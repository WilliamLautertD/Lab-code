#!/bin/bash
#SBATCH -p general
#SBATCH --job-name=trimming_WIAB_IDPE
#SBATCH --output=trimming_WIAB_IDPE_output.log
#SBATCH --error=trimming_WIAB_IDPE_output.err
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
REF="/home/lauterw/refs/human_GRCh38_p14/GRCh38.p14_genomic.fna"
DATADIR="/home/lauterw/WIAB_IDPE/data"
LIST="${DATADIR}/basenames.txt"

OUTDIR="/home/lauterw/WIAB_IDPE/QC_analysis/trimmed"

export REF DATADIR LIST OUTDIR

# Running fastp
parallel -j 5 '
    echo fastp --in1 "${DATADIR}/{}_R1.fastq.gz" --in2 "${DATADIR}/{}_R2.fastq.gz" \
    --out1 "${OUTDIR}/{}_trimmed_R1.fastq.gz" \
    --out2 "${OUTDIR}/{}_trimmed_R2.fastq.gz" \
    
    --thread 20
' :::: $LIST

# QC report for trimmed reads
# FastQC
echo fastqc $OUTDIR/* -o $OUTDIR/

# MultiQC
echo multiqc $OUTDIR/ --outdir $OUTDIR/multiqc