## chr19
python universal_stitch.py \
  --donor_seq verkko.chr19.fasta \
  --main_seq hifiasm.chr19.fasta \
  --out Filled-CHR19.fasta \
  --min_aln_len 500000 \
  --min_mapq 60 \
  --trim_edge 10000 \
  --keep_tmp \
  --aln-x asm5 \
  --aln-t 16 \
  --aln-k 27 \
  --aln-secondary no

## chrX
python universal_stitch.py \
  --donor_seq verkko.chrX.fasta \
  --main_seq hifiasm.chrX.fasta \
  --out Filled-CHRX.fasta \
  --min_aln_len 500000 \
  --min_mapq 60 \
  --trim_edge 10000 \
  --keep_tmp \
  --aln-x asm5 \
  --aln-t 16 \
  --aln-k 27 \
  --aln-secondary no
