#include "ggml.h"
#include "ggml-cpu.h"
#include "ggml-impl.h"
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <vector>

int main() {
    ggml_cpu_init();
    for (ggml_type type : {GGML_TYPE_F32, GGML_TYPE_Q8_0}) {
        for (int tokens : {1, 17, 512}) {
            for (int sequences : {1, 2}) {
                constexpr int width = 5120, heads = 48;
                ggml_context * ctx = ggml_init({128 * 1024 * 1024, nullptr, false});
                GGML_ASSERT(ctx);
                auto * weights = ggml_new_tensor_2d(ctx, type, width, heads);
                auto * input = ggml_new_tensor_2d(ctx, GGML_TYPE_F32, width, tokens * sequences);
                auto * bias = ggml_new_tensor_1d(ctx, GGML_TYPE_F32, heads);
                auto * decay = ggml_new_tensor_1d(ctx, GGML_TYPE_F32, heads);
                std::vector<float> values(width * heads);
                for (size_t i = 0; i < values.size(); ++i) values[i] = 0.01f * std::sin(float(i));
                if (type == GGML_TYPE_F32) std::memcpy(weights->data, values.data(), ggml_nbytes(weights));
                else ggml_quantize_chunk(type, values.data(), weights->data, 0, heads, width, nullptr);
                for (int64_t i = 0; i < ggml_nelements(input); ++i) ((float *) input->data)[i] = std::cos(float(i) * 0.1f);
                for (int i = 0; i < heads; ++i) {
                    ((float *) bias->data)[i] = float(i - heads / 2);
                    ((float *) decay->data)[i] = -0.1f * float(i + 1);
                }
                auto * old_projection = ggml_mul_mat(ctx, weights, input);
                auto * old_alpha = ggml_add(ctx, ggml_reshape_3d(ctx, old_projection, heads, tokens, sequences), bias);
                auto * old_output = ggml_mul(ctx, ggml_softplus(ctx, old_alpha), decay);
                auto * new_projection = ggml_mul_mat(ctx, weights, input);
                auto * new_bias = ggml_add(ctx, new_projection, bias);
                auto * new_alpha = ggml_reshape_3d(ctx, new_bias, heads, tokens, sequences);
                auto * new_output = ggml_mul(ctx, ggml_softplus(ctx, new_alpha), decay);
                auto * graph = ggml_new_graph(ctx);
                ggml_build_forward_expand(graph, new_output);
                GGML_ASSERT(ggml_can_fuse(graph, 0, {GGML_OP_MUL_MAT, GGML_OP_ADD}));
                ggml_build_forward_expand(graph, old_output);
                GGML_ASSERT(ggml_graph_compute_with_ctx(ctx, graph, 4) == GGML_STATUS_SUCCESS);
                GGML_ASSERT(ggml_are_same_shape(old_output, new_output));
                float max_error = 0;
                for (int64_t i = 0; i < ggml_nelements(new_output); ++i) {
                    const float a = ((float *) old_output->data)[i], b = ((float *) new_output->data)[i];
                    GGML_ASSERT(std::isfinite(a) && std::isfinite(b));
                    max_error = std::max(max_error, std::abs(a - b));
                }
                std::printf("%s tokens=%d sequences=%d max_error=%g fusion_pattern=PASS\n", ggml_type_name(type), tokens, sequences, max_error);
                GGML_ASSERT(max_error == 0);
                ggml_free(ctx);
            }
        }
    }
    ggml_quantize_free();
}
