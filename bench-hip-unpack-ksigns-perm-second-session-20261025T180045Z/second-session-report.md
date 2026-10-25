# `unpack_ksigns` `amdgcn_perm`: second C/E session

Target: RX 7800 XT (`gfx1101`). This is a new paired session; it does not reuse the first session's report as a result. C remained the fork's active control, and E was selected only through a per-run `LD_LIBRARY_PATH`.

## Result

E again measured a positive decode gain at both depths. In this second session, both paired 95% intervals were above zero. The `pp512` point estimate was slightly negative, but its interval includes zero, so this session does not demonstrate a prefill regression.

| Workload | C mean | E mean | Paired gain | Paired 95% CI |
| --- | ---: | ---: | ---: | ---: |
| `tg128`, `d=0` | 34.03540 tok/s | 34.26080 tok/s | +0.662% | +0.398% to +0.927% |
| `tg128`, `d=4096` | 33.02261 tok/s | 33.34604 tok/s | +0.984% | +0.189% to +1.778% |
| `pp512` | 620.45796 tok/s | 619.24981 tok/s | -0.193% | -0.803% to +0.417% |

These paired measurements add evidence for a small decode improvement. Keep C active and E isolated as requested; this run does not activate or promote E.

## Protocol

The model was `/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` (SHA-256 `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`). The same `llama-bench` executable and runtime settings as the previous C/E session were used: `ROCm0`, `-ngl 99`, flash attention on, F16 K/V cache, batch 2048, microbatch 512, 8 threads, `-r 1`.

Decode command template:

```sh
llama-bench -m "$MODEL" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 \
  -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 128 -d 0,4096
```

Prefill command template:

```sh
llama-bench -m "$MODEL" -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 \
  -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 512 -n 0 -d 0
```

There were ten adjacent pairs for each workload. Pair order alternated, with five C-E and five E-C pairs per workload. Decode runs each returned both depths. `llama-bench` retained its built-in warmup for each generation depth and for pp512. MTP was disabled by the `llama-bench` default (`load_mtp=false`); no draft/MTP option was supplied. The 40 JSON files contain 60 result rows, all checked for model, prompt/decode shape, depth, offload, cache, batch, threads, and flash-attention settings.

Gain is calculated for each pair as `100 * (E avg_ts / C avg_ts - 1)`. Intervals are two-sided paired Student-t intervals over ten percentage gains (`df=9`, `t*=2.262157`). The decode summary with equal weight for the two depths is +0.823% (95% CI +0.445% to +1.201%); prefill is kept separate.

## Comparison with the first session

The first session measured `tg128 d=0` at +0.723% (95% CI -0.100% to +1.545%) and `d=4096` at +1.057% (95% CI +0.427% to +1.687%). The second session's paired gains are again positive at both depths; the `d=0` interval now excludes zero. Absolute throughput is not compared across sessions because runtime and clock telemetry can shift between sessions. The first session did not measure E vs C at pp512; the prefill result above is new.

## Telemetry and limits

The configured graphics power cap was 190 W in both before and after snapshots; no power or clock setting was changed. Runtime device-override variables were unset. The 341 one-second telemetry samples tagged to C/E runs included 139/169 busy C samples and 140/172 busy E samples (`GPU use >=95%`). For those busy-tagged samples:

| Variant | Mean / range sampled power | Mean SCLK / range | Junction range | Memory range |
| --- | ---: | ---: | ---: | ---: |
| C | 189.2 W / 86-219 W | 2319 / 2210-2484 MHz | 52-75 C | 63-83 C |
| E | 188.4 W / 86-214 W | 2318 / 2194-2480 MHz | 52-75 C | 66-84 C |

The 1-second telemetry can include run-boundary samples; some sampled power values exceed 190 W, although the configured cap remained 190 W. The C/E mean SCLKs were nearly identical in this session. This supports the paired comparison, while the limited sample count and GPU telemetry resolution remain constraints.

## Final state and artifacts

Final active source SHA-256: `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83`.

Final active library SHA-256: `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8`.

With `LD_LIBRARY_PATH` unset, `build-hip-baseline/bin/llama-bench` resolves the HIP library under `build-hip-baseline/bin`. E source and library remain isolated in the first experiment directory; E library SHA-256 is `ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24`.

- [`paired-summary.md`](paired-summary.md), [`paired-results.csv`](paired-results.csv), and [`analysis-output.txt`](analysis-output.txt)
- [`run-second-session.sh`](run-second-session.sh), [`sequence.log`](sequence.log), and exact commands/JSON/logs under [`raw/`](raw/)
- [`telemetry-summary.txt`](telemetry-summary.txt), [`telemetry.jsonl`](telemetry.jsonl), and before/after snapshots
- [`binary-hashes.txt`](binary-hashes.txt), [`runtime-environment.txt`](runtime-environment.txt), [`mtp-runtime.txt`](mtp-runtime.txt), and per-variant loader records

No commit, push, or PR was made.
