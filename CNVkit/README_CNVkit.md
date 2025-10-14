## CNKit Copy Number Analysis Pipeline (CNVkit-based)

1.  Environment Setup

-   Load required modules (HPC environment)
-   Before running any CNVkit scripts, make sure the environment is properly configured.
-   Check available modules:

```         
module avail
```

-   Load modules:

```         
module purge
module load python/3.10.13-gcc-13.1.0
module load cnvkit/0.9.10-gcc-13.1.0
module load picard/3.2.0-gcc-13.1.0
```

2.  Workflow Overview
    2.  The CNKit pipeline uses CNVkit to perform copy number variation (CNV) analysis on exome or targeted sequencing data.
3.  Calculate Coverage
    2.  Function: `cnvkit.py coverage`
    3.  Input: BAMs + target and antitarget BEDs
    4.  Output: `.targetcoverage.cnn` and `.antitargetcoverage.cnn`
    5.  Script: `cnvkit_coverage.sh`
4.  Build Reference (Pool of normal samples)
    2.  Function: `cnvkit.py reference`
    3.  Input: Normal sample CNNs
    4.  Output: `*_reference.cnn`
    5.  Script: `cnvkit_normal_refs.sh`
5.  Run CNVkit Batch mode
    2.  Function: `cnvkit.py batch`
    3.  Input: treated or Tumor BAMs + `*_reference.cnn`
    4.  Output: `.cns`, `.cnr`, plots (defined by user)
    5.  Script: \`cnvkit_batch.sh\`\`
6.  Input files
    2.  Bam directory

        -   \`/home/lauterw/WIAB_IDPE/results/bwa_output/marked_duplicates/\`\`

        2.  Each BAM must be **sorted**, **indexed**, and **duplicate-marked**
7.  Reference genome FASTA
    2.  `/home/lauterw/refs/human_hg38_UCSC/hg38.fa`
    3.  Targets and anti-targets BED files (designed for your sequencing design):
    4.  `/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_targets_WIAB_IDPE.bed`
    5.  `/home/lauterw/WIAB_IDPE/results/cnaKit/inter_files/my_antitargets_WIAB_IDPE.bed`
    6.  `/home/lauterw/WIAB_IDPE/data/Illumina_Exome_TargetedRegions_v1.2.hg38.bed`

<!-- -->

4.  Pipeline
    -   Coverage Calculation
    -   Script: cnvkit_coverage.sh
    -   This step computes read coverage across target and antitarget regions for each sample.
    -   OBS: Two coverage sets are generated: `RPE` and `P53_loss` groups.

-   Build Reference

    -   Script: \`cnvkit_normal_refs.sh\`

    -   Builds a reference profile using normal/control samples.

    -   The reference .cnn files are used as CNV baselines for treated/test samples.

-   CNVkit Batch Processing

    -   Script: `cnvkit_batch.sh`

    -   Runs CNVkit’s main batch function to calculate copy ratios and visualize results.

    -   `.cnr`: per-bin copy ratio data

    -   `.cns`: segmented copy number profile

    -   Output folders: `/results/WIAB_RPE_vs_RPE_ref/` and `/results/WIAB_P53_vs_P53_ref/`

    -   OBS: Option `--drop-low-coverage` filters noisy bins

-   CNV Calling

    -   Script: `cnvkit_call.sh`

    -   Calls discrete CN states (loss/neutral/gain/amplification) from .cns files.

    -   Output `.call.cns` files with discrete CN calls

    -   Adjusted `--purity` for tumor content estimation (Positive cells fractions - FISH calls)

5.  Results

-   Outputs

    -   `.cnn` - Bin-level coverage (target and antitarget)

    -   `.cnr` - Copy number ratios for all bins

    -   `.cns` - Segmented copy number regions

    -   `.call.cns` - CNV calls (loss/gain/amplification)

    -   `.diagram.pdf` - Genome-wide visualization

    -   `.scatter.pdf` - CNV scatter plots per sample

6.  Interpreting CNVkit Results
    6.  Copy ratio interpretation:

| log₂ Ratio | Approx. Copy Number | Biological Interpretation |
|------------|---------------------|---------------------------|
| \~0        | 2 copies (normal)   | Diploid                   |
| +0.58      | \~3 copies          | Gain                      |
| +1.0       | \~4 copies          | Amplification             |
| -0.58      | \~1 copy            | Heterozygous loss         |
| ≤ -1.0     | 0 copies            | Homozygous deletion       |

-   Formula: Copy number≈2×2\^(log2 ratio)

    -   File columns:

    -   chromosome, start, end — Genomic coordinates

    -   log2 — Log₂ copy ratio

    -   cn — Estimated absolute copy number

    -   depth — Bin coverage depth

7.  Scripts summary

| Script | Purpose |
|--------------------------|----------------------------------------------|
| **`cnvkit_coverage.sh`** | Calculates coverage across targets and antitargets |
| **`cnvkit_normal_refs.sh`** | Builds reference CNNs (equivalent to GATK PoN) |
| **`cnvkit_batch.sh`** | Runs CNVkit analysis pipeline for each sample |
| **`cnvkit_call.sh`** | Calls discrete CN states and filters low coverage |



### October 13th

-   Generate gene metrics with following thresholds

    -   threshold (log₂ Ratio) > 1 = >\~4 copies
    -   `cnvkit.py genemetrics <WIAB_IDPE_?.call.cns> -s <WIAB_IDPE_?.marked.cns> -t 1 -m 5 -o WIAB_IDPE_genemetrics_t_1.txt -x x`
    -   `WIAB_IDPE_P53_treated_GeneMetrics_t_1.xlsx` - Genemetrics results for P53-/- treated with SETD2i
    -   `WIAB_IDPE_RPE_treated_GeneMetrics_t_1.xlsx` - Genemetrics results for RPE treated with SETD2i
    -   `WIAB_IDPE_vs_hg38_GeneMetrics_t_1.xlsx` - Genemetrics results for P53-/- and RPE treated with SETD2i vs hg38
    -   Generated list analysis using `https://molbiotools.com/listcompare.php`
    -   Lists saved in cnvkit results `