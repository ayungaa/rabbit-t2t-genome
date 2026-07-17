### 
makeblastdb -in genome.fasta -input_type fasta -dbtype nucl -title genome.fasta -out genome.fasta
blastn -db genome.fasta -query /dir/to/Genbank-KY962518.1/rDNA.fasta -outfmt 6 -out rDNA.blast.out -num_threads 64 -evalue 1e-10
less rDNA.blast.out | awk '$3 >= 85 && $4 >= 1000' > rDNA.blast.out.filtered
