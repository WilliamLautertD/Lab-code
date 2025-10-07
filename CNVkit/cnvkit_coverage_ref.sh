#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=cnvkit_coverage
#SBATCH --output=cnvkit_coverageoutput.log
#SBATCH --error=cnvkit_coverage_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=20
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
# make sure Picard 3+ is available

# Directories
BAM="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"  # your sorted BAMs
OUTDIR="/home/lauterw/WIAB_IDPE/results/cnaKit/concat_refs"  # your sorted BAMs

LIST_RPE="$OUTDIR/RPE_Ref_WIAB_IDPE.txt"
LIST_P53="$OUTDIR/P53_loss_Ref_WIAB_IDPE.txt"

TARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_targets_WIAB_IDPE.bed"
ANTITARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_antitargets_WIAB_IDPE.bed"

export BAM OUTDIR LIST_RPE LIST_P53 TARGETS ANTITARGETS

export TMPDIR='/rs01/home/lauterw/tmp'

export REF DATADIR LIST OUTDIR

parallel --tmpdir "$TMPDIR" --jobs 6 --halt soon,fail=10 '
    
    WIAB_IDPE={}

    BAM="$BAM/${WIAB_IDPE}.marked.bam"
    
    echo "Calculating coverage in the given regions from BAM read depths for $WIAB_IDPE..."
    cnvkit.py coverage "$BAM" "$TARGETS" -o "$OUTDIR/${WIAB_IDPE}.P53_loss.targetcoverage.cnn" -p 20
    cnvkit.py coverage "$BAM" "$ANTITARGETS" -o "$OUTDIR/${WIAB_IDPE}.P53_loss.antitargetcoverage.cnn" -p 20

    echo "Finished $WIAB_IDPE"

' :::: "$LIST_P53" 

parallel --jobs 6 "$TMPDIR" --halt soon,fail=10 '
    
    WIAB_IDPE={}

    BAM="$BAM/${WIAB_IDPE}.marked.bam"
    
    echo "Calculating coverage in the given regions from BAM read depths for $WIAB_IDPE..."
    cnvkit.py coverage "$BAM" "$TARGETS" -o "$OUTDIR/${WIAB_IDPE}.RPE.targetcoverage.cnn" -p 20
    cnvkit.py coverage "$BAM" "$ANTITARGETS" -o "$OUTDIR/${WIAB_IDPE}.RPE.antitargetcoverage.cnn" -p 20

    echo "Finished $WIAB_IDPE"

' :::: "$LIST_RPE" 

