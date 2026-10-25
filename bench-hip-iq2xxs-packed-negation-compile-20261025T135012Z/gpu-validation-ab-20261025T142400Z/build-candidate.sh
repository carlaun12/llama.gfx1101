#!/usr/bin/env bash
set -euo pipefail

repo_dir=/home/carlos/project/llama.gfx1101
experiment_dir="$repo_dir/bench-hip-iq2xxs-packed-negation-compile-20261025T135012Z"
run_dir="$experiment_dir/gpu-validation-ab-20261025T142400Z"
source_dir="$run_dir/source-candidate"
build_dir="$run_dir/build-candidate"
control_library_dir="$run_dir/control-library"
candidate_library_dir="$run_dir/candidate-library"

if [[ ! -e "$source_dir/.git" ]]; then
    git -C "$repo_dir" worktree add --detach "$source_dir" HEAD
fi

cp "$experiment_dir/candidate/ggml-cuda/vecdotq.cuh" "$source_dir/ggml/src/ggml-cuda/vecdotq.cuh"
cmp "$experiment_dir/candidate/ggml-cuda/vecdotq.cuh" "$source_dir/ggml/src/ggml-cuda/vecdotq.cuh"

mkdir -p "$control_library_dir" "$candidate_library_dir"
cp -L "$repo_dir/build-hip-baseline/bin/libggml-hip.so.0.27.0" "$control_library_dir/libggml-hip.so.0.27.0"
ln -sfn libggml-hip.so.0.27.0 "$control_library_dir/libggml-hip.so.0"
ln -sfn libggml-hip.so.0 "$control_library_dir/libggml-hip.so"

configure=(cmake -S "$source_dir" -B "$build_dir" -G Ninja
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang
    -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++
    -DCMAKE_HIP_COMPILER=/opt/rocm/llvm/bin/clang++
    -DCMAKE_PREFIX_PATH=/opt/rocm
    -DGGML_HIP=ON -DGPU_TARGETS=gfx1101 -DGGML_VULKAN=OFF
    -DGGML_NATIVE=ON -DGGML_HIP_GRAPHS=ON -DGGML_HIP_MMQ_MFMA=ON -DGGML_HIP_NO_VMM=ON
    -DLLAMA_BUILD_TESTS=ON -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_SERVER=OFF -DLLAMA_BUILD_APP=OFF)
printf '%q ' "${configure[@]}" > "$run_dir/configure-command.txt"
printf '\n' >> "$run_dir/configure-command.txt"
"${configure[@]}" 2>&1 | tee "$run_dir/configure.log"

build=(cmake --build "$build_dir" --target ggml-hip -j 4)
printf '%q ' "${build[@]}" > "$run_dir/build-command.txt"
printf '\n' >> "$run_dir/build-command.txt"
"${build[@]}" 2>&1 | tee "$run_dir/build.log"

cp -L "$build_dir/bin/libggml-hip.so.0.27.0" "$candidate_library_dir/libggml-hip.so.0.27.0"
ln -sfn libggml-hip.so.0.27.0 "$candidate_library_dir/libggml-hip.so.0"
ln -sfn libggml-hip.so.0 "$candidate_library_dir/libggml-hip.so"

sha256sum "$repo_dir/ggml/src/ggml-cuda/vecdotq.cuh" \
    "$experiment_dir/candidate/ggml-cuda/vecdotq.cuh" \
    "$control_library_dir/libggml-hip.so.0.27.0" \
    "$candidate_library_dir/libggml-hip.so.0.27.0" \
    > "$run_dir/source-and-library-hashes.txt"
