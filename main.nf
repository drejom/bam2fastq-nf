#!/usr/bin/env nextflow

/*
 * Copyright (c) City of Hope and the authors.
 *
 *   This file is part of 'bam2fastq-nf'.
 *
 *   bam2fastq-nf is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   bam2fastq-nf is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with bam2fastq-nf.  If not, see <http://www.gnu.org/licenses/>.
 */

/* 
 * Main bam2fastq-nf pipeline script
 *
 * @authors
 * Denis O'Meally <domeally.coh.org>
 */


log.info "bam2fastq - N F  ~  version 0.1"
log.info "====================================="
log.info "name                   : ${params.name}"
log.info "BAM files              : ${params.bams}"
log.info "output                 : ${params.output}"
log.info "\n"

/*
 * Create a channel for BAM files 
 */
 
bams_sorting = Channel
    .fromPath( params.bams)
    .ifEmpty { exit 1, "Cannot find any BAMs matching: ${params.bams}" }
    .map { file -> tuple(file.baseName, file) }
/*
 * STEP 1 - Sort BAMs by read name and pipe to samtools fastq
 */
process sort_bams_to_fastq {
    tag "$name"
    container "quay.io/biocontainers/samtools:1.9--h10a08f8_12"
    //module 'samtools/1.6'
    cpus 2

    publishDir "${params.output}", mode: 'copy'

    input:
    set name, file(bam) from bams_sorting

    output:
    set val(name), file("*_R*.fastq.gz") into read_pairs_fastqc

    script:
    """
    samtools sort -@ ${task.cpus} -n ${bam} | samtools fastq -1 ${name}_R1.fastq.gz -2 ${name}_R2.fastq.gz -0 ${name}_R0.fastq.gz -s /dev/null -N -F 0x900 -
    """
}

/*
 * FastQC
 */

process fastqc {
    tag "$name"
    container "quay.io/biocontainers/fastqc:0.11.8--1"
    cpus 2
    memory 2.GB

    //publishDir "${params.output}/fastqc_rawdata", mode: 'copy',
    //    saveAs: {filename -> filename.indexOf(".zip") > 0 ? "zips/$filename" : "$filename"}

    input:
    set val(name), file(reads) from read_pairs_fastqc

    output:
    file "*_fastqc.{zip,html}" into fastqc_results

    script:
    """
    fastqc -q $reads
    """
}

process multiqc {

    container "ewels/multiqc:1.7"

    publishDir "${params.output}/MultiQC", mode: 'copy'

    input:
    file ('fastqc/*') from fastqc_results.collect().ifEmpty([])
    
    output:
    file "*multiqc_report.html" into multiqc_report
    file "*_data"

    script:
    """
    multiqc . 
    """
}
