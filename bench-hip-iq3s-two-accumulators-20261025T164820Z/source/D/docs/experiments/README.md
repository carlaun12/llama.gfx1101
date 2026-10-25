# RX 7800 XT HIP experiments

Local experiment log for branch `experiment_1`. Dates in artifact names use UTC; the measurements started on 2026-10-19 in America/Sao_Paulo.

## Current state

| ID | Change | Decision |
| --- | --- | --- |
| E001 | Move the Qwen35 alpha reshape after its bias addition | Retained; small observed improvement needs alternating comparisons |
| E002 | Fuse RMSNorm, weight multiplication, SiLU and gate multiplication | Retained; confirmed active in the GPU trace, small observed improvement |
| E003 | Two warps for IQ3_XXS decode on gfx1101 | Rejected; generation regressed by about 2.6-2.9% |
| E004 | Two independent integer accumulators in IQ3_XXS vec_dot | Rejected; no measurable end-to-end improvement |
| E005 | Two IQ3_XXS output rows per warp on gfx1101 | Rejected; no benefit, generation decreased by 0.33-0.48% |

The active source contains E001 and E002. E003, E004 and E005 are absent. The matrix-vector kernel uses the original launch parameters and single-accumulator vec_dot.

The first commits were `697b93eb2` (baseline script and initial measurements), `58182cfec` (E001) and `c7411aa4c` (E001 results). E002 and subsequent experiments were tested as uncommitted changes. The `build_commit` field alone does not identify their code: retain each run's `source.diff` as well.

## Hardware and model

- GPU: AMD Radeon RX 7800 XT, gfx1101, 16,368 MiB reported VRAM, wave size 32.
- CPU: AMD Ryzen 7 5700X, 8 cores.
- Backend: HIP/ROCm, Release build targeting `gfx1101`. The profile reports ROCm 7.2.4 and rocprofv3 1.1.0.
- Model: `$HOME/slop/Qwen3.8-27B-UD-IQ3_XXS.gguf`, from Unsloth.
- Model SHA-256: `c0b7c3038681ed2e3040456c1dd45f9858b6c2290bed172c70388a94874f3eee`.
- GGUF architecture: `qwen35`; 64 main layers and one additional MTP layer; embedding width 5120; FFN width 17408.
- The regular layer pattern is three Gated DeltaNet layers followed by one full-attention layer, giving 48 linear-attention and 16 full-attention layers.
- The file uses mixed quantization. IQ1, IQ2, IQ3, IQ4 and K-quants occur among its weights; the filename does not describe every tensor.

The user selected 190 W as the operating limit after the initial run. Later runs are labeled 190 W based on that session setting. The original benchmark script did not record power caps. The profile did record `power1_cap=190000000` microwatts.

## Benchmark protocol

The runner is [baseline-hip-gfx1101.sh](../../scripts/baseline-hip-gfx1101.sh). It builds incrementally into `build-hip-baseline`, checks for the RX 7800 XT at `ROCm0`, and saves the source diff, commands, environment, build configuration and measurements.

Fixed benchmark parameters:

```text
-dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16
-b 2048 -ub 512 -t 8 -r 5 -o json --progress
```

The model is offloaded to the GPU; KV caches are F16. Warmup is enabled. MTP is not used by these llama-bench tests. HIP graphs remain enabled in the build configuration.

The four cases are prompt processing with 512 and 2048 tokens, and generation of 128 tokens at initial context depths 0 and 4096. The context-prefill work for the depth-4096 case is outside the generation timing. llama-bench excludes tokenization and sampling from these measurements.

Each table entry below is the average of five repetitions in tokens/second. Exact means, standard deviations and individual samples are archived in [results.json](results.json), [results.csv](results.csv), and the per-run files under [runs/](runs/).

| Configuration | pp512 | pp2048 | tg128, depth 0 | tg128, depth 4096 |
| --- | ---: | ---: | ---: | ---: |
| Initial run, before the 190 W setting | 657.94 | 647.67 | 32.26 | 30.63 |
| Baseline, 190 W | 635.63 | 628.41 | 31.24 | 30.64 |
| E001: alpha reshape | 645.76 | 636.19 | 31.70 | 30.94 |
| E002: E001 plus RMSNorm/SiLU fusion | 648.43 | 638.94 | 31.88 | 31.15 |
| E003: E002 plus two warps | 648.01 | 639.05 | 30.97 | 30.34 |
| E004: E002 plus two accumulators | 647.33 | 639.93 | 31.83 | 31.16 |
| E005: E002 plus two rows per warp | 648.01 | 639.14 | 31.73 | 31.05 |

The comparisons were sequential, not alternating A/B runs. The initial power setting differs from the later baseline. Temperature, clocks and background GPU activity were not recorded by the original benchmark runner. Small improvements are observations, not established causal speedups. Changes to different hypotheses must be measured separately.

## E001: alpha projection and bias

Source: [qwen35.cpp](../../src/models/qwen35.cpp), `build_layer_attn_linear`. Patch: [0001-alpha-bias-fusion.diff](patches/0001-alpha-bias-fusion.diff).

The original sequence was projection, reshape, bias addition. Moving the reshape after the bias makes the projection and bias adjacent, allowing the existing matrix-vector/bias fusion during single-token decode. The checkpoint's alpha weights are Q8_0, with dimensions 5120 by 48.

This can remove one separate bias kernel per linear-attention layer, or up to 48 launches per generated token. The arithmetic and tensor values are unchanged.

Validation: HIP build passed. A separate GGML CPU check compared the original and new orders with F32 and Q8_0 weights, token counts 1, 17 and 512, and one or two sequences. All 12 cases were bit-exact and the new graph matched the projection/bias fusion pattern.

Run: [20261020T003050Z](runs/baseline-hip-20261020T003050Z-IuI2h6/). Relative to the 190 W baseline, generation increased by 1.48% at depth 0 and 0.97% at depth 4096. Retained provisionally.

## E002: RMSNorm and SiLU gate fusion

Sources: `ggml/src/ggml-cuda/norm.cu`, `norm.cuh`, `ggml-cuda.cu`, and Qwen35 `build_norm_gated`. Patch: [0002-rmsnorm-silu-gate.diff](patches/0002-rmsnorm-silu-gate.diff).

Fuse `RMSNorm(input) * weight * SiLU(gate)` into one kernel. Build the gate branch before the normalization to keep the four operations adjacent in the graph. Reuse the existing RMSNorm kernel and dispatch logic.

The matcher requires F32 tensors, matching shapes, a contiguous vector of weights, contiguous gate/output tensors and contiguous input rows. Strided input rows are supported. Other layouts, reused intermediate outputs, explicit inplace operations, and unsafe overlapping buffers fall back to existing operations. Exact output/input buffer reuse is allowed only for the supported row-local read/write layout.

Validation: HIP build passed; 15 backend cases passed on CPU, covering scalar/vector widths, batches, sequences, strided inputs, fallback cases, swapped multiplication inputs and dimensions above the grid limit. GPU-test stdout was not archived with the benchmark. The later GPU trace proves the fused kernel executed: `rms_norm_f32<32, 1, true, true, false, false, true>` appeared 6,192 times, matching 48 layers times 129 decode steps including warmup.

Run: [20261020T004601Z](runs/baseline-hip-20261020T004601Z-LQyC4l/). Relative to E001, generation increased by 0.58% at depth 0 and 0.69% at depth 4096. Relative to the original 190 W baseline, the accumulated observed improvement was 1.67-2.07% across the four cases. Retained provisionally.

## GPU profile after E002

Runner: [profile-hip-generation.sh](../../scripts/profile-hip-generation.sh). Analyzer: [summarize-hip-profile.py](../../scripts/summarize-hip-profile.py).

The capture uses `rocprofv3 --kernel-trace --stats --output-format csv`, with 128 generated tokens, no prompt/depth prefill, one repetition, and the normal one-token warmup. HIP graphs and fusion stay enabled. Setup kernels are included. Profiled throughput is not a substitute for the unprofiled benchmark.

Run: `profile-hip-20261020T005155Z-ZzsihC`. Archived summary: [profiles/](profiles/profile-hip-20261020T005155Z-ZzsihC/). The complete trace is versioned as [generation_kernel_trace.csv.gz](../../profile-hip-20261020T005155Z-ZzsihC/trace/generation_kernel_trace.csv.gz). The uncompressed CSV remains local in the original profile directory. Decompress the archive before using the analyzer on another checkout.

Summed GPU kernel duration: 3487.051 ms. Percentages below use summed kernel duration, not wall-clock time; they do not establish whether a kernel is memory-bound or instruction-bound.

| Matrix-vector weight type | GPU time, ms | Share of summed kernel time |
| --- | ---: | ---: |
| IQ3_XXS | 894.451 | 25.65% |
| IQ3_S | 758.352 | 21.75% |
| IQ4_XS | 340.046 | 9.75% |
| IQ2_S | 308.653 | 8.85% |
| Q4_K | 218.554 | 6.27% |
| IQ2_XXS | 189.119 | 5.42% |
| IQ2_XS | 108.470 | 3.11% |

IQ3_XXS and IQ3_S together account for about 47.4% of kernel time. The trace shows IQ3_XXS using a 32-thread workgroup, with 48 reported VGPRs in the plain kernel and 56 in the fused kernel; reported scratch usage is zero for these entries. Large IQ3_XXS grid sizes correspond to FFN-sized output dimensions. Gated DeltaNet accounts for about 1.34% of kernel time in this capture.

## E003: two warps for IQ3_XXS

Source: `ggml/src/ggml-cuda/mmvq.cu`. Patch: [0003-two-warps.diff](patches/0003-two-warps.diff).

Select a dedicated gfx1101 parameter table and increase IQ3_XXS single-token decode from one to two warps per block. Keep other types and architectures unchanged. The hypothesis was that distributing the K loop over more threads could shorten each row's computation.

Validation: HIP build passed; a host comparison checked 1,376 parameter combinations and verified the intended scope. Six targeted CPU backend cases covered IQ3_XXS with bias or fused SwiGLU at K values 256, 5120 and 17408. GPU-test stdout was not archived.

Run: [20261020T005547Z](runs/baseline-hip-20261020T005547Z-KEflXU/). Relative to E002:

- Prompt cases: -0.06% and +0.02%, effectively unchanged.
- Generation at depth 0: 31.882439 to 30.969020 tokens/s, or -2.86%.
- Generation at depth 4096: 31.149671 to 30.338985 tokens/s, or -2.60%.

Rejected. The one-warp configuration was restored and rebuilt before E004. This result does not prove which hardware cost caused the regression.

## E004: two integer accumulator chains

Source: `ggml/src/ggml-cuda/vecdotq.cuh`, `vec_dot_iq3_xxs_q8_1`. Patch: [0004-two-accumulators.diff](patches/0004-two-accumulators.diff).

Replace the eight dependent integer dot-product updates with two independent chains, then combine their results before the original scale calculation. Keep one warp per block. The hypothesis was that instruction-level parallelism could reduce dependency stalls.

Validation: HIP build passed. A host emulation of the original and changed function compared 1,600,000 dot products, including extreme activation values, with bit-exact results under undefined-behavior sanitization. The integer bound before the final division is 3,936,256, below the signed 32-bit limit. A gfx1101 probe showed two independent dot-product chains and the same 35 VGPRs before/after; this register count applies only to that probe. All 55 selected IQ3_XXS CPU backend cases passed. GPU-test stdout was not archived.

Run: [20261020T010605Z](runs/baseline-hip-20261020T010605Z-ASw2Dn/). Relative to E002:

- Prompt cases: -0.17% and +0.15%.
- Generation at depth 0: -0.17%.
- Generation at depth 4096: +0.02%.

Rejected because no measurable end-to-end benefit was demonstrated. The original single-accumulator function was restored before E005.

## E005: two IQ3_XXS rows per warp

Source: `ggml/src/ggml-cuda/mmvq.cu`. Patch: [0005-two-rows.diff](patches/0005-two-rows.diff).

Reuse the existing multi-row matrix-vector kernel with two output rows per block, keeping one 32-lane warp. Enable this only for gfx1101, IQ3_XXS and one output token. Other types, architectures and token batch sizes retain their previous parameters.

Both rows use the same Q8_1 activation data. The hypothesis is that grouping rows can reuse activation loads and reduce block count. Possible costs include increased register pressure and lower occupancy. Neither a benefit nor actual load reuse is assumed before measurement.

An explicit check skips the second row when it exceeds the actual output row count, preventing an out-of-range weight read for odd row counts. The kernel receives that count separately from the output stride, which can include multiple experts in the ID layout. The same bound protects bias reads and result writes. Targeted tests cover output row counts 1, 63, 64 and 65, with and without the gate, at K values 256, 5120 and 17408. Additional ID-layout cases cover 63 rows and two selected experts.

Validation: HIP compilation passed. All 75 selected IQ3_XXS CPU backend cases passed. A host parameter check covered 1,376 configurations, confirmed unchanged warp counts, and verified that only the intended configuration changes to two rows. Its row-coverage simulation includes odd tails. The same 75 selected cases subsequently passed on ROCm0; their output is archived in [gpu-tests.txt](validation/E005/gpu-tests.txt). Logs and the parameter checker are archived under [validation/E005/](validation/E005/).

The comparison control is E002, not E003 or E004. The run used the session setting of 190 W. The test and benchmark commands were:

```bash
set -o pipefail
build-hip-baseline/bin/test-backend-ops -b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p iq3_xxs 2>&1 |
    tee docs/experiments/validation/E005/gpu-tests.txt &&
bash scripts/baseline-hip-gfx1101.sh
```

The benchmark script can reconfigure tests off without deleting the already built test executable. It reuses the existing build directory and rebuilds only changed dependencies. Changes to `vecdotq.cuh` trigger a larger HIP rebuild because many kernels include that header.

Run: [20261020T012102Z](runs/baseline-hip-20261020T012102Z-vXuCZL/). Relative to E002:

- Prompt cases: -0.06% and +0.03%, effectively unchanged.
- Generation at depth 0: 31.882439 to 31.729446 tokens/s, or -0.48%.
- Generation at depth 4096: 31.149671 to 31.047529 tokens/s, or -0.33%.

Rejected because this run demonstrated no benefit and both generation means decreased. This small difference has not been confirmed with alternating control/experiment runs and does not establish a hardware cause. The original matrix-vector source was restored after preserving the patch and measurements. The additional correctness tests remain. The HIP rebuild of `llama-bench` after restoring the source passed; its output is archived in [revert-build.txt](validation/E005/revert-build.txt).

## Artifacts and next measurements

The [runs/](runs/) archive contains raw benchmark JSON, source diffs, commands and recorded environment for every measured variant. [results.csv](results.csv) and [results.json](results.json) provide a consolidated index. The [patches/](patches/) archive retains changes independently of the current working tree; patches describe alternatives and must not all be applied together. Supplemental local checks are archived under [validation/](validation/).

Original root-level run directories also retain configure/build logs, CMake caches and rocminfo output. Local binary snapshots are ignored by Git: `build-hip-reference-31288c9c6`, `build-hip-reference-alpha`, and `build-hip-reference-norm`. Their `run-bench.sh` wrappers set `LD_LIBRARY_PATH` because copied binaries retain their original absolute RUNPATH. Use the matching wrapper to avoid accidentally loading newer libraries.

For each new measurement, record the power setting, exact source diff, test output, benchmark command and results before changing another hypothesis. Use alternating control/experiment runs to establish gains smaller than a few percent. A fresh kernel trace can distinguish a change in IQ3 kernel duration from changes elsewhere, while preserving the same workload and settings.

## Candidate analysis after E005

See [optimization-candidates.md](optimization-candidates.md) for the prioritized analysis, source evidence, costs and measurement requirements before implementing another experiment.
