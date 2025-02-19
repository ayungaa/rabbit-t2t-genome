## data dir
dir=$(pwd)
ontRead1=/pmaster/yunga/Project/Rabit/00.data/19.NANOPORE/01.clean-all-in-one/PAI39783.PAI40415.GuoSong.ONT2023.clean.fastq
## ref
ln -s  NZRBvaprsc.fasta  ref.fa

## software
minimap2=/pmaster/yunga/Software/minimap2/minimap2/minimap2 
samtools=/pmaster/yunga/Software/condamaster/envs/sambam/bin/samtools

## make ref index
$minimap2 -t 64 -d $dir/ref.fa.mini $dir/ref.fa

### map to ref , sam to bam , sort bam
$minimap2 -t 24 -ax map-ont $dir/ref.fa $ontRead1 | $samtools view -@ 24 -bS - | $samtools sort -o $dir/alin.sort.bam -@ 24 - 

### make bam index
$samtools index $dir/alin.sort.bam -@ 12 $dir/alin.sort.bam.bai
