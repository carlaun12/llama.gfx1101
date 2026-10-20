#!/usr/bin/env python3
"""Summarize rocprofv3 kernel traces without mixing in API or statistics CSVs."""

import argparse
import csv
import json
import re
from collections import defaultdict
from pathlib import Path


def summarize(directory: Path) -> dict:
    traces = sorted(directory.rglob('*kernel_trace.csv'))
    if not traces:
        raise ValueError(f'No kernel_trace.csv found in {directory}')
    totals = defaultdict(lambda: {'calls': 0, 'total_ns': 0})
    for trace in traces:
        with trace.open(newline='', encoding='utf-8-sig') as stream:
            reader = csv.DictReader(stream)
            required = {'Kernel_Name', 'Start_Timestamp', 'End_Timestamp'}
            if not required.issubset(reader.fieldnames or []):
                raise ValueError(f'Unexpected kernel trace columns in {trace}: {reader.fieldnames}')
            for row in reader:
                start = int(row['Start_Timestamp'])
                end = int(row['End_Timestamp'])
                if end < start:
                    raise ValueError(f'Negative kernel duration in {trace}')
                item = totals[row['Kernel_Name']]
                item['calls'] += 1
                item['total_ns'] += end - start
    if not totals:
        raise ValueError('The kernel trace is empty; no GPU timing was collected')

    header = Path(__file__).resolve().parents[1] / 'ggml/include/ggml.h'
    types = {int(number): name for name, number in re.findall(
        r'GGML_TYPE_(\w+)\s*=\s*(\d+)', header.read_text(encoding='utf-8'))}
    kernels = []
    for name, item in totals.items():
        quant = re.search(r'mul_mat_vec_q<\s*(?:\(ggml_type\)\s*)?(\d+)\s*,', name)
        kernels.append({
            'kernel': name,
            'quantization': types.get(int(quant[1]), 'unknown') if quant else None,
            **item,
        })
    kernels.sort(key=lambda item: item['total_ns'], reverse=True)
    total_ns = sum(item['total_ns'] for item in kernels)
    if not total_ns:
        raise ValueError('All kernel durations are zero')
    for item in kernels:
        item['percent_kernel_time'] = 100 * item['total_ns'] / total_ns
        item['average_us'] = item['total_ns'] / item['calls'] / 1000
    return {'trace_files': [str(path) for path in traces], 'total_kernel_ns': total_ns, 'kernels': kernels}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    args = parser.parse_args()
    try:
        result = summarize(args.directory)
    except (ValueError, OSError) as error:
        parser.exit(1, f'{error}\n')
    (args.directory / 'kernel-summary.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(f"Summed GPU kernel time: {result['total_kernel_ns'] / 1e6:.3f} ms")
    print('Includes setup and one warmup token. Percentages are of summed kernel time, not wall time.')
    print('Profiler throughput must not be compared directly with the unprofiled baseline.\n')
    print('Top kernels: percent | calls | total ms | average us | name')
    for item in result['kernels'][:20]:
        print(f"{item['percent_kernel_time']:6.2f}% | {item['calls']:7d} | "
              f"{item['total_ns'] / 1e6:10.3f} | {item['average_us']:10.3f} | {item['kernel']}")
    quant_totals = defaultdict(int)
    for item in result['kernels']:
        if item['quantization']:
            quant_totals[item['quantization']] += item['total_ns']
    if quant_totals:
        print('\nQuantized matrix-vector kernels by weight type:')
        for name, total_ns in sorted(quant_totals.items(), key=lambda pair: pair[1], reverse=True):
            print(f"{name:12s} {total_ns / 1e6:10.3f} ms  {100 * total_ns / result['total_kernel_ns']:6.2f}% of kernel time")


if __name__ == '__main__':
    main()
