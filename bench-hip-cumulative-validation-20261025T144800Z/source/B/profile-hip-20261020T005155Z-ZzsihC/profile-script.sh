#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
model_path="${1:-$HOME/slop/Qwen3.8-27B-UD-IQ3_XXS.gguf}"
build_dir="$repo_dir/build-hip-baseline"
profiler="${ROCPROFV3:-/opt/rocm/bin/rocprofv3}"

if [[ ! -x "$profiler" ]]; then
    profiler="$(command -v rocprofv3 || true)"
fi
if [[ ! -x "$profiler" ]]; then
    printf 'rocprofv3 is missing. On Arch Linux install the rocprofiler package.\n' >&2
    exit 1
fi
if [[ ! -r /dev/kfd || ! -w /dev/kfd ]]; then
    printf 'Run this script in a terminal with HIP access to the GPU (/dev/kfd).\n' >&2
    exit 1
fi
if [[ ! -r "$model_path" || ! -f "$build_dir/CMakeCache.txt" ]]; then
    printf 'Model or HIP baseline build is missing. Run the baseline script first.\n' >&2
    exit 1
fi

run_dir="$(mktemp -d "$repo_dir/profile-hip-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")"
printf 'Profile: %s\nKeep the GPU at 190 W, as in the baseline.\n' "$run_dir"
cmake --build "$build_dir" --target llama-bench -j "${BUILD_JOBS:-4}" \
    > "$run_dir/build.log" 2>&1
bench="$build_dir/bin/llama-bench"
"$bench" --list-devices > "$run_dir/devices.txt" 2>&1
if ! rg -q 'ROCm0:.*7800 XT' "$run_dir/devices.txt"; then
    printf 'Expected RX 7800 XT at ROCm0; see %s\n' "$run_dir/devices.txt" >&2
    exit 1
fi

{
    date -u --iso-8601=seconds
    git -C "$repo_dir" rev-parse HEAD
    git -C "$repo_dir" status --short
    "$profiler" --version
    printf '\nPower caps (microwatts):\n'
    for power_file in /sys/class/drm/card*/device/hwmon/hwmon*/power1_cap; do
        if [[ -r "$power_file" ]]; then
            printf '%s: ' "$power_file"
            cat "$power_file"
        fi
    done
} > "$run_dir/environment.txt" 2>&1
git -C "$repo_dir" diff HEAD > "$run_dir/source.diff"
cp "$build_dir/CMakeCache.txt" "$run_dir/CMakeCache.txt"
sha256sum "$bench" "$build_dir/bin/libggml-hip.so" > "$run_dir/binaries.sha256"
cp -- "${BASH_SOURCE[0]}" "$run_dir/profile-script.sh"

# Decode only: no prompt/depth prefill. One warmup token and setup are also traced.
# Keep HIP graphs and fusion settings unchanged from the normal benchmark.
profile_args=(--kernel-trace --stats --output-format csv
    --output-directory "$run_dir/trace" --output-file generation --
    "$bench" -m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16
    -b 2048 -ub 512 -t 8 -r 1 -p 0 -n 128 -d 0 -o json --progress)
printf '%q ' "$profiler" "${profile_args[@]}" > "$run_dir/command.txt"
printf '\n' >> "$run_dir/command.txt"
"$profiler" "${profile_args[@]}" > "$run_dir/profiler.stdout.log" 2> "$run_dir/profiler.stderr.log"

python3 "$repo_dir/scripts/summarize-hip-profile.py" "$run_dir" \
    | tee "$run_dir/summary.txt"
printf 'Profile complete: %s\n' "$run_dir"
