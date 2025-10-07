#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=cnvkit_batch
#SBATCH --output=cnvkit_batch.log
#SBATCH --error=cnvkit_batch.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
# make sure Picard 3+ is available

# Directories 
BAM="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"  # your sorted BAMs
OUTDIR="/home/lauterw/WIAB_IDPE/results/cnaKit/results"  
REF="/home/lauterw/WIAB_IDPE/results/cnaKit/concat_refs"

#LIST_RPE="$OUTDIR/RPE_SETD2i_WIAB_IDPE.txt"
#LIST_P53="$OUTDIR/P53_SETD2i_WIAB_IDPE.txt"

#Non-treated
LIST_RPE="$REF/RPE_Ref_WIAB_IDPE.txt"
LIST_P53="$REF/P53_loss_Ref_WIAB_IDPE.txt"

TARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_targets_WIAB_IDPE.bed"
ANTITARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_antitargets_WIAB_IDPE.bed"

export BAM OUTDIR LIST_RPE LIST_P53 TARGETS ANTITARGETS REF

export TMPDIR='/rs01/home/lauterw/tmp'

parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    BAM="$BAM/${WIAB_IDPE}.marked.bam"
    
    cnvkit.py batch "$BAM" -r "$REF/RPE_reference.cnn" -p 30 \
	--output-dir "$OUTDIR/WIAB_RPE_vs_RPE_ref" \
	--diagram \
	--scatter \
	--drop-low-coverage 

' :::: "$LIST_RPE"

parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    BAM="$BAM/${WIAB_IDPE}.marked.bam"
    cnvkit.py batch "$BAM" -r "$REF/P53_reference.cnn" -p 30 \
	--output-dir "$OUTDIR/WIAB_P53_vs_P53_ref" \
	--diagram \
	--scatter \
	--drop-low-coverage

' :::: "$LIST_P53"

