# bam2fastq-nf

This pipeline takes BAMs and converts them into fastq files, runs FastQC and produces a MultiQC report.

The command follows the `samtools fastq` man page by first sorting by name (`-n`), then piping to `samtools fastq`. If the reads are paired, forward and reverse reads are emitted to `*R2.fastq.gz` and `*R2.fastq.gz` respectively. Read names are appended with `/1` and `/2` (`-N`). Single-end reads are emitted to `*R0.fastq.gz`.

``` bash
    samtools sort -@ ${task.cpus} -n ${bam} | samtools fastq -1 ${name}_R1.fastq.gz -2 ${name}_R2.fastq.gz -0 ${name}_R0.fastq.gz -s /dev/null -N -F 0x900 -
```
