conda activate rptmas
### create custom library
BuildDatabase -engine ncbi -name mydb.library /dir/to/genome.fasta > run.log
RepeatModeler -engine ncbi -database mydb.library -pa 4  > run.out
cat mydb.library Dfam.library Repbase.library > final.library
### mask
RepeatMasker -nolow -no_is -norna -engine ncbi -parallel 2 -lib final.library /dir/to/genome.fasta > genome.fasta.log 2> /genome.fasta.log2
/dir/to/trf genome.fasta 2 7 7 80 10 50 2000 -d -h

