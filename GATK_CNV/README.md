## Configuring GATK for CNV analysis

1.  Load modules in the HPC

    1.  check modules

    2.  `module avail`

    3.  Load:

```         
module purge
module load openjdk/17.0.8.1_1-gcc-13.1.0
module load gatk/4.4.0.0-gcc-13.1.0
```

-   Check env:

```         
gatk --list
```

2.  Workflow Plan:

    -   Preprocess Target Intervals

        -   Function: `PreprocessIntervals`\`

        -   Generate the interval list that defines the regions for counting reads

        -   Input: Illumina target BED file and ref genome FASTA

        -   Output: `targets/preprocessed_intervals.interval_list`

    -   Annotate Intervals

        -   Function: AnnotateIntervals

        -   Add GC content and mappability data to the intervals

        -   Input: ref genome FASTA and list of `targets/preprocessed_intervals.interval_list`

        -   Output: \`targets/annotated_intervals.tsv\`\`

    -   Collect Read Counts (All Samples)

        -   Function: CollectReadCounts

        -   Generate read count files for all your BAMs — both normal and treated

        -   Input: BAM files

        -   Output: `.counts.hdf5`

    -   Create Panel of Normals (PoN)

        -   Function: CreateReadCountPanelOfNormals

        -   Use only the normal samples to build the PoN

        -   Input: Normal `normal/*.counts.hdf5`

        -   Output: `pon/pon.hdf5`

    -   Denoise Read Counts (Treated Samples)

        -   Function: DenoiseReadCounts

        -   Use the PoN to remove systematic noise from treated samples

        -   Input: `treated/*.counts.hdf5`

        -   Output: `denoised/treated1.standardizedCR.tsv` and `denoised/treated1.denoisedCR.tsv`

    -   Model Segments (Identify CNVs)

        -   Function: ModelSegments

        -   Combine denoised copy ratios to segment data

        -   Input: `denoised/treated1.standardizedCR.tsv`

        -   Output: `segments/treated1/treated1.modelFinal.seg` and `segments/treated1/treated1.cr.seg`

        -   Obs: For case where SNP is not available, omit the `--allelic-counts` argument

    -   Call Copy Ratio Segments

        -   Function: CallCopyRatioSegments

        -   Classify segments into deletions, neutral, or amplifications

        -   Input: `segments/treated1/treated1.modelFinal.seg`

        -   Output: `segments/treated1/treated1.called.seg`

3.  Pipeline

-   Preprocess and annotate Target Intervals

    -   Obs: GATK requires a FASTA dictionary file (.dict) alongside your reference FASTA (.fa)

    -   Solve: Run `gatk CreateSequenceDictionary` in ref folder.

    -   Output in the same location

    -   Obs 2: Add the same argument, `--interval-merging-rule OVERLAPPING_ONLY` to AnnotateIntervals call

    -   script: `GATK_process_intervals.sh`

```         
gatk CreateSequenceDictionary \
    -R /home/lauterw/refs/human_hg38_UCSC/hg38.fa \
    -O /home/lauterw/refs/human_hg38_UCSC/hg38.dict
```

-    Collect Read Counts

    -   script: `GATK_collect_counts.sh`

    -   OBS: Add the same argument, `--interval-merging-rule OVERLAPPING_ONLY` to CollectReadCounts

-   Create Panel of Normals (PoN)

    -   script: `GATK_panel_of_normals.sh`

-   Denoise Read Counts

    -   script: `GATK_denoise.sh`

-   Model Segments

-   script: `GATK_model_seg_call_CNV.sh`

-   Best Practices:

    -   No allelic counts - only use `--denoised-copy-ratios`

    -   Target seq, more noise - use `--number-of-changepoints-penalty-factor 2.0`

    -   Running with default and optmized parameters

-   Results:

    -   `modelBegin.seg.` Initial segmentation before smoothing. From `ModelSegments` — diagnostic

    -   `.modelFinal.seg` Final smoothed segmentation. From `ModelSegments` — key segmentation output.
<<<<<<< Updated upstream
=======

    -   `.modelBegin.af.param`, `.modelBegin.cr.param`- Posterior parameter summaries (Initial). Used for QC, advanced modeling checks.

    -   `.modelFinal.af.param`, `.modelFinal.cr.param`. Posterior parameter summaries (final). Reflect refined model fit.

    -   `.cr.seg`. **Copy-ratio segments**. Input to `CallCopyRatioSegments`.

    -   `.cr.igv.seg`, `.af.igv.seg`. IGV-formatted copy ratio / allele fraction segments. Load directly in IGV for visualization.

    -   `.called.seg`. **Final called copy ratio segments** (loss/neutral/gain/amplification). Main biological output.

    -   `.called.igv.seg`. Same, formatted for IGV. For CNV inspection across samples.
>>>>>>> Stashed changes

    -   `.modelBegin.af.param`, `.modelBegin.cr.param`- Posterior parameter summaries (Initial). Used for QC, advanced modeling checks.

<<<<<<< Updated upstream
    -   `.modelFinal.af.param`, `.modelFinal.cr.param`. Posterior parameter summaries (final). Reflect refined model fit.

    -   `.cr.seg`. **Copy-ratio segments**. Input to `CallCopyRatioSegments`.

    -   `.cr.igv.seg`, `.af.igv.seg`. IGV-formatted copy ratio / allele fraction segments. Load directly in IGV for visualization.

    -   `.called.seg`. **Final called copy ratio segments** (loss/neutral/gain/amplification). Main biological output.

    -   `.called.igv.seg`. Same, formatted for IGV. For CNV inspection across samples.

<!-- -->

=======
>>>>>>> Stashed changes
-   Interpretation of results table

    -   Example: Copy number ≈ 2 × 2\^(mean_log2_copy_ratio). mean_log2_copy_ratio = 1.826993. Copy number ≈ 2 × 2\^(1.826993) ≈ 7.1 copies

-   Table:

|                      |                     |                     |
|----------------------|---------------------|---------------------|
| MEAN_LOG2_COPY_RATIO | Approx. Copy Number | Interpretation      |
| \~0                  | 2 copies (normal)   | Diploid             |
| +0.58                | \~3 copies          | Gain                |
| +1.0                 | \~4 copies          | Amplification       |
| -0.58                | \~1 copy            | Heterozygous loss   |
| ≤ -1.0               | 0 copies            | Homozygous deletion |

-   **CONTIG** - Chromosome

-   **START, END** - Coordinates of the CNV segment

-   **NUM_POINTS_COPY_RATIO** - Number of bins used to define this segment

-   **MEAN_LOG2_COPY_RATIO** - The log₂ ratio of tumor/normal coverage. - 0 → normal copy (2 copies) - positive → gain/amplification - negative → loss/deletion

-   The **copy ratio** is a normalized measure of how many copies of a genomic region are present relative to the expected number.

-   In diploid regions (normal), the expected copy number is **2**

-   If the copy ratio is **1**, it usually corresponds to **2 copies** (normal)

-   A **copy ratio \< 1** indicates a deletion (fewer copies), and **\> 1** indicates a gain (more copies)
