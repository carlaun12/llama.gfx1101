#include <cstdint>
#include <cstdio>
#include <vector>

#include <hip/hip_runtime.h>
#include "ggml-cuda/vendors/hip.h"

#define GGML_COMMON_DECL_HIP
#define GGML_COMMON_IMPL_HIP
#include "ggml-common.h"

struct result_t {
    uint32_t expected_mask;
    uint32_t actual_mask;
    uint32_t expected_grid;
    uint32_t actual_grid;
    uint32_t zero_lanes;
};

__global__ void check_iq2s_direct_signs(result_t * results, int count) {
    const int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) {
        return;
    }

    const int grid_index = i / 512;
    const uint32_t sign_byte = (i / 2) % 256;
    const bool high = (i & 1) != 0;
    const uint32_t nibble = high ? sign_byte >> 4 : sign_byte & 0x0fu;
    const uint64_t row = iq2s_grid[grid_index];
    const uint32_t grid = (uint32_t) (row >> (high ? 32 : 0));
    const uint32_t bits = (nibble * 0x00204081u) & 0x01010101u;
    const uint32_t mask = bits * 255u;

    uint32_t expected_mask = 0;
    uint32_t expected_grid = 0;
    uint32_t zero_lanes = 0;
#pragma unroll
    for (int lane = 0; lane < 4; ++lane) {
        const uint32_t magnitude = (grid >> (8 * lane)) & 0xffu;
        const bool negative = (nibble & (1u << lane)) != 0;
        expected_mask |= (negative ? 0xffu : 0u) << (8 * lane);
        expected_grid |= (negative ? (0u - magnitude) & 0xffu : magnitude) << (8 * lane);
        zero_lanes |= (magnitude == 0) << lane;
    }

    results[i] = { expected_mask, mask, expected_grid, (grid ^ mask) + bits, zero_lanes };
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
    constexpr int count = 1024 * 256 * 2;
    result_t * device_results = nullptr;
    HIP_CHECK(hipMalloc(&device_results, sizeof(result_t) * count));

    check_iq2s_direct_signs<<<(count + 255) / 256, 256>>>(device_results, count);
    HIP_CHECK(hipGetLastError());

    std::vector<result_t> results(count);
    HIP_CHECK(hipMemcpy(results.data(), device_results, sizeof(result_t) * count, hipMemcpyDeviceToHost));
    HIP_CHECK(hipFree(device_results));

    int mask_mismatches = 0;
    int grid_mismatches = 0;
    int zero_halves = 0;
    for (int i = 0; i < count; ++i) {
        const result_t & result = results[i];
        mask_mismatches += result.expected_mask != result.actual_mask;
        grid_mismatches += result.expected_grid != result.actual_grid;
        if ((i % 512) < 2) {
            zero_halves += result.zero_lanes != 0;
        }
    }

    if (mask_mismatches != 0 || grid_mismatches != 0 || zero_halves != 0) {
        std::fprintf(stderr, "FAIL: %d mask mismatches, %d packed-grid mismatches, %d table halves with zero lanes\n",
                mask_mismatches, grid_mismatches, zero_halves);
        return 1;
    }

    std::printf("PASS: %d table entries x 256 sign bytes x 2 grid halves; exact masks and packed operands, no zero lanes\n",
            1024);
    return 0;
}
