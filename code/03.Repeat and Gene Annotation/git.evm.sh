/dir/to/evidencemodeler-1.1.1/EvmUtils/partition_EVM_inputs.pl \
           --genome /dir/to/genome.fasta \
	   --gene_predictions /dir/to/augustus.gff \
           --protein_alignments /dir/to/genewise.gff \
	   --transcript_alignments /dir/to/rnaBased.gff \
	   --segmentSize 5000000 --overlapSize 500000 \
           --partition_listing partitions_list.out 
mkdir CommandSet
cd CommandSet
/dir/to/evidencemodeler-1.1.1/EvmUtils/write_EVM_commands.pl \
       --partitions ./partitions_list.out \
       --genome /dir/to/genome.fasta \
       --gene_predictions /dir/to/augustus.gff \
       --protein_alignments /dir/to/genewise.gff \
       --transcript_alignments /dir/to/rnaBased.gff \
       --weights /dir/to/weights.txt \
       --output_file_name evm.out > CommandSet.sh
cd ..
/dir/to/evidencemodeler-1.1.1/EvmUtils/recombine_EVM_partial_outputs.pl \
	--partitions ./partitions_list.out \
	--output_file_name evm.out
/dir/to/evidencemodeler-1.1.1/EvmUtils/convert_EVM_outputs_to_GFF3.pl \
	--partitions ./partitions_list.out \
	--output_file_name evm.out \
	--genome genome.fasta
