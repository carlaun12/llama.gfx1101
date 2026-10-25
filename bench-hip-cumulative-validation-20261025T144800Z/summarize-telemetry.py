#!/usr/bin/env python3
import datetime
import json
import pathlib
import re
import statistics


run_dir = pathlib.Path(__file__).resolve().parent
time_pattern = re.compile(r"(2026-\d\d-\d\dT\d\d:\d\d:\d\dZ)")
mhz_pattern = re.compile(r"(-?\d+(?:\.\d+)?)")


def read_samples(path):
    samples = []
    current_time = None
    for line in pathlib.Path(path).read_text(errors="replace").splitlines():
        time_match = time_pattern.search(line)
        if time_match:
            current_time = datetime.datetime.fromisoformat(time_match.group(1).replace("Z", "+00:00"))
        if not line.startswith('{"card0"'):
            continue
        try:
            data = json.loads(line)["card0"]
        except (json.JSONDecodeError, KeyError):
            continue

        def number(key):
            value = data.get(key)
            if value is None:
                return None
            match = mhz_pattern.search(str(value))
            return float(match.group(1)) if match else None

        if current_time is not None:
            samples.append({
                "time": current_time,
                "util": number("GPU use (%)"),
                "power": number("Average Graphics Package Power (W)"),
                "sclk": number("sclk clock speed:"),
                "mclk": number("mclk clock speed:"),
                "fclk": number("fclk clock speed:"),
                "edge": number("Temperature (Sensor edge) (C)"),
                "junction": number("Temperature (Sensor junction) (C)"),
                "memory": number("Temperature (Sensor memory) (C)"),
            })
    return samples


def describe(samples):
    busy = [sample for sample in samples if (sample["util"] or 0) >= 95]
    result = {"all": len(samples), "busy": len(busy)}
    for key in ("util", "power", "sclk", "mclk", "fclk", "edge", "junction", "memory"):
        values = [sample[key] for sample in busy if sample[key] is not None]
        if values:
            result[key] = {
                "mean": statistics.mean(values),
                "min": min(values),
                "max": max(values),
                "above_190": sum(value > 190 for value in values) if key == "power" else None,
            }
    return busy, result


current_samples = read_samples(run_dir / "telemetry.log")
busy_samples, overall = describe(current_samples)
events = {}
for line in (run_dir / "sequence.log").read_text().splitlines():
    match = re.match(r"(\S+) (start|end) (\S+)", line)
    if not match:
        continue
    timestamp, action, sample_id = match.groups()
    moment = datetime.datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    events.setdefault(sample_id, {})[action] = moment

by_group = {}
for sample in busy_samples:
    active_id = None
    for sample_id, interval in events.items():
        if "start" in interval and interval["start"] <= sample["time"] <= interval.get("end", interval["start"]):
            active_id = sample_id
            break
    if active_id is None:
        continue
    parts = active_id.split("-")
    mode, comparison, pair, variant = parts[0], parts[1], parts[2], parts[3]
    by_group.setdefault((mode, variant), []).append(sample)

historical = {
    "IQ3_XXS direct session 13:02": read_samples(run_dir.parent / "bench-hip-iq3xxs-direct-20261025T125138Z/telemetry.log"),
    "IQ2_XXS validation session 14:32": read_samples(run_dir.parent / "bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/gpu-validation-ab-20261025T142400Z/telemetry.log"),
}
historical_summaries = {name: describe(samples)[1] for name, samples in historical.items()}

with (run_dir / "telemetry-summary.md").open("w") as output:
    output.write("# GPU telemetry summary\n\n")
    output.write("Busy samples use GPU utilization >=95%. RX 7800 XT reports `Average Graphics Package Power`; repeated readings exceeded the configured/reported 190 W power cap. No clock or power limit was changed by this experiment.\n\n")
    output.write("| Session / variant | Busy samples | Mean power | Mean SCLK | Mean junction | Power >190 W | Ranges (power / SCLK / junction / memory) |\n| --- | ---: | ---: | ---: | ---: | ---: | --- |\n")

    def row(name, stats):
        power = stats.get("power", {})
        sclk = stats.get("sclk", {})
        junction = stats.get("junction", {})
        memory = stats.get("memory", {})
        power_gt = f"{power.get('above_190', 0)}/{stats['busy']}" if power else "-"
        ranges = f"{power.get('min', 0):.0f}-{power.get('max', 0):.0f} W / {sclk.get('min', 0):.0f}-{sclk.get('max', 0):.0f} MHz / {junction.get('min', 0):.0f}-{junction.get('max', 0):.0f} C / {memory.get('min', 0):.0f}-{memory.get('max', 0):.0f} C"
        output.write(f"| {name} | {stats['busy']} | {power.get('mean', 0):.1f} W | {sclk.get('mean', 0):.1f} MHz | {junction.get('mean', 0):.1f} C | {power_gt} | {ranges} |\n")

    row("Cumulative session, all", overall)
    for key in sorted(by_group):
        _, stats = describe(by_group[key])
        row(f"Cumulative session, {key[0]} / {key[1]}", stats)
    for name, stats in historical_summaries.items():
        row(name, stats)

    output.write("\nThe current A/B/C sessions were interleaved by pair. Per-variant telemetry includes only samples attributed to that variant's benchmark interval. Historical session totals are less precise for per-variant attribution, but are adequate to compare overall device state.\n")

print((run_dir / "telemetry-summary.md").read_text())
