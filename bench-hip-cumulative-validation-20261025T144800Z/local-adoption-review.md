# C local adoption review

Target: RX 7800 XT / gfx1101, ROCm, model `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`.

## Scope and final diff

A is the original source at commit `bb41340de1868650bffc3ad09d62fb18f2748754`; B is the active control at the start of the cumulative run; C is B plus the validated IQ2_XXS candidate. The complete A-to-C review diff is `final-A-to-C.diff`. A/C differ in one source file, `ggml/src/ggml-cuda/vecdotq.cuh`, and only the four documented sign-handling paths below. No MTP, other quantization formats, or runtime flags changed.

| Path | Change and valid input domain | GPU evidence |
| --- | --- | --- |
| IQ2_S (A->B) | Expand the two sign nibbles directly into per-byte sign bits, then use XOR plus add. The `iq2s_grid` magnitude bytes are `{8,25,43}`; none is zero. | 524,288 cases (1,024 table entries x 256 sign bytes x two halves), exact expanded masks and packed operands. |
| IQ3_XXS (A->B) | Keep parity-corrected sign extraction and `__vcmpne4`; replace `__vsub4` with XOR plus the per-byte low-bit add. The `iq3xxs_grid` magnitudes are `{4,12,20,28,36,44,52,62}`; none is zero. | 65,536 cases across all table indices, valid sign encodings, both halves, exact packed equality and no zero lanes. |
| IQ3_S (A->B) | Expand low/high sign nibbles directly and use XOR plus add. `iq3s_grid` magnitude bytes are `{1,3,5,7,9,11,13,15}`. | 16,384 cases (512 table entries x 16 sign combinations x two halves), exact packed equality and no zero lanes. |
| IQ2_XXS (B->C) | Keep `unpack_ksigns` and `__vcmpne4`; replace only the two `__vsub4` operations. `iq2xxs_grid` magnitudes are `{8,25,43}`; none is zero. | 65,536 three-way GPU cases (control, candidate, independent byte reference), exact match and no carry. |

For the packed-add paths, `signs` must be the documented per-byte `0x00/0xff` mask and each magnitude must be nonzero. A negative lane computes `(~g)+1`; if `g=0`, that could carry into the adjacent byte. The proof and tests cover only each table's valid indices and sign encodings, not arbitrary byte values. Total exhaustive arithmetic coverage is 671,744 cases.

Review checks: one backend source file, no new op/type/API, no new allocations or untrusted indexing, no debug logging, and no tolerance changes. The code is limited here to the recorded ROCm Clang 22 / gfx1101 build. The existing B-to-C compile settings match, and A/B/C libraries are isolated.

## IQ3_XXS backend-test failures

The two failures were reproduced with the same deterministic seeds in A/B/C. The diagnostic harness saved the exact tensor bytes; SHA-256 inputs are in `diagnostic-repro/input-sha256-summary.md`. The fused and unfused runs have identical IQ3_XXS weight and activation hashes per seed, and all A/B/C hashes match. GPU outputs also match exactly across A/B/C.

| Seed / K | Graph result | ROCm0 | CPU reference | Abs. error | Rel. error vs CPU | NMSE | Existing threshold |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 17 / 256 | Plain `MUL_MAT` | 1.56525158882 | 1.6245855093 | 0.05933392048 | 3.6523% | 0.00143693724 | 0.005 |
| 17 / 256 | Fused final `ADD` | -0.184896230698 | -0.125562310219 | 0.05933392048 | 47.2546% | 0.10297930810 | 0.005 |
| 25025 / 5120 | Plain `MUL_MAT` | 1.710729599 | 1.78455781937 | 0.07382822037 | 4.1371% | 0.00186243914 | 0.005 |
| 25025 / 5120 | Fused final `ADD` | 0.686857461929 | 0.760685682297 | 0.07382822037 | 9.7055% | 0.01155344688 | 0.005 |

The test computes `NMSE = sum((GPU-CPU)^2) / sum(GPU^2)`. In each scalar case, the two bias additions leave the same absolute difference as the underlying matmul, but nearly cancel the result. The plain matmul's NMSE is below the unchanged 0.005 threshold; the fused output's NMSE exceeds it after normalization by the much smaller final output. This attributes the test failure to the normalization/tolerance at a cancellation-sensitive scalar output. It does not identify a C-specific arithmetic divergence or establish that the CPU reference is wrong. The reported fused test still fails with its existing criterion; that remains a test limitation, not a passing test. Any change to this metric or case is independent work and is not mixed into C.

The temporary fused diagnostic also requested internal tensors that the HIP fusion does not materialize. Those stale intermediate reads are excluded from the table above; only its final fused output is used. The plain `MUL_MAT` reruns provide the actual standalone matmul values.

## Model-shape coverage

`model-tensor-coverage.md` lists counts and K/N pairs directly from the GGUF metadata (model SHA is recorded there). The completed private shape harness covers all 27 distinct `(type, K, N)` pairs for IQ2_S, IQ3_S, IQ3_XXS, and IQ2_XXS in plain `MUL_MAT`, plus the actual FFN gate/up decode form `K=5120, N=17408` for all four types in `MUL_MAT_VEC_FUSION`. A/B/C each passed 392/392 cases with the same seed. Commands, loader checks, harness, and full logs are under `model-shape-coverage-complete/`; the earlier narrower IQ2_XXS-only run remains archived under `model-shape-coverage/`. Exhaustive GPU checks validate the arithmetic domain for all four paths. The shape harness uses one activation row and does not independently execute every tensor in the full model graph; target-GGUF decode and prefill were exercised in the prior paired benchmarks.

## Performance evidence and recommendation

No A/B was repeated. The prior same-session paired results show B vs A at +7.616% (95% CI +7.081 to +8.150) for `tg128 d=0` and +8.172% (+7.408 to +8.936) for `d=4096`; equal-weight decode +7.894% (+7.604 to +8.184). C vs B adds +0.797% (+0.392 to +1.203) at d=0 and +0.703% (+0.079 to +1.327) at d=4096; equal-weight +0.750% (+0.466 to +1.034). `pp512` was -0.044% with CI -0.668 to +0.581, so no prefill difference was demonstrated. These are paired results from the earlier validation report, not new measurements.

The gain is calculated per pair as `(candidate_tps / control_tps - 1) * 100`; the 95% interval is a two-sided paired Student-t interval over 10 pair gains (`df=9`). Equal-weight decode averages the two depth gains within each pair before computing the interval. Prefill stays separate: A/B was -0.088% (95% CI -0.476 to +0.300), and B/C was -0.044% (95% CI -0.668 to +0.581). Both intervals include zero.

I recommend C for controlled local use after human review. Decode improvement was positive in both tested depths and passed exhaustive IQ2_XXS arithmetic plus the targeted model-shape suite. Prefill remains statistically unresolved. Keep the shared IQ3_XXS scalar-NMSE failure recorded as an open validation limitation; it occurs identically in A/B/C and its cause is the test's cancellation-sensitive normalization. The previous telemetry sometimes exceeded the configured 190 W cap, and the roughly 8% cross-session shift remains unexplained, so rely on within-session paired gains only.

## Reversible activation

C is not activated. The switch target is the working source `ggml/src/ggml-cuda/vecdotq.cuh` and the default runtime library `build-hip-baseline/bin/libggml-hip.so.0.27.0`; `build-hip-baseline/bin/llama-bench` resolves that library through `libggml-hip.so.0`. The control snapshots are `activation-snapshots/control-vecdotq.cuh` and `activation-snapshots/control-libggml-hip.so.0.27.0`.

The complete identities are:

All paths in this table are relative to `bench-hip-cumulative-validation-20261025T144800Z/`.

| State | Source path | Source SHA-256 | HIP library path | HIP library SHA-256 |
| --- | --- | --- | --- | --- |
| B control snapshot | `activation-snapshots/control-vecdotq.cuh` | `a22eebfb491090e3cb5c5d297caacd3bff0055f12fe0318db897d7873f6efceb` | `activation-snapshots/control-libggml-hip.so.0.27.0` | `676433a44e3e947b0d37d050109328aa4b8d20f77a515276e50135b92d8e658b` |
| C candidate | `source/C/ggml/src/ggml-cuda/vecdotq.cuh` | `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83` | `library/C/libggml-hip.so.0.27.0` | `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8` |

To switch locally after review, run from the repository root:

```sh
bench-hip-cumulative-validation-20261025T144800Z/activate-c-local.sh
```

To restore the current B control:

```sh
bench-hip-cumulative-validation-20261025T144800Z/restore-control-local.sh
```

Both scripts check full source/library SHA-256 values, refuse unexpected states, verify `llama-bench` loader resolution, and use preserved control snapshots. They were syntax-checked only; neither was executed. C remains isolated in `source/C`, `build/C`, and `library/C`.

At review time, B remains active at `ggml/src/ggml-cuda/vecdotq.cuh` and `build-hip-baseline/bin/libggml-hip.so.0.27.0`; the active `llama-bench` SHA-256 is `39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25` and `ldd` resolves `libggml-hip.so.0` to that library. C remains isolated at the paths in the table.
