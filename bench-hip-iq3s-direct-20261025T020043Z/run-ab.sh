#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-iq3s-direct-20261025T020043Z"
build_dir="$repo_dir/build-hip-baseline"
control_dir=/tmp/iq3s-control
model_path=/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf
bench="$build_dir/bin/llama-bench"
sequence=(A B B A B A A B A B B A B A A B A B B A)
sample=1

for variant in "${sequence[@]}"; do
    printf -v sample_id '%02d-%s' "$sample" "$variant"
    printf '%s\n' "$sample_id"

    if [[ "$variant" == A ]]; then
        LD_LIBRARY_PATH="$control_dir:$build_dir/bin:/opt/rocm/lib" "$bench" \
            -m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 \
            -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096 \
            > "$run_dir/$sample_id.json" 2> "$run_dir/$sample_id.log"
    else
        LD_LIBRARY_PATH="$build_dir/bin:/opt/rocm/lib" "$bench" \
            -m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 \
            -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096 \
            > "$run_dir/$sample_id.json" 2> "$run_dir/$sample_id.log"
    fi

    sample=$((sample + 1))
done
