import csv
import json
import math
import pathlib
import re
import statistics

root = pathlib.Path(__file__).resolve().parent
sequence = "C D D C D C C D C D D C D C C D C D D C".split()
runs = []
for index, variant in enumerate(sequence, 1):
    path = root / f"{index:02d}-{variant}.json"
    rows = json.loads(path.read_text())
    if len(rows) != 2:
        raise SystemExit(f"unexpected row count in {path}: {len(rows)}")
    result = {int(row["n_depth"]): row for row in rows}
    if set(result) != {0, 4096}:
        raise SystemExit(f"unexpected depths in {path}: {sorted(result)}")
    if any(int(row["n_gen"]) != 128 or int(row["n_prompt"]) != 0 for row in rows):
        raise SystemExit(f"unexpected p/n in {path}")
    runs.append({depth: float(row["avg_ts"]) for depth, row in result.items()})

if len(runs) != 20 or sequence.count("C") != 10 or sequence.count("D") != 10:
    raise SystemExit("expected 20 runs with 10 per variant")

rows = []
summary = [
    "IQ3_S two-accumulator experiment: C control vs D candidate",
    "20 runs; 10 adjacent pairs per depth; order balanced 5 C-D and 5 D-C.",
    "Metric: llama-bench avg_ts (tokens/s). Pair gain = 100 * (D/C - 1).",
    "CI: two-sided paired Student t interval over the 10 pair gains, df=9, t*=2.262157.",
]
for pair in range(10):
    i0 = pair * 2
    i1 = i0 + 1
    c_index = i0 if sequence[i0] == "C" else i1
    d_index = i0 if sequence[i0] == "D" else i1
    for depth in (0, 4096):
        c_value = runs[c_index][depth]
        d_value = runs[d_index][depth]
        gain = 100.0 * (d_value / c_value - 1.0)
        rows.append((pair + 1, f"{sequence[i0]}-{sequence[i1]}", depth, c_value, d_value, gain))

with (root / "paired-results.csv").open("w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(("pair", "order", "depth", "C_tokens_per_second", "D_tokens_per_second", "D_gain_percent"))
    writer.writerows(rows)

for depth in (0, 4096):
    c_values = [runs[i][depth] for i, variant in enumerate(sequence) if variant == "C"]
    d_values = [runs[i][depth] for i, variant in enumerate(sequence) if variant == "D"]
    gains = [gain for _, _, row_depth, _, _, gain in rows if row_depth == depth]
    mean = statistics.mean(gains)
    sd = statistics.stdev(gains)
    half = 2.262157 * sd / math.sqrt(len(gains))
    summary.append(
        f"depth={depth}: C mean={statistics.mean(c_values):.4f} t/s; D mean={statistics.mean(d_values):.4f} t/s; "
        f"mean paired gain={mean:+.3f}% (95% CI {mean-half:+.3f}% to {mean+half:+.3f}%)."
    )
    summary.append("  pair gains: " + ", ".join(f"{gain:+.3f}%" for gain in gains))

sample_rows = []
number = re.compile(r"-?\d+(?:\.\d+)?")
def num(value):
    match = number.search(str(value))
    return float(match.group()) if match else float("nan")

for line in (root / "telemetry.jsonl").read_text().splitlines():
    try:
        row = json.loads(line)
        card = row["rocm"]["card0"]
    except (json.JSONDecodeError, KeyError):
        continue
    stage = row.get("stage", "unknown")
    if stage in ("stage", "complete") or len(stage) < 4 or stage[-1] not in "CD":
        continue
    sample_rows.append({
        "stage": stage,
        "variant": stage[-1],
        "busy": num(card.get("GPU use (%)")),
        "power_w": num(card.get("Average Graphics Package Power (W)")),
        "sclk_mhz": num(card.get("sclk clock speed:")),
        "mclk_mhz": num(card.get("mclk clock speed:")),
        "junction_c": num(card.get("Temperature (Sensor junction) (C)")),
        "memory_c": num(card.get("Temperature (Sensor memory) (C)")),
    })
with (root / "telemetry-samples.csv").open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=("stage", "variant", "busy", "power_w", "sclk_mhz", "mclk_mhz", "junction_c", "memory_c"))
    writer.writeheader()
    writer.writerows(sample_rows)

summary.append(f"telemetry samples parsed: {len(sample_rows)}; busy means GPU use >=95%.")
for variant in ("C", "D"):
    subset = [row for row in sample_rows if row["variant"] == variant]
    busy = [row for row in subset if row["busy"] >= 95]
    summary.append(f"telemetry {variant}: {len(busy)}/{len(subset)} busy samples; "
                   f"power mean/max={statistics.mean(r['power_w'] for r in busy):.1f}/{max(r['power_w'] for r in busy):.1f} W; "
                   f"SCLK mean/range={statistics.mean(r['sclk_mhz'] for r in busy):.0f}/"
                   f"{min(r['sclk_mhz'] for r in busy):.0f}-{max(r['sclk_mhz'] for r in busy):.0f} MHz; "
                   f"junction range={min(r['junction_c'] for r in busy):.0f}-{max(r['junction_c'] for r in busy):.0f} C; "
                   f"memory range={min(r['memory_c'] for r in busy):.0f}-{max(r['memory_c'] for r in busy):.0f} C; "
                   f"samples >190 W={sum(r['power_w'] > 190 for r in busy)}.")

errors = []
for path in sorted(root.glob("[0-9][0-9]-[CD].log")):
    log = path.read_text(errors="replace").lower()
    if "error:" in log or "failed" in log or "aborted" in log:
        errors.append(path.name)
summary.append(f"run logs with error/failure markers: {len(errors)}")
if errors:
    summary.append("error logs: " + ", ".join(errors))
(root / "paired-summary.txt").write_text("\n".join(summary) + "\n")
print("\n".join(summary))
