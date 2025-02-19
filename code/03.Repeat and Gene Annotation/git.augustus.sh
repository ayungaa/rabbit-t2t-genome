conda activate Augustus
augustus \
	--species=human \
	--uniqueGeneId=true \
	--noInFrameStop=true \
	--gff3=true \
	--strand=both \
	genome.masked.fa > genome.masked.fa.augustus
