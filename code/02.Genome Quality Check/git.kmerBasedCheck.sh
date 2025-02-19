source /Software/condamaster/bin/activate merqury
ccs=/dir/to/hifi.fa.gz
fa=genome.fasta
genome_size=2831164548

/Software/Merqury/merqury/best_k.sh  $genome_size  
k=21
/Software/condamaster/envs/merqury/bin/meryl  k=$k count output read.meryl $ccs
/Software/condamaster/envs/merqury/bin/merqury.sh  read.meryl  $fa  rbtccs
