# IQ2_XS MMQ prefill follow-up

Target: RX 7800 XT / gfx1101. E remained active; F remained isolated.

## Identity and dispatch confirmation

E and F hashes were checked before tracing and again after all measurements. The default loader for `build-hip-baseline/bin/llama-bench` continued to resolve to E. Full values are in `identity-and-dispatch.txt` and `shape-perf/ab/hashes.txt`.

The dispatch code gives a concrete pp128 boundary for this GPU:

- `GGML_TYPE_IQ2_XS` is enum value 17.
- MMVQ handles at most 8 columns.
- MMF rejects quantized source weights.
- The RDNA3 IQ2_XS MMQ rule accepts `ne11 <= 128`.

With `-p 128 -b 128 -ub 128`, the F `rocprofv3` trace contained **64** `mul_mat_q<(ggml_type)17, 128, ...>` dispatches. The profiler stats report 37,581,801 ns summed kernel duration for those dispatches. The trace includes setup, warmup, and the measured prompt operation; these profiler timings confirm the route only and are not normal performance results. Raw command and trace CSV are in `trace/`.

## Model-level pp128

The model benchmark used the usual GGUF and runtime settings, changing only prompt/batch values to 128:

```text
llama-bench -m /home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 128 -ub 128 -t 8 -r 1 -o json --progress -p 128 -n 0 -d 0
```

MTP was disabled by the `llama-bench` default. Ten adjacent pairs were run in one session, with five E-F and five F-E orders. Each `llama-bench` process did its normal prompt warmup before its measured run. The idle guard required no KFD PIDs and <=5% reported GPU use before every sample; it waited at several brief 6-8% readings. User applications were not stopped.

| Scenario | E mean | F mean | Mean paired gain | Paired 95% CI |
| --- | ---: | ---: | ---: | ---: |
| pp128 | 478.6901 tok/s | 479.2761 tok/s | +0.125% | -0.456% to +0.705% |

Gain is `100 * (F avg_ts / E avg_ts - 1)`. The interval is a two-sided paired Student-t interval over 10 pair gains, df=9, t*=2.262157. The model-level result is inconclusive and shows no demonstrated regression or gain.

## Isolated IQ2_XS MMQ shapes

Since the model-level effect is diluted, the existing backend performance harness was adapted in an isolated test source to add the five actual IQ2_XS `(M,K)` shapes recorded from the GGUF. Every operation used `n=128`, which the trace and dispatch rules confirm selects MMQ. The harness generates deterministic quantized weights and activations; these are shape-matched measurements, not timings on the GGUF's actual weight values. It ran without `rocprofv3` and measured each backend operation for at least one second after its warmup.

The A/B contained ten adjacent pairs for each shape, five E-F and five F-E. Positive gain means lower F latency, computed per pair as `100 * (E us/run / F us/run - 1)`. Confidence intervals use the paired Student-t method over 10 gains, df=9, t*=2.262157.

| Output M | Input K | E mean us/run | F mean us/run | Gain | Paired 95% CI |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 5120 | 6144 | 308.29 | 302.82 | +1.839% | +0.027% to +3.651% |
| 5120 | 17408 | 855.31 | 844.53 | +1.287% | +0.542% to +2.031% |
| 6144 | 5120 | 339.91 | 334.94 | +1.522% | -0.343% to +3.386% |
| 10240 | 5120 | 483.38 | 475.83 | +1.593% | +0.792% to +2.394% |
| 17408 | 5120 | 790.05 | 777.89 | +1.567% | +0.909% to +2.226% |
| Equal-weight five-shape aggregate | - | - | - | +1.562% | +1.013% to +2.110% |

The aggregate averages the five shape gains inside each pair, then forms the paired interval over 10 pairs. Four individual shapes have intervals above zero; the 6144x5120 output/input shape is individually inconclusive. Raw per-pair latencies are in `shape-perf/ab/paired-shape-results.csv`; each command and complete output is retained under `shape-perf/ab/raw/`.

## Telemetry and run conditions

For the model pp128 session, the recorded maximum was 183 W, with no one-second sample over the configured 190 W cap. Busy-tagged mean SCLK was E/F 2410.8/2406.2 MHz. For the isolated shapes session, the 544 telemetry samples had a maximum of 184 W and none exceeded 190 W. Among samples tagged busy at >=95% GPU use, E/F means were:

| Metric | E | F |
| --- | ---: | ---: |
| Busy samples | 45 | 45 |
| Power | 153.4 W | 153.6 W |
| SCLK | 2413.3 MHz | 2410.5 MHz |
| Edge temperature | 35.4 C | 35.1 C |
| Junction temperature | 49.9 C | 48.2 C |
| Memory temperature | 58.4 C | 58.5 C |

The configured cap remained 190 W. No clock or power setting was changed. The shape runner waited before starts when utilization briefly read 6-8% and no KFD PID was present. A separate, unpaired harness selector check was run after a 7% reading with no KFD PID; it is retained as `shape-perf/selector-check-F.log` and excluded from all reported results. The paired runner's own idle guard was satisfied for every sample.

## Interpretation and recommendation

The existing decode A/B remains favorable: +0.782% at d=0 (95% CI +0.640% to +0.924%) and +0.873% at d=4096 (95% CI +0.690% to +1.056%), from one valid session. The new trace closes the dispatch uncertainty. The isolated MMQ measurements show an equal-weight +1.562% gain with a 95% interval above zero, while the full-model pp128 effect is too small to distinguish from noise.

The evidence now supports a reversible, controlled local adoption of F: decode is positive, and the MMQ path has a repeatable paired shape-level gain without a model-level prefill regression demonstrated. The shape harness uses synthetic tensor values and the pp128 model interval still permits a small loss, so this is not a claim of a full-model prefill speedup. Per the request, E stays active and F stays isolated. The previously documented IQ3_XXS failures shared by the earlier A/B/C controls remain separate and unresolved.

## Artifact map

- `identity-and-dispatch.txt`: full variant identities and dispatch result.
- `final-active-state.txt`: final E source/library hashes, default loader resolution, and idle GPU snapshot.
- `trace/`: short F dispatch trace, separate from unprofiled timing.
- `paired-summary.txt`, `paired-results.csv`, `raw/`, and telemetry files: model pp128 results.
- `shape-perf/test-backend-ops-mmq-perf.cpp` and `shape-perf/source.diff`: isolated five-shape harness adjustment.
- `shape-perf/ab/paired-shape-summary.txt`, `paired-shape-results.csv`, `raw/`, and telemetry files: MMQ shape A/B data.
- `shape-perf/run-shape-perf-ab.sh`, `shape-perf/analyze_shape_perf.py`: reproducible runner and paired analysis.
