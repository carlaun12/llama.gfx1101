#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-cumulative-validation-20261025T144800Z"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/correctness-start-time.txt"

"$repo_dir/bench-hip-iq2s-direct-20261025T030406Z/gpu-direct-equivalence" \
    > "$run_dir/gpu-iq2s-exact.log" 2>&1
"$repo_dir/bench-hip-iq3s-direct-20261025T020043Z/gpu-packed-equivalence" \
    > "$run_dir/gpu-iq3s-exact.log" 2>&1
"$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/gpu-validation-ab-20261025T142400Z/gpu-iq2xxs-packed-equivalence" \
    > "$run_dir/gpu-iq2xxs-exact.log" 2>&1

test_bin="$repo_dir/build-hip-baseline/bin/test-backend-ops"
backend_args=(-b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p 'iq2_s|iq3_s|iq3_xxs|iq2_xxs')
rocm-smi --showproductname --showuse --showtemp --showclocks --showpower --showmaxpower \
    > "$run_dir/backend-tests-before.txt" 2>&1
sha256sum "$test_bin" > "$run_dir/test-backend-executable.sha256"

for variant in A B C; do
    library_dir="$run_dir/library/$variant"
    library_path="$library_dir:$repo_dir/build-hip-baseline/bin:/opt/rocm/lib"
    loader_log="$run_dir/loader-test-backend-$variant.txt"
    test_log="$run_dir/backend-tests-$variant.log"
    printf '%q ' env "LD_LIBRARY_PATH=$library_path" "$test_bin" "${backend_args[@]}" \
        > "$run_dir/backend-tests-$variant.command.txt"
    printf '\n' >> "$run_dir/backend-tests-$variant.command.txt"

    LD_LIBRARY_PATH="$library_path" ldd "$test_bin" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
    if ! LD_LIBRARY_PATH="$library_path" "$test_bin" "${backend_args[@]}" > "$test_log" 2>&1; then
        cat "$test_log"
        exit 1
    fi
done

rocm-smi --showproductname --showuse --showtemp --showclocks --showpower --showmaxpower \
    > "$run_dir/backend-tests-after.txt" 2>&1
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/correctness-end-time.txt"
printf 'GPU arithmetic checks and A/B/C backend tests passed.\n' > "$run_dir/correctness-passed.txt"
