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
