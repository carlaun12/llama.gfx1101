import json
import pathlib


root = pathlib.Path(__file__).resolve().parent
samples = []
for line in (root / "telemetry.log").read_text(errors="replace").splitlines():
    if not line.startswith("{"):
        continue
    item = json.loads(line)["card0"]
    sample = {
        "busy": float(item["GPU use (%)"]),
        "power": float(item["Average Graphics Package Power (W)"]),
        "sclk": float(item["sclk clock speed:"].strip("()Mhz")),
        "junction": float(item["Temperature (Sensor junction) (C)"]),
        "memory": float(item["Temperature (Sensor memory) (C)"]),
    }
    if sample["busy"] >= 95:
        samples.append(sample)

if not samples:
    raise SystemExit("no busy GPU samples found")

lines = [f"busy_samples={len(samples)} (GPU use >= 95%)"]
above_cap = sum(sample["power"] > 190.0 for sample in samples)
lines.append(f"samples_above_reported_190W_cap={above_cap}/{len(samples)}")
for key, label in (("power", "graphics_package_power_w"), ("sclk", "sclk_mhz"),
                   ("junction", "junction_temp_c"), ("memory", "memory_temp_c")):
    values = [sample[key] for sample in samples]
    lines.append(f"{label}: min={min(values):.0f}, max={max(values):.0f}")

(root / "telemetry-summary.txt").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
