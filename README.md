## QC pipelines
deeptools tools for exploring deep sequencing data
- Analysis of correlation of bamfiles

## Mapping pipelines

## Copy Number Variation (CNV) Analysis Pipelines
GATK & CNVkit Workflows for Targeted and Whole-Exome Sequencing

### Overview
This repository provides reproducible, HPC-ready workflows for copy number variation (CNV) analysis using two independent pipelines:
1. GATK CNV Workflow — Best-practice CNV calling using the Broad Institute's Genome Analysis Toolkit (GATK).
2. CNVkit Workflow — Coverage-based CNV detection using CNVkit for targeted and hybrid capture sequencing.

Each workflow includes:
- Ready-to-run SLURM batch scripts for HPC clusters
- Step-by-step setup and execution guides
- Notes on parameters, expected outputs, and biological interpretation

### Reproducibility
All scripts are fully modular and can be customized per project.
Each step includes:
- Input and output definitions
- Environment setup instructions
- Optional parameters for advanced tuning
To rerun or adapt:
- Update paths in the scripts (BAM, REF, TARGETS, etc.)
- Submit each job to the HPC queue using sbatch
- Review logs and resulting CNV tables/plots

## Duplicate and fusion genes
- Manual inspection of fusioned genes 
- Using the "supplementary", "mates on different chromosomes", and mates on same chromosomes but in distant than expected" reads. 
- Compare it with Normal. 

## Repository Structure

### Folder Organization

- **CNVkit**: Contains scripts and tools for copy number variation analysis using CNVkit.
- **GATK_CNV**: Includes files related to the Genome Analysis Toolkit for copy number variations.
- **Mapping**: Houses the mapping files and scripts used for aligning sequencing data.
- **QC**: Contains quality control metrics and reports for the datasets.
- **ChIP-Seq_Chromatin_analysis**: Includes analysis scripts and data related to ChIP-Seq experiments.
- **Duplication_fusion_genes**: Contains files related to the analysis of gene duplications and fusions.
- **deeptools**: Houses scripts and tools used for deep data analysis.
- **bcftools**: Contains tools for variant calling and manipulating VCF files.
- **fastq**: Houses FASTQ files of raw sequencing data.

### Technology Stack
- **Shell**: 84.9%
- **Jupyter Notebook**: 15.1%

## Citation
relevant tools:
- GATK CNV – Benjamin et al., Nature Genetics (2013)
- CNVkit – Talevich et al., PLOS Computational Biology (2016)