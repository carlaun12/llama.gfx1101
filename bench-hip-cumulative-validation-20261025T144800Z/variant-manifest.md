# Variant manifest

## Reconstruction

The original baseline is commit `bb41340de1868650bffc3ad09d62fb18f2748754`. The archived baseline from 2026-10-25 01:20 has that commit and an empty `source.diff`; its `tg128` results are in `baseline-hip-20261025T012021Z-xZDy5L/generation.json`. Variant A was rebuilt from a detached worktree at that commit.

| Variant | Source state | Optimizations from this series | Source SHA-256 | Isolated HIP library SHA-256 |
| --- | --- | --- | --- | --- |
| A | Original commit, no local diff | None | `37aa1bbf64367736a65a122ccc9ce2ce8a305eeb4931385156d282c1efbf296` | `7cc139be17c4185dbafbeff0bb8e91732bcca7c333343ad870bbc4af6c4c03f8` |
| B | Active control source snapshot at experiment start | IQ3_S direct sign expansion; IQ2_S direct sign expansion; IQ3_XXS packed negation | `a22eebfb491090e3cb5c5d297caacd3bff0055f12fe0318db897d7873f6efceb` | `642b0f909860de6d036dc0e75f5740b7d93f183faaaf1c5c04c516a9aab70830` |
| C | B plus the archived IQ2_XXS candidate | B plus IQ2_XXS packed-negation simplification | `4c6ddd1e07ebbcc35c165bd16b5f62bb8551046fcf19a5e6b022f9ba03887d83` | `a0b56310f88fa0f6fdbb6a4e3ba188617c2dbbe7f43b4a371094139754e264b8` |

`B.patch` records A->B; `B-to-C.patch` records B->C and contains only the two IQ2_XXS `grid0`/`grid1` expressions. IQ2_XXS sign extraction and `__vcmpne4` are unchanged.

## Build and runtime identity

A, B, and C have separate source worktrees, build directories, and library directories. Their CMake settings match: Release, ROCm Clang 22, HIP for `gfx1101`, native CPU, HIP graphs, MFMA, no VMM, tests enabled, Vulkan/CUDA/examples/server/app disabled. The normalized compile commands match for `mmvq.cu` and the IQ2_S, IQ3_S, IQ3_XXS, and IQ2_XXS MMQ instances. See `normalized-build-settings.txt`, `configure-*.command.txt`, and `build-*.log`.

The same host executables were used for every variant:

- `llama-bench`: SHA-256 `39ed56ec48bb770fdd99fcfb048906adc1d9d48b60ed3b888c2e8c4c65fcda25`.
- `test-backend-ops`: SHA-256 `aa2ca679ae5bc887057fa6b2cff7df3206dc405e182160eac6a097cb16a33741`.
- Model: `/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`, SHA-256 `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`.

Each executable's `ldd` output was checked for A/B/C. The selected `libggml-hip.so.0` resolves to the matching experiment library. Loader evidence is in `loader-llama-bench-{A,B,C}.txt` and `loader-test-backend-{A,B,C}.txt`; deterministic test loader checks are also saved per seed.

The control source and library active at experiment start were preserved. Their initial and final hashes match: source `a22eebfb...f6efceb`, active library `676433a44e3e947b0d37d050109328aa4b8d20f77a515276e50135b92d8e658b`. The isolated B rebuild has a different binary hash because it was compiled in its own worktree/build path, but its source hash is identical to the active control. C remains isolated under `library/C` and `build/C`.
