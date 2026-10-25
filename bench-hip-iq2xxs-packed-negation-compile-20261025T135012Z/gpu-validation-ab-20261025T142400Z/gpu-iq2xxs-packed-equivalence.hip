#include <cstdint>
#include <cstdio>
#include <vector>

#include <hip/hip_runtime.h>
#include "ggml-cuda/vendors/hip.h"

#define GGML_COMMON_DECL_HIP
#define GGML_COMMON_IMPL_HIP
#include "ggml-common.h"

struct result_t {
    uint32_t table_index;
    uint32_t raw_signs;
    uint32_t half;
    uint32_t sign_mask;
    uint32_t reference_mask;
    uint32_t grid;
    uint32_t control;
    uint32_t candidate;
    uint32_t reference;
    uint32_t zero_lane_mask;
    uint32_t carry_mask;
};

__device__ static uint32_t unpack_iq2xxs_signs(uint32_t raw) {
    const uint32_t parity = __popc(raw) & 1u;
    const uint32_t signs = raw ^ (parity << 7);
    return signs * 0x01010101u;
}

__global__ void check_iq2xxs_packed_negation(result_t * results, uint32_t count) {
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) {
        return;
    }

    const uint32_t table_index = i / (128u * 2u);
    const uint32_t raw_signs = (i / 2u) % 128u;
    const uint32_t half = i & 1u;
    const uint2 grid_pos = ((const uint2 *) iq2xxs_grid)[table_index];
    const uint32_t grid = half ? grid_pos.y : grid_pos.x;
    const uint32_t signs = unpack_iq2xxs_signs(raw_signs);
    const uint32_t selector = half ? 0x80402010u : 0x08040201u;
    const uint32_t sign_mask = (uint32_t) __vcmpne4((int) (signs & selector), 0);

    const uint32_t control = (uint32_t) __vsub4((int) (grid ^ sign_mask), (int) sign_mask);
    const uint32_t candidate = (grid ^ sign_mask) + (sign_mask & 0x01010101u);

    uint32_t reference_mask = 0;
    uint32_t reference = 0;
    uint32_t zero_lane_mask = 0;
    uint32_t carry_mask = 0;
#pragma unroll
    for (uint32_t lane = 0; lane < 4; ++lane) {
        const uint32_t magnitude = (grid >> (lane * 8u)) & 0xffu;
        const bool negative = ((raw_signs ^ ((__popc(raw_signs) & 1u) << 7)) & (1u << (lane + half * 4u))) != 0;
        const uint32_t sign_byte = negative ? 0xffu : 0u;
        const uint32_t result_byte = negative ? (0u - magnitude) & 0xffu : magnitude;
        const uint32_t candidate_sum = (magnitude ^ sign_byte) + (sign_byte & 1u);

        reference_mask |= sign_byte << (lane * 8u);
        reference |= result_byte << (lane * 8u);
        zero_lane_mask |= (magnitude == 0u) << lane;
        carry_mask |= (candidate_sum > 0xffu) << lane;
    }

    results[i] = { table_index, raw_signs, half, sign_mask, reference_mask, grid,
        control, candidate, reference, zero_lane_mask, carry_mask };
}

static bool check(hipError_t error, const char * expression, int line) {
    if (error == hipSuccess) {
        return true;
    }
    std::fprintf(stderr, "line %d: %s: %s\n", line, expression, hipGetErrorString(error));
    return false;
}

#define HIP_CHECK(expression) do { if (!check((expression), #expression, __LINE__)) return 1; } while (0)

int main() {
    constexpr uint32_t count = 256u * 128u * 2u;
    result_t * device_results = nullptr;
    HIP_CHECK(hipMalloc(&device_results, sizeof(result_t) * count));

    check_iq2xxs_packed_negation<<<(count + 255u) / 256u, 256u>>>(device_results, count);
    HIP_CHECK(hipGetLastError());

    std::vector<result_t> results(count);
    HIP_CHECK(hipMemcpy(results.data(), device_results, sizeof(result_t) * count, hipMemcpyDeviceToHost));
    HIP_CHECK(hipFree(device_results));

    uint32_t mask_mismatches = 0;
    uint32_t control_mismatches = 0;
    uint32_t candidate_mismatches = 0;
    uint32_t zero_lanes = 0;
    uint32_t carry_lanes = 0;
    uint32_t min_magnitude = 0xffu;
    uint32_t max_magnitude = 0;
    uint8_t magnitudes[256] = {};

    for (uint32_t i = 0; i < count; ++i) {
        const result_t & result = results[i];
        const uint32_t expected_index = i / (128u * 2u);
        const uint32_t expected_raw = (i / 2u) % 128u;
        const uint32_t expected_half = i & 1u;
        if (result.table_index != expected_index || result.raw_signs != expected_raw || result.half != expected_half) {
            std::fprintf(stderr, "FAIL: coverage mismatch at case %u\n", i);
            return 1;
        }

        mask_mismatches += result.sign_mask != result.reference_mask;
        control_mismatches += result.control != result.reference;
        candidate_mismatches += result.candidate != result.reference;
        zero_lanes += __builtin_popcount(result.zero_lane_mask);
        carry_lanes += __builtin_popcount(result.carry_mask);

        for (uint32_t lane = 0; lane < 4; ++lane) {
            const uint32_t magnitude = (result.grid >> (lane * 8u)) & 0xffu;
            magnitudes[magnitude] = 1;
            min_magnitude = magnitude < min_magnitude ? magnitude : min_magnitude;
            max_magnitude = magnitude > max_magnitude ? magnitude : max_magnitude;
        }
    }

    uint32_t unique_magnitudes = 0;
    for (uint32_t i = 0; i < 256; ++i) {
        unique_magnitudes += magnitudes[i] != 0;
    }

    if (mask_mismatches || control_mismatches || candidate_mismatches || zero_lanes || carry_lanes) {
        std::fprintf(stderr,
            "FAIL: mask=%u control=%u candidate=%u zero_lanes=%u carry_lanes=%u\n",
            mask_mismatches, control_mismatches, candidate_mismatches, zero_lanes, carry_lanes);
        return 1;
    }

    std::printf("PASS: %u GPU cases (256 table entries x 128 valid sign encodings x 2 halves); "
        "exact control/candidate/reference match; %u nonzero magnitudes in [%u,%u]; no carry\n",
        count, unique_magnitudes, min_magnitude, max_magnitude);
    return 0;
}
