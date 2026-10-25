#!/usr/bin/env bash
set -euo pipefail
repo_dir=/home/carlos/project/llama.gfx1101
experiment_dir="$repo_dir/bench-hip-iq2xs-direct-signs-20261025T182634Z"
run_dir="$experiment_dir/ab-session2-20261025T184643Z"
bench="$repo_dir/build-hip-baseline/bin/llama-bench"
e_dir="$repo_dir/build-hip-baseline/bin"
f_dir="$experiment_dir/build/F/bin"
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
sequence=(E F F E F E E F E F F E F E E F E F F E)
sample=1
source_hash=$(sha256sum "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" | cut -d ' ' -f1)
e_library_hash=$(sha256sum "$e_dir/libggml-hip.so.0.27.0" | cut -d ' ' -f1)
f_library_hash=$(sha256sum "$f_dir/libggml-hip.so.0.27.0" | cut -d ' ' -f1)
[[ "$source_hash" == 9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c ]] || { echo "E source hash mismatch: $source_hash" >&2; exit 1; }
[[ "$e_library_hash" == ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24 ]] || { echo "E library hash mismatch: $e_library_hash" >&2; exit 1; }
[[ "$f_library_hash" == 3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce ]] || { echo "F library hash mismatch: $f_library_hash" >&2; exit 1; }
sha256sum \
    "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$repo_dir/ggml/src/ggml-cuda/mmq-load-tiles.cuh" \
    "$experiment_dir/source/F/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$experiment_dir/source/F/ggml/src/ggml-cuda/mmq-load-tiles.cuh" \
    "$e_dir/libggml-hip.so.0.27.0" "$f_dir/libggml-hip.so.0.27.0" \
    "$bench" "$model_path" > "$run_dir/binary-hashes.txt"
printf '%s\n' 'MTP disabled: llama-bench default load_mtp=false; no draft/MTP option is passed.' > "$run_dir/mtp-runtime.txt"
{
    printf 'HSA_OVERRIDE_GFX_VERSION=%s\n' "${HSA_OVERRIDE_GFX_VERSION-<unset>}"
    printf 'ROCR_VISIBLE_DEVICES=%s\n' "${ROCR_VISIBLE_DEVICES-<unset>}"
    printf 'HIP_VISIBLE_DEVICES=%s\n' "${HIP_VISIBLE_DEVICES-<unset>}"
    printf 'GPU_DEVICE_ORDINAL=%s\n' "${GPU_DEVICE_ORDINAL-<unset>}"
    printf 'LD_LIBRARY_PATH=%s\n' "${LD_LIBRARY_PATH-<unset>}"
} > "$run_dir/runtime-environment.txt"
rocm-smi --showmaxpower --showpower --showtemp --showclocks --showuse > "$run_dir/telemetry-before.txt"
for variant in E F; do
    if [[ "$variant" == E ]]; then library_dir="$e_dir"; else library_dir="$f_dir"; fi
    loader_log="$run_dir/loader-llama-bench-$variant.txt"
    library_path="$library_dir:$e_dir:/opt/rocm/lib"
    LD_LIBRARY_PATH="$library_path" ldd "$bench" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    [[ -n "$resolved" && "$(readlink -f "$resolved")" == "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]] || { echo "Unexpected HIP library for $variant: $resolved" >&2; exit 1; }
done
printf 'stage\n' > "$run_dir/telemetry-stage.txt"
python3 "$run_dir/collect_telemetry.py" > "$run_dir/telemetry.jsonl" 2> "$run_dir/telemetry.stderr" &
telemetry_pid=$!
trap 'kill "$telemetry_pid" 2>/dev/null || true' EXIT
for variant in "${sequence[@]}"; do
    printf -v sample_id '%02d-%s' "$sample" "$variant"
    printf '%s\n' "$sample_id"
    printf '%s\n' "$sample_id" > "$run_dir/telemetry-stage.txt"
    if [[ "$variant" == E ]]; then library_dir="$e_dir"; else library_dir="$f_dir"; fi
    library_path="$library_dir:$e_dir:/opt/rocm/lib"
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
rocm-smi --showmaxpower --showtemp --showclocks --showuse > "$run_dir/telemetry-after.txt"
