#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/gpu-validation-ab-20261025T142400Z"
{
    date -u '+%Y-%m-%dT%H:%M:%SZ'
    printf '\nActive source and binary hashes:\n'
    sha256sum "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
        "$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0" \
        "$repo_dir/build-hip-baseline/bin/llama-bench"
    printf '\nActive source matches archived control source:\n'
    cmp "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
        "$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/control/ggml-cuda/vecdotq.cuh"
    printf 'yes\n'
    printf '\nDefault active llama-bench HIP library:\n'
    ldd "$repo_dir/build-hip-baseline/bin/llama-bench" | rg 'libggml-hip\.so\.0'
    printf '\nGit status:\n'
    git -C "$repo_dir" status --short
    printf '\nRemaining benchmark processes:\n'
    ps -eo pid,etime,cmd | rg '(llama-bench|test-backend-ops|rocprof|gpu-iq2xxs-packed-equivalence)' | rg -v 'rg ' || true
    printf '\nFinal GPU status:\n'
    rocm-smi --showproductname --showuse --showmaxpower --showpower --showtemp --showclocks
} > "$run_dir/final-state.txt" 2>&1
