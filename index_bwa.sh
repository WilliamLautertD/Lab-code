#!/bin/bash
#SBATCH --job-name=index_Hs_genome_bwa
#SBATCH --output=index_Hs_genome_bwa_output.log
#SBATCH --error=index_Hs_genome_bwa_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Load BWA module if needed (uncomment if using environment modules)
# module load bwa

# Path to genome FASTA
file="/home/lauterw/refs/human_GRCh38_p14/GRCh38.p14_genomic.fna"

# Output index prefix
prefix=$(basename "$file" .fna)

# Navigate to the directory where the FASTA file is located
cd $(dirname "$file")

# Run BWA index
echo bwa index -p "$prefix" "$file"


