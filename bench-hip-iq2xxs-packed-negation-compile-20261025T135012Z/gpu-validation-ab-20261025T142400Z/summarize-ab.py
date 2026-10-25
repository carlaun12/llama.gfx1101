import csv
import json
import math
import pathlib
import re
import statistics


root = pathlib.Path(__file__).resolve().parent
model_path = "/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf"
sequence_lines = (root / "sequence.log").read_text().splitlines()
sequence = [re.fullmatch(r"\d{2}-([AB])", line).group(1) for line in sequence_lines[:20]]
if len(sequence) != 20:
    raise SystemExit(f"expected 20 sequence entries, got {len(sequence)}")

run_results = []
for index, variant in enumerate(sequence, 1):
    path = root / f"{index:02d}-{variant}.json"
    data = json.loads(path.read_text())
    if len(data) != 2:
        raise SystemExit(f"unexpected result count in {path}")
    by_depth = {}
    for item in data:
        depth = int(item["n_depth"])
        if depth in by_depth:
            raise SystemExit(f"duplicate depth {depth} in {path}")
        expected = {
            "model_filename": model_path,
            "n_prompt": 0,
            "n_gen": 128,
            "n_batch": 2048,
            "n_ubatch": 512,
            "n_threads": 8,
            "type_k": "f16",
            "type_v": "f16",
            "n_gpu_layers": 99,
            "flash_attn": 1,
            "devices": "ROCm0",
            "repack": True,
        }
        for key, value in expected.items():
            if item.get(key) != value:
                raise SystemExit(f"{path}: {key}={item.get(key)!r}, expected {value!r}")
        rate = float(item["avg_ts"])
        if rate <= 0 or not math.isfinite(rate):
            raise SystemExit(f"invalid throughput in {path}: {rate}")
        by_depth[depth] = rate
    if set(by_depth) != {0, 4096}:
        raise SystemExit(f"unexpected depth coverage in {path}: {sorted(by_depth)}")
    run_results.append(by_depth)

if len(run_results) != 20:
    raise SystemExit(f"expected 20 runs, got {len(run_results)}")
orders = []
for pair_index in range(10):
    pair = sequence[pair_index * 2:pair_index * 2 + 2]
    if set(pair) != {"A", "B"}:
        raise SystemExit(f"pair {pair_index + 1} is not adjacent A/B: {pair}")
    orders.append("".join(pair))
if orders.count("AB") != 5 or orders.count("BA") != 5:
    raise SystemExit(f"pair order is not balanced: {orders}")

errors = []
for index, variant in enumerate(sequence, 1):
    path = root / f"{index:02d}-{variant}.log"
    content = path.read_text(errors="replace").lower()
    if re.search(r"error:|failed to run|aborted|segmentation fault", content):
        errors.append(path.name)
if errors:
    raise SystemExit("benchmark errors: " + ", ".join(errors))

critical_t = 2.262157
gains_by_depth = {}
summary = [
    "IQ2_XXS packed-negation candidate A/B",
    "A: active control (IQ3_S direct, IQ2_S direct, IQ3_XXS packed negation)",
    "B: same control plus IQ2_XXS packed-negation simplification",
    "tg128, d=0 and d=4096; 10 adjacent pairs per depth; 5 AB and 5 BA pair orders.",
    f"Paired gain=(B/A-1)*100; mean paired percentage and Student-t 95% CI, df=9, t*={critical_t:.6f}.",
]
csv_path = root / "paired-results.csv"
with csv_path.open("w", newline="") as output:
    writer = csv.writer(output)
    writer.writerow(["pair", "order", "depth", "A_tok_s", "B_tok_s", "gain_percent"])
    for depth in (0, 4096):
        a_values = []
        b_values = []
        gains = []
        pair_rows = []
        for pair_index in range(10):
            left = pair_index * 2
            right = left + 1
            a_index = left if sequence[left] == "A" else right
            b_index = left if sequence[left] == "B" else right
            a_rate = run_results[a_index][depth]
            b_rate = run_results[b_index][depth]
            gain = 100.0 * (b_rate / a_rate - 1.0)
            a_values.append(a_rate)
            b_values.append(b_rate)
            gains.append(gain)
            pair_rows.append((pair_index + 1, orders[pair_index], a_rate, b_rate, gain))
            writer.writerow([pair_index + 1, orders[pair_index], depth, f"{a_rate:.6f}", f"{b_rate:.6f}", f"{gain:.6f}"])

        gains_by_depth[depth] = gains
        mean = statistics.mean(gains)
        sd = statistics.stdev(gains)
        half_width = critical_t * sd / math.sqrt(len(gains))
        summary.append(
            f"d={depth}: A mean={statistics.mean(a_values):.5f} tok/s; "
            f"B mean={statistics.mean(b_values):.5f} tok/s; "
            f"mean paired gain={mean:+.3f}% (95% CI {mean-half_width:+.3f}% to {mean+half_width:+.3f}%); "
            f"paired SD={sd:.3f}%"
        )
        summary.append("  pairs: " + ", ".join(
            f"{pair_no:02d}-{order} A={a_rate:.5f} B={b_rate:.5f} gain={gain:+.3f}%"
            for pair_no, order, a_rate, b_rate, gain in pair_rows
        ))

combined = [(a + b) / 2.0 for a, b in zip(gains_by_depth[0], gains_by_depth[4096])]
combined_mean = statistics.mean(combined)
combined_sd = statistics.stdev(combined)
combined_half_width = critical_t * combined_sd / math.sqrt(len(combined))
summary.append(
    f"equal-weight d=0/d=4096 aggregate: mean paired gain={combined_mean:+.3f}% "
    f"(95% CI {combined_mean-combined_half_width:+.3f}% to {combined_mean+combined_half_width:+.3f}%), "
    "computed from 10 pair-level averages to preserve pairing."
)
summary.append("  pair aggregate gains: " + ", ".join(f"{value:+.3f}%" for value in combined))
summary.append("valid_json=20/20; depths=20/20 per scenario; run_errors=0")
(root / "paired-summary.txt").write_text("\n".join(summary) + "\n")
print("\n".join(summary))
