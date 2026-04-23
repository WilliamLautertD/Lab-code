#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process FASTQC_RAW {
    tag "${meta.id}"
    publishDir "${params.outdir}/qc/raw/${meta.id}", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}.raw_fastqc.done")
    path("*_fastqc.html"), emit: html
    path("*_fastqc.zip"), emit: zip

    script:
    """
    fastqc -t ${task.cpus} ${reads}
    touch ${meta.id}.raw_fastqc.done
    """

    stub:
    """
    touch ${meta.id}.raw_fastqc.done
    touch ${meta.id}_R1_fastqc.html ${meta.id}_R1_fastqc.zip
    touch ${meta.id}_R2_fastqc.html ${meta.id}_R2_fastqc.zip
    """
}

process FASTP_TRIM {
    tag "${meta.id}"
    publishDir "${params.outdir}/fastq_trimmed", mode: 'copy'

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}.trimmed.R1.fastq.gz"), path("${meta.id}.trimmed.R2.fastq.gz"), emit: trimmed
    path("${meta.id}.fastp.html"), emit: html
    path("${meta.id}.fastp.json"), emit: json

    script:
    """
    fastp \
      --in1 ${r1} \
      --in2 ${r2} \
      --out1 ${meta.id}.trimmed.R1.fastq.gz \
      --out2 ${meta.id}.trimmed.R2.fastq.gz \
      --html ${meta.id}.fastp.html \
      --json ${meta.id}.fastp.json \
      --thread ${task.cpus} \
      ${params.fastp_extra}
    """

    stub:
    """
    touch ${meta.id}.trimmed.R1.fastq.gz
    touch ${meta.id}.trimmed.R2.fastq.gz
    touch ${meta.id}.fastp.html
    touch ${meta.id}.fastp.json
    """
}

process FASTQC_TRIMMED {
    tag "${meta.id}"
    publishDir "${params.outdir}/qc/trimmed/${meta.id}", mode: 'copy'

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}.trimmed_fastqc.done")
    path("*_fastqc.html"), emit: html
    path("*_fastqc.zip"), emit: zip

    script:
    """
    fastqc -t ${task.cpus} ${r1} ${r2}
    touch ${meta.id}.trimmed_fastqc.done
    """

    stub:
    """
    touch ${meta.id}.trimmed_fastqc.done
    touch ${meta.id}.trimmed.R1_fastqc.html ${meta.id}.trimmed.R1_fastqc.zip
    touch ${meta.id}.trimmed.R2_fastqc.html ${meta.id}.trimmed.R2_fastqc.zip
    """
}

process BWA_MEM_FILTER {
    tag "${meta.id}"
    publishDir "${params.outdir}/mapping/bam", mode: 'copy'

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}.filtered.bam"), path("${meta.id}.filtered.bam.bai"), path("${meta.id}.flagstat.tsv"), emit: bam

    script:
    def ref = params.bwa_index_prefix ?: params.reference_fasta
    """
    bwa mem -t ${task.cpus} ${ref} ${r1} ${r2} \
      | samtools collate -@ ${task.cpus} -O -u - \
      | samtools fixmate -@ ${task.cpus} -m -u - - \
      | samtools sort -@ ${task.cpus} -u - \
      | samtools markdup -@ ${task.cpus} - - \
      | samtools view -@ ${task.cpus} -b -q ${params.min_mapq} -F ${params.exclude_flags} - \
      | samtools sort -@ ${task.cpus} -o ${meta.id}.filtered.bam -

    samtools index -@ ${task.cpus} ${meta.id}.filtered.bam
    samtools flagstat -@ ${task.cpus} -O tsv ${meta.id}.filtered.bam > ${meta.id}.flagstat.tsv
    """

    stub:
    """
    touch ${meta.id}.filtered.bam
    touch ${meta.id}.filtered.bam.bai
    touch ${meta.id}.flagstat.tsv
    """
}

process BAM_COVERAGE {
    tag "${meta.id}"
    publishDir "${params.outdir}/coverage/bigwig", mode: 'copy'

    input:
    tuple val(meta), path(bam), path(bai), path(flagstat)

    output:
    tuple val(meta), path("${meta.id}.bw"), emit: bw

    script:
    def blacklist = params.blacklist_bed ? "--blackListFileName ${params.blacklist_bed}" : ''
    """
    bamCoverage \
      --bam ${bam} \
      --outFileName ${meta.id}.bw \
      --outFileFormat bigwig \
      --binSize ${params.bigwig_binsize} \
      --normalizeUsing ${params.bigwig_normalization} \
      --effectiveGenomeSize ${params.effective_genome_size} \
      --numberOfProcessors ${task.cpus} \
      ${blacklist}
    """

    stub:
    """
    touch ${meta.id}.bw
    """
}

process MULTIQC {
    publishDir "${params.outdir}/qc", mode: 'copy'

    input:
    path qc_inputs

    output:
    path 'multiqc_report.html', emit: report

    script:
    """
    multiqc . --filename multiqc_report.html
    """

    stub:
    """
    touch multiqc_report.html
    """
}

workflow {
    samples_ch = Channel
        .fromPath(params.samples)
        .splitCsv(header: true, sep: '\t')
        .map { row ->
            def sampleId = row.sample?.trim()
            if (!sampleId) {
                error "Each row in ${params.samples} must include a non-empty 'sample' value"
            }
            if (!row.fastq_r1 || !row.fastq_r2) {
                error "Sample ${sampleId} is missing fastq_r1 or fastq_r2"
            }

            def meta = [
                id: sampleId,
                condition: row.condition ?: 'unspecified',
                replicate: row.replicate ?: '1',
                library: row.read_group_library ?: 'lib1',
                unit: row.read_group_unit ?: 'unit1'
            ]
            tuple(meta, file(row.fastq_r1), file(row.fastq_r2))
        }

    raw_reads_ch = samples_ch.map { meta, r1, r2 -> tuple(meta, [r1, r2]) }

    FASTQC_RAW(raw_reads_ch)
    FASTP_TRIM(samples_ch)
    FASTQC_TRIMMED(FASTP_TRIM.out.trimmed)
    BWA_MEM_FILTER(FASTP_TRIM.out.trimmed)

    if (params.make_bigwig) {
        BAM_COVERAGE(BWA_MEM_FILTER.out.bam)
    }

    multiqc_inputs = FASTQC_RAW.out.html
        .mix(FASTQC_RAW.out.zip)
        .mix(FASTQC_TRIMMED.out.html)
        .mix(FASTQC_TRIMMED.out.zip)
        .mix(FASTP_TRIM.out.html)
        .mix(FASTP_TRIM.out.json)
        .mix(BWA_MEM_FILTER.out.bam.map { meta, bam, bai, flagstat -> flagstat })
        .collect()

    MULTIQC(multiqc_inputs)
}
