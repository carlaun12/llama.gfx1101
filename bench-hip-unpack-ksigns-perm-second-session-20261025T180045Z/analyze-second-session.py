import csv
import json
import math
import pathlib
import re
import statistics

root = pathlib.Path(__file__).resolve().parent
model = "/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf"
t975_df9 = 2.262157
expected = {
    "model_filename": model,
    "n_batch": 2048,
    "n_ubatch": 512,
    "n_threads": 8,
    "type_k": "f16",
    "type_v": "f16",
    "n_gpu_layers": 99,
    "flash_attn": 1,
    "devices": "ROCm0",
}


def read_rows(mode, pair, variant):
    path = root / "raw" / f"{mode}-p{pair:02d}-{variant}.json"
    rows = json.loads(path.read_text())
    for row in rows:
        for key, value in expected.items():
            if row.get(key) != value:
                raise ValueError(f"{path}: {key}={row.get(key)!r}, expected {value!r}")
    return rows


def get_tps(mode, pair, variant, depth):
    rows = read_rows(mode, pair, variant)
    if mode == "tg":
        found = [r for r in rows if r.get("n_prompt") == 0 and r.get("n_gen") == 128 and r.get("n_depth") == depth]
    else:
        found = [r for r in rows if r.get("n_prompt") == 512 and r.get("n_gen") == 0 and r.get("n_depth") == 0]
    if len(found) != 1:
        raise ValueError(f"{mode} pair {pair} {variant} depth {depth}: expected one JSON result, found {len(found)}")
    return float(found[0]["avg_ts"])


config_rows = 0
for mode, expected_cases in (("tg", {(0, 128, 0), (0, 128, 4096)}), ("pp", {(512, 0, 0)})):
    for pair in range(1, 11):
        for variant in ("C", "E"):
            rows = read_rows(mode, pair, variant)
            actual_cases = {(r.get("n_prompt"), r.get("n_gen"), r.get("n_depth")) for r in rows}
            if actual_cases != expected_cases or len(rows) != len(expected_cases):
                raise ValueError(f"{mode} pair {pair} {variant}: unexpected cases {actual_cases}")
            config_rows += len(rows)
if config_rows != 60:
    raise ValueError(f"expected 60 result rows, found {config_rows}")
for pair in range(1, 11):
    order = "CE" if pair % 2 else "EC"
    expected_order = [f"{mode}-p{pair:02d}-{variant}" for mode in ("tg", "pp") for variant in order]
    if not all((root / "raw" / f"{sample}.json").is_file() for sample in expected_order):
        raise ValueError(f"missing an alternating pair {pair}: {expected_order}")


def summarize(gains):
    mean = statistics.mean(gains)
    sd = statistics.stdev(gains)
    half = t975_df9 * sd / math.sqrt(len(gains))
    return mean, mean - half, mean + half


results = []
pair_gains = {}
with (root / "paired-results.csv").open("w", newline="") as stream:
    writer = csv.writer(stream)
    writer.writerow(("workload", "depth", "pair", "order", "C_tps", "E_tps", "gain_percent"))
    for mode, depths in (("tg", (0, 4096)), ("pp", ("pp512",))):
        for depth in depths:
            gains = []
            c_values = []
            e_values = []
            for pair in range(1, 11):
                data_depth = depth if mode == "tg" else None
                c = get_tps(mode, pair, "C", data_depth)
                e = get_tps(mode, pair, "E", data_depth)
                gain = (e / c - 1.0) * 100.0
                order = "CE" if pair % 2 else "EC"
                writer.writerow((mode, depth, pair, order, f"{c:.9f}", f"{e:.9f}", f"{gain:.9f}"))
                gains.append(gain)
                c_values.append(c)
                e_values.append(e)
                pair_gains.setdefault(pair, {})[depth] = gain
            mean, low, high = summarize(gains)
            results.append((mode, depth, statistics.mean(c_values), statistics.mean(e_values), mean, low, high, gains))

decode_gains = [statistics.mean((pair_gains[p][0], pair_gains[p][4096])) for p in range(1, 11)]
decode_mean, decode_low, decode_high = summarize(decode_gains)

out = [
    "Second C/E session: 10 adjacent pairs each for tg128 d=0, tg128 d=4096, and pp512.",
    "Order alternated by pair: odd CE, even EC. Gain = 100 * (E/C - 1) using avg_ts.",
    "Intervals: two-sided paired Student t, 95%, n=10, df=9, t*=2.262157.",
    "All JSON rows were checked against the expected model, offload, batch, cache, thread, and flash-attention settings.",
    f"JSON case coverage: {config_rows}/60 rows; exact cases per run were verified.",
    "",
    "| Workload | C mean tok/s | E mean tok/s | Paired gain | 95% CI |",
    "| --- | ---: | ---: | ---: | ---: |",
]
for mode, depth, c_mean, e_mean, mean, low, high, gains in results:
    workload = f"tg128 d={depth}" if mode == "tg" else "pp512"
    out.append(f"| {workload} | {c_mean:.5f} | {e_mean:.5f} | {mean:+.3f}% | [{low:+.3f}%, {high:+.3f}%] |")
out.append(f"| tg128 equal-weight d=0/4096 | - | - | {decode_mean:+.3f}% | [{decode_low:+.3f}%, {decode_high:+.3f}%] |")
out.extend(["", "Per-pair gains:"])
for mode, depth, _, _, _, _, _, gains in results:
    label = f"tg128 d={depth}" if mode == "tg" else "pp512"
    out.append(f"- {label}: " + ", ".join(f"{x:+.3f}%" for x in gains))
out.append("- tg128 equal-weight d=0/4096: " + ", ".join(f"{x:+.3f}%" for x in decode_gains))
(root / "paired-summary.md").write_text("\n".join(out) + "\n")

sample_count = 0
telemetry = {"C": [], "E": []}
raw = (root / "telemetry.jsonl").read_text().splitlines()
for i in range(0, len(raw) - 1, 2):
    stage = json.loads(raw[i])
    sample = json.loads(raw[i + 1])
    match = re.search(r"\b([CE])\b", stage.get("stage", ""))
    if not match or "card0" not in sample:
        continue
    card = sample["card0"]
    def number(key):
        value = card.get(key)
        if value is None:
            return None
        m = re.search(r"-?\d+(?:\.\d+)?", str(value))
        return float(m.group()) if m else None
    item = {
        "gpu_use": number("GPU use (%)"),
        "power": number("Average Graphics Package Power (W)"),
        "sclk": number("sclk clock speed:"),
        "edge": number("Temperature (Sensor edge) (C)"),
        "junction": number("Temperature (Sensor junction) (C)"),
        "memory": number("Temperature (Sensor memory) (C)"),
    }
    telemetry[match.group(1)].append(item)
    sample_count += 1

telemetry_lines = [f"Captured telemetry samples with C/E run-stage tags: {sample_count}."]
telemetry_lines.append("Busy means GPU use >=95%; power and clocks below are summarized over busy samples.")
for variant, items in telemetry.items():
    busy = [x for x in items if x["gpu_use"] is not None and x["gpu_use"] >= 95]
    def values(name):
        return [x[name] for x in busy if x[name] is not None]
    telemetry_lines.append(f"{variant}: tagged={len(items)}, busy={len(busy)}")
    for name in ("power", "sclk", "edge", "junction", "memory"):
        vals = values(name)
        if vals:
            telemetry_lines.append(f"  {name}: mean={statistics.mean(vals):.1f}; range={min(vals):.1f}-{max(vals):.1f}")
(root / "telemetry-summary.txt").write_text("\n".join(telemetry_lines) + "\n")
print((root / "paired-summary.md").read_text())
print((root / "telemetry-summary.txt").read_text())
