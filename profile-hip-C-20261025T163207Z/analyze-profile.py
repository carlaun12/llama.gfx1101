#!/usr/bin/env python3
import csv
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

root = Path(sys.argv[1])
header = (root.parent / 'ggml/include/ggml.h').read_text(encoding='utf-8')
types = {int(n): name for name, n in re.findall(r'GGML_TYPE_(\w+)\s*=\s*(\d+)', header)}
all_rows = []
totals = {}
matvec_groups = defaultdict(lambda: [0, 0, 0])
mmq_groups = defaultdict(lambda: [0, 0, 0])
category_groups = defaultdict(lambda: [0, 0, 0])

def classify(name):
    if 'mul_mat_vec_q<' in name:
        return 'quantized MMVQ'
    if 'mul_mat_q<' in name:
        return 'quantized MMQ'
    if name.startswith(('Cijk_', 'Cij_')):
        return 'dense GEMM / hipBLAS'
    if 'quantize_mmq_q8_1' in name:
        return 'Q8_1 activation quantization (MMQ)'
    if 'quantize_q8_1' in name:
        return 'Q8_1 activation quantization (MMVQ)'
    if 'flash_attn' in name or 'softmax' in name or 'attention' in name.lower():
        return 'attention'
    if 'gated_delta_net' in name:
        return 'GDN'
    if 'rms_norm' in name:
        return 'RMS norm'
    if 'k_get_rows' in name:
        return 'row gather'
    if 'mul_mat_vec_f<' in name:
        return 'BF16/F16 matrix-vector'
    if 'dequantize_block' in name:
        return 'dequantization'
    if 'rope' in name.lower():
        return 'RoPE'
    if 'ssm_conv' in name:
        return 'SSM convolution'
    return 'other'

for depth in ('d0', 'd4096'):
    doc = json.loads((root / depth / 'kernel-summary.json').read_text())
    total = doc['total_kernel_ns']
    totals[depth] = total
    with (root / depth / 'kernel-details.csv').open('w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['kernel', 'quantization', 'path', 'category', 'calls', 'total_ms', 'average_us', 'percent_of_summed_kernel_time'])
        for k in doc['kernels']:
            name = k['kernel']
            quant = ''
            path = ''
            m = re.search(r'mul_mat_vec_q<\s*(?:\(ggml_type\)\s*)?(\d+)\s*,\s*1\s*,\s*(true|false)', name)
            q = re.search(r'mul_mat_q<\s*(?:\(ggml_type\)\s*)?(\d+)\s*,', name)
            if m:
                quant = types.get(int(m.group(1)), 'unknown')
                path = 'fused' if m.group(2) == 'true' else 'plain'
                g = matvec_groups[(depth, quant, path)]
                g[0] += k['calls']; g[1] += k['total_ns']; g[2] += total
            elif q:
                quant = types.get(int(q.group(1)), 'unknown')
                path = 'MMQ'
                g = mmq_groups[(depth, quant)]
                g[0] += k['calls']; g[1] += k['total_ns']; g[2] += total
            category = classify(name)
            cg = category_groups[(depth, category)]
            cg[0] += k['calls']; cg[1] += k['total_ns']; cg[2] += total
            w.writerow([name, quant, path, category, k['calls'], f"{k['total_ns']/1e6:.6f}", f"{k['average_us']:.6f}", f"{100*k['total_ns']/total:.6f}"])

with (root / 'quant-matvec-by-type-path.csv').open('w', newline='') as f:
    w=csv.writer(f); w.writerow(['depth','quantization','path','calls','total_ms','percent_of_summed_kernel_time'])
    for (d,t,p),(calls,ns,den) in sorted(matvec_groups.items()): w.writerow([d,t,p,calls,f'{ns/1e6:.6f}',f'{100*ns/totals[d]:.6f}'])
with (root / 'quant-mmq-by-type.csv').open('w', newline='') as f:
    w=csv.writer(f); w.writerow(['depth','quantization','calls','total_ms','percent_of_summed_kernel_time'])
    for (d,t),(calls,ns,den) in sorted(mmq_groups.items()): w.writerow([d,t,calls,f'{ns/1e6:.6f}',f'{100*ns/totals[d]:.6f}'])
with (root / 'operation-groups.csv').open('w', newline='') as f:
    w=csv.writer(f); w.writerow(['depth','category','calls','total_ms','percent_of_summed_kernel_time'])
    for (d,c),(calls,ns,den) in sorted(category_groups.items()): w.writerow([d,c,calls,f'{ns/1e6:.6f}',f'{100*ns/totals[d]:.6f}'])
with (root / 'telemetry-summary.csv').open('w', newline='') as f:
    w=csv.writer(f); w.writerow(['depth','samples','busy_samples_ge_95pct','mean_busy_pct','mean_power_busy_W','max_power_W','edge_C_min','edge_C_max','junction_C_min','junction_C_max','memory_C_min','memory_C_max','mean_sclk_busy_MHz','mean_mclk_busy_MHz'])
    for depth in ('d0','d4096'):
        rows=list(csv.DictReader((root/depth/'telemetry.csv').open()))
        busy=[r for r in rows if int(r['gpu_busy_percent'] or 0)>=95]
        def vals(rs,key,scale=1): return [float(r[key])/scale for r in rs if r.get(key)]
        def mean(xs): return sum(xs)/len(xs) if xs else float('nan')
        power=vals(busy,'power1_average_uW',1e6)
        row=[depth,len(rows),len(busy),f'{mean(vals(rows,"gpu_busy_percent")):.2f}',f'{mean(power):.2f}',f'{max(power):.2f}',f'{min(vals(rows,"temp1_mC",1000)):.1f}',f'{max(vals(rows,"temp1_mC",1000)):.1f}',f'{min(vals(rows,"temp2_mC",1000)):.1f}',f'{max(vals(rows,"temp2_mC",1000)):.1f}',f'{min(vals(rows,"temp3_mC",1000)):.1f}',f'{max(vals(rows,"temp3_mC",1000)):.1f}',f'{mean(vals(busy,"freq1_Hz",1e6)):.1f}',f'{mean(vals(busy,"freq2_Hz",1e6)):.1f}']
        w.writerow(row)
