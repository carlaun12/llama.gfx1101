# IQ3_S two-accumulator experiment

Target: RX 7800 XT / gfx1101. Model SHA-256: `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`.

## Control, candidate, and isolation

C was verified before compilation and remains active. Its source hash is `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83`; its active HIP library hash is `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8`. The final unmodified-environment `ldd` check resolves `llama-bench` to `build-hip-baseline/bin/libggml-hip.so.0`, backed by that hash.

D is isolated under `source/D`, `build/D`, and `library/D`. C and D use the same Release/ROCm Clang 22/gfx1101 configuration and HIP options. Normalizing the source/build paths in the two recorded CMake commands makes them identical. The C-to-D source tree comparison reports only `ggml/src/ggml-cuda/vecdotq.cuh`; no active source or library was replaced.

| Variant | Source header SHA-256 | HIP library SHA-256 |
| --- | --- | --- |
| C control | `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83` | `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8` |
| D candidate | `1d074b8cae5845d0d794f803292c4c1d05ecfc3ef0d58befb3bdcf99bea0e794` | `ee87339b8a9b3657a7c317a8e33e4e00f1e1c7f63f58e0a5b4e0c069b42671b9` |

The complete diff is in `candidate.diff`; the build source copies are under `source/C` (prior validation artifact) and `source/D` (this run). The candidate changes only the IQ3_S integer accumulation. It leaves codebook indices, sign extraction/application, activation loads, scale placement, half conversions, and final float multiplication unchanged. The IQ3_S function has no integer division; the nearby division in the source belongs to IQ3_XXS and was not touched.

## Integer bounds and exactness

The 512-entry `iq3s_grid` has 2,048 magnitude bytes. Direct enumeration found only `{1,3,5,7,9,11,13,15}` and no zero values. Sign application therefore produces signed weights in `[-15,15]`. Each Q8_1 activation lane is an `int8_t`, in `[-128,127]`.

A single 4-lane DOT4 has absolute value at most `4 * 15 * 128 = 7,680`. Each candidate accumulator contains four DOT4 results, so its absolute bound is `30,720`. Their sum contains all eight terms and is bounded by `61,440`, far below `INT32_MAX`. The unchanged scale multiplier is 1..31, so the largest scaled integer magnitude is `1,904,640`, also within int32. The split and original accumulation are therefore exact for the valid IQ3_S/Q8_1 domain; this is not a claim about arbitrary packed bytes outside that domain.

`accum-equivalence.hip` ran 524,288 GPU cases. It swept every table index, each of the 16 sign nibbles at each of the eight term positions, and eight activation patterns including signed extremes. The original sequential recurrence, the two-accumulator candidate, and an independent int64 scalar byte-product reference matched exactly in every case. The largest absolute sum in those sampled cases was 18,346; the wider safety bound above is analytic.

The candidate HIP library also passed 49/49 IQ3_S `MUL_MAT` and `MUL_MAT_VEC_FUSION` backend cases. It passed 56/56 IQ3_S tests using the GGUF's distinct plain K/N shapes plus the model's fused gate/up shape (`K=5120, N=17408`). Both paths ran on ROCm0 with seed 4321 and the loader selected D's isolated library.

## ISA comparison

Fresh control and candidate assembly used the active build's compile flags and isolated copies of `mmvq.cu`/`vecdotq.cuh`. The emitted DOT4 dependency chains are:

| Path | C control | D candidate |
| --- | --- | --- |
| Plain | 8 DOT4 in one chain of 8 | 8 DOT4 in two chains of 4 |
| Fused | 16 DOT4 in two independent chains of 8 (the fused outputs) | 16 DOT4 in four chains of 4 |

Thus the compiler did not already split a single IQ3_S accumulation. It already interleaved the independent fused outputs; D further splits each output's own chain. The number of global load instructions is unchanged (28 plain, 47 fused), but their order differs in the scheduler output.

| Path | Variant | Static instructions | VGPR | SGPR | VGPR/SGPR spills | Private segment |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Plain | C | 303 | 39 | 24 | 0 / 0 | 0 |
| Plain | D | 300 | 45 | 24 | 0 / 0 | 0 |
| Fused | C | 764 | 54 | 48 | 0 / 0 | 0 |
| Fused | D | 768 | 59 | 48 | 0 / 0 | 0 |

The split survives compilation without spills. It costs 6 VGPR in plain and 5 in fused; total static instruction count falls by 3 in plain and rises by 4 in fused. The corresponding full assembly and AMDGPU metadata are under `isa/`.

## Paired decode benchmark

C and D ran in the same session with the same host executable, model, flags, loader setup, warmup, and `llama-bench -r 1`. Each process ran `-p 0 -n 128 -d 0,4096`; logs show warmup and measured generation for both depths, including a depth-prefill phase for d=4096. MTP was disabled: `llama-bench` uses the model default `load_mtp=false`, and no draft/MTP option was passed. There were 10 adjacent pairs per depth, with five C-D and five D-C orders. The 20 raw JSON and stderr logs are retained.

The metric is `avg_ts` in tokens/s. Each paired gain is `100 * (D/C - 1)`. The 95% interval is a two-sided paired Student t interval across the 10 gains (df=9, critical value 2.262157). Decode depths are reported separately.

| Depth | C mean | D mean | Mean paired gain | 95% CI | Result |
| ---: | ---: | ---: | ---: | ---: | --- |
| d=0 | 35.2859 t/s | 35.3054 t/s | +0.058% | -0.360% to +0.476% | Inconclusive |
| d=4096 | 34.5413 t/s | 34.6232 t/s | +0.238% | +0.020% to +0.456% | Positive in this paired sample |

Per-pair values are in `paired-results.csv`; the calculation is recorded in `paired-summary.txt`. The d=4096 interval only narrowly excludes zero. No result from a profiler is used as throughput.

## Telemetry and caveats

The power cap read before and after the run was 190 W; no clock or power controls were changed. One-second samples during the combined runs show:

- C: 123/137 samples at >=95% GPU use; busy-sample mean/max power 189.9/204 W; mean SCLK 2,337 MHz (range 2,205-2,435); junction 50-78 C; memory 57-84 C.
- D: 125/139 samples at >=95% GPU use; busy-sample mean/max power 187.9/206 W; mean SCLK 2,343 MHz (range 2,229-2,482); junction 54-78 C; memory 64-84 C.

Short telemetry samples exceeded the reported 190 W cap (62 C samples and 51 D samples). Mean busy SCLK was about 6 MHz higher for D, a small but relevant confound for the roughly 0.24% d=4096 effect. The samples span model load, warmup, d=4096 prefill, and generation in each process, so they are not separated by depth. The console emitted the ROCm low-power-state warning at the session boundaries; the logged busy samples show high utilization and clocks above 2.2 GHz. No benchmark log reported an error.

## Recommendation

**Keep the result inconclusive; do not promote D.** The source transformation is exact and the GPU/backend checks pass. The model-level data show no demonstrated gain at d=0 and only a small d=4096 gain whose interval barely clears zero while D also sampled at slightly higher SCLK. This does not establish a reliable improvement across decode contexts.

C remains active and unchanged. D remains isolated for review; no commit or promotion was made.

## Artifacts

- `candidate.diff`: source change.
- `isa/control.s`, `isa/candidate.s`, `isa/*-*.body.s`, `isa/resource-summary.txt`, `isa/*-object-notes.txt`: machine code and resources.
- `accum-equivalence.hip`, `accum-equivalence.command.txt`, `accum-equivalence.log`: GPU integer checker.
- `backend-generic-D.command.txt`, `backend-generic-D.log`: 49 generic cases.
- `backend-model-shapes-D.command.txt`, `backend-model-shapes-D.log`, `loader-model-shapes-D.txt`: 56 model-shape cases.
- `run-ab.sh`, `01-C` through `20-C/D` `.command.txt`, `.json`, `.log`: benchmark sequence and raw results.
- `paired-results.csv`, `paired-summary.txt`: pairwise statistics.
- `telemetry.jsonl`, `telemetry-samples.csv`, `telemetry-before.txt`, `telemetry-after.txt`: telemetry.
- `binary-hashes.txt`, `final-hashes.txt`, `loader-llama-bench-C.txt`, `loader-llama-bench-D.txt`, `final-loader-active-C.txt`: binary and loader checks.
- `configure-D.command.txt`, `build/D/CMakeCache.txt`, `source-tree-diff.txt`: isolated build setup and source scope.
