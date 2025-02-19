source /software/bin/activate minibusco
python compleasm.py run -a genoem.fasta -o ./NZW-T2T -l mammalia_odb10 -t 64 -L ../lineages_folde
python compleasm.py run -a OryCun2.0.fasta -o ./OryCun2.0 -l mammalia_odb10 -t 64 -L ../lineages_folde
python compleasm.py run -a UM_NZW_1.0.fasta -o ./UM_NZW_1.0 -l mammalia_odb10 -t 64 -L ../lineages_folde
python compleasm.py run -a OryCun3.0.fasta -o ./OryCun3.0 -l mammalia_odb10 -t 64 -L ../lineages_folde
/Software/busco/bin/python /Software/busco/bin/generate_plot.py -wd ./
