### genome DB
/dir/to/ncbi-blast-2.15.0+/bin/makeblastdb -in genome.fasta -input_type fasta -dbtype nucl -title genome.fasta -out genome.fasta

### iglv
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGLV.fasta -outfmt 6 -out IGLV.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGLV.fasta > IGLV.fasta.len
python add-len-info.py IGLV.fasta.len IGLV.blast.out > IGLV.blast.out.1
less IGLV.blast.out.1 | awk '{if($3>=90) print $0}' > IGLV.blast.out.2
python filter-cover.py --blast IGLV.blast.out.2 --cover 0.9 > IGLV.blast.out.90
### filter uniq region
python filter.py IGLV.blast.out.90 > IGLV.blast.out.90.filter.1
less IGLV.blast.out.90.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGLV.blast.result

### iglj
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGLJ.fasta -outfmt 6 -out IGLJ.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGLJ.fasta > IGLJ.fasta.len
python add-len-info.py IGLJ.fasta.len IGLJ.blast.out > IGLJ.blast.out.1
less IGLJ.blast.out.1 | awk '{if($3>=90) print $0}' > IGLJ.blast.out.2
python filter-cover.py --blast IGLJ.blast.out.2 --cover 0.9 > IGLJ.blast.out.90
#### select best one
python -m jcvi.formats.blast best -n 1 IGLJ.blast.out.90
#### filter uniq region
python filter.py IGLJ.blast.out.best > IGLJ.blast.out.best.filter.1
less IGLJ.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGLJ.blast.result

###iglc
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGLC.fasta -outfmt 6 -out IGLC.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGLC.fasta > IGLC.fasta.len
python add-len-info.py IGLC.fasta.len IGLC.blast.out > IGLC.blast.out.1
less IGLC.blast.out.1 | awk '{if($3>=90) print $0}' > IGLC.blast.out.2
python filter-cover.py --blast IGLC.blast.out.2 --cover 0.9 > IGLC.blast.out.90
#### select best one
python -m jcvi.formats.blast best -n 1 IGLC.blast.out
#### filter uniq region
python filter.py IGLC.blast.out.best > IGLC.blast.out.best.filter.1
less IGLC.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGLC.blast.result
