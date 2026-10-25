#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-unpack-ksigns-perm-20261025T171525Z"
activation_dir="$run_dir/local-activation-E-20261025T181721Z"
source_path="$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh"
library_path="$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0"
bench_bin="$repo_dir/build-hip-baseline/bin/llama-bench"
control_source="$activation_dir/snapshots/C/vecdotq.cuh"
control_library="$activation_dir/snapshots/C/libggml-hip.so.0.27.0"
candidate_source="$run_dir/source/E/ggml/src/ggml-cuda/vecdotq.cuh"
candidate_library="$run_dir/library/E/libggml-hip.so.0.27.0"
expected_c_source=4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83
expected_c_library=a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8
expected_e_source=9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c
expected_e_library=ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24
changed=0

hash_of() { sha256sum "$1" | awk '{print $1}'; }
require_hash() {
    local path="$1" expected="$2" label="$3" actual
    actual=$(hash_of "$path")
    if [[ "$actual" != "$expected" ]]; then
        printf '%s hash mismatch: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}
restore_c_if_safe() {
    local path="$1" backup="$2" e_hash="$3" c_hash="$4" tmp
    local active_hash
    active_hash=$(hash_of "$path")
    if [[ "$active_hash" == "$e_hash" ]]; then
        tmp="$path.rollback.$$"
        cp -p "$backup" "$tmp"
        mv -f -- "$tmp" "$path"
    elif [[ "$active_hash" != "$c_hash" ]]; then
        printf 'Rollback left unexpected file unchanged: %s (%s)\n' "$path" "$active_hash" >&2
    fi
}
rollback_on_error() {
    local status=$?
    trap - EXIT
    if [[ "$status" -ne 0 && "$changed" -eq 1 ]]; then
        restore_c_if_safe "$source_path" "$control_source" "$expected_e_source" "$expected_c_source"
        restore_c_if_safe "$library_path" "$control_library" "$expected_e_library" "$expected_c_library"
    fi
    exit "$status"
}
trap rollback_on_error EXIT

for binary in llama-cli llama-server llama-bench; do
    if pgrep -x "$binary" >/dev/null 2>&1; then
        printf 'Refusing activation while %s is running.\n' "$binary" >&2
        exit 1
    fi
done

require_hash "$control_source" "$expected_c_source" 'preserved C source'
require_hash "$control_library" "$expected_c_library" 'preserved C library'
require_hash "$source_path" "$expected_c_source" 'active C source'
require_hash "$library_path" "$expected_c_library" 'active C library'
require_hash "$candidate_source" "$expected_e_source" 'validated E source'
require_hash "$candidate_library" "$expected_e_library" 'validated E library'

source_tmp="$source_path.E.$$"
library_tmp="$library_path.E.$$"
cp -p "$candidate_source" "$source_tmp"
cp -p "$candidate_library" "$library_tmp"
require_hash "$source_tmp" "$expected_e_source" 'staged E source'
require_hash "$library_tmp" "$expected_e_library" 'staged E library'
changed=1
mv -f -- "$source_tmp" "$source_path"
mv -f -- "$library_tmp" "$library_path"
require_hash "$source_path" "$expected_e_source" 'active E source'
require_hash "$library_path" "$expected_e_library" 'active E library'
resolved=$(env -u LD_LIBRARY_PATH ldd "$bench_bin" | awk '/libggml-hip\.so\.0 =>/ {print $3; exit}')
if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_path")" ]]; then
    printf 'llama-bench did not resolve active E library: %s\n' "$resolved" >&2
    exit 1
fi
changed=0
trap - EXIT
printf 'E active. Source and HIP library hashes and default loader resolution match the validated E artifacts.\n'
