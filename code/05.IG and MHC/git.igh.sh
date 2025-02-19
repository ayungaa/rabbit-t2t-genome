### genome DB
/dir/to/ncbi-blast-2.15.0+/bin/makeblastdb -in genome.fasta -input_type fasta -dbtype nucl -title genome.fasta -out genome.fasta

### ighv
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGHV.fasta -outfmt 6 -out IGHV.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGHV.fasta > IGHV.fasta.len
python add-len-info.py IGHV.fasta.len IGHV.blast.out > IGHV.blast.out.1
less IGHV.blast.out.1 | awk '{if($3>=90) print $0}' > IGHV.blast.out.2
python filter-cover.py --blast IGHV.blast.out.2 --cover 0.9 > IGHV.blast.out.90
### filter uniq region
python filter.py IGHV.blast.out.90 > IGHV.blast.out.90.filter.1
less IGHV.blast.out.90.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGHV.blast.result

### ighd
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGHD.fasta -outfmt 6 -out IGHD.blast.out -num_threads 64 -task blastn-short
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGHD.fasta > IGHD.fasta.len
python add-len-info.py IGHD.fasta.len IGHD.blast.out > IGHD.blast.out.1
less IGHD.blast.out.1 | awk '{if($3>=90) print $0}' > IGHD.blast.out.2
python filter-cover.py --blast IGHD.blast.out.2 --cover 0.9 > IGHD.blast.out.90
#### select best one
python -m jcvi.formats.blast best -n 1 IGHD.blast.out.90
#### filter uniq region
python filter.py IGHD.blast.out.best > IGHD.blast.out.best.filter.1
less IGHD.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGHD.blast.result

### ighj
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGHJ.fasta -outfmt 6 -out IGHJ.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGHJ.fasta > IGHJ.fasta.len
python add-len-info.py IGHJ.fasta.len IGHJ.blast.out > IGHJ.blast.out.1
less IGHJ.blast.out.1 | awk '{if($3>=90) print $0}' > IGHJ.blast.out.2
python filter-cover.py --blast IGHJ.blast.out.2 --cover 0.9 > IGHJ.blast.out.90
#### select best one
python -m jcvi.formats.blast best -n 1 IGHJ.blast.out.90
#### filter uniq region
python filter.py IGHJ.blast.out.best > IGHJ.blast.out.best.se.filter.1
less IGHJ.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGHJ.blast.result

### ighc
/dir/to/ncbi-blast-2.15.0+/bin/blastn -db genome.fasta -query IGHC.fasta -outfmt 6 -out IGHC.blast.out -num_threads 64
### coverage > 90 && identity > 90
seqkit fx2tab --name --length IGHC.fasta > IGHC.fasta.len
python add-len-info.py IGHC.fasta.len IGHC.blast.out > IGHC.blast.out.1
less IGHC.blast.out.1 | awk '{if($3>=90) print $0}' > IGHC.blast.out.2
python filter-cover.py --blast IGHC.blast.out.2 --cover 0.9 > IGHC.blast.out.90
#### select best one
python -m jcvi.formats.blast best -n 1 IGHC.blast.out.90
#### filter uniq region
python filter.py IGHC.blast.out.best > IGHC.blast.out.best.filter.1
less IGHC.blast.out.best.filter.1 | sed 's/ /\t/g' | sort -k9 -n > IGHC.blast.result
