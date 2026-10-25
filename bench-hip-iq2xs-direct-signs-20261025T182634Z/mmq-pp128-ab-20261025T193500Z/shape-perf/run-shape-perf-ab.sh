#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
experiment_dir="$repo_dir/bench-hip-iq2xs-direct-signs-20261025T182634Z"
run_dir="$experiment_dir/mmq-pp128-ab-20261025T193500Z/shape-perf/ab"
e_dir="$repo_dir/build-hip-baseline/bin"
f_dir="$experiment_dir/build/F/bin"
perf_bin="$experiment_dir/mmq-pp128-ab-20261025T193500Z/shape-perf/bin/test-backend-ops-mmq-perf"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
sequence=(E F F E E F F E E F F E E F F E E F F E)
expected_e_vecdot=9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c
expected_e_mmq=829528f15e95ff0d665efa1e36f3458730c3b36800231b16cb7c245fc9b0b3c5
expected_e_library=ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24
expected_f_vecdot=defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c
expected_f_mmq=18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f
expected_f_library=3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce
expected_perf_bin=82cd6d14afdef5e0dd2e3a02682cbe01f559069bf013d720d90b2788ce11bce8
expected_model=e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803
params_filter='type_a=iq2_xs.*n=128.*'

hash_of() { sha256sum "$1" | awk '{print $1}'; }
check_hash() {
    local path="$1" expected="$2" label="$3" actual
    actual=$(hash_of "$path")
    if [[ "$actual" != "$expected" ]]; then
        printf 'Hash mismatch for %s: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}
gpu_snapshot() { rocm-smi --showuse --showpower --showtemp --showclocks --showpids 2>&1; }
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
check_hash "$perf_bin" "$expected_perf_bin" 'shape performance harness'
check_hash "$model_path" "$expected_model" 'model'

mkdir -p "$run_dir/raw"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/start-time.txt"
sha256sum "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" "$repo_dir/ggml/src/ggml-cuda/mmq-load-tiles.cuh" \
    "$experiment_dir/source/F/ggml/src/ggml-cuda/vecdotq.cuh" "$experiment_dir/source/F/ggml/src/ggml-cuda/mmq-load-tiles.cuh" \
    "$e_dir/libggml-hip.so.0.27.0" "$f_dir/libggml-hip.so.0.27.0" "$perf_bin" "$model_path" > "$run_dir/hashes.txt"
printf 'HSA_OVERRIDE_GFX_VERSION=%s\nROCR_VISIBLE_DEVICES=%s\nHIP_VISIBLE_DEVICES=%s\nGPU_DEVICE_ORDINAL=%s\nGGML_CUDA_FORCE_MMQ=%s\nGGML_CUDA_FORCE_CUBLAS=%s\n' \
    "${HSA_OVERRIDE_GFX_VERSION-<unset>}" "${ROCR_VISIBLE_DEVICES-<unset>}" \
    "${HIP_VISIBLE_DEVICES-<unset>}" "${GPU_DEVICE_ORDINAL-<unset>}" \
    "${GGML_CUDA_FORCE_MMQ-<unset>}" "${GGML_CUDA_FORCE_CUBLAS-<unset>}" > "$run_dir/runtime-environment.txt"
wait_for_gpu_idle initial
gpu_snapshot > "$run_dir/preflight-gpu-idle.txt"
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse > "$run_dir/telemetry-before.txt" 2>&1

for variant in E F; do
    if [[ "$variant" == E ]]; then library_dir="$e_dir"; else library_dir="$f_dir"; fi
    loader_log="$run_dir/loader-harness-$variant.txt"
    LD_LIBRARY_PATH="$library_dir:$e_dir:/opt/rocm/lib" ldd "$perf_bin" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
done

cp "$experiment_dir/mmq-pp128-ab-20261025T193500Z/collect_telemetry.py" "$run_dir/collect_telemetry.py"
printf 'setup\n' > "$run_dir/telemetry-stage.txt"
python3 "$run_dir/collect_telemetry.py" > "$run_dir/telemetry.jsonl" 2> "$run_dir/telemetry.stderr" &
telemetry_pid=$!
trap 'kill "$telemetry_pid" 2>/dev/null || true; wait "$telemetry_pid" 2>/dev/null || true' EXIT

printf 'Each backend perf case warms once and runs for at least 1 second. This harness uses GGUF IQ2_XS dimensions with n=128; it does not load model weights or use MTP.\n' > "$run_dir/warmup-policy.txt"
printf 'perf -b ROCm0 -o MUL_MAT -p %q\n' "$params_filter" > "$run_dir/command-template.txt"
: > "$run_dir/sequence.log"

sample=1
for variant in "${sequence[@]}"; do
    printf -v sample_id 'shape-%02d-%s' "$sample" "$variant"
    wait_for_gpu_idle "before $sample_id"
    if [[ "$variant" == E ]]; then library_dir="$e_dir"; else library_dir="$f_dir"; fi
    library_path="$library_dir:$e_dir:/opt/rocm/lib"
    printf '%s start %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$sample_id" | tee -a "$run_dir/sequence.log"
    printf '%s\n' "$sample_id" > "$run_dir/telemetry-stage.txt"
    printf '%q ' env LLAMA_TEST_RANDOM_SEED=4321 "LD_LIBRARY_PATH=$library_path" "$perf_bin" perf -b ROCm0 -o MUL_MAT -p "$params_filter" > "$run_dir/raw/$sample_id.command.txt"
    printf '\n' >> "$run_dir/raw/$sample_id.command.txt"
    if ! LLAMA_TEST_RANDOM_SEED=4321 LD_LIBRARY_PATH="$library_path" "$perf_bin" perf -b ROCm0 -o MUL_MAT -p "$params_filter" \
            > "$run_dir/raw/$sample_id.log" 2>&1; then
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
rocm-smi --showproductname --showmaxpower --showpower --showtemp --showclocks --showuse > "$run_dir/telemetry-after.txt" 2>&1
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/end-time.txt"
