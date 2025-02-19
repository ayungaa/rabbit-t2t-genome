/dir/to/genblastA \
	-P blast \
	-pg tblastn \
	-q /dir/to/homologous_mhc.fasta \
	-t /dir/to/genome.fasta \
	-p T \
	-e 1e-5 \
	-g T \
	-f F \
	-a 0.5 \
	-d 100000 \
	-r 10 \
	-c 0.8 \
	-s 0
	-o mhc.region

/dir/to/genewise \
	/dir/to/homologous_mhc.fasta \
	mhc.region.fasta \
	-tfor \
	-gff

