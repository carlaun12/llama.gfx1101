#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
experiment_dir="$repo_dir/bench-hip-iq2xs-direct-signs-20261025T182634Z"
run_dir="$experiment_dir/mmq-pp128-ab-20261025T193500Z"
build_dir="$repo_dir/build-hip-baseline"
e_dir="$build_dir/bin"
f_dir="$experiment_dir/build/F/bin"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
bench="$build_dir/bin/llama-bench"
expected_e_vecdot=9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c
expected_e_mmq=829528f15e95ff0d665efa1e36f3458730c3b36800231b16cb7c245fc9b0b3c5
expected_e_library=ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24
expected_f_vecdot=defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c
expected_f_mmq=18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f
expected_f_library=3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce
expected_bench=39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25
expected_model=e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803
sequence=(E F F E E F F E E F F E E F F E E F F E)
common_args=(-m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 128 -ub 128 -t 8 -r 1 -o json --progress)
pp_args=("${common_args[@]}" -p 128 -n 0 -d 0)

hash_of() { sha256sum "$1" | awk '{print $1}'; }
check_hash() {
    local path="$1" expected="$2" label="$3" actual
    actual=$(hash_of "$path")
    if [[ "$actual" != "$expected" ]]; then
        printf 'Hash mismatch for %s: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}
gpu_snapshot() {
    rocm-smi --showuse --showpower --showtemp --showclocks --showpids 2>&1
}
gpu_snapshot_is_idle() {
    local snapshot="$1" utilization
    grep -q 'No KFD PIDs currently running' <<< "$snapshot" || return 1
    utilization=$(awk -F: '/GPU use \(%\)/ { gsub(/[^0-9.]/, "", $NF); print $NF; exit }' <<< "$snapshot")
    [[ -n "$utilization" ]] || return 1
    awk -v value="$utilization" 'BEGIN { exit !(value <= 5) }'
}
wait_for_gpu_idle() {
    local reason="$1" snapshot
    while true; do
        snapshot=$(gpu_snapshot)
        if gpu_snapshot_is_idle "$snapshot"; then
            printf '%s idle preflight (%s)\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$reason" >> "$run_dir/gpu-idle-checks.log"
            return
        fi
        {
            printf '%s waiting for GPU idle (%s)\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$reason"
            printf '%s\n' "$snapshot"
        } >> "$run_dir/gpu-idle-checks.log"
        sleep 5
    done
}

check_hash "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" "$expected_e_vecdot" 'active E vecdot source'
check_hash "$repo_dir/ggml/src/ggml-cuda/mmq-load-tiles.cuh" "$expected_e_mmq" 'active E MMQ source'
check_hash "$e_dir/libggml-hip.so.0.27.0" "$expected_e_library" 'E library'
check_hash "$experiment_dir/source/F/ggml/src/ggml-cuda/vecdotq.cuh" "$expected_f_vecdot" 'F vecdot source'
check_hash "$experiment_dir/source/F/ggml/src/ggml-cuda/mmq-load-tiles.cuh" "$expected_f_mmq" 'F MMQ source'
check_hash "$f_dir/libggml-hip.so.0.27.0" "$expected_f_library" 'F library'
check_hash "$bench" "$expected_bench" 'llama-bench'
check_hash "$model_path" "$expected_model" 'model'

mkdir -p "$run_dir/raw"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/benchmark-start-time.txt"
sha256sum \
    "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$repo_dir/ggml/src/ggml-cuda/mmq-load-tiles.cuh" \
    "$experiment_dir/source/F/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$experiment_dir/source/F/ggml/src/ggml-cuda/mmq-load-tiles.cuh" \
    "$e_dir/libggml-hip.so.0.27.0" "$f_dir/libggml-hip.so.0.27.0" \
    "$bench" "$model_path" > "$run_dir/binary-hashes.txt"
printf 'HSA_OVERRIDE_GFX_VERSION=%s\nROCR_VISIBLE_DEVICES=%s\nHIP_VISIBLE_DEVICES=%s\nGPU_DEVICE_ORDINAL=%s\nLD_LIBRARY_PATH=%s\nGGML_CUDA_FORCE_MMQ=%s\nGGML_CUDA_FORCE_CUBLAS=%s\n' \
    "${HSA_OVERRIDE_GFX_VERSION-<unset>}" "${ROCR_VISIBLE_DEVICES-<unset>}" \
    "${HIP_VISIBLE_DEVICES-<unset>}" "${GPU_DEVICE_ORDINAL-<unset>}" \
    "${LD_LIBRARY_PATH-<unset>}" "${GGML_CUDA_FORCE_MMQ-<unset>}" \
    "${GGML_CUDA_FORCE_CUBLAS-<unset>}" > "$run_dir/runtime-environment.txt"
wait_for_gpu_idle initial
gpu_snapshot > "$run_dir/preflight-gpu-idle.txt"
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/telemetry-before.txt" 2>&1

for variant in E F; do
    if [[ "$variant" == E ]]; then library_dir="$e_dir"; else library_dir="$f_dir"; fi
    library_path="$library_dir:$e_dir:/opt/rocm/lib"
    loader_log="$run_dir/loader-llama-bench-$variant.txt"
    LD_LIBRARY_PATH="$library_path" ldd "$bench" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
done

printf 'setup\n' > "$run_dir/telemetry-stage.txt"
python3 "$run_dir/collect_telemetry.py" > "$run_dir/telemetry.jsonl" 2> "$run_dir/telemetry.stderr" &
telemetry_pid=$!
trap 'kill "$telemetry_pid" 2>/dev/null || true; wait "$telemetry_pid" 2>/dev/null || true' EXIT

printf 'llama-bench prompt warmup retained; MTP disabled by default. GPU-idle check requires no KFD PIDs and <=5%% GPU use before each sample.\n' \
    > "$run_dir/warmup-and-idle-policy.txt"
printf 'MTP disabled: llama-bench default load_mtp=false; no draft/MTP option is passed.\n' > "$run_dir/mtp-runtime.txt"
printf '%q ' "$bench" "${pp_args[@]}" > "$run_dir/pp-command-template.txt"
printf '\n' >> "$run_dir/pp-command-template.txt"
: > "$run_dir/sequence.log"

sample=1
for variant in "${sequence[@]}"; do
    wait_for_gpu_idle "before sample $sample-$variant"
    printf -v sample_id 'pp128-%02d-%s' "$sample" "$variant"
    if [[ "$variant" == E ]]; then library_dir="$e_dir"; else library_dir="$f_dir"; fi
    library_path="$library_dir:$e_dir:/opt/rocm/lib"
    printf '%s start %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" | tee -a "$run_dir/sequence.log"
    printf '%s\n' "$sample_id" > "$run_dir/telemetry-stage.txt"
    printf '%q ' env "LD_LIBRARY_PATH=$library_path" "$bench" "${pp_args[@]}" > "$run_dir/raw/$sample_id.command.txt"
    printf '\n' >> "$run_dir/raw/$sample_id.command.txt"
    if ! LD_LIBRARY_PATH="$library_path" "$bench" "${pp_args[@]}" \
        > "$run_dir/raw/$sample_id.json" 2> "$run_dir/raw/$sample_id.log"; then
        printf '%s failed %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" | tee -a "$run_dir/sequence.log"
        exit 1
    fi
    printf '%s end %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" >> "$run_dir/sequence.log"
    sample=$((sample + 1))
done

printf 'complete\n' > "$run_dir/telemetry-stage.txt"
kill "$telemetry_pid" 2>/dev/null || true
wait "$telemetry_pid" 2>/dev/null || true
trap - EXIT
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse \
    > "$run_dir/telemetry-after.txt" 2>&1
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/benchmark-end-time.txt"
