# E local activation record

Activated E locally on 2026-10-25 after the two paired C/E sessions. C remains preserved for restoration. No benchmark was run as part of activation; the inference below is only a smoke test.

## Reviewed change and hashes

The recorded C-to-E diff is [`C-to-E.diff`](C-to-E.diff). It contains only the HIP branch of `unpack_ksigns`: HIP uses `__builtin_amdgcn_perm(0, s, 0)`, and the non-HIP branch keeps the multiplication. The parity correction and all consumers remain unchanged.

| Variant | Source SHA-256 | HIP library SHA-256 |
| --- | --- | --- |
| Preserved C | `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83` | `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8` |
| Active E | `9f0faab54379357d5239191cfe367a3789c39a8c519c82ea45826791ca7fc11c` | `ea89b81c6ac2c519fbbb8c43f3d986413cfb14f4901098f1817c085431cfbf24` |

The activation script verified that active source and library matched C before replacement, that the preserved C snapshots and validated E artifacts matched their full hashes, and that no `llama-cli`, `llama-server`, or `llama-bench` process was running. After activation, both active hashes matched E and default `ldd` resolution for `llama-bench` pointed to `build-hip-baseline/bin/libggml-hip.so.0`, whose target is the E library. See [`activation.log`](activation.log), [`final-active-hashes.txt`](final-active-hashes.txt), and [`final-active-loader.txt`](final-active-loader.txt).

## Smoke test

The fork's prior local inference check uses `llama-bench` with the established decode settings and eight generated tokens:

```sh
env -u LD_LIBRARY_PATH /home/carlos/project/llama.gfx1101/build-hip-baseline/bin/llama-bench \
  -m /home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf \
  -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 \
  -r 1 -o json --progress -p 0 -n 8 -d 0
```

Exit status was 0. The runtime log detected the AMD Radeon RX 7800 XT (`gfx1101`), then reported warmup and `generation run 1/1`. JSON output identifies the habitual Qwen3.8 27B IQ3_XXS GGUF and records `n_gen=8`. MTP stayed disabled: `llama-bench` default `load_mtp=false`; no draft/MTP option was passed. This confirms basic load and generation only; it is not a correctness test or performance measurement. See [`smoke-command.txt`](smoke-command.txt), [`smoke-stderr.log`](smoke-stderr.log), [`smoke-stdout.json`](smoke-stdout.json), and [`smoke-exit-status.txt`](smoke-exit-status.txt).

## Active paths and restore

E is active at:

- Source: `/home/carlos/project/llama.gfx1101/ggml/src/ggml-cuda/vecdotq.cuh`
- HIP library: `/home/carlos/project/llama.gfx1101/build-hip-baseline/bin/libggml-hip.so.0.27.0`
- Default executable: `/home/carlos/project/llama.gfx1101/build-hip-baseline/bin/llama-bench`

The exact C source and library backups are in [`snapshots/C/`](snapshots/C/). To restore C from the repository root, run:

```sh
bash bench-hip-unpack-ksigns-perm-20261025T171525Z/local-activation-E-20261025T181721Z/restore-control-local.sh
```

The restore script requires the active source and library to still match E, verifies both C backups, refuses to run while an inference process is active, restores C, and verifies the hashes and default loader resolution. If either active file has changed since activation, it aborts instead of overwriting it.

The known IQ3_XXS backend-test failures at seeds 17 and 25025 remain documented in [`shared-iq3xxs-failures/comparison.txt`](../shared-iq3xxs-failures/comparison.txt) and the prior [local adoption review](../../bench-hip-cumulative-validation-20261025T144800Z/local-adoption-review.md). They occur with the same inputs and outputs across the tested variants and still exceed the existing NMSE threshold of `0.005`; no tolerance was changed. Their underlying cause is not proven.

No clock or power setting was changed. No commit, push, or PR was made.
