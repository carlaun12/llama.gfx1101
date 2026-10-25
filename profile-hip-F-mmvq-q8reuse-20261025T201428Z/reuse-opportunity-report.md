# MMVQ q8_1 activation reuse diagnostic

Date: 2026-10-25  
Target: RX 7800 XT / `gfx1101`  
Model: `/home/carlos/slop/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`

## Active control and scope

F remained active. Its source hashes are:

- `ggml/src/ggml-cuda/vecdotq.cuh`: `defbd93d6b8f5d46edd00410c97a6fdaee9087d583c4c8bb75fa40603c762c1c`
- `ggml/src/ggml-cuda/mmq-load-tiles.cuh`: `18771895fb1f5f8bfed621239357d4af9cd4b1b030ea25228ba04e98efda801f`
- `build-hip-baseline/bin/libggml-hip.so.0.27.0`: `3feb9be9f5e459045b8b73cbdd30e98598f6f5c8a6af45f4805a7215a2d66dce`

`ldd build-hip-baseline/bin/llama-bench` resolves `libggml-hip.so.0` from `build-hip-baseline/bin`; the F activation smoke record also captured the loaded `.so.0.27.0` in `/proc/<pid>/maps`. The activation record is [activation-summary.md](../bench-hip-iq2xs-direct-signs-20261025T182634Z/local-adoption-review-20261025T191110Z/activation-20261025T200629Z/activation-summary.md).

No source or runtime configuration was changed for this diagnostic. MTP remained disabled (`llama-bench` default `load_mtp=false`); the GGUF contains 65 blocks, while the regular model graph executes trunk layers 0-63. The extra block 64 is not evidence that MTP ran.

## Same-activation opportunities in the graph

The graph creates `cur` as the layer's `attn_norm` result in [qwen35.cpp](../src/models/qwen35.cpp#L164). The model metadata gives hidden width 5120, 48 recurrent/GDN layers and 16 full-attention layers in the executed 64-layer trunk. The GGUF stores separate quantized projection weights for these operations:

| Layer path | Projections using the same `cur` | Weight shapes `(K,N)` | Calls per token | Redundant calls |
|---|---|---:|---:|---:|
| 48 recurrent/GDN layers | `attn_qkv`, `attn_gate` | `(5120,10240)`, `(5120,6144)` | 96 | 48 |
| 16 full-attention layers | `attn_q`, `attn_k`, `attn_v` | `(5120,12288)`, `(5120,1024)`, `(5120,1024)` | 48 | 32 |
| **Total** | | | **144** | **80** |

The GDN graph calls `build_lora_mm` for `wqkv` and `wqkv_gate` with the same `input` tensor in [build_qkvz](../src/models/qwen35.cpp#L239-L252). Full attention passes the same `cur` into the separate Q/K/V projections in [build_layer_attn](../src/models/qwen35.cpp#L268-L285); the GGUF has no fused QKV weight for these layers. These graph edges establish common tensor identity and producer, rather than inferring equality from coincident device pointers.

At decode batch one, the source activation is F32 with logical shape `[5120,1,1,1]`, contiguous dimension-zero stride 4 bytes and row pitch 20480 bytes. `build_norm` selects non-in-place `ggml_rms_norm` in [llama-graph.cpp](../src/llama-graph.cpp#L1720-L1735); RMS norm creates a duplicate tensor with canonical contiguous strides ([ggml.c](../ggml/src/ggml.c#L3188-L3200), [ggml.c](../ggml/src/ggml.c#L1915-L1917)). Its values are the same normalized layer output for all sibling projections. The MMVQ path in [mmvq.cu](../ggml/src/ggml-cuda/mmvq.cu#L1551-L1586) quantizes `src1` into `block_q8_1`; it pads `ne10` to `MATRIX_ROW_PADDING=512` ([common.cuh](../ggml/src/ggml-cuda/common.cuh#L187)). Since 5120 is divisible by 512, padded width remains 5120 (160 Q8_1 blocks of 32 values per row). All listed consumers use the same q8_1 activation representation, independent of the weight quantization type. No activation transform sits between these sibling projection inputs.

The MLP gate/up pair is not counted: the active decode path fuses it into a single MMVQ operation, so the trace has one activation quantization for that fused invocation. The down projection consumes a different activation with width 17408. GDN `ssm_out` consumes its own width-6144 activation. GDN `ssm_alpha` and `ssm_beta` also read `cur`, but their BF16 weights use the separate BF16 matvec path rather than q8_1. These do not add q8_1 reuse candidates.

## Trace and cost estimate

The minimal active-F collection is [command.txt](command.txt), with raw ROCm traces in [trace/](trace/), environment in [environment.txt](environment.txt), and summarized kernel times in [summary.txt](summary.txt). Effective command parameters were `-dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -p 0 -n 1 -d 0`; MTP was disabled. HIP graphs were enabled and `GGML_CUDA_GRAPH_OPT` was unset. No prompt-prefill was included.

The short run contains the normal warmup generation and one measured generation. ROCm kernel trace has no llama-bench phase markers, so the two structurally matching decode passes cannot be labelled separately in the CSV. Counts divide evenly between them and match the prior C d=0 trace at 384 q8_1 calls per token. The summary's summed-kernel denominator is 51.443 ms and includes setup plus the warmup and measured decode passes; q8_1 is 2.58% of that denominator. The profiler result is not a normal throughput measurement.

| q8_1 input width (`Grid_Size_X`) | Calls in trace | Calls/token | Trace time | Mean per call |
|---:|---:|---:|---:|---:|
| 5120 | 512 | 256 | 0.878487 ms | 1.7158 us |
| 6144 | 128 | 64 | 0.220561 ms | 1.7231 us |
| 17408 | 128 | 64 | 0.228001 ms | 1.7813 us |
| **All widths** | **768** | **384** | **1.327049 ms** | **1.7279 us** |

The 80 identified redundant calls are all width 5120: 48 from GDN sibling projections and 32 from full-attention Q/K/V groups. At the observed width-5120 mean, their q8_1 kernel time is approximately `80 x 1.7158 us = 137.3 us/token`. This is 20.7% of the observed q8_1 time per token, or 31.25% of width-5120 quantization time. It is about 0.49% of the prior unprofiled F d=0 token latency (`35.8866 tok/s`, from the F decode report) if every microsecond removed translated directly to wall time. Treat that as an optimistic ceiling, not a predicted gain: profiler kernel-duration sums do not account for host launch costs, overlap, graph effects, or changes in scheduling. The profiler's `avg_ts` must not be compared with the unprofiled result.

Prefill is not included in this estimate. MMVQ is the decode route for the observed batch-one workload; larger prefill batches can dispatch MMQ instead and need separate accounting.

## Lifetime, overwrite, stream, and graph constraints

- During each layer's sibling projections, `cur` is an input and the projection outputs are distinct tensors. The graph has no intervening in-place transform of `cur` before the sibling reads. The source remains live through its final consumer, but a later graph allocation may reuse its memory after that point.
- Pointer equality alone is insufficient. A safe key must include source tensor identity plus type, all dimensions, all strides, and padded quantized extent. Reused allocator addresses can hold different values in later graph evaluations.
- The current MMVQ implementation allocates `src1_q8_1` from the temporary CUDA/HIP pool inside each call ([mmvq.cu](../ggml/src/ggml-cuda/mmvq.cu#L1551-L1558)). That scratch lifetime is not an adequate persistent cache lifetime. A reuse experiment would need a context-owned, fixed-address q8_1 buffer large enough for the active shape and allocated outside graph capture.
- HIP graphs are enabled. Graph capture records the first q8_1 quantization and later sibling MMVQ consumers on the same stream; replay must run that producer quantization on every replay. Cache bookkeeping must be reset when building/evaluating a new graph, and a write that overlaps a cached activation must invalidate its entry. Graph recapture/update and direct non-graph evaluation also need correct reset behavior.
- For this run, `GGML_CUDA_GRAPH_OPT` was unset. The optional concurrent-stream scheduling path returns early when unset ([ggml-cuda.cu](../ggml/src/ggml-cuda/ggml-cuda.cu#L5034-L5048)); the captured graph is launched on the backend's current stream ([ggml-cuda.cu](../ggml/src/ggml-cuda/ggml-cuda.cu#L4790-L4799)). If concurrent streams are enabled later, only reuse with an explicit producer-consumer stream dependency is safe. The simpler experiment should skip concurrent regions and `MUL_MAT_ID`/ids paths.
- Any cached source whose backing range may be overwritten or aliased must invalidate before reuse. In-place nodes, views with overlapping ranges, pointer reuse, graph shape changes, and a replay with a different input are concrete hazards.

## External implementation comparison

The referenced [commit e3c431b](https://github.com/achyudh/llama.cpp/commit/e3c431b2d162a2d389517c3551065da94209048f) implements q8_1 reuse using persistent context storage, activation metadata checks, graph/capture-aware invalidation, and exclusions for paths that do not fit its reuse assumptions. Its patch also contains concurrent matmul execution changes and broader tests; those are not required to test same-stream q8_1 reuse here and should not be imported with it. Its RX 9070 XT results are external evidence that the idea can help another workload, not a performance prediction for this RX 7800 XT or model configuration.

The minimum isolated experiment here would add only context-scoped q8_1 reuse for same-stream MMVQ consumers. It would need exact key validation (type, shape, strides, padding), stable storage outside capture, graph-start/replay-safe producer behavior, invalidation on overlapping writes or pointer reuse, and a conservative bypass for `ids` and concurrent-stream regions. Tests should cover the GDN pair, Q/K/V siblings, graph capture and replay with changing activation contents, in-place overwrite, views/stride mismatch, and existing relevant backend cases. No matmul concurrency mechanism is needed.

## Recommendation

Prioritize another measured MMVQ kernel-level opportunity before implementing a q8_1 cache. The trace's largest quantized weight groups are IQ3_S (18.01%), IQ3_XXS (16.42%), and IQ2_S (14.22%) of the 51.443 ms summed-kernel denominator. The cache opportunity is real and well identified, but its direct q8 kernel-time ceiling is only about half a percent of prior full-model decode latency, while correct handling of temporary memory, graph replay, overwrite, and stream ordering adds nontrivial complexity. Revisit it if a new end-to-end measurement or graph-launch analysis shows a larger benefit. Do not repeat prior inconclusive IQ3_S accumulator splitting or rejected direct-sign variants without a new code-generation hypothesis.
