export WISECONFIGDIR=/dir/to/wisecfg;
/dir/to/wise2.4.1/src/bin/genewise -trev -sum -genesf -gff /dir/to/Human.pep.fa /dir/to/genome.fa > human.genewise 2> /dev/null;
/dir/to/wise2.4.1/src/bin/genewise -trev -sum -genesf -gff /dir/to/Mouse.pep.fa /dir/to/genome.fa > mouse.genewise 2> /dev/null;
/dir/to/wise2.4.1/src/bin/genewise -trev -sum -genesf -gff /dir/to/EuropeanHare.pep.fa /dir/to/genome.fa > EuropeanHare.genewise 2> /dev/null;
