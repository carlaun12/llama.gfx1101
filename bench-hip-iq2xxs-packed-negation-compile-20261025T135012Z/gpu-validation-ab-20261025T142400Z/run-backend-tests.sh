#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/gpu-validation-ab-20261025T142400Z"
build_dir="$repo_dir/build-hip-baseline"
test_bin="$build_dir/bin/test-backend-ops"
backend_args=(-b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p iq2_xxs)

date -u '+%Y-%m-%dT%H:%M:%SZ' > "$run_dir/backend-tests-start-time.txt"
rocm-smi --showproductname --showuse --showtemp --showclocks --showpower \
    > "$run_dir/backend-tests-before.txt" 2>&1
sha256sum "$test_bin" > "$run_dir/backend-test-executable.sha256"

for variant in control candidate; do
    library_dir="$run_dir/$variant-library"
    loader_log="$run_dir/$variant-test-backend-ops-loader.txt"
    test_log="$run_dir/$variant-backend-tests.log"
    library_path="$library_dir:$build_dir/bin:/opt/rocm/lib"

    printf '%q ' env "LD_LIBRARY_PATH=$library_path" "$test_bin" "${backend_args[@]}" \
        > "$run_dir/$variant-backend-test-command.txt"
    printf '\n' >> "$run_dir/$variant-backend-test-command.txt"

    LD_LIBRARY_PATH="$library_path" ldd "$test_bin" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi

    if ! LD_LIBRARY_PATH="$library_path" "$test_bin" "${backend_args[@]}" \
        > "$test_log" 2>&1; then
        cat "$test_log"
        exit 1
    fi
done

rocm-smi --showproductname --showuse --showtemp --showclocks --showpower \
    > "$run_dir/backend-tests-after.txt" 2>&1
