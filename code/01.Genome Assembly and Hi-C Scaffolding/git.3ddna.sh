#!/bin/bash
mkdir tmp

export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/dir/to/tmp -XX:ParallelGCThreads=10"
export TMPDIR=/dir/to/tmp
conda activate juicer-3ddna
/dir/to/3d-dna/run-asm-pipeline.sh -r 0 ./genome.fasta ./merged_nodups.txt &> 3d.log
