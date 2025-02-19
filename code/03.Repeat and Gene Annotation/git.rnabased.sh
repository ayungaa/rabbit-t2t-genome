wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz
/dir/to/diamond makedb --in uniprot_sprot.fasta --db uniprot_sprot.fasta

### Hisat2 ###
/dir/to/hisat2-build  genome.fasta  ./index/genome.fasta.hisat -p 20
/dir/to/hisat2 -p 64 \
 -x /dir/to/genome.fasta.hisat \
 -1 /dir/to/rnaTissue_R1.fq.gz \
 -2 /dir/to/rnaTissue_R2.fq.gz \
 | samtools sort -@ 64 -o genome.fasta.bam 

/dir/to/stringtie -p 64 -o stringtie_merged.gtf -l genome.fasta genome.fasta.bam
/dir/to/transdecoder/bin/gtf_genome_to_cdna_fasta.pl ./stringtie_merged.gtf ./genome.fasta > merged_stringtie_transdecoder.fa
/dir/to/transdecoder/bin/TransDecoder.LongOrfs -t merged_stringtie_transdecoder.fa
/dir/to/diamond blastp -d ./uniprot_sprot.fasta -q ./merged_stringtie_transdecoder.fa.transdecoder_dir/longest_orfs.pep --evalue 1e-5 --max-target-seqs 1 > blastp.outfmt6
/dir/to/transdecoder/bin/gtf_to_alignment_gff3.pl ./stringtie_merged.gtf > stringtie_merged.gff3
/dir/to/transdecoder/bin/TransDecoder.Predict -t merged_stringtie_transdecoder.fa --retain_blastp_hits blastp.outfmt6
/dir/to/transdecoder/bin/cdna_alignment_orf_to_genome_orf.pl \
 merged_stringtie_transdecoder.fa.transdecoder.gff3 \
 stringtie_merged.gff3 \
 merged_stringtie_transdecoder.fa > rna_based.gff3
