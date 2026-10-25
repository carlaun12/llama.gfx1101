#!/usr/bin/env bash
set -u

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-cumulative-validation-20261025T144800Z"
test_bin="$repo_dir/build-hip-baseline/bin/test-backend-ops"
backend_args=(-b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p 'iq2_s|iq3_s|iq3_xxs|iq2_xxs')

for variant in B C A; do
    library_dir="$run_dir/library/$variant"
    library_path="$library_dir:$repo_dir/build-hip-baseline/bin:/opt/rocm/lib"
    test_log="$run_dir/backend-tests-$variant-rerun.log"
    loader_log="$run_dir/loader-test-backend-$variant-rerun.txt"
    LD_LIBRARY_PATH="$library_path" ldd "$test_bin" > "$loader_log"
    resolved=$(awk '/libggml-hip\.so\.0 =>/ { print $3; exit }' "$loader_log")
    if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_dir/libggml-hip.so.0.27.0")" ]]; then
        printf 'Unexpected HIP library for %s: %s\n' "$variant" "$resolved" >&2
        exit 1
    fi
    set +e
    LD_LIBRARY_PATH="$library_path" "$test_bin" "${backend_args[@]}" > "$test_log" 2>&1
    status=$?
    set -e
    printf '%s exit=%s ' "$variant" "$status"
    rg '^[[:space:]]*[0-9]+/[0-9]+ tests passed|\[ADD\] ERR =|^Failing tests:|^  Backend ROCm0:' "$test_log" | tail -8 | tr '\n' ' '
    printf '\n'
    printf '%s %s\n' "$variant" "$status" >> "$run_dir/backend-test-rerun-status.txt"
done
