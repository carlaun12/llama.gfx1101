# Target model tensor shapes

Model: `/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`
Model SHA-256: `e13d3e7400b6c7f980ebd30c0edd6be43eb1865b50be8562a9db042706c7d803`
Architecture: `qwen35`; tensors in file: 866

Dimensions below use GGUF order `K x N` (first and second tensor dimensions). Counts include tensors with that pair.

| Type | Tensor count | K x N | Count |
| --- | ---: | --- | ---: |
| IQ2_S | 72 | 5120 x 1024 | 2 |
| IQ2_S | 72 | 5120 x 6144 | 7 |
| IQ2_S | 72 | 5120 x 10240 | 15 |
| IQ2_S | 72 | 5120 x 17408 | 28 |
| IQ2_S | 72 | 5120 x 248320 | 1 |
| IQ2_S | 72 | 6144 x 5120 | 4 |
| IQ2_S | 72 | 17408 x 5120 | 15 |
| IQ3_S | 97 | 5120 x 1024 | 7 |
| IQ3_S | 97 | 5120 x 6144 | 7 |
| IQ3_S | 97 | 5120 x 10240 | 10 |
| IQ3_S | 97 | 5120 x 17408 | 22 |
| IQ3_S | 97 | 6144 x 5120 | 35 |
| IQ3_S | 97 | 17408 x 5120 | 16 |
| IQ3_XXS | 83 | 5120 x 1024 | 3 |
| IQ3_XXS | 83 | 5120 x 6144 | 12 |
| IQ3_XXS | 83 | 5120 x 10240 | 9 |
| IQ3_XXS | 83 | 5120 x 12288 | 8 |
| IQ3_XXS | 83 | 5120 x 17408 | 24 |
| IQ3_XXS | 83 | 6144 x 5120 | 10 |
| IQ3_XXS | 83 | 17408 x 5120 | 17 |
| IQ2_XXS | 30 | 5120 x 1024 | 1 |
| IQ2_XXS | 30 | 5120 x 6144 | 3 |
| IQ2_XXS | 30 | 5120 x 10240 | 2 |
| IQ2_XXS | 30 | 5120 x 12288 | 1 |
| IQ2_XXS | 30 | 5120 x 17408 | 19 |
| IQ2_XXS | 30 | 6144 x 5120 | 2 |
| IQ2_XXS | 30 | 17408 x 5120 | 2 |

Additional shape coverage is recorded in `model-shape-coverage-complete/README.md`: all 27 distinct `(type,K,N)` pairs across the four optimized formats passed `MUL_MAT`, plus the actual gated decode shape `K=5120, N=17408` for all four types in `MUL_MAT_VEC_FUSION`. A/B/C each passed 392/392 selected backend cases with the same seed. The model generation benchmark used the target GGUF and exercises its real tensor shapes, but is not a numerical reference test for every model tensor.
