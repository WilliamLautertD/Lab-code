## CNKit Copy Number Analysis Pipeline (CNVkit-based)

1. Environment Setup
-   Load required modules (HPC environment)
-   Before running any CNVkit scripts, make sure the environment is properly configured.
-   Check available modules:
````
module avail
````
-   Load modules:
````
module purge
module load python/3.10.13-gcc-13.1.0
module load cnvkit/0.9.10-gcc-13.1.0
module load picard/3.2.0-gcc-13.1.0
````

2. Workflow Overview
-   The CNKit pipeline uses CNVkit to perform copy number variation (CNV) analysis on exome or targeted sequencing data.

- Calculate Coverage
-   Function: `cnvkit.py coverage`
-   Input: BAMs + target and antitarget BEDs 
-   Output: `.targetcoverage.cnn` and `.antitargetcoverage.cnn`
-   Script: `cnvkit_coverage.sh`

- Build Reference (Pool of normal samples)
-   Function: `cnvkit.py reference`
-   Input: Normal sample CNNs
-   Output: `*_reference.cnn`
-   Script: `cnvkit_normal_refs.sh`

- Run CNVkit Batch mode
-   Function: `cnvkit.py batch`
-   Input: treated or Tumor BAMs + `*_reference.cnn`
-   Output: `.cns`, `.cnr`, plots (defined by user)
-   Script: `cnvkit_batch.sh``

3. Input files

- Bam directory
-   `/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates/``
-   Each BAM must be **sorted**, **indexed**, and **duplicate-marked**

- Reference genome FASTA
-   `/home/lauterw/refs/human_hg38_UCSC/hg38.fa`

- Targets and anti-targets BED files (designed for your sequencing design):
-   `/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_targets_WIAB_IDPE.bed`
-   `/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_antitargets_WIAB_IDPE.bed`
-   `/home/lauterw/WIAB_IDPE/data/Illumina_Exome_TargetedRegions_v1.2.hg38.bed`

4. Pipeline

4.1 - Coverage Calculation
-   Script: cnvkit_coverage.sh
-   This step computes read coverage across target and antitarget regions for each sample.
-   OBS: Two coverage sets are generated: `RPE` and `P53_loss` groups.

4.2 - Build Reference
-   Script: `cnvkit_normal_refs.sh``
-   Builds a reference profile using normal/control samples.
-   The reference .cnn files are used as CNV baselines for treated/test samples.

4.3 - CNVkit Batch Processing
-   Script: `cnvkit_batch.sh`
-   Runs CNVkit’s main batch function to calculate copy ratios and visualize results.
-   `.cnr`: per-bin copy ratio data
-   `.cns`: segmented copy number profile
-   Output folders: `/results/WIAB_RPE_vs_RPE_ref/` and `/results/WIAB_P53_vs_P53_ref/`
-   OBS: Option `--drop-low-coverage` filters noisy bins

4.4 - CNV Calling
-   Script: `cnvkit_call.sh`
-   Calls discrete CN states (loss/neutral/gain/amplification) from .cns files.
-   Output `.call.cns` files with discrete CN calls
-   Adjusted `--purity` for tumor content estimation (Positive cells fractions - FISH calls)

5. Results

- Outputs
-   `.cnn` - Bin-level coverage (target and antitarget)
-   `.cnr` - Copy number ratios for all bins
-   `.cns` - Segmented copy number regions
-   `.call.cns` - CNV calls (loss/gain/amplification)
-   `.diagram.pdf` - Genome-wide visualization
-   `.scatter.pdf` - CNV scatter plots per sample

6. Interpreting CNVkit Results

- Copy ratio interpretation:

| log₂ Ratio | Approx. Copy Number | Biological Interpretation |
| ---------- | ------------------- | ------------------------- |
| ~0         | 2 copies (normal)   | Diploid                   |
| +0.58      | ~3 copies           | Gain                      |
| +1.0       | ~4 copies           | Amplification             |
| -0.58      | ~1 copy             | Heterozygous loss         |
| ≤ -1.0     | 0 copies            | Homozygous deletion       |

- Formula: Copy number≈2×2^(log2 ratio)
- File columns:
-   chromosome, start, end — Genomic coordinates
-   log2 — Log₂ copy ratio
-   cn — Estimated absolute copy number
-   depth — Bin coverage depth

7. Scripts summary

| Script                      | Purpose                                            |
| --------------------------- | -------------------------------------------------- |
| **`cnvkit_coverage.sh`**    | Calculates coverage across targets and antitargets |
| **`cnvkit_normal_refs.sh`** | Builds reference CNNs (equivalent to GATK PoN)     |
| **`cnvkit_batch.sh`**       | Runs CNVkit analysis pipeline for each sample      |
| **`cnvkit_call.sh`**        | Calls discrete CN states and filters low coverage  |
