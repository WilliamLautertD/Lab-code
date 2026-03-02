#!/bin/bash
#SBATCH -p general
#SBATCH --job-name=cnvkit_normal_refs
#SBATCH --output=cnvkit_normal_refs.log
#SBATCH --error=cnvkit_normal_refs.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
# make sure Picard 3+ is available

# Directories
#BAM="/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates"  # your sorted BAMs
OUTDIR="/home/lauterw/WIAB_IDPE/results/cnaKit/concat_refs"  # your sorted BAMs
REF="/home/lauterw/refs/human_hg38_UCSC/hg38.fa"

TARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_targets_WIAB_IDPE.bed"
ANTITARGETS="/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_antitargets_WIAB_IDPE.bed"

export OUTDIR REF TARGETS ANTITARGETS

export TMPDIR='/rs01/home/lauterw/tmp'

export REF DATADIR LIST OUTDIR

#cnvkit.py reference "$OUTDIR"/*.RPE.targetcoverage.cnn "$OUTDIR"/*.RPE.antitargetcoverage.cnn \
#    -f $REF -o "$OUTDIR/RPE_reference.cnn" \
#    -c

cnvkit.py reference "$OUTDIR"/*.P53_loss.targetcoverage.cnn "$OUTDIR"/*.P53_loss.antitargetcoverage.cnn \
    -f $REF -o "$OUTDIR/P53_reference.cnn" \
    -c
