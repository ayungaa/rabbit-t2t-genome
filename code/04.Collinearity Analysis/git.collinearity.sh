conda activate NGenomeSyn
perl /dir/to/NGenomeSyn/bin/GetTwoGenomeSyn.pl \
	-InGenomeA /dir/to/UM_NZW_1.0.fa \
	-InGenomeB /dir/to/genome.fasta \
	-OutPrefix UM_NZW_1.0-VS-genome \
	-MappingBin minimap2 \
	-MinLenA 1000 \
	-MinLenB 1000

