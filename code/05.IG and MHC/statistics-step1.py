#!/usr/bin/env python3
import sys
import argparse
from collections import defaultdict

def has_spatial_conflict(s_start, s_end, locked_intervals, tolerance):
    """检查当前 Reference 区间是否与已锁定的已知基因发生物理位置重叠"""
    s_min, s_max = min(s_start, s_end), max(s_start, s_end)
    for l_min, l_max in locked_intervals:
        overlap_len = min(s_max, l_max) - max(s_min, l_min)
        if overlap_len > tolerance:
            return True
    return False

def evaluate_assembly(blast_file, query_list_file, out_prefix, cov_high, cov_partial, idt_perfect, tolerance):
    print("=" * 70)
    print(f"{'基因组组装质量评估 - IG 基因三分类器':^60}")
    print("=" * 70)
    print(f" [参数] 完整已知覆盖度限 (cov-high)    : {cov_high}")
    print(f" [参数] 部分已知覆盖度下限 (cov-partial): {cov_partial}")
    print(f" [参数] 相同序列一致性限 (idt-perfect) : {idt_perfect}%")
    print(f" [参数] 物理位置重叠容忍度 (tolerance) : {tolerance} bp")
    print("-" * 70)

    # 1. 载入所有新组装预测基因
    all_queries = set()
    with open(query_list_file, 'r') as f:
        for line in f:
            if line.strip():
                all_queries.add(line.strip().split()[0])

    # 2. 读入比对结果
    query_all_hits = defaultdict(list)
    all_hits_flat = []
    
    with open(blast_file, 'r') as f:
        for line in f:
            if not line.strip() or line.startswith('#'):
                continue
            parts = line.strip().split('\t')
            
            hit = {
                'qseqid': parts[0],
                'sseqid': parts[1],
                'pident': float(parts[2]),
                'aln_len': int(parts[3]),
                'sstart': int(parts[8]),   
                'send': int(parts[9]),     
                'bitscore': float(parts[11]),
                'qlen': int(parts[12])     
            }
            query_all_hits[parts[0]].append(hit)
            all_hits_flat.append(hit)

    # ==========================================
    # [第一轮]：锁定“前人已知 (Known)”
    # ==========================================
    all_hits_flat.sort(key=lambda x: x['bitscore'], reverse=True)
    
    known_queries = {}
    locked_ref_regions = defaultdict(list)
    
    for hit in all_hits_flat:
        q = hit['qseqid']
        s = hit['sseqid']
        
        # [修改点]：判断比对长度与查询长度，用较短的值除以较长的值
        shorter_len = min(hit['aln_len'], hit['qlen'])
        longer_len = max(hit['aln_len'], hit['qlen'])

        # 计算覆盖度并强制最高为 1.0
        raw_cov = shorter_len / longer_len
        cov = raw_cov
        idt = hit['pident']
        
        if q in known_queries: continue
        if cov < cov_high or idt < idt_perfect: continue
        if has_spatial_conflict(hit['sstart'], hit['send'], locked_ref_regions[s], tolerance): continue
            
        known_queries[q] = hit
        s_min, s_max = min(hit['sstart'], hit['send']), max(hit['sstart'], hit['send'])
        locked_ref_regions[s].append((s_min, s_max))

    # ==========================================
    # [第二轮]：鉴定“前人部分已知 (Partial)”与“前人完全未知 (Novel)”
    # ==========================================
    categories = {
        'Known': list(known_queries.values()),
        'Partial': [],
        'Novel': []  # 合并了所有前人基因组中不存在的情况
    }
    
    final_output_rows = []
    overflow_records = [] # 新增：用于记录覆盖度大于 1 的条目
    
    for qname in all_queries:
        # 1. 已经成功锁定的 -> 前人已知
        if qname in known_queries:
            hit = known_queries[qname]
            raw_cov = hit['aln_len'] / hit['qlen']
            cov = min(raw_cov, 1.0)
            tgt = f"{hit['sseqid']}:{min(hit['sstart'], hit['send'])}-{max(hit['sstart'], hit['send'])}"
            final_output_rows.append(f"{qname}\tKnown\t{tgt}\t{hit['pident']:.2f}\t{cov:.4f}\t前人完全已知(序列与位置匹配)")
            
            # 如果原始覆盖度大于 1，则记录到溢出列表
            if raw_cov > 1.0:
                overflow_records.append(f"{qname}\t{tgt}\tKnown\t{raw_cov:.4f}\t{hit['aln_len']}\t{hit['qlen']}")
            continue
            
        # 2. 没有任何记录的 -> 前人完全未知
        if qname not in query_all_hits:
            categories['Novel'].append(qname)
            final_output_rows.append(f"{qname}\tNovel\tNone\t0.00\t0.0000\t前人完全未知(旧版无此序列)")
            continue
            
        # 3. 有记录的，提取其自身最佳比对进行分类
        best_hit = sorted(query_all_hits[qname], key=lambda x: x['bitscore'], reverse=True)[0]
        
        # 计算覆盖度并强制最高为 1.0
        raw_cov = best_hit['aln_len'] / best_hit['qlen']
        cov = min(raw_cov, 1.0)
        idt = best_hit['pident']
        tgt = f"{best_hit['sseqid']}:{min(best_hit['sstart'], best_hit['send'])}-{max(best_hit['sstart'], best_hit['send'])}"
        
        status = ""
        log_msg = ""
        
        if cov >= cov_high:
            # 骨架完整，但第一轮没进去(Idt低或旧版位置被占) -> 前人完全未知
            status = "Novel"
            log_msg = "前人完全未知(旧版缺失该完整序列)"
        elif cov >= cov_partial:
            # 骨架残缺 -> 前人部分已知
            status = "Partial"
            log_msg = "前人部分已知(旧版组装断裂)"
        else:
            # 噪音 -> 前人完全未知
            status = "Novel"
            log_msg = "前人完全未知(仅有低质量噪音映射)"
            
        categories[status].append(best_hit)
        final_output_rows.append(f"{qname}\t{status}\t{tgt}\t{idt:.2f}\t{cov:.4f}\t{log_msg}")
        
        # 如果原始覆盖度大于 1，则记录到溢出列表
        if raw_cov > 1.0:
            overflow_records.append(f"{qname}\t{tgt}\t{status}\t{raw_cov:.4f}\t{best_hit['aln_len']}\t{best_hit['qlen']}")

    # ==========================================
    # 打印最终三分类报表
    # ==========================================
    print(f" (1) 前人已知的基因 (Known)    : {len(categories['Known']):>5} 个")
    print(f" (2) 前人部分已知的基因 (Partial): {len(categories['Partial']):>5} 个")
    print(f" (3) 前人完全未知的基因 (Novel)  : {len(categories['Novel']):>5} 个")
    print("-" * 70)
    print(f" 评估基因总数 (Total)          : {len(all_queries):>5} 个")
    print("=" * 70)

    # 输出主报表
    out_file = f"{out_prefix}_assembly_evaluation.tsv"
    with open(out_file, 'w') as f:
        f.write("Query_ID\tFinal_Status\tBest_Target\tIdentity\tCoverage\tEvaluation_Log\n")
        for row in sorted(final_output_rows):
            f.write(row + '\n')
    print(f"[INFO] 详细评估名单已保存至: {out_file}")
    
    # 输出覆盖度溢出日志（如果有的话）
    if overflow_records:
        out_overflow_file = f"{out_prefix}_coverage_overflow.tsv"
        with open(out_overflow_file, 'w') as f:
            f.write("Query_ID\tTarget_Position\tFinal_Status\tRaw_Coverage\tAln_Len\tQuery_Len\n")
            for rec in sorted(overflow_records):
                f.write(rec + '\n')
        print(f"[INFO] 发现 Coverage > 1.0 的条目，异常位置记录已保存至: {out_overflow_file}")
    print()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="严格进行新旧组装比对的三分类评估工具")
    parser.add_argument("-i", "--input", required=True, help="输入的 13 列 BLAST 结果文件")
    parser.add_argument("-q", "--query-list", required=True, help="新组装基因的单列名单")
    parser.add_argument("-o", "--out", required=True, help="输出文件前缀")
    
    parser.add_argument("--cov-high", type=float, default=0.95, help="完整骨架覆盖度限 (默认: 0.95)")
    parser.add_argument("--cov-partial", type=float, default=0.10, help="碎裂片段覆盖度下限 (默认: 0.10)")
    parser.add_argument("--idt-perfect", type=float, default=97.0, help="判定为已知基因的一致性限 (默认: 97.0)")
    parser.add_argument("--tolerance", type=int, default=5, help="位置重叠容忍度 (默认: 5 bp)")
    
    args = parser.parse_args()
    
    evaluate_assembly(args.input, args.query_list, args.out, args.cov_high, args.cov_partial, args.idt_perfect, args.tolerance)
