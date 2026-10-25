#include <cstdint>
#include <cstdio>
#include <vector>

#include <hip/hip_runtime.h>
#include "ggml-cuda/vendors/hip.h"

#define GGML_COMMON_DECL_HIP
#define GGML_COMMON_IMPL_HIP
#include "ggml-common.h"

struct result_t {
    uint32_t old_mask;
    uint32_t direct_mask;
    uint32_t old_grid;
    uint32_t direct_grid;
    uint32_t expected_grid;
    uint32_t zero_lanes;
};

__global__ void check_iq3xxs_direct_signs(result_t * results, int count) {
    const int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) {
        return;
    }

    const uint32_t grid_index = i / 256;
    const uint32_t raw = (i / 2) % 128;
    const bool high = (i & 1) != 0;
    const uint32_t signs = raw | ((__popc(raw) & 1u) << 7);
    const uint32_t old_signs = raw ^ ((__popc(raw) & 1u) << 7);
    const uint32_t broadcast = old_signs * 0x01010101u;
    const uint32_t selector = high ? 0x80402010u : 0x08040201u;
    const uint32_t bits = (((high ? signs >> 4 : signs) & 15u) * 0x00204081u) & 0x01010101u;
    const uint32_t mask = bits * 255u;
    const uint32_t grid = iq3xxs_grid[grid_index];
    const uint32_t old_mask = (uint32_t) __vcmpne4((int) (broadcast & selector), 0);

    uint32_t expected_grid = 0;
    uint32_t zero_lanes = 0;
#pragma unroll
    for (int lane = 0; lane < 4; ++lane) {
        const uint32_t magnitude = (grid >> (8 * lane)) & 0xffu;
        const bool negative = ((signs >> (lane + (high ? 4 : 0))) & 1u) != 0;
        expected_grid |= (negative ? (0u - magnitude) & 0xffu : magnitude) << (8 * lane);
        zero_lanes |= (magnitude == 0) << lane;
    }

    const uint32_t old_grid = (grid ^ old_mask) + (old_mask & 0x01010101u);
    const uint32_t direct_grid = (grid ^ mask) + bits;
    results[i] = { old_mask, mask, old_grid, direct_grid, expected_grid, zero_lanes };
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
    constexpr int count = 256 * 128 * 2;
    result_t * device_results = nullptr;
    HIP_CHECK(hipMalloc(&device_results, sizeof(result_t) * count));

    check_iq3xxs_direct_signs<<<(count + 255) / 256, 256>>>(device_results, count);
    HIP_CHECK(hipGetLastError());

    std::vector<result_t> results(count);
    HIP_CHECK(hipMemcpy(results.data(), device_results, sizeof(result_t) * count, hipMemcpyDeviceToHost));
    HIP_CHECK(hipFree(device_results));

    int mask_mismatches = 0;
    int grid_mismatches = 0;
    int zero_halves = 0;
    for (int i = 0; i < count; ++i) {
        const result_t & result = results[i];
        mask_mismatches += result.old_mask != result.direct_mask;
        grid_mismatches += result.old_grid != result.expected_grid || result.direct_grid != result.expected_grid;
        zero_halves += result.zero_lanes != 0;
    }

    if (mask_mismatches != 0 || grid_mismatches != 0 || zero_halves != 0) {
        std::fprintf(stderr, "FAIL: %d mask mismatches, %d packed-grid mismatches, %d table entries with zero lanes\n",
                mask_mismatches, grid_mismatches, zero_halves);
        return 1;
    }

    std::printf("PASS: 256 IQ3_XXS table entries x 128 raw sign bytes x 2 grid halves; exact masks and packed operands, no zero lanes\n");
    return 0;
}
