#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
experiment_dir="$repo_dir/bench-hip-iq2xs-direct-signs-20261025T182634Z"
adoption_dir="$experiment_dir/local-adoption-review-20261025T191110Z"
vecdot_path="$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh"
mmq_path="$repo_dir/ggml/src/ggml-cuda/mmq-load-tiles.cuh"
library_path="$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0"
bench_bin="$repo_dir/build-hip-baseline/bin/llama-bench"
e_vecdot="$adoption_dir/snapshots/E/vecdotq.cuh"
e_mmq="$adoption_dir/snapshots/E/mmq-load-tiles.cuh"
e_library="$adoption_dir/snapshots/E/libggml-hip.so.0.27.0"
f_vecdot="$experiment_dir/source/F/ggml/src/ggml-cuda/vecdotq.cuh"
f_mmq="$experiment_dir/source/F/ggml/src/ggml-cuda/mmq-load-tiles.cuh"
f_library="$experiment_dir/build/F/bin/libggml-hip.so.0.27.0"
e_vecdot_hash=9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c
e_mmq_hash=829528f15e95ff0d665efa1e36f3458730c3b36800231b16cb7c245fc9b0b3c5
e_library_hash=ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24
f_vecdot_hash=defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c
f_mmq_hash=18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f
f_library_hash=3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce
bench_hash=39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25
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
restore_e_if_safe() {
    local path="$1" backup="$2" f_hash="$3" e_hash="$4" tmp active_hash
    active_hash=$(hash_of "$path")
    if [[ "$active_hash" == "$f_hash" ]]; then
        tmp="$path.rollback-E.$$"
        cp -p "$backup" "$tmp"
        mv -f -- "$tmp" "$path"
    elif [[ "$active_hash" != "$e_hash" ]]; then
        printf 'Rollback left unexpected file unchanged: %s (%s)\n' "$path" "$active_hash" >&2
    fi
}
rollback_on_error() {
    local status=$?
    trap - EXIT
    if [[ "$status" -ne 0 && "$changed" -eq 1 ]]; then
        restore_e_if_safe "$vecdot_path" "$e_vecdot" "$f_vecdot_hash" "$e_vecdot_hash"
        restore_e_if_safe "$mmq_path" "$e_mmq" "$f_mmq_hash" "$e_mmq_hash"
        restore_e_if_safe "$library_path" "$e_library" "$f_library_hash" "$e_library_hash"
    fi
    exit "$status"
}
trap rollback_on_error EXIT

if pgrep -x llama-bench >/dev/null 2>&1; then
    printf 'Refusing activation while llama-bench is running.\n' >&2
    exit 1
fi

require_hash "$e_vecdot" "$e_vecdot_hash" 'preserved E vecdot source'
require_hash "$e_mmq" "$e_mmq_hash" 'preserved E MMQ source'
require_hash "$e_library" "$e_library_hash" 'preserved E library'
require_hash "$bench_bin" "$bench_hash" 'llama-bench executable'
require_hash "$vecdot_path" "$e_vecdot_hash" 'active E vecdot source'
require_hash "$mmq_path" "$e_mmq_hash" 'active E MMQ source'
require_hash "$library_path" "$e_library_hash" 'active E library'
require_hash "$f_vecdot" "$f_vecdot_hash" 'validated F vecdot source'
require_hash "$f_mmq" "$f_mmq_hash" 'validated F MMQ source'
require_hash "$f_library" "$f_library_hash" 'validated F library'

vecdot_tmp="$vecdot_path.F.$$"
mmq_tmp="$mmq_path.F.$$"
library_tmp="$library_path.F.$$"
cp -p "$f_vecdot" "$vecdot_tmp"
cp -p "$f_mmq" "$mmq_tmp"
cp -p "$f_library" "$library_tmp"
require_hash "$vecdot_tmp" "$f_vecdot_hash" 'staged F vecdot source'
require_hash "$mmq_tmp" "$f_mmq_hash" 'staged F MMQ source'
require_hash "$library_tmp" "$f_library_hash" 'staged F library'
changed=1
mv -f -- "$vecdot_tmp" "$vecdot_path"
mv -f -- "$mmq_tmp" "$mmq_path"
mv -f -- "$library_tmp" "$library_path"
require_hash "$vecdot_path" "$f_vecdot_hash" 'active F vecdot source'
require_hash "$mmq_path" "$f_mmq_hash" 'active F MMQ source'
require_hash "$library_path" "$f_library_hash" 'active F library'
resolved=$(env -u LD_LIBRARY_PATH ldd "$bench_bin" | awk '/libggml-hip\.so\.0 =>/ {print $3; exit}')
if [[ -z "$resolved" || "$(readlink -f "$resolved")" != "$(readlink -f "$library_path")" ]]; then
    printf 'llama-bench did not resolve the active F library: %s\n' "$resolved" >&2
    exit 1
fi
changed=0
trap - EXIT
printf 'F active. Both source hashes, library hash, and default loader path match the validated F artifacts.\n'
