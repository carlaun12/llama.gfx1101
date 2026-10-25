# `unpack_ksigns` `amdgcn_perm` experiment

Target: RX 7800 XT (`gfx1101`). Control C remained active in the fork. Candidate E was built and benchmarked from an isolated source tree.

## Result

The candidate replaces the HIP broadcast multiply with one `v_perm_b32` in the relevant kernels. It preserves the same registers and load schedule. Backend correctness checks passed for both variants, and the exhaustive GPU helper check matched for all 256 byte values.

The decode result is mixed by depth: E measured **+0.723%** at `d=0` with a 95% paired interval crossing zero, and **+1.057%** at `d=4096` with an interval above zero. This does not establish a reliable improvement across both decode scenarios. **Recommendation: retain C; keep E isolated and treat its model-level result as inconclusive for general adoption.**

## Variant identity and scope

| Variant | Source `vecdotq.cuh` SHA-256 | HIP library SHA-256 |
| --- | --- | --- |
| C control | `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83` | `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8` |
| E candidate | `9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c` | `ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24` |

The complete C-to-E source diff is [`candidate.diff`](candidate.diff). It changes only `unpack_ksigns` in the HIP branch:

```cpp
#if defined(GGML_USE_HIP)
    return __builtin_amdgcn_perm(0, s, 0);
#else
    return s * 0x01010101;
#endif
```

The parity correction that reconstructs the eighth sign remains before the branch. Sign extraction and application, accumulators, and non-HIP code are unchanged. The IQ3_S two-accumulator candidate was not included; the C source and library hashes still match the C manifest.

C and E used Release builds with ROCm Clang from `/opt/rocm`, target `gfx1101`, and matching normalized CMake values. Normalized compile commands matched for `mmvq.cu` and the IQ2_XXS, IQ2_XS, and IQ3_XXS MMQ instantiations. See [`build-settings-compare.txt`](build-settings-compare.txt) and [`normalized-compile-settings.txt`](normalized-compile-settings.txt). The same `llama-bench` executable was used for both variants.

## Consumers and ISA

`unpack_ksigns` has three MMVQ consumers in `vecdotq.cuh` (IQ2_XXS, IQ2_XS, IQ3_XXS) and three MMQ consumers in `mmq-load-tiles.cuh` for the same formats. The C assembly lowers the broadcast multiply to `v_mul_lo_u32`; E lowers it to `v_perm_b32`. The compiler did not already make these forms equivalent.

MMVQ focused plain/fused kernels:

| Type | Path | Static instructions C -> E | Broadcast C -> E | DOT4 C/E | Loads C/E | VGPR C/E | SGPR C/E | Private bytes C/E |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| IQ2_XXS | plain | 309 -> 309 | 4 mul -> 4 perm | 8/8 | 21/21 | 36/36 | 22/22 | 0/0 |
| IQ2_XXS | fused | 768 -> 765 | 8 mul -> 8 perm | 16/16 | 33/33 | 49/49 | 46/46 | 0/0 |
| IQ2_XS | plain | 341 -> 342 | 4 mul -> 4 perm | 8/8 | 22/22 | 43/43 | 22/22 | 0/0 |
| IQ2_XS | fused | 844 -> 843 | 8 mul -> 8 perm | 16/16 | 35/35 | 58/58 | 46/46 | 0/0 |
| IQ3_XXS | plain | 330 -> 329 | 4 mul -> 4 perm | 8/8 | 26/26 | 36/36 | 22/22 | 0/0 |
| IQ3_XXS | fused | 816 -> 816 | 8 mul -> 8 perm | 16/16 | 43/43 | 50/50 | 46/46 | 0/0 |

Representative plain and fused instruction-event schedules retain the same load, popcount, broadcast, and DOT4 ordering. The broadcast remains a single producer-to-consumer operation; the replacement adds no dependency chain. No MMVQ resource record changed.

For MMQ, each type's template compilation replaces 176 broadcast multiplies with 176 permutes. Aggregate static instruction totals across instantiated kernels were IQ2_XXS `17981 -> 17973`, IQ2_XS `17979 -> 17981`, and IQ3_XXS `18911 -> 18911`. Load counts and resource metadata were unchanged. Existing MMQ spill ranges also remained unchanged: VGPR spills up to 36, 7, and 37 respectively; SGPR spills were zero. These are existing template records, not new spills from E.

The focused assembly and resource comparison are in [`isa/isa-focused.txt`](isa/isa-focused.txt), [`isa/isa-summary.txt`](isa/isa-summary.txt), and [`isa/object-notes/resource-delta.txt`](isa/object-notes/resource-delta.txt).

## Correctness

The GPU checker compared the original multiply, the HIP `amdgcn_perm` result, and a separate byte-wise parity-and-shift reference for every `uint8_t` input: **256 checked, 0 mismatches**. See [`unpack-ksigns-check.hip`](unpack-ksigns-check.hip) and [`unpack-ksigns-check.log`](unpack-ksigns-check.log).

The GGUF contains the affected formats in these tensor shapes (`K x N`):

| Type | Shapes present |
| --- | --- |
| IQ2_XXS | `5120x1024`, `5120x6144`, `5120x10240`, `5120x12288`, `5120x17408`, `6144x5120`, `17408x5120` |
| IQ2_XS | `5120x6144`, `5120x10240`, `5120x17408`, `6144x5120`, `17408x5120` |
| IQ3_XXS | `5120x1024`, `5120x6144`, `5120x10240`, `5120x12288`, `5120x17408`, `6144x5120`, `17408x5120` |

The targeted backend suite exercised `MUL_MAT` and `MUL_MAT_VEC_FUSION`, including the fused gate/up form (`K=5120`, `N=17408`). Both C and E passed **332/332 tests**. Logs and exact commands are under [`model-shape/`](model-shape/).

The previously known IQ3_XXS failures were replayed separately at seeds 17 and 25025. At each seed C and E had the same two failing operations and identical diagnostic input/value lines; the existing NMSE threshold (`0.005`) was not changed. Examples of GPU-versus-reference output from that replay:

| Seed / shape | C and E GPU output | Reference | Absolute error |
| --- | ---: | ---: | ---: |
| 17, fused `K=256` | `-0.184896230698` | `-0.125562310219` | `0.059333920479` |
| 25025, fused `K=5120` | `0.686857461929` | `0.760685682297` | `0.073828220367` |

The failures are shared with C, not evidence that all backend validation passes, and their underlying cause remains unresolved. See [`shared-iq3xxs-failures/comparison.txt`](shared-iq3xxs-failures/comparison.txt) and the per-variant logs there.

## Decode A/B

The benchmark used the established GGUF and flags:

```sh
llama-bench -m "$MODEL" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 \
  -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096
```

MTP was disabled (`llama-bench` default `load_mtp=false`; no draft/MTP option). Runtime JSON for all 40 rows confirms the same model, offload, cache, batch, thread, flash-attention, and decode settings; [`check-bench-json.py`](check-bench-json.py) records this check in [`benchmark-config-check.txt`](benchmark-config-check.txt). Ten adjacent pairs were run per depth with balanced order (five C-E and five E-C). Each invocation used the same load/warmup behavior. The exact commands, JSON, logs, and library-resolution records are preserved per run.

| Depth | C mean | E mean | Mean paired gain | Paired 95% CI |
| ---: | ---: | ---: | ---: | ---: |
| `d=0` | 34.8479 tok/s | 35.0968 tok/s | +0.723% | -0.100% to +1.545% |
| `d=4096` | 33.9034 tok/s | 34.2606 tok/s | +1.057% | +0.427% to +1.687% |

Each pair gain is `100 * (E/C - 1)` using `avg_ts`. The interval is a two-sided paired Student-t 95% CI over the ten pair gains (`df=9`, `t*=2.262157`). The `d=0` interval includes zero; `d=4096` is positive in this sample. Raw pair gains and summary are in [`paired-results.csv`](paired-results.csv) and [`paired-summary.txt`](paired-summary.txt). These are unprofiled `llama-bench` results, not profiler throughput.

## Telemetry and limits

The configured maximum graphics power was **190 W** in both `rocm-smi` snapshots before and after the run. No power limit or clock setting was changed. During 279 one-second samples, GPU utilization was at least 95% for 124/140 C samples and 124/139 E samples.

| Variant | Mean / max sampled power | Mean SCLK (range) | Junction range | Memory range |
| --- | ---: | ---: | ---: | ---: |
| C | 189.2 / 207 W | 2336 (2224-2454) MHz | 51-77 C | 62-84 C |
| E | 190.5 / 215 W | 2338 (2233-2482) MHz | 55-77 C | 67-84 C |

Some instantaneous power samples exceeded the configured 190 W cap in both variants. E's sampled mean SCLK was 2 MHz higher, so this run cannot attribute the small measured difference solely to the instruction substitution. The intervals also show the `d=0` result is noisy. Raw telemetry is in [`telemetry-samples.csv`](telemetry-samples.csv), [`telemetry-before.txt`](telemetry-before.txt), and [`telemetry-after.txt`](telemetry-after.txt).

## Final active state

C remains active. Final check: source SHA-256 `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83`; active library SHA-256 `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8`. With `LD_LIBRARY_PATH` unset, `build-hip-baseline/bin/llama-bench` resolves `libggml-hip.so.0` to `build-hip-baseline/bin/libggml-hip.so.0.27.0`. E remains isolated under `library/E` and `source/E`.

The final state check is [`final-active-control.txt`](final-active-control.txt); run sequence and raw artifacts are retained in this directory. No commit, push, or PR was made.
