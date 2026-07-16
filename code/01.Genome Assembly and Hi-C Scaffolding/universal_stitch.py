import argparse
import subprocess
import os
import sys
import re

def read_fasta_multi(file_path):
    seqs = {}
    header = ""
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line: continue
            if line.startswith('>'):
                header = line[1:].split()[0]
                seqs[header] = []
            else:
                if header: seqs[header].append(line)
    for k in seqs: seqs[k] = "".join(seqs[k])
    return seqs

def process_and_split_main(input_fasta, temp_fasta_path):
    print(">>> [Pre-process] Scanning main sequence for 'N' gaps...")
    seqs = read_fasta_multi(input_fasta)
    needs_split = False
    new_seqs = {}
    
    for header, seq in seqs.items():
        if 'N' in seq or 'n' in seq:
            needs_split = True
            parts = re.split(r'[Nn]+', seq)
            parts = [p for p in parts if len(p) > 0]
            for i, p in enumerate(parts):
                new_seqs[f"{header}_split{i+1}"] = p
        else:
            new_seqs[header] = seq
            
    if needs_split:
        print(f"    -> Gaps detected. Main sequence dynamically split into {len(new_seqs)} independent contigs.")
        with open(temp_fasta_path, 'w') as f:
            for h, s in new_seqs.items():
                f.write(f">{h}\n")
                for i in range(0, len(s), 80):
                    f.write(s[i:i+80] + '\n')
        return temp_fasta_path, True
    else:
        print("    -> No 'N' gaps detected. Proceeding with original main sequence.")
        return input_fasta, False


def run_minimap2(donor_path, main_path, paf_output, args):
    print(f">>> [Step 1] Running alignment...")
    cmd = [
        "minimap2", 
        "-x", args.aln_x, 
        "-k", str(args.aln_k), 
        "-w", str(args.aln_w),
        "-r", str(args.aln_r), 
        f"--secondary={args.aln_secondary}", 
        "-t", str(args.aln_t),
        donor_path, main_path
    ]
    cmd_str = " ".join(cmd)
    print(f"    $ {cmd_str}")
    try:
        with open(paf_output, "w") as out_f:
            subprocess.run(cmd, stdout=out_f, stderr=subprocess.DEVNULL, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: alignment execution failed. Please check your input FASTA files.")
        sys.exit(1)


def parse_best_alignment_per_contig(paf_file, min_mapq, min_aln_len, trim_edge):
    print(f">>> [Step 2] Parsing PAF and anchoring (Edge trim: {trim_edge} bp)...")
    best_alignments = {}
    
    with open(paf_file, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) < 12: continue
            
            mapq = int(parts[11])
            matches = int(parts[9])
            if mapq < min_mapq or matches < min_aln_len: continue
                
            q_name = parts[0]
            if q_name not in best_alignments or matches > best_alignments[q_name]['matches']:
                best_alignments[q_name] = {
                    'q_name': q_name,
                    'q_start': int(parts[2]), 'q_end': int(parts[3]),
                    'strand': parts[4],
                    't_start': int(parts[7]), 't_end': int(parts[8]),
                    'matches': matches, 'mapq': mapq
                }

    if not best_alignments:
        print(f"Error: No main contigs passed the filters (MAPQ>={min_mapq}, Length>={min_aln_len}).")
        sys.exit(1)

    blocks = list(best_alignments.values())
    blocks.sort(key=lambda x: x['t_start'])
    
    trimmed_blocks = []
    for i, b in enumerate(blocks):
        b['q_start'] += trim_edge
        b['q_end'] -= trim_edge
        b['t_start'] += trim_edge
        b['t_end'] -= trim_edge
        trimmed_blocks.append(b)
        print(f"    -> Successfully anchored [{b['q_name']}] (Strand: {b['strand']})")
    # Conflict Resolution
    for i in range(len(trimmed_blocks) - 1):
        if trimmed_blocks[i]['t_end'] > trimmed_blocks[i+1]['t_start']:
            overlap = trimmed_blocks[i]['t_end'] - trimmed_blocks[i+1]['t_start']
            half_overlap = overlap // 2 + 1
            trimmed_blocks[i]['t_end'] -= half_overlap
            trimmed_blocks[i]['q_end'] -= half_overlap
            trimmed_blocks[i+1]['t_start'] += half_overlap
            trimmed_blocks[i+1]['q_start'] += half_overlap

    return trimmed_blocks

def rev_comp(seq):
    trans = str.maketrans('ATCGatcgNn', 'TAGCtagcNn')
    return seq.translate(trans)[::-1]

def main():
    parser = argparse.ArgumentParser(description="Universal Stitcher: Filling the Gap")
    
    # Base IO
    parser.add_argument("--donor_seq", required=True, help="Donor Assembly FASTA")
    parser.add_argument("--main_seq", required=True, help="Near T2T Assembly FASTA (The gaps in this sequence will be filled)")
    parser.add_argument("--out", required=True, help="Output unified FASTA filename")
    
    # Core Logic
    parser.add_argument("--min_aln_len", type=int, default=1000000, help="Min alignment match length in bp [Default: 1000000]")
    parser.add_argument("--trim_edge", type=int, default=5000, help="Length to trim from main sequence edges to avoid artifacts [Default: 5000]")
    parser.add_argument("--min_mapq", type=int, default=60, help="Min mapping quality (MAPQ) [Default: 60]")
    parser.add_argument("--keep_tmp", action="store_true", help="Keep temporary PAF and split FASTA files")
    
    # Alignment Parameters (--aln- prefix)
    parser.add_argument("--aln-x", default="asm5", help="alignment preset [Default: asm5]")
    parser.add_argument("--aln-k", type=int, default=19, help="alignment k-mer size [Default: 19]")
    parser.add_argument("--aln-w", type=int, default=19, help="alignment minimizer window size [Default: 19]")
    parser.add_argument("--aln-r", type=int, default=500, help="alignment chaining bandwidth [Default: 500]")
    parser.add_argument("--aln-secondary", choices=['yes', 'no'], default='no', help="alignment secondary alignments [Default: no]")
    parser.add_argument("--aln-t", type=int, default=8, help="alignment threads [Default: 8]")
    
    args = parser.parse_args()
    
    temp_fasta = "temp_main_split.fasta"
    paf_file = "temp_stitch_anchor.paf"
    
    working_main, is_split = process_and_split_main(args.main_seq, temp_fasta)
    run_minimap2(args.donor_seq, working_main, paf_file, args)
    blocks = parse_best_alignment_per_contig(paf_file, args.min_mapq, args.min_aln_len, args.trim_edge)
    
    print(">>> [Step 3] Extracting and stitching sequences on unified coordinate system...")
    donor_seqs = read_fasta_multi(args.donor_seq)
    main_seqs = read_fasta_multi(working_main)
    
    donor_chr_name = list(donor_seqs.keys())[0]
    donor_seq = donor_seqs[donor_chr_name]
    
    final_seq = ""
    last_v_pos = 0
    
    print("-" * 55)
    for i, b in enumerate(blocks):
        gap_len = b['t_start'] - last_v_pos
        gap_seq = donor_seq[last_v_pos : b['t_start']]
        final_seq += gap_seq
        
        step_name = "[Donor Fill - Left Edge]" if i == 0 else "[Donor Fill - Internal Gap]"
        print(f"  {step_name:<35} Length: {gap_len:,} bp")
            
        q_seq = main_seqs[b['q_name']][b['q_start'] : b['q_end']]
        
        if b['strand'] == '-':
            q_seq = rev_comp(q_seq)
            print(f"  [Main Sequence Integration - {b['q_name']:<10}] Length: {len(q_seq):,} bp (RevComp)")
        else:
            print(f"  [Main Sequence Integration - {b['q_name']:<10}] Length: {len(q_seq):,} bp (Forward)")
            
        final_seq += q_seq
        last_v_pos = b['t_end']
        
    right_flank = donor_seq[last_v_pos : ]
    final_seq += right_flank
    print(f"  [Donor Fill - Right Edge]{'':<9} Length: {len(right_flank):,} bp")
    print("-" * 55)
    
    print(f">>> Mission Complete! Total length of unified assembly: {len(final_seq):,} bp")
    
    with open(args.out, 'w') as f:
        seq_id = os.path.splitext(os.path.basename(args.out))[0]
        f.write(f">{seq_id}\n")
        for i in range(0, len(final_seq), 80):
            f.write(final_seq[i:i+80] + "\n")
            
    if not args.keep_tmp:
        if os.path.exists(paf_file): os.remove(paf_file)
        if is_split and os.path.exists(temp_fasta): os.remove(temp_fasta)

if __name__ == "__main__":
    main()
