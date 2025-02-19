less ../01.hicpro/results/hic_results/data/reads/reads.allValidPairs | awk -F '/' '{print $1}' | sed 's/$/\/1/g' > reads1
less ../01.hicpro/results/hic_results/data/reads/reads.allValidPairs | awk -F '/' '{print $1}' | sed 's/$/\/2/g' > reads2
seqkit grep -f reads1 ../00.reads/cleanHicdata_75_R1.fq.gz -o valid_75_R1.fastq
seqkit grep -f reads2 ../00.reads/cleanHicdata_75_R2.fq.gz -o valid_75_R2.fastq
seqkit grep -f reads1 ../00.reads/cleanHicdata_76_R1.fq.gz -o valid_76_R1.fastq
seqkit grep -f reads2 ../00.reads/cleanHicdata_76_R2.fq.gz -o valid_76_R2.fastq
cat valid_75_R1.fastq valid_76_R1.fastq > valid_7576_R1.fastq &
cat valid_75_R2.fastq valid_76_R2.fastq > valid_7576_R2.fastq &
