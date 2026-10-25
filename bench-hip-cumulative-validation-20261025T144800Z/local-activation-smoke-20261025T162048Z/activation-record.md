# Local activation record: C

Activation completed on 2026-10-25. The activation script's preconditions matched B: active source and library hashes matched the control values, and the preserved B snapshots also matched. The script verified C's hashes and `ldd` resolution after the swap. It refuses to replace source or library files whose hashes differ from the recorded state; its error trap restores B if post-swap verification fails.

## Active paths and hashes

- Source: `/home/carlos/project/llama.gfx1101/ggml/src/ggml-cuda/vecdotq.cuh`
  - SHA-256: `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83`
- HIP library: `/home/carlos/project/llama.gfx1101/build-hip-baseline/bin/libggml-hip.so.0.27.0`
  - SHA-256: `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8`
- Executable: `/home/carlos/project/llama.gfx1101/build-hip-baseline/bin/llama-bench`
  - `ldd` resolves `libggml-hip.so.0` to `/home/carlos/project/llama.gfx1101/build-hip-baseline/bin/libggml-hip.so.0`.

## Smoke inference

The recorded baseline decode command uses `llama-bench` with `-dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -p 0 -d 0`. This smoke run kept those runtime settings and shortened generation to 8 tokens with one repetition:

```sh
/home/carlos/project/llama.gfx1101/build-hip-baseline/bin/llama-bench \
  -m /home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf \
  -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 \
  -r 1 -o json --progress -p 0 -n 8 -d 0
```

Exit status was 0. The JSON identifies the requested GGUF as `qwen35 27B IQ3_XXS`, with 27,320,697,856 parameters and `n_gen=8`. Stderr confirms the RX 7800 XT / gfx1101 was detected and reports warmup plus generation run `1/1`. This confirms basic model loading and generation; it is not a numerical equivalence check or a performance comparison. No clock or power setting was changed.

Command, loader map, stdout, stderr, and exit status are saved next to this record.

## Restore B

From the repository root, run:

```sh
bench-hip-cumulative-validation-20261025T144800Z/restore-control-local.sh
```

The restore script requires the active C source/library hashes to match before replacing them and verifies the restored B hashes and loader resolution. Preserved B snapshots are under `activation-snapshots/`.

The shared IQ3_XXS fused backend-test failures from seeds 17 and 25025 remain documented in `local-adoption-review.md`. Their occurrence is identical across A/B/C; cancellation sensitivity in the NMSE check remains a hypothesis, not a demonstrated cause.
