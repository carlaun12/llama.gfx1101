#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-unpack-ksigns-perm-second-session-20261025T180045Z"
first_run="$repo_dir/bench-hip-unpack-ksigns-perm-20261025T171525Z"
build_dir="$repo_dir/build-hip-baseline"
control_dir="$first_run/library/C"
candidate_dir="$first_run/library/E"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
bench="$build_dir/bin/llama-bench"
expected_c_source=4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83
expected_c_library=a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8
expected_e_source=9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c
expected_e_library=ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24
expected_bench=39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25
expected_model=e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803

hash_of() { sha256sum "$1" | awk '{print $1}'; }
check_hash() {
    local path="$1" expected="$2" label="$3" actual
    actual=$(hash_of "$path")
    if [[ "$actual" != "$expected" ]]; then
        printf 'Hash mismatch for %s: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}

check_hash "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" "$expected_c_source" 'active C source'
check_hash "$build_dir/bin/libggml-hip.so.0.27.0" "$expected_c_library" 'active C library'
check_hash "$control_dir/libggml-hip.so.0.27.0" "$expected_c_library" 'isolated C library'
check_hash "$first_run/source/E/ggml/src/ggml-cuda/vecdotq.cuh" "$expected_e_source" 'isolated E source'
check_hash "$candidate_dir/libggml-hip.so.0.27.0" "$expected_e_library" 'isolated E library'
check_hash "$bench" "$expected_bench" 'llama-bench'
check_hash "$model_path" "$expected_model" 'model'

common_args=(-m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -r 1 -o json --progress)
tg_args=("${common_args[@]}" -p 0 -n 128 -d 0,4096)
pp_args=("${common_args[@]}" -p 512 -n 0 -d 0)
sequence=(C E E C C E E C C E E C C E E C C E E C)

mkdir -p "$run_dir/raw"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/benchmark-start-time.txt"
sha256sum "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$build_dir/bin/libggml-hip.so.0.27.0" \
    "$first_run/source/E/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$control_dir/libggml-hip.so.0.27.0" "$candidate_dir/libggml-hip.so.0.27.0" \
    "$bench" "$model_path" > "$run_dir/binary-hashes.txt"
printf 'HIP_VISIBLE_DEVICES=%s\nROCR_VISIBLE_DEVICES=%s\nHSA_OVERRIDE_GFX_VERSION=%s\nGGML_CUDA_FORCE_MMQ=%s\nGGML_CUDA_FORCE_CUBLAS=%s\nGGML_CUDA_DISABLE_GRAPHS=%s\nLD_LIBRARY_PATH=%s\n' \
    "${HIP_VISIBLE_DEVICES-<unset>}" "${ROCR_VISIBLE_DEVICES-<unset>}" \
    "${HSA_OVERRIDE_GFX_VERSION-<unset>}" "${GGML_CUDA_FORCE_MMQ-<unset>}" \
    "${GGML_CUDA_FORCE_CUBLAS-<unset>}" "${GGML_CUDA_DISABLE_GRAPHS-<unset>}" \
    "${LD_LIBRARY_PATH-<unset>}" > "$run_dir/runtime-environment.txt"
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/telemetry-before.txt" 2>&1

for variant in C E; do
    if [[ "$variant" == C ]]; then library_dir="$control_dir"; else library_dir="$candidate_dir"; fi
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
        printf '{"time":"%s","stage":"%s"}\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$(cat "$run_dir/telemetry-stage.txt" 2>/dev/null || echo setup)"
        rocm-smi --json --showpower --showtemp --showclocks --showuse
        sleep 1
    done
}
printf 'setup\n' > "$run_dir/telemetry-stage.txt"
telemetry > "$run_dir/telemetry.jsonl" 2> "$run_dir/telemetry.stderr" &
telemetry_pid=$!
cleanup() {
    kill "$telemetry_pid" 2>/dev/null || true
    wait "$telemetry_pid" 2>/dev/null || true
}
trap cleanup EXIT

run_one() {
    local mode="$1" pair="$2" variant="$3" order="$4"
    local sample_id library_dir library_path
    local -a args
    printf -v sample_id '%s-p%02d-%s' "$mode" "$pair" "$variant"
    if [[ "$variant" == C ]]; then library_dir="$control_dir"; else library_dir="$candidate_dir"; fi
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"
    if [[ "$mode" == tg ]]; then args=("${tg_args[@]}"); else args=("${pp_args[@]}"); fi
    printf '%s start %s order=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" "$order" \
        | tee -a "$run_dir/sequence.log"
    printf '%s %s %s\n' "$mode" "$sample_id" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$run_dir/telemetry-stage.txt"
    printf '%q ' env "LD_LIBRARY_PATH=$library_path" "$bench" "${args[@]}" \
        > "$run_dir/raw/$sample_id.command.txt"
    printf '\n' >> "$run_dir/raw/$sample_id.command.txt"
    if ! LD_LIBRARY_PATH="$library_path" "$bench" "${args[@]}" \
        > "$run_dir/raw/$sample_id.json" 2> "$run_dir/raw/$sample_id.log"; then
        printf '%s failed %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" \
            | tee -a "$run_dir/sequence.log"
        return 1
    fi
    printf '%s end %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" >> "$run_dir/sequence.log"
}

printf 'llama-bench internal warmup retained: generation warmup for each depth and one prompt warmup for pp512. No clocks or power settings are changed.\n' \
    > "$run_dir/warmup-policy.txt"
printf 'MTP disabled: llama-bench default load_mtp=false; no draft/MTP option passed.\n' \
    > "$run_dir/mtp-runtime.txt"
printf '%q ' "$bench" "${tg_args[@]}" > "$run_dir/tg-command-template.txt"
printf '\n' >> "$run_dir/tg-command-template.txt"
printf '%q ' "$bench" "${pp_args[@]}" > "$run_dir/pp-command-template.txt"
printf '\n' >> "$run_dir/pp-command-template.txt"
: > "$run_dir/sequence.log"

for pair in $(seq 1 10); do
    if (( pair % 2 == 1 )); then
        run_one tg "$pair" C CE
        run_one tg "$pair" E CE
    else
        run_one tg "$pair" E EC
        run_one tg "$pair" C EC
    fi
done

for pair in $(seq 1 10); do
    if (( pair % 2 == 1 )); then
        run_one pp "$pair" C CE
        run_one pp "$pair" E CE
    else
        run_one pp "$pair" E EC
        run_one pp "$pair" C EC
    fi
done

printf 'complete\n' > "$run_dir/telemetry-stage.txt"
cleanup
trap - EXIT
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/telemetry-after.txt" 2>&1
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/benchmark-end-time.txt"
