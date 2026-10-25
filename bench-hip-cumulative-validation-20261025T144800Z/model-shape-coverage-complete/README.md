# Complete model shape checks

Target: RX 7800 XT / gfx1101. Model: the GGUF named in the parent validation report, SHA-256 `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`.

The prior operation suite covered the four optimized quantization types, but several cases used generic dimensions. This private test harness adds every distinct type/K/N pair found in the model for plain `MUL_MAT`, plus the actual FFN gate/up decode shape (`K=5120, N=17408`) for each type in `MUL_MAT_VEC_FUSION`.

| Type | Plain K x N shapes |
| --- | --- |
| IQ2_S | 5120x1024, 5120x6144, 5120x10240, 5120x17408, 5120x248320, 6144x5120, 17408x5120 |
| IQ3_S | 5120x1024, 5120x6144, 5120x10240, 5120x17408, 6144x5120, 17408x5120 |
| IQ3_XXS | 5120x1024, 5120x6144, 5120x10240, 5120x12288, 5120x17408, 6144x5120, 17408x5120 |
| IQ2_XXS | 5120x1024, 5120x6144, 5120x10240, 5120x12288, 5120x17408, 6144x5120, 17408x5120 |

A, B, and C each passed `392/392` selected backend cases with seed `4321`. This includes the existing four-format backend suite, all 27 exact model shape cases, and four fused gate/up cases. No tolerance or repository source was changed. The harness and executable are private to this experiment.

`run-complete-shape-coverage.py` records the command and verifies `ldd` selects the matching isolated HIP library before each run. Full stdout is in `A.log`, `B.log`, and `C.log`; exact commands and loader maps are in the matching `.command.txt` and `loader-*.txt` files. Compile and link commands are also recorded.

The shape test uses one activation row and validates the exact quantized weight dimensions against the backend reference. It does not independently execute every tensor in the full model graph. The earlier target-GGUF decode and prefill benchmarks exercise model inference; their performance results are in the parent report.
