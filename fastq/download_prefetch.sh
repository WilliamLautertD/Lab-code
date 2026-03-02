#!/bin/bash
#SBATCH --job-name=prefetch_download
#SBATCH --output=prefetch_output.log
#SBATCH --error=prefetch_output.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=72:00:00
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

parallel -j 32 'prefetch {}' :::: SRR_Acc_List.txt
