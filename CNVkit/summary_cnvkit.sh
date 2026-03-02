#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=cnvkit_summary
#SBATCH --output=cnvkit_summary.log
#SBATCH --error=cnvkit_summary.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
# make sure Picard 3+ is available

# Directories 
OUTDIR="/home/lauterw/WIAB_IDPE/results/cnaKit/results"  

#Control
LIST_RPE="$OUTDIR/RPE_Ref_WIAB_IDPE.txt"
LIST_P53="$OUTDIR/P53_loss_Ref_WIAB_IDPE.txt"

#SETD2i
#LIST_RPE="$OUTDIR/RPE_SETD2i_WIAB_IDPE.txt"
#LIST_P53="$OUTDIR/P53_SETD2i_WIAB_IDPE.txt"

export OUTDIR LIST_RPE LIST_P53

export TMPDIR='/rs01/home/lauterw/tmp'

# WIAB_RPE
parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    cnvkit.py scatter "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.bintest.call.cns" \
        -g MYC \
        -c chr8:122000000-132000000 \
        -o "$OUTDIR/WIAB_RPE/MYC_${WIAB_IDPE}.pdf"

    cnvkit.py diagram "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.cnr" \
    	-o "$OUTDIR/WIAB_RPE/MYC_${WIAB_IDPE}_diagram.pdf"
    
    cnvkit.py breaks "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.cnr" "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.bintest.call.cns" > "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.breaks.txt"
    
    cnvkit.py genemetrics "$OUTDIR/WIAB_RPE/${WIAB_IDPE}.marked.cnr" \
    	-t 0.4 -m 5 -o "$OUTDIR/WIAB_RPE/${WIAB_IDPE}_metrics.txt"

' :::: "$LIST_RPE"

# WIAB_P53
parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    cnvkit.py scatter "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.bintest.call.cns" \
        -g MYC \
        -c chr8:122000000-132000000 \
        -o "$OUTDIR/WIAB_P53/MYC_${WIAB_IDPE}.pdf"

    cnvkit.py diagram "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.cnr" \
    	-o "$OUTDIR/WIAB_P53/MYC_${WIAB_IDPE}_diagram.pdf"

    cnvkit.py breaks "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.cnr" "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.bintest.call.cns" > "$OUTDIR/WIAB_P53/${WIAB_IDPE}.breaks.txt"
    
    cnvkit.py genemetrics "$OUTDIR/WIAB_P53/${WIAB_IDPE}.marked.cnr" \
    	-t 0.4 -m 5 -o "$OUTDIR/WIAB_RPE/${WIAB_IDPE}_metrics.txt"

' :::: "$LIST_P53"

# WIAB_RPE_purity
parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    cnvkit.py scatter "$OUTDIR/WIAB_RPE_0_15/${WIAB_IDPE}.marked.bintest.call.cns" \
        -g MYC \
        -c chr8:122000000-132000000 \
        -o "$OUTDIR/WIAB_RPE_0_15/MYC_${WIAB_IDPE}.pdf"

    cnvkit.py diagram "$OUTDIR/WIAB_RPE_0_15/${WIAB_IDPE}.marked.bintest.call.cns" \
    	-o "$OUTDIR/WIAB_RPE_0_15/MYC_${WIAB_IDPE}_diagram.pdf"

' :::: "$LIST_RPE"

# WIAB_P53_purity
parallel --tmpdir "$TMPDIR" --jobs 1 --halt soon,fail=10 '

    WIAB_IDPE={}

    cnvkit.py scatter "$OUTDIR/WIAB_P53_purity_0_45/${WIAB_IDPE}.marked.bintest.call.cns" \
        -g MYC \
        -c chr8:122000000-132000000 \
        -o "$OUTDIR/WIAB_P53_purity_0_45/MYC_${WIAB_IDPE}.pdf"

    cnvkit.py diagram "$OUTDIR/WIAB_P53_purity_0_45/${WIAB_IDPE}.marked.bintest.call.cns" \
    	-o "$OUTDIR/WIAB_P53_purity_0_45/MYC_${WIAB_IDPE}_diagram.pdf"

' :::: "$LIST_P53"

