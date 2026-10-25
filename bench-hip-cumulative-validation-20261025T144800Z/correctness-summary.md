# Cumulative correctness validation

GPU: AMD Radeon RX 7800 XT, gfx1101. Tests ran serially, with isolated A/B/C HIP libraries selected through `LD_LIBRARY_PATH` and checked with `ldd`.

## Exact packed arithmetic checks

| Path | Coverage | Result |
| --- | ---: | --- |
| IQ2_S direct sign expansion | 1,024 entries x 256 sign bytes x 2 halves = 524,288 cases | Exact masks and packed operands; no zero lanes |
| IQ3_S direct sign expansion | 512 entries x 16 low/high sign values x 2 halves = 16,384 cases | Exact packed equality; no zero lanes |
| IQ3_XXS packed negation | 256 entries x 128 valid sign encodings x 2 halves = 65,536 cases | Exact packed equality; no zero lanes |
| IQ2_XXS packed negation | 256 entries x 128 valid sign encodings x 2 halves = 65,536 cases | Control, candidate, and independent byte reference match; no zero lanes or carry |

Each packed-add identity is valid only for the sign masks and nonzero codebook magnitudes checked above. The proof does not cover arbitrary byte values outside those domains.

## Backend operation tests

The existing `test-backend-ops` program covered `MUL_MAT` and `MUL_MAT_VEC_FUSION` for IQ2_S, IQ3_S, IQ3_XXS, and IQ2_XXS. Its default test inputs use `random_device`, and separate invocations therefore do not receive the same tensors. A temporary copy of the harness changed only `init_tensor_uniform` to take a seed from `LLAMA_TEST_RANDOM_SEED`; no repository source or official executable was changed.

For each of seeds 17, 25025, and 4321, A, B, and C ran the same 361 tests with the same generated inputs:

- Seed 17: A/B/C each passed 360/361. The same IQ3_XXS fused case (`SWIGLU`, k=256, n=1, bias, no gate) failed with the same reported error, 0.102979308.
- Seed 25025: A/B/C each passed 360/361. The same IQ3_XXS fused case (`SWIGLU`, k=5120, n=1, bias, no gate) failed with the same reported error, 0.011553447.
- Seed 4321: A/B/C each passed 361/361.

The two failures reproduce identically on original A, current control B, and candidate C. They are shared backend-test/reference failures, not a difference between the variants. The separate non-deterministic run also had isolated IQ3_XXS fused failures; an A rerun passed. The matched-seed evidence is used for attribution.

## Library selection

For all A/B/C backend runs, `ldd` resolved `libggml-hip.so.0` to the corresponding isolated library in this experiment. The deterministic harness has a private executable and source diff under `deterministic-test/`; the original test executable and fork source remain unchanged.
