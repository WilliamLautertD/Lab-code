#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=CNVkit_subsampling
#SBATCH --output=CNVkit_subsampling.log
#SBATCH --error=CNVkit_subsampling.err
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=15
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules

# Directories 
BAMDIR="/home/lauterw/WIAB_IDPE/results/bwa_output"
OUTBASE="/home/lauterw/WIAB_IDPE/results/cnaKit/results/subset/P53_SETD2i"
HG19="/home/lauterw/refs/human_hg38_UCSC/hg38.fa"

# Target and antitarget files
TARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_targets_WIAB_IDPE.bed"
ANTITARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_antitargets_WIAB_IDPE.bed"

# List samples
LIST_P53_loss="$BAMDIR/marked_duplicates/P53_loss_Ref_WIAB_IDPE.txt"
LIST_P53_SETD2i="$BAMDIR/marked_duplicates/P53_SETD2i_WIAB_IDPE.txt"

# Subsample and process each sample in the list
COVERAGE="01 05 10 15 20 25 30"

# Export variables for GNU Parallel
export BAMDIR OUTBASE LIST_P53_loss TARGETS ANTITARGETS HG19 COVERAGE

# Set temporary directory for GNU Parallel
export TMPDIR='/rs01/home/lauterw/tmp'

# Create output dirs
for i in $COVERAGE; do
  mkdir -p "$OUTBASE/sub_${i}/ref"
done

# Calculate coverage for each sample and coverage level in parallel
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '
    
    SAMPLE={}

    for i in $COVERAGE; do

        subdir="sub_${i}" 
        BAM="$BAMDIR/P53_loss_subsampled/${subdir}/${SAMPLE}.subsampled_${i}.bam"

        echo "Calculating coverage in the given regions from BAM read depths for $SAMPLE with coverage $i..."
        
        cnvkit.py coverage "$BAM" "$TARGETS" \
            -o "$OUTBASE/${subdir}/ref/${SAMPLE}.P53_loss.targetcoverage.${i}.cnn" \
            -p 15
    
        cnvkit.py coverage "$BAM" "$ANTITARGETS" \
            -o "$OUTBASE/${subdir}/ref/${SAMPLE}.P53_loss.antitargetcoverage.${i}.cnn" \
            -p 15

    echo "Finished $SAMPLE"
    done

' :::: "$LIST_P53_loss"

# Create reference from the target and antitarget coverage files
for i in $COVERAGE; do

    echo "Creating reference for coverage level $i..."
    subdir="sub_${i}"
    cnvkit.py reference \
        "$OUTBASE/${subdir}/ref/"*P53_loss.targetcoverage.${i}.cnn \
        "$OUTBASE/${subdir}/ref/"*P53_loss.antitargetcoverage.${i}.cnn \
        -f "$HG19" \
        -o "$OUTBASE/${subdir}/ref/P53_reference_${i}.cnn"
done


# Run CNVkit batch for each sample and coverage level in parallel
parallel --tmpdir "$TMPDIR" --jobs 5 --halt soon,fail=10 '

    SAMPLE={}

    for i in $COVERAGE; do
        
        subdir="sub_${i}"
        BAM="$BAMDIR/P53_loss_SETD2i_subsampled/${subdir}/${SAMPLE}.subsampled_${i}.bam"
        
        
        cnvkit.py batch "$BAM" \
        -r "$OUTBASE/${subdir}/ref/P53_reference_${i}.cnn" \
        --output-dir "$OUTBASE/${subdir}/${SAMPLE}_P53_vs_P53_ref_${i}" \
	    --diagram \
	    --scatter \
	    --drop-low-coverage \
        -p 15
    echo "Finished $SAMPLE with coverage $i"
    done

' :::: "$LIST_P53_SETD2i"


