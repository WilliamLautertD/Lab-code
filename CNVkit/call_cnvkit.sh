#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=cnvkit_call
#SBATCH --output=cnvkit_call.log
#SBATCH --error=cnvkit_call.err
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

#Control
LIST_RPE="$OUTDIR/RPE_Ref_WIAB_IDPE.txt"
LIST_P53="$OUTDIR/P53_loss_Ref_WIAB_IDPE.txt"

#SETD2i
#LIST_RPE="$OUTDIR/RPE_SETD2i_WIAB_IDPE.txt"
#LIST_P53="$OUTDIR/P53_SETD2i_WIAB_IDPE.txt"


export OUTDIR LIST_RPE LIST_P53

export TMPDIR='/rs01/home/lauterw/tmp'

parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    cnvkit.py call "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.bintest.cns" \
    -m clonal \
    --purity 0.15 \
    -o "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.bintest.call.cns" \
    --drop-low-coverage

' :::: "$LIST_RPE"

parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    cnvkit.py call "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.bintest.cns" -m clonal \
    --purity 0.15 \
    -o "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.bintest.call.cns" \
    --drop-low-coverage

' :::: "$LIST_P53"
