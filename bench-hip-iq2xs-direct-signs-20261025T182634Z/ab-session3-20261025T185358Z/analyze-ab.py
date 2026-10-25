#!/usr/bin/env python3
import csv
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
T_CRIT_DF9 = 2.262157
SEQUENCE = ["E", "F", "F", "E", "F", "E", "E", "F", "E", "F",
            "F", "E", "F", "E", "E", "F", "E", "F", "F", "E"]

samples = {}
for idx, variant in enumerate(SEQUENCE, start=1):
    sample_id = f"{idx:02d}-{variant}"
    rows = json.loads((ROOT / f"{sample_id}.json").read_text())
    assert len(rows) == 2, (sample_id, len(rows))
    assert all(row["build_commit"] == "bb41340de" for row in rows)
    by_depth = {int(row["n_depth"]): float(row["avg_ts"]) for row in rows}
    assert set(by_depth) == {0, 4096}, (sample_id, by_depth)
    samples[sample_id] = by_depth

pair_rows = []
for pair_idx in range(10):
    left_id = f"{2 * pair_idx + 1:02d}-{SEQUENCE[2 * pair_idx]}"
    right_id = f"{2 * pair_idx + 2:02d}-{SEQUENCE[2 * pair_idx + 1]}"
    left_variant, right_variant = left_id[-1], right_id[-1]
    assert {left_variant, right_variant} == {"E", "F"}
    e_id = left_id if left_variant == "E" else right_id
    f_id = left_id if left_variant == "F" else right_id
    for depth in (0, 4096):
        e_tps = samples[e_id][depth]
        f_tps = samples[f_id][depth]
        gain = 100.0 * (f_tps / e_tps - 1.0)
        pair_rows.append({
            "pair": pair_idx + 1,
            "order": f"{left_variant}-{right_variant}",
            "depth": depth,
            "E_sample": e_id,
            "F_sample": f_id,
            "E_tps": e_tps,
            "F_tps": f_tps,
            "gain_percent": gain,
        })

def summarize(values):
    n = len(values)
    mean = sum(values) / n
    variance = sum((x - mean) ** 2 for x in values) / (n - 1)
    sd = math.sqrt(variance)
    half = T_CRIT_DF9 * sd / math.sqrt(n)
    return mean, mean - half, mean + half, sd

csv_path = ROOT / "paired-results.csv"
with csv_path.open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(pair_rows[0]))
    writer.writeheader()
    writer.writerows(pair_rows)

summary_lines = [
    "Paired gain = 100 * (F avg_ts / E avg_ts - 1).",
    "95% CI = two-sided paired Student-t interval over 10 percentage gains (df=9, t*=2.262157).",
    "Each pair consists of adjacent runs in the balanced AB/BA sequence.",
    "",
]
for depth in (0, 4096):
    rows = [r for r in pair_rows if r["depth"] == depth]
    gains = [r["gain_percent"] for r in rows]
    mean, low, high, sd = summarize(gains)
    e_mean = sum(r["E_tps"] for r in rows) / len(rows)
    f_mean = sum(r["F_tps"] for r in rows) / len(rows)
    summary_lines.append(
        f"tg128 d={depth}: E={e_mean:.4f} tok/s; F={f_mean:.4f} tok/s; "
        f"mean paired gain={mean:+.3f}% (95% CI {low:+.3f}% to {high:+.3f}%); "
        f"paired SD={sd:.3f}%"
    )
aggregate = []
for pair_idx in range(10):
    vals = [r["gain_percent"] for r in pair_rows if r["pair"] == pair_idx + 1]
    aggregate.append(sum(vals) / len(vals))
mean, low, high, sd = summarize(aggregate)
summary_lines.append(
    f"Equal-weight decode aggregate (d=0,d=4096): {mean:+.3f}% "
    f"(95% CI {low:+.3f}% to {high:+.3f}%), paired SD={sd:.3f}%"
)
(ROOT / "paired-summary.txt").write_text("\n".join(summary_lines) + "\n")

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
                f"  busy {label}: mean={sum(values)/len(values):.1f}, "
                f"min={min(values):.1f}, max={max(values):.1f}"
            )
(ROOT / "telemetry-summary.txt").write_text("\n".join(telemetry_lines) + "\n")
print("\n".join(summary_lines))
print("\n".join(telemetry_lines))
