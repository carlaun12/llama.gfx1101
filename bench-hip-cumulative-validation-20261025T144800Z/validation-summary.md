# Cumulative HIP optimization validation

Target: AMD Radeon RX 7800 XT / gfx1101. Model SHA-256: `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`.

## Variants and validation

- **A** is the original commit `bb41340de1868650bffc3ad09d62fb18f2748754`, reconstructed from a detached worktree. The initial baseline snapshot has an empty source diff.
- **B** is the control source that was active at the start: IQ3_S direct signs, IQ2_S direct signs, and IQ3_XXS packed negation.
- **C** is B plus only the validated IQ2_XXS packed-negation simplification.

A/B/C have isolated source worktrees, builds, and HIP libraries. Their Release/ROCm Clang 22/gfx1101 settings and normalized compile commands match. Both executables loaded the matching HIP library for every test and benchmark. The active control source/library were left untouched; C remains isolated.

Four GPU arithmetic checkers passed across 671,744 codebook/sign/half combinations in total: IQ2_S, IQ3_S, IQ3_XXS packed negation, and IQ2_XXS packed negation. The backend suite exercised `MUL_MAT` and `MUL_MAT_VEC_FUSION` for those four types, 361 cases per variant and seed. On matched seeds 17 and 25025, A/B/C each produced the same single IQ3_XXS fused-operation/reference failure; on seed 4321, all three passed 361/361. Since the failing case and error were identical on original A and optimized B/C, no change-specific divergence was found. See `correctness-summary.md` for the exact cases and limitation.

## Paired performance

There were 10 adjacent pairs per comparison and workload, five in each order. A/B and B/C were interleaved during one session. Every tg128 invocation measured both d=0 and d=4096. Prefill used a separate pp512 workload. `llama-bench` warmup remained enabled for each case. All 80 JSON outputs parsed successfully and no benchmark process failed.

| Comparison | Workload | Control mean | Candidate mean | Paired gain | 95% CI |
| --- | --- | ---: | ---: | ---: | ---: |
| A/B | tg128, d=0 | 32.33337 tok/s | 34.79532 tok/s | +7.616% | [+7.081%, +8.150%] |
| A/B | tg128, d=4096 | 31.55651 tok/s | 34.13248 tok/s | +8.172% | [+7.408%, +8.936%] |
| A/B | tg128, equal-weight d=0/d=4096 | - | - | +7.894% | [+7.604%, +8.184%] |
| A/B | pp512 | 648.14009 tok/s | 647.55892 tok/s | -0.088% | [-0.476%, +0.300%] |
| B/C | tg128, d=0 | 34.78216 tok/s | 35.05884 tok/s | +0.797% | [+0.392%, +1.203%] |
| B/C | tg128, d=4096 | 34.05995 tok/s | 34.29797 tok/s | +0.703% | [+0.079%, +1.327%] |
| B/C | tg128, equal-weight d=0/d=4096 | - | - | +0.750% | [+0.466%, +1.034%] |
| B/C | pp512 | 647.85043 tok/s | 647.54177 tok/s | -0.044% | [-0.668%, +0.581%] |

Per-pair gain is `(candidate_tps / control_tps - 1) * 100`. The 95% intervals use a two-sided paired Student-t interval on 10 pair-level gains (`df=9`, `t*=2.262157`). The equal-weight decode interval averages d=0 and d=4096 gains within each pair before computing the interval. These are per-scenario intervals; prompt and generation results are not combined.

## Telemetry and session shift

The cumulative session had 560 samples at >=95% GPU utilization. Mean busy-sample package power was 190.1 W, mean SCLK was 2316.2 MHz, and junction temperature ranged from 54 to 81 C. The reported cap remained 190 W, but 266/560 busy samples reported more than 190 W, with a maximum of 224 W. No power limit or clock setting was changed.

Earlier sessions show a 7.4-7.9% absolute throughput shift for the same active control library, executable, model, and command settings. Recorded SCLK differed by about 1.6% and average power was nearly identical; the available telemetry does not explain the full gap. Its cause remains unknown. All conclusions here use paired measurements from this one session.

## Recommendation and final state

The accumulated B package shows a clear tg128 improvement over original A. IQ2_XXS C adds a smaller but positive paired decode gain, while both pp512 confidence intervals include zero and show no demonstrated prefill regression. I recommend advancing C for human review as an incremental decode optimization, while treating the shared IQ3_XXS backend-test failure as a validation limitation to understand before any external merge. C was not promoted or activated automatically.

The active source hash at finish is `a22eebfb491090e3cb5c5d297caacd3bff0055f12fe0318db897d7873f6efceb`; the active HIP library remains `676433a44e3e947b0d37d050109328aa4b8d20f77a515276e50135b92d8e658b`; default `llama-bench` loading still resolves to `build-hip-baseline/bin/libggml-hip.so.0`. C's source, build, and library remain isolated. No commit, push, or PR was made.

## Artifacts

- `variant-manifest.md`: reconstructed source map, build configuration, hashes, and loader evidence.
- `correctness-summary.md`: GPU arithmetic coverage and matched-seed backend tests.
- `paired-summary.md`, `paired-results.csv`: per-workload means, per-pair gains, and confidence intervals.
- `telemetry-summary.md`, `telemetry.log`: current and historical telemetry.
- `session-variance-investigation.md`: evidence and unresolved explanation for the previous session shift.
- `raw/`: all benchmark commands, JSON results, and stderr logs.
- `prepare-builds.sh`, `verify-variants.py`, `run-correctness.sh`, `run-deterministic-backend-tests.sh`, `run-benchmarks.sh`, `analyze-benchmarks.py`, `summarize-telemetry.py`: repeatable experiment scripts.
