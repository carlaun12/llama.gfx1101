# IQ2_XS direct sign experiment

Target: RX 7800 XT / gfx1101. Control E remains active in the fork. Candidate F is isolated in this experiment directory.

## Variant identity and scope

| Variant | `vecdotq.cuh` SHA-256 | `mmq-load-tiles.cuh` SHA-256 | HIP library SHA-256 |
| --- | --- | --- | --- |
| E control | `9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c` | `829528f15e95ff0d665efa1e36f3458730c3b36800231b16cb7c245fc9b0b3c5` | `ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24` |
| F candidate | `defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c` | `18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f` | `3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce` |

The source-tree comparison contains exactly the IQ2_XS branches in `vec_dot_iq2_xs_q8_1` (MMVQ) and `ggml_cuda_mmq_load_tiles_iq2_xs` (MMQ). The HIP branch uses the direct uint32 formula; the original E implementation remains under the non-HIP branch. `unpack_ksigns`, including E's `__builtin_amdgcn_perm` broadcast and parity reconstruction, is byte-identical. Accumulation, scales, indices, loads, and all other formats are unchanged. See `candidate.diff` and `source-tree-diff.txt`.

## Arithmetic domain and proof

The block index is 9 bits and selects one of 512 table entries. The stored sign field is 7 bits; E's helper reconstructs the eighth sign from parity. The GPU checker enumerated all 128 valid stored sign patterns, not arbitrary 8-bit values.

All 4,096 bytes of `iq2xs_grid` were enumerated. Their distinct values are `{0x08, 0x19, 0x2b}`; no byte is zero. This matters because negating a packed zero could carry into its neighboring byte.

For each selected lane, `signs & selector` is either 0 or one-hot in `[1,128]`. Adding `0x7f` gives 127 for an unselected lane and 128..255 for a selected lane, so the add has no byte carry. Shifting by 7 and masking with `0x01010101` yields per-byte `m_i` in `{0,1}`.

For `m_i` in `{0,1}`, `(m << 8) - m` produces `0xff` in lane `i` exactly when `m_i=1`; the subtraction borrow into lane `i` equals the preceding `m` bit, so each output lane is `-m_i mod 256`. The final signed-lane operation is `(g ^ 0xff) + 1 = 256-g`. Since `g` is 8, 25, or 43, the result is 248, 231, or 213 and stays in its byte. Unselected lanes remain unchanged. This proof is limited to the actual IQ2_XS table and valid sign encoding.

The full argument and checked cases are in `arithmetic-proof.md` and `gpu-equivalence.hip`.

## Build and ISA

E and F were compiled with the same Release CMake options, ROCm Clang 22, and `gfx1101`. The recorded E and F CMake HIP compile commands normalize identically for `mmvq.cu` and `mmq-instance-iq2_xs.cu`. The exact configure command is `configure-F.command.txt`.

The full all-target build stopped in unrelated `test-chat` and `test-server-component` translation units because this configuration lacks `mtmd.h`. The HIP library itself linked successfully, and the targeted `test-backend-ops` and `llama-bench` targets built successfully. Logs are `build-F.log` and `build-targets-F.log`.

| MMVQ path | E instructions | F instructions | DOT4 E/F | loads E/F | VGPR E/F | SGPR E/F | private/spills |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Plain | 342 | 300 | 8 / 8 | 22 / 22 | 43 / 43 | 22 / 22 | 0 / 0 in both |
| Fused | 843 | 767 | 16 / 16 | 35 / 35 | 58 / 56 | 46 / 46 | 0 / 0 in both |

F's sign dependency is `unpack_ksigns perm -> selector AND -> add 0x7f7f7f7f -> shift 7 -> AND 0x01010101 -> multiply by 255 for the byte mask -> XOR grid -> add m -> DOT4`. E keeps the same unpack helper and uses the `__vcmpne4` plus `__vsub4` sequence. The plain load instruction order changes, while the fused load order is unchanged.

For MMQ IQ2_XS, the 32 active device kernels have 18,128 E static instructions and 16,311 F instructions. The global-load count remains 665. Three kernels use fewer VGPRs; no resource record adds spills. Existing MMQ maximum VGPR spills remain 7 and private segment max remains 32 bytes in both variants. Full resource records and code objects are in `resource-summary.txt` and `isa/`.

## Correctness

The GPU checker compared E's byte-SIMD operation, the candidate uint32 transform, and an independent lane-by-lane reference for all 512 table entries x 128 valid sign encodings x both four-byte halves: **131,072 cases, exact equality, zero mismatches**. The parity reference independently loops over the seven stored bits.

With the F library verified by `LD_LIBRARY_PATH`:

- `test-backend-ops -b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p iq2_xs`: **49/49 passed**.
- The existing model-shape backend harness covered IQ2_XS GGUF shapes `5120x6144`, `5120x10240`, `5120x17408`, `6144x5120`, and `17408x5120`, including fused gate/up `K=5120, N=17408`: **55/55 passed**.

Commands and loader evidence are in `backend-F.command.txt`, `model-shapes-F.command.txt`, `loader-test-backend-ops-F.txt`, and `loader-model-shapes-F.txt`.

## Paired performance

Two initialization attempts produced no valid samples. The first remained before warmup for 5:40 while `ForzaHorizon4.exe` was active. After the user closed the game, the second remained in `filemap_read_folio` while reading the 9.8 GiB GGUF for 5:50 and wrote no JSON; it was stopped and preserved under `ab-session2-20261025T184643Z/`. Neither attempt is benchmark data.

A clean third session completed all 20 runs in [`ab-session3-20261025T185358Z/`](ab-session3-20261025T185358Z/). Its sequence has ten adjacent E/F pairs, with five E-F and five F-E orders. Each process performed its normal warmup before one measured run for `tg128` at depths 0 and 4096. Effective JSON settings were `ROCm0`, 99 GPU layers, flash attention on, `n_batch=2048`, `n_ubatch=512`, 8 CPU threads, F16 KV, and `n_gen=128`; commands and JSON are preserved per sample. MTP was disabled by the `llama-bench` default. The GPU was otherwise idle before the session, and `ForzaHorizon4.exe` was absent.

| Scenario | E mean | F mean | Mean paired gain | Paired 95% CI |
| --- | ---: | ---: | ---: | ---: |
| tg128 d=0 | 35.6081 tok/s | 35.8866 tok/s | +0.782% | +0.640% to +0.924% |
| tg128 d=4096 | 34.8813 tok/s | 35.1859 tok/s | +0.873% | +0.690% to +1.056% |
| Equal-weight decode aggregate | - | - | +0.827% | +0.691% to +0.964% |

For each adjacent pair and depth, gain is `100 * (F avg_ts / E avg_ts - 1)`. The interval is a two-sided paired Student-t interval over ten percentage gains (`df=9`, `t*=2.262157`). The aggregate averages the two depth gains inside each pair, then uses the same paired interval over ten pairs. Raw measurements and pair gains are in `paired-results.csv`; calculations are in `paired-summary.txt`. These are unprofiled model-level measurements.

Telemetry recorded 286 one-second samples: 144 tagged E, of which 122 had GPU use >=95%; 142 tagged F, of which 126 had GPU use >=95%. Busy-tagged means were E/F: power 189.3/188.8 W, SCLK 2342/2344 MHz, edge temperature 52.7/52.9 C, junction 68.6/68.9 C, and memory 76.8/77.2 C. The configured power cap was 190 W before and after, and no clock or power setting was changed. One-second samples reached 211 W, above the configured cap; the cause is undetermined. Run-boundary samples may be included in the stage-tagged telemetry. See `telemetry-summary.txt` and `telemetry.jsonl`.

## Prompt processing check

The requested pp512 check completed 10 adjacent E/F pairs in one session, five E-F and five F-E. Each run used the same model and settings as decode, with `-p 512 -n 0 -d 0`; MTP was disabled by the `llama-bench` default. E averaged 653.4072 tok/s and F 655.9041 tok/s. The mean paired gain was +0.393%, with a two-sided paired Student-t 95% CI of -0.360% to +1.145% over 10 pair gains (df=9, t*=2.262157). The interval crosses zero, so the result shows neither a prefill gain nor a regression. Pair 9 measured +3.267% because its E result was 632.702 tok/s; it is included in the estimate and its cause is unknown.

This pp512 measurement does not exercise either changed IQ2_XS path. The model uses batch 512 here: IQ2_XS MMVQ is limited to 8 columns, and RDNA3 IQ2_XS MMQ is limited to batch 128. At batch 512 dispatch uses the BLAS route. Treat this as a full-model prefill regression check, not a direct test of the changed MMVQ/MMQ code. Raw commands, outputs, pair calculations, and telemetry are in `pp512-ab-20261025T191110Z/`. The detailed coverage and review are in `local-adoption-review-20261025T191110Z/adoption-review.md`.

The pp512 telemetry recorded 72 one-second samples, 38 tagged E and 33 tagged F. Busy-tagged means were E/F: power 179.3/192.1 W, SCLK 2352.6/2343.6 MHz, edge temperature 39.7/39.8 C, junction 55.1/54.8 C, and memory 61.4/61.5 C. Eighteen samples exceeded the configured 190 W cap, with a maximum of 220 W. The cap was 190 W before and after, and no clock or power setting was changed. The cause of readings above the cap is undetermined; see `pp512-ab-20261025T191110Z/telemetry-summary.txt` and `telemetry.jsonl`.

## MMQ prefill follow-up

A dispatch trace with `-p 128 -b 128 -ub 128` confirmed 64 `mul_mat_q<(ggml_type)17, 128, ...>` IQ2_XS MMQ dispatches. An unprofiled, ten-pair pp128 model A/B measured +0.125% (95% CI -0.456% to +0.705%), which is inconclusive. The five-shape backend perf follow-up used actual IQ2_XS `(M,K)` dimensions from the GGUF at `n=128`; its equal-weight paired gain was +1.562% (95% CI +1.013% to +2.110%). Four individual shape intervals were above zero and one crossed zero. The harness uses synthetic quantized values and is separate from model throughput. Details, trace, raw samples, and telemetry are in `mmq-pp128-ab-20261025T193500Z/mmq-prefill-report.md`.

## Active state and recommendation

The ordinary loader still resolves `build-hip-baseline/bin/llama-bench` to E's library with the expected hash. F remains under `source/F` and `build/F`; the A/B used isolated `LD_LIBRARY_PATH` values and made no source or library change to the active build. Final source and library hashes plus loader resolution are recorded in `ab-session3-20261025T185358Z/final-state.txt`.

**Recommendation: F has enough evidence for controlled local adoption, but E remains active as requested.** F has exact GPU equivalence, both changed paths have numeric/backend coverage, no new spills were found, and the paired decode gain was positive with 95% intervals above zero at both depths. The separate MMQ shape A/B is +1.562% in the equal-weight aggregate with a 95% interval above zero. Full-model pp128 is inconclusive (+0.125%, CI -0.456% to +0.705%); it shows neither a prefill gain nor a regression. The shape test uses synthetic values and is not a full-model prefill speedup claim. No activation, automatic promotion, commit, push, or PR was made.

Reversible activation and restoration scripts, with hash guards for E/F sources, HIP libraries, and the bench executable, are prepared but not run in `local-adoption-review-20261025T191110Z/`.

## Artifact index

- `candidate.diff`, `vecdotq.diff`, `mmq-load-tiles.diff`: source delta.
- `arithmetic-proof.md`, `gpu-equivalence.hip`, `gpu-equivalence.command.txt`, `gpu-equivalence.log`: arithmetic proof and exact GPU validation.
- `isa/`, `isa-summary.txt`, `resource-summary.txt`: assembly, normalized commands, code objects, and resource metadata.
- `backend-F.log`, `model-shapes-F.log`: backend test results.
- `build-F.log`, `build-targets-F.log`, `configure-F.command.txt`: build records.
- `run-ab.sh`, `ab-interrupted-initialization/`, `ab-session2-20261025T184643Z/`: paired procedure and preserved interrupted attempts.
- `ab-session3-20261025T185358Z/`: completed A/B, per-run commands/logs/JSON, raw telemetry, paired analysis, and final active-state hashes.
- `pp512-ab-20261025T191110Z/`: completed 10-pair pp512 check, raw outputs, commands, telemetry, and paired analysis.
- `mmq-pp128-ab-20261025T193500Z/`: verified MMQ dispatch, ten-pair model pp128 check, five-shape IQ2_XS MMQ A/B, raw outputs, and telemetry.
- `mmq-pp128-ab-20261025T193500Z/final-active-state.txt`: final check that E remains active and F isolated.
- `local-adoption-review-20261025T191110Z/`: final E/F diff review, path coverage, adoption recommendation, active-state capture, hash-guarded reversible scripts, and `review-artifact-hashes.txt`.
