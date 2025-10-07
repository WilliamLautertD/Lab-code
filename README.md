# Copy Number Variation (CNV) Analysis Pipelines
GATK & CNVkit Workflows for Targeted and Whole-Exome Sequencing

## Overview
This repository provides reproducible, HPC-ready workflows for copy number variation (CNV) analysis using two independent pipelines:
1. GATK CNV Workflow — Best-practice CNV calling using the Broad Institute’s Genome Analysis Toolkit (GATK).
2. CNVkit Workflow — Coverage-based CNV detection using CNVkit for targeted and hybrid capture sequencing.

Each workflow includes:
- Ready-to-run SLURM batch scripts for HPC clusters
- Step-by-step setup and execution guides
- Notes on parameters, expected outputs, and biological interpretation

## Reproducibility
All scripts are fully modular and can be customized per project.
Each step includes:
- Input and output definitions
- Environment setup instructions
- Optional parameters for advanced tuning
To rerun or adapt:
- Update paths in the scripts (BAM, REF, TARGETS, etc.)
- Submit each job to the HPC queue using sbatch
- Review logs and resulting CNV tables/plots

## Citation
relevant tools:
- GATK CNV – Benjamin et al., Nature Genetics (2013)
- CNVkit – Talevich et al., PLOS Computational Biology (2016)
