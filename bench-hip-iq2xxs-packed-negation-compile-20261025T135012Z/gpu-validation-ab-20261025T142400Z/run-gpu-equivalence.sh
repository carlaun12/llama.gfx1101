#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/gpu-validation-ab-20261025T142400Z"
source_file="$run_dir/gpu-iq2xxs-packed-equivalence.hip"
binary="$run_dir/gpu-iq2xxs-packed-equivalence"
compile=(/opt/rocm/llvm/bin/clang++ -x hip --offload-arch=gfx1101 -O3 -std=c++17
    -I "$repo_dir/ggml/src" -I "$repo_dir/ggml/src/ggml-cuda"
    "$source_file" -o "$binary")

printf '%q ' "${compile[@]}" > "$run_dir/gpu-equivalence-compile-command.txt"
printf '\n' >> "$run_dir/gpu-equivalence-compile-command.txt"
"${compile[@]}" 2>&1 | tee "$run_dir/gpu-equivalence-compile.log"

date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/gpu-equivalence-start-time.txt"
rocm-smi --showproductname --showuse --showtemp --showclocks --showpower \
    > "$run_dir/gpu-equivalence-before.txt" 2>&1
"$binary" 2>&1 | tee "$run_dir/gpu-equivalence.log"
rocm-smi --showproductname --showuse --showtemp --showclocks --showpower \
    > "$run_dir/gpu-equivalence-after.txt" 2>&1
sha256sum "$binary" > "$run_dir/gpu-equivalence-binary.sha256"
