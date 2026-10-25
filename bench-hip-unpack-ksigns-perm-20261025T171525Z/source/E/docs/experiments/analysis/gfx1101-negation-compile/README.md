# Isolated compilation of the packed-negation hypothesis

This is a compiler analysis, not an enabled experiment. The main source, build directory and binary were not changed. The candidate header exists only in `/tmp/iq3-negation-isa-review`.

The local host equivalence check is in `../gfx1101-review/check-packed-negation.py`. It exhausts 12,288 codebook/sign combinations. GPU correctness and throughput have not been measured for this candidate.

Reproduction: copy `mmvq.cu` and all `.cuh` files in `ggml/src/ggml-cuda/` into a temporary directory. Apply `analysis-only.diff` to the copied `vecdotq.cuh`. Read the mmvq command from `build-hip-baseline/compile_commands.json`, preserve its defines, optimization flags and include paths, remove `-c` and its object-output argument, use the temporary source as input, and add `-I<original ggml-cuda directory> --cuda-device-only -S -o <temporary candidate.s>`. Compile the original mmvq source with the same flags into a separate control assembly. The saved `compile-command.json` records the exact candidate invocation and local paths. Compilation uses the build directory as its working directory. The additional copied headers are necessary because `quantize.cuh` also includes vecdotq indirectly through MMQ headers.

Compare the full functions whose symbols are recorded in `comparison.json`. Selected complete function assembly is archived here. Counts are static instruction sites across the full function, including setup, branches and delays. They are not executed instruction counts, cycle counts or speedup predictions.

| Kernel | Control instruction sites | Candidate instruction sites | Control next_free_vgpr | Candidate next_free_vgpr |
| --- | ---: | ---: | ---: | ---: |
| IQ3_XXS plain | 362 | 332 | 42 | 36 |
| IQ3_XXS fused | 885 | 818 | 56 | 50 |
| IQ3_S plain | 390 | 358 | 45 | 45 |
| IQ3_S fused | 947 | 879 | 60 | 60 |

All four have zero compiler-declared private segment size, both before and after. Dot4 instruction-site counts remain 8 for plain and 16 for fused. The 249 non-IQ3 matrix-vector variants have unchanged instruction mnemonic sequences and VGPR metadata; this scope check does not compare every operand.

`next_free_vgpr` is compiler metadata before hardware allocation granularity. It differs from the profiler-reported allocated counts (48/56 for IQ3_XXS, 48/64 for IQ3_S). A reduction in this field does not by itself imply more resident waves, and the two counts must not be mixed in one comparison.

These compiler results strengthen the packed-negation candidate. They do not demonstrate faster generation, or prove that instruction processing is the runtime bottleneck at 190 W. A gfx1101-scoped production experiment still needs GPU correctness tests and controlled throughput measurements. Do not apply this analysis patch as an already approved optimization.
