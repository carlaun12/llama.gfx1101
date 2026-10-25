#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-iq3s-two-accumulators-20261025T164820Z"
build_dir="$repo_dir/build-hip-baseline"
control_dir="$repo_dir/bench-hip-cumulative-validation-20261025T144800Z/library/C"
candidate_dir="$run_dir/library/D"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
bench="$build_dir/bin/llama-bench"
sequence=(C D D C D C C D C D D C D C C D C D D C)
sample=1

sha256sum "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0" \
    "$control_dir/libggml-hip.so.0.27.0" \
    "$candidate_dir/libggml-hip.so.0.27.0" "$bench" "$model_path" > "$run_dir/binary-hashes.txt"
rocm-smi --showmaxpower --showpower --showtemp --showclocks --showuse > "$run_dir/telemetry-before.txt"
for variant in C D; do
    if [[ "$variant" == C ]]; then library_dir="$control_dir"; else library_dir="$candidate_dir"; fi
    loader_log="$run_dir/loader-llama-bench-$variant.txt"
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    LD_LIBRARY_PATH="$library_path" ldd "$bench" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
done
printf 'stage\n' > "$run_dir/telemetry-stage.txt"
python3 "$run_dir/collect_telemetry.py" > "$run_dir/telemetry.jsonl" 2> "$run_dir/telemetry.stderr" &
telemetry_pid=$!
trap 'kill "$telemetry_pid" 2>/dev/null || true' EXIT

for variant in "${sequence[@]}"; do
    printf -v sample_id '%02d-%s' "$sample" "$variant"
    printf '%s\n' "$sample_id"
    printf '%s\n' "$sample_id" > "$run_dir/telemetry-stage.txt"
    if [[ "$variant" == C ]]; then library_dir="$control_dir"; else library_dir="$candidate_dir"; fi
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    printf 'env LD_LIBRARY_PATH=%s %s -m %s -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096\n' \
        "$library_path" "$bench" "$model_path" > "$run_dir/$sample_id.command.txt"
    LD_LIBRARY_PATH="$library_path" "$bench" \
        -m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 \
        -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096 \
        > "$run_dir/$sample_id.json" 2> "$run_dir/$sample_id.log"
    sample=$((sample + 1))
done
printf 'complete\n' > "$run_dir/telemetry-stage.txt"
kill "$telemetry_pid" 2>/dev/null || true
wait "$telemetry_pid" 2>/dev/null || true
trap - EXIT
rocm-smi --showmaxpower --showpower --showtemp --showclocks --showuse > "$run_dir/telemetry-after.txt"
printf 'MTP: disabled; llama-bench defaults load_mtp=false and no draft/MTP option was passed.\n' > "$run_dir/mtp-runtime.txt"
