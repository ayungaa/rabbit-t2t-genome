### chrX
source("asynt-master/asynt-master/asynt.R")
library(xlsx)
options(scipen = 100)
alignments <- import.paf("align.paf")
ref_data <- import.genome(fai_file="genome.fasta.fai")
query_data <- import.genome(fai_file="UM_NZW_1.0.fasta.fai")
alignments <- subset(alignments, Rlen >= 200 & Qlen >= 200)
alignments <- subset(alignments, reference == "chrX")
query_aln_prop <- get.query.aln.prop(alignments, query_lens = query_data$seq_len)
barplot(query_aln_prop, las=2)
synblocks <- get.synteny.blocks.multi(alignments, min_subblock_size=200)
align <- synblocks[, c("Rstart", "Rend")]
plot.alignments.multi(synblocks, reference_lens=ref_data$seq_len, query_lens=query_data$seq_len, sigmoid=T)