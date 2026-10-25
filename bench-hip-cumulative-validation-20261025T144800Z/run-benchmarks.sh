#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-cumulative-validation-20261025T144800Z"
build_dir="$repo_dir/build-hip-baseline"
bench="$build_dir/bin/llama-bench"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf

common_args=(-m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16
    -b 2048 -ub 512 -t 8 -r 1 -o json --progress)
tg_args=("${common_args[@]}" -p 0 -n 128 -d 0,4096)
pp_args=("${common_args[@]}" -p 512 -n 0 -d 0)

mkdir -p "$run_dir/raw"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/benchmark-start-time.txt"
sha256sum "$bench" "$model_path" > "$run_dir/benchmark-model-hashes.txt"
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/power-before.txt" 2>&1
printf 'HIP_VISIBLE_DEVICES=%s\nROCR_VISIBLE_DEVICES=%s\nHSA_OVERRIDE_GFX_VERSION=%s\nGGML_CUDA_FORCE_MMQ=%s\nGGML_CUDA_FORCE_CUBLAS=%s\nGGML_CUDA_DISABLE_GRAPHS=%s\n' \
    "${HIP_VISIBLE_DEVICES-<unset>}" "${ROCR_VISIBLE_DEVICES-<unset>}" \
    "${HSA_OVERRIDE_GFX_VERSION-<unset>}" "${GGML_CUDA_FORCE_MMQ-<unset>}" \
    "${GGML_CUDA_FORCE_CUBLAS-<unset>}" "${GGML_CUDA_DISABLE_GRAPHS-<unset>}" \
    > "$run_dir/runtime-environment.txt"

for variant in A B C; do
    library_dir="$run_dir/library/$variant"
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    loader_log="$run_dir/loader-llama-bench-$variant.txt"
    LD_LIBRARY_PATH="$library_path" ldd "$bench" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
done

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

run_one() {
    local mode="$1"
    local comparison="$2"
    local pair="$3"
    local variant="$4"
    local order="$5"
    local sample_id
    printf -v sample_id '%s-%s-p%02d-%s' "$mode" "$comparison" "$pair" "$variant"
    local library_dir="$run_dir/library/$variant"
    local library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    local -a args
    if [[ "$mode" == tg ]]; then
        args=("${tg_args[@]}")
    else
        args=("${pp_args[@]}")
    fi

    printf '%s start %s order=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" "$order" \
        | tee -a "$run_dir/sequence.log"
    printf '%q ' env "LD_LIBRARY_PATH=$library_path" "$bench" "${args[@]}" \
        > "$run_dir/raw/$sample_id.command.txt"
    printf '\n' >> "$run_dir/raw/$sample_id.command.txt"
    if ! LD_LIBRARY_PATH="$library_path" "$bench" "${args[@]}" \
        > "$run_dir/raw/$sample_id.json" 2> "$run_dir/raw/$sample_id.log"; then
        printf '%s failed %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" \
            | tee -a "$run_dir/sequence.log"
        return 1
    fi
    printf '%s end %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" \
        >> "$run_dir/sequence.log"
}

printf 'llama-bench internal warmup remains enabled: one prompt warmup for pp512 and one generation warmup per tg128 depth case.\n' \
    > "$run_dir/warmup-policy.txt"
printf '%q ' "$bench" "${tg_args[@]}" > "$run_dir/tg-command-template.txt"
printf '\n' >> "$run_dir/tg-command-template.txt"
printf '%q ' "$bench" "${pp_args[@]}" > "$run_dir/pp-command-template.txt"
printf '\n' >> "$run_dir/pp-command-template.txt"

: > "$run_dir/sequence.log"
for pair in $(seq 1 10); do
    if (( pair % 2 == 1 )); then
        run_one tg ab "$pair" A AB
        run_one tg ab "$pair" B AB
        run_one tg bc "$pair" B BC
        run_one tg bc "$pair" C BC
    else
        run_one tg ab "$pair" B BA
        run_one tg ab "$pair" A BA
        run_one tg bc "$pair" C CB
        run_one tg bc "$pair" B CB
    fi
done

for pair in $(seq 1 10); do
    if (( pair % 2 == 1 )); then
        run_one pp ab "$pair" A AB
        run_one pp ab "$pair" B AB
        run_one pp bc "$pair" B BC
        run_one pp bc "$pair" C BC
    else
        run_one pp ab "$pair" B BA
        run_one pp ab "$pair" A BA
        run_one pp bc "$pair" C CB
        run_one pp bc "$pair" B CB
    fi
done

rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/power-after.txt" 2>&1
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/benchmark-end-time.txt"
