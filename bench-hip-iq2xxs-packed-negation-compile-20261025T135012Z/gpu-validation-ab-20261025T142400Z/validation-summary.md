# IQ2_XXS packed-negation validation

## Scope and build isolation

- GPU: AMD Radeon RX 7800 XT, gfx1101.
- Model: `/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`.
- The active source file still matches the archived control source. The candidate source differs only in the two `grid0` and `grid1` expressions in `vec_dot_iq2_xxs_q8_1`.
- Control and candidate HIP libraries are separate files. The candidate was built in `source-candidate/` and `build-candidate/`; the active `build-hip-baseline` was not rebuilt or overwritten.
- CMake settings match for Release, ROCm clang 22, gfx1101, HIP, graphs, MFMA, no-VMM, and native CPU. The normalized compile commands for `mmvq.cu` and `mmq-instance-iq2_xxs.cu` match.
- The same `llama-bench` and `test-backend-ops` executables were used for both variants. Loader logs confirm that `LD_LIBRARY_PATH` selected the isolated control or candidate HIP library for each run.

## Arithmetic and GPU validation

The packed addition is valid only for sign-mask bytes produced by `__vcmpne4` (each byte is `0x00` or `0xff`) and nonzero magnitude bytes in the `iq2xxs_grid` table. For a negative lane, the operation computes `(~g) + 1`. The table has three magnitude values, all nonzero, so this sum stays within the byte and cannot carry into an adjacent lane. This argument does not cover arbitrary `grid` or `signs` values outside this domain.

The GPU check covered 256 table entries x 128 valid seven-bit sign encodings x two grid halves = 65,536 cases. It compared the `__vsub4` control, the packed-add candidate, and a per-byte reference that independently reconstructs each signed magnitude. All masks and packed operands matched exactly. The table contained three nonzero magnitudes in `[8, 43]`; no lane produced a carry.

ROCm backend tests used `-b ROCm0 -o MUL_MAT,MUL_MAT_VEC_FUSION -p iq2_xxs` on both libraries:

- Control: 186/186 supported cases passed, with 81 `MUL_MAT` cases and 105 `MUL_MAT_VEC_FUSION` cases. 33 additional `MUL_MAT` shapes were reported unsupported and skipped.
- Candidate: the same 186/186 cases passed, with the same 33 unsupported shapes.

## A/B results

The run used `llama-bench` with `-dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -r 1 -p 0 -n 128 -d 0,4096`. Internal warmup was enabled for every invocation and case. There were 10 adjacent pairs per depth, with five `AB` and five `BA` pair orders. No other benchmark or profiler ran concurrently.

For each pair, gain is `(B/A - 1) * 100`, using the reported `avg_ts`. The aggregate and 95% CI are the mean paired percentage and Student-t interval `mean +/- t(0.975, 9) * sample_sd / sqrt(10)`, with `t*=2.262157`. The combined estimate averages both depth gains within each pair first, then computes the interval over 10 pair-level averages.

| Scenario | Control A mean | Candidate B mean | Mean paired gain | 95% CI |
| --- | ---: | ---: | ---: | ---: |
| tg128, d=0 | 34.98567 tok/s | 35.22541 tok/s | +0.687% | +0.321% to +1.053% |
| tg128, d=4096 | 34.31173 tok/s | 34.47115 tok/s | +0.465% | +0.135% to +0.795% |
| Equal-weight d=0/d=4096 | - | - | +0.576% | +0.305% to +0.847% |

All 20 JSON outputs validated and all 20 runs completed without logged errors. The per-pair values are in `paired-results.csv` and `paired-summary.txt`.

## Telemetry and limits

`rocm-smi` reported a 190 W max graphics package power before and after the run; no power limit or clock setting was changed. One-second telemetry contained 277 samples, of which 250 showed at least 95% GPU use. Busy-sample ranges were:

- GPU use: 98-100%.
- Reported package power: 87-210 W; 102/250 busy samples were above 190 W.
- SCLK: 2,210-2,482 MHz; MCLK: 1,218 MHz; FCLK: 1,950-2,301 MHz.
- Edge temperature: 38-61 C; junction: 52-82 C; memory: 62-87 C.
- Mean busy power and SCLK were similar between A (188.59 W, 2,328.0 MHz) and B (189.55 W, 2,328.9 MHz).

The configured cap was unchanged, but the reported power readings exceeded it in many busy samples. Therefore this run does not establish that the GPU stayed strictly at or below 190 W. The paired order was balanced, and A/B mean clocks were close, but the measured gain should be interpreted under the observed telemetry rather than as a guaranteed result at a strict 190 W draw.

There was also a large cross-session shift in the control mean. The previous IQ3_XXS A/B recorded control A at 32.56938 tok/s for d=0 and 31.79945 tok/s for d=4096. This run measured 34.98567 and 34.31173 tok/s, respectively, about 7.4% and 7.9% higher. The previous run records the same control-library hash, benchmark executable hash, model hash, flags, and control source hash. The cause of the session-level shift was not identified. The paired gains below are within-session comparisons; do not compare the absolute means across sessions as a performance trend.

## Recommendation and active state

Recommendation: promote this candidate to the next cumulative-validation stage, while keeping the active control unchanged. Both depth-specific paired 95% intervals are above zero, and exact GPU operand validation plus plain/fused backend coverage passed. The measured end-to-end gain is small, under 1%, and the power telemetry and unexplained cross-session shift limit how broadly to generalize it.

The candidate was not activated. The active source still has SHA-256 `a22eebfb491090e3cb5c5d297caacd3bff0055f12fe0318db897d7873f6efceb`, and the active HIP library still has SHA-256 `676433a44e3e947b0d37d050109328aa4b8d20f77a515276e50135b92d8e658b`. Default `ldd` resolution for the active `llama-bench` points to `build-hip-baseline/bin/libggml-hip.so.0`. No commit, push, or PR was created.

## Artifacts

- `gpu-iq2xxs-packed-equivalence.hip`, `gpu-equivalence-compile-command.txt`, `gpu-equivalence.log`: GPU exhaustive arithmetic check.
- `control-backend-tests.log`, `candidate-backend-tests.log`, and matching loader/command logs: backend validation.
- `run-ab.sh`, `sequence.log`, `benchmark-command.txt`, `NN-A/B.json`, `NN-A/B.log`, and `NN-A/B.command.txt`: A/B driver and raw results.
- `paired-results.csv`, `paired-summary.txt`: per-pair throughput and confidence intervals.
- `telemetry.log`, `telemetry-summary.txt`, `power-before.txt`, `power-after.txt`: raw and summarized hardware telemetry.
- `build-candidate.sh`, `build-comparison.txt`, `source-and-library-hashes.txt`, and `final-state.txt`: isolated build, compiler-option comparison, hashes, and active-control check.
- `build-candidate/`, `candidate-library/`, `control-library/`, and `source-candidate/`: isolated candidate build and libraries plus the unchanged control copy.
