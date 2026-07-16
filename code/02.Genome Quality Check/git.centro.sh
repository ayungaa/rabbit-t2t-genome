### Centromics method
# Pacbio hifi long reads
source /Software/condamaster/bin/activate RepCent
centromics \
	-l /dir/to/hifi.fa.gz \
	-g genome.fasta \
	-pre hifi -outdir hifi -tmpdir hifi.tmp -ncpu 24  &>hifi.log
# ONT long reads
centromics \
	-l /dir/to/ont.fa.gz \
	-g genome.fasta \
	-pre ont -outdir ont -tmpdir ont.tmp -ncpu 24  &>ont.log

### CENP-A CUT&Tag method
bowtie2 \
	--end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 \
	-p 60 -x genome.fasta \
	-1 rbCenp-fastp_R1.fq.gz \
	-2 rbCenp-fastp_R2.fq.gz \
	--rg-id CENP_rg \
	--rg SM:sample1 \
	--rg PL:Illumina \
	--rg LB:lib1 \
	--rg PU:unit1 \
	-S bowtie2.sam &> bowtie2.txt
java -Xms2g -Xmx60g -jar picard.jar \
	SortSam \
	I=bowtie2.sam \
	O=bowtie2.sorted.sam \
	SORT_ORDER=coordinate
java -Xms2g -Xmx60g -jar picard.jar \
	MarkDuplicates \
	I=bowtie2.sorted.sam \
	O=bowtie2.sorted.dupMarked.sam \
	METRICS_FILE=picard.dupMark.txt
java -Xms2g -Xmx60g -jar picard.jar \
	MarkDuplicates \
	I=bowtie2.sorted.sam \
	O=bowtie2.sorted.rmDup.sam \
	REMOVE_DUPLICATES=true \
	METRICS_FILE=picard.rmDup.txt
samtools view -bS -F 0x04 bowtie2.sorted.rmDup.sam > bowtie2.sorted.rmDup.bam
bedtools bamtobed -i bowtie2.sorted.rmDup.bam -bedpe > bowtie2.sorted.rmDup.bed
awk '$1==$4 && $6-$2 < 1000 {print $0}' bowtie2.sorted.rmDup.bed > bowtie2.sorted.rmDup.clean.bed
cut -f 1,2,6 bowtie2.sorted.rmDup.clean.bed | sort -k1,1 -k2,2n -k3,3n  > bowtie2.sorted.rmDup.clean.fragments.bed
bedtools genomecov -bg -i bowtie2.sorted.rmDup.clean.fragments.bed -g genome.fasta.fai > bowtie2.sorted.rmDup.clean.fragments.bedgraph
samtools index bowtie2.sorted.rmDup.bam
bamCoverage --binSize 1 -b bowtie2.sorted.rmDup.bam -o bowtie2.sorted.rmDup.bw --outFileFormat bigwig --normalizeUsing BPM -p 15
bash /dir/to/SEACR_1.3.sh \
	bowtie2.sorted.rmDup.clean.fragments.bedgraph \
	0.01 \
	non \
	stringent \
	seacr_top0.01.peaks
