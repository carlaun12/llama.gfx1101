#include <cstdint>
#include <cstdio>
#include <vector>

#include <hip/hip_runtime.h>
#include "ggml-cuda/vendors/hip.h"

#define GGML_COMMON_DECL_HIP
#define GGML_COMMON_IMPL_HIP
#include "ggml-common.h"

struct result_t {
    uint32_t expected;
    uint32_t actual;
    uint32_t zero_lanes;
};

__global__ void check_iq3xxs_signs(result_t * results, int count) {
    const int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) {
        return;
    }

    const int grid_index = i / 256;
    const int raw = (i / 2) % 128;
    const bool high = (i & 1) != 0;
    const uint32_t p = __popc(raw) & 1u;
    const uint32_t signs = (raw ^ (p << 7)) * 0x01010101u;
    const uint32_t grid = iq3xxs_grid[grid_index];
    const int sign_mask = high
        ? __vcmpne4(signs & 0x80402010u, 0)
        : __vcmpne4(signs & 0x08040201u, 0);
    const uint32_t bits = (uint32_t) sign_mask & 0x01010101u;

    results[i].expected = (uint32_t) __vsub4((int) (grid ^ (uint32_t) sign_mask), sign_mask);
    results[i].actual = (grid ^ (uint32_t) sign_mask) + bits;
    results[i].zero_lanes = 0;
#pragma unroll
    for (int lane = 0; lane < 4; ++lane) {
        results[i].zero_lanes |= (((grid >> (8 * lane)) & 0xffu) == 0) << lane;
    }
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

    check_iq3xxs_signs<<<(count + 255) / 256, 256>>>(device_results, count);
    HIP_CHECK(hipGetLastError());

    std::vector<result_t> results(count);
    HIP_CHECK(hipMemcpy(results.data(), device_results, sizeof(result_t) * count, hipMemcpyDeviceToHost));
    HIP_CHECK(hipFree(device_results));

    int mismatches = 0;
    int zero_entries = 0;
    for (int grid = 0; grid < 256; ++grid) {
        zero_entries += results[grid * 256].zero_lanes != 0;
        for (int j = 0; j < 256; ++j) {
            const result_t & result = results[grid * 256 + j];
            if (result.expected != result.actual) {
                if (mismatches++ == 0) {
                    std::fprintf(stderr, "first mismatch: grid=%d case=%d expected=%08x actual=%08x\n",
                            grid, j, result.expected, result.actual);
                }
            }
        }
    }

    if (mismatches != 0 || zero_entries != 0) {
        std::fprintf(stderr, "FAIL: %d mismatches, %d table entries with zero lanes\n", mismatches, zero_entries);
        return 1;
    }

    std::printf("PASS: %d table entries, %d low/high parity-corrected sign cases, exact packed equality, no zero lanes\n",
            256, count);
    return 0;
}
