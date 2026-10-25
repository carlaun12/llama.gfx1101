#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
model_path="${1:-$HOME/slop/Qwen3.8-27B-UD-IQ3_XXS.gguf}"
build_dir="$repo_dir/build-hip-baseline"
rocm_dir="${ROCM_PATH:-/opt/rocm}"

if [[ ! -r "$model_path" ]]; then
    printf 'Model is not readable: %s\n' "$model_path" >&2
    exit 1
fi
if [[ ! -c /dev/kfd || ! -r /dev/kfd || ! -w /dev/kfd ]]; then
    printf 'HIP requires read/write access to /dev/kfd. Run on the GPU host or expose the GPU to this session.\n' >&2
    exit 1
fi
if ! compgen -G '/dev/dri/renderD*' > /dev/null; then
    printf 'No DRM render device is exposed under /dev/dri.\n' >&2
    exit 1
fi

run_dir="$(mktemp -d "$repo_dir/baseline-hip-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")"
printf 'Results: %s\n' "$run_dir"
"$rocm_dir/bin/rocminfo" > "$run_dir/rocminfo.txt" 2>&1
if ! rg -q 'gfx1101' "$run_dir/rocminfo.txt"; then
    printf 'gfx1101 was not reported by rocminfo; see %s\n' "$run_dir/rocminfo.txt" >&2
    exit 1
fi

{
    date -u --iso-8601=seconds
    git -C "$repo_dir" rev-parse HEAD
    git -C "$repo_dir" status --short
    uname -a
    lscpu
    "$rocm_dir/bin/hipconfig" --version
    cmake --version
    stat -- "$model_path"
    sha256sum -- "$model_path"
    for var_name in HIP_VISIBLE_DEVICES ROCR_VISIBLE_DEVICES HSA_OVERRIDE_GFX_VERSION \
        GGML_CUDA_FORCE_MMQ GGML_CUDA_FORCE_CUBLAS GGML_CUDA_DISABLE_GRAPHS; do
        printf '%s=%s\n' "$var_name" "${!var_name-<unset>}"
    done
} > "$run_dir/environment.txt" 2>&1
git -C "$repo_dir" diff HEAD > "$run_dir/source.diff"
cp -- "${BASH_SOURCE[0]}" "$run_dir/baseline-script.sh"

cmake -S "$repo_dir" -B "$build_dir" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="$rocm_dir/llvm/bin/clang" \
    -DCMAKE_CXX_COMPILER="$rocm_dir/llvm/bin/clang++" \
    -DCMAKE_HIP_COMPILER="$rocm_dir/llvm/bin/clang++" \
    -DCMAKE_PREFIX_PATH="$rocm_dir" \
    -DGGML_HIP=ON -DGPU_TARGETS=gfx1101 -DGGML_VULKAN=OFF \
    -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_SERVER=OFF -DLLAMA_BUILD_APP=OFF \
    2>&1 | tee "$run_dir/configure.log"
cmake --build "$build_dir" --target llama-bench -j "${BUILD_JOBS:-4}" \
    2>&1 | tee "$run_dir/build.log"
cp "$build_dir/CMakeCache.txt" "$run_dir/CMakeCache.txt"

bench="$build_dir/bin/llama-bench"
"$bench" --list-devices > "$run_dir/devices.txt" 2>&1
cat "$run_dir/devices.txt"
if ! rg -q 'ROCm0:.*7800 XT' "$run_dir/devices.txt"; then
    printf 'Expected RX 7800 XT at ROCm0; inspect devices.txt before selecting another device.\n' >&2
    exit 1
fi

bench_args=(-m "$model_path" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16
    -b 2048 -ub 512 -t 8 -r 5 -o json --progress)
run_bench() {
    local case_name="$1"
    shift
    printf '%q ' "$bench" "${bench_args[@]}" "$@" > "$run_dir/$case_name.command.txt"
    printf '\n' >> "$run_dir/$case_name.command.txt"
    "$bench" "${bench_args[@]}" "$@" \
        > "$run_dir/$case_name.json" 2> "$run_dir/$case_name.log"
}

# Warmup remains enabled. llama-bench measures inference without sampling or MTP.
run_bench prompt -p 512,2048 -n 0
run_bench generation -p 0 -n 128 -d 0,4096
printf 'Baseline complete: %s\n' "$run_dir"
