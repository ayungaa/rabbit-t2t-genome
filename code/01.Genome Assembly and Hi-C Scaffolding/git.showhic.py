# -*- coding: utf-8 -*-
import argparse
import hicstraw
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib.colors import LinearSegmentedColormap

mpl.rcParams['pdf.fonttype'] = 42
mpl.rcParams['pdf.compression'] = 0
mpl.rcParams['savefig.transparent'] = False

def plot_hic_map(hic_file, start_pos, end_pos, resolution, out_pdf):
    chrom = "assembly"
    region = f"{chrom}:{start_pos}:{end_pos}"
    
    try:
        result = hicstraw.straw('observed', 'NONE', hic_file, region, region, 'BP', resolution)
    except Exception as e:
        print(f"Error fetching data: {e}")
        return

    x = [(row.binX - start_pos) // resolution for row in result]
    y = [(row.binY - start_pos) // resolution for row in result]
    counts = [row.counts for row in result]

    if not x:
        print("Warning: No data found.")
        return

    matrix_size = (end_pos - start_pos) // resolution + 1
    matrix = np.zeros((matrix_size, matrix_size))

    for xi, yi, count in zip(x, y, counts):
        if xi < matrix_size and yi < matrix_size:
            matrix[xi, yi] = count
            matrix[yi, xi] = count

    log_matrix = np.log1p(matrix)

    N = matrix_size
    X, Y = np.meshgrid(np.arange(N + 1), np.arange(N + 1))
    pts_x = X.flatten()
    pts_y = Y.flatten()

    grid_i, grid_j = np.meshgrid(np.arange(N), np.arange(N), indexing='ij')
    v0 = grid_i * (N + 1) + grid_j
    v1 = v0 + 1
    v2 = v0 + (N + 1)
    v3 = v2 + 1

    v0, v1, v2, v3 = v0.flatten(), v1.flatten(), v2.flatten(), v3.flatten()

    triangles = np.empty((N * N * 2, 3), dtype=np.int32)
    
    triangles[0::2, 0] = v0
    triangles[0::2, 1] = v2
    triangles[0::2, 2] = v3

    triangles[1::2, 0] = v0
    triangles[1::2, 1] = v1
    triangles[1::2, 2] = v3

    flat_matrix = log_matrix.flatten()
    triangle_colors = np.repeat(flat_matrix, 2)

    cmap_white_red = LinearSegmentedColormap.from_list("WhiteRedBright", ["#FFFFFF", "#FFEDED", "#FF0000"])
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.invert_yaxis()

    tc = ax.tripcolor(pts_x, pts_y, triangles, facecolors=triangle_colors, 
                      cmap=cmap_white_red, edgecolors='gray', linewidth=0.1)

    fig.colorbar(tc, ax=ax)

    ax.set_aspect('equal')
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_xlim(0, N)
    ax.set_ylim(N, 0)
    
    plt.title(f"Hi-C Contact Map\n({start_pos/1e6:.2f}Mb - {end_pos/1e6:.2f}Mb, Resolution: {resolution//1000}kb)", fontsize=14)
    plt.tight_layout()

    plt.savefig(out_pdf, format='pdf')
    print(f"Success! PDF saved to: {out_pdf}")
    plt.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Draw Hi-C local map.")
    parser.add_argument("--hic", required=True, help=".hic file path")
    parser.add_argument("--start", required=True, type=int, help="Start position (bp)")
    parser.add_argument("--end", required=True, type=int, help="End position (bp)")
    parser.add_argument("--resolution", type=int, default=125000, help="Resolution")
    parser.add_argument("--out", default="target_region.pdf", help="Output PDF filename")
    
    args = parser.parse_args()
    plot_hic_map(args.hic, args.start, args.end, args.resolution, args.out)
