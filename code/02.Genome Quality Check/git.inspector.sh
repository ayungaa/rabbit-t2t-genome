source /Software/condamaster/bin/activate Inspector
python /Software/Inspector/Inspector/inspector.py \
	-c /dir/to/genome.fasta \
	-r /dir/to/hifi.fa.gz \
	-o hifi_out \
	--datatype hifi \
	-t 36
python /Software/Inspector/Inspector/inspector.py \
	-c /dir/to/genome.fasta \
	-r /dir/to/hifi.fa.gz \
	-o ont_out \
	--datatype nanopore \
	-t 36
