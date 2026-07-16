#!/bin/bash

# genome
GENOMES=("orycun2" "orycun3" "umnzw1" "morycun1.1")

# genes
BLAST_GENES=("IGHV" "IGHD" "IGHJ" "IGHC" "IGKV" "IGKJ" "IGKC" "IGLV" "IGLJ" "IGLC")
MINIMAP_GENES=("MHC-I" "MHC-II")

# para
COV_HIGH=0.95
COV_PARTIAL=0.1
IDT_PERFECT=95
TOLERANCE=0
NUM_THREADS=64

for gene in "${BLAST_GENES[@]}" "${MINIMAP_GENES[@]}"; do
  less "${gene}.fasta" | grep ">" | sed 's/>//g' > query.id

  for genome in "${GENOMES[@]}"; do
    if [[ " ${BLAST_GENES[*]} " =~ " ${gene} " ]]; then
      blastn -db "${genome}.fasta" \
             -query "${gene}.fasta" \
             -outfmt 6 \
             -out "${genome}.${gene}.blast.out" \
             -num_threads $NUM_THREADS
      python add-len-info.py "${gene}.fasta.len" "${genome}.${gene}.blast.out" > "${genome}.${gene}.blast.out.1"
    elif [[ " ${MINIMAP_GENES[*]} " =~ " ${gene} " ]]; then
      minimap2 -c -x asm5 "${genome}.fasta" "${gene}.fasta" > "${genome}.${gene}.paf"
      python paf2blast6.py -i "${genome}.${gene}.paf" -o "${genome}.${gene}.out"
      python add-len-info.py "${gene}.fasta.len" "${genome}.${gene}.out" > "${genome}.${gene}.out.1"
    fi

    python statistics-step1.py \
           -i "${genome}.${gene}.blast.out.1" \
           -q query.id \
           -o "${genome}.${gene}" \
           --cov-high $COV_HIGH \
           --cov-partial $COV_PARTIAL \
           --idt-perfect $IDT_PERFECT \
           --tolerance $TOLERANCE
    python statistics-step2.py \
           -i "${genome}.${gene}_assembly_evaluation.tsv" \
           -o "${genome}.${gene}_assembly_evaluation.tsv.1"
    python statistics-step3.py \
           -i "${genome}.${gene}_assembly_evaluation.tsv.1" \
           -o "${genome}.${gene}_assembly_evaluation.table"
  done
done
