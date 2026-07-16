#!/bin/bash

REFERENCE="genome.fasta" 
QUERIES=("orycun2.fasta" "orycun3.fasta" "umnzw1.fasta" "morycun1.1.fasta")
CHR_COUNT=22

WINNOWMAP_BIN="winnowmap"
PAFTOOLS_BIN="paftools.js"
SEQKIT_BIN="seqkit"
BEDTOOLS_BIN="bedtools"
OUTPUT_DIR="./analysis_output"
mkdir -p "$OUTPUT_DIR"

$SEQKIT_BIN fx2tab --name --length "$REFERENCE" > "${OUTPUT_DIR}/genome.fasta.len"
for QUERY in "${QUERIES[@]}"; do
    BASENAME=$(basename "$QUERY" .fasta)
    echo "Processing $QUERY against $REFERENCE..."
    $WINNOWMAP_BIN -ax asm20 -t 64 -H --MD "$REFERENCE" "$QUERY" > "${OUTPUT_DIR}/${BASENAME}.sam"
    $PAFTOOLS_BIN sam2paf -p "${OUTPUT_DIR}/${BASENAME}.sam" > "${OUTPUT_DIR}/${BASENAME}.paf"
    cat "${OUTPUT_DIR}/${BASENAME}.paf" | awk '{if ($12 > 0) print $6"\t"$8"\t"$9}' \
        | $BEDTOOLS_BIN sort -i - | $BEDTOOLS_BIN merge -i - | sort -V > "${OUTPUT_DIR}/${BASENAME}.mapped.region"
    cat "${OUTPUT_DIR}/${BASENAME}.paf" | awk '{if ($12 > 0) print $6"\t"$8"\t"$9}' \
        | $BEDTOOLS_BIN sort -i - | $BEDTOOLS_BIN merge -i - | sort -V \
        | $BEDTOOLS_BIN complement -i - -g "${OUTPUT_DIR}/genome.fasta.len" > "${OUTPUT_DIR}/${BASENAME}.previous.unassembled.region"
    ABSENT_LEN_FILE="${OUTPUT_DIR}/absent.in.${BASENAME}.len"
    > "$ABSENT_LEN_FILE"
    for i in $(seq 1 21) chrX; do
        cat "${OUTPUT_DIR}/${BASENAME}.previous.unassembled.region" | grep -w "chr$i" | awk '{print $3-$2}' \
            | awk '{sum+=$1} END {print sum}' >> "$ABSENT_LEN_FILE"
    done
done
