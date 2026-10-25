#!/usr/bin/env python3
import csv
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
T_CRIT_DF9 = 2.262157
SEQUENCE = ["E", "F", "F", "E", "E", "F", "F", "E", "E", "F",
            "F", "E", "E", "F", "F", "E", "E", "F", "F", "E"]
MODEL = "/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf"

samples = {}
for idx, variant in enumerate(SEQUENCE, start=1):
    sample_id = f"pp128-{idx:02d}-{variant}"
    rows = json.loads((ROOT / "raw" / f"{sample_id}.json").read_text())
    assert len(rows) == 1, (sample_id, len(rows))
    row = rows[0]
    assert row["build_commit"] == "bb41340de", sample_id
    assert row["model_filename"] == MODEL, sample_id
    assert (row["n_prompt"], row["n_gen"], row["n_depth"]) == (128, 0, 0), sample_id
    assert (row["n_batch"], row["n_ubatch"], row["n_threads"]) == (128, 128, 8), sample_id
    assert (row["n_gpu_layers"], row["flash_attn"], row["type_k"], row["type_v"]) == (99, 1, "f16", "f16"), sample_id
    samples[sample_id] = float(row["avg_ts"])

pairs = []
for pair_idx in range(10):
    left_id = f"pp128-{2 * pair_idx + 1:02d}-{SEQUENCE[2 * pair_idx]}"
    right_id = f"pp128-{2 * pair_idx + 2:02d}-{SEQUENCE[2 * pair_idx + 1]}"
    assert {left_id[-1], right_id[-1]} == {"E", "F"}
    e_id = left_id if left_id.endswith("-E") else right_id
    f_id = left_id if left_id.endswith("-F") else right_id
    e_tps, f_tps = samples[e_id], samples[f_id]
    pairs.append({
        "pair": pair_idx + 1,
        "order": f"{left_id[-1]}-{right_id[-1]}",
        "E_sample": e_id,
        "F_sample": f_id,
        "E_tps": e_tps,
        "F_tps": f_tps,
        "gain_percent": 100.0 * (f_tps / e_tps - 1.0),
    })

gains = [row["gain_percent"] for row in pairs]
mean = sum(gains) / len(gains)
sd = math.sqrt(sum((x - mean) ** 2 for x in gains) / (len(gains) - 1))
half = T_CRIT_DF9 * sd / math.sqrt(len(gains))
e_mean = sum(row["E_tps"] for row in pairs) / len(pairs)
f_mean = sum(row["F_tps"] for row in pairs) / len(pairs)

with (ROOT / "paired-results.csv").open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(pairs[0]))
    writer.writeheader()
    writer.writerows(pairs)

summary = [
    "pp128 paired gain = 100 * (F avg_ts / E avg_ts - 1).",
    "95% CI = two-sided paired Student-t interval over 10 percentage gains (df=9, t*=2.262157).",
    "Pair order alternated: five E-F and five F-E.",
    f"E mean={e_mean:.4f} tok/s; F mean={f_mean:.4f} tok/s; mean paired gain={mean:+.3f}% "
    f"(95% CI {mean-half:+.3f}% to {mean+half:+.3f}%); paired SD={sd:.3f}%",
]
(ROOT / "paired-summary.txt").write_text("\n".join(summary) + "\n")

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
print("\n".join(summary))
print("\n".join(telemetry_lines))
