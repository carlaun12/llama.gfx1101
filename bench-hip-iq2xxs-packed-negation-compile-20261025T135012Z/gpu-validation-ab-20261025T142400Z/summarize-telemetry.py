import datetime
import json
import pathlib
import re
import statistics


root = pathlib.Path(__file__).resolve().parent
timestamp = None
samples = []
for line in (root / "telemetry.log").read_text(errors="replace").splitlines():
    match = re.match(r"(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ)$", line.strip())
    if match:
        timestamp = datetime.datetime.fromisoformat(match.group(1).replace("Z", "+00:00"))
        continue
    if not line.lstrip().startswith("{"):
        continue
    data = json.loads(line)
    item = data.get("card0")
    if item is None or timestamp is None:
        continue

    def number(name):
        return float(item[name])

    def clock(name):
        return float(item[name].strip("()Mhz"))

    samples.append({
        "time": timestamp,
        "busy": number("GPU use (%)"),
        "power": number("Average Graphics Package Power (W)"),
        "sclk": clock("sclk clock speed:"),
        "mclk": clock("mclk clock speed:"),
        "fclk": clock("fclk clock speed:"),
        "edge": number("Temperature (Sensor edge) (C)"),
        "junction": number("Temperature (Sensor junction) (C)"),
        "memory": number("Temperature (Sensor memory) (C)"),
    })

starts = []
for line in (root / "sequence.log").read_text().splitlines()[20:]:
    match = re.fullmatch(r"(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ) (\d\d)-([AB])", line)
    if match:
        starts.append((
            datetime.datetime.fromisoformat(match.group(1).replace("Z", "+00:00")),
            int(match.group(2)), match.group(3),
        ))
if len(starts) != 20:
    raise SystemExit(f"expected 20 timed runs, got {len(starts)}")

busy = [sample for sample in samples if sample["busy"] >= 95]
if not busy:
    raise SystemExit("no busy GPU telemetry samples")

summary = [
    f"telemetry_samples={len(samples)}; busy_samples={len(busy)} (GPU use >= 95%)",
    f"utilization_percent: min={min(s['busy'] for s in busy):.0f}, max={max(s['busy'] for s in busy):.0f}",
    f"power_w: min={min(s['power'] for s in busy):.0f}, max={max(s['power'] for s in busy):.0f}, "
    f"samples_above_190W={sum(s['power'] > 190.0 for s in busy)}/{len(busy)}",
]
for key, label in (("sclk", "sclk_mhz"), ("mclk", "mclk_mhz"), ("fclk", "fclk_mhz"),
                   ("edge", "edge_temp_c"), ("junction", "junction_temp_c"), ("memory", "memory_temp_c")):
    values = [sample[key] for sample in busy]
    summary.append(f"{label}: min={min(values):.0f}, max={max(values):.0f}")

by_variant = {"A": [], "B": []}
for index, (start, sample_no, variant) in enumerate(starts):
    end = starts[index + 1][0] if index + 1 < len(starts) else datetime.datetime.max.replace(tzinfo=datetime.timezone.utc)
    group = [sample for sample in busy if start <= sample["time"] < end]
    if not group:
        summary.append(f"{sample_no:02d}-{variant}: no busy telemetry samples")
        continue
    by_variant[variant].extend(group)
    summary.append(
        f"{sample_no:02d}-{variant}: busy_samples={len(group)}, "
        f"mean_power={statistics.mean(s['power'] for s in group):.1f}W, "
        f"mean_sclk={statistics.mean(s['sclk'] for s in group):.0f}MHz, "
        f"max_junction={max(s['junction'] for s in group):.0f}C, "
        f"max_memory={max(s['memory'] for s in group):.0f}C"
    )

for variant in ("A", "B"):
    group = by_variant[variant]
    summary.append(
        f"{variant} aggregate: busy_samples={len(group)}, "
        f"mean_power={statistics.mean(s['power'] for s in group):.2f}W, "
        f"mean_sclk={statistics.mean(s['sclk'] for s in group):.1f}MHz, "
        f"mean_fclk={statistics.mean(s['fclk'] for s in group):.1f}MHz, "
        f"mean_junction={statistics.mean(s['junction'] for s in group):.1f}C, "
        f"samples_above_190W={sum(s['power'] > 190.0 for s in group)}"
    )

(root / "telemetry-summary.txt").write_text("\n".join(summary) + "\n")
print("\n".join(summary))
