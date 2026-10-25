#!/usr/bin/env python3
import json
import pathlib
import re
import sys


run_dir = pathlib.Path(__file__).resolve().parent
variants = ("A", "B", "C")
keys = (
    "CMAKE_BUILD_TYPE",
    "CMAKE_C_COMPILER:UNINITIALIZED",
    "CMAKE_CXX_COMPILER:UNINITIALIZED",
    "CMAKE_HIP_COMPILER:UNINITIALIZED",
    "CMAKE_PREFIX_PATH:UNINITIALIZED",
    "GGML_CUDA:BOOL",
    "GGML_HIP:BOOL",
    "GPU_TARGETS:UNINITIALIZED",
    "GGML_VULKAN:BOOL",
    "GGML_NATIVE:BOOL",
    "GGML_HIP_GRAPHS:BOOL",
    "GGML_HIP_MMQ_MFMA:BOOL",
    "GGML_HIP_NO_VMM:BOOL",
    "LLAMA_BUILD_TESTS:BOOL",
    "LLAMA_BUILD_EXAMPLES:BOOL",
    "LLAMA_BUILD_SERVER:BOOL",
    "LLAMA_BUILD_APP:BOOL",
)
changed = False
summary = []

for variant in variants:
    cache_path = run_dir / f"CMakeCache-{variant}.txt"
    cache = {}
    for line in cache_path.read_text().splitlines():
        match = re.match(r"([^:#]+):[^=]+=(.*)$", line)
        if match:
            cache[match.group(1)] = match.group(2)
    settings = {}
    for key in keys:
        name = key.split(":", 1)[0]
        settings[name] = cache.get(name, "<missing>")
    summary.append((variant, settings))

for key in summary[0][1]:
    values = [settings[key] for _, settings in summary]
    if len(set(values)) != 1:
        changed = True
        print(f"CMake mismatch {key}: {values}")

compile_names = (
    "/ggml-cuda/mmvq.cu",
    "/ggml-cuda/template-instances/mmq-instance-iq2_s.cu",
    "/ggml-cuda/template-instances/mmq-instance-iq3_s.cu",
    "/ggml-cuda/template-instances/mmq-instance-iq3_xxs.cu",
    "/ggml-cuda/template-instances/mmq-instance-iq2_xxs.cu",
)
normalized = {}
for variant in variants:
    source_root = str(run_dir / "source" / variant)
    build_root = str(run_dir / "build" / variant)
    entries = json.loads((run_dir / f"compile_commands-{variant}.json").read_text())
    by_name = {}
    for entry in entries:
        filepath = entry["file"]
        if not any(filepath.endswith(name) for name in compile_names):
            continue
        command = entry.get("command")
        if command is None:
            command = " ".join(entry["arguments"])
        command = command.replace(source_root, "<SOURCE>").replace(build_root, "<BUILD>")
        by_name[pathlib.Path(filepath).name] = command
    normalized[variant] = by_name
    if len(by_name) != len(compile_names):
        changed = True
        print(f"{variant} missing expected compile entries: {sorted(set(compile_names))} vs {sorted(by_name)}")

for name in normalized["A"]:
    commands = [normalized[variant].get(name) for variant in variants]
    if len(set(commands)) != 1:
        changed = True
        print(f"Compile command mismatch {name}")
        for variant, command in zip(variants, commands):
            print(f"  {variant}: {command}")

with (run_dir / "normalized-build-settings.txt").open("w") as output:
    for variant, settings in summary:
        output.write(f"[{variant}]\n")
        for key, value in settings.items():
            output.write(f"{key}={value}\n")
        for name in sorted(normalized[variant]):
            output.write(f"compile:{name}={normalized[variant][name]}\n")

if changed:
    sys.exit("Variant build settings or target compile commands differ")
print("PASS: A/B/C CMake settings match and normalized HIP compile commands match for mmvq plus four quantized MMQ instances")
