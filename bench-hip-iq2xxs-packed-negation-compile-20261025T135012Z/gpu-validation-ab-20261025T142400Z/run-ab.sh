#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/gpu-validation-ab-20261025T142400Z"
build_dir="$repo_dir/build-hip-baseline"
bench="$build_dir/bin/llama-bench"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
sequence=(A B B A A B B A A B B A A B B A A B B A)
sample=1

bench_args=(-m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16
    -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096)

printf '%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$run_dir/ab-start-time.txt"
git -C "$repo_dir" rev-parse HEAD > "$run_dir/commit.txt"
git -C "$repo_dir" status --short > "$run_dir/git-status-before.txt"
sha256sum "$bench" "$model_path" \
    "$run_dir/control-library/libggml-hip.so.0.27.0" \
    "$run_dir/candidate-library/libggml-hip.so.0.27.0" \
    > "$run_dir/ab-binary-model-hashes.txt"
rocm-smi --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/power-before.txt" 2>&1

for variant in control candidate; do
    library_dir="$run_dir/$variant-library"
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    loader_log="$run_dir/$variant-llama-bench-loader.txt"
    LD_LIBRARY_PATH="$library_path" ldd "$bench" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
done

printf '%s\n' "${sequence[@]}" | awk '{ printf "%02d-%s\n", NR, $0 }' > "$run_dir/sequence.log"
printf '%s\n' "llama-bench internal warmup remains enabled for each case; one generation warmup token per invocation and depth case." \
    > "$run_dir/warmup-policy.txt"
printf '%q ' "$bench" "${bench_args[@]}" > "$run_dir/benchmark-command.txt"
printf '\n' >> "$run_dir/benchmark-command.txt"

telemetry() {
    while true; do
        printf '%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        rocm-smi --json --showpower --showtemp --showclocks --showuse
        sleep 1
    done
}
telemetry > "$run_dir/telemetry.log" 2>&1 &
telemetry_pid=$!
cleanup() {
    kill "$telemetry_pid" 2>/dev/null || true
    wait "$telemetry_pid" 2>/dev/null || true
}
trap cleanup EXIT

for variant in "${sequence[@]}"; do
    printf -v sample_id '%02d-%s' "$sample" "$variant"
    printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" >> "$run_dir/sequence.log"
    if [[ "$variant" == A ]]; then
        library_dir="$run_dir/control-library"
    else
        library_dir="$run_dir/candidate-library"
    fi
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    printf '%q ' env "LD_LIBRARY_PATH=$library_path" "$bench" "${bench_args[@]}" \
        > "$run_dir/$sample_id.command.txt"
    printf '\n' >> "$run_dir/$sample_id.command.txt"
    if ! LD_LIBRARY_PATH="$library_path" "$bench" "${bench_args[@]}" \
        > "$run_dir/$sample_id.json" 2> "$run_dir/$sample_id.log"; then
        printf 'Run failed: %s\n' "$sample_id" >&2
        exit 1
    fi
    sample=$((sample + 1))
done

rocm-smi --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/power-after.txt" 2>&1
printf '%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$run_dir/ab-end-time.txt"
