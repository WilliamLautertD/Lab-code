#!/bin/bash
<<<<<<< Updated upstream
#SBATCH -p general
=======
#SBATCH -p general_long
>>>>>>> Stashed changes
#SBATCH --job-name=QC_and_trimming
#SBATCH --output=QC_and_trimming.log
#SBATCH --error=QC_and_trimming.err
#SBATCH --nodes=1
<<<<<<< Updated upstream
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=20
=======
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
export DATADIR LIST OUTDIR

# Running FASTQC on raw reads
parallel -j 5 --dry-run '
    echo fastqc "${DATADIR}/{}_L001_R1_001.fastq.gz" -o ${DATADIR}/qc/
    conda run -n qc_analysis fastqc \
        "${DATADIR}/{}_L001_R1_001.fastq.gz" \
        -o ${DATADIR}/qc/ -t 20
    
    echo fastqc "${DATADIR}/{}_L001_R2_001.fastq.gz" -o ${DATADIR}/qc/
    conda run -n qc_analysis fastqc \
        "${DATADIR}/{}_L001_R2_001.fastq.gz" \
        -o ${DATADIR}/qc/ -t 20
' :::: $LIST

# Running fastp for trimming
parallel -j 5 --dry-run '
=======
# export variables for parallel
export DATADIR LIST OUTDIR

# Export tmp directory for fastp
export TMPDIR="${SLURM_TMPDIR:-$HOME/tmp}"
mkdir -p "$TMPDIR"
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=$TMPDIR"


# Running FASTQC on raw reads
parallel --tmpdir "$TMPDIR" -j 5 '
    echo fastqc "${DATADIR}/{}_L001_R1_001.fastq.gz" -o ${OUTDIR}/qc/
    conda run -n qc_analysis fastqc \
        "${DATADIR}/{}_L001_R1_001.fastq.gz" \
        -o ${OUTDIR}/qc/ 
    
    echo fastqc "${DATADIR}/{}_L001_R2_001.fastq.gz" -o ${OUTDIR}/qc/
    conda run -n qc_analysis fastqc \
        "${DATADIR}/{}_L001_R2_001.fastq.gz" \
        -o ${OUTDIR}/qc/ 
' :::: $LIST

# Running fastp for trimming
parallel --tmpdir "$TMPDIR" -j 3 '
>>>>>>> Stashed changes
    conda run -n qc_analysis fastp \
    --in1 "${DATADIR}/{}_L001_R1_001.fastq.gz" \
    --in2 "${DATADIR}/{}_L001_R2_001.fastq.gz" \
    --out1 "${OUTDIR}/{}_trimmed_R1.fastq.gz" \
    --out2 "${OUTDIR}/{}_trimmed_R2.fastq.gz" \
    --thread 20
' :::: $LIST

# QC report for trimmed reads
# FastQC
<<<<<<< Updated upstream
echo conda run -n qc_analysis fastqc $OUTDIR/* -o $OUTDIR/qc/ -t 20

# MultiQC
echo conda run -n qc_analysis multiqc $OUTDIR/qc/fastqc/ \
    --outdir $OUTDIR/qc/multiqc \
    --title "MultiQC Report"
=======
conda run -n qc_analysis fastqc $OUTDIR/*_trimmed_R*.fastq.gz -o $OUTDIR/qc/ -t 5

# MultiQC
conda run -n qc_analysis multiqc $OUTDIR/qc/ \
    --outdir $OUTDIR/qc/multiqc \
    --title "MultiQC Report"

>>>>>>> Stashed changes
