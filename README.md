# bam2fastq-nf

The pipeline takes BAMs from `../data/bam/*.bam` and converts them into fastq files, runs FastQC and produces a MultiQC report in `../data/fastq`.

The command follows the `samtools fastq` man page by first sorting by name (`-n`), then piping to `samtools fastq`. If the reads are paired, forward and reverse reads are emitted to `*R1.fastq.gz` and `*R2.fastq.gz` respectively. Read names are appended with `/1` and `/2` (`-N`). Single-end reads are emitted to `*R0.fastq.gz`. Singletons (unmatched reads) are discarded.

``` bash
    samtools sort -@ ${task.cpus} -n ${bam} | samtools fastq -1 ${name}_R1.fastq.gz -2 ${name}_R2.fastq.gz -0 ${name}_R0.fastq.gz -s /dev/null -N -F 0x900 -
```

To run the pipeline, make sure `nextflow` and `singularity` are available, then:

``` bash
nextflow run drejom/bam2fastq-nf
```
