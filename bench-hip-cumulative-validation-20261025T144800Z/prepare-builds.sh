#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
run_dir="$repo_dir/bench-hip-cumulative-validation-20261025T144800Z"
candidate_source="$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z/candidate/ggml-cuda/vecdotq.cuh"
active_source="$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh"
active_library="$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0"

mkdir -p "$run_dir/sources" "$run_dir/initial-active-library"
cp "$active_source" "$run_dir/sources/B.vecdotq.cuh"
cp "$candidate_source" "$run_dir/sources/C.vecdotq.cuh"
cp -L "$active_library" "$run_dir/initial-active-library/libggml-hip.so.0.27.0"
sha256sum "$active_source" "$active_library" \
    "$repo_dir/build-hip-baseline/bin/llama-bench" \
    "$repo_dir/build-hip-baseline/bin/test-backend-ops" \
    > "$run_dir/initial-state-hashes.txt"

for variant in A B C; do
    source_dir="$run_dir/source/$variant"
    build_dir="$run_dir/build/$variant"
    mkdir -p "$run_dir/source" "$run_dir/build" "$run_dir/library/$variant"
    git -C "$repo_dir" worktree add --detach "$source_dir" HEAD \
        > "$run_dir/worktree-$variant.log" 2>&1
    case "$variant" in
        B) cp "$run_dir/sources/B.vecdotq.cuh" "$source_dir/ggml/src/ggml-cuda/vecdotq.cuh" ;;
        C) cp "$run_dir/sources/C.vecdotq.cuh" "$source_dir/ggml/src/ggml-cuda/vecdotq.cuh" ;;
    esac
    cp "$source_dir/ggml/src/ggml-cuda/vecdotq.cuh" "$run_dir/sources/$variant.vecdotq.cuh"
    git -C "$source_dir" diff --binary -- ggml/src/ggml-cuda/vecdotq.cuh \
        > "$run_dir/sources/$variant.patch"
    git -C "$source_dir" status --short > "$run_dir/sources/$variant.status"
done

cp "$run_dir/source/A/ggml/src/ggml-cuda/vecdotq.cuh" "$run_dir/sources/A.vecdotq.cuh"

configure_variant() {
    local variant="$1"
    local source_dir="$run_dir/source/$variant"
    local build_dir="$run_dir/build/$variant"
    local -a configure=(cmake -S "$source_dir" -B "$build_dir" -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang
        -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++
        -DCMAKE_HIP_COMPILER=/opt/rocm/llvm/bin/clang++
        -DCMAKE_PREFIX_PATH=/opt/rocm
        -DGGML_CUDA=OFF -DGGML_HIP=ON -DGPU_TARGETS=gfx1101 -DGGML_VULKAN=OFF
        -DGGML_NATIVE=ON -DGGML_HIP_GRAPHS=ON -DGGML_HIP_MMQ_MFMA=ON -DGGML_HIP_NO_VMM=ON
        -DLLAMA_BUILD_TESTS=ON -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_SERVER=OFF -DLLAMA_BUILD_APP=OFF)
    printf '%q ' "${configure[@]}" > "$run_dir/configure-$variant.command.txt"
    printf '\n' >> "$run_dir/configure-$variant.command.txt"
    "${configure[@]}" 2>&1 | tee "$run_dir/configure-$variant.log"
}

build_variant() {
    local variant="$1"
    local build_dir="$run_dir/build/$variant"
    cmake --build "$build_dir" --target ggml-hip -j 4 2>&1 | tee "$run_dir/build-$variant.log"
    cp -L "$build_dir/bin/libggml-hip.so.0.27.0" "$run_dir/library/$variant/libggml-hip.so.0.27.0"
    ln -sfn libggml-hip.so.0.27.0 "$run_dir/library/$variant/libggml-hip.so.0"
    ln -sfn libggml-hip.so.0 "$run_dir/library/$variant/libggml-hip.so"
}

for variant in A B C; do
    configure_variant "$variant"
    build_variant "$variant"
done

sha256sum "$run_dir"/sources/*.vecdotq.cuh "$run_dir"/library/*/libggml-hip.so.0.27.0 \
    "$repo_dir/build-hip-baseline/bin/llama-bench" \
    "$repo_dir/build-hip-baseline/bin/test-backend-ops" \
    > "$run_dir/variant-hashes.txt"

for variant in A B C; do
    cp "$run_dir/build/$variant/CMakeCache.txt" "$run_dir/CMakeCache-$variant.txt"
    cp "$run_dir/build/$variant/compile_commands.json" "$run_dir/compile_commands-$variant.json"
done

printf 'Built isolated HIP libraries for A/B/C.\n' | tee "$run_dir/builds-complete.txt"
