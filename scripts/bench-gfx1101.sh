#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || ( "$1" != hip && "$1" != vulkan ) ]]; then
    echo "Usage: $0 hip|vulkan /path/to/Qwen3.8-27B-UD-IQ3_XXS.gguf [llama-bench options]" >&2
    exit 2
fi

backend="$1"
model="$2"
shift 2
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bench="${root_dir}/build-gfx1101-${backend}-release/bin/llama-bench"
if [[ ! -f "$model" || ! -x "$bench" ]]; then
    echo "Model or benchmark executable missing. See docs/gfx1101.md." >&2
    exit 1
fi

mkdir -p "${root_dir}/results-gfx1101"
result_dir="$(mktemp -d "${root_dir}/results-gfx1101/${backend}-XXXXXXXX")"
git -C "$root_dir" rev-parse HEAD > "${result_dir}/commit.txt"
git -C "$root_dir" diff > "${result_dir}/changes.patch"
"$bench" --version > "${result_dir}/version.txt" 2>&1
echo "Results: ${result_dir}" >&2

# Keep cache precision fixed while comparing backend, Flash Attention and ubatch.
"$bench" -m "$model" -ngl 99 -b 512 -ub 128,256,512 \
    -fa on,off -ctk f16 -ctv f16 -p 512 -n 128 -pg 2048,128 \
    -r 3 -o json "$@" > "${result_dir}/bench.json" 2> "${result_dir}/bench.log"
echo "Completed: ${result_dir}/bench.json" >&2
