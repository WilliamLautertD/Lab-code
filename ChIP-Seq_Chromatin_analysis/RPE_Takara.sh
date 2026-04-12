#!/bin/bash
#SBATCH -p general
#SBATCH --job-name=Takara_ChIP_Seq_Test_6_Cycles
#SBATCH --output=Takara_ChIP_Seq_Test_6_Cycles.log
#SBATCH --error=Takara_ChIP_Seq_Test_6_Cycles.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=100
#SBATCH --time=10:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

#--------------------
# 1 - Load modules 
# Load modules (if needed)
module load bwa/0.7.17-gcc-13.1.0
module load samtools/1.17-gcc-13.1.0

#--------------------
# 2 - Load input files
# List of fastq files
DATADIR="/home/lauterw/RPE_Takara_Chip_Seq_Test/Takara_ChIP_Seq_Test_6_Cycles"
LIST="${DATADIR}/data/filenames.txt"

#--------------------
# Define constants
# QC
OUTDIR_TRIM="${DATADIR}/data/trimmed"
OUTDIR_QC="${DATADIR}/data/qc"

# Make output directory if it doesn't exist
mkdir -p "$OUTDIR_TRIM"
mkdir -p "$OUTDIR_QC"

#--------------------
# Mapping 
REF="/home/lauterw/refs/human_hg19_igenome/hg19.fa"
OUTDIR_BAM="${DATADIR}/bwa_mapping_hg19"

# Make directory if it doesn't exist
mkdir -p "$OUTDIR_BAM"
mkdir -p "$OUTDIR_BAM/rmdupl_duplicates"

#--------------------
# Set temporary directory for GNU Parallel
TMPDIR='/rs01/home/lauterw/tmp'
mkdir -p "$TMPDIR"

#--------------------
# export variables for parallel
export DATADIR LIST OUTDIR_QC OUTDIR_TRIM REF OUTDIR_BAM TMPDIR

# Export tmp directory for fastp
export TMPDIR="${SLURM_TMPDIR:-$HOME/tmp}"
mkdir -p "$TMPDIR"
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=$TMPDIR"

#--------------------
# 3 - Quality Analysis 
# Running FASTQC on raw reads
parallel --tmpdir "$TMPDIR" -j 5 '
    echo fastqc "${DATADIR}/data/{}_L001_R1_001.fastq.gz" -o ${OUTDIR_QC}
    conda run -n qc_analysis fastqc \
        "${DATADIR}/data/{}_L001_R1_001.fastq.gz" \
        -o ${OUTDIR_QC} 
    
    echo fastqc "${DATADIR}/data/{}_L001_R2_001.fastq.gz" -o ${OUTDIR_QC}
    conda run -n qc_analysis fastqc \
        "${DATADIR}/data/{}_L001_R2_001.fastq.gz" \
        -o ${OUTDIR_QC} 
' :::: $LIST

# Running fastp for trimming
parallel --tmpdir "$TMPDIR" -j 3 '
    conda run -n qc_analysis fastp \
    --in1 "${DATADIR}/data/{}_L001_R1_001.fastq.gz" \
    --in2 "${DATADIR}/data/{}_L001_R2_001.fastq.gz" \
    --out1 "${OUTDIR_TRIM}/{}_trimmed_R1.fastq.gz" \
    --out2 "${OUTDIR_TRIM}/{}_trimmed_R2.fastq.gz" \
    --thread 20
' :::: $LIST

# QC report for trimmed reads
# FastQC
conda run -n qc_analysis \
  fastqc ${OUTDIR_TRIM}/*.fastq.gz \
  -o ${OUTDIR_QC} -t 5

# MultiQC
conda run -n qc_analysis multiqc ${OUTDIR_QC} \
    --outdir ${OUTDIR_QC}/multiqc \
    --title "MultiQC Report - Takara_ChIP_Seq_Test_6_Cycles"


#--------------------
# 4 - Mapping reads to genome 
# Mapping Reads
parallel -j 2 --halt soon,fail=10 '
    READS={}
    
    R1="'$OUTDIR_TRIM'/${READS}_trimmed_R1.fastq.gz"
    R2="'$OUTDIR_TRIM'/${READS}_trimmed_R2.fastq.gz"
    
    OUTBAM="'$OUTDIR_BAM/rmdupl_duplicates'/${READS}.sorted.rmdup.bam"

    TMPPFX="${TMPDIR}/${READS}.{#}"

    echo "Processing $READS..."

    bwa mem -t 20 "'$REF'" "$R1" "$R2" | \
        samtools collate -@ 4 -O -u - | \
        samtools fixmate -@ 4 -m -u - - | \
        samtools sort -@ 8 -T "${TMPPFX}.sort" -u - | \
        samtools markdup -@ 8 - - | \
        samtools view -@ 4 -b -q 30 -F 4 -F 256 -F 2048 -F 1024 - | \
        samtools sort -@ 8 -T "${TMPPFX}.finalsort" -o "${OUTBAM}" -

    samtools index "${OUTBAM}"

    samtools flagstat -@ 4 \
        -O tsv "${OUTBAM}" > "${OUTDIR_BAM}/rmdupl_duplicates/${READS}.sorted.rmdup.flagstats.tsv"

    echo "Finished $READS"

' :::: "$LIST"


#--------------------
# 5 - Get BigWig of ChIP vs Input signal
DEEPCPU=20
OUTDIR_BW="${DATADIR}/bigwig_files"
# Make output directory if it doesn't exist
mkdir -p "$OUTDIR_BW"
export OUTDIR_BW DEEPCPU


# Bin size 200, smooth length 600
#----------------------------------------------------------
# CTCF  (Input: siCTRL_INPUT_S11)
#----------------------------------------------------------

for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siCT1_K36me3_6_cycles_S5.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siCT2_K36me3_6_cycles_S6.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS200_S600.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_siCTRL_INPUT_S11.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 600 \
    --binSize 200

  conda run -n deeptools plotFingerprint  \
    -b "$bam" "$OUTDIR_BAM/rmdupl_duplicates/03302026_siCTRL_INPUT_S11.sorted.rmdup.bam" \
    -T "Fingerprints of CTCFs" \
    --labels $base input \
    --plotFile "$OUTDIR_BW/fingerprints_$base".png \
    --outRawCounts "$OUTDIR_BW/fingerprints_$base".tab \
    --numberOfProcessors "${DEEPCPU}"
done

#----------------------------------------------------------
# SETD2  (Input: 03302026_siSETD2_INPUT_S12)
#----------------------------------------------------------

for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siSETD2_23_K36me3_6_cycles_S7.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siSETD2_25_K36me3_6_cycles_S8.sorted.rmdup.bam"

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS200_S600.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_siSETD2_INPUT_S12.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 600 \
    --binSize 200

  conda run -n deeptools plotFingerprint  \
    -b "$bam" "$OUTDIR_BAM/rmdupl_duplicates/03302026_siSETD2_INPUT_S12.sorted.rmdup.bam" \
    -T "Fingerprints of SETD2" \
    --labels $base input \
    --plotFile "$OUTDIR_BW/fingerprints_$base".png \
    --outRawCounts "$OUTDIR_BW/fingerprints_$base".tab \
    --numberOfProcessors "${DEEPCPU}" 
done

#----------------------------------------------------------
# RPE 1 (Input: 03302026_RPE_1_K9_INPUT_S9)
#----------------------------------------------------------
for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_1_K9me1_6_cycles_S1.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_1_K9me2_6_cycles_S3.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS200_S600.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_RPE_1_K9_INPUT_S9.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 600 \
    --binSize 200

  conda run -n deeptools plotFingerprint  \
    -b "$bam" "$OUTDIR_BAM/rmdupl_duplicates/03302026_RPE_1_K9_INPUT_S9.sorted.rmdup.bam" \
    -T "Fingerprints of RPE 1" \
    --labels $base input \
    --plotFile "$OUTDIR_BW/fingerprints_$base".png \
    --outRawCounts "$OUTDIR_BW/fingerprints_$base".tab \
    --numberOfProcessors "${DEEPCPU}" 
done

#----------------------------------------------------------
# RPE 2 (Input: 03302026_RPE_2_K9_INPUT_S10)
#----------------------------------------------------------

for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_2_K9me1_6_cycles_S2.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_2_K9me2_6_cycles_S4.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS200_S600.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_RPE_2_K9_INPUT_S10.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 600 \
    --binSize 200

  conda run -n deeptools plotFingerprint  \
    -b "$bam" "$OUTDIR_BAM/rmdupl_duplicates/03302026_RPE_2_K9_INPUT_S10.sorted.rmdup.bam" \
    -T "Fingerprints of RPE 2" \
    --labels $base input \
    --plotFile "$OUTDIR_BW/fingerprints_$base".png \
    --outRawCounts "$OUTDIR_BW/fingerprints_$base".tab \
    --numberOfProcessors "${DEEPCPU}"  
done


# Bin size 50, smooth length 150
#----------------------------------------------------------
# CTCF  (Input: siCTRL_INPUT_S11)
#----------------------------------------------------------

for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siCT1_K36me3_6_cycles_S5.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siCT2_K36me3_6_cycles_S6.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS50_S150.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_siCTRL_INPUT_S11.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 150 \
    --binSize 50
 
done

#----------------------------------------------------------
# SETD2  (Input: 03302026_siSETD2_INPUT_S12)
#----------------------------------------------------------

for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siSETD2_23_K36me3_6_cycles_S7.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_siSETD2_25_K36me3_6_cycles_S8.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS50_S150.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_siSETD2_INPUT_S12.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 150 \
    --binSize 50

done

#----------------------------------------------------------
# RPE 1 (Input: 03302026_RPE_1_K9_INPUT_S9)
#----------------------------------------------------------
for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_1_K9me1_6_cycles_S1.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_1_K9me2_6_cycles_S3.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS50_S150.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_RPE_1_K9_INPUT_S9.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 150 \
    --binSize 50
 
done

#----------------------------------------------------------
# RPE 2 (Input: 03302026_RPE_2_K9_INPUT_S10)
#----------------------------------------------------------

for bam in \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_2_K9me1_6_cycles_S2.sorted.rmdup.bam" \
    "${OUTDIR_BAM}/rmdupl_duplicates/03302026_RPE_2_K9me2_6_cycles_S4.sorted.rmdup.bam" 

do

  base=$(basename "$bam" .sorted.rmdup.bam)
  bw="$OUTDIR_BW/${base}_BS50_S150.bw"
  echo "Processing DEFAULT $bam -> $bw"

  conda run -n deeptools bamCompare \
    -b1 "$bam" \
    -b2 "$OUTDIR_BAM/rmdupl_duplicates/03302026_RPE_2_K9_INPUT_S10.sorted.rmdup.bam" \
    -o "$bw" \
    --ignoreDuplicates \
    --numberOfProcessors "${DEEPCPU}" \
    --operation ratio \
    --smoothLength 150 \
    --binSize 50

done

