#!/bin/bash
#SBATCH --job-name=index_Hs_genome_STAR
#SBATCH --output=index_Hs_genome_STAR_output.log
#SBATCH --error=index_Hs_genome_STAR_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load BWA module if needed (uncomment if using environment modules)
# module load STAR

# Path to genome FASTA
file="/home/lauterw/refs/human_GRCh38_p14/GRCh38.p14_genomic.fna"

# Navigate to the directory where the FASTA file is located
cd $(dirname "$file")

mkdir -p STARindex

# Run STAR index
STAR --runMode genomeGenerate \
        --runThreadN 32 \
        --genomeDir STARindex \
        --genomeFastaFiles $file \
        --sjdbGTFfile "$(dirname $file)/$(basename $file .fna).gtf" \
        --sjdbOverhang 49
