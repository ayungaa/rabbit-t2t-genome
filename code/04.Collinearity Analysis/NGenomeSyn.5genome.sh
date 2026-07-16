#!/bin/bash

GENOMES=("orycun2" "orycun3" "umnzw1" "morycun1.1")
OUTPUT_DIR="./syn_output"                        
TOOL="/dir/to/NGenomeSyn/bin/GetTwoGenomeSyn.pl" 
MAPPING_BIN="minimap2"                           
MIN_LEN_A=1000                                   
MIN_LEN_B=1000                                  

mkdir -p "$OUTPUT_DIR"

for GENOME in "${GENOMES[@]}"; do
  for CHR in chr{1..21} chrX; do 
    INPUT_A="${GENOME}.${CHR}.fasta"
    INPUT_B="genome.${CHR}.fasta"
    PREFIX="${OUTPUT_DIR}/${GENOME}-vs-genome-${CHR}"
    perl "$TOOL" -InGenomeA "$INPUT_A" -InGenomeB "$INPUT_B" \
      -OutPrefix "$PREFIX" -MappingBin "$MAPPING_BIN" \
      -MinLenA "$MIN_LEN_A" -MinLenB "$MIN_LEN_B"
  done
done
