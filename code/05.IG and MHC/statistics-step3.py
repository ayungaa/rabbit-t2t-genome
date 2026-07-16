#!/usr/bin/env python3
import argparse
import sys
import re

def format_number(num):
    """将数字转换为带逗号的千分位格式"""
    if num == "NA":
        return "NA"
    return "{:,}".format(int(num))

def process_data(input_file, output_file):
    records = []
    
    # 定义输出表头
    headers = [
        "query ID", "query chromosome", "query start", "query end",
        "Best target chromosome", "Best target start", "Best target end", 
        "Status", "Reason"
    ]
    
    # 第一阶段：读取并解析所有数据
    try:
        with open(input_file, 'r', encoding='utf-8') as fin:
            first_line = True
            for line in fin:
                line = line.strip()
                if not line:
                    continue
                
                fields = re.split(r'\s+', line)
                if first_line:
                    first_line = False
                    continue
                
                raw_query = fields[0]
                status = fields[1]
                raw_target = fields[2]
                identity = fields[3] if len(fields) > 3 else "NA"
                
                # 解析 Query 坐标
                try:
                    query_id, query_loc = raw_query.split("::")
                    query_chrom, query_coords = query_loc.split(":")
                    q_s_str, q_e_str = query_coords.split("-")
                    q_start = int(q_s_str)
                    q_end = int(q_e_str)
                except ValueError:
                    print(f"警告：无法解析 Query 格式，跳过该行: {raw_query}", file=sys.stderr)
                    continue
                
                # 解析 Target 坐标
                target_chrom = "NA"
                t_start = 0
                t_end = 0
                
                if status.lower() != "novel":
                    try:
                        target_chrom, target_coords = raw_target.split(":")
                        t_s_str, t_e_str = target_coords.split("-")
                        t_start = int(t_s_str)
                        t_end = int(t_e_str)
                    except ValueError:
                        target_chrom = "NA"
                
                records.append({
                    'query_id': query_id,
                    'query_chrom': query_chrom,
                    'q_start': q_start,
                    'q_end': q_end,
                    'target_chrom': target_chrom,
                    't_start': t_start,
                    't_end': t_end,
                    'status': status,
                    'identity': identity
                })
    except FileNotFoundError:
        print(f"错误：找不到输入文件 '{input_file}'", file=sys.stderr)
        sys.exit(1)

    # 第二阶段：计算 Overlap 并判定 Reason
    for i, rec in enumerate(records):
        status_upper = rec['status'].capitalize()
        
        if status_upper == "Known":
            rec['reason'] = "High quality 1-vs-1 location"
            
        elif status_upper == "Novel":
            rec['reason'] = "No high quality hit"
            
        elif status_upper == "Partial":
            is_unique = True
            
            # 计算当前 Partial 的 target 实际区间（取最小最大值，防止反向比对）
            r_t_min = min(rec['t_start'], rec['t_end'])
            r_t_max = max(rec['t_start'], rec['t_end'])
            r_t_len = r_t_max - r_t_min + 1
            
            # 遍历其他记录，寻找重叠
            for j, other in enumerate(records):
                if i == j: # 跳过自身
                    continue
                if other['status'].capitalize() not in ["Known", "Partial"]:
                    continue
                if other['target_chrom'] != rec['target_chrom']:
                    continue
                
                o_t_min = min(other['t_start'], other['t_end'])
                o_t_max = max(other['t_start'], other['t_end'])
                
                # 计算重叠区域长度
                overlap_start = max(r_t_min, o_t_min)
                overlap_end = min(r_t_max, o_t_max)
                overlap_len = max(0, overlap_end - overlap_start + 1)
                
                # 如果重叠长度超过自身长度的 50%
                if r_t_len > 0 and (overlap_len / r_t_len) > 0.5:
                    is_unique = False
                    break
            
            if is_unique:
                # Target 长度 / Query 长度 (加上 1 以精准计算碱基数)
                q_len = abs(rec['q_end'] - rec['q_start']) + 1
                coverage = r_t_len / q_len if q_len > 0 else 0
                rec['reason'] = f"coverage: {coverage:.2f}, identity: {rec['identity']}"
            else:
                rec['reason'] = "no 1-vs-1 location"
                
        else:
            rec['reason'] = "NA"

    # 第三阶段：格式化数字并输出
    try:
        with open(output_file, 'w', encoding='utf-8') as fout:
            fout.write("\t".join(headers) + "\n")
            
            for rec in records:
                # 针对 Novel 将 target 坐标强行置为 NA
                if rec['status'].capitalize() == "Novel":
                    tgt_chrom = "NA"
                    tgt_start = "NA"
                    tgt_end = "NA"
                else:
                    tgt_chrom = rec['target_chrom']
                    tgt_start = format_number(rec['t_start'])
                    tgt_end = format_number(rec['t_end'])
                    
                output_row = [
                    rec['query_id'],
                    rec['query_chrom'],
                    format_number(rec['q_start']),
                    format_number(rec['q_end']),
                    tgt_chrom,
                    tgt_start,
                    tgt_end,
                    rec['status'],
                    rec['reason']
                ]
                fout.write("\t".join(output_row) + "\n")
                
        print(f"处理完成！结果已保存至: {output_file}")
        
    except Exception as e:
        print(f"写入文件时发生错误: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="格式化 IGHV 比对结果文件 (Advanced)。\n"
                    "功能包括：\n"
                    "1. 拆分 Query 和 Best target 的染色体坐标。\n"
                    "2. 千分位格式化坐标数字 (如 50,179,698)。\n"
                    "3. 新增一列 Reason 分析状态原因：\n"
                    "   - Known -> 'best target'\n"
                    "   - Novel -> 'no good hits' (并隐去 target 坐标)\n"
                    "   - Partial -> 自动扫描是否与其他片段在 Target 上产生 >50% 重叠。\n"
                    "                若无重叠，计算输出 'coverage: X.XX, identity: X.XX'；\n"
                    "                若重叠，输出 'no 1-vs-1 location'。",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument("-i", "--input", required=True, help="输入的原始 txt/tsv 数据文件路径")
    parser.add_argument("-o", "--output", required=True, help="处理后的输出文件路径")
    
    args = parser.parse_args()
    process_data(args.input, args.output)


if __name__ == '__main__':
    main()
