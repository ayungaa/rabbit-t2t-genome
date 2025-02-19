### genome DB
/dir/to/ncbi-blast-2.15.0+/bin/makeblastdb -in genome.fasta -input_type fasta -dbtype nucl -title genome.fasta -out genome.fasta

### IGKV
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGKV.fasta -outfmt 6 -out IGKV.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGKV.fasta > IGKV.fasta.len
python add-len-info.py IGKV.fasta.len IGKV.blast.out > IGKV.blast.out.1
less IGKV.blast.out.1 | awk '{if($3>=90) print $0}' > IGKV.blast.out.2
python filter-cover.py --blast IGKV.blast.out.2 --cover 0.9 > IGKV.blast.out.90
### filter uniq region
python filter.py IGKV.blast.out.90 > IGKV.blast.out.90.filter.1
less IGKV.blast.out.90.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGKV.blast.result

### IGKJ
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGKJ.fasta -outfmt 6 -out IGKJ.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGKJ.fasta > IGKJ.fasta.len
python add-len-info.py IGKJ.fasta.len IGKJ.blast.out > IGKJ.blast.out.1
less IGKJ.blast.out.1 | awk '{if($3>=90) print $0}' > IGKJ.blast.out.2
python filter-cover.py --blast IGKJ.blast.out.2 --cover 0.9 > IGKJ.blast.out.90
### select best one
python -m jcvi.formats.blast best -n 1 IGKJ.blast.out
###filter uniq region
python filter.py IGKJ.blast.out.best > IGKJ.blast.out.best.filter.1
less IGKJ.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGKJ.blast.result

### IGKC
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGKC.fasta -outfmt 6 -out IGKC.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGKC.fasta > IGKC.fasta.len
python add-len-info.py IGKC.fasta.len IGKC.blast.out > IGKC.blast.out.1
less IGKC.blast.out.1 | awk '{if($3>=90) print $0}' > IGKC.blast.out.2
python filter-cover.py --blast IGKC.blast.out.2 --cover 0.9 > IGKC.blast.out.90
#### select best one
python -m jcvi.formats.blast best -n 1 IGKC.blast.out
### filter uniq region
python filter.py IGKC.blast.out.best > IGKC.blast.out.best.filter.1
less IGKC.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGKC.blast.result

