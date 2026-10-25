#!/usr/bin/env python3
import csv
import json
import math
import pathlib
import statistics


run_dir = pathlib.Path(__file__).resolve().parent
t_975_df9 = 2.262157
comparisons = (("ab", "A", "B"), ("bc", "B", "C"))


def read_tps(mode, comparison, pair, variant, depth=None):
    path = run_dir / "raw" / f"{mode}-{comparison}-p{pair:02d}-{variant}.json"
    rows = json.loads(path.read_text())
    matches = []
    for row in rows:
        if mode == "tg":
            if row.get("n_prompt") == 0 and row.get("n_gen") == 128 and row.get("n_depth") == depth:
                matches.append(float(row["avg_ts"]))
        elif row.get("n_prompt") == 512 and row.get("n_gen") == 0:
            matches.append(float(row["avg_ts"]))
    if len(matches) != 1:
        raise ValueError(f"expected one result for {path} depth={depth}; found {len(matches)}")
    return matches[0]


def summarize(values):
    mean = statistics.mean(values)
    sd = statistics.stdev(values)
    half = t_975_df9 * sd / math.sqrt(len(values))
    return mean, mean - half, mean + half, sd


results = []
with (run_dir / "paired-results.csv").open("w", newline="") as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(("comparison", "mode", "depth", "pair", "order", "control_tps", "candidate_tps", "gain_percent"))

    for comparison, control, candidate in comparisons:
        for mode in ("tg", "pp"):
            depths = (0, 4096) if mode == "tg" else ("pp512",)
            pair_gain = {}
            for depth in depths:
                gains = []
                control_values = []
                candidate_values = []
                for pair in range(1, 11):
                    case_depth = depth if mode == "tg" else None
                    control_tps = read_tps(mode, comparison, pair, control, case_depth)
                    candidate_tps = read_tps(mode, comparison, pair, candidate, case_depth)
                    gain = (candidate_tps / control_tps - 1.0) * 100.0
                    order = control + candidate if pair % 2 == 1 else candidate + control
                    control_values.append(control_tps)
                    candidate_values.append(candidate_tps)
                    gains.append(gain)
                    pair_gain.setdefault(pair, {})[depth] = gain
                    writer.writerow((comparison.upper(), mode, depth, pair, order, f"{control_tps:.9f}", f"{candidate_tps:.9f}", f"{gain:.9f}"))
                mean, low, high, sd = summarize(gains)
                results.append({
                    "comparison": comparison.upper(), "mode": mode, "depth": depth,
                    "control_mean_tps": statistics.mean(control_values),
                    "candidate_mean_tps": statistics.mean(candidate_values),
                    "gain_mean": mean, "ci_low": low, "ci_high": high, "paired_sd": sd,
                })
            if mode == "tg":
                combined = [statistics.mean(pair_gain[pair][depth] for depth in (0, 4096)) for pair in range(1, 11)]
                mean, low, high, sd = summarize(combined)
                results.append({
                    "comparison": comparison.upper(), "mode": "tg", "depth": "equal-weight d=0/d=4096",
                    "control_mean_tps": None, "candidate_mean_tps": None,
                    "gain_mean": mean, "ci_low": low, "ci_high": high, "paired_sd": sd,
                })

with (run_dir / "paired-summary.md").open("w") as output:
    output.write("# Paired A/B results\n\n")
    output.write("Gains are computed per adjacent pair as `(candidate_tps / control_tps - 1) * 100`. Intervals are two-sided 95% Student-t intervals on the 10 paired percentage gains (`df=9`, `t*=2.262157`). The equal-weight decode summary averages d=0 and d=4096 gains within each pair before calculating its interval. Prefill is reported separately.\n\n")
    output.write("| Comparison | Workload | Control mean | Candidate mean | Paired gain | 95% CI |\n| --- | --- | ---: | ---: | ---: | ---: |\n")
    for row in results:
        if row["mode"] == "tg" and isinstance(row["depth"], int):
            workload = f"tg128, d={row['depth']}"
        elif row["mode"] == "tg":
            workload = "tg128 equal-weight d=0/4096"
        else:
            workload = "pp512"
        control = "-" if row["control_mean_tps"] is None else f"{row['control_mean_tps']:.5f} tok/s"
        candidate = "-" if row["candidate_mean_tps"] is None else f"{row['candidate_mean_tps']:.5f} tok/s"
        output.write(f"| {row['comparison']} | {workload} | {control} | {candidate} | {row['gain_mean']:+.3f}% | [{row['ci_low']:+.3f}%, {row['ci_high']:+.3f}%] |\n")

print((run_dir / "paired-summary.md").read_text())
