#!/usr/bin/env python3
import argparse
import sys
import re

def process_data(input_file, output_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as fin:
            lines = fin.readlines()
    except FileNotFoundError:
        print(f"错误：找不到输入文件 '{input_file}'", file=sys.stderr)
        sys.exit(1)

    if not lines:
        print("错误：输入文件为空", file=sys.stderr)
        sys.exit(1)

    # 1. 提取并格式化表头
    header_line = lines[0].strip()
    headers = re.split(r'\s+', header_line)

    data = []
    partial_groups = {} # 用于存储 Best_Target 对应的 Partial 行索引

    # 2. 逐行读取数据
    for idx, line in enumerate(lines[1:]):
        line = line.strip()
        if not line:
            continue
        
        # 使用正则按空白字符拆分，最大拆分5次以防 Evaluation_Log 中包含空格
        parts = re.split(r'\s+', line, maxsplit=5)
        if len(parts) < 6:
            parts.extend([''] * (6 - len(parts))) # 补齐空缺列

        row_dict = {
            'Query_ID': parts[0],
            'Final_Status': parts[1],
            'Best_Target': parts[2],
            'Identity': parts[3],
            'Coverage': parts[4],
            'Evaluation_Log': parts[5]
        }
        data.append(row_dict)

        # 仅对 Partial 状态的靶标进行分组收集
        if row_dict['Final_Status'] == 'Partial':
            target = row_dict['Best_Target']
            if target not in partial_groups:
                partial_groups[target] = []
            partial_groups[target].append(idx) # 记录该行在 data 列表中的索引

    # 3. 核心过滤逻辑：处理有多个 Query 竞争同一个 Partial Target 的情况
    for target, indices in partial_groups.items():
        if len(indices) > 1:
            # 排序机制：优先按照 Identity 降序排序，若 Identity 相同则按 Coverage 降序排序
            indices.sort(
                key=lambda i: (float(data[i]['Identity']), float(data[i]['Coverage'])), 
                reverse=True
            )
            
            # 第一名（indices[0]）保留 'Partial' 状态，其余降级为 'Novel'
            for i in indices[1:]:
                data[i]['Final_Status'] = 'Novel'
                # 更新评估日志以防文字矛盾，方便后续追溯
                data[i]['Evaluation_Log'] = '前人完全未知(同源区间竞争降级为Novel)'

    # 4. 输出结果到新文件
    try:
        with open(output_file, 'w', encoding='utf-8') as fout:
            # 写入表头，以制表符分隔
            fout.write('\t'.join(headers) + '\n')
            
            # 写入处理后的数据
            for row in data:
                output_row = [
                    row['Query_ID'],
                    row['Final_Status'],
                    row['Best_Target'],
                    row['Identity'],
                    row['Coverage'],
                    row['Evaluation_Log']
                ]
                fout.write('\t'.join(output_row) + '\n')
                
        print(f"处理完成！结果已成功保存至: {output_file}")
        
    except Exception as e:
        print(f"写入文件时发生错误: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="过滤比对结果：针对具有相同 Best_Target 的 Partial 状态基因引入竞争机制。\n"
                    "逻辑说明：\n"
                    "1. 忽略 Known 状态（保持原样）。\n"
                    "2. 扫描所有 Partial 状态记录，若多个 Query 命中同一个 Best_Target：\n"
                    "   - 根据 Identity 和 Coverage 从高到低排序。\n"
                    "   - 保留得分最高的一条为 'Partial'。\n"
                    "   - 将其余竞争失败的条目状态改为 'Novel'。\n",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument("-i", "--input", required=True, help="输入的原始 txt/tsv 数据文件路径")
    parser.add_argument("-o", "--output", required=True, help="处理后生成的输出文件路径")
    
    args = parser.parse_args()
    process_data(args.input, args.output)

if __name__ == '__main__':
    main()
