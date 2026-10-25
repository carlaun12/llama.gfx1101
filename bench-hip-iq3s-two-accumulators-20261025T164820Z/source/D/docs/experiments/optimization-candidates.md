# Candidate optimizations after E005

Analysis only. No new kernel implementation is authorized by this document. Target: Qwen3.8-27B mixed IQ quantization on gfx1101, HIP, 190 W.

## Evidence and measurement limits

The E002 trace attributes 25.65% of summed kernel time to IQ3_XXS and 21.75% to IQ3_S. These are the primary targets. The existing trace does not measure memory bandwidth, cache hit rates or instruction stalls. It cannot establish which resource limits performance.

Two warps regressed, two integer accumulator chains were neutral, and two rows per warp showed no benefit. Do not repeat these changes without a new mechanism and supporting evidence. Small sequential-run differences need alternating control/experiment measurements.

The review below now includes disassembly of all four complete IQ3 single-token kernels in the current gfx1101 binary. Their K dimensions remain runtime parameters. Before implementation, inspect how the loop behaves for the relevant K dimensions (5120 and 17408). Check actual activation loads, integer instruction sequences, VGPR allocation and scratch. A small isolated dot-product probe is insufficient to predict the whole kernel. Where supported, collect hardware counters to distinguish memory/cache limitations from instruction throughput and latency.

## Prioritized candidates

| Priority | Candidate | Concrete opportunity | Cost and uncertainty |
| --- | --- | --- | --- |
| 1 | Simplify IQ3 sign application | Both IQ3 dot functions expand sign masks with `__vcmpne4` and apply byte negation through `__vsub4`. HIP implements these generic helpers using multiple integer operations. A local equivalent specialized to the actual mask and grid ranges may reduce instruction count. IQ3_XXS already computes parity in `unpack_ksigns`; it does not need a sign lookup-table removal. | Moderate. Prove byte-level equivalence, including no cross-byte borrow errors; inspect full-kernel assembly before benchmarking. Compiler optimization may already remove part of the cost. |
| 2 | Reduce register lifetimes and specialize the dense fused path | The full disassembly already shares the Q8 activation loads between up and gate. Instead, examine unnecessary metadata/setup and register lifetimes, and specialize gate presence or the no-ID dense path only where the generated code improves. | Moderate to high. IQ3_S has 64 reported VGPRs fused versus 48 plain; IQ3_XXS has 56 versus 48. These counts do not establish an occupancy bottleneck. Uniform runtime branches are not proof of lane divergence. |
| 3 | Improve codebook lookup access | `iq3xxs_grid` has 256 uint32 entries (1 KiB), `iq3s_grid` has 512 (2 KiB); both are device tables accessed by weight-dependent indices. Compare the current generated loads with selected cache policies or a block-local LDS copy. | Moderate. LDS initialization, synchronization and bank conflicts may outweigh benefits, especially with the current one-warp blocks. Measure lookup/cache cost before choosing a placement. Constant memory is not automatically preferable for lane-dependent indices. |
| 4 | Pipeline weight loads and decoding | The current loop loads packed indices, then looks up grids, applies signs and computes dot products. Preparing the next K block earlier may overlap independent work with load latency without changing rows or warp counts. | Moderate. Prefetching/unrolling can increase registers and compete for cache capacity. Requires assembly and counters; the existing prefetch path in this file is specific to DGX Spark, not evidence for AMD. |
| 5 | Repack IQ3 weights once at load time | A HIP-specific internal representation could make index, sign and scale loads easier to vectorize, or pre-expand selected metadata while keeping decoded weight values identical. | High. Adds buffer management and loading work; can increase VRAM and bytes read per token. Measure the model, KV cache and runtime memory headroom first. Full expansion to Q8 is not a free optimization on a 16 GiB card. |
| 6 | Remove redundant activation quantization | `quantize_q8_1` accounts for 2.52% of summed kernel time. Audit whether multiple consumers of an unchanged activation already share the quantized buffer; consider reuse or producer fusion only for a proven duplicate. | Moderate to high relative to its limited target share. Existing scheduler/buffer reuse may already avoid duplication. Lower priority than the IQ3 dot kernels. |

These are hypotheses, not promised speedups. Prefer a small gfx1101-specific implementation after confirming the relevant mechanism. Keep model quantization and the 190 W cap fixed. Validate GPU correctness and then use alternating E002/candidate benchmark runs before retaining small gains. Prompt processing needs its own matrix-matrix profile if it becomes the primary objective; the existing capture covers decode.

## Revised gfx1101 analysis

The previous list overstated explicit sharing of activation loads as an opportunity. Disassembling the complete kernels shows that the compiler already keeps a single Q8 chunk for both projections: each fused IQ3 kernel has two `global_load_b128` instructions for its 32 activation bytes, a 32-bit load covering the remaining chunk/scale data, and both sets of dot products consume the loaded values. It does not load a second full Q8 chunk for the gate. A paired helper cannot be justified solely as removing duplicate activation loads.

The sign application remains a concrete arithmetic opportunity in the full kernels. `iq3xxs_grid` contains only byte magnitudes {4,12,20,28,36,44,52,62}; `iq3s_grid` contains {1,3,5,7,9,11,13,15}. Thus every byte is positive, nonzero and below 128. For a byte mask whose lanes are either 0x00 or 0xff, the existing operation can be expressed as:

```text
__vsub4(grid ^ mask, mask)
    == (grid ^ mask) + (mask & 0x01010101)
```

For a negative lane, the complemented magnitude is at most 254, so adding one cannot carry into the next byte. Positive lanes receive zero. This identity depends on the actual codebook range and must not replace the generic HIP helper globally. A host check exhausted every entry in both codebooks and all 16 four-byte sign patterns: 12,288 combinations matched both independent byte-wise negation and the current helper arithmetic. This proves the local arithmetic identity for these inputs; no candidate HIP kernel has been built or measured. See [check-packed-negation.py](analysis/gfx1101-review/check-packed-negation.py) and [packed-negation.txt](analysis/gfx1101-review/packed-negation.txt).

The current full kernels still contain the generic mask/subtraction sequences. The four archived disassemblies in [analysis/gfx1101-review/](analysis/gfx1101-review/) show 8 dot4 instruction sites in each plain kernel and 16 in each fused kernel. These are static sites, not per-token executed instruction counts. Native `v_dot4_i32_iu8` is already present. A useful first candidate is the local packed-negation simplification, followed by examining sign-mask construction; neither requires increasing warp count or grouping output rows.

The profile reports 48 VGPRs for both plain kernels, 56 for fused IQ3_XXS and 64 for fused IQ3_S, all with zero scratch. Higher register counts justify checking lifetimes, but do not prove occupancy or spills are limiting execution. The 64-VGPR fused IQ3_S path deserves independent study rather than applying the same launch change to both types.

Grouping the trace by output rows gives additional priorities: fused IQ3_S with 5120 output rows takes 228.924 ms; fused IQ3_XXS with 17408 rows takes 221.253 ms; plain IQ3_XXS with 17408 rows takes 218.955 ms. The row count comes from total grid workitems divided by the observed 32-thread one-row block. This does not reveal K or tensor identity, so those must be correlated with model metadata before assigning individual projection costs. The grouped trace is archived in [profile-by-row-count.json](analysis/gfx1101-review/profile-by-row-count.json).

LDS codebook staging and one-time repacking remain lower-confidence options. Small codebooks may already be cached, and a one-warp block pays staging costs for very little block-local reuse. Do not prioritize LDS without evidence of costly table misses. Prefetching also needs evidence of load stalls and room for additional live registers. At 190 W, compare every retained candidate using the same power setting; none of these observations proves how the power cap affects the bottleneck.

Revised order: (1) local packed-negation and mask simplification, (2) register lifetimes and selective dense/fused specialization, (3) cache/pipeline changes only after counters support them, (4) repacking as a larger design experiment. Quantization reuse remains low priority. No kernel source was changed during this review.

## Second review: isolated compilation

The packed-negation hypothesis has now been compiled in a temporary copy of the complete matrix-vector translation unit, using the current build flags and gfx1101 target. The active kernels and binary remain unchanged. See [gfx1101-negation-compile/](analysis/gfx1101-negation-compile/) for assembly, compiler invocation, patch, metadata, limitations and reproduction instructions.

| Kernel | Static instruction sites, before -> after | Compiler next_free_vgpr, before -> after |
| --- | --- | --- |
| IQ3_XXS plain | 362 -> 332 | 42 -> 36 |
| IQ3_XXS fused | 885 -> 818 | 56 -> 50 |
| IQ3_S plain | 390 -> 358 | 45 -> 45 |
| IQ3_S fused | 947 -> 879 | 60 -> 60 |

Private segment size remains zero. Compiler register metadata is not identical to profiler-reported allocation; do not infer an occupancy improvement from these numbers alone. Static instruction savings do not translate directly into runtime savings. The 249 non-IQ3 matrix-vector variants retain their instruction mnemonic sequences and VGPR metadata.

The expression is therefore supported by both exhaustive local arithmetic checks and full-kernel compiler evidence. It remains the strongest small candidate, with no GPU performance claim. The register-lifetime candidate stays second, but the negation simplification does not reduce IQ3_S register metadata; that problem needs a separate mechanism. No new evidence supports prioritizing codebook staging, prefetching or weight repacking.

## Third review: expand packed sign bits directly

The previous small candidate still retained generic sign-mask expansion. A second isolated candidate now replaces that expansion as well as the byte negation. All 393,216 codebook/packed-sign/half combinations passed a host comparison against the actual old mask formulas and independent byte-wise negation. See [gfx1101-direct-signs/](analysis/gfx1101-direct-signs/) for the patch, complete selected assembly, compile invocation and checker.

| Kernel | Original static sites / compiler VGPRs | Negation only | Direct signs plus negation |
| --- | --- | --- | --- |
| IQ3_XXS plain | 362 / 42 | 332 / 36 | 301 / 40 |
| IQ3_XXS fused | 885 / 56 | 818 / 50 | 759 / 52 |
| IQ3_S plain | 390 / 45 | 358 / 45 | 305 / 39 |
| IQ3_S fused | 947 / 60 | 879 / 60 | 766 / 54 |

Direct signs have fewer instruction sites for both types, but more register metadata than negation-only for IQ3_XXS. Both remain candidates; neither has been executed on the GPU or enabled in the main build. The stronger compiler evidence for IQ3_S makes it a first-class target alongside IQ3_XXS. A single arithmetic implementation need not be optimal for both types.

The four-block-per-iteration mapping of the current one-warp kernel also shows that two warps introduce a half-active final iteration at K=5120 and K=17408. This is one plausible cost of E003, not a causal diagnosis. Full calculations and the revised measurement requirements are in the new analysis document. No new kernel source change was made.

## Source references

- `ggml/src/ggml-cuda/vecdotq.cuh`: `vec_dot_iq3_xxs_q8_1`, `vec_dot_iq3_s_q8_1`, `unpack_ksigns`.
- `ggml/src/ggml-cuda/vendors/hip.h`: implementations of `__vcmpne4` and `__vsub4`.
- `ggml/src/ggml-cuda/mmvq.cu`: K loop, separate up/gate helper calls and fusion dispatch.
- `ggml/src/ggml-common.h`: device-table declarations and IQ3 codebooks.
- `ggml/src/ggml-cuda/common.cuh`: `ggml_cuda_dp4a` already selects an AMD dot-product builtin on RDNA3; adding a native dot instruction is not a missing optimization here.
