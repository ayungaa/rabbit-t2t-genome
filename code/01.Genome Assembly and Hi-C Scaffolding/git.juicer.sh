export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/dir/to/tmp -XX:ParallelGCThreads=12"
export TMPDIR=/dir/to/tmp
conda activate juicer-3ddna
juicer.sh -z genome/genome.fasta -y genome/genome.fasta_DpnII.txt -p genome/genome.fasta.size.txt -s DpnII -d ./ -D /Software/to/juicer -t 40 -T 40 --assembly
