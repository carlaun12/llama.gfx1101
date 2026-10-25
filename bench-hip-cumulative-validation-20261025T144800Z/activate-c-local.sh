#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-cumulative-validation-20261025T144800Z"
source_path="$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh"
library_path="$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0"
bench_bin="$repo_dir/build-hip-baseline/bin/llama-bench"
source_backup="$run_dir/activation-snapshots/control-vecdotq.cuh"
library_backup="$run_dir/activation-snapshots/control-libggml-hip.so.0.27.0"
candidate_source="$run_dir/source/C/ggml/src/ggml-cuda/vecdotq.cuh"
candidate_library="$run_dir/library/C/libggml-hip.so.0.27.0"
expected_control_source=a22eebfb491090e3cb5c5d297caacd3bff0055f12fe0318db897d7873f6efceb
expected_control_library=676433a44e3e947b0d37d050109328aa4b8d20f77a515276e50135b92d8e658b
expected_candidate_source=4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83
expected_candidate_library=a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8
changed=0

hash_file() { sha256sum "$1" | awk '{print $1}'; }
require_hash() {
    local path="$1" expected="$2" label="$3" actual
    actual=$(hash_file "$path")
    if [[ "$actual" != "$expected" ]]; then
        printf '%s hash mismatch: %s
' "$label" "$actual" >&2
        exit 1
    fi
}
restore_on_error() {
    local status=$?
    trap - EXIT
    if [[ "$status" -ne 0 && "$changed" -eq 1 ]]; then
        cp -p "$source_backup" "$source_path.rollback.$$"
        cp -p "$library_backup" "$library_path.rollback.$$"
        mv -f -- "$source_path.rollback.$$" "$source_path"
        mv -f -- "$library_path.rollback.$$" "$library_path"
    fi
    exit "$status"
}
trap restore_on_error EXIT

require_hash "$source_backup" "$expected_control_source" 'control source snapshot'
require_hash "$library_backup" "$expected_control_library" 'control library snapshot'
require_hash "$source_path" "$expected_control_source" 'active control source'
require_hash "$library_path" "$expected_control_library" 'active control library'
require_hash "$candidate_source" "$expected_candidate_source" 'candidate source'
require_hash "$candidate_library" "$expected_candidate_library" 'candidate library'

source_tmp="$source_path.candidate.$$"
library_tmp="$library_path.candidate.$$"
cp -p "$candidate_source" "$source_tmp"
cp -p "$candidate_library" "$library_tmp"
changed=1
mv -f -- "$source_tmp" "$source_path"
mv -f -- "$library_tmp" "$library_path"
require_hash "$source_path" "$expected_candidate_source" 'active candidate source'
require_hash "$library_path" "$expected_candidate_library" 'active candidate library'
resolved=$(env -u LD_LIBRARY_PATH ldd "$bench_bin" | awk '/libggml-hip\.so\.0 =>/ {print $3; exit}')
if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_path")" ]]; then
    printf 'llama-bench did not resolve the activated HIP library: %s
' "$resolved" >&2
    exit 1
fi
changed=0
trap - EXIT
printf 'C active locally. Source and library hashes match the recorded candidate.
'
