# C decode profile: RX 7800 XT / gfx1101

Date: 2026-10-25. Diagnostic only; no source, runtime, clock, or power settings were changed. C remains active.

## State and runtime

- Active source: `ggml/src/ggml-cuda/vecdotq.cuh`, SHA-256 `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83`.
- Loaded HIP library: `build-hip-baseline/bin/libggml-hip.so.0.27.0`, SHA-256 `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8`. `ldd` for `llama-bench` resolves `libggml-hip.so.0` to this active build directory.
- `llama-bench` SHA-256 `39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25`.
- Model SHA-256 `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`.
- Effective benchmark settings in the JSON: ROCm0, `n_gpu_layers=99`, `n_cpu_moe=0`, layer split, flash attention on, K/V cache f16, batch 2048, ubatch 512, 8 CPU threads, `no_kv_offload=false` (K/Q/V offload enabled), repack enabled, one measured repetition. Nominal context is 128 for d=0 and 4224 for d=4096 (`n_prompt+n_gen+n_depth`). Build is Release with ROCm Clang 22, gfx1101, HIP graphs and MMQ MFMA enabled, matching the previous A/B command settings.

The GGUF has `qwen35.block_count=65`, `qwen35.nextn_predict_layers=1`, and four `blk.64.nextn.*` tensors; the inventory is in `model-mtp-inventory.txt`. This is weight presence only. `llama_model_default_params()` sets `load_mtp=false` (`src/llama-model.cpp:3365`), `llama-bench` obtains those defaults and does not override `load_mtp`, and `nextn_flags()` skips NextN tensors when it is false (`src/llama-model.cpp:3898-3900`). The benchmark path has no draft/MTP option. MTP was not loaded or executed in these profiles.

## Commands and phase coverage

The benchmark arguments are identical to the previous tg128 A/B command template. The only difference between commands is `-d 0` versus `-d 4096`; each trace is run separately with C's active executable/library and `LD_LIBRARY_PATH` unset so the loader follows the verified default path. Full commands are saved in each `command.txt`.

```sh
env -u LD_LIBRARY_PATH /opt/rocm/bin/rocprofv3 --kernel-trace --stats --output-format csv \
  --output-directory "$RUN/d0/trace" --output-file generation -- \
  /home/carlos/project/llama.gfx1101/build-hip-baseline/bin/llama-bench \
  -m /home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf \
  -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 \
  -r 1 -o json --progress -p 0 -n 128 -d 0
```

The d=4096 command uses the same arguments with `--output-directory "$RUN/d4096/trace"` and `-d 4096`.

Runtime options and HIP-related environment overrides match the previous A/B record (all listed overrides were unset). The loader path differs: A/B put the isolated `library/C` copy first in `LD_LIBRARY_PATH`; this profile unset `LD_LIBRARY_PATH` to exercise the active library in `build-hip-baseline`. Both libraries have the same SHA-256, and their resolved ROCm dependency files match. Details are in `loader-comparison.txt`.

`llama-bench` logs `warmup generation run` then `generation run 1/1` for d=0. For d=4096 it logs `warmup generation run`, `depth run 1/1`, then `generation run 1/1`. The README defines `-d` as prefilling the KV cache with that many tokens, and the source calls `test_prompt()` for that phase (`tools/llama-bench/README.md:96`, `tools/llama-bench/llama-bench.cpp:2447-2466`). Thus d=4096's full trace includes a 4096-token prefill in addition to warmup and generation.

The installed `rocprofv3` supports ROCTX marker-region selection, but that needs `roctxProfilerResume/Pause` markers; `llama-bench` emits no such markers. Its kernel trace does not tag model load, warmup, depth prefill, or measured generation as separate regions. `kernel-iteration-range` cannot identify those application phases. This run collected kernel dispatches, not HIP API/memory-copy traces, so model-load wall time and transfers are not included as a separate measurement. Therefore the numbers below are sums over the whole emitted kernel trace. The benchmark JSON includes a profiled `avg_ts`, but it is not normal throughput and is not used here.

## Totals and denominator

All percentages use **summed GPU kernel duration in that trace** as denominator. They are not percentages of wall time, critical path, or normal benchmark latency. Concurrent kernel durations are summed separately.

| Scenario | Summed kernel duration | Kernel calls in trace |
| --- | ---: | ---: |
| tg128, d=0 | 3166.449 ms | 230,764 |
| tg128, d=4096 | 9408.074 ms | 250,322 |

The per-kernel time, call count, average duration and share are in `d0/kernel-details.csv` and `d4096/kernel-details.csv`. The original full kernel traces, summaries and stdout/stderr are retained under each scenario.

## Quantized matrix-vector paths

In `mul_mat_vec_q<type,1,has_fusion,...>`, `has_fusion=false` is the plain path and `true` is the fused gate/up path (`ggml/src/ggml-cuda/mmvq.cu:1046-1075`). Below are totals by quant type across the two paths. Full plain/fused rows and call counts are in `quant-matvec-by-type-path.csv`.

| Weight type | d=0 time | d=0 share | d=4096 time | d=4096 share of full trace |
| --- | ---: | ---: | ---: | ---: |
| IQ3_S | 589.325 ms | 18.61% | 589.553 ms | 6.27% |
| IQ3_XXS | 550.465 ms | 17.38% | 551.236 ms | 5.86% |
| IQ2_S | 469.399 ms | 14.82% | 468.817 ms | 4.98% |
| IQ4_XS | 335.173 ms | 10.59% | 337.928 ms | 3.59% |
| IQ2_XS | 228.174 ms | 7.21% | 227.845 ms | 2.42% |
| IQ2_XXS | 202.098 ms | 6.38% | 201.997 ms | 2.15% |
| Q2_K | 159.243 ms | 5.03% | 159.913 ms | 1.70% |
| Q4_K | 96.039 ms | 3.03% | 96.674 ms | 1.03% |
| IQ1_M | 16.952 ms | 0.54% | 16.831 ms | 0.18% |
| IQ1_S | 15.041 ms | 0.48% | 14.817 ms | 0.16% |

Largest individual decode groups at d=0:

| Kernel group | Calls | Time | Share of d=0 trace |
| --- | ---: | ---: | ---: |
| IQ3_S plain MMVQ | 8,256 | 331.777 ms | 10.48% |
| IQ3_XXS plain MMVQ | 7,482 | 329.190 ms | 10.40% |
| IQ4_XS plain MMVQ | 3,612 | 280.307 ms | 8.85% |
| IQ2_S plain MMVQ | 5,805 | 268.523 ms | 8.48% |
| IQ3_S fused MMVQ | 3,741 | 257.547 ms | 8.13% |
| IQ3_XXS fused MMVQ | 2,709 | 221.274 ms | 6.99% |
| IQ2_S fused MMVQ | 2,709 | 200.876 ms | 6.34% |

The d=4096 MMVQ type/path totals are within 0.14% of d=0 overall, with almost identical call counts. Their percentages are smaller because the d=4096 denominator includes prefill kernels.

## Other kernel families

| Family | d=0 calls / time / share | d=4096 calls / time / share |
| --- | --- | --- |
| Quantized MMVQ | 49,536 / 2661.909 ms / 84.07% | 49,544 / 2665.611 ms / 28.33% |
| Quantized MMQ | 0 / 0 ms / 0% | 2,096 / 3237.509 ms / 34.41% |
| Dense GEMM / hipBLAS | 0 / 0 ms / 0% | 1,848 / 1697.851 ms / 18.05% |
| Q8_1 activation quantization for MMVQ | 49,536 / 71.356 ms / 2.25% | 49,544 / 71.643 ms / 0.76% |
| Q8_1 activation quantization for MMQ | 0 / 0 ms / 0% | 2,096 / 76.826 ms / 0.82% |
| Attention kernels | 4,128 / 27.510 ms / 0.87% | 4,256 / 311.370 ms / 3.31% |
| GDN | 6,192 / 47.187 ms / 1.49% | 6,576 / 264.355 ms / 2.81% |
| RMS norm | 39,345 / 99.287 ms / 3.14% | 41,773 / 154.904 ms / 1.65% |
| Row gather | 12,642 / 68.642 ms / 2.17% | 13,414 / 74.416 ms / 0.79% |
| Dequantization | 0 / 0 ms / 0% | 1,080 / 242.573 ms / 2.58% |
| BF16/F16 matrix-vector | 12,384 / 62.009 ms / 1.96% | 12,384 / 62.115 ms / 0.66% |
| Other kernels | 46,681 / 98.547 ms / 3.11% | 54,751 / 464.311 ms / 4.94% |

The d=4096 trace's largest kernel entries are a hipBLAS/Tensile GEMM (`Cijk...`: 1,064 calls, 1666.064 ms), IQ3_S MMQ (776 calls, 1160.587 ms), and IQ3_XXS MMQ (664 calls, 1155.855 ms). These are dominated by the explicit depth prefill, not a pure decode-only slice. The category detail and remaining kernels are in the CSVs.

## Three largest decode quant groups: observations and hypotheses

These are timed observations, not proof of a bandwidth or arithmetic limit. No hardware counters for memory throughput, issue rate, or stalls were collected.

### 1. IQ3_S

**Observed:** 589.325 ms, 11,997 MMVQ calls, 18.61% of d=0 summed kernel time. Plain contributes 331.777 ms; fused contributes 257.547 ms.

**Code and hypothesis:** `vec_dot_iq3_s_q8_1()` expands signs, then sends eight `ggml_cuda_dp4a` results through one serial `sumi` recurrence (`ggml/src/ggml-cuda/vecdotq.cuh:1277-1310`). A small isolated candidate could split this recurrence into two independent integer accumulators, then combine them before applying the existing scale. This may expose instruction-level overlap. `IQ2_S` already uses two accumulators in the same file (`:1203-1229`), which is a nearby pattern, but does not prove a gain for IQ3_S.

**Risk:** the compiler may already schedule the dependencies well; extra live registers can hurt occupancy or produce no speedup. Integer reordering is exact only after confirming the dot sum cannot overflow for the IQ3_S/Q8_1 bounds. No memory-vs-compute diagnosis follows from the kernel time.

**Smallest test:** compile only a C+IQ3_S accumulator-split variant; compare plain/fused gfx1101 ISA and VGPR allocation. If it creates two interleavable DP4A chains without spills or a worse resource allocation, compare exact IQ3_S backend outputs, then run paired tg128 d=0 and d=4096 against C.

### 2. IQ3_XXS

**Observed:** 550.465 ms, 10,191 calls, 17.38% of d=0 summed kernel time; 329.190 ms plain and 221.274 ms fused.

**Code and hypothesis:** `vec_dot_iq3_xxs_q8_1()` also accumulates eight DP4A operations into one `sumi` (`vecdotq.cuh:1238-1270`). Two accumulators are a possible separate experiment, but it should follow IQ3_S so this round stays one variable. Prior direct sign expansion for IQ3_XXS reduced static instruction sites but raised VGPR counts and did not demonstrate a throughput win: the paired CIs included zero. Do not repeat that direct-sign change here.

**Risk:** the same register pressure is material, and the prior direct-sign result gives no evidence that reducing source operations alone is enough. A new accumulation schedule could still be neutral or regress.

**Smallest test:** use the prior IQ3_XXS ISA artifacts as control; first determine whether the current DP4A accumulator is a true emitted dependency. If so, compile a two-accumulator-only variant and check registers before correctness or A/B.

### 3. IQ2_S

**Observed:** 469.399 ms, 8,514 calls, 14.82% of d=0 summed kernel time; 268.523 ms plain and 200.876 ms fused.

**Code and hypothesis:** the direct sign expansion already present in C is not a candidate to repeat. `vec_dot_iq2_s_q8_1()` already keeps two partial sums and combines them with their separate scales (`vecdotq.cuh:1203-1229`). A narrower possible change is to expose the Q8 activation loads earlier relative to sign/table decode, allowing the compiler to overlap independent work.

**Risk:** source order may not constrain machine scheduling; the compiler may emit the same ISA. IQ2_S signs have already had a direct-expansion optimization, so a second source-only rewrite has little evidence unless disassembly shows a concrete dependency.

**Smallest test:** compare current gfx1101 ISA for plain/fused IQ2_S with a load-hoisted-only candidate. If emitted instructions or dependency placement do not change, stop without a full A/B.

## Next experiment

Prioritize the **IQ3_S two-accumulator scheduling experiment**. It targets the largest decode quant group (18.61%), changes one function, does not repeat the accepted IQ3_S sign expansion or the unproven IQ3_XXS direct-sign attempt, and has a clear static check before a GPU A/B. The measured group bounds the opportunity: even a local improvement would affect only part of the full decode trace, and profile time cannot be translated directly to throughput.

If the ISA check is favorable, the smallest full performance test is C versus C+IQ3_S accumulator split, with no other source/runtime change, at tg128 d=0 and d=4096, at least 10 paired repetitions per depth, balanced order, same A/B flags, and the existing 190 W setting left untouched. Keep prompt-prefill measurements separate. Preserve the shared IQ3_XXS backend-test limitation from the cumulative validation; this profiling run does not resolve it.

## Telemetry and limits

The power cap read before profiling was `190000000` uW and was not changed. One-second sysfs samples show:

| Scenario | Samples / busy samples (>=95%) | Mean busy-sample power | Max sampled power | Junction range | Memory range | Mean busy SCLK / MCLK |
| --- | --- | ---: | ---: | --- | --- | --- |
| d=0 | 6 / 4 | 189.0 W | 211 W | 39-54 C | 56-64 C | 2441.5 / 1218 MHz |
| d=4096 | 13 / 10 | 173.5 W | 193 W | 42-62 C | 56-66 C | 2384.9 / 1218 MHz |

The sampled power exceeded the configured cap in both traces; the configured value was left untouched. These short samples are context for this profile, not a power-accuracy test. The d=4096 power/clock averages include model setup, warmup and depth prefill and should not be compared as performance results.

## Artifacts

- `d0/command.txt`, `d4096/command.txt`: full commands.
- `d0/trace/`, `d4096/trace/`: raw rocprofv3 CSVs, including complete kernel traces.
- `d0/kernel-summary.json`, `d4096/kernel-summary.json`: full per-kernel totals from the existing summarizer.
- `d0/kernel-details.csv`, `d4096/kernel-details.csv`: every kernel name with calls, summed time, average and share.
- `quant-matvec-by-type-path.csv`, `quant-mmq-by-type.csv`, `operation-groups.csv`: grouped views.
- `d0/telemetry.csv`, `d4096/telemetry.csv`, `telemetry-summary.csv`: sampled GPU state.
- `environment.txt`, `CMakeCache.txt`, `final-state.txt`, `model-mtp-inventory.txt`: runtime/build/device identity.
- `analyze-profile.py`: grouping script for this report.
- Existing infrastructure reused: `scripts/profile-hip-generation.sh` workflow and `scripts/summarize-hip-profile.py`; the build step in the wrapper was skipped to preserve the active C library.
