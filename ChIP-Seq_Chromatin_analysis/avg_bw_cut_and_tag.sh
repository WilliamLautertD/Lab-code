#!/bin/bash
#SBATCH -p general_long
#SBATCH --job-name=avg_cut_and_TAG_rep
#SBATCH --output=avg_cut_and_TAG_rep.log
#SBATCH --error=avg_cut_and_TAG_rep.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --time=10:00:00
#SBATCH --mem=150G
#SBATCH --mail-user=William.LautertDutra@fccc.edu
#SBATCH --mail-type=END,FAIL

# Pair 1: KDM4C_OE KDM4C 4ug
bigwigAverage -b \
    --bs 1 \
    3_27_26_KDM4C_OE_KDM4C_4ug_S1_S29.spikenorm.bw \
    3_27_26_KDM4C_OE_KDM4C_4ug_S2_S35.spikenorm.bw \
    -o 3_27_26_KDM4C_OE_KDM4C_4ug_avg.bw -p 60

bigWigToBedGraph 3_27_26_KDM4C_OE_KDM4C_4ug_avg.bw 3_27_26_KDM4C_OE_KDM4C_4ug_avg.bedGraph

# Pair 2: KDM4C_OE KDM4C 2ug
bigwigAverage -b \
  --bs 1 \
  3_27_26_KDM4C_OE_KDM4C_2ug_S1_S27.spikenorm.bw \
  3_27_26_KDM4C_OE_KDM4C_2ug_S2_S33.spikenorm.bw \
  -o 3_27_26_KDM4C_OE_KDM4C_2ug_avg.bw -p 60

bigWigToBedGraph 3_27_26_KDM4C_OE_KDM4C_2ug_avg.bw 3_27_26_KDM4C_OE_KDM4C_2ug_avg.bedGraph

# Pair 3: KDM4C_OE H3K4me3
bigwigAverage -b \
  --bs 1 \
  3_27_26_KDM4C_OE_H3K4me3_S1_S31.spikenorm.bw \
  3_27_26_KDM4C_OE_H3K4me3_S2_S37.spikenorm.bw \
  -o 3_27_26_KDM4C_OE_H3K4me3_avg.bw -p 60

bigWigToBedGraph 3_27_26_KDM4C_OE_H3K4me3_avg.bw 3_27_26_KDM4C_OE_H3K4me3_avg.bedGraph
# Pair 4: EV KDM4C 4ug
bigwigAverage -b \
  --bs 1 \
  3_27_26_EV_KDM4C_4ug_S1_S28.spikenorm.bw \
  3_27_26_EV_KDM4C_4ug_S2_S34.spikenorm.bw \
  -o 3_27_26_EV_KDM4C_4ug_avg.bw -p 60

bigWigToBedGraph 3_27_26_EV_KDM4C_4ug_avg.bw 3_27_26_EV_KDM4C_4ug_avg.bedGraph

# Pair 5: EV KDM4C 2ug
bigwigAverage -b \
  --bs 1 \
  3_27_26_EV_KDM4C_2ug_S1_S26.spikenorm.bw \
  3_27_26_EV_KDM4C_2ug_S2_S32.spikenorm.bw \
  -o 3_27_26_EV_KDM4C_2ug_avg.bw -p 60

bigWigToBedGraph 3_27_26_EV_KDM4C_2ug_avg.bw 3_27_26_EV_KDM4C_2ug_avg.bedGraph
 
# Pair 6: EV H3K4me3 (adding since you have the files)
bigwigAverage -b \
  --bs 1 \
  3_27_26_EV_H3K4me3_S1_S30.spikenorm.bw \
  3_27_26_EV_H3K4me3_S2_S36.spikenorm.bw \
  -o 3_27_26_EV_H3K4me3_avg.bw -p 60

bigWigToBedGraph 3_27_26_EV_H3K4me3_avg.bw 3_27_26_EV_H3K4me3_avg.bedGraph

