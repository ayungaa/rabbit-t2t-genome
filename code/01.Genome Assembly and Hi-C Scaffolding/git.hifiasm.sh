hifiasm \
	-o hifiasmU90 \
	-l0 \
	-t 64 \
	-ul /dir/to/nanopore.fa.gz /dir/to/hifi.fa.gz
awk '/^S/{print ">"$2;print $3}' hifiasmU90.bp.p_ctg.gfa >  hifiasmU90.bp.p_ctg.fasta
