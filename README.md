# bam2fastq-nf

The pipeline converts unmapped BAMs downloaded from the European Genome-Phenome Archive. It takes files from `../data/bam/*.bam` and converts them into fastq files, runs FastQC and produces a MultiQC report in `../data/fastq`.

This follows the `samtools fastq` man page by first sorting by name (`-n`), then piping to `samtools fastq`. If the reads are paired, forward and reverse reads are emitted to `*_R1.fastq.gz` and `*_R2.fastq.gz` respectively. Read names are appended with `/1` and `/2` (`-N`). Singletons (unmatched reads) are discarded. When reads are single-ended, they are emitted to `*_R0.fastq.gz`. 

``` bash
    samtools sort -@ ${task.cpus} -n ${bam} | samtools fastq -1 ${name}_R1.fastq.gz -2 ${name}_R2.fastq.gz -0 ${name}_R0.fastq.gz -s /dev/null -N -F 0x900 -
```

To run the pipeline, make sure `nextflow` and `singularity` are available in the `$PATH`, then:

``` bash
nextflow run drejom/bam2fastq-nf
```

The input locations can be changed at runtime by setting  `--bams`  to a quoted, globbed, relative or absolute path (eg `--bams 'downloads/*.bam'`); similarly the location of the output can be set with the `--output` parameter.
