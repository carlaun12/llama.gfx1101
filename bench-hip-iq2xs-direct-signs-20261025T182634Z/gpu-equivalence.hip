#include <cstdint>
#include <cstdio>
#include <vector>

#include <hip/hip_runtime.h>
#include "ggml-cuda/vendors/hip.h"

#define GGML_COMMON_DECL_HIP
#define GGML_COMMON_IMPL_HIP
#include "ggml-common.h"

struct result_t {
    uint32_t control;
    uint32_t candidate;
    uint32_t reference;
};

__global__ void check_iq2xs_signs(result_t * results, int count) {
    const int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) {
        return;
    }

    const int half = i & 1;
    const int sign_index = (i >> 1) % 128;
    const int grid_index = i / (2 * 128);
    const uint8_t packed_signs = (uint8_t) sign_index;
    const uint64_t row = iq2xs_grid[grid_index];
    const uint32_t grid = (uint32_t) (row >> (half ? 32 : 0));
    const uint32_t selector = half ? 0x80402010u : 0x08040201u;

    const uint32_t parity_signs = __popc(packed_signs) & 1u;
    const uint32_t control_sign_byte = packed_signs ^ (parity_signs << 7);
    const uint32_t control_signs = __builtin_amdgcn_perm(0, control_sign_byte, 0);
    const int control_mask = __vcmpne4(control_signs & selector, 0);
    const uint32_t control = (uint32_t) __vsub4((int) (grid ^ (uint32_t) control_mask), control_mask);

    const uint32_t m = (((control_signs & selector) + 0x7f7f7f7fu) >> 7) & 0x01010101u;
    const uint32_t mask = (m << 8) - m;
    const uint32_t candidate = (grid ^ mask) + m;

    uint32_t ref_parity = 0;
#pragma unroll
    for (int bit = 0; bit < 7; ++bit) {
        ref_parity ^= (packed_signs >> bit) & 1u;
    }
    const uint8_t ref_sign_byte = packed_signs | (uint8_t) (ref_parity << 7);
    uint32_t reference = 0;
#pragma unroll
    for (int lane = 0; lane < 4; ++lane) {
        const uint32_t magnitude = (grid >> (8 * lane)) & 0xffu;
        const int sign_lane = half ? lane + 4 : lane;
        const bool negative = ((ref_sign_byte >> sign_lane) & 1u) != 0;
        const uint32_t value = negative ? (0u - magnitude) & 0xffu : magnitude;
        reference |= value << (8 * lane);
    }

    results[i] = { control, candidate, reference };
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
    constexpr int count = 512 * 128 * 2;
    result_t * device_results = nullptr;
    HIP_CHECK(hipMalloc(&device_results, sizeof(result_t) * count));

    check_iq2xs_signs<<<(count + 255) / 256, 256>>>(device_results, count);
    HIP_CHECK(hipGetLastError());

    std::vector<result_t> results(count);
    HIP_CHECK(hipMemcpy(results.data(), device_results, sizeof(result_t) * count, hipMemcpyDeviceToHost));
    HIP_CHECK(hipFree(device_results));

    int mismatches = 0;
    for (int i = 0; i < count; ++i) {
        mismatches += results[i].control != results[i].candidate;
        mismatches += results[i].control != results[i].reference;
    }
    if (mismatches != 0) {
        std::fprintf(stderr, "FAIL: %d packed-byte mismatches over %d valid cases\n", mismatches, count);
        return 1;
    }

    std::printf("PASS: %d IQ2_XS table entries x 128 valid sign patterns x 2 halves; E, direct formula, and byte reference match exactly\n", 512);
    return 0;
}
