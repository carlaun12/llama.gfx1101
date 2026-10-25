# F local activation record

Activated F on 2026-10-25 for local use on RX 7800 XT / gfx1101. E is preserved in ../snapshots/E/ for restoration. No source beyond the validated F files was changed. No clocks or power limits were changed.

## Active F hashes

- ggml/src/ggml-cuda/vecdotq.cuh: defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c
- ggml/src/ggml-cuda/mmq-load-tiles.cuh: 18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f
- build-hip-baseline/bin/libggml-hip.so.0.27.0: 3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce

The default ldd resolution for build-hip-baseline/bin/llama-bench points to build-hip-baseline/bin/libggml-hip.so.0. During the smoke run, /proc/<pid>/maps showed /home/carlos/project/llama.gfx1101/build-hip-baseline/bin/libggml-hip.so.0.27.0.

## Smoke test

Command:

    env -u LD_LIBRARY_PATH build-hip-baseline/bin/llama-bench -m /home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf -dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -r 1 -o json --progress -p 0 -n 8 -d 0

llama-bench reported the RX 7800 XT / gfx1101, completed its warmup generation and measured generation run, and loaded the expected GGUF. The measured run generated 8 tokens and exited with status 0. MTP remained disabled by the established llama-bench default. This smoke test confirms basic operation; its throughput is not a performance result. The exact stdout, loaded-library map, and exit status are in this directory.

## Restore E

Run:

    bash bench-hip-iq2xs-direct-signs-20261025T182634Z/local-adoption-review-20261025T191110Z/restore-e-local.sh

The script checks that the active files still match F, verifies the preserved E snapshots and llama-bench hash, stages and verifies E before replacement, confirms the E hashes and default loader path, and refuses unexpected later changes.

## Known validation limits

The two IQ3_XXS backend failures recorded in the earlier cumulative validation are shared by the prior A/B/C controls and remain unresolved. The full-model pp128 prefill comparison remains inconclusive: +0.125%, paired 95% CI -0.456% to +0.705%, so no prefill gain or regression was demonstrated. The isolated MMQ shape result is not a full-model prefill speedup claim.
