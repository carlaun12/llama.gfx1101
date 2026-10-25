#!/usr/bin/env python3
import csv
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent / "ab"
SEQUENCE = ["E", "F", "F", "E", "E", "F", "F", "E", "E", "F",
            "F", "E", "E", "F", "F", "E", "E", "F", "F", "E"]
T_CRIT_DF9 = 2.262157
EXPECTED_SHAPES = {(6144, 5120), (10240, 5120), (17408, 5120), (5120, 6144), (5120, 17408)}
line_re = re.compile(r"MUL_MAT\(([^)]*)\):\s+(\d+) runs -\s+([\d.]+) us/run")
shape_re = re.compile(r"m=(\d+),n=128,k=(\d+)")

samples = {}
for sample_idx, variant in enumerate(SEQUENCE, start=1):
    sample_id = f"shape-{sample_idx:02d}-{variant}"
    log = (ROOT / "raw" / f"{sample_id}.log").read_text()
    assert "Backend ROCm0:" in log and "2/2 backends passed" in log, sample_id
    shapes = {}
    for line in log.splitlines():
        match = line_re.search(line)
        if not match:
            continue
        params, n_runs, time_us = match.groups()
        shape = shape_re.search(params)
        assert shape, (sample_id, params)
        key = tuple(map(int, shape.groups()))
        assert key not in shapes, (sample_id, key)
        shapes[key] = {"time_us": float(time_us), "n_runs": int(n_runs)}
    assert set(shapes) == EXPECTED_SHAPES, (sample_id, sorted(shapes))
    samples[sample_id] = shapes

pair_rows = []
per_shape_gains = {shape: [] for shape in EXPECTED_SHAPES}
per_shape_e = {shape: [] for shape in EXPECTED_SHAPES}
per_shape_f = {shape: [] for shape in EXPECTED_SHAPES}
aggregate_gains = []

for pair_idx in range(10):
    left_variant = SEQUENCE[2 * pair_idx]
    right_variant = SEQUENCE[2 * pair_idx + 1]
    assert left_variant != right_variant
    left_id = f"shape-{2 * pair_idx + 1:02d}-{left_variant}"
    right_id = f"shape-{2 * pair_idx + 2:02d}-{right_variant}"
    e_id = left_id if left_variant == "E" else right_id
    f_id = left_id if left_variant == "F" else right_id
    this_pair = []
    for m, k in sorted(EXPECTED_SHAPES):
        e_us = samples[e_id][(m, k)]["time_us"]
        f_us = samples[f_id][(m, k)]["time_us"]
        gain = 100.0 * (e_us / f_us - 1.0)
        per_shape_e[(m, k)].append(e_us)
        per_shape_f[(m, k)].append(f_us)
        per_shape_gains[(m, k)].append(gain)
        this_pair.append(gain)
        pair_rows.append({
            "pair": pair_idx + 1,
            "order": f"{left_variant}-{right_variant}",
            "shape_m": m,
            "shape_k": k,
            "E_sample": e_id,
            "F_sample": f_id,
            "E_us_per_run": e_us,
            "F_us_per_run": f_us,
            "gain_percent": gain,
        })
    aggregate_gains.append(sum(this_pair) / len(this_pair))

def summary_stats(values):
    mean = sum(values) / len(values)
    sd = math.sqrt(sum((x - mean) ** 2 for x in values) / (len(values) - 1))
    half = T_CRIT_DF9 * sd / math.sqrt(len(values))
    return mean, sd, mean - half, mean + half

with (ROOT / "paired-shape-results.csv").open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(pair_rows[0]))
    writer.writeheader()
    writer.writerows(pair_rows)

lines = [
    "Kernel-shape gain = 100 * (E us/run / F us/run - 1), so positive values mean lower F latency.",
    "95% CI = two-sided paired Student-t interval over 10 paired percentage gains (df=9, t*=2.262157).",
    "The backend perf harness is unprofiled, uses randomized quantized weights and activations, and matches GGUF K/M shapes with n=128.",
    "Pair order is balanced: five E-F and five F-E.",
    "",
    "shape_m,shape_k,E_mean_us,F_mean_us,mean_gain_percent,ci95_low_percent,ci95_high_percent,paired_sd_percent",
]
for shape in sorted(EXPECTED_SHAPES):
    gains = per_shape_gains[shape]
    mean, sd, low, high = summary_stats(gains)
    lines.append(
        f"{shape[0]},{shape[1]},{sum(per_shape_e[shape])/10:.2f},{sum(per_shape_f[shape])/10:.2f},"
        f"{mean:+.3f},{low:+.3f},{high:+.3f},{sd:.3f}"
    )
mean, sd, low, high = summary_stats(aggregate_gains)
lines.extend([
    "",
    f"Equal-weight five-shape paired gain={mean:+.3f}% (95% CI {low:+.3f}% to {high:+.3f}%); paired SD={sd:.3f}%.",
])
(ROOT / "paired-shape-summary.txt").write_text("\n".join(lines) + "\n")

telemetry = []
for line in (ROOT / "telemetry.jsonl").read_text().splitlines():
    if line.strip():
        telemetry.append(json.loads(line))

def number(value):
    match = re.search(r"-?\d+(?:\.\d+)?", str(value))
    return float(match.group()) if match else None

def metric(sample, pattern):
    device = sample.get("rocm", {}).get("card0", {})
    for key, value in device.items():
        if pattern in key:
            return number(value)
    return None

telemetry_lines = [f"total one-second samples: {len(telemetry)}"]
power_all = [metric(x, "Average Graphics Package Power (W)") for x in telemetry]
power_all = [x for x in power_all if x is not None]
over_cap = [x for x in power_all if x > 190.0]
telemetry_lines.append(
    f"all tagged samples: power max={max(power_all):.1f} W; samples above configured 190 W={len(over_cap)}; cause undetermined"
)
for variant in ("E", "F"):
    tagged = [x for x in telemetry if x.get("stage", "").endswith("-" + variant)]
    busy = [x for x in tagged if (metric(x, "GPU use (%)") or 0) >= 95]
    telemetry_lines.append(f"{variant}: tagged={len(tagged)}, busy>=95%={len(busy)}")
    for label, pattern in (("power W", "Average Graphics Package Power (W)"),
                           ("SCLK MHz", "sclk clock speed"),
                           ("edge C", "Temperature (Sensor edge) (C)"),
                           ("junction C", "Temperature (Sensor junction) (C)"),
                           ("memory C", "Temperature (Sensor memory) (C)")):
        values = [metric(x, pattern) for x in busy]
        values = [x for x in values if x is not None]
        if values:
            telemetry_lines.append(
                f"  busy {label}: mean={sum(values)/len(values):.1f}, min={min(values):.1f}, max={max(values):.1f}"
            )
(ROOT / "telemetry-summary.txt").write_text("\n".join(telemetry_lines) + "\n")
print("\n".join(lines))
print("\n".join(telemetry_lines))
