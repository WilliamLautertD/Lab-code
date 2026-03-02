
#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=mapping_GSE175750_bwa
#SBATCH --output=mapping_GSE175750_bwa_output.log
#SBATCH --error=mapping_GSE175750_bwa_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=10
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules if needed
# module load bwa
# module load samtools
# module load deeptools

REF="/home/lauterw/refs/human_GRCh38_p14/GRCh38.p14_genomic.fna"
DATADIR="/home/lauterw/STAR_protocol_Ji_2022/data/GSE175750"
ACC_LIST="${DATADIR}/SRR_Acc_List.txt"
OUTDIR="/home/lauterw/STAR_protocol_Ji_2022/results/bwa_output"

mkdir -p "$OUTDIR"

export REF DATADIR ACC_LIST OUTDIR

parallel --dry-run -j 5 --halt soon,fail=10 '
    SRR={}
    FASTQ="'$DATADIR'/${SRR}.fastq"
    BAM="'$OUTDIR'/${SRR}.sorted.bam"
    BAM_NDUP="'$OUTDIR'/${SRR}.sorted.rmdup.bam"
    BW="'$OUTDIR'/${SRR}.bw"

    echo "Processing $SRR..."

    #bwa mem -t 20 "'$REF'" "$FASTQ" | \
    #    samtools view -bS - | \
    #    samtools sort -o "$BAM"

    #samtools index "$BAM"

    samtools rmdup "$BAM" "$BAM_NDUP"

    bamCoverage -b "$BAM_NDUP" -o "$BW" -e --normalizeUsing RPKM --extendReads 150

    echo "Finished $SRR"

' :::: "$ACC_LIST"

#bamCompare -b1 Chip.bam