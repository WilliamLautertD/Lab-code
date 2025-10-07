#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=GATK_panel_of_normals
#SBATCH --output=GATK_panel_of_normals.log
#SBATCH --error=GATK_panel_of_normals.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=24:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load modules
module purge
module load openjdk/17.0.8.1_1-gcc-13.1.0
module load gatk/4.4.0.0-gcc-13.1.0

# Directories
DIR="/home/lauterw/WIAB_IDPE/results/GATK_CNV"
PON_dir="$DIR/pon"
ANN_INTER="$DIR/targets/annotated_intervals.tsv"

#tmp dir
TMPDIR='/rs01/home/lauterw/tmp'

# export variables
export DIR REF_gen ANN_INTER TMPDIR

# Ensure output directory exists
mkdir -p "$PON_dir"

#Panel of Normal - RPE
gatk CreateReadCountPanelOfNormals \
    -I "$DIR/counts/normal/RPE/WIAB_IDPE_1.counts.hdf5" \
    -I "$DIR/counts/normal/RPE/WIAB_IDPE_3.counts.hdf5" \
    -I "$DIR/counts/normal/RPE/WIAB_IDPE_7.counts.hdf5" \
    -I "$DIR/counts/normal/RPE/WIAB_IDPE_9.counts.hdf5" \
    -I "$DIR/counts/normal/RPE/WIAB_IDPE_13.counts.hdf5" \
    -I "$DIR/counts/normal/RPE/WIAB_IDPE_15.counts.hdf5" \
    --annotated-intervals  "$ANN_INTER" \
    -O "$PON_dir/RPE/pon_RPE.hdf5"

#Panel of Normal - P53
gatk CreateReadCountPanelOfNormals \
    -I "$DIR/counts/normal/P53/WIAB_IDPE_19.counts.hdf5" \
    -I "$DIR/counts/normal/P53/WIAB_IDPE_23.counts.hdf5" \
    -I "$DIR/counts/normal/P53/WIAB_IDPE_25.counts.hdf5" \
    -I "$DIR/counts/normal/P53/WIAB_IDPE_27.counts.hdf5" \
    -I "$DIR/counts/normal/P53/WIAB_IDPE_29.counts.hdf5" \
    -I "$DIR/counts/normal/P53/WIAB_IDPE_31.counts.hdf5" \
    --annotated-intervals  "$ANN_INTER" \
    -O "$PON_dir/P53/pon_P53.hdf5"