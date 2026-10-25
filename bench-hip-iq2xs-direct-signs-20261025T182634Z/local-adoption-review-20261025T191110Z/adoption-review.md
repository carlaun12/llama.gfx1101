# F local adoption review

Target: RX 7800 XT / gfx1101. This review leaves E active and F isolated.

## Scope and exact diff

The complete E/F diff contains only these two HIP code paths:

| File | Function/path | Behavior changed | Evidence |
| --- | --- | --- | --- |
| `ggml/src/ggml-cuda/vecdotq.cuh` | `vec_dot_iq2_xs_q8_1`, MMVQ plain and fused | Replaces byte compare/subtract sign application for both grid halves with the direct uint32 construction | 131,072-case GPU equivalence checker; 49/49 IQ2_XS backend operations; model-shape and fused coverage |
| `ggml/src/ggml-cuda/mmq-load-tiles.cuh` | `ggml_cuda_mmq_load_tiles_iq2_xs`, MMQ tile load | Applies the same construction to both grid halves before writing MMQ tiles | The same exhaustive checker; `MUL_MAT` backend cases with batch sizes above the MMVQ limit; ISA comparison of 32 IQ2_XS device kernels |

No other quantization or runtime path changes. `unpack_ksigns`, including E's `amdgcn_perm` broadcast and eighth-sign parity reconstruction, is unchanged. Indices, codebook loads, activation loads, accumulation, scales, and launch configuration are unchanged. The non-HIP implementation remains the original E code.

The F construction is:

```c
m = (((signs & selector) + 0x7f7f7f7fu) >> 7) & 0x01010101u;
mask = (m << 8) - m;
grid_signed = (grid ^ mask) + m;
```

The proof is limited to the actual IQ2_XS table and valid sign encoding. The 512-entry table has only magnitude bytes `0x08`, `0x19`, and `0x2b`; none are zero. The stored seven sign bits and parity-derived eighth bit produce the tested sign domain. Exhaustive validation covered all entries, all 128 valid stored sign patterns, and both four-byte halves. The independent lane reference agreed exactly with E and F in all 131,072 cases. This does not establish safety for arbitrary packed bytes or sign masks.

## Build, ISA, and numeric coverage

E and F use the same Release flags, ROCm Clang 22, and gfx1101. Normalized HIP compile commands match. E/F source and library hashes are listed in `variant-manifest.txt` and `local-adoption-review-20261025T191110Z/variant-hashes.txt`.

| Path | Static instructions E -> F | VGPR E -> F | SGPR E -> F | Spill change |
| --- | ---: | ---: | ---: | --- |
| MMVQ plain | 342 -> 300 | 43 -> 43 | 22 -> 22 | none |
| MMVQ fused | 843 -> 767 | 58 -> 56 | 46 -> 46 | none |
| IQ2_XS MMQ device kernels, total | 18,128 -> 16,311 | Three kernels use fewer; others recorded in `isa/resource-summary.txt` | See resource records | No new spills; existing maximum remains 7 VGPR spills and 32-byte private segment |

Correctness checks on F:

- GPU packed-value checker: 131,072/131,072 exact matches, zero mismatches.
- `test-backend-ops -b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p iq2_xs`: 49/49 passed.
- GGUF model-shape harness: 55/55 passed. IQ2_XS shapes include K=5120 with output widths 6144, 10240, and 17408, plus the recorded 6144x5120 and 17408x5120 operations. Batch-one and gate/up fused cases exercise MMVQ. `MUL_MAT` cases with RHS batch 9, 13, and 16 exceed gfx1101's MMVQ batch limit of 8 and cover MMQ dispatch.

These results cover both changed paths. The broader backend suite has two known IQ3_XXS failures shared by original A, B, and C in the earlier cumulative experiment: seed 17, fused SWIGLU K=256, error 0.102979308; seed 25025, fused SWIGLU K=5120, error 0.011553447. They are not IQ2_XS cases and do not differ among those variants. Keep them recorded as a separate unresolved validation limitation; do not treat this IQ2_XS validation as resolving them.

## Model-level measurements

Decode data is from the completed third session, not the two interrupted initialization attempts. Each scenario has 10 adjacent pairs, five E-F and five F-E. Each process had its normal warmup and one measured `tg128` run. Paired gain is `100 * (F avg_ts / E avg_ts - 1)`. Intervals use a two-sided paired Student-t interval over the 10 pair gains, df=9, t*=2.262157.

| Scenario | E mean | F mean | Mean paired gain | Paired 95% CI |
| --- | ---: | ---: | ---: | ---: |
| tg128 d=0 | 35.6081 tok/s | 35.8866 tok/s | +0.782% | +0.640% to +0.924% |
| tg128 d=4096 | 34.8813 tok/s | 35.1859 tok/s | +0.873% | +0.690% to +1.056% |
| Equal-weight decode aggregate | - | - | +0.827% | +0.691% to +0.964% |

The two depths are evidence within one session, not independent session replication. Full raw runs, commands, paired results, and telemetry are in `ab-session3-20261025T185358Z/`.

The requested prompt-processing check used 10 adjacent pairs in one session, five EF and five FE, with one prompt warmup and one measured run per process. MTP was disabled by the `llama-bench` default. Command: `llama-bench -m /home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 512 -n 0 -d 0`.

| Scenario | E mean | F mean | Mean paired gain | Paired 95% CI |
| --- | ---: | ---: | ---: | ---: |
| pp512 | 653.4072 tok/s | 655.9041 tok/s | +0.393% | -0.360% to +1.145% |

The pp512 interval crosses zero, so this sample demonstrates neither a prefill gain nor a prefill regression. Pair 9 had a +3.267% result because its E sample was 632.702 tok/s; it remains included in the reported estimate, and its cause is unknown. There is also a dispatch limitation: IQ2_XS MMVQ accepts at most 8 columns. On this RDNA3 GPU, IQ2_XS MMQ is selected only through batch 128; at batch 512, quantized weights bypass MMVQ and MMQ and use the BLAS route. Therefore this full-batch pp512 result does not execute either changed IQ2_XS code path. It is a model-level regression check, not a direct prefill test of F's code.

## Telemetry and limitations

The pp512 session recorded 72 one-second telemetry samples, 38 tagged E and 33 tagged F; one sample was setup or untagged. Samples marked busy at >=95% GPU use averaged:

| Metric | E | F |
| --- | ---: | ---: |
| Busy samples | 16 | 13 |
| Power | 179.3 W | 192.1 W |
| SCLK | 2352.6 MHz | 2343.6 MHz |
| Edge temperature | 39.7 C | 39.8 C |
| Junction temperature | 55.1 C | 54.8 C |
| Memory temperature | 61.4 C | 61.5 C |

The configured power cap was 190 W before and after, and the scripts did not change power or clocks. Eighteen telemetry samples exceeded 190 W; the maximum was 220 W. The cause of these readings is undetermined. Do not attribute them solely to telemetry resolution. The GPU-idle log shows that the script waited through a brief 9% utilization sample before resuming; it did not stop user applications, and no competing KFD process was reported.

## Adoption recommendation and reversible procedure

Decode shows a modest positive paired result at both depths, with both intervals above zero. The pp512 check showed no demonstrated regression, but its batch did not exercise the modified paths. A later batch-128 follow-up confirmed IQ2_XS MMQ dispatch. Full-model pp128 remained inconclusive, while an unprofiled five-shape MMQ A/B showed an equal-weight +1.562% paired gain (95% CI +1.013% to +2.110%). See `../mmq-pp128-ab-20261025T193500Z/mmq-prefill-report.md` for details and the synthetic-value limitation. Recommendation: F is suitable for controlled local adoption. This review does not activate F. E remains the active control pending the user's decision.

The activation and restoration scripts are prepared, reviewed, and syntax-checked, but have not been run:

- Activate F: `bash bench-hip-iq2xs-direct-signs-20261025T182634Z/local-adoption-review-20261025T191110Z/activate-f-local.sh`
- Restore E: `bash bench-hip-iq2xs-direct-signs-20261025T182634Z/local-adoption-review-20261025T191110Z/restore-e-local.sh`

Both scripts check the active source and library hashes, the preserved E snapshots, the isolated F artifacts, and the `llama-bench` hash before replacing any file. They refuse to run while `llama-bench` is active. Each stages and verifies files before moving them, verifies the resulting hashes and default loader path, and rolls back only files still matching the expected target hashes. Any source, library, or executable hash outside the manifest makes the script stop without replacing that file. E snapshots are independent copies under `snapshots/E/`.

Expected identities:

| Artifact | E | F |
| --- | --- | --- |
| `vecdotq.cuh` | `9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c` | `defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c` |
| `mmq-load-tiles.cuh` | `829528f15e95ff0d665efa1e36f3458730c3b36800231b16cb7c245fc9b0b3c5` | `18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f` |
| HIP library | `ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24` | `3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce` |
| `llama-bench` | `39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25` | same executable |

Final state check for this review: E source and HIP library hashes match the values above; default `ldd` resolution for `build-hip-baseline/bin/llama-bench` points to `build-hip-baseline/bin/libggml-hip.so.0`. F remains isolated in `source/F` and `build/F`. The active-state capture is `final-active-state.txt`.

## Review disposition

No correctness mismatch or new resource spill was found in the documented IQ2_XS scope. The remaining limitations are the shared IQ3_XXS failures, the lack of independent decode-session replication, the inconclusive pp512 interval, and the pp512 dispatch path bypassing F's changed kernels. Keep E active until the human owner chooses whether to try F locally.
