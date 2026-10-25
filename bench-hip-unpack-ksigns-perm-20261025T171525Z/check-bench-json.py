import json
import pathlib

root = pathlib.Path(__file__).resolve().parent
expected = {
    "model_filename": "/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf",
    "n_batch": 2048,
    "n_ubatch": 512,
    "n_threads": 8,
    "type_k": "f16",
    "type_v": "f16",
    "n_gpu_layers": 99,
    "flash_attn": 1,
    "devices": "ROCm0",
    "n_prompt": 0,
    "n_gen": 128,
}
rows = []
sequence = []
errors = []
for index in range(1, 21):
    tag = f"{index:02d}"
    variants = [v for v in ("C", "E") if (root / f"{tag}-{v}.json").exists()]
    if len(variants) != 1:
        errors.append(f"{tag}: expected one variant file, found {variants}")
        continue
    variant = variants[0]
    sequence.append(variant)
    data = json.loads((root / f"{tag}-{variant}.json").read_text())
    for row in data:
        rows.append((index, variant, row))
        for key, value in expected.items():
            if row.get(key) != value:
                errors.append(f"{tag}-{variant}: {key}={row.get(key)!r}, expected {value!r}")
        if row.get("n_depth") not in (0, 4096):
            errors.append(f"{tag}-{variant}: unexpected n_depth={row.get('n_depth')!r}")

print(f"rows={len(rows)} expected=40")
for depth in (0, 4096):
    subset = [row for _, _, row in rows if row["n_depth"] == depth]
    c_count = sum(1 for _, variant, row in rows if variant == "C" and row["n_depth"] == depth)
    e_count = sum(1 for _, variant, row in rows if variant == "E" and row["n_depth"] == depth)
    print(f"depth={depth}: rows={len(subset)} C={c_count} E={e_count}")
print("sequence=" + " ".join(sequence))
print(f"configuration_errors={len(errors)}")
for error in errors:
    print(error)
if len(rows) != 40 or errors:
    raise SystemExit(1)
