# Direct sign-mask expansion: third review

Compiler analysis only; no change to the active repository kernels, build or binary. This candidate combines packed negation with direct expansion of four packed sign bits into four byte lanes. The isolated compile uses the same flags and gfx1101 target as the previous control. Full compiler command, selected assembly and temporary-header patch are archived here. Reproduction follows `../gfx1101-negation-compile/README.md`, with this analysis patch instead.

For nibble `n`, `bits = (n * 0x00204081u) & 0x01010101u` places each of its four bits in the least significant bit of a byte. `mask = bits * 255u` expands selected bytes to 0xff. Signed magnitudes are then `(grid ^ mask) + bits`, with unsigned 32-bit arithmetic. For IQ3_XXS, decode the seven stored sign bits and restore the eighth using parity; for IQ3_S use the stored sign byte. This replaces both the broadcast/byte comparison sequence and the generic byte subtraction, without using a sign lookup table.

`check-direct-signs.py` compares the new mask to the actual old sign-mask formulas and checks the final bytes against independent per-byte negation. It covers all 256 packed sign inputs, both four-byte halves and every entry in both codebooks: 393,216 combinations passed. This is host arithmetic validation, not GPU execution.

| Kernel | Original instruction sites / VGPR metadata | Negation only | Direct signs plus negation |
| --- | --- | --- | --- |
| IQ3_XXS plain | 362 / 42 | 332 / 36 | 301 / 40 |
| IQ3_XXS fused | 885 / 56 | 818 / 50 | 759 / 52 |
| IQ3_S plain | 390 / 45 | 358 / 45 | 305 / 39 |
| IQ3_S fused | 947 / 60 | 879 / 60 | 766 / 54 |

Register metadata is `next_free_vgpr`, not profiler allocation. All variants have zero declared private segment size. Native dot4 sites remain 8 plain / 16 fused. Static instruction sites include prologue, loop, reductions, alternative paths, waits and delay instructions; these are not dynamic counts or cycles. The control and negation-only counts are copied from the previous identical-flag compiler comparison.

Direct signs reduce instruction sites for both types and register metadata for IQ3_S. However, they require more VGPRs than negation-only for IQ3_XXS. This is a tradeoff, not a measured runtime win. Compare the two alternatives separately for each type before deciding whether to combine them. No GPU correctness or throughput result exists for either candidate.

## Loop coverage and interpretation of earlier experiments

The current one-warp IQ3 kernel has qk=256, qi=16, vdr=2 and wave size 32, giving four quantization blocks per loop iteration. K=5120 has 20 blocks and needs five iterations; K=17408 has 68 blocks and needs seventeen. Doubling to two warps would use eight blocks per iteration, requiring three and nine iterations respectively. The last two-warp iteration has only four active blocks for both K values, giving block-slot utilization of 83.33% and 94.44% across the loop, before considering reduction overhead.

These calculations expose costs of widening the block but do not establish why E003 regressed. Likewise, the neutral two-accumulator result does not prove the kernel is memory-bound, and E005 does not rule out all activation reuse. The candidates have different mechanisms and must be judged independently.

## Measurement discipline

The existing trace provides kernel durations and allocation information, not a memory/compute bottleneck diagnosis. Hardware counters and repeated, alternating control/candidate runs at 190 W remain necessary for small changes. Do not convert the instruction-site reduction into a tokens/s prediction. Do not automatically reject or retain a sub-percent effect from one sequential comparison. The correct next implementation, if requested, is a narrow experiment with archived GPU correctness output and explicit comparisons of the two arithmetic alternatives.
