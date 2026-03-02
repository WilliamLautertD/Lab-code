#!/bin/bash
#SBATCH --job-name=fastq_dump_GSE176495
#SBATCH --output=fastq-dump_output_176495.log
#SBATCH --error=fastq-dump_output_176495.err
#SBATCH --nodes=1
#SBATCH --ntasks=27
#SBATCH --cpus-per-task=1
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Created by: William L. - Whetstine's Lab, Fox Chase Cancer Center
# Pre-processing '.sra' files downloaded from SRA database

# Help message function
usage() {
  echo "Usage: $(basename "$0") -1 <working_dir> -2 <srr_list_file> -o <output_dir>"
  echo "Pre-processing '.sra' files downloaded from SRA database."
  echo ""
  echo "Options:"
  echo "  -h             Show this help message"
  echo "  -1 <dir>       Directory where the SRR dirs are saved"
  echo "  -2 <file>      Path to SRR_Acc_List.txt"
  echo "  -o <out>       Output directory for the fastq files"
  echo ""
  echo "Example:"
  echo "  $(basename "$0") -1 data/GSE175751 -2 data/GSE175751/SRR_Acc_List.txt -o /data/GSE175751"
  exit 1
}

# Default values
dir=""
file=""
out=""

# Parse input arguments
while getopts ":1:2:o:h" opt; do
  case ${opt} in
    1 ) dir="$OPTARG" ;;
    2 ) file="$OPTARG" ;;
    o ) out="$OPTARG" ;;
    h ) usage ;;
    \? ) echo "Invalid option: -$OPTARG" >&2; usage ;;
    : ) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Validate required inputs
if [[ -z "$dir" || -z "$file" || -z "$out" ]]; then
  echo "Error: All three parameters -1, -2, and -o are required."
  usage
fi

# Run fastq-dump in parallel
echo "Running fastq-dump on SRR list..."
parallel -j 27 "fastq-dump --split-files  ${dir}/{} -O ${out}" :::: "$file"
