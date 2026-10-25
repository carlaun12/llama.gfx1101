#include <cstdint>
#include <cstdio>
#include <vector>

#include <hip/hip_runtime.h>
#include "ggml-cuda/common.cuh"

struct result_t {
    int32_t control;
    int32_t candidate;
    int64_t reference;
};

__device__ int8_t activation_value(int pattern, int index, int term, int lane) {
    switch (pattern) {
        case 0: return -128;
        case 1: return 127;
        case 2: return (lane & 1) ? 127 : -128;
        case 3: return (lane & 1) ? -128 : 127;
        case 4: {
            const int values[4] = {-128, -1, 0, 127};
            return values[lane];
        }
        case 5: {
            const int values[4] = {127, 0, -1, -128};
            return values[lane];
        }
        case 6: return (int8_t) ((index * 37 + term * 61 + lane * 83 + 19) & 255);
        default: return (int8_t) ((index * 73 + term * 29 + lane * 107 + 151) & 255);
    }
}

__global__ void check_accumulation(result_t * results, int count) {
    const int case_id = blockIdx.x * blockDim.x + threadIdx.x;
    if (case_id >= count) {
        return;
    }

    int value = case_id;
    const int pattern = value % 8;
    value /= 8;
    const int target_term = value % 8;
    value /= 8;
    const int sign_nibble = value % 16;
    const int base_index = value / 16;

    int control = 0;
    int candidate_even = 0;
    int candidate_odd = 0;
    int64_t reference = 0;

#pragma unroll
    for (int term = 0; term < 8; ++term) {
        const int index = term == target_term ? base_index : (base_index + term * 71 + pattern * 19 + sign_nibble * 13) & 511;
        const int nibble = term == target_term ? sign_nibble : (sign_nibble + term * 7 + pattern) & 15;
        const uint32_t bits = ((uint32_t) nibble * 0x00204081u) & 0x01010101u;
        const uint32_t grid = (iq3s_grid[index] ^ (bits * 255u)) + bits;

        uint32_t activation = 0;
#pragma unroll
        for (int lane = 0; lane < 4; ++lane) {
            activation |= (uint32_t) (uint8_t) activation_value(pattern, base_index, term, lane) << (8 * lane);
        }

        control = ggml_cuda_dp4a((int) grid, (int) activation, control);
        if (term & 1) {
            candidate_odd = ggml_cuda_dp4a((int) grid, (int) activation, candidate_odd);
        } else {
            candidate_even = ggml_cuda_dp4a((int) grid, (int) activation, candidate_even);
        }

#pragma unroll
        for (int lane = 0; lane < 4; ++lane) {
            const int8_t weight = (int8_t) ((grid >> (8 * lane)) & 255u);
            const int8_t x = (int8_t) ((activation >> (8 * lane)) & 255u);
            reference += (int64_t) weight * (int64_t) x;
        }
    }

    results[case_id].control = control;
    results[case_id].candidate = candidate_even + candidate_odd;
    results[case_id].reference = reference;
}

static bool hip_check(hipError_t error, const char * expression, int line) {
    if (error == hipSuccess) {
        return true;
    }
    std::fprintf(stderr, "line %d: %s: %s\n", line, expression, hipGetErrorString(error));
    return false;
}

#define HIP_CHECK(expression) do { if (!hip_check((expression), #expression, __LINE__)) return 1; } while (0)

int main() {
    constexpr int count = 512 * 16 * 8 * 8;
    result_t * device_results = nullptr;
    HIP_CHECK(hipMalloc(&device_results, sizeof(result_t) * count));
    check_accumulation<<<(count + 255) / 256, 256>>>(device_results, count);
    HIP_CHECK(hipGetLastError());

    std::vector<result_t> results(count);
    HIP_CHECK(hipMemcpy(results.data(), device_results, sizeof(result_t) * count, hipMemcpyDeviceToHost));
    HIP_CHECK(hipFree(device_results));

    int mismatches = 0;
    int64_t max_abs = 0;
    for (int i = 0; i < count; ++i) {
        const result_t & result = results[i];
        if (result.control != result.candidate || result.control != result.reference) {
            if (mismatches++ == 0) {
                std::fprintf(stderr, "first mismatch: case=%d control=%d candidate=%d reference=%lld\n",
                        i, result.control, result.candidate, (long long) result.reference);
            }
        }
        const int64_t value = result.reference < 0 ? -result.reference : result.reference;
        if (value > max_abs) {
            max_abs = value;
        }
    }

    if (mismatches != 0) {
        std::fprintf(stderr, "FAIL: %d mismatches across %d cases\n", mismatches, count);
        return 1;
    }

    std::printf("PASS: %d GPU cases; control recurrence, two accumulators, and int64 scalar reference match exactly; max_abs=%lld\n",
            count, (long long) max_abs);
    return 0;
}
