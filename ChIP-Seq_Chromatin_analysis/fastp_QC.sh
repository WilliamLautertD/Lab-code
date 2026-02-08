# Define constants
DATADIR="/Users/williamlautert/Desktop/Whetstine_Lab/MapR"
LIST="${DATADIR}/data/basenames.txt"

OUTDIR_trimmed="${DATADIR}/data/trimmed"
OUTDIR_qc="${DATADIR}/results/"

export REF DATADIR LIST OUTDIR_trimmed OUTDIR_qc

# Running fastp
parallel -j 1 '
    fastp --in1 "${DATADIR}/data/{}_R1_001.fastq.gz" --in2 "${DATADIR}/data/{}_R2_001.fastq.gz" \
    --out1 "${OUTDIR_trimmed}/{}_trimmed_R1.fastq.gz" \
    --out2 "${OUTDIR_trimmed}/{}_trimmed_R2.fastq.gz" \
    --thread 8
' :::: $LIST

# QC report for trimmed reads
# FastQC
fastqc $OUTDIR_trimmed/* -o $OUTDIR_qc/fastqc/

# MultiQC
multiqc $OUTDIR_qc/fastqc/ --outdir $OUTDIR_qc/multiqc \
    --title "MultiQC Report - Trimmed Reads"