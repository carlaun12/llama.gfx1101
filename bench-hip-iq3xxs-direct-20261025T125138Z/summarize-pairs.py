import json
import math
import pathlib
import statistics


root = pathlib.Path(__file__).resolve().parent
sequence = "A B B A B A A B A B B A B A A B A B B A".split()
runs = []
for index, variant in enumerate(sequence, 1):
    path = root / f"{index:02d}-{variant}.json"
    data = json.loads(path.read_text())
    if len(data) != 2:
        raise SystemExit(f"unexpected result count in {path}")
    runs.append({int(item["n_depth"]): float(item["avg_ts"]) for item in data})

if len(runs) != 20:
    raise SystemExit(f"expected 20 runs, got {len(runs)}")

summary = [
    "IQ3_XXS direct-sign A/B",
    "A: IQ3_S and IQ2_S direct, IQ3_XXS packed negation; B: same plus IQ3_XXS direct sign expansion",
    "n=10 adjacent pairs; 95% paired t interval (df=9); t*=2.262157",
]
for depth in (0, 4096):
    a_values = [runs[i][depth] for i, variant in enumerate(sequence) if variant == "A"]
    b_values = [runs[i][depth] for i, variant in enumerate(sequence) if variant == "B"]
    deltas = []
    for i in range(0, len(sequence), 2):
        a_index = i if sequence[i] == "A" else i + 1
        b_index = i if sequence[i] == "B" else i + 1
        deltas.append(100.0 * (runs[b_index][depth] / runs[a_index][depth] - 1.0))
    mean = statistics.mean(deltas)
    sd = statistics.stdev(deltas)
    half = 2.262157 * sd / math.sqrt(len(deltas))
    summary.append(
        f"depth={depth}: A={statistics.mean(a_values):.5f}, B={statistics.mean(b_values):.5f}, "
        f"mean paired delta={mean:+.3f}% (95% CI {mean-half:+.3f} to {mean+half:+.3f}), "
        f"paired SD={sd:.3f}%"
    )
    summary.append("  pairs=" + ", ".join(f"{value:+.3f}%" for value in deltas))

errors = []
for path in sorted(root.glob("[0-9][0-9]-[AB].log")):
    content = path.read_text(errors="replace").lower()
    if "error:" in content or "failed" in content or "aborted" in content:
        errors.append(path.name)
summary.append(f"validated_json={len(runs)}/20; run_errors={len(errors)}")
if errors:
    summary.append("error_logs=" + ", ".join(errors))

(root / "paired-summary.txt").write_text("\n".join(summary) + "\n")
print("\n".join(summary))
